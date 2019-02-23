import os
import sys
import re
import pickle
from time import time
import numpy as np
import pandas as pd
from scipy.ndimage import generic_filter
from scipy.interpolate import RectBivariateSpline
from scipy.spatial import distance
from scipy.misc import imread
import matplotlib.pyplot as plt
from matplotlib.colors import ListedColormap
from matplotlib import lines
from matplotlib.ticker import MultipleLocator, FuncFormatter
from descartes import PolygonPatch
from geopandas import GeoDataFrame

import lib.plotformat as pformat

gwc = {'doc29_2005': [13600, 166500, 14600, 45000],
       'doc29_2015': [14000, 180000, 14800, 48500]}


def tic(message=''):
    '''Start timer'''
    global _ticTime
    _ticTime = time()
    if message:
        print('{:6.1f} s: {:s}'.format(0, message))


def toc(message='', reset=False):
    '''Print de tijd sinds tic'''
    global _ticTime
    print('{:6.1f} s  {:s}'.format(time() - _ticTime, message))
    if reset:
        _ticTime = time()

    
def make_dir(directory):
    '''Maak een directory aan als die nog niet bestaat'''
    # add trailing slash...
    directory = os.path.join(directory, '')
    if not os.path.exists(directory):
        os.makedirs(directory)
        
    return directory


def check_dir(directory):
    '''Check of een directory echt bestaat'''
    directory = os.path.join(directory, '')
    if not os.path.exists(directory):
        sys.exit('Directory not found:\n    {:s}'.format(directory))
    else:
        return directory        


def read_adressen(wbs, hdr=None, dat=None, limit=48, footprint=3, key='wbs'):
    'Read woningbestand met geluidbelasting boven de limietwaarde'
    
    if hdr is not None and dat is not None:
        # stap 1: limietwaarde
        b = dat >= limit
        
        # stap 2: breid de selectie uit
        fp = np.ones((footprint, footprint), dtype=bool)
        c = generic_filter(b, any, footprint=fp)[:-1,:-1]
        
        # stap 3: vind de x-, en y-waarden
        iy, ix = np.where(c)
        
        x = hdr['Xonder'] + ix*hdr['Xstap']
        y = hdr['Yonder'] + iy*hdr['Ystap']
        
        cells = set(x*1000000 + y)    
        
        # Lees adressen in    
        df = pd.read_hdf(wbs, key=key, where='index=cells')
    else:
        df = pd.read_hdf(wbs, key=key)
               
    return df


def hdr_val(string, type):
    'Read value from header line'
    
    name, val = string.split()
    return type(val)

    
def read_envira(grid, noHeader=False, scale=1):
    'Read NLR grid-file and return header and noise data'

    with open(grid, "r") as data:
        hdr = {}
        hdr['tekst1'] = data.readline().strip()
        hdr['tekst2'] = data.readline().strip()  
        hdr['tekst3'] = data.readline().strip()
        
        line = data.readline()
        hdr['datum'], hdr['tijd'] = line.split()
        
        hdr['eenheid'] = hdr_val(data.readline(), str)
        hdr['grondinvloed'] = hdr_val(data.readline(), str)
        
        # skip, heeft geen functie meer 
        # hdr['tellingen'] = hdr_val(data.readline(), int)
        data.readline()
        
        hdr['demping_landing'] = hdr_val(data.readline(), float)
        hdr['demping_start'] = hdr_val(data.readline(), float)
        hdr['mindba'] = hdr_val(data.readline(), float)
        hdr['tijdstap'] = hdr_val(data.readline(), float)            
        hdr['Xonder'] = hdr_val(data.readline(), int)
        hdr['Xboven'] = hdr_val(data.readline(), int)
        hdr['Xstap'] = hdr_val(data.readline(), int)
        hdr['nx'] = hdr_val(data.readline(), int)
        hdr['Yonder'] = hdr_val(data.readline(), int)
        hdr['Yboven'] = hdr_val(data.readline(), int)
        hdr['Ystap'] = hdr_val(data.readline(), int)
        hdr['ny'] = hdr_val(data.readline(), int)
        hdr['nvlb'] = hdr_val(data.readline(), int)
        hdr['neff'] = hdr_val(data.readline(), float)  
        hdr['nlos'] = hdr_val(data.readline(), int)  
        hdr['nweg'] = hdr_val(data.readline(), int)  

        # Overschrijf onbetrouwbare waarden
        hdr['Xboven'] = hdr['Xonder'] + (hdr['nx'] - 1) * hdr['Xstap']
        hdr['Yboven'] = hdr['Yonder'] + (hdr['ny'] - 1) * hdr['Ystap']
           
        dat = np.flipud(np.fromfile(data ,sep=" ").reshape(hdr['ny'], hdr['nx']))
    
    # Schaalfactor    
    dat = dat + 10*np.log10(scale)
        
    if noHeader:
        return dat
    else:
        return hdr, dat
    

