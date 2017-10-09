
import os
import json
import warnings
import io

import datetime as dt
import numpy as np
import pandas as pd
import requests as rq

from IPython.display import display

from .util import to_pickle, from_pickle, json_serial
from .object_from_dict import ObjOneLevel
from .db_random import create_random_df

class DB:
    """
    Carbon db convenient load and post processing
    """
    # api
    # URL = 'https://srvparshxp08:8447/CarbOn/services//CorporateAction/getMDCorporateActions'
    URL = 'https://srvparshxp08:8447/CarbOn/services//CorporateAction/getCorporateActions'
    HEADERs = {"Content-Type": "application/json", "Accept": "application/json"}

    INVALID_STATUS = ['CANCELLED', 'DENIED', 'POSSIBLE']


    def __init__(self, random=False):
        """
        Instantiate class DB
        Attributes are set to None
        """
        self.random = random

        if random:
            with open(os.path.join(os.path.dirname(os.path.realpath(__file__)), 'fields_random.json')) as data_file:    
                self.MODEL = json.load(data_file)
        else:
            with open(os.path.join(os.path.dirname(os.path.realpath(__file__)), 'fields.json')) as data_file:    
                self.MODEL = json.load(data_file)
        self.TABLE_NAMES = list(self.MODEL.keys())

        for name in self.MODEL:
            setattr(self, name, None)
        self.df_share = None
        self.dic_distinct_values = None

        self.df_bbg_mktdata = None
        self.df_bbg_sector = None
        self.df_bbg_exchange = None

    def get_random(self):
        for name in self.TABLE_NAMES:
            print('creating df ' + name)
            setattr(self, name, create_random_df(name))

    def raw_request(self, name):
        """
        Raw http request to API
        Cf. swagger http://srvparshxp09.fr.world.socgen:8079/sradSwagger/detail.html?url=https://srvparshxp08:8447/CarbOn/services/swagger/swagger.json
        """
        data = json.dumps({"caType": name.upper(), "functionalScope": "CA_ALL"})

        with warnings.catch_warnings():
            warnings.simplefilter('ignore') # no https triggers warning
            res = rq.post(url=self.URL, headers=self.HEADERs, data=data, verify=False)
            data = res.content.decode('utf-8')
            data = json.loads(data)

        return data


    def get_from_api(self, name, verbose=True):
        """
        Load one table from API
        """
        data = json.dumps({"caType": name.upper(), "functionalScope": "CA_ALL"})

        with warnings.catch_warnings():
            warnings.simplefilter('ignore') # no https triggers warning
            res = rq.post(url=self.URL, headers=self.HEADERs, data=data, verify=False)

        if verbose:
            print(name, res)
        data = res.content.decode('utf-8')
        data = json.loads(data)

        df = pd.DataFrame(data)
        df = df.reindex_axis(sorted(df.columns), axis=1)
        setattr(self, name, df)


    def convert_carbontime_to_datetime(self, se):
        """
        Carbon time is unixtime * 1000
        """
        s = se.copy()
        s = s.fillna(0)/1000
        v = [dt.datetime.utcfromtimestamp(int(e)) for e in s]

        unixtimezero = dt.datetime.utcfromtimestamp(0)
        v = [e if e != unixtimezero else pd.NaT for e in v]

        return v


    def build_share(self, verbose=True):
        """
        Build df_share from all tables share and targetShare fields
        """
        if self.df_share is None:
            if verbose:
                print('extract shares from tables - build df_share')

            li_share_all = []
            for name in self.MODEL:
                df = getattr(self, name)
                
                li_share = list(df['share'])
                df['share'] = df['share'].map(lambda x: x['bloombergCode'] if x else None)

                if 'targetShare' in df.columns:
                    li_share += list(df['targetShare'])
                    df['targetShare'] = df['targetShare'].map(lambda x: x['bloombergCode'] if x else None)

                setattr(self, name, df)

                li_share_all += li_share
                if verbose:
                    print('\t{}\t{}'.format(name, len(li_share_all)))

            print('nb shares = {}'.format(len(li_share_all)))

            li_share_slim = []
            for e in li_share_all:
                if e is not None:
                    d = {k: v for k, v in e.items() if k not in ['market', 'userAuditEntity']}
                li_share_slim.append(d)

            df_share = pd.DataFrame(li_share_slim)
            df_share = df_share.drop_duplicates()

            for c in df_share.columns:
                if 'Ts' in c:
                    pass
                    df_share[c] = self.convert_carbontime_to_datetime(df_share[c])

            df_share.reindex_axis(sorted(df_share.columns), axis=1)
            df_share = df_share.reset_index(drop=True)

            self.df_share = df_share
            print('nb unique shares = {}'.format(len(self.df_share)))

        else:
            print('extraction done already')
            print('nb unique shares = {}'.format(len(self.df_share)))


    def put_to_disk(self, path=os.path.join('data', 'carbon.pk')):
        """
        Save data to disk
        """
        print('store tables from disk')
        dic_table = {}
        for name in self.MODEL:
            obj = getattr(self, name)
            isEmpty = ' (empty)' if (obj is None) else ''
            print('\ttable {}{}'.format(name, isEmpty))
            dic_table[name] = obj
        to_pickle(path, dic_table)
    

    def get_from_disk(self, path=os.path.join('data', 'carbon.pk')):
        """
        Read data from disk
        """
        print('read tables from disk')
        dic_table = from_pickle(path)
        for name, t in dic_table.items():
            print('\ttable {}'.format(name))
            setattr(self, name, t)


    def filter(self, name, verbose=True):
        """
        Process request raw table data into user data
        Highly specific transformation - based on file fields.json
        Convert date columns to datetime
        """

        # start define extract functions

        def func_od_transferable(df):
            se = df['scripRights']
            li_v = [e['transferable'] for e in se]
            return li_v

        def func_od_tradable(df):
            se = df['scripRights']
            li_v = [e['tradable'] for e in se]
            return li_v

        def func_od_listedOnExchange(df):
            se = df['scripRights']
            li_v = [e['listedOnExchange'] for e in se]
            return li_v

        def func_cb_currency(df):
            se = df['cb']
            li_v = [e['currency'] for e in se]
            return li_v

        def func_cb_coupon(df):
            se = df['cb']
            li_v = [e['coupon'] for e in se]
            return li_v

        def func_ri_transferable(df):
            se = df['right']
            li_v = [e['transferable'] for e in se]
            return li_v

        def func_ri_primaryAllocationMethod(df):
            se = df['allocationMethods']
            li_v = []
            for e in se:
                v = [a['allocationMethod'] for a in e if a['key']['rank'] == 'PRIMARY']
                if len(v) ==0:
                    v = ['UNKNOWN']
                assert len(v) == 1, 'Not exactly one primary method: {}'.format(v)
                li_v.append(v[0])
            return li_v
            return se

        def func_ri_secondaryAllocationMethod(df):
            se = df['allocationMethods']
            li_v = []
            for e in se:
                v = [a['allocationMethod'] for a in e if a['key']['rank'] == 'SECONDARY']
                if len(v) ==0:
                    v = ['UNKNOWN']
                assert len(v) == 1, 'Not exactly one secondary method: {}'.format(v)
                li_v.append(v[0])
            return li_v
            return se

        def func_ri_tertiaryAllocationMethod(df):
            se = df['allocationMethods']
            li_v = []
            for e in se:
                v = [a['allocationMethod'] for a in e if a['key']['rank'] == 'TERTIARY']
                if len(v) ==0:
                    v = ['UNKNOWN']
                assert len(v) == 1, 'Not exactly one tertiary method: {}'.format(v)
                li_v.append(v[0])
            return li_v
            return se

        dic_func = {('right_issue', 'transferable'): func_ri_transferable,
                    ('right_issue', 'primaryAllocationMethod') : func_ri_primaryAllocationMethod,
                    ('right_issue', 'secondaryAllocationMethod') : func_ri_secondaryAllocationMethod,
                    ('right_issue', 'tertiaryAllocationMethod') : func_ri_tertiaryAllocationMethod,
                    ('optional_dividend', 'transferable'): func_od_transferable,
                    ('optional_dividend', 'tradable'): func_od_tradable,
                    ('optional_dividend', 'listedOnExchange'): func_od_listedOnExchange,
                    ('convertible_bond', 'cbCurrency'): func_cb_currency,
                    ('convertible_bond', 'cbCoupon'): func_cb_coupon,
                   }

        # start process

        if verbose:
            print('shape {}'.format(name))
            print('\tinvalid status:' + str(self.INVALID_STATUS))

        df = getattr(self, name).copy()
        fields = self.MODEL[name]

        li_field = []
        li_field_func = []
        for field in fields:
            if not field.startswith('*'):
                if verbose:
                    print('\tregular \t{}'.format(field))
                assert field in df.columns, 'field {} is not in {}.df.columns'.format(field, name)
                li_field.append(field)
            else:
                if verbose:
                    print('\tspecific\t{}'.format(field))
                field = field[1:]
                func = dic_func[(name, field)]
                li_field_func.append((field, func))

        dfn = df[li_field]

        
        if verbose:
            print('\tspecific phase')
        for field, func in li_field_func:
            if verbose:
                print('\t\t{}'.format(field))
            dfn = dfn.assign(**{field: func(df)})
        dfn = dfn.loc[~df['status'].isin(self.INVALID_STATUS)]

        if verbose:
            print('\tconvert dates to datetime')
        for c in dfn.columns:
            if 'date' in c.lower():
                if verbose:
                    print('\t\t{}'.format(c))
                dfn[c] = self.convert_carbontime_to_datetime(dfn[c])

        setattr(self, name, dfn)


    def get_from_api_all(self):
        """
        Load all tables from API
        """
        for name in self.TABLE_NAMES:
            self.get_from_api(name)


    def filter_all(self):
        """
        Process raw data in user data for all tables
        """
        for name in self.TABLE_NAMES:
            self.filter(name)


    def overview(self, toString=False):
        """
        Display all tables summary
        """
        
        print('Overview - dataframes structures')

        if toString:
            buf = io.StringIO()
            s = 'Overview - dataframes structures\n'
        for name in self.MODEL:
            print('\n{}'.format(name))
            df = getattr(self, name)

            if toString:
                s += '\n{}'.format(name)
                df.info(buf=buf)
                s += buf.getvalue()
                buf = io.StringIO()
            else:
                df.info()

        if not self.random:
            print('\n{}'.format('share'))

            if toString:
                s += '\n{}'.format('share')
                self.df_share.info(buf=buf)
                s += buf.getvalue()
            else:
                self.df_share.info()
        
        if toString:
            return s

    def overview_one_table(self, name, toString=False, verbose=False):
        """
        Display one table summary
        """
        
        print('Overview - dataframes structure')

        if toString:
            buf = io.StringIO()
            s = 'Overview - dataframes structures\n'

        print('\n{}'.format(name))
        df = getattr(self, name)

        if toString:
            s += '\n{}'.format(name)
            df.info(buf=buf)
            s += buf.getvalue()
            if verbose:
                s += '\nThis is a verbose line - to be replaced by something interesting.'
        else:
            df.info()
        if toString:
            return s


    def distinct_values(self, verbose=True):
        """
        Overview of data per table and column
        min/max for number columns
        earliest/latest for date columns
        set of values for other columns
        """
        dic = {}

        for name in self.MODEL:
            dic[name] = {}
            df = getattr(self, name)
            if df is None:
                continue
            df_nb = df.select_dtypes(include=['number'])
            df_dt = df.select_dtypes(include=['datetime'])

            if verbose:
                print(name)
                print('\t number columns: {}'.format(list(df_nb.columns)))
                print('\t date columns: {}'.format(list(df_dt.columns)))

            for c in df.columns:
                if c not in ['caKey', 'share']:
                    if c in df_nb.columns:
                        my_min = np.min(df[c])
                        my_max = np.max(df[c])
                        my_avg = np.mean(df[c])
                        dic[name][c] = {'type': 'number',
                                        'min': my_min,
                                        'max': my_max,
                                        'avg': my_avg,
                                        }
                    elif c in df_dt.columns:

                        my_min = df[c].min()
                        if pd.isnull(my_min):
                            my_min = None
                        else:
                            my_min = my_min.strftime('%Y-%m-%d')

                        my_max = df[c].max()
                        if pd.isnull(my_max):
                            my_max = None
                        else:
                            my_max = my_max.strftime('%Y-%m-%d')

                        dic[name][c] = {'type': 'date',
                                        'earliest': my_min,
                                        'latest': my_max,
                                        }
                    else:
                        dic[name][c] = list(set(df[c]))


        self.dic_distinct_values = dic

        if verbose:
            print('\nOverview - distinct values')
            print(json.dumps(dic, default=json_serial, indent=2))


    def put_to_csv(self):
        """
        Save all tables and df_share to disk
        """
        print('save dataframes to disk')

        dir_name = os.path.join('dump')
        if not os.path.exists(dir_name):
            os.makedirs(dir_name)

        for name in self.MODEL:
            df = getattr(self, name)
            file_name = 'df_'+name+'.csv'
            path = os.path.join(dir_name, file_name)
            df.to_csv(path)
            print('\t{:<25}\t{}'.format(name, path))

        if not self.random:
            file_name = 'df_share.csv'
            path = os.path.join(dir_name, file_name)
            self.df_share.to_csv(path, index=False)
            print('\t{:<25}\t{}'.format('share', path))

    # def get_from_csv(self):
    #     """
    #     Get all tables from folder dump
    #     """
    #     print('get dataframes from folder dump')
    #     # Issue with dates which are recognized as strings for now.

    #     dir_name = os.path.join('dump')
    #     if not os.path.exists(dir_name):
    #         print('Error: No folder dump')
    #         return

    #     for name in self.MODEL:
    #         file_name = 'df_'+name+'.csv'
    #         path = os.path.join(dir_name, file_name)
    #         df = pd.read_csv(path)
    #         print('\t{}\t{}'.format(name, path))
    #         setattr(self, name, df)

    #     if not self.random:
    #         file_name = 'df_share.csv'
    #         path = os.path.join(dir_name, file_name)
    #         self.df_share = pd.read_csv(path)
    #         print('\t{}\t{}'.format('share', path))


    def get_bbg_data(self, verbose=True):
        """
        Load bbg data from folder
        """
        path = os.path.join('bbg', 'df_bbg_mktcap.csv')
        self.df_bbg_mktdata = pd.read_csv(path, index_col=0, parse_dates=['Date'])
        if verbose:
            print('{} loaded'.format(path))

        path = os.path.join('bbg', 'df_bbg_sector.csv')
        self.df_bbg_sector = pd.read_csv(path, index_col=0)
        if verbose:
            print('{} loaded'.format(path))

        path = os.path.join('bbg', 'df_bbg_exchange.csv')
        self.df_bbg_exchange = pd.read_csv(path, index_col=0)
        if verbose:
            print('{} loaded'.format(path))

