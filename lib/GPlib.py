
def importGP():
    #pandas
    pandas = __import__('pandas', globals(), locals()) 
    pd = pandas
    # do not show annoyng subset warnings
    pd.options.mode.chained_assignment = None  # default='warn'
    #numpy
    numpy = __import__('numpy', globals(), locals())
    np = numpy
    # plotlib
    matplotlib = __import__('matplotlib', globals(), locals())
    plt = matplotlib.pyplot
    lines = matplotlib.lines
    MultipleLocator = matplotlib.ticker.MultipleLocator
    FuncFormatter = matplotlib.ticker.FuncFormatter
    
    # datetime
    datetime = __import__('datetime', globals(), locals())  
    # pformat
    lib = __import__('lib.plotformat', globals(), locals())
    pformat = lib
    return pd, np, plt, datetime, pformat,lines,MultipleLocator,FuncFormatter


def DENverdeling(df,hdr_time,hdr_sum,hdr_LT,hdr_multiindex):
    
    pd, np, plt, datetime, pformat,lines,MultipleLocator,FuncFormatter = importGP()
    hdr1 = hdr_multiindex+ ', landingen'
    hdr2 = hdr_multiindex+ ', starts'
    hdr3 = hdr_multiindex+ ', totaal'
    
    
    df[hdr_time] = pd.to_datetime(df[hdr_time])
    df['DEN'] =df[hdr_time]
    df['DEN'] = "D"
    # change string to date
    t1 = pd.to_datetime('22:59:59')
    t2 = pd.to_datetime('07:00:00')
    t3 = pd.to_datetime('18:59:59')
    t4 = pd.to_datetime('23:00:00')
    t5 = pd.to_datetime('05:59:59')
    # logical indexing
    df['DEN'][(df[hdr_time]>t1) | (df[hdr_time]<t2)] = "N"
    df['DEN'][(df[hdr_time]>t3) & (df[hdr_time]<t4)] = "E"
    df['DEN'][(df[hdr_time]>t5) & (df[hdr_time]<t2)] = "EM"
    # change LT or AD to starts en landingen
    df[hdr_LT][(df[hdr_LT] == 'L') | (df[hdr_LT] == 'A')] = hdr1
    df[hdr_LT][(df[hdr_LT] == 'T') | (df[hdr_LT] == 'D')] =  hdr2
    # use groubpy to aggregate
    df_out          = pd.pivot_table(df,values=hdr_sum,index='DEN',columns=hdr_LT, aggfunc=np.sum) 
    # swap EM and N rows
    df_out = df_out.reindex(["D", "E", "N","EM"])
    
    
    df_out[hdr3]    = df_out[hdr1]+df_out[hdr2]
    # swap rows
    
    df_out.loc['totaal']    = df_out.sum()
    # round to 100 
    df_out = round(df_out,-2)
    
    #create group headers
    a = df_out .columns.str.split(', ', expand=True).values
    df_out.columns = pd.MultiIndex.from_tuples([('', x[0]) if pd.isnull(x[1]) else x for x in a])
    return df_out


def SWverdeling(df,hdr_date,hdr_sum,gj):
    #import packages
    pd, np, plt, datetime, pformat,lines,MultipleLocator,FuncFormatter = importGP()
    #make summer/winter column
    df[hdr_date] = pd.to_datetime(df[hdr_date])
    df['SW']  =df[hdr_sum]
    df['SW'] = "zomer"
    
    season = 'zomer'
    start = gebruiksjaar(gj,season)
    df['SW'][df[hdr_date]<start] = 'winter'
    df_out = df.groupby(['SW']).agg({hdr_sum:'sum'}).reset_index()
    # round to 100 
    df_out = round(df_out,-2)
#    df_out.reset_index(['SW'])
    return df_out


def gebruiksjaar(year,season):
    pd, np, plt, datetime, pformat,lines,MultipleLocator,FuncFormatter = importGP()
    if (season =='summer') | (season == 'zomer'):
        #zondag van het laatste weekend van Maart
        date = datetime.date(year,  3, 31 - (int(float(4 + 5 * year/4)) % 7))
    else:
        #zondag van het laatste weekend van oktober
        date = datetime.date(year, 10, 31 - (int(float(1 + 5 * year/4)) % 7)) 
    startdate = datetime.datetime.combine(date,datetime.time(0,0))
    return startdate
    

