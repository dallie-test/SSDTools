from ssdtools.branding import default
from ssdtools.figures import GridPlot
from ssdtools.grid import Grid


def example_1():
    # Collect a Grid
    grid = Grid.read_envira('../tests/data/MER2015 - Doc29 - Lden y1974.dat')

    # Create a figure
    plot = GridPlot(grid)

    # Add the background
    plot.add_background('../lib/Schiphol_RD900dpi.png')

    # Add a scale
    plot.add_scale()

    # Add the terrain
    plot.add_terrain('../lib/2013-spl-luchtvaartterrein.shp')

    # Add the place names
    plot.add_place_names('../lib/plaatsnamen.csv')

    # Add the 58dB contour
    plot.add_contours(58, default['kleuren']['schemergroen'], default['kleuren']['wolkengrijs_1'])

    # Add the 48dB contour
    plot.add_contours(48, default['kleuren']['schipholblauw'], default['kleuren']['middagblauw'])

    # Save the figure
    plot.save('figures/plot_grid_example_1.pdf')

    # And show the plot
    plot.show()


def example_2():
    # Collect a Grid
    grid = Grid.read_enviras('../tests/data/MER2019 H_500_doc29_VVR', r'[\w\d\s]+{}[\w\d\s]+\.dat'.format('Lden'))

    # Create a figure
    plot = GridPlot(grid)

    # Add the 58dB contour
    plot.add_contours(48, default['kleuren']['schipholblauw'], default['kleuren']['middagblauw'])

    # Save the figure
    plot.save('figures/plot_grid_example_2.pdf')

    # And show the plot
    plot.show()


def example_3():
    # Collect a Grid
    grid = Grid.read_envira('../tests/data/MER2015 - Doc29 - Lden y1974.dat')

    # Create a figure
    plot = GridPlot(grid)

    # Add the background
    plot.add_background('../lib/Schiphol_RD900dpi.png')

    # Add a scale
    plot.add_scale()

    # Add the heatmap
    plot.add_heatmap(vmin=46, vmax=70)

    # Add a colorbar
    plot.add_colorbar()

    # Save the figure
    plot.save('figures/plot_grid_example_3.pdf')

    # And show the plot
    plot.show()


def example_4():
    # Collect a Grid
    grid_1 = Grid.read_envira('../tests/data/MER2019 H_500_doc29_VVR/MER2018 - Doc29 - Lden y1974.dat')

    # Collect a Grid to compare
    grid_2 = Grid.read_envira('../tests/data/H_500_00_doc29/MER2015 - Doc29 - Lden y1974.dat')

    # Create a figure
    plot = GridPlot(grid_1)

    # Add the background
    plot.add_background('../lib/Schiphol_RD900dpi.png')

    # Add a scale
    plot.add_scale()

    # Add the comparison heatmap
    plot.add_comparison_heatmap(grid_2, vmin=-3, vmax=3)

    # Add a colorbar
    plot.add_colorbar()

    # Save the figure
    plot.save('figures/plot_grid_example_4.pdf')

    # And show the plot
    plot.show()


if __name__ == "__main__":
    example_1()
    example_2()
    example_3()
    example_4()
