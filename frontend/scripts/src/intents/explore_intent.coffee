sdk = require('@botfuel/bot-sdk')
Log4js = require('log4js')
Message = require('@botfuel/bot-common').Message
index = require('../client_js/dist/index.js')

class ExploreIntent extends sdk.BaseIntent
  LOGGER = Log4js.getLogger('ExploreIntent')

  trainingSet: ->
    [
      "%explore"
    ]

  usage: ->
    "Type '%explore' to enter exploration mode."

  compute: (id, res, cb) ->
    sentence = Message.getSentence(res) # useful to send specific modifyers to the backend.
    modifyers = sentence.split(' ')[1..]
#    json_sent['modifyers'] = modifyers
    LOGGER.debug(sentence)

    index.explore({'modifyers' : modifyers})

   # cb(null, {})    
    

module.exports = ExploreIntent
