sdk = require('@botfuel/bot-sdk')


class FilterExtractor extends sdk.CorpusExtractor
  constructor: (key) ->
    corpus = new sdk.FileCorpus(key, 'eng', __dirname + '/../../../data')
    # super(key, corpus, normalizationRegexp = /,.*/g, true)
    super(key, corpus, null,  /,.*|[^\w\s]/g, true)
    # to keep only the part of the sentence before the first ","

  # Get corpus standardized value for entity: e.g. (MA) -> Merger & Acquisition
  transformEntities: (entities) ->
    @corpus.getValue(entity) for entity in entities

module.exports = FilterExtractor
