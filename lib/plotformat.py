# -*- coding: utf-8 -*-
"""
Created on Thu Nov 16 09:19:57 2017

@author: gordijn_e
"""
import matplotlib.pyplot as plt

baangebruik = {'MER': {'markerwidth': [0.5, 0.4, 0.08],   # voor 1, 2 en >2 traffics
                       'markerheight': [0.2, 0.2, 0.08],  # voor 1, 2 en >2
                       'barwidth': [0.15, 0.15, 0.04],
                       'bargap': [0, 0, 0.05],            # voor 1, 2 en >2
                       'refbar': {'facecolor': '#ecce5f',
                                'edgecolor': ['#4d4d4d']*10, # bug in Matplotlib
                                'linewidth': 0.3},                             
                       'bar': {'facecolor': '#adc5e2',
                                'edgecolor': ['#4d4d4d']*10, # bug in Matplotlib
                                'linewidth': 0.3},
                       'refmarker': {'facecolor': '#e88c2b',
                                   'edgecolor': ['#4d4d4d']*10, # bug in Matplotlib
                                   'linewidth': 0.3},
                       'marker': {'facecolor': '#3a96b2',
                                   'edgecolor': ['#4d4d4d']*10, # bug in Matplotlib
                                   'linewidth': 0.3},
                       'spines': {'color': '#4d4d4d',
                                  'linewidth': 0.5},
                       'facecolor': ['#dae9e8', '#e2dfcd'],
                       'grouplines': {'color': '#4d4d4d',
                                      'linewidth': 0.5},
                       'axislabel': {'labelcolor': '#333333',
                                     'labelsize': 6},
                       'grouptext': {'color': '#333333',
                                     'fontsize': 14,
                                     'horizontalalignment':'center',
                                     'verticalalignment':'center'},
                       'legendtext': {'color': '#333333',
                                     'fontsize': 6,
                                     'verticalalignment':'center'}}}

verkeersvolume = {'MER': {'history': {'marker': 'o',
                                      'markersize': 4,   
                                      'markerfacecolor': 'none',
                                      'markeredgecolor': '#4d4d4d',
                                      'markeredgewidth': 0.5,
                                      'linewidth': 1.0,
                                      'color': '#ecce5f'},
                         'spines': {'color': '#4d4d4d',
                                  'linewidth': 0.5},
                         'facecolor': ['#dae9e8', '#e2dfcd'],
                         'gridline': {'linewidth': 0.75,
                                      'color': 'white'},
                         'grouplines': {'color': '#4d4d4d',
                                        'linewidth': 0.5},
                         'axislabel': {'labelcolor': '#333333',
                                       'labelsize': 6},
                         'grouptext': {'color': '#333333',
                                       'fontsize': 14,
                                       'horizontalalignment':'center',
                                       'verticalalignment':'center'},
                         'legendtext': {'color': '#333333',
                                        'fontsize': 4,
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
                        'colorbar': {'format': '%.1f'},
                        'colorbarlabel': {'labelsize': 6,
                                          'labelcolor':(0, 0.45, 0.45, 1.0)},
                        'colorbaroutline': {'edgecolor':(0, 0.45, 0.45, 1.0),
                                            'linewidth': 0.5,}}}                       