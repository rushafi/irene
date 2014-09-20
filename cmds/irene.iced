_ = require 'underscore'
querystring = require 'querystring'
request = require 'request'

@bind = (irene) ->
	irene.cmds.add 'what\'s your name', (ctx, {q}) =>
		ctx.say 'My name is Irene'

	irene.cmds.add 'what is your name', (ctx, {q}) =>
		ctx.say 'My name is Irene'

	irene.cmds.add 'who are you', (ctx, {targ, q}) =>
		ctx.say 'I am Irene'

	irene.cmds.add 'how old are you', (ctx, {targ, q}) =>
		ctx.say 'Why do you ask?'

