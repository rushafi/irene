fs = require 'fs'
slackNotify = require('slack-notify') process.env.SLACK_WEBHOOK_URL
wolframAlpha = new (require 'node-wolfram') process.env.WOLFRAM_APP_ID

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
			if pod.$.title isnt 'Input interpretation'
				if pod.subpod[0].img[0].$.height < 20
					ctx.say pod.subpod[0].plaintext[0]
				else
					ctx.say pod.subpod[0].img[0].$.src
				return

		ctx.say 'I don\'t understand'

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
						data = ctx.msg.match pat
						if match
							data = data[1...]

					when typeof pat is 'string'
						parts = pat.split ' '
						words = ctx.msg.split ' '
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
			@chan = data.channel_name
			@msg = data.text[data.trigger_word.length...]
				.replace(/\s+/, ' ')
				.replace(/^[:.\s]+/, '')
				.trim()

		say: (msg) ->
			if not @chan?
				return console.log msg

			await slackNotify.send
				channel: "##{@chan}"
				username: process.env.SLACK_USERNAME
				icon_emoji: process.env.SLACK_ICON_EMOJI
				icon_url: process.env.SLACK_ICON_URL
				text: msg
				unfurl_links: yes
			defer err
			if err?
				return console.log err