def write_envira(filename, hdr, dat, scale=1):
    'Write NLR grid-file with header and noise data'
    
    # Schaalfactor    
    dat = dat + 10*np.log10(scale)
    
    with open(filename, 'w' ) as f:
        
        # Write the header
        f.write('{:s}\n'.format(hdr['tekst1']))
        f.write('{:s}\n'.format(hdr['tekst2']))
        f.write('{:s}\n'.format(hdr['tekst3']))
        f.write('{:s} {:s}\n'.format(hdr['datum'], hdr['tijd']));
        f.write('EENHEID {:s}\n'.format(hdr['eenheid']))
        f.write('GRONDINVLOED {:s}\n'.format(hdr['grondinvloed']))
        f.write('TELLINGEN\n')
        f.write('DEMPING-LANDING {:6.2f}\n'.format(hdr['demping_landing']))
        f.write('DEMPING-START {:6.2f}\n'.format(hdr['demping_start']))
        f.write('MINDBA {:6.2f}\n'.format(hdr['mindba']))
        f.write('TIJDSTAP {:6.2f}\n'.format(hdr['tijdstap']))
        f.write('X-ONDER {:9.0f}\n'.format(hdr['Xonder']))
        f.write('X-BOVEN {:9.0f}\n'.format(hdr['Xboven']))
        f.write('X-STAP {:9.0f}\n'.format(hdr['Xstap']))
        f.write('NX{:6.0f}\n'.format(hdr['nx']))
        f.write('Y-ONDER {:9.0f}\n'.format(hdr['Yonder']))
        f.write('Y-BOVEN {:9.0f}\n'.format(hdr['Yboven']))
        f.write('Y-STAP {:9.0f}\n'.format(hdr['Ystap']))
        f.write('NY{:6.0f}\n'.format(hdr['ny']))
        f.write('NVLB {:9.0f}\n'.format(hdr['nvlb']))
        f.write('NEFF {:9.0f}\n'.format(hdr['neff']))
        f.write('NLOS {:9.0f}\n'.format(hdr['nlos']))
        f.write('NWEG {:9.0f}\n'.format(hdr['nweg']))
        
        # Write noise data
        np.set_printoptions(threshold=np.nan)
        f.write(np.array2string(np.flipud(dat), 
                                max_line_width=131,
                                formatter={'float': lambda x: '{:12.6E}'.format(x)})
               .replace('[', ' ')
               .replace(']', '')
               .replace('  ', ' '))


def mmgrid(dat, years, unit, mm='hybride'):
    '''Bepaald max-grid exclusief buitengewoon weerjaren

       dat          noisegrids van alle jaren
       years        de jaren in de dat
       unit         Lden of Lnight
       mm           methode of jaren waarmee de meteotoeslag wordt bepaald
   '''

    # Methode
    if isinstance(mm, str):
        mm_dict = {('empirisch', 'Lden'): [1972,1976,1981,1990,1994,1996,2000,2003],
                   ('empirisch', 'Lnight'): [1973,1979,1985,1989,1994,1995,1996,2002],
                   ('hybride', 'Lden'): [1981,1984,1993,1994,1996,2000,2002,2010],
                   ('hybride', 'Lnight'): [1973,1976,1980,1987,1994,1995,1996,2010]}
                               
        mmyears= np.setdiff1d(np.arange(1971, 2011), mm_dict[(mm, unit)])
    else:
        mmyears = mm                       
    
    i_my = np.array([i in mmyears for i in years])
    
    if np.sum(i_my) != 32:
        print('Expected 32 meteoyears but found {:d}'.format(np.sum(i_my)))
        sys.exit('Eror in mmgrid')
    
    mmDat = np.amax(dat[i_my,:,:], axis=0)
    
    return mmDat, mmyears
    
    
def gridstats(dat, scale=1):
    '''Bepaal gemiddelde, standaard deviate en betrouwbaarheidsinterval'''
    
    # Schaalfactor
    dat = dat + 10*np.log10(scale)
    
    # Statistiek
    meanDat = 10*np.log10(np.mean(10**(dat/10), axis=0))
    stdDat = np.std(dat, axis=0)
    
    # Betrouwbaarheidsinterval (99.5%)
    z = 2.5758
    dhiDat = meanDat + z*stdDat
    dloDat = meanDat - z*stdDat
    
    return {'mean': meanDat,
            'std': stdDat,
            'dhi': dhiDat,
            'dlo': dloDat,
            'dat': dat}


