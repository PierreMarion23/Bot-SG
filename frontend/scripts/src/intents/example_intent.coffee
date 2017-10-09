sdk = require('@botfuel/bot-sdk')

class ExampleIntent extends sdk.BaseIntent
  responses : (id) ->
    [
      "Examples of questions you can ask are: "
      "How many write issues in Europe in 2008 in the banking sector ?"
      "Average of reinvestment ratio for scrip dividends from 2008 to 2012 in France ?"
      "SD of terms for rights issues in 2014 in the US ?"
    ]
  
  trainingSet: ->
    [
      "%example"
    ]

  usage: ->
    "Type '%example' to display examples of messages you can send to the bot."

module.exports = ExampleIntent
