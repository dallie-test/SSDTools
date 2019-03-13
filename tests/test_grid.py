import os

from gptools.grid import Grid


def test_read_envira():
    # Get the path to the Envira file
    file_path = abs_path('data/GP2018 - Lnight y2016.dat')

    # Create a grid object from the data file
    grid = Grid.from_envira_file(file_path)

    pass


def test_read_enviras():
    # Get the path to the Envira files
    file_paths = abs_path('data/*.dat')

    # Create a grid object from the data file
    grid = Grid.from_envira_files(file_paths)

    pass


def test_to_envira():
    # Get the path from the original Envira file
    original_file_path = abs_path('data/GP2018 - Lnight y2016.dat')

    # Create a grid object from the data file
    grid = Grid.from_envira_file(original_file_path)

    # Set the path to the new Envira file
    new_file_path = abs_path('data/envira-test.dat')

    # Export the grid to the new file
    grid.to_envira(new_file_path)

    pass


def abs_path(rel_path):
    return os.path.join(os.path.dirname(__file__), rel_path)