def gridimport(grid_dir, noise, scale=1, mm='hybride'):
    '''Lees de grids in de opgegeven directory

       grid_dir     directory met de Daisy-grids
       noise        te gebruiken noise als regular expression
       scale        schaalfactor
       mm           methode of jaren waarmee de meteotoeslag wordt bepaald
   '''
   
    # Absolute path
#    base_dir = os.path.dirname(__file__)
    base_dir = os.getcwd()
    grid_dir = os.path.join(base_dir, grid_dir)
    
    # Read files 
    files = [f for f in sorted(os.listdir(grid_dir)) if re.match(noise + ' y', f)]
    base_name = files[0][:-10] # exlusief 'y0000.dat'
        
    if not files:
        print('No files found: \n  dir: {:s}\nnoise: {:s}'.format(grid_dir, noise))
        sys.exit('Eror in gridimport')

# Bug!
# Gaat fout als je opnieuw importeerd met een andere schaalfactor dan de eerste keer
#
        
#    try:
#        with open(grid_dir + base_name + '_hdr.pkl', 'rb') as f:
#            hdr = pickle.load(f)
#        with open(grid_dir + base_name + '_dat.pkl', 'rb') as f:
#            grids = pickle.load(f)
#    except:
    dat = []
    my = []
    for file in files:
        hdr, my_dat = read_envira(os.path.join(grid_dir, file))   
        dat.append(my_dat)
        
        my.append(int(file[-8:-4]))
    
    grids = {'dat': np.asarray(dat)}
  
    # Header aanvullen
    hdr['noise'] = base_name
    hdr['my'] = my
    hdr['mm'] = mm

#    if 'scale' not in hdr or hdr['scale'] != scale:
    hdr['scale'] = scale

    # Statistiek
    grids = gridstats(grids['dat'], scale) 
    
    # Meteotoeslag
    grids['mm'], hdr['mmy'] = mmgrid(grids['dat'], years=hdr['my'], unit=hdr['eenheid'], mm=mm)
        
#        # Export naar Pickle
#        with open(grid_dir + base_name + '_hdr.pkl', 'wb') as f:
#            pickle.dump(hdr, f)
#        with open(grid_dir + base_name + '_dat.pkl', 'wb') as f:
#            pickle.dump(grids, f)
   
    return hdr, grids
                  
                  
def interpolatie_func(hdr, dat):
    'Bepaal de bi-cubic spline interpolatie functie'
    
    # Dimensions coarse grid    
    X0 = np.linspace(hdr['Xonder'], hdr['Xboven'], num=hdr['nx'])
    Y0 = np.linspace(hdr['Yonder'], hdr['Yboven'], num=hdr['ny'])
    Z0 = dat    

    return RectBivariateSpline(Y0, X0, Z0)

def grid_interpolatie(wbs, hdr, dat):
    '''Bepaal de geluidbelasting op de adreslocaties o.b.v.
       cubic-spline interpolatie.
       
       Resultaat is een array met de geluidbelasting en een
       interpolatiefunctie.'''
    
    func = interpolatie_func(hdr, dat)   
    db = func(wbs['y'], wbs['x'], grid=False)

    return db, func


def verfijn(hdr, dat, func=None, k=20):
    'Interpoleer met bi-cubic spline'    

    # Dimensions refined grid
    nx1 = 1 + k*(hdr['nx'] - 1)
    ny1 = 1 + k*(hdr['ny'] - 1)
    X1 = np.linspace(hdr['Xonder'], hdr['Xboven'], num=nx1)
    Y1 = np.linspace(hdr['Yonder'], hdr['Yboven'], num=ny1)

    # Refine the grid
    if func is None:
        func = interpolatie_func(hdr, dat)
    Z1 = func(Y1, X1)

    return X1, Y1, Z1

    
def gehinderden(db, personen, de='ges2002', dbmax=65):
    '''Bereken het aantal gehinderden
       
       db        Array met dB-waarden
       
       personen  Array met het aantal personen
       
       de        Dosis-effectrelatie, ges2002 of doc29
    
       dbmax     Kap de dosis-effectrelatie bij deze waarde af       
                 Bij ges2002 is het gebruikelijk om voor dB-waarden boven de 65 dB(A)
                 de dosis-effectrelatie te gebruiken bij 65 dB(A). In doc 29 wordt
                 de afkap niet gebruikt.
    '''

    # Afkap bij dbmax
    if dbmax is not None:
        db = np.minimum(db, dbmax)
    
    # Dosis-effectrelatie toepassen
    if de == 'ges2002':
        egh = personen * 1 / (1/np.exp(-8.1101 + 0.1333*db) + 1)
    elif de == 'doc29-v0':
        egh = personen * np.minimum(1, 1 - 1/(1 + np.exp(-8.638 + 0.1336*db)) 
                                         + 0.00002938*db**2)
    elif de == 'doc29':
        egh = personen * (1 - 1/(1 + np.exp(-7.7130 + 0.1260*db))) 

    return egh


