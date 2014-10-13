mongoose = require 'mongoose'

schema = new mongoose.Schema
	chan:
		type: String
		required: yes

	cands:
		type: Object
		required: yes

	votes:
		type: Object
		default: -> {}

	createdBy:
		type: String
		required: yes

	closedAt:
		type: Date

schema.index
	chan: 1
	closedAt: 1
, unique: yes

module.exports = exports = Poll = mongoose.model 'Poll', schema
