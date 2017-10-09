sdk = require('@botfuel/bot-sdk')
Log4js = require('log4js')
#Extractor = require('@botfuel/bot-sdk/src/extractors/extractor')

class TimeFrameExtractor extends sdk.EntextExtractor
  LOGGER = Log4js.getLogger('TimeFrameExtractor')
  constructor: (key, locale) ->
    super(key, 'time', locale)
  
  extract: (id, robot, sentence, cb) ->
    sentence = @normalizeSentence(sentence.split(',')[0])
    if sentence?.length > 0
      @extractFromNormalized(id, robot, sentence, (err, res) ->
        if err
          cb(err, null)
        else
          cb(null, res))
    else
      LOGGER.debug("extract: empty sentence")
      cb(null, {})

  computeResult: (json) ->
    cleanJson = super(json)
    raw_result = cleanJson.filter (entry) -> entry.dim is 'time'

    result = []
    if raw_result.length == 1

      # only one timestamp detected
      if raw_result[0].values[0].type == "timestamp"
        result.push raw_result[0].values[0]["time-stamp"]

      # one interval detected
      if raw_result[0].values[0].type == "interval"
        result.push raw_result[0].values[0].from["time-stamp"]
        result.push raw_result[0].values[0].to["time-stamp"]
    
    # two timestamps detected
    if raw_result.length == 2
      if raw_result[0].values[0].type == "timestamp"
        result.push raw_result[0].values[0]["time-stamp"]
      if raw_result[1].values[0].type == "timestamp"
        result.push raw_result[1].values[0]["time-stamp"]

    return result

module.exports = TimeFrameExtractor