def slaapverstoorden(db, personen,  de='ges2002', dbmax=65):
    '''Bereken het aantal slaapverstoorden
        
       db        Array met dB-waarden
       
       personen  Array met het aantal personen
       
       de        Dosis-effectrelatie, ges2002 of doc29
    
       dbmax     Kap de dosis-effectrelatie bij deze waarde af       
                 Bij ges2002 is het gebruikelijk om voor dB-waarden boven de 57 dB(A)
                 de dosis-effectrelatie te gebruiken bij 57 dB(A). In doc 29 wordt
                 de afkap niet gebruikt.
    '''
    
    # Afkap bij dbmax
    if dbmax is not None:
        db = np.minimum(db, dbmax)
    
    # Dosis-effectrelatie toepassen
    if de == 'ges2002':
        sv = personen * 1 / (1/np.exp(-6.642 + 0.1046*db) + 1)
    elif de == 'doc29-v0':
        sv = personen * np.minimum(1, 1 - 1/(1 + np.exp(-9.733 + 0.1457*db)) 
                                        + 0.00003897*db**2)
    elif de == 'doc29':
        sv = personen * (1 - 1/(1 + np.exp(-6.2952 + 0.0960*db)))
        
    return sv
    
    
def tellen_etmaal(db, woningen, personen, de='ges2002', scale=1, bins=[48,58,9999], cumulatief=True):
    '''Tel het aantal woningen en gehinderen binnen de contourwaarden'''

    db = db + 10*np.log10(scale)
    egh_per_locatie = gehinderden(db, personen, de)

    w, _ = np.histogram(db, bins=bins, weights=woningen)
    egh, _ = np.histogram(db, bins=bins, weights=egh_per_locatie)
    
    if cumulatief:
        return np.cumsum(w[::-1]), np.cumsum(egh[::-1])
    else:
        return w, egh

    
def tellen_nacht(db, woningen, personen, de='ges2002', scale=1, bins=[40,48,9999], cumulatief=True):
    '''Tel het aantal woningen en slaapverstoorden binnen de contourwaarden'''

    db = db + 10*np.log10(scale)
    sv_per_locatie = slaapverstoorden(db, personen, de)

    w, _ = np.histogram(db, bins=bins, weights=woningen)
    sv, _ = np.histogram(db, bins=bins, weights=sv_per_locatie)
    
    if cumulatief:
        return np.cumsum(w[::-1]), np.cumsum(sv[::-1])
    else:
        return w, sv


def schaal_per_etmaalperiode(dat_den, hdr_den, dat_n, scale_de=1, scale_n=1, c=True):
    '''Schaal het Lden-grid afzonderlijk voor de dag- en avondperiode
       en de nachtperiode.
    '''

    # Corrigeer Lnight naar Ln
    if c:
        # Corrigeer met 10 dB en de tijdscorrectie voor Lnight
        dat_n = dat_n + 10 + 10*np.log10(8/24)
    else:
        # Corrigeer alleen met 10 dB
        dat_n = dat_n + 10
        
    # Schaal alleen de dag- en avondperiode
    db = 10*np.log10((10**(dat_den/10) - 10**(dat_n/10)) * scale_de
                     + (10**(dat_n/10) * scale_n))

    # Statistiek
    grids = gridstats(db) 
    
    # Meteotoeslag
    grids['mm'], _ = mmgrid(db, years=hdr_den['my'], unit=hdr_den['eenheid'], mm='hybride')
    
    return grids

       
def relatief_norm_etmaal(scale, norm, wbs, dat_den, hdr_den, dat_n=None,
                         scale_de=None, scale_n=None, c=True):
    '''Bereken het verschil t.o.v. de norm voor woningen en ernstig gehinderden'''
    
    if dat_n is not None:
        if scale_de is None: scale_de = scale
        if scale_n is None: scale_n = scale
        
        dat_den = schaal_per_etmaalperiode(dat_den, hdr_den, dat_n,
                                           scale_de=scale_de,
                                           scale_n=scale_n,
                                           c=c)
        dat_den = dat_den['mm']
        scale = 1
        
    # Interpoleer geluidbelasting
    dbden, _ = grid_interpolatie(wbs, hdr_den, dat_den)
        
    w, p = tellen_etmaal(dbden, wbs['woningen'], wbs['personen'], scale=scale)
    
