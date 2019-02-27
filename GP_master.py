
import pandas as pd

import lib.GPlib as lg
import lib.doc29lib as ld

import lib.huisstijl as lh

from matplotlib import rcParams
import os

#%% inputs folders
input_folder        = 'input/Hybride/'
input_folder_MER    = 'input/MER2018 H_500_doc29_actualisatie - inclusief TC/'
output_folder       = 'output/' 


#%% process inputs

# Gebruiksjaarinfo
jaar = 2019
winter, summer = lg.GebruiksjaarInfo(year=jaar)


# check if output folder exists:
if not os.path.exists(output_folder):
    os.makedirs(output_folder)

if not os.path.exists(output_folder+ 'figuren/'):
    os.makedirs(output_folder+ 'figuren/')   
   

# huisstijl
hs = lh.getHuisStijl() 
rcParams['font.family'] = hs['fontname']['grafiek']



##%% FIGUUR 5.1
#hdr_den, dat_den = ld.gridimport(grid_dir = input_folder,
#                                           noise = 'GP2019 - Lden doc29',
#                                           scale = 1.025)
#
##%% FIGUUR 5.2
#hdr_n, dat_n = ld.gridimport(grid_dir = input_folder,
#                                           noise = 'GP2019 - Lnight doc29',
#                                           scale = 1.0) 
#
##%% verschilplot
#
#hdr_den_MER, dat_den_MER = ld.gridimport(grid_dir = input_folder_MER,
#                                           noise = 'MER2018 - Doc29 - Lden',
#                                           scale = 1.025) 
#
#hdr_n_MER, dat_n_MER = ld.gridimport(grid_dir = input_folder_MER,
#                                           noise = 'MER2018 - Doc29 - Lnight',
#                                           scale = 1.0) 
#
#
#X1, Y1, Z1 = ld.verfijn(hdr_den, dat_den['mean'], func=None, k=20)
#X2, Y2, Z2 = ld.verfijn(hdr_den_MER, dat_den_MER['mean'], func=None, k=20)
#
#fn = 'output/figuren/verschil_MER_GP_Lden_mean.png'
#ld.verschilplot(X1, Y1, [Z1,Z2],fn,
#                labels=['GP','MER'],
#                legend_title=r'Geluidbelasting $L_{den}$',
#                deltas='default',
#                cutoff='default',
#                levels=[48, 58])
#
#
#X1, Y1, Z1 = ld.verfijn(hdr_n, dat_n['mean'], func=None, k=20)
#X2, Y2, Z2 = ld.verfijn(hdr_n_MER, dat_n_MER['mean'], func=None, k=20)
#
#fn =  'output/figuren/verschil_MER_GP_Lnight_mean.png'
#ld.verschilplot(X1, Y1, [Z1,Z2],fn,
#                labels=['GP','MER'],
#                legend_title=r'Geluidbelasting $L_{night}$',
#                deltas='default',
#                cutoff='default',
#                levels=[40, 48])


#%% verschil in traffic

prognose_winter = 'input/Hybride/traffic Winterseizoen.txt'
prognose_zomer  = 'input/Hybride/traffic Zomerseizoen.txt'

data_GP_winter    = pd.read_csv(prognose_winter, sep="\t")
data_GP_zomer     = pd.read_csv(prognose_zomer, sep="\t")

# add summer to winter prognose
data_GP = pd.concat([data_GP_winter,data_GP_zomer])


prognose_MER    = 'input/MER2018 H_500_doc29_actualisatie - inclusief TC/traffic 500k geschaald obv GP2019.txt'
data_MER        = pd.read_csv(prognose_MER, sep="\t")


DEN_MER    = lg.DENverdeling(data_MER,"d_schedule","d_lt",'prognose',"total")
DEN_GP    = lg.DENverdeling(data_GP,"d_schedule","d_lt",'prognose',"total")



#samenvoegen tot 1 tabel
DEN = pd.concat([DEN_GP,DEN_MER], axis=1)
print(DEN)
#
##%% GWC
#GWC = lg.compGWCforGP(hdr_den,
#                      hdr_n,
#                      dat_den,
#                      dat_n,
#                      de='doc29')

#print(GWC)
output_excel        = 'output/traffic_vergelijking.xlsx'
writer = pd.ExcelWriter(output_excel)
#GWC.to_excel(writer,sheet_name='GWC')
DEN.to_excel(writer,sheet_name='DEN')
writer.save()

