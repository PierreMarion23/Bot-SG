sdk = require('@botfuel/bot-sdk')

class HelloIntent extends sdk.BaseIntent
  responses: (id) ->
    [
      "Welcome, please specify your request."
      "Examples of questions you can ask are: "
      "How many write issues in Europe in 2008 in the banking sector ?"
      "Average of reinvestment ratio for scrip dividends from 2008 to 2012 in France ?"
      "SD of terms for rights issues in 2014 in the US ?"
    ]

  stateOut: (id) ->
    "main"
  
  conversation: (id) ->
    {}

  trainingSet: ->
    [
      "Hello"
      "Restart"
      "Stop"
      "Cancel"
    ]

  usage: ->
    "Type 'Stop' to start a new conversation and return to the home message."

module.exports = HelloIntent
