# Botfuel doc: about running the bot

## Prerequisites

### Env var
- **BOTFUEL_APP_ID**=...
- **BOTFUEL_APP_KEY**=...

## How to test the bot

### Using the staging version of the ws-entext service
```
BOTFUEL_APP_ID=... BOTFUEL_APP_KEY=... npm run test
```

## How to run/use the bot

### Running the bot locally
```
BOTFUEL_APP_ID=... BOTFUEL_APP_KEY=... npm run bot
```

## How to generate the doc
```
codo scripts -o doc
```

## How to check the coding style
```
coffeelint scripts
```

For spellchecking, you can use either the web service or the local host.
If you use the local host (port 8081), run it before running the bot.
To do so, see doc of spellchecking.