_ = require 'underscore'
querystring = require 'querystring'
request = require 'request'

@bind = (irene) ->
	irene.cmds.add 'youtube :q*', (ctx, {q}) =>
		await request.get 'http://gdata.youtube.com/feeds/api/videos?'+querystring.stringify(q: q, alt: 'json'), defer err, resp, body
		if err?
			return console.log err

		body = JSON.parse body
		if not body.feed.entry?
			return ctx.say 'That\'s one strange video you are looking for!'

		video = _.sample body.feed.entry
		for link in video.link
			if link.rel is 'alternate' and link.type is 'text/html'
				return ctx.say link.href
