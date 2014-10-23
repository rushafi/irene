_ = require 'underscore'
querystring = require 'querystring'
request = require 'request'

@bind = (irene) ->
	irene.cmds.add 'ping', (ctx, {q}) =>
		ctx.say 'Pong'

	irene.cmds.add 'what\'s your name', (ctx, {q}) =>
		ctx.say 'My name is Irene'

	irene.cmds.add 'what is your name', (ctx, {q}) =>
		ctx.say 'My name is Irene'

	irene.cmds.add 'who are you', (ctx, {targ, q}) =>
		ctx.say 'I am Irene'

	irene.cmds.add 'who\'re you', (ctx, {targ, q}) =>
		ctx.say 'I am Irene'

	irene.cmds.add 'how old are you', (ctx, {targ, q}) =>
		ctx.say 'Why do you ask?'

	irene.cmds.add 'what is your age', (ctx, {targ, q}) =>
		ctx.say 'Why do you ask?'

	irene.cmds.add 'when were you born', (ctx, {targ, q}) =>
		ctx.say 'Why do you ask?'

	irene.cmds.add 'what is your date of birth', (ctx, {targ, q}) =>
		ctx.say 'Why do you ask?'

	irene.cmds.add 'what is your birthday', (ctx, {targ, q}) =>
		ctx.say 'Why do you ask?'

	irene.cmds.add 'when is your birthday', (ctx, {targ, q}) =>
		ctx.say 'Why do you ask?'

	irene.cmds.add 'what is your birth date', (ctx, {targ, q}) =>
		ctx.say 'Why do you ask?'

	irene.cmds.add 'what makes you tick', (ctx, {targ, q}) =>
		ctx.say 'https://github.com/hjr265/irene'
