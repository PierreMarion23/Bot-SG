sdk = require('@botfuel/bot-sdk')
version = require('../../package.json').version
HelpIntent = require('./intents/help_intent')
HelloIntent = require('./intents/hello_intent')
PromptIntent = require('./intents/prompt_intent')
SendIntent = require('./intents/send_intent')
ExampleIntent = require('./intents/example_intent')
ReviewIntent = require('./intents/review_intent')
StartIntent = require('./intents/start_intent')
ExploreIntent = require('./intents/explore_intent')

class Automaton extends sdk.Automaton
  constructor: (robot) ->
    super(robot, 'initialize', 'test-societe-generale', version, 'shell', 'fr')

  init: ->
    @addIntent('catchall', sdk.CatchallIntent)
    @addIntent('help', HelpIntent)
    @addIntent('hello', HelloIntent)
    @addIntent('prompt_intent', PromptIntent)
    @addIntent('send', SendIntent)
    @addIntent('examples', ExampleIntent)
    @addIntent('review', ReviewIntent)
    @addIntent('start', StartIntent)
    @addIntent('explore', ExploreIntent)

    @addEngine('initialize', sdk.ConstantEngine, ['start'])
    @addEngine('nlp_main', sdk.NlpEngine, ['hello', 'help', 'explore', 'examples', 'review'])
    @addEngine('base_request', sdk.ConstantEngine, ['prompt_intent'])
    @addEngine('send', sdk.NlpEngine, ['hello', 'help', 'explore', 'send', 'review'])

    @addState('initialize', ['initialize'])
    @addState('main', ['nlp_main', 'base_request'])
    @addState('send', ['send', 'base_request'])

module.exports = Automaton
