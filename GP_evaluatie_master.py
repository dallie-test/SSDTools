import lib.GPlib as GP
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
history         = 'input/history.xlsx'

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
history = pd.read_excel(history)
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

##%% figuur 2.2
data_prognose_mean = pd.read_csv(prognose_mean, sep="\t")
#vvc_pattern     = ['[0]\/[0-9]','[12]\/[0-9]','[3]\/[0-9]','[45]\/[0-9]','[6]\/[0-9]','[7]\/[0-9]','[89]\/[0-9]']
#MTOW            = ['< 6','6 - 40','40 - 60','60 - 160','160 - 230','230 - 300','> 300'] 
#
## prognose
#for find,replace in zip(vvc_pattern,MTOW): 
#    data_prognose_mean = data_prognose_mean.replace(to_replace=find,value=replace,regex=True)
#
#vloot = data_prognose_mean.groupby(['d_ac_cat'])['total'].sum()
#vloot = vloot.reindex(MTOW)
#vloot= vloot/vloot.sum()*100
#vloot = vloot.fillna(0)
#
## realisatie
#for find,replace in zip(vvc_pattern,MTOW): 
#    data_realisatie_HV = data_realisatie_HV.replace(to_replace=find,value=replace,regex=True)
#
#vloot2 = data_realisatie_HV.groupby(['C_VVC'])['C_actual'].count()
#vloot2 = vloot2.reindex(MTOW)
#vloot2 = vloot2/vloot2.sum()*100
#vloot2 = vloot2.fillna(0)
#
## make figure
#fn = output_folder+ 'figuren/figuur22.png'
#GP.fig23(vloot,'prognose',fn,hs,
#         vloot2,
#         'realisatie')

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
                 realisatie,
                 den,
                 fn)


#% FIGUUR 4.4
fn = 'output/figuren/figuur42.png'
den=['N']
GP.plot_baangebruik(trf_files,
                 labels,
                 hs,
                 realisatie,
                 den,
                 fn,
                 ylim=[0,12000],
                 dy=1000)

#%% figuur 4.2



##%% tabelvorm baangebruik
#
##PROGNOSE
## aggregeer etmaalperiode en bereken stats
#trf_file = 'input/001 Hybride/traffic 1971-2016 - years.txt'
#trf = pd.read_csv(trf_file, delimiter='\t') 
#trf = trf.groupby(['d_lt', 'd_runway', 'd_myear'])['total'].sum().reset_index()
#trf_stats1 = round(trf.groupby(['d_lt', 'd_runway'])['total'].agg(['mean']).reset_index(),-2)
#        
##REALISATIE Nacht
#trf_stats2 = round(data_realisatie_HV.
#                   query('DEN == "N" | DEN == "EM"').
#                   groupby(['C_AD', 'C_runway'])['C_actual'].
#                   agg(['count']).
#                   reset_index(),-2)
#
#trf_stats2['C_AD'][(trf_stats2['C_AD'] == 'realisatie, landingen')] ='L' 
#trf_stats2['C_AD'][(trf_stats2['C_AD'] == 'realisatie, starts')] ='T' 
#trf_stats2['C_runway'][(trf_stats2['C_runway'] == '9')] ='09' 
#trf_stats2['C_runway'][(trf_stats2['C_runway'] == '6')] ='06' 
#trf_stats2['C_runway'][(trf_stats2['C_runway'] == '4')] ='04'
#
##REALISATIE etmaal
#trf_stats3 = round(data_realisatie_HV.
#                   groupby(['C_AD', 'C_runway'])['C_actual'].
#                   agg(['count']).
#                   reset_index(),-2)
#
#trf_stats3['C_AD'][(trf_stats3['C_AD'] == 'realisatie, landingen')] ='L' 
#trf_stats3['C_AD'][(trf_stats3['C_AD'] == 'realisatie, starts')] ='T' 
#trf_stats3['C_runway'][(trf_stats3['C_runway'] == '9')] ='09' 
#trf_stats3['C_runway'][(trf_stats3['C_runway'] == '6')] ='06' 
#trf_stats3['C_runway'][(trf_stats3['C_runway'] == '4')] ='04'
#
##%% merge
#m = trf_stats1.merge(trf_stats3,left_on=['d_lt', 'd_runway'],right_on=['C_AD', 'C_runway'],how='left')
#m = m.drop(columns=['C_AD', 'C_runway'])
#
##%% merge
#m = m.merge(trf_stats2,left_on=['d_lt', 'd_runway'],right_on=['C_AD', 'C_runway'],how='left')
#m = m.drop(columns=['C_AD', 'C_runway'])
#
##%% opmaak
#m = m.rename(columns={'d_lt': 'Landing/Take-off', 
#                      'd_runway': 'baan', 
#                      'mean': 'prognose, etmaal', 
#                      'count_x': 'realisatie, etmaal',
#                      'count_y': 'realisatie, nacht',})
#
#total = m.sum(numeric_only=True)
#total['Landing/Take-off'] = 'totaal'
#total['baan'] = 'totaal'
#m = m.append(total, ignore_index=True)
#
#m = m.fillna(value=0)
#BG = m.set_index(['Landing/Take-off','baan'])
#print(BG)
#


#%% Print to excel
writer = pd.ExcelWriter(output_folder + 'tabellen_evaluatie_gj2018.xlsx' )
DEN.to_excel(writer,sheet_name='DENverdeling')
SW.to_excel(writer,sheet_name='Seizoensverdeling')
starts.to_excel(writer,sheet_name='Startprocedures')
landingen.to_excel(writer,sheet_name='Landingsprocedures')
writer.save()



##%% plot het baangebruik
#traffic = 'traffics/'
#output = 'output/'
#trf_files = [traffic +'traffic 1971-2015 - years_GP2017.txt',
#             traffic +'traffic 1971-2015 - years_GP2017+US0624.txt',
#             traffic +'traffic 2021 - years_GP2017+US0624+weer.txt',
#             traffic +'traffic 2021 - years_GP2017+empirie+weer.txt']
#
#trf_realisatie = traffic + '20171107_Traffic_2017_HV.txt'
#
#labels = ['GP2017', 'GO','GO+meteo','GO+meteo+OO']
#
##%% DEN     
#GP.plot_baangebruik(trf_files,
#                    labels,
#                    trf_realisatie,
#                    TL='T',
#                    fname=output+'Lden_TO.png')
#
#GP.plot_baangebruik(trf_files,
#                    labels,
#                    trf_realisatie,
#                    TL='L',
#                    fname=output+'Lden_Landing.png')
#
##%% night
#GP.plot_baangebruik(trf_files,
#                    labels,
#                    trf_realisatie,
#                    TL='T',
#                    DEN='N',
#                    ylim=[0,20000],
#                    dy=2000,
#                    fname=output+'Lnight_TO.png')
#
#GP.plot_baangebruik(trf_files,
#                    labels,
#                    trf_realisatie,
#                    TL='L',
#                    DEN='N',
#                    ylim=[0,20000],
#                    dy=2000,
#                    fname=output+'Lnight_Landing.png')
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#








