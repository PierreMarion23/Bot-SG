sdk = require('@botfuel/bot-sdk')
Log4js = require('log4js')


class SecondaryFieldNameExtractor extends sdk.CorpusExtractor
  LOGGER = Log4js.getLogger('SecondaryFieldNameExtractor')
  constructor: (key) ->
    corpus = new sdk.FileCorpus('secondary_field_name', 'eng', __dirname + '/../corpora')
    super(key, corpus)

  # Get corpus standardized value for entity
  transformEntities: (entities) ->
    @corpus.getValue(entity) for entity in entities

module.exports = SecondaryFieldNameExtractor
