_ = require 'underscore'
fs = require 'fs'
slackNotify = require('slack-notify') process.env.SLACK_WEBHOOK_URL
wolframAlpha = new (require 'node-wolfram') process.env.WOLFRAM_APP_ID
spintax = require 'spintax'
util = require 'util'

module.exports = exports = class Irene
	constructor: ->
		@cmds = new Irene.Commands
		for filename in fs.readdirSync "#{__dirname}/cmds"
			require("#{__dirname}/cmds/#{filename}").bind? @

	'do': (ctx) ->
		[func, data] = @cmds.find ctx
		if func?
			return func ctx, data

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
		constructor: (data) ->
			@chan =
				id: data.channel_id
				name: data.channel_name
			@msg = data.text[data.trigger_word.length...]
				.replace(/\s+/, ' ')
				.replace(/^[:.\s]+/, '')
				.replace(/[.?\s]+$/, '')
			@user =
				id: data.user_id
				name: data.user_name

		say: (msg, opts) ->
			if util.isArray msg
				msg = _.sample msg
			msg = spintax.unspin msg

			if process.env.SLACK_PRETEND is 'yes'
				return console.log msg

			await slackNotify.send
				channel: opts?.chan or "##{@chan.name}"
				username: process.env.SLACK_USERNAME
				icon_emoji: process.env.SLACK_ICON_EMOJI
				icon_url: process.env.SLACK_ICON_URL
				text: msg
				unfurl_links: opts?.unfurl or yes
			defer err
			if err?
				return console.log err
