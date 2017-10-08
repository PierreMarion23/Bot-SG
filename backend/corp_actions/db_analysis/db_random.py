import pandas as pd
import random as rd
import datetime as dt
import calendar
import string

def random_num(mini, maxi):
    return mini + (maxi-mini)*rd.random()

def random_date(min_year, min_month, min_day, max_year, max_month, max_day):
    d_min = dt.date(min_year, min_month, min_day)
    d_max = dt.date(max_year, max_month, max_day)
    stamp_min = calendar.timegm(d_min.timetuple())
    stamp_max = calendar.timegm(d_max.timetuple())
    stamp_rand = random_num(stamp_min, stamp_max)
    return dt.datetime.fromtimestamp(stamp_rand)

def random_bool():
    r = rd.random()
    if r < 0.1:
        return None
    return r > 0.5

def random_category():
    length = rd.randint(2, 8)
    letters = string.ascii_lowercase
    return ''.join(rd.choice(letters) for i in range(length))

def random_from_list(L):
    n = rd.randint(0, len(L)-1)
    return L[n]

def create_random_df(s):
    dic = {
        'creation_date':[random_date(2010, 1, 13, 2015, 7, 25) for k in range(50)],
        'geographic':[random_from_list(['France', 'Germany', 'Spain', 'Italy', 'GB', 'USA', None]) for k in range(50)],
        'sector':[random_from_list(['Industry', 'Banking', 'Farming', 'Taxi_driving', 'Strategy', 'CS', None]) for k in range(50)],
        'index':[random_from_list(['Index1', 'Index2', 'Index3', 'Index4', 'Index5', 'Index6', None]) for k in range(50)],
        'data_bool_' + s:[random_bool() for k in range(50)],
        'data_bool2':[random_bool() for k in range(50)],
        'data_date_' + s:[random_date(2010, 1, 13, 2015, 7, 25) for k in range(50)],
        'data_categorical_' + s:[random_category() for k in range(5)]*10,
        'data_num_' + s:[random_num(0, 10) for k in range(50)]
    }
    return pd.DataFrame(dic)