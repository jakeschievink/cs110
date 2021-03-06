mongoose = require 'mongoose'
Schema = mongoose.Schema

module.exports = (dateFormatter,CommentsSchema,commentHelper,mdHelper)->
	Hw_submissionsSchema = new Schema {
		user: {type:Schema.Types.ObjectId, ref:"Users"}
		text:{type:String,get:mdHelper.get}
		hw: {type:Schema.Types.ObjectId, ref:"Hws"}
		complete:Boolean
		grader:{type:Schema.Types.ObjectId, ref:"Users"}
		comments: [CommentsSchema]
	}

	Hw_submissionsSchema.post 'save', ->
		self = @
		for p,s of {Users:'user',Hws:'hw'}
			mongoose.model(p).findById @[s], (err,thing)->
				return console.log err if err?
				thing.hw_submissions.addToSet self.id
				thing.save()

	# method to locate all issues by this user for this homework assignment
	Hw_submissionsSchema.methods.issuesByUser = (cb)->
		mongoose.model('Issues').find {user:@user,hw:@hw},cb
		cb()

	Hw_submissionsSchema.virtual('commentNotification').get ->
		"There's been a comment on a homework thread!"

	Hw_submissionsSchema.virtual('incomplete').get ->
		not @complete

	Hw_submissionsSchema.plugin dateFormatter.addon
	Hw_submissionsSchema.plugin commentHelper

	mongoose.model 'Hw_submissions', Hw_submissionsSchema