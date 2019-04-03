from gptools.figures import GridPlot
from gptools.grid import Grid

if __name__ == "__main__":
    # Collect a Grid
    grid = Grid.read_envira('../tests/data/MER2015 - Doc29 - Lden y1974.dat')

    # Create a figure
    grid_plot = GridPlot(grid,
                         background='../lib/Schiphol_RD900dpi.png',
                         place_names='../lib/plaatsnamen.csv',
                         schiphol_border='../lib/2013-spl-luchtvaartterrein.shp')

    # Add the 58dB contour
    grid_plot.add_contours(58)

    # Add the 48dB contour
    grid_plot.add_contours(48)

    # Or save the figure
    grid_plot.save('figures/plot_grid.png')

    # Show the plot
    grid_plot.show()
