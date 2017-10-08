sdk = require('@botfuel/bot-sdk')


class FilterExtractor extends sdk.CorpusExtractor
  constructor: (key) ->
    corpus = new sdk.FileCorpus(key, 'eng', __dirname + '/../corpora')
    super(key, corpus, true)

  # Get corpus standardized value for entity: e.g. (MA) -> Merger & Acquisition
  transformEntities: (entities) ->
    @corpus.getValue(entity) for entity in entities

module.exports = FilterExtractor
