sdk = require('@botfuel/bot-sdk')
Log4js = require('log4js')
index = require('../client_js/dist/index.js')

class StartIntent extends sdk.BaseIntent
  LOGGER = Log4js.getLogger('Bot')

  RESPONSES = [
    "Server launched."
    "Welcome, please specify your request."
    "Examples of questions you can ask are: "
    "How many write issues in Europe in 2008 in the banking sector ?"
    "Average of reinvestment ratio for scrip dividends from 2008 to 2012 in France ?"
    "SD of terms for rights issues in 2014 in the US ?"
  ]

  compute: (id, msg, cb) ->
    LOGGER.debug("Send HTTP request to backend here. GET ?")
    index.sum()
    index.init()
    index.test_explo()
    
    responses = RESPONSES
    cb(null, {
      responses: responses
      state_out: "main"
    })


module.exports = StartIntent
