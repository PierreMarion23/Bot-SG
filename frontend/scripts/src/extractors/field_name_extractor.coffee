sdk = require('@botfuel/bot-sdk')
Log4js = require('log4js')


class FieldNameExtractor extends sdk.CorpusExtractor
  LOGGER = Log4js.getLogger('FieldNameExtractor')
  constructor: (key, ca_type) ->
    corpus = new sdk.FileCorpus('__field_name', 'eng', __dirname + '/../../../data/' + ca_type)
    
    super(key, corpus)

  # Get corpus standardized value for entity
  transformEntities: (entities) ->
    @corpus.getValue(entity) for entity in entities

module.exports = FieldNameExtractor
