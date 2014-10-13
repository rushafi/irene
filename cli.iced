Irene = require './irene'
mongoose = require 'mongoose'

mongoose.connect process.env.MONGO_URL or process.env.MONGOHQ_URL

irene = new Irene

ctx = new Irene.Context
	channel_name: process.argv[2]
	user_id: process.argv[3].split('|')[0]
	user_name: process.argv[3].split('|')[1]
	text: process.argv[4]
	trigger_word: ''
irene.do ctx
