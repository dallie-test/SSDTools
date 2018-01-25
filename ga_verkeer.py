import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
#%%
filename = 'gj2017_AD_callsign.csv'
data = pd.read_csv(filename)

data["time_ACT"]=pd.to_datetime(data["time_ACT"])
data["DEN"]=data["time_ACT"]


#%%
data["DEN"]= "D"
# change string to date of today N.B.
t1 =pd.to_datetime('2018-1-23 22:59:59')
t2 =pd.to_datetime('2018-1-23 07:00:00')
t3 =pd.to_datetime('2018-1-23 18:59:59')
t4 =pd.to_datetime('2018-1-23 23:00:00')
t5 =pd.to_datetime('2018-1-23 05:59:59')

data["DEN"][(data['time_ACT']>t1) | (data['time_ACT']<t2)] = "N"
data["DEN"][(data['time_ACT']>t3) & (data['time_ACT']<t4)] = "E"
#data["DEN"][(data['time_ACT']>t5) & (data['time_ACT']<t2)] = "EM"
#%%
data_ga = data[~data['FLNAT_code'].isin(['PL','PC','PP','FL','FC','FP'])]

u = pd.unique(data['AC_typeICAO'])

heli =['AS32', 'AS55', 'EC20', 'EC30', 'EC35', 'EC55','EH10','G2CA', 'S76', 'PUMA', 'R44','H25' , 'A109', 'A139',]

data_heli = data_ga[data_ga['AC_typeICAO'].isin(heli)]



#%% aggregate

data_a = data.groupby(['DEN']).agg({'Sum':'sum'}).reset_index()

data_a_ga = data_ga.groupby(['DEN']).agg({'Sum':'sum'}).reset_index()
data_a_heli = data_heli.groupby(['DEN']).agg({'Sum':'sum'}).reset_index()


#%% bracket verdeling
n_flights = data_ga.query('DEN == "N" or DEN == "EM"')
# tijdblok
hour                    = n_flights['time_ACT'].dt.hour
minute                  = n_flights['time_ACT'].dt.minute
n_flights['tijdsblok']  = pd.Categorical(1 + hour*3 + minute//20, categories=range(1,73))
#PerTijdsblok            = n_flights.groupby(['AD','tijdsblok']).agg({'Sum':'sum'}).reset_index()      
table = pd.pivot_table(n_flights, values='Sum', index=['tijdsblok'],
                    columns=['AD'], aggfunc=np.sum)
l = [70,71,72]+list(range(1,22))
table = table.reindex(l)

fig = table.plot(kind='bar',stacked=True)
fig.set_xlabel("tijdsblok", fontsize=12)
fig.set_ylabel("Bewegingen", fontsize=12)
fig.grid(color='k', linestyle='-', linewidth=.3)
plt.show()
fig.figure.savefig('GA_nacht_totaal.png', dpi=300)


#%% bracket verdeling 2 
n_flights = data_heli.query('DEN == "N" or DEN == "EM"')
# tijdblok
hour                    = n_flights['time_ACT'].dt.hour
minute                  = n_flights['time_ACT'].dt.minute
n_flights['tijdsblok']  = pd.Categorical(1 + hour*3 + minute//20, categories=range(1,73))
#PerTijdsblok            = n_flights.groupby(['AD','tijdsblok']).agg({'Sum':'sum'}).reset_index()      
table = pd.pivot_table(n_flights, values='Sum', index=['tijdsblok'],
                    columns=['AD'], aggfunc=np.sum)
l = [70,71,72]+list(range(1,22))
table = table.reindex(l)

fig2 = table.plot(kind='bar',stacked=True)
fig2.set_xlabel("tijdsblok", fontsize=12)
fig2.set_ylabel("Bewegingen", fontsize=12)
fig2.grid(color='k', linestyle='-', linewidth=.3)
plt.show()
fig2.figure.savefig('GA_nacht_heli.png', dpi=300)

#%% bracket verdeling 3 
n_flights = data_ga.query('DEN == "N" or DEN == "EM"')
n_flights['heli'] = 'GA'
n_flights['heli'][n_flights['AC_typeICAO'].isin(heli)] = 'heli'

# tijdblok
hour                    = n_flights['time_ACT'].dt.hour
minute                  = n_flights['time_ACT'].dt.minute
n_flights['tijdsblok']  = pd.Categorical(1 + hour*3 + minute//20, categories=range(1,73))
#PerTijdsblok            = n_flights.groupby(['AD','tijdsblok']).agg({'Sum':'sum'}).reset_index()      
table = pd.pivot_table(n_flights, values='Sum', index=['tijdsblok'],
                    columns=['heli'], aggfunc=np.sum)
l = [70,71,72]+list(range(1,22))
table = table.reindex(l)


fig3 = table.plot(kind='bar',stacked=True)
fig3.set_xlabel("tijdsblok", fontsize=12)
fig3.set_ylabel("Bewegingen", fontsize=12)
fig3.grid(color='k', linestyle='-', linewidth=.3)
plt.show()
fig3.figure.savefig('GA_breakdown.png', dpi=300)



#%% callsign verdeling

flights = data_heli    
table = pd.pivot_table(flights, values='Sum', index=['Flightnr'],
                    columns=['DEN'], aggfunc=np.sum)
