fs = require 'fs'
slackNotify = require('slack-notify') process.env.SLACK_WEBHOOK_URL

module.exports = exports = class Irene
	constructor: ->
		@cmds = new Irene.Commands
		for filename in fs.readdirSync "#{__dirname}/cmds"
			require("#{__dirname}/cmds/#{filename}").bind? @

	do: (ctx) ->
		[func, data] = @cmds.find ctx
		if not func?
			return ctx.say 'I don\'t understand'
		func ctx, data

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

	@Context = class Context
		constructor: (data) ->
			@chan = data.channel_name
			@msg = data.text[data.trigger_word.length...]
				.replace(/\s+/, ' ')
				.trim()

		say: (msg) ->
			await slackNotify.send
				channel: "##{@chan}"
				username: process.env.SLACK_USERNAME
				icon_emoji: process.env.SLACK_ICON_EMOJI
				icon_url: process.env.SLACK_ICON_URL
				text: msg
			defer err
			if err?
				return console.log err
