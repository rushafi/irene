_ = require 'underscore'
Poll = require '../models/poll'
querystring = require 'querystring'
request = require 'request'

@bind = (irene) ->
	irene.cmds.add 'start a poll :d*', (ctx, {d}) =>
		cands = {}
		for l in d.split('\n')
			m = l.match /(\d+)\.\s*(.+)/
			if m
				cands[m[1]] = m[2]

		poll = new Poll
			chan: ctx.chan
			cands: cands
			votes: {}
			createdBy: ctx.user.id
			createdAt: null
		await poll.save defer err
		if err?
			if err.code is 11000
				return ctx.say 'One at a time! A poll is already running...'
			return console.log err

		r = "<!everyone> Poll! Let us know what you prefer:\n"
		for key, cand of poll.cands
			r += "#{key}. #{cand}\n"
		keys = _.keys(poll.cands)
		r += "Pick by responding with \"@Irene: I pick <n>\", where _n_ can be #{keys.slice(0, keys.length-1).join(', ')} or #{_.last(keys)}"
		ctx.say r

	irene.cmds.add 'close poll', (ctx) =>
		await Poll.findOne()
		.where('chan', ctx.chan)
		.where('closedAt', null)
		.exec defer err, poll
		if err?
			return console.log err

		if not poll? or poll.createdBy isnt ctx.user.id
			return ctx.say 'You didn\'t start any poll'

		poll.closedAt = new Date()
		await poll.save defer err
		if err?
			return console.log err

		if _.keys(poll.votes).length is 0
			return ctx.say 'Poll closed'

		r = 'Poll closed. Results:\n'
		counts = {}
		for key, cand of poll.cands
			counts[key] = 0
		for user, candKey of poll.votes
			counts[candKey] += 1
		for [cand, count] in _.sortBy(_.pairs(counts), ([candKey, count]) -> -count)
			perc = Math.round(count/_.keys(poll.votes).length*1000)/10
			r += "#{cand}. #{poll.cands[cand]} \u2014 *#{perc}%*\n"
		ctx.say r

	irene.cmds.add 'show poll status', (ctx) =>
		await Poll.findOne()
		.where('chan', ctx.chan)
		.where('closedAt', null)
		.exec defer err, poll
		if err?
			return console.log err

		if not poll?
			return ctx.say 'No poll running'

		if _.keys(poll.votes).length is 0
			return ctx.say 'A poll is running... Awaiting votes...'

		r = 'A poll is running... Current status:\n'
		counts = {}
		for key, cand of poll.cands
			counts[key] = 0
		for user, candKey of poll.votes
			counts[candKey] += 1
		for [cand, count] in _.sortBy(_.pairs(counts), ([candKey, count]) -> -count)
			perc = Math.round(count/_.keys(poll.votes).length*1000)/10
			r += "#{cand}. #{poll.cands[cand]} \u2014 *#{perc}%*\n"
		ctx.say r

	irene.cmds.add /i\s+pick\s+(\d+)/i, (ctx, [n]) =>
		await Poll.findOne()
		.where('chan', ctx.chan)
		.where('closedAt', null)
		.exec defer err, poll
		if err?
			return console.log err

		if not poll?
			return ctx.say 'No active poll exists'

		if not poll.cands[n]?
			return ctx.say "<@#{ctx.user.name}> Did I say you can pick that?"

		poll.votes[ctx.user.id] = n
		poll.markModified("votes.#{ctx.user.id}")
		await poll.save defer err
		if err?
			return console.log err
