#!/usr/bin/env node

'use strict';

import fs from 'fs';
import rimraf from 'rimraf';

import myAddition from './lib/addition';
import myApi from './lib/api';


var sum = function() {
	console.log('*********** Add 2 numbers');
	var [a, b] = [21, 45];
	var c = myAddition(a, b);

	console.log(a + " + " + b + " = " + c);
}

var init = function() {

	console.log('*********** test api/init');

	let success = (response) => {
		console.log('in success');
		var data = response.data;
		console.log('data');
		console.log(data);

		fs.mkdir('data', (err) => {
			console.log(err)
			update_dir_data()
		});

		fs.writeFile('structure.json', JSON.stringify(data['types'], null, '\t'), (err) => {
			console.log('The file json has been saved!');
			if (err) throw err;	
		});

		var update_dir_data = function(){
			Object.keys(data['cat_values']).forEach(function(db_name){
				console.log(db_name);
				rimraf('data/' + db_name, (err) =>{
					console.log('remove dir ' + db_name)
					if (err){
						console.log(err)
					};
					create_and_fill_dir()
				});
	
				var create_and_fill_dir = function(){
					fs.mkdir('data/' + db_name, (err) => {
						console.log('made dir ' + db_name);
						if (err){
							console.log(err)
							return
						}
						let db_cat_columns = data['cat_values'][db_name];
						Object.keys(db_cat_columns).forEach(function(db_cat_name){
							fs.writeFile('data/' + db_name + '/' + db_cat_name + '.txt', db_cat_columns[db_cat_name], (err) => {
								console.log('The file ' + db_cat_name + ' has been saved!');
								if (err) throw err;	
								});
						});
					});
				};
			});	
		}
		
	};

	let error = (response) => {
		console.log('api error');
		console.log(response.status, response.statusText);
	};

	let url = '/init';
	myApi.Get(url, success, error);
}

var test_explo = function() {

	console.log('*********** test api/exploration');

	let success = (response) => {
		console.log('in success');
		var data = response.data;
		console.log('data.res');
		console.log(data.res);
	};

	let error = (response) => {
		console.log('api error');
		console.log(response.status, response.statusText);
	};

	let url = '/exploration';
	let data = {
		'random': true,
		'modifiers': ['--verbose']
	}
	myApi.Post(url, data, success, error);

}

module.exports = {
	sum: sum,
	init: init,
	test_explo: test_explo
}