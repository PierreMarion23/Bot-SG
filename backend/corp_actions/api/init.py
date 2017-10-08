import os
import flask
from flask_restful import Resource

from ..db_analysis.db import DB

class InitApi(Resource):

    def dic_from_distinct_values(self, dic):
        dic_types = {}
        dic_cat_values = {}
        for db_name, dic_columns in dic.items():
            dic_types[db_name] = {}
            dic_cat_values[db_name] = {}
            for col_name, col_info in dic_columns.items():
                if isinstance(col_info, list):
                    dic_types[db_name][col_name] = 'category'
                    dic_cat_values[db_name][col_name] = '\n'.join([str(x) for x in col_info])
                else:
                    dic_types[db_name][col_name] = col_info['type']
        return dic_types, dic_cat_values
  
    def get(self):
        db = DB(random=True)
        db.get_random()
        db.put_to_disk(path=os.path.join('.', 'data', 'carbon_random.pk'))
        db.distinct_values(verbose=False)
        dic_types, dic_cat_values = self.dic_from_distinct_values(db.dic_distinct_values)
        return {'types': dic_types, 'cat_values':dic_cat_values}, 200
