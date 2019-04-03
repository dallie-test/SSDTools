from gptools.branding import default
from gptools.figures import GridPlot
from gptools.grid import Grid


def example_1():
    # Collect a Grid
    grid = Grid.read_envira('../tests/data/MER2015 - Doc29 - Lden y1974.dat')

    # Create a figure
    plot = GridPlot(grid,
                    background='../lib/Schiphol_RD900dpi.png',
                    place_names='../lib/plaatsnamen.csv',
                    schiphol_border='../lib/2013-spl-luchtvaartterrein.shp')

    # Add the 58dB contour
    plot.add_contours(58, default['kleuren']['schemergroen'], default['kleuren']['wolkengrijs_1'])

    # Add the 48dB contour
    plot.add_contours(48, default['kleuren']['schipholblauw'], default['kleuren']['middagblauw'])

    # Or save the figure
    plot.save('figures/plot_grid_example_1.png')

    # Show the plot
    plot.show()


def example_2():
    # Collect a Grid
    grid = Grid.read_enviras('../tests/data/MER2019 H_500_doc29_VVR', r'[\w\d\s]+{}[\w\d\s]+\.dat'.format('Lden'))

    # Create a figure
    plot = GridPlot(grid, background='../lib/Schiphol_RD900dpi.png', place_names=False, schiphol_border=False)

    # Add the 58dB contour
    plot.add_contours(48, default['kleuren']['schipholblauw'], default['kleuren']['middagblauw'])

    # Or save the figure
    plot.save('figures/plot_grid_example_2.png')

    # Show the plot
    plot.show()


if __name__ == "__main__":
    example_1()
    example_2()
