import lib.GPlib as GP
pd, np, plt, datetime, pformat,lines,MultipleLocator,FuncFormatter = GP.importGP()

#%% settings

gj = 2017
realisatie      = 'TIS_traffics/gj2017_AD.csv'
prognose_winter = 'K:/D-CD/SSD/(b) CAP-EC/01 Kernactiviteiten/OP-Declaratie/2017/Evaluatie/2. daisy_output/GP2017/traffic Winterseizoen .txt'
prognose_zomer  = 'K:/D-CD/SSD/(b) CAP-EC/01 Kernactiviteiten/OP-Declaratie/2017/Evaluatie/2. daisy_output/GP2017/traffic Zomerseizoen .txt'

output_excel    = 'output/traffic_tabellen.xls'

#%% input traffics
data_realisatie      = pd.read_csv(realisatie)
data_prognose_winter = pd.read_csv(prognose_winter, sep="\t")
data_prognose_zomer  = pd.read_csv(prognose_zomer, sep="\t")

# add summer to winter prognose
data_prognose = pd.concat([data_prognose_winter,data_prognose_zomer])

#%% split traffic into GA, HV traffic, heli traffic
flnat_hv               = ['PL','PC','PP','PF','FL','FC','FP','FF'] #N.B. 8 flnat codes maken HV
data_realisatie_ga     = data_realisatie[~data_realisatie['FLNAT_code'].isin(flnat_hv)]
data_realisatie_HV     = data_realisatie[data_realisatie['FLNAT_code'].isin(flnat_hv)]

u           = pd.unique(data_realisatie['AC_typeICAO'])
heli        = ['AS32', 'AS55', 'EC20', 'EC30', 'EC35', 'EC55','EH10','G2CA', 'S76', 'PUMA', 'R44','H25' , 'A109', 'A139',]
data_heli   = data_realisatie_ga[data_realisatie_ga['AC_typeICAO'].isin(heli)]

#%% DEN distribution
DEN_realisatie  = GP.DENverdeling(data_realisatie_HV,"time_ACT","Sum","AD",'realisatie')
DEN_prognose    = GP.DENverdeling(data_prognose,"d_schedule","total","d_lt",'prognose')

#samenvoegen tot 1 tabel
DEN = pd.concat([DEN_realisatie, DEN_prognose], axis=1)
del DEN.index.name

#%% summer winter distribution
prognose_zomer  = int(round(data_prognose_zomer['total'].sum(),-2))
prognose_winter = int(round(data_prognose_winter['total'].sum(),-2))

# zomer winter verdeling realisatie
SW = GP.SWverdeling(data_realisatie_HV,'date_ACT','Sum',gj)

#tabellen samenvoegen
SW['prognose'] = SW['SW']
SW['prognose'][0] = prognose_winter
SW['prognose'][1] = prognose_zomer
SW = SW.rename(columns={'Sum': 'realisatie'})
SW = SW.set_index('SW')
del SW.index.name

#%% Print to excel
writer = pd.ExcelWriter(output_excel)
DEN.to_excel(writer,sheet_name='DENverdeling')
SW.to_excel(writer,sheet_name='Seizoensverdeling')
writer.save()

#%% plot het baangebruik

traffic = 'traffics/'
output = 'output/'
trf_files = [traffic +'traffic 1971-2015 - years_GP2017.txt',
             traffic +'traffic 1971-2015 - years_GP2017+US0624.txt',
             traffic +'traffic 2021 - years_GP2017+US0624+weer.txt',
             traffic +'traffic 2021 - years_GP2017+empirie+weer.txt']

trf_realisatie = traffic + '20171107_Traffic_2017_HV.txt'

labels = ['GP2017', 'GO','GO+meteo','GO+meteo+OO']

#%% DEN     
GP.plot_baangebruik(trf_files,
                    labels,
                    trf_realisatie,
                    TL='T',
                    fname=output+'Lden_TO.png')

GP.plot_baangebruik(trf_files,
                    labels,
                    trf_realisatie,
                    TL='L',
                    fname=output+'Lden_Landing.png')

#%% night
GP.plot_baangebruik(trf_files,
                    labels,
                    trf_realisatie,
                    TL='T',
                    DEN='N',
                    ylim=[0,20000],
                    dy=2000,
                    fname=output+'Lnight_TO.png')

GP.plot_baangebruik(trf_files,
                    labels,
                    trf_realisatie,
                    TL='L',
                    DEN='N',
                    ylim=[0,20000],
                    dy=2000,
                    fname=output+'Lnight_Landing.png')




