#    print('{:7.0f}{:7.0f}'.format(w[0], p[1]))

    delta_w = norm[0] - w[0]
    delta_p = norm[1] - p[1]
    
    return min(delta_w, delta_p)                  


def start_contourplot(figsize=(21/2.54, 21/2.54),
                      xlim=(80000,140000),
                      ylim=(455000,515000),
                      background='default',
                      schiphol_border='default',
                      placenames='default',
                      extent=[80000, 158750, 430000, 541375]):
    'Initieer een plot'

    # Nieuw figuur met figsize
    fig = plt.figure(figsize=figsize)

    # Don't show axis                  
    ax = plt.Axes(fig, [0., 0., 1., 1.])
    ax.set_axis_off()
    fig.add_axes(ax)

    # Square X- and Y-axis
    ax.set_aspect('equal', 'box')
    
    # Zoom in
    ax.set_xlim(xlim)
    ax.set_ylim(ylim)
    
    # Achtergrond
    if background is not None:
        if isinstance(background, str):
            if background == 'default':
                background = imread('lib/Schiphol_RD900dpi.png')
            else:
                 background = imread(background)

        ax.imshow(background, zorder=0, extent=extent)

    # Plaatsnamen                                    
    if placenames is not None:
        if placenames == 'default':
            placenames = pd.read_csv('lib/plaatsnamen.csv', comment='#')
        else:
            placenames = pd.read_csv(placenames, comment='#')

        color=(0.0, 0.3, 0.3)
        for index, row in placenames.iterrows():
            ax.annotate(row['name'], xy=(row['x'], row['y']),
                        size=4,
                        color=color,
                        horizontalalignment='center',
                        verticalalignment='center')

    # Schiphol terreingrens
    if schiphol_border is not None:
        if schiphol_border == 'default':
            schiphol_border = GeoDataFrame.from_file('lib/2013-spl-luchtvaartterrein.shp')
        else:
            schiphol_border = GeoDataFrame.from_file(schiphol_border)

        fc = 'none'
        ec = (.0, .0, .0)
        poly = schiphol_border['geometry'][0]
        patch = PolygonPatch(poly, fc=fc, ec=ec, lw=0.2, zorder=10)
        ax.add_patch(patch)

        im = ax.imshow(background, clip_path=patch, clip_on=True, zorder=9, extent=extent)
        im.set_clip_path(patch)
        
    # Schaalbalk
    xpos = .95             # positie in fig-eenheden
    ypos = 0.04            # positie in fig-eenheden
    ticks = [0, 2, 5, 10]
        
        
    # Transform van data naar fig
    L_data = ticks[-1] * 1000
    L_disp = ax.transData.transform((L_data,0)) - ax.transData.transform((0,0))
    inv_fig = fig.transFigure.inverted()        
    L_fig = inv_fig.transform(L_disp)[0]
    
    ax2 = fig.add_axes([xpos-L_fig, ypos, L_fig, 0.01]) 
    
    # transparant background
    ax2.patch.set_alpha(0)
    
    # Zet spines uit
    for loc in ['right', 'left', 'top']:
        ax2.spines[loc].set_color('none')
    
    # Geen Y-as
    ax2.yaxis.set_ticks([])
    
    # X-ticks
    ax2.xaxis.set_ticks(ticks)
    labels = ['{}'.format(tick) for tick in ticks]
    labels[-1] = '{} km'.format(ticks[-1])
    ax2.set_xticklabels(labels)
    
    # Format
    color = (0.0, 0.3, 0.3)
    ax2.spines['bottom'].set_color(color)
    ax2.spines['bottom'].set_linewidth(0.5)
    ax2.tick_params(axis='x',
                    labelsize=6,
                    colors=color,
                    length=4,
                    direction='in',
                    width=0.5)
        
    return fig, ax
    
    
