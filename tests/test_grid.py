import os
import re

import numpy as np
from gptools.grid import Grid, read_envira


def test_read_envira():
    # Get the path to the Envira file
    file_path = abs_path('data/GP2018 - Lnight y2016.dat')

    # Create a grid object from the data file
    grid = Grid.from_envira_file(file_path)

    pass


def test_read_enviras_inconsistent_info():
    # Get the path to the Envira files
    file_paths = abs_path('data/')

    # Set the pattern
    pattern = r'GP2018 - Lnight y2016h?.dat'

    try:
        # Create a grid object from the data file
        grid = Grid.from_envira_files(file_paths, pattern)

        # If the test reaches this point, the method is not working properly
        assert False
    except ValueError:

        # Get the envira files
        file_paths = [f for f in os.listdir(file_paths) if re.search(pattern, f)]

        # Check if the file names are correct
        assert file_paths == ['GP2018 - Lnight y2016.dat', 'GP2018 - Lnight y2016h.dat']


def test_read_enviras_inconsistent_data():
    # Get the path to the Envira files
    file_paths = abs_path('data/')

    # Set the pattern
    pattern = r'GP2018 - Lnight y2016r?.dat'

    try:
        # Create a grid object from the data file
        grid = Grid.from_envira_files(file_paths, pattern)

        # If the test reaches this point, the method is not working properly
        assert False
    except ValueError:

        # Get the envira files
        file_paths = [f for f in os.listdir(file_paths) if re.search(pattern, f)]

        # Check if the file names are correct
        assert file_paths == ['GP2018 - Lnight y2016.dat', 'GP2018 - Lnight y2016r.dat']


def test_read_enviras_inconsistent_input():
    # Get the path to the Envira files
    file_paths = abs_path('data/')

    # Set the pattern
    pattern = r'GP2018 - Lnight y201[67].dat'

    # Get the envira files
    file_names = [f for f in os.listdir(file_paths) if re.search(pattern, f)]

    # Create info and data lists
    cls_info = []
    cls_data = []

    # Read the envira files
    for file_name in file_names:
        info, data = read_envira(os.path.join(file_paths, file_name))
        cls_info.append(info)
        cls_data.append(data)

    try:
        # Add the data to a Grid object
        grid = Grid(data=cls_data, info=[cls_info[0]])

        # If the test reaches this point, the method is not working properly
        assert False
    except IndexError:

        # Check if the file names are correct
        assert file_names == ['GP2018 - Lnight y2016.dat', 'GP2018 - Lnight y2017.dat']


def test_read_enviras_inconsistent_list_size():
    # Get the path to the Envira files
    file_paths = abs_path('data/')

    # Set the pattern
    pattern = r'GP2018 - Lnight y201[67].dat'

    # Get the envira files
    file_names = [f for f in os.listdir(file_paths) if re.search(pattern, f)]

    # Create info and data lists
    cls_info = []
    cls_data = []

    # Read the envira files
    for file_name in file_names:
        info, data = read_envira(os.path.join(file_paths, file_name))
        cls_info.append(info)
        cls_data.append(data)

    try:
        # Add the data to a Grid object
        grid = Grid(data=cls_data, info=cls_info[0])

        # If the test reaches this point, the method is not working properly
        assert False
    except TypeError:

        # Check if the file names are correct
        assert file_names == ['GP2018 - Lnight y2016.dat', 'GP2018 - Lnight y2017.dat']


def test_read_consistent_enviras():
    # Get the path to the Envira files
    file_paths = abs_path('data/')

    # Set the pattern
    pattern = r'GP2018 - Lnight y201[67].dat'

    # Create a grid object from the data file
    grid = Grid.from_envira_files(file_paths, pattern)

    # Check if the data is stored correctly
    assert isinstance(grid.data, list) and len(grid.data) == 2
    assert isinstance(grid.info, list) and len(grid.data) == 2


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
