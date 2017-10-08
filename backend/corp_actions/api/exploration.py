import os
import flask
from flask import request
from flask_restful import Resource

from ..db_analysis.db import DB

class ExplorationApi(Resource):

    def post(self):

        dic_input = request.json
        random = dic_input.pop('random') if 'random' in dic_input else False
        modifiers = dic_input.pop('modifiers') if 'modifiers' in dic_input else {}
        entity_name = dic_input.pop('entity_name') if 'entity_name' in dic_input else None  # not used for now
        db_name = dic_input.pop('db_name') if 'db_name' in dic_input else None
        db_field_name = dic_input.pop('db_field_name') if 'db_field_name' in dic_input else None

        # Treatment of modifiers
        verbose = ('--verbose' in modifiers)

        # Load db
        db = DB(random)
        db.get_from_disk(path=os.path.join('.', 'data', 'carbon_random.pk'))
        db.distinct_values(verbose=False)

        if db_name is not None:
            if db_field_name is None:
                res = db.overview_one_table(db_name, toString=True, verbose=verbose)
                return {'res':res}, 200
            else:    
                res = str(db.dic_distinct_values[db_name][db_field_name])
                return {'res':res}, 200
        else:
            res = db.overview(toString=True)
            return {'res':res}, 200