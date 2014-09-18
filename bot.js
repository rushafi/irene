express = require('express')
slackNotify = require('slack-notify')(process.env.SLACK_WEBHOOK_URL)

app = express()

app.route('/initiate')
.post(function(req, res, next) {
	slackNotify.send({
		channel: process.env.SLACK_CHANNEL,
		username: process.env.SLACK_USERNAME,
		icon_emoji: process.env.SLACK_ICON_EMOJI,
		text: '@channel It\'s Standup Time! Can everyone answer these following few questions?\n1. What did you do yesterday?\n2. What do you plan on doing today?\n3. Is there anything you\'re blocked on?\n\nAlso, can you please make sure you\'ve updated the Trello board with what you\'re currently working on?'
	}, function(err) {
		if(err) {
			return next(err)
		}
		res.end()
	})
})

app.listen(process.env.PORT, function() {
	console.log('Listening on '+process.env.PORT)
})
