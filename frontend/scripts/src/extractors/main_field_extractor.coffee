sdk = require('@botfuel/bot-sdk')
Log4js = require('log4js')


class MainFieldExtractor extends sdk.CorpusExtractor
  LOGGER = Log4js.getLogger('MainFieldExtractor')
  constructor: (key) ->
    corpus = new sdk.FileCorpus('main_field_name', 'eng', __dirname + '/../corpora')
    super(key, corpus)

  # Get corpus standardized value for entity: e.g. (Market capacity) -> MarketCap
  transformEntities: (entities) ->
    @corpus.getValue(entity) for entity in entities
    
module.exports = MainFieldExtractor
