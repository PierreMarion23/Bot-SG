
'use strict';

require('dotenv-extended').load();
const log = require('simple-node-logger').createSimpleLogger();
const { EntityExtraction } = require('botfuel-nlp-sdk');

const extractor = new EntityExtraction({
	appId: process.env.BOTFUEL_APP_ID,
	appKey: process.env.BOTFUEL_APP_KEY
});

extractor
	.compute({
		sentence: '221 Baker St London NW1 6XE UK',
		dimensions: ['city', 'postal'],
		antidimensions: ['address']
	})
	.then(entities => {
		log.info('entities:\n', JSON.stringify(entities, null, '  '));
	});

