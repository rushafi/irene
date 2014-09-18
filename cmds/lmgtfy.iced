_ = require 'underscore'
querystring = require 'querystring'
request = require 'request'

@bind = (irene) ->
	irene.cmds.add 'lmgtfy :q*', (ctx, {q}) =>
		ctx.say "http://lmgtfy.com/?q=#{querystring.escape q}"

	irene.cmds.add 'teach :targ how to google :q*', (ctx, {targ, q}) =>
		ctx.say "#{targ}: http://lmgtfy.com/?q=#{querystring.escape q}"
