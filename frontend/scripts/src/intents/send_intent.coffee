sdk = require('@botfuel/bot-sdk')
Log4js = require('log4js')
User = require('@botfuel/bot-common').User

class SendIntent extends sdk.BaseIntent
  LOGGER = Log4js.getLogger('PromptIntent')

  responses: (id) ->
    [
      "Your request is now sent. Please wait during processing."
    ]

  trainingSet: ->
    [
      "Go"
      "Send"
      "Request finished"
    ]

  usage: ->
    "Type 'Go' to send your request."

  compute: (id, res, cb) ->
    lastConversation = JSON.stringify(User.getLastConversation(id, @getBrain()))
    LOGGER.debug(lastConversation)
    # Will send request to backend here. POST ?
    # If request = success, send result to user. How ? File download ? Display string ? Then return to state root.
    # If request = failure, explain why to the user. Let him change his request if necessary. Return to state send ?
    cb(null, {
      responses: @responses(id)
      state_out: 'main'
      conversation: {}
    })

module.exports = SendIntent
