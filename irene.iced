_ = require 'underscore'
async = require 'async'
fs = require 'fs'
request = require 'request'
slackNotify = require('slack-notify') process.env.SLACK_WEBHOOK_URL
wolframAlpha = new (require 'node-wolfram') process.env.WOLFRAM_APP_ID
spintax = require 'spintax'
util = require 'util'
websocket = require 'nodejs-websocket'

module.exports = exports = class Irene
	constructor: ->
		@cmds = new Irene.Commands
		for filename in fs.readdirSync "#{__dirname}/cmds"
			require("#{__dirname}/cmds/#{filename}").bind? @

		@q = async.queue (v, done) =>
			ctx = new Irene.Context @conn, @chans[v.channel], @users[v.user]

			switch yes
				when v.type is 'message' and not v.subtype and v.user isnt @self.id
					if not ctx.chan or not ctx.user
						return done()

					ctx.msg = v.text

					if ctx.chan.id[0] isnt 'D' and ctx.msg.indexOf("<@#{@self.id}>") is -1
						return done()

					ctx.msg = ctx.msg
						.replace("<@#{@self.id}>", '')
						.replace(/\s+/, ' ')
						.replace(/^[:.\s]+/, '')
						.replace(/[.?\s]+$/, '')

					@do ctx

			done()

	initialize: (done) ->
		await request.get "https://slack.com/api/users.list?token=#{process.env.SLACK_API_TOKEN}", defer err, resp, body
		if err?
			return console.log err

		body = JSON.parse body

		@users = {}
		for user in body.members
			@users[user.id] = user
			@users["@#{user.name}"] = user

		await request.get "https://slack.com/api/channels.list?token=#{process.env.SLACK_API_TOKEN}", defer err, resp, body
		if err?
			return console.log err

		body = JSON.parse body

		@chans = {}
		for chan in body.channels
			@chans[chan.id] = chan
			@chans["##{chan.name}"] = chan

		await request.get "https://slack.com/api/im.list?token=#{process.env.SLACK_API_TOKEN}", defer err, resp, body
		if err?
			return console.log err

		body = JSON.parse body

		for chan in body.ims
			@chans[chan.id] = chan

		await request.get "https://slack.com/api/rtm.start?token=#{process.env.SLACK_BOT_TOKEN}", defer err, resp, body
		if err?
			return done err

		body = JSON.parse body

		@self = body.self

		@conn = websocket.connect body.url, -> done()
		@conn.on 'text', (v) =>
			v = JSON.parse v
			@q.push v

	'do': (ctx) ->
		[func, data] = @cmds.find ctx
		if func?
			return func ctx, data

		if process.env.WOLFRAM_APP_ID
			await wolframAlpha.query ctx.msg, defer err, res
			pods = res?.queryresult?.pod
			for pod in pods or []
				if not _.contains(['Input', 'Input interpretation'], pod.$.title)
					if pod.subpod[0].plaintext[0].match /wolfram/i
						break
					#if pod.subpod[0].img[0].$.height <= 20
					ctx.say pod.subpod[0].plaintext[0]
					#else
					#	ctx.say pod.subpod[0].img[0].$.src
					return

		ctx.say [
			'I {do not|don\'t} understand'
			'What do you mean?'
			'And what exactly is that supposed to mean?'
			'{I am|I\'m} not sure I understand'
			'What are you trying to say?'
			'I {do not|don\'t} think I can help you with that'
		]

	say: (chan, msg, done) ->
		if util.isArray msg
				msg = _.sample msg
			msg = spintax.unspin msg
			
		if process.env.SLACK_PRETEND is 'yes'
			return console.log msg

		await @conn.sendText JSON.stringify({
			id: 1
			type: 'message'
			channel: @chans[chan].id
			text: msg
		}), defer err
		if err
			return console.log err

		done()

	@Commands = class Commands
		constructor: ->
			@all = []

		add: (pat, func) ->
			@all.push
				pat: pat
				func: func

		find: (ctx) ->
			for {pat, func} in @all
				switch yes
					when pat instanceof RegExp
						match = ctx.msg.match pat
						if match
							match = match[1...]

					when typeof pat is 'string'
						parts = pat.split ' '
						lines = ctx.msg.split '\n'
						words = lines[0].split ' '
						if lines.length > 1
							words.push lines[1...].join('\n')
						if parts.length > words.length
							continue
						match = {}
						for part, i in parts
							word = words.shift()
							if not word?
								match = null
								break
							if part.match /^:/
								part = part.replace /^:/, ''
								greedy = part.match /\*$/
								if greedy
									part = part.replace /\*$/, ''
								match[part] = word
								if greedy
									while words.length > 0
										match[part] += " #{words.shift()}"
								continue
							if part.toLowerCase() isnt word.toLowerCase()
								match = null
								break

				if match?
					return [func, match]
			return []

	@Context = class Context
		constructor: (@conn, @chan, @user) ->
			@msg = ''

		say: (msg, opts) ->
			if util.isArray msg
				msg = _.sample msg
			msg = spintax.unspin msg

			if process.env.SLACK_PRETEND is 'yes'
				return console.log msg

			await @conn.sendText JSON.stringify({
				id: 1
				type: 'message'
				channel: @chan.id
				text: msg
			}), defer err
			if err
				return console.log err
