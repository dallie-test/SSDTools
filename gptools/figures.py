import matplotlib.pyplot as plt
import pandas as pd
from descartes import PolygonPatch
from geopandas import GeoDataFrame

from scipy.misc import imread


class GridPlot(object):
    def __init__(self, grid, other_grid=None, title=None, figsize=None, xlim=None, ylim=None, background=None,
                 schiphol_border=None, place_names=None, extent=None):

        # Create an ID
        self.id = str(pd.Timestamp.utcnow())

        # Set the grids
        self.grid = grid
        self.other = other_grid

        # Set the plotting options
        self.title = title
        self.figsize = (21 / 2.54, 21 / 2.54) if figsize is None else figsize
        self.xlim = (80000, 140000) if xlim is None else xlim
        self.ylim = (455000, 515000) if ylim is None else ylim
        self.background = 'lib/Schiphol_RD900dpi.png' if background is None else background
        self.schiphol_border = 'lib/2013-spl-luchtvaartterrein.shp' if schiphol_border is None else schiphol_border
        self.place_names = 'lib/plaatsnamen.csv' if place_names is None else place_names
        self.extent = [80000, 158750, 430000, 541375] if extent is None else extent

        # Create a new figure
        self.fig, self.ax = self.create_figure()

    def create_figure(self):
        """
        Initialize a new contour plot.

        :return: the figure and axis handles.
        """

        # Create a new figure with figsize
        fig = plt.figure(num=self.id, figsize=self.figsize)

        # Don't show axis
        ax = plt.Axes(fig, [0., 0., 1., 1.])
        ax.set_axis_off()
        fig.add_axes(ax)

        # Square X- and Y-axis
        ax.set_aspect('equal', 'box')

        # Zoom in
        ax.set_xlim(self.xlim)
        ax.set_ylim(self.ylim)

        # Set the background
        if self.background is not False:
            if isinstance(self.background, str):
                self.background = imread(self.background)
            ax.imshow(self.background, zorder=0, extent=self.extent)

        # Add the place names
        if self.place_names is not False:
            if isinstance(self.place_names, str):
                self.place_names = pd.read_csv(self.place_names, comment='#')

            color = (0.0, 0.3, 0.3)
            for index, row in self.place_names.iterrows():
                ax.annotate(row['name'], xy=(row['x'], row['y']), size=4, color=color, horizontalalignment='center',
                            verticalalignment='center')

        # Define the Schiphol terrain border
        if self.schiphol_border is not False:
            if isinstance(self.schiphol_border, str):
                self.schiphol_border = GeoDataFrame.from_file(self.schiphol_border)

            fc = 'none'
            ec = (.0, .0, .0)
            poly = self.schiphol_border['geometry'][0]
            patch = PolygonPatch(poly, fc=fc, ec=ec, lw=0.2, zorder=10)
            ax.add_patch(patch)

            im = ax.imshow(self.background, clip_path=patch, clip_on=True, zorder=9, extent=self.extent)
            im.set_clip_path(patch)

        # Scale, with xpos and ypos as position in fig-units
        xpos = .95
        ypos = 0.04
        ticks = [0, 2, 5, 10]

        # Transform from data to fig
        l_data = ticks[-1] * 1000
        l_disp = ax.transData.transform((l_data, 0)) - ax.transData.transform((0, 0))
        inv_fig = fig.transFigure.inverted()
        l_fig = inv_fig.transform(l_disp)[0]

        ax2 = fig.add_axes([xpos - l_fig, ypos, l_fig, 0.01])

        # Transparent background
        ax2.patch.set_alpha(0)

        # Disable spines
        for loc in ['right', 'left', 'top']:
            ax2.spines[loc].set_color('none')

        # Remove Y-as
        ax2.yaxis.set_ticks([])

        # Add X-ticks
        ax2.xaxis.set_ticks(ticks)
        labels = ['{}'.format(tick) for tick in ticks]
        labels[-1] = '{} km'.format(ticks[-1])
        ax2.set_xticklabels(labels)

        # Format
        color = (0.0, 0.3, 0.3)
        ax2.spines['bottom'].set_color(color)
        ax2.spines['bottom'].set_linewidth(0.5)
        ax2.tick_params(axis='x', labelsize=6, colors=color, length=4, direction='in', width=0.5)

        return fig, ax

    def add_contours(self, level, primary_color=None, secondary_color=None):
        self.select()

        # If the grid is a multigrid, all noise levels should be plotted.
        if isinstance(self.grid.data, list):

            # Process all individual contours
            for year in self.grid.years:
                grid = self.grid.grid_from_year(year).refine(20)

                x = grid.shape.get_x_coordinates()
                y = grid.shape.get_y_coordinates()
                z = grid.data

                cs = self.ax.contour(x, y, z, levels=[level], colors=secondary_color, linewidths=[3, 3], alpha=0.1)

            X1, Y1, Z1 = ld.verfijn(hdr, dat['mean'], k=20)
            X2, Y2, Z2 = ld.verfijn(hdr, dat['dhi'], k=20)
            X3, Y3, Z3 = ld.verfijn(hdr, dat['dlo'], k=20)
            #
            cs1 = ax.contour(X1, Y1, Z1, levels=[level], colors=primary_color, linewidths=[1, 1])
            cs2 = ax.contour(X2, Y2, Z2, levels=[level], colors=secondary_color, linewidths=[0.5, 0.5])
            cs3 = ax.contour(X3, Y3, Z3, levels=[level], colors=secondary_color, linewidths=[0.5, 0.5])

        # The input is a single grid, so only a single contour should be plotted
        else:
            grid = self.grid.copy().refine(20)

            x1 = grid.shape.get_x_coordinates()
            y1 = grid.shape.get_y_coordinates()
            z1 = grid.data

            cs = self.ax.contour(x1, y1, z1, levels=[level], colors=primary_color, linewidths=[1, 1])

        return cs

    def select(self):
        plt.figure(self.id)

    def compare(self, grid):
        self.other = grid

    def save(self, *args, **kwargs):
        return self.fig.savefig(*args, **kwargs)

    def show(self):
        return self.fig.show()
