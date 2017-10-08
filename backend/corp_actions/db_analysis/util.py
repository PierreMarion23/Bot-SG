
import gzip
import pickle

import datetime as dt



def to_pickle(fname, obj, compresslevel=3):
    # compresslevel from 0 to 9, 9 is default, slowest, most compressed
    pickle.dump(obj=obj, file=gzip.open(fname, "wb", compresslevel), protocol=pickle.HIGHEST_PROTOCOL)


def from_pickle(fname):
    return pickle.load(gzip.open(fname, "rb"))


def json_serial(obj):
    """JSON serializer for objects not serializable by default json code"""

    if isinstance(obj, (dt.datetime, dt.date)):
        return obj.isoformat()
    return obj
