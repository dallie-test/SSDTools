import numpy as np
import pandas as pd

fn = 'TIS_traffics/gj2017_airline.csv'

data = pd.read_csv(fn)


#%% adjust data
data["time_ACT"] = pd.to_datetime(data["time_ACT"])
data["DEN"]      = data["time_ACT"]
data["DEN"]= "D"
# change string to date of today N.B.
t1 =pd.to_datetime('22:59:59')
t2 =pd.to_datetime('07:00:00')
t3 =pd.to_datetime('18:59:59')
t4 =pd.to_datetime('23:00:00')
t5 =pd.to_datetime('05:59:59')

data["DEN"][(data['time_ACT']>t1) | (data['time_ACT']<t2)] = "N"
data["DEN"][(data['time_ACT']>t3) & (data['time_ACT']<t4)] = "E"
data["DEN"][(data['time_ACT']>t5) & (data['time_ACT']<t2)] = "EM"


#%% add HV GA field
data["CG"]  = data["DEN"]
data["CG"]  = 'GA'
flnat_hv    = ['PL','PC','PP','PF','FL','FC','FP','FF'] #N.B. 8 flnat codes maken HV
data["CG"][data['FLNAT_code'].isin(flnat_hv)]     = 'HV'

#%% add MTOW
fn_nc = 'lib/aircraftcategories_RMI.csv'
noisecats = pd.read_csv(fn_nc)
noisecats = noisecats.rename(columns={'icao_aircraft': 'AC_typeICAO'})

#merge
m = pd.merge(data, noisecats, on='AC_typeICAO')


columns = ['iata_aircraft',
           'icao_airline',
           'iata_airline',
           'ac_cat',
           'wtc',
           'safety_cat',
           'motor',
           'comment']
m= m.drop(columns, axis=1)

#%% pivot tabel
m['mtow_cat'] = pd.cut(m['mtow'],
        [0,6,40,60,160,230,300,1000], labels=["< 6", "6-40", "40-60","60-160", "160-230", "230-300","> 300"])
table = pd.pivot_table(m, values='Sum', index=['CG'],
                    columns=['mtow_cat'], aggfunc=np.sum)


#%% Print to excel
output_excel    = 'output/GA_VERKEER.xls'
writer = pd.ExcelWriter(output_excel)
table.to_excel(writer)
writer.save()