def contourplot(x, y, z,
                fname,
                fig=None,
                ax=None,
                labels=None,
                legend_title=r'Geluidbelasting $L_{den}$',
                levels=[48, 58],
                ankerpoints=[(115000, 495500), (112000, 497500)],
                dxy=(7000, 3000),
                style='MER',
                title=None,
                schiphol_border='default',
                background='default',
                placenames='default',
                extent=[80000, 158750, 430000, 541375],
                dpi=300):
    '''Maak een contourplot'''
    
    def GetVal(var, i):
        'Scalar of een list'
        if isinstance(var, list):
            i = min(i, len(var)) # hergebruik van de laatste waarde 
            return var[i]
        else:
            return var
        
    # Init met achtergrond
    if fig is None:
        fig, ax = start_contourplot(background=background,
                                    schiphol_border=schiphol_border,
                                    placenames=placenames)

    # Title
    if title:
        ax.title.set_position([.02, .96])
        ax.set_title(title, fontsize=12, horizontalalignment='left')
        title_space=0.02
    else:
        title_space=0

    # Contours
    cs = []
    if not isinstance(z, list): z = [z]
    for i, zi in enumerate(z):
        cs.append(ax.contour(x, y, zi,
                             levels=levels,
                             colors=pformat.contourplot[style]['colors'][i],
                             **pformat.contourplot[style]['contour']))
        # Legenda
        if labels:
            cs[i].collections[1].set_label(GetVal(labels, i))

    # Legenda
    if labels:
        legend = ax.legend(title=legend_title,
                           **pformat.contourplot[style]['legend'],
                           loc='upper left',
                           bbox_to_anchor=(0.02, 0.98-title_space))
        legend.get_title().set(**pformat.contourplot[style]['legendtitle'])
        
        frame = legend.get_frame()
        frame.set(**pformat.contourplot[style]['legendframe'])
    
    # Annotate contours
    for level, ankerpoint, cs in zip(levels, ankerpoints, cs[0].collections):
    
        # Nearest datapunt
        xy2 = [vertices for path in cs.get_paths() for vertices in path.vertices]
        p2 = xy2[distance.cdist([ankerpoint], xy2).argmin()]
        textloc = p2 + dxy
        
        # ax.scatter(ankerpoint[0],ankerpoint[1], color='red', marker='o', s=3)
        ax.scatter(p2[0],p2[1], 
                   **pformat.contourplot[style]['annotatemarker'],
                   zorder=10)
        
        text='{} dB(A)'.format(level)
        ax.annotate(text, xy=p2, xytext=textloc,
                    **pformat.contourplot[style]['annotate'])
                    
    if fname:
        fig.savefig(fname, dpi=dpi)
        plt.close(fig)
    else:
        plt.show()


def verschilplot(x, y, z,
                 fname,
                 labels=None,
                 legend_title=r'Geluidbelasting $L_{den}$',
                 deltas='default',
                 cutoff='default',
                 levels=[48, 58],
                 ankerpoints=[(115000, 495500), (112000, 497500)],
                 dxy=(7000, 3000),
                 style='MER',
                 title=None,
                 schiphol_border='default',
                 background='default',
                 placenames='default',
                 extent=[80000, 158750, 430000, 541375],
                 dpi=300):
    "Maak een verschilplot met contouren en delta's"
    
    # Init met achtergrond
    fig, ax = start_contourplot(background=background,
                                schiphol_border=schiphol_border,
                                placenames=placenames)

    
    # Start contourplot
    contourplot(x, y, z, fname, fig, ax, labels, legend_title, levels,
                ankerpoints, dxy, style, title, schiphol_border, background,
                placenames, extent, dpi)

    delta_z = z[1] - z[0]    
             
    # Lineair fading between level[0] and cutoff
    if cutoff == 'default':
        cutoff = levels[0] - 3
        
    if cutoff is not None:
        maxgrid = np.amax(z, axis=0)
        fading = (maxgrid - cutoff) / (levels[0] - cutoff)
        
        fading[maxgrid < cutoff] = 0
        fading[maxgrid > levels[0]] = 1
        
        delta_z = delta_z * fading
        
    # Plot deltas    
    if deltas is 'default':
        deltas = np.arange(-1.5,1.6,0.1)
    
    # colormap
    cmap = pformat.verschilplot[style]['cmap']
    
    # Extend colormap
    cmap.set_under(cmap(0))
    cmap.set_over(cmap(-1))
    
    # Get the colormap colors
    my_cmap = cmap(np.arange(cmap.N))
    
    # Set alpha
    # Linear between +- tipping_point and zero
    # ---         ---
    #     \     /
    #       ---
    tipping_pnt = deltas[-1]/6 # 0.25 bij een bereik van -1.5 tot +1.5
    zero_pnt = deltas[-1]/10   # 0.15 bij een bereik van -1.5 tot +1.5
    index1 = int((deltas.max() - tipping_pnt) * cmap.N / (deltas.max()-deltas.min()))
    index2 = int((deltas.max() - zero_pnt) * cmap.N / (deltas.max()-deltas.min()))
    index3 = (cmap.N- 2* index2) # //2    
    my_cmap[:,-1] = np.concatenate((np.ones(index1),
                                    np.linspace(1, 0, index2 - index1),
                                    np.zeros(index3),
                                    np.linspace(0, 1, index2 - index1),
                                    np.ones(index1)
                                  )) * 0.8
    
    # Create new colormap
    delta_cmap = ListedColormap(my_cmap)
    

        
    cs0 = ax.contourf(x, y, delta_z, deltas,
                       cmap=delta_cmap, extend='both',
                       origin='lower')
    
    # Add colorbar
    mn=deltas[0]           # colorbar min value
    mx=deltas[-1]          # colorbar max value
    md=round((mx+mn)/2, 1) # colorbar midpoint value
    
    cbaxes = fig.add_axes([0.05, 0.04, 0.2, 0.015]) 
    cb = fig.colorbar(cs0, cax=cbaxes, ticks=[mn,md,mx],
                      orientation='horizontal',
                      **pformat.verschilplot[style]['colorbar'])
    cb.patch.set_alpha(0)  # transparant background

    # Ticks
    cb.ax.tick_params(length=0,
                      **pformat.verschilplot[style]['colorbarlabel'])
    
    # Linewidth
    cb.outline.set(**pformat.verschilplot[style]['colorbaroutline'])
                    
    if fname:
        fig.savefig(fname, dpi=dpi)
        plt.close(fig)
    else:
        plt.show()


