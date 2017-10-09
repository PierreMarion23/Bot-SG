sdk = require('@botfuel/bot-sdk')
Log4js = require('log4js')
User = require('@botfuel/bot-common').User
Message = require('@botfuel/bot-common').Message
index = require('../client_js/dist/index.js')

class SendIntent extends sdk.BaseIntent
  LOGGER = Log4js.getLogger('SendIntent')

  responses: (id) ->
    [
      "Your request is now sent. Please wait during processing."
    ]

  trainingSet: ->
    [
      "%go"
    ]

  usage: ->
    "Type '%go' to send your request."

  compute: (id, res, cb) ->
    json_sent = {}
    json_lastConversation = User.getLastConversation(id, @getBrain())

    sentence = Message.getSentence(res) # useful to send specific modifyers to the backend.
    modifyers = sentence.split(' ')[1..]
    json_sent['modifyers'] = modifyers
    LOGGER.debug(sentence)

    interestKeys = ['ca_type', 'geographic', 'sector', 'time_frame', 'index', 'computation', 'main_field', 'secondary_fields']
    for k,v of json_lastConversation
      if k in interestKeys
        json_sent[k] = v
    LOGGER.debug(JSON.stringify(json_sent))

    # next_state = (ok, cb) ->
    #   LOGGER.debug('in next_state') 
    #   LOGGER.debug(cb)
    #   if ok
    #     LOGGER.debug('ok') 
    #     cb(null, {
    #       responses: @responses(id)
    #       state_out: 'main'
    #       conversation: {}
    #     })
    #     LOGGER.debug('ok') 
    #   else
    #     LOGGER.debug('not ok') 
    #     cb(null, {
    #       responses: ['You can modify your previous request here:']
    #       state_out: 'send'
    #     })

    # ok = index.compute(json_sent, next_state, cb)

    index.compute(json_sent)

    cb(null, {
      responses: ["You can modify your previous request, or return to beg by typing '%cancel'"]
      state_out: 'send'
    })

    # If request = success, send result to user. How ? File download ? Display string ? Then return to state root.
    # If request = failure, explain why to the user. Let him change his request if necessary. Return to state send ?
    
    

module.exports = SendIntent
