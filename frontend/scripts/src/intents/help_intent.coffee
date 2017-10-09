sdk = require('@botfuel/bot-sdk')

class HelpIntent extends sdk.HelpIntent
  responses: (id) ->
    [
      "Examples of messages you can send to the bot now: "
    ]

  trainingSet: ->
    [
      "%help"
    ]

  usage: ->
    [
      "Type '%help' to print the help message"
    ]

module.exports = HelpIntent