def plot_baangebruik(trf_files,
                     labels,
                     den=['D', 'E', 'N'],
                     fname=None,
                     n=7,
                     runways=None,
                     ylim=[0,110000],
                     dy=10000,
                     reftraffic=1,
                     style='MER',
                     dpi=300):
    '''Plot het baangebruik'''

    def NumberFormatter(x, pos):
        'The two args are the value and tick position'
        return '{:,.0f}'.format(x).replace(',', '.')
    def GetVal(var, i):
        'Scalar of een list'
        if isinstance(var, list):
            i = min(i, len(var)-1) # hergebruik van de laatste waarde 
            return var[i]
        else:
            return var

    
    # check of trf_files een string of list is   
    if not isinstance(trf_files, list):
        trf_files = [trf_files]
        
    # N = trf_stats['d_lt'].count()
    
    # X-positie van de bars
    x = np.arange(n)

    ntrf = len(trf_files)
    i = ntrf - 1
    w = (GetVal(pformat.baangebruik[style]['barwidth'], i) # of /ntrf
         * n/7) # normaliseer voor de aslengte
    g = GetVal(pformat.baangebruik[style]['bargap'], i) # of /ntrf?
    
    dx = [(w+g)*(i - 0.5*(ntrf-1)) for i in range(ntrf)]
    
    # markers en staafjes
    marker_height = (GetVal(pformat.baangebruik[style]['markerheight'], i)
                     * (ylim[-1] - ylim[0]) / 10) 
    mw = (GetVal(pformat.baangebruik[style]['markerwidth'], i)
          * n/7)
    dxm = list(dx)
    
    # clip marker
    if ntrf == 2:
        mw = (mw + w)/2
        dxm[0] = dx[0] - (mw-w)/2
        dxm[1] = dx[1] + (mw-w)/2
    elif ntrf > 2:
        mw = [min(mw, w+g)]
    
    # twee aansluitende subplots
    fig, (ax1, ax2) = plt.subplots(1, 2, sharey=True)
    fig.set_size_inches(21/2.54, 10/2.54)
    
    # margins
    fig.subplots_adjust(bottom=0.18)    
    fig.subplots_adjust(wspace=0)
    
    # legenda
    ax0 = fig.add_axes([0.8, 0.9, 0.05, 0.1]) 
    
    # geen assen
    ax0.axis('off')
    
    # genormaliseerde asses
    ax0.set_xlim(-0.5*n/7, 0.5*n/7)
    ax0.set_ylim(0, 1)
    
    # staafjes
    if ntrf == 2:
        #TODO: 1 of >2 staafjes
        # gemiddelde
        for i, yi, bottom, xt, yt, alignment in [(0, 0.4, 0.1, 0.2, 0.4, 'right'),
                                                 (1, 0.5, 0.3, 0.8, 0.4, 'left')]:
            if i == reftraffic:
                ref = 'ref'
            else:
                ref = ''
            ax0.bar(dx[i], height=0.6, bottom=bottom,
                    width=w,
                    **pformat.baangebruik[style][ref+'bar'],
                    zorder=4)
            ax0.bar(dxm[i], height=0.05, bottom=yi,
                    width=mw,
                    **pformat.baangebruik[style][ref+'marker'],
                    zorder=6)
            ax0.text(xt, yt, labels[i],
               transform=ax0.transAxes,
               horizontalalignment=alignment,
               **pformat.baangebruik[style]['legendtext'])
    
    
    # verwerken traffics
    for i, trf_file in enumerate(trf_files):
        
        # lees csv
        trf = pd.read_csv(trf_file, delimiter='\t')
        trf = trf.loc[trf['d_den'].isin(den)]
        
        # aggregeer etmaalperiode en bereken stats
        trf = trf.groupby(['d_lt', 'd_runway', 'd_myear'])['total'].sum().reset_index()
        trf_stats = trf.groupby(['d_lt', 'd_runway'])['total'].agg(['min','max','mean']).reset_index()
        
        # sorteer
        if 'key' not in trf_stats.columns:
            trf_stats['key'] = trf_stats['d_lt'] + trf_stats['d_runway']

        if runways is not None:
            # tweede traffic in dezelfde volgorde
            keys = [k + r for k in runways for r in runways[k]]    # keys: combinatie van lt en runway
            sorterIndex = dict(zip(keys, range(len(keys))))        # plak een volgnummer aan de keys     
            trf_stats['order'] = trf_stats['key'].map(sorterIndex) # soteerindex toevoegen
            trf_stats = trf_stats.sort_values(by=['order'])        # sorteer dataframe
        else:
            trf_stats = trf_stats.sort_values(by=['d_lt', 'mean'], ascending=False)
            runways = {'L': trf_stats['d_runway'].loc[trf_stats['d_lt'] == 'L'],
                       'T': trf_stats['d_runway'].loc[trf_stats['d_lt'] == 'T']}
        
        # maak de plot
        for lt, xlabel, fc, spine, ax in zip(['T', 'L'],
                                             ['starts', 'landingen'],
                                             pformat.baangebruik[style]['facecolor'],
                                             ['right', 'left'],
                                             [ax1, ax2]):
            
            # selecteer L of T
            trf2 = trf_stats.loc[trf_stats['d_lt'] == lt]
            trf2 = trf2.head(n) # gaat alleen goed als er ook echt n-runways zijn
            
            # staafjes
            bar_height = trf2['max'] - trf2['min']
            if i == reftraffic:
                ref = 'ref'
            else:
                ref = ''
                
            ax.bar(x+dx[i], height=bar_height, bottom=trf2['min'],
                   width=w,
                   **pformat.baangebruik[style][ref+'bar'],
                   zorder=4)
            
            # gemiddelde
            ax.bar(x+dxm[i], height=marker_height, bottom=trf2['mean']-marker_height/2,
                   width=mw,
                   **pformat.baangebruik[style][ref+'marker'],
                   zorder=4)
          
            # achtergrondkleur
            ax.set_facecolor(fc)
        
            # border
            plt.setp(ax.spines.values(), **pformat.baangebruik[style]['spines'])
                     
            # scheidingslijntje tussen subplots
            ax.spines[spine].set_color('white')
        
            # tweak scheidingslijntje tussen subplots
            for y in [0,1]:
                frame = lines.Line2D([0, 1], [y, y], 
                              transform=ax1.transAxes,
                              **pformat.baangebruik[style]['spines'],
                              zorder=10)
                frame.set_clip_on(False)
                ax.add_line(frame)  
                 
            # gridlines
            ax.grid(which='major', axis='y', linewidth=0.5, color='white')
            
            # geen tickmarks
            plt.setp([ax.get_xticklines(), ax.get_yticklines()], color='none')
        
            # label size and color   
            ax.tick_params(axis='both', **pformat.baangebruik[style]['axislabel'])
                    
            # X-as
            ax.set_xticks(x)
            ax.set_xticklabels(trf2['d_runway'])
            ax.text(0.5, -0.18, xlabel,
               transform=ax.transAxes,
               **pformat.baangebruik[style]['grouptext'])
          
            # X-as lijntjes
            ax.set_xlim(-0.5, n-0.5)
            line = lines.Line2D([0.02, 0.98], [-.11, -.11], 
                                transform=ax.transAxes,
                                **pformat.baangebruik[style]['grouplines'])
            line.set_clip_on(False)
            ax.add_line(line)
        
            # Y-as
            ax.set_ylim(ylim)
            ax.yaxis.set_major_locator(MultipleLocator(base=dy))
            ax.yaxis.set_major_formatter(FuncFormatter(NumberFormatter))
            
    if fname:
        fig.savefig(fname, dpi=dpi)
        plt.close(fig)
    else:
        plt.show()
