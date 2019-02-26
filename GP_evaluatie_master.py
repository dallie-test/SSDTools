import lib.GPlib as GP
import lib.doc29lib as doc29
import pandas as pd
import lib.huisstijl as lh
import os

#%% settings
gj = 2018

realisatie      = 'input/realisatie/Vluchten Export 2017-11-01 00_00_00 - 2018-11-01 00_00_00_2019-01-29 10_59_35.csv'
prognose_winter = 'input/001 Hybride/traffic Winterseizoen.txt'
prognose_zomer  = 'input/001 Hybride/traffic Zomerseizoen.txt'
prognose_mean   = 'input/001 Hybride/traffic 1971-2016 - mean.txt'
prognose_years1   = 'input/001 Hybride/traffic 1971-2016 - years.txt'
prognose_years2   = 'input/001 Hybride Scenario Onderhoud/traffic 1971-2016 - years.txt'
output_folder   = 'output/'
history_excel         = 'input/history.xlsx'


#%% preparation
hs = lh.getHuisStijl() 

# check if output folder exists:
if not os.path.exists(output_folder):
    os.makedirs(output_folder)

if not os.path.exists(output_folder+ 'figuren/'):
    os.makedirs(output_folder+ 'figuren/')   
    
#% input traffics
data_realisatie         = pd.read_csv(realisatie)
data_realisatie['C_AD'] = data_realisatie['C_sidstar']
data_realisatie['C_AD'] = 'D' 
arrivals = ['RIVER','SUGOL','ARTIP']
data_realisatie.loc[data_realisatie['C_sidstar'].isin(arrivals),'C_AD']='A'

data_prognose_winter    = pd.read_csv(prognose_winter, sep="\t")
data_prognose_zomer     = pd.read_csv(prognose_zomer, sep="\t")

# add summer to winter prognose
data_prognose = pd.concat([data_prognose_winter,data_prognose_zomer])

#% split traffic into GA, HV traffic, heli traffic
flnat_hv               = ['PL','PC','PP','PF','FL','FC','FP','FF'] #N.B. 8 flnat codes maken HV
data_realisatie_ga     = data_realisatie[~data_realisatie['C_naflt'].isin(flnat_hv)]
data_realisatie_HV     = data_realisatie[data_realisatie['C_naflt'].isin(flnat_hv)]

u           = pd.unique(data_realisatie['C_ac_type'])
heli        = ['AS32', 'AS55', 'EC20', 'EC30', 'EC35', 'EC55','EH10','G2CA', 'S76', 'PUMA', 'R44','H25' , 'A109', 'A139',]
data_heli   = data_realisatie_ga[data_realisatie_ga['C_ac_type'].isin(heli)]

#%% figuur 2.1
history = pd.read_excel(history_excel,'realisatie')
# prognose data 
prognose_max = 500000
prog = sum(data_prognose['total'])
prognose_min = 492000
prognose = [gj,prog,prognose_min,prognose_max]

# make figure
fn = output_folder + 'figuren/figuur21.png'
GP.figHistory(history,prognose,'verkeer',fn,hs,ylim = [350000,505000])

#%% tabel 2.1
DEN_prognose    = GP.DENverdeling(data_prognose,"d_schedule","d_lt",'prognose',"total")
DEN_realisatie  = GP.DENverdeling(data_realisatie_HV,"C_actual","C_AD",'realisatie')

#samenvoegen tot 1 tabel
DEN = pd.concat([DEN_prognose,DEN_realisatie], axis=1)
print(DEN)


#%% tabel 2.2
prognose_zomer  = int(round(data_prognose_zomer['total'].sum(),-2))
prognose_winter = int(round(data_prognose_winter['total'].sum(),-2))

## zomer winter verdeling realisatie
SW_realisatie = GP.SWverdeling(data_realisatie_HV,'C_actual',gj)

#tabel maken
d = {'prognose': [prognose_winter,prognose_zomer], 'realisatie': SW_realisatie}
SW = pd.DataFrame(data=d)
del SW.index.name
print(SW)

#%% figuur 2.2
data_prognose_mean = pd.read_csv(prognose_mean, sep="\t")
vvc_pattern     = ['[0]\/[0-9]','[12]\/[0-9]','[3]\/[0-9]','[45]\/[0-9]','[6]\/[0-9]','[7]\/[0-9]','[89]\/[0-9]']
MTOW            = ['< 6','6 - 40','40 - 60','60 - 160','160 - 230','230 - 300','> 300'] 

# prognose
for find,replace in zip(vvc_pattern,MTOW): 
    data_prognose_mean = data_prognose_mean.replace(to_replace=find,value=replace,regex=True)

