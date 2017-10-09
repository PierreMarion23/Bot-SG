sdk = require('@botfuel/bot-sdk')
Log4js = require('log4js')
fs = require('fs')

FieldNameExtractor = require('../extractors/field_name_extractor.coffee')
SecondaryFieldStrExtractor = require('../extractors/secondary_field_str_extractor.coffee')
TimeFrameExtractor = require('../extractors/time_frame_extractor')
common = require('@botfuel/bot-common')

class FieldWrapperExtractor extends sdk.Extractor
  LOGGER = Log4js.getLogger('FieldWrapperExtractor')
  constructor: (key, funct, isSecondary) ->
    @getBrain = funct
    @isSecondary = isSecondary
    super(key)

  extract: (id, robot, sentence, cb) ->

    # If user wants to add secondary fields
    # Existing secondary fields will be overwritten if same field name
    # Existing secondary fields will not be overwritten if different field name

    # secondary_fields = common.User.get(id, @getBrain, 'secondary_fields')
    # if ! (secondary_fields == undefined)
    #   for secondary_field in secondary_fields
    #     field_name = secondary_field.split(' ')[0]
    #     if ! (sentence.includes(field_name))
    #       sentence = sentence +  ' ' + secondary_field

    ca_type = common.User.get(id, @getBrain, 'ca_type')
    if ca_type == undefined
      return cb(null, {})
    LOGGER.debug('ca_type ' + ca_type)
    @FieldNameExtractor = new FieldNameExtractor(@key, ca_type)

    sentences = sentence.split(',')

    if ! @isSecondary
      sentence = sentences[0]
      LOGGER.debug('not is secondary')
      # @FieldNameExtractor.extract(id, robot, sentence, (err, result) =>
      #   if err
      #     return cb(err, null)
      #   else
      #     return cb(null, {
      #       entity_key: @key
      #       entity_value: result.entity_value
      #     })
      # )
      @FieldNameExtractor.extract(id, robot, sentence, (err, result) => 
        LOGGER.debug('in callback')
        return cb(err, result)
        )
      return
      LOGGER.debug('should not be read')

    LOGGER.debug('is secondary')

    if sentences.length > 1
      sentences = sentences[1..]
    else
      LOGGER.debug('null')
      return cb(null, {})
    outputs = {}
    field_names = []

    structure_str = fs.readFileSync('data/structure.json', 'utf8')
    dict_type = JSON.parse(structure_str)
    LOGGER.debug(dict_type)

    for sentence in sentences
      @FieldNameExtractor.extract(id, robot, sentence, (err, result) =>
        if err
          return cb(err, null)
        else
          if result != {}
            name =  result.entity_value[0]
            field_names.push(name)
          else
            field_names.push('%not_understood')
      )
    LOGGER.debug('field names extracted: ' + field_names)

    for k in [0..sentences.length-1]
      LOGGER.debug(k)
      sentence = sentences[k]
      LOGGER.debug(sentence)
      name = field_names[k]
      LOGGER.debug(name)
      if name == '%not_understood' or ! name in dict_type
        continue
      type = dict_type[ca_type][name]
      LOGGER.debug(type)

      if type == 'category'
        secondaryFieldStrExtractor = new SecondaryFieldStrExtractor(ca_type, name)
        secondaryFieldStrExtractor.extract(id, robot, sentence, (err, result) =>
          if err
            return cb(err, null)
          else
            if result != {}
              value =  result.entity_value[0]
              outputs[name] = value
        )
      
      if type == 'date'
        TimeFrameExtractor = new TimeFrameExtractor('whatever', 'en')
        TimeFrameExtractor.extract(id, robot, sentence, (err, result) =>
          LOGGER.debug(result.entity_value)
          outputs = entity_value
      )


    return cb(null, {
        entity_key: @key
        entity_value: outputs
      })
  

module.exports = FieldWrapperExtractor