def plot_baangebruik(trf_files,
                     labels,
                     trf_realisatie,
                     TL,
                     DEN='DEN',
                     fname=None,
                     n=7,
                     runways=None,
                     ylim=[0,110000],
                     dy=10000,
                     reftraffic=1,
                     style='MER',
                     dpi=300):
    '''Plot het baangebruik'''
    
    # import GPlibrary
    import lib.GPlib as GP
    pd, np, plt, datetime, pformat,lines,MultipleLocator,FuncFormatter = GP.importGP()
    import lib.plotformat as pformat
    
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
    w = GetVal(pformat.baangebruik[style]['barwidth'], i) # of /ntrf
    g = GetVal(pformat.baangebruik[style]['bargap'], i) # of /ntrf?
    
    dx = [(w+g)*(i - 0.5*(ntrf-1)) for i in range(ntrf)]
    
    # markers en staafjes
    marker_height = dy * GetVal(pformat.baangebruik[style]['markerheight'], i)
    mw = GetVal(pformat.baangebruik[style]['markerwidth'], i)
    dxm = list(dx)
    
    # clip marker
    if ntrf == 2:
        mw = (mw + w)/2
        dxm[0] = dx[0] - (mw-w)/2
        dxm[1] = dx[1] + (mw-w)/2
    elif ntrf > 2:
        mw = [min(mw, w+g)]
    
    # open 1 figuur
    fig, (ax1) = plt.subplots(1, 1, sharey=True)
    fig.set_size_inches(21/2.54, 10/2.54)
    
    # margins
    fig.subplots_adjust(bottom=0.18)    
    fig.subplots_adjust(wspace=0)
    
    # LEGENDA 1
    ax0 = fig.add_axes([0, 0.9, 0.6, 0.1]) 
    # geen assen
    ax0.axis('off') 
    # genormaliseerde asses
    ax0.set_xlim(-.5, 0.5)
    ax0.set_ylim(0, 1)
    
    
    for i, yi, xt, stylo1, stylo2 in [(0, 0.5, 0,'bar','marker'),
                       (1, 0.5, 0.15,'refbar','refmarker'),
                       (2, 0.5, 0.25,'refbar1','refmarker1'),
                       (3, 0.5, 0.45,'refbar2','refmarker2')]:
        if i<2:
            ax0.bar(xt, height=0.6, bottom=0.1,
                    width=0.02,
                    **pformat.baangebruik[style][stylo1],
                    zorder=4)
        
        ax0.bar(xt, height=0.1, bottom=0.5,
                width=0.04,
                **pformat.baangebruik[style][stylo2],
                zorder=6)
        
        ax0.text(xt+0.03, 0.5, labels[i],
                 **pformat.baangebruik[style]['legendtext'])
    
    
    
    # LEGENDA 2 - REALISATIE
    ax0b = fig.add_axes([-0.05, 0.9, 0.3, 0.1]) 
    # geen assen
    ax0b.axis('off')
    # genormaliseerde asses
    ax0b.set_xlim(-.5, 0.5)
    ax0b.set_ylim(0, 1)
    #plot realisatie
    ax0b.plot([0,0.3],
             [0.5,0.5],
             'k--',
             zorder=10,
             linewidth=2)   
    
    ax0b.text(0.3, 0.5, 'realisatie',
                 **pformat.baangebruik[style]['legendtext'])
    
    
    # Realisatie
    trf = pd.read_csv(trf_realisatie, delimiter='\t')
    
    # if night figure do
    if DEN!='DEN':
        trf = trf[trf['d_den']=='N']
          
    trf = trf.groupby(['d_lt', 'd_runway', 'd_myear'])['total'].sum().reset_index()

    trf_stats = trf.groupby(['d_lt', 'd_runway'])['total'].agg(['min','max','mean']).reset_index()
#    print(trf_stats)
    
    # selecteer L of T
    trfn = trf_stats.loc[trf_stats['d_lt'] == TL]
    trfn = trfn.sort_values(by =['mean'],ascending=False)
    trfn = trfn.head(n) # gaat alleen goed als er ook echt n-runways zijn
    ind= trfn['d_runway']
#    print(trfn)
#    print(ind)
   
    stylo1 = ['bar','refbar','refbar1','refbar2']
    stylo2 = ['marker','refmarker','refmarker1','refmarker2']
    
    # verwerken traffics
    for i, trf_file in enumerate(trf_files):
        # lees csv
        trf = pd.read_csv(trf_file, delimiter='\t') 
        
        # if night figure do
        if DEN!='DEN':
            trf = trf[trf['d_den']=='N']
        
        # aggregeer etmaalperiode en bereken stats
        trf = trf.groupby(['d_lt', 'd_runway', 'd_myear'])['total'].sum().reset_index()
        trf_stats = trf.groupby(['d_lt', 'd_runway'])['total'].agg(['min','max','mean']).reset_index()
        
        
        # filter out NOG flights
        trf_stats =trf_stats.query("d_runway != 'NOG'").reset_index()
        
        
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
        
        if TL == 'L':
            le = ['landingen']
            st1 = 'facecolor2'
        else:
            le = ['starts']
            st1 ='facecolor1'
            
        # maak de plot
        for lt, xlabel, fc, spine, ax in zip(TL,
                                             le,
                                             pformat.baangebruik[style][st1],
                                             ['right', 'left'],
                                             [ax1]):

            # selecteer L of T
            trf2 = trf_stats.loc[trf_stats['d_lt'] == lt]
            trf2 = trf2.head(n) # gaat alleen goed als er ook echt n-runways zijn
#            print(trf2)
            trf2 = trf2.set_index('d_runway')
            #set index to correct order
            trf2 = trf2.reindex(ind)
            trf2 = trf2.reset_index()
            
#            print(trf2)
            
            # staafjes
            bar_height = trf2['max'] - trf2['min']
                
            ax.bar(x+dx[i], height=bar_height, bottom=trf2['min'],
                   width=w,
                   **pformat.baangebruik[style][stylo1[i]],
                   zorder=4)
            
            # gemiddelde
            ax.bar(x+dxm[i], height=marker_height, bottom=trf2['mean']-marker_height/2,
                   width=mw,
                   **pformat.baangebruik[style][stylo2[i]],
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
            
    #plot realisatie
    ax1.plot([x-0.4,x+0.4],
             [trfn['mean'],trfn['mean']],
             'k--',
             zorder=10,
             linewidth=2)        
    
    #save if nescessary, or print to screen
    if fname:
        fig.savefig(fname, dpi=dpi)
        plt.close(fig)
    else:
        plt.show()






