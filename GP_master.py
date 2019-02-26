
import pandas as pd

import lib.GPlib as lg
import lib.doc29lib as ld

import lib.huisstijl as lh

from matplotlib import rcParams
import os

#%% inputs folders
input_folder       = 'input/Hybride/'
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



#%% FIGUUR 5.1
hdr_den, dat_den = ld.gridimport(grid_dir = input_folder,
                                           noise = 'GP2019 - Lden doc29',
                                           scale = 1.025) 



#%% FIGUUR 5.2
hdr_n, dat_n = ld.gridimport(grid_dir = input_folder,
                                           noise = 'GP2019 - Lnight doc29',
                                           scale = 1.0) 



GWC = lg.compGWCforGP(hdr_den,
                      hdr_n,
                      dat_den,
                      dat_n,
                      de='doc29')

#%%

print(GWC)
output_excel        = 'output/GWC_GP2019_v2.xlsx'
writer = pd.ExcelWriter(output_excel)
GWC.to_excel(writer,sheet_name='GWC')
writer.save()

