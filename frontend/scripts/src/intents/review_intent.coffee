sdk = require('@botfuel/bot-sdk')
User = require('@botfuel/bot-common').User
Log4js = require('log4js')

class ReviewIntent extends sdk.BaseIntent
  LOGGER = Log4js.getLogger('ReviewIntent')

  compute: (id, msg, cb) ->
    lastConversation = User.getLastConversation(id, @getBrain())
    interestKeys = ['ca_type', 'geographic', 'sector', 'time_frame', 'index', 'computation', 'main_field', 'secondary_fields']
    responses = ["Your request is in the following state:"]
    for k,v of lastConversation
      if k in interestKeys
        # TODO : better format string to be more user-friendly. Use functions defined for prompt_intent.
        responses.push('You selected the CA verifying: ' + k + " = " + v)
    if (responses.length == 1)
      responses = ["You have not started your request."]
    cb(null, {
      responses: responses
    })

  trainingSet: ->
    [
      "Review"
    ]

  usage: ->
    "Type 'Review' to review the current state of your request."

module.exports = ReviewIntent
