import os
import numpy as np
from gptools.grid import Grid


def test_read_envira():
    # Get the path to the Envira file
    file_path = abs_path('data/GP2018 - Lnight y2016.dat')

    # Create a grid object from the data file
    grid = Grid.from_envira_file(file_path)

    pass


def test_read_enviras():
    # Get the path to the Envira files
    file_paths = abs_path('data/')

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

    # Create a grid object from the new data file
    grid_new = Grid.from_envira_file(new_file_path)

    # Test if the headers of the files are the same
    assert grid_new.info == grid.info

    # Check if the data is still correct
    np.testing.assert_equal(grid_new.data, grid.data)


def abs_path(rel_path):
    return os.path.join(os.path.dirname(__file__), rel_path)
