import os
import flask
from flask import request
from flask_restful import Resource
import random as rd

from ..db_analysis.db import DB

class ComputeApi(Resource):

    def post(self):

        dic_input = request.json
        print(dic_input)
        random = dic_input.pop('random') if 'random' in dic_input else False
        modifiers = dic_input.pop('modifiers') if 'modifiers' in dic_input else {}

        db_name = dic_input.pop('ca_type') if 'ca_type' in dic_input else None
        sector = dic_input.pop('sector') if 'sector' in dic_input else None
        geographic = dic_input.pop('geographic') if 'geographic' in dic_input else None
        time_frame = dic_input.pop('time_frame') if 'time_frame' in dic_input else None
        index = dic_input.pop('index') if 'index' in dic_input else None
        computation = dic_input.pop('computation') if 'computation' in dic_input else None
        main_field = dic_input.pop('main_field') if 'main_field' in dic_input else None
        secondary_fields = dic_input.pop('secondary_fields') if 'secondary_fields' in dic_input else None

        # Treatment of modifiers
        verbose = ('--verbose' in modifiers)

        # Load db
        db = DB(random)
        db.get_from_disk(path=os.path.join('.', 'data', 'carbon_random.pk'))
        db.distinct_values(verbose=False)

        # here business computation

        return {'res':rd.random()}, 200