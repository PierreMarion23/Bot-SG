sdk = require('@botfuel/bot-sdk')
Log4js = require('log4js')


class SecondaryFieldStrExtractor extends sdk.CorpusExtractor
  LOGGER = Log4js.getLogger('SecondaryFieldStrExtractor')
  constructor: (ca_type, name) ->
    corpus = new sdk.FileCorpus(name, 'eng', __dirname + '/../../../data/' + ca_type)
    super('whatever', corpus)

  # Get corpus standardized value for entity
  transformEntities: (entities) ->
    @corpus.getValue(entity) for entity in entities

module.exports = SecondaryFieldStrExtractor
