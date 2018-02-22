# -*- coding: utf-8 -*-
"""
Created on Thu Nov 16 09:19:57 2017

@author: gordijn_e
"""
import matplotlib.pyplot as plt

baangebruik = {'MER': {'markerwidth': [0.15, 0.15, 0.15],   # voor 1, 2 en >2 traffics
                       'markerheight': [0.2, 0.2, 0.2],  # voor 1, 2 en >2
                       'barwidth': [0.1, 0.1, 0.1],
                       'bargap': [0.1, 0.1, 0.1],            # voor 1, 2 en >2
                       'bar': {'facecolor': '#adc5e2',
                                'edgecolor': ['#4d4d4d']*10, # bug in Matplotlib
                                'linewidth': 0.3},
                       'refbar': {'facecolor': '#ecce5f',
                                'edgecolor': ['#4d4d4d']*10, # bug in Matplotlib
                                'linewidth': 0.3},                             
                       'refbar1': {'facecolor': '#ab2222',
                                'edgecolor': ['#4d4d4d']*10, # bug in Matplotlib
                                'linewidth': 0.3},                             
                       'refbar2': {'facecolor': '#2b6e1e',
                                'edgecolor': ['#4d4d4d']*10, # bug in Matplotlib
                                'linewidth': 0.3},
                       'marker': {'facecolor': '#3a96b2',
                                   'edgecolor': ['#4d4d4d']*10, # bug in Matplotlib
                                   'linewidth': 0.3},
                       'refmarker': {'facecolor': '#e88c2b',
                                   'edgecolor': ['#4d4d4d']*10, # bug in Matplotlib
                                   'linewidth': 0.3},
                       'refmarker1': {'facecolor': '#ab2222',
                                   'edgecolor': ['#4d4d4d']*10, # bug in Matplotlib
                                   'linewidth': 0.3},
                       'refmarker2': {'facecolor': '#2b6e1e',
                                   'edgecolor': ['#4d4d4d']*10, # bug in Matplotlib
                                   'linewidth': 0.3},
                       'spines': {'color': '#4d4d4d',
                                  'linewidth': 0.5},
                       'facecolor1': {'#dae9e8'},
                       'facecolor2': {'#e2dfcd'},
                       'grouplines': {'color': '#4d4d4d',
                                      'linewidth': 0.5},
                       'axislabel': {'labelcolor': '#333333',
                                     'labelsize': 8},
                       'grouptext': {'color': '#333333',
                                     'fontsize': 10,
                                     'horizontalalignment':'center',
                                     'verticalalignment':'center'},
                       'legendtext': {'color': '#333333',
                                     'fontsize': 8,
                                     'verticalalignment':'center'}}}
                       
                       
contourplot = {'MER': {'colors': ['#8c564b','#9467bd','#ff7f0e','#1f77b4','#17becf'],
                       'contour': {'linewidths':[0.35, 0.5]},
                       'annotate': {'bbox': {'boxstyle':'round4,pad=0.3',
                                             'facecolor':(1.0, 1.0, 1.0, 0.4),
                                             'edgecolor':(0, 0.45, 0.45, 1.0),
                                             'linewidth':0.5},
                                    'arrowprops': {'arrowstyle':'-',
                                                   'color':(0, 0.45, 0.45, 1.0),
                                                   'linewidth':0.5},
                                    'color':'black',
                                    'size':6},
                      'annotatemarker': {'color':(0, 0.45, 0.45, 1.0),
                                          'marker':'o',
                                          's':3},
                      'legend': {'fontsize':6,
                                 'fancybox':True},                   
                      'legendframe': {'facecolor':(1.0, 1.0, 1.0, 0.4),
                                      'edgecolor':(0, 0.45, 0.45, 1.0)},
                      'legendtitle': {'fontsize': 8}}}

verschilplot = {'MER': {'cmap': plt.cm.BrBG_r,
                      'colorbarlabel': {'labelsize': 6,
                                        'labelcolor':(0, 0.45, 0.45, 1.0)},
                      'colorbaroutline': {'edgecolor':(0, 0.45, 0.45, 1.0),
                                          'linewidth': 0.5,}}}                       