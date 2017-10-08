## Steps

1. Write your code in folder src - ES6 javacript authorised
1. Create package.json
    ````
    npm init
    ````
1. Install packages
    ````
    npm install axios --save
    ````
1. Install dev packages
    ````
    npm install babel-cli babel-preset-env --save-dev
    ````
1. Edit package.json and adjust name, description, scripts
    ````
    "scripts": {
        "build": "babel src -d dist",
        "go": "node ./dist/index.js"
    }
    ````
1. Scripts are shortcuts.  
    To transpile ES6 javascript with babel:
    ````
    npm run build
    ````
    See the plain javascript result in folder dist/.  
    To run transpiled code:
    ````
    npm run go
    ````

## CommonJS module

If you don't want to use the transpiler ([babel](https://babeljs.io/)) the use CommonJS modules instead. But the syntax is more cumbersome.
