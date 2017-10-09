#!/usr/bin/env node


'use strict';

var _fs = require('fs');

var _fs2 = _interopRequireDefault(_fs);

var _rimraf = require('rimraf');

var _rimraf2 = _interopRequireDefault(_rimraf);

var _addition = require('./lib/addition');

var _addition2 = _interopRequireDefault(_addition);

var _api = require('./lib/api');

var _api2 = _interopRequireDefault(_api);

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

var sum = function sum() {
	console.log('*********** Add 2 numbers');
	var a = 21,
	    b = 45;

	var c = (0, _addition2.default)(a, b);

	console.log(a + " + " + b + " = " + c);
};

var init = function init() {

	console.log('*********** test api/init');

	var success = function success(response) {
		console.log('in success');
		var data = response.data;
		console.log('data');
		console.log(data);

		_fs2.default.mkdir('data', function (err) {
			console.log(err);
			update_dir_data();
		});

		_fs2.default.writeFile('data/structure.json', JSON.stringify(data['types'], null, '\t'), function (err) {
			console.log('The file json has been saved!');
			if (err) throw err;
		});

		var update_dir_data = function update_dir_data() {
			Object.keys(data['common']).forEach(function (file_name) {
				console.log(file_name);
				(0, _rimraf2.default)('data/' + file_name, function (err) {
					console.log('remove dir ' + file_name);
					if (err) {
						console.log(err);
					};
					create_and_fill_dir();
				});

				var create_and_fill_dir = function create_and_fill_dir() {
					var content = data['common'][file_name];
					_fs2.default.writeFile('data/' + file_name + '.eng.txt', content, function (err) {
						console.log('The file ' + file_name + ' has been saved!');
						if (err) {
							console.log(err);
							return;
						}
					});
				};
			});

			Object.keys(data['cat_values']).forEach(function (db_name) {
				console.log(db_name);
				(0, _rimraf2.default)('data/' + db_name, function (err) {
					console.log('remove dir ' + db_name);
					if (err) {
						console.log(err);
					};
					create_and_fill_dir();
				});

				var create_and_fill_dir = function create_and_fill_dir() {
					_fs2.default.mkdir('data/' + db_name, function (err) {
						console.log('made dir ' + db_name);
						if (err) {
							console.log(err);
							return;
						}
						var db_cat_columns = data['cat_values'][db_name];
						Object.keys(db_cat_columns).forEach(function (db_cat_name) {
							_fs2.default.writeFile('data/' + db_name + '/' + db_cat_name + '.eng.txt', db_cat_columns[db_cat_name], function (err) {
								console.log('The file ' + db_cat_name + ' has been saved!');
								if (err) throw err;
							});
						});
					});
				};
			});
		};
	};

	var error = function error(response) {
		console.log('api error');
		console.log(response.status, response.statusText);
	};

	var url = '/init';
	_api2.default.Get(url, success, error);
};

var test_explo = function test_explo() {

	console.log('*********** test api/exploration');

	var success = function success(response) {
		console.log('in success');
		var data = response.data;
		console.log('data.res');
		console.log(data.res);
	};

	var error = function error(response) {
		console.log('api error');
		console.log(response.status, response.statusText);
	};

	var url = '/exploration';
	var data = {
		'random': true,
		'modifiers': ['--verbose']
	};
	_api2.default.Post(url, data, success, error);
};

var compute = function compute(data) {

	console.log('*********** api/compute');

	var success = function success(response) {
		console.log('in success');
		var data = response.data;
		console.log('data.res');
		console.log(data.res);
		// next_state(true, cb);
	};

	var error = function error(response) {
		console.log('api error');
		console.log(response.status, response.statusText);
		// next_state(false, cb);
	};

	var url = '/compute';
	// let data = {
	// 	'random': true,
	// 	'modifiers': ['--verbose']
	// }
	_api2.default.Post(url, data, success, error);
};

var explore = function explore(data) {

	console.log('*********** api/exploration');

	var success = function success(response) {
		console.log('in success');
		var data = response.data;
		console.log('data.res');
		console.log(data.res);
		// next_state(true, cb);
	};

	var error = function error(response) {
		console.log('api error');
		console.log(response.status, response.statusText);
		// next_state(false, cb);
	};

	var url = '/exploration';
	// let data = {
	// 	'random': true,
	// 	'modifiers': ['--verbose']
	// }
	_api2.default.Post(url, data, success, error);
};

module.exports = {
	sum: sum,
	init: init,
	test_explo: test_explo,
	compute: compute,
	explore: explore
};