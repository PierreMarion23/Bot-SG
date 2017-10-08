Log4js = require('log4js')
sdk = require('@botfuel/bot-sdk')
common = require('@botfuel/bot-common')
moment = require('moment')
moment.locale('fr')

FilterExtractor = require('../extractors/filter_extractor')
TimeFrameExtractor = require('../extractors/time_frame_extractor')
MainFieldExtractor = require('../extractors/main_field_extractor')
SecondaryFieldWrapperExtractor = require('../extractors/secondary_field_wrapper_extractor')

class PromptIntent extends sdk.PromptIntent
  LOGGER = Log4js.getLogger('PromptIntent')
  MainCorpus = new sdk.FileCorpus('main_field', 'eng', __dirname + '/../corpora')
  SecondaryCorpus = new sdk.FileCorpus('secondary_field', 'eng', __dirname + '/../corpora')

  constructor: (automaton) ->
    super(automaton, 'prompt', 'root')
    
  usage: ->
    "You can also specify your request for the Carbon database now."

  getStateOut: ->
    "main"
  
  # nice output of time frame for user interaction
  TIME_FRAME = (value) ->
    if value.length is 2
      if value[0] == value[1]
        ["You selected CA for one year starting #{value[0]}"] # one year selected
      else
        ["You selected CA between #{value[0]} and #{value[1]}"]
    else
      ["You selected CA for one year starting #{value[0]}"]


  # nice output of secondary field for user interaction
  # Uses ninja tricks in the way secondary_field corpus is built. See doc.
  SECONDARY_FIELD = (values) ->
    # info = ''
    # res = []
    # LOGGER.debug('values ' + values)
    # for key in values
    #   for rawLine in SecondaryCorpus.rawLines
    #     words = rawLine.split(',')
    #     keys = words.map((t) => SecondaryCorpus.normalize(t.toLowerCase()))
    #     if key.toLowerCase() in keys
    #       res.push sdk.Corpus.trim(words[1])
    #       continue
    # LOGGER.debug('res ' + res)

    # for value in res
    #   field_name = value.split("__$__")[0]
    #   field_value = value.split("__$__")[1]
    #   if field_value == " ERROR"
    #     info = info + '\n' + "The bot didn't recognize the field value for field name: " + field_name
    #     # TODO: add corpus of possible values. This corpus will be constructed at the same time than secondary_field.eng.txt
    #   else
    #     info = info + '\n' + "You selected CA which verify condition: " + field_name + "=" + field_value

    LOGGER.debug('values ' + values)
    info = ''
    for field_name in Object.keys(values)
      info = info + '\n' + "You selected CA which verify condition: " + field_name + "=" + values[field_name]
    LOGGER.debug(info)
    if info.length > 0
      info = info.slice(1, info.length)
    
    return [info]

  # nice output of secondary field for user interaction
  # Uses ninja tricks in the way main_field corpus is built. See doc.
  MAIN_FIELD = (value) ->
    key = value[0]
    for rawLine in MainCorpus.rawLines
      words = rawLine.split(',')
      keys = words.map((t) => MainCorpus.normalize(t.toLowerCase()))
      if key.toLowerCase() in keys
        return ['You want to perform the computation on field: ' + sdk.Corpus.trim(words[1])]

  entities: ->
    'ca_type':
      question: ["Which CA type(s)?"]
      information: (values) -> ['You selected the CA type(s): ' + values]
      extractor: new FilterExtractor('ca_type')
    'geographic':
      # question: ["Which geographic sector(s)?"]     # if question is present, means the field is mandatory.
      # If no question: the user can still precise field, but will not be asked for it.
      information: (values) -> ['You selected the geographic sector(s): ' + values]
      extractor: new FilterExtractor('geographic')
    'sector':
      # question: ["Which economical sector(s)?"]     
      information: (values) -> ['You selected the economical sector(s): ' + values]
      extractor: new FilterExtractor('sector')
    'time_frame':
    # question: ["Which time frame?"]
      information: TIME_FRAME
      extractor: new TimeFrameExtractor('time_frame', 'en')
    'index':
      # question: ["Which index(es)?"]
      information: (values) -> ['You selected the index(es): ' + values]
      extractor: new FilterExtractor('index')
    'computation':
      question: ["Which computation(s)?"]
      information: (values) -> ['You selected the computation(s): ' + values]
      extractor: new FilterExtractor('computation')
    'main_field':
      # question: ["On which field do you want to perform the computation?"]
      information: MAIN_FIELD
      extractor: new FilterExtractor('main_field')
    'secondary_fields':
      # question: ["On which secondary field do you want to perform the computation?"]
      information: SECONDARY_FIELD
      extractor: new SecondaryFieldWrapperExtractor('secondary_fields', @getBrain())


  checkFieldsAreCorrect: (geographic, sector, index, time_frame, computation, main_field, secondary_fields, ca_type) ->

    LOGGER.debug("checkFieldsAreCorrect")
    if (computation != undefined && computation.length > 1)
      return ["You selected more than one computation. Please enter the computation you want to apply"]

    if (main_field == undefined && computation[0] in ['sum', 'average', 'median', 'SD'])
      return ["You selected a numerical computation without precising the field on which to apply the computation. Please enter the field now:"]

    # TODO: check here that secondary_field(s) are coherent with CA.
    # Read a (JSON ?) file which describes possible fields for each CA. If not coherent, tell the user and ask him
    # to change either CA or secondary field.

    # Check for ERROR in secondary_fields.

    return []

  computeAfterQuestions: (id, responses, cb) ->
    LOGGER.debug("computeAfterQuestions")

    geographic = common.User.get(id, @getBrain(), 'geographic')
    sector = common.User.get(id, @getBrain(), 'sector')
    index = common.User.get(id, @getBrain(), 'index')
    time_frame = common.User.get(id, @getBrain(), 'time_frame')
    computation = common.User.get(id, @getBrain(), 'computation')
    main_field = common.User.get(id, @getBrain(), 'main_field')
    secondary_fields = common.User.get(id, @getBrain(), 'secondary_fields')
    ca_type = common.User.get(id, @getBrain(), 'ca_type')

    problem = @checkFieldsAreCorrect(geographic, sector, index, time_frame, computation, main_field, secondary_fields, ca_type)
    
    if problem.length > 0
      responses = responses.concat problem
      return cb(null, { responses: responses })

    else
      responses.push "Your request is now ready to be sent. Type 'Go' to send it now. You can also precise it."
      if geographic == undefined
        responses.push "You can add a geographic filter."
      if sector == undefined
        responses.push "You can add a sector filter."
      if index == undefined
        responses.push "You can add an index filter."
      if time_frame == undefined
        responses.push "You can add a time frame filter."
      responses.push "You can also add CA-specific field filter(s)"

      return cb(null, {
          responses: responses
          state_out: 'send'
        })

   
module.exports = PromptIntent
