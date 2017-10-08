Automaton = require('./src/automaton')
encodeUrl = require('encodeurl')
request = require('request')
Log4js = require('log4js')


module.exports = (robot) ->
  LOGGER = Log4js.getLogger('Bot')
  automaton = new Automaton(robot)
  automaton.init()


# If no spellchecker:
  robot.hear /.*/, (res) ->
    automaton.respond(res)


  # robot.hear /.*/, (res) ->

  #   # For web-service spellchecker
  #   uri = "https://ws-spellchecker.herokuapp.com/spellchecker/?sentence=#{res.match[0]}&key=EN_1"
    
  #   # # For local spellchecker
  #   # uri = "http://localhost:8081/spellchecker/?sentence=#{res.match[0]}&key=EN_1"
  #   requestData = {
  #     uri: encodeUrl(uri),
  #     method: 'GET'
  #   }
  #   request requestData, (error, response, body) ->
  #     if error
  #       LOGGER.error("Spellchecking error: #{ JSON.stringify(error) }")
  #       automaton.respond(res)
  #     if not error
  #       LOGGER.debug("Spellchecking success: #{ JSON.stringify(body) }")
  #       res.match[0] = JSON.parse(body).correctSentence
  #       automaton.respond(res)