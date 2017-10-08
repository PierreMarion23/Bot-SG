# Bot SG DataBase analysis

## How is the bot launched ???
Possible to do require a js file in coffeescript. Have the js apart from coffeescript for now. Good for modularity.

## bot.coffee
Entry point of the bot.
Here you can specify the spellchecker you want to use, and also how to treat the response of the spellchecker.

## automaton.coffee
Defines how the bot works at a high level.
3 layers = states, engines, intents.

The bot cannot (generally) change state automatically, you have to explicitly order him to do so.
In a state, there are several engines. The first engine (in the order defined in @addState line) able to answer the request will do so. 
2 types of engines here:
    - NlpEngine: will answer requests similar to a training set. Has one or several intents.
    - ConstantEngine: will answer any request. Has only one intent.

## Intents

Intent classes define one way to respond to the user request. Three sdk classes of intents are used: sdk.PromptIntent (asks questions to the user), sdk.HelpIntent (will display help), and sdk.BaseIntent.

### HelloIntent (in hello_intent.coffee)
Displays welcome message, erases the conversation, and returns to the main state. Subclass of sdk.BaseIntent.

### HelpIntent (in help_intent.coffee)
Extends sdk.HelpIntent. Will display all usage strings from intents of the same state. Subclass of sdk.HelpIntent.

### ReviewIntent (in review_intent.coffee)
Allows the user to review the current state of his request. Loads last conversation and display interesting fields for the user. Subclass of sdk.BaseIntent.

### SendIntent (in send_intent.coffee)
Sends request to backend, and treats answer. Subclass of sdk.BaseIntent.

### StartIntent (in start_intent.coffee)
First intent to be reached at the beginning of the bot execution. Will send a first request to backend, to ask for data base download and construction of corpora. Subclass of sdk.BaseIntent.

### PromptIntent (in prompt_intent.coffee)
Asks the user to specify his request. Wraps all extractors. Read about those first, it helps to understand the details of the prompt_intent code.
The core of the intent is the entities property which specifies all the entities the intent will extract.
Some fields of the request are mandatory (e.g. CA type). First the user is asked to complete these fields. (in entities -> question)
Every time the user completes one or several field(s), a confirmation message is printed. (in entities -> information). For several fields, the confirmation message needs special computations in separate methods.
Once all mandatory fields are completed, the bot enters the method computeAfterQuestions. There he checks that the request is valid (in checkFieldsAreCorrect), and prints warning for the user if not.
Once all warnings have been treated by the user, the bot displays a message saying that the user can now send his request if he wants, or precise it further more. The bot transitions to the state 'send'.
Subclass of sdk.PromptIntent.

## filter_extractor.coffee
Extracts from user-issued messages entities according to a corpus defined by the argument 'key'.

## secondary_field_wrapper_extractor.coffee
Allows to store several field values in secondary_field, without overwriting old values when the user submits new ones.
Needs the @getBrain (a deep bot layer where the bot data is stored) to get access to the previous value of the secondary_field.
Calls secondary_field_extractor.coffee, which functions the same way as filter_extractor.coffee. I left it separate from filter_extractor, to be able to change it in the future, without changing the standard filter_extractor.

## time_frame_extractor.coffee
Calls the webservice of entity extraction. When deployed, will call a local service working the same way as the webservice.
Specifies to the service that the entity we're looking for is a time entity.
When the service returns the result, computeResult will post process to return the result to prompt_intent.coffee under the good form.

## Corpora
Contains the specific vocab which will be recognized by the bot extractors. Each line corresponds to one concept. The different possible ways to express the concept are separated by commas. The first expression of the line has a special status : it is interpreted by the bot as the standard expression of the concept.
For main_field and secondary_field, I implemented a little trick: the second expression of the line corresponds to a nice way to print out the field for user interaction.
For secondary_field, two other subtleties: 

    - there is a \__$\__ markup for the second expression to separate the field name and the field value. Is used to render nicely for user interaction.

    - there is a special concept, identified by the tag 'ERROR'. It will be recognized by the bot if the field name is identified but not any correct field value, in which case the bot will ask the user for a correct field value. 