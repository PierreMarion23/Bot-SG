import os
import flask
import json
from flask_restful import Resource

from ..db_analysis.db import DB

class InitApi(Resource):

    def dic_from_distinct_values(self, dic):
        dic_types = {}
        dic_cat_values = {}
        for db_name, dic_columns in dic.items():
            dic_types[db_name] = {}
            dic_cat_values[db_name] = {'__field_name':''}
            for col_name, col_info in dic_columns.items():
                dic_cat_values[db_name]['__field_name'] += col_name + '\n'
                if isinstance(col_info, list):
                    dic_types[db_name][col_name] = 'category'
                    dic_cat_values[db_name][col_name] = '\n'.join([str(x) for x in col_info])
                    dic_cat_values[db_name][col_name] += '\n'   # to add empty line at the end
                else:
                    dic_types[db_name][col_name] = col_info['type']
        return dic_types, dic_cat_values
  
    def get(self):
        db = DB(random=True)
        db.get_random()
        db.put_to_disk(path=os.path.join('.', 'data', 'carbon_random.pk'))
        db.distinct_values(verbose=False)
        dic_types, dic_cat_values = self.dic_from_distinct_values(db.dic_distinct_values)

        # very specific to our example
        with open(os.path.join('.', 'data', 'common.json')) as data_file:    
            dic_common = json.load(data_file)
        for (file_name, file_content) in dic_common.items():
            dic_common[file_name] = '\n'.join([','.join(x) for x in file_content])
            dic_common[file_name] += '\n'   # to add empty line at the end

        return {'common': dic_common, 'types': dic_types, 'cat_values':dic_cat_values}, 200
