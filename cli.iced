Irene = require './irene'

irene = new Irene

ctx = new Irene.Context
	text: process.argv[2...].join ' '
	trigger_word: ''
irene.do ctx