vloot = data_prognose_mean.groupby(['d_ac_cat'])['total'].sum()
vloot = vloot.reindex(MTOW)
vloot= vloot/vloot.sum()*100
vloot = vloot.fillna(0)

# realisatie
for find,replace in zip(vvc_pattern,MTOW): 
    data_realisatie_HV = data_realisatie_HV.replace(to_replace=find,value=replace,regex=True)

vloot2 = data_realisatie_HV.groupby(['C_VVC'])['C_actual'].count()
vloot2 = vloot2.reindex(MTOW)
vloot2 = vloot2/vloot2.sum()*100
vloot2 = vloot2.fillna(0)

# make figure
fn = output_folder+ 'figuren/figuur22.png'
GP.fig23(vloot,'prognose',fn,hs,
         vloot2,
         'realisatie')

#%% tabel 2.3 en tabel 2.4
starts, landingen = GP.procedureverdeling(data_realisatie_HV,data_prognose_mean)
print(starts)
print(landingen)

#%% figuur 4.1

style='MER'
labels = ['GP2018','GP2018 excl. GO']
trf_files = [prognose_years2,
             prognose_years1]
fn = 'output/figuren/figuur41.png'
den=['D', 'E', 'N']
GP.plot_baangebruik(trf_files,
                 labels,
                 hs,
                 data_realisatie_HV,
                 den,
                 fn)


#% FIGUUR 4.4
fn = 'output/figuren/figuur42.png'
den=['N']
GP.plot_baangebruik(trf_files,
                 labels,
                 hs,
                 data_realisatie_HV,
                 den,
                 fn,
                 ylim=[0,12000],
                 dy=1000)


#%% figuur 5.1 TO DO remake into GP format, currently in MER format

realisatie_grid_lden = 'input/realisatie/Result_Lden_EHAM_2018_klein'
realisatie_grid_lnight = 'input/realisatie/Result_Lnight_EHAM_2018_klein'
prognose_input_folder = 'input/001 Hybride/'

prognose_grid = doc29.gridimport(prognose_input_folder, 'GP2018 - Lden', scale=1.025, mm='empirisch')
realisatie_hdr,realisatie_dat= doc29.read_envira(realisatie_grid_lden, noHeader=False, scale=1)
X1, Y1, Z1 = doc29.verfijn(realisatie_hdr, realisatie_dat, func=None, k=20)
X2, Y2, Z2 = doc29.verfijn(prognose_grid[0], prognose_grid[1]['mean'], func=None, k=20)

fn = 'output/figuren/figuur51.png'
doc29.verschilplot(X1, Y1, [Z1,Z2],
                   fn)

#%% figuur 5.2
prognose_grid = doc29.gridimport(prognose_input_folder, 'GP2018 - Lnight', scale=1.025, mm='empirisch')
realisatie_hdr,realisatie_dat= doc29.read_envira(realisatie_grid_lnight, noHeader=False, scale=1)
X1, Y1, Z1 = doc29.verfijn(realisatie_hdr, realisatie_dat, func=None, k=20)
X2, Y2, Z2 = doc29.verfijn(prognose_grid[0], prognose_grid[1]['mean'], func=None, k=20)

fn = 'output/figuren/figuur52.png'
doc29.verschilplot(X1, Y1, [Z1,Z2],
                   fn)

#%% figuur 6.1 t/m 6.4

key = ['w58den', 'eh48den','w48n', 'sv40n']
files = ['figuur61', 'figuur62', 'figuur63', 'figuur64']
fn = [output_folder + 'figuren/'+ f + '.png' for f in files]
jaar = 2018

history2 = pd.read_excel(history_excel,'prognose')
history2 = history2.set_index('jaar')

for k,f in zip(key,fn):
    # prognose data 
    prognose = [jaar,
                history2[k+'_mean'][jaar],
                history2[k+'_max'][jaar],
                history2[k+'_min'][jaar]]
    
    GP.figHistory(history,prognose,k,f,hs)

#%% tabel 6.1 TO DO
    
#%% tabel 6.2 TO DO
    
#%% tabel 6.3 TO DO

#%% Print to excel
writer = pd.ExcelWriter(output_folder + 'tabellen_evaluatie_gj2018.xlsx' )
DEN.to_excel(writer,sheet_name='DENverdeling')
SW.to_excel(writer,sheet_name='Seizoensverdeling')
starts.to_excel(writer,sheet_name='Startprocedures')
landingen.to_excel(writer,sheet_name='Landingsprocedures')
writer.save()






