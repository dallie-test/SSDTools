import lib.GPlib as GP

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












