express = require 'express'
Irene = require './irene'
mongoose = require 'mongoose'
slackNotify = require('slack-notify') process.env.SLACK_WEBHOOK_URL

mongoose.connect process.env.MONGO_URL or process.env.MONGOHQ_URL

irene = new Irene

app = express()

app
.use(require('morgan')('combined'))
.use(require('body-parser').urlencoded(extended: true))

app.route('/api/do-standup')
.post((req, res, next) ->
	await slackNotify.send
		channel: process.env.SLACK_STANDUP_CHANNEL
		username: process.env.SLACK_USERNAME
		icon_emoji: process.env.SLACK_ICON_EMOJI
		icon_url: process.env.SLACK_ICON_URL
		text: '<!everyone> It\'s Standup Time! Can everyone answer these following few questions?\n1. What did you do yesterday?\n2. What do you plan on doing today?\n3. Is there anything you\'re blocked on?\n\nAlso, can you please make sure you\'ve updated the Trello board with what you\'re currently working on?'
	, defer err
	if err?
		return next err
	res.end()
)

app.route('/api/do')
.post((req, res, next) ->
	irene.do new Irene.Context req.body
	res.end()
)

await app.listen (port = process.env.PORT), defer err
if err?
	throw err

console.log "Listening on #{port}"
