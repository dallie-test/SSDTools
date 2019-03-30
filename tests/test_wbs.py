import os
import numpy as np
from nose.tools import raises

from gptools.grid import Grid
from gptools.wbs import WBS


def test_wbs_read_file():
    # Get the path to the WBS file
    file_path = abs_path('data/wbs2005.h5')

    # Create a wbs object from the data file
    WBS.read_file(file_path)


def test_add_noise_from_grid():
    # Get the path to the WBS file
    file_path = abs_path('data/wbs2005.h5')

    # Create a wbs object from the data file
    wbs = WBS.read_file(file_path)

    # Get the path to the Envira file
    file_path = abs_path('data/MER2015 - Doc29 - Lden y1974.dat')

    # Create a grid object from the data file
    grid = Grid.read_envira(file_path)

    # Add the interpolated Lden values from the grid
    wbs.add_noise_from_grid(grid)


def test_add_noise_from_grid_lden_lnight():
    # Get the path to the WBS file
    file_path = abs_path('data/wbs2005.h5')

    # Create a wbs object from the data file
    wbs = WBS.read_file(file_path)

    # Get the path to the Lden Envira file
    file_path = abs_path('data/MER2015 - Doc29 - Lden y1974.dat')

    # Create a grid object from the data file
    grid = Grid.read_envira(file_path)

    # Add the interpolated Lden values from the grid
    wbs.add_noise_from_grid(grid)

    # Get the path to the Lnight Envira file
    file_path = abs_path('data/GP2018 - Lnight y2016.dat')

    # Create a grid object from the data file
    grid = Grid.read_envira(file_path)

    # Add the interpolated Lnight values from the grid
    wbs.add_noise_from_grid(grid)


def test_select_above():
    # Get the path to the WBS file
    file_path = abs_path('data/wbs2005.h5')

    # Create a wbs object from the data file
    wbs = WBS.read_file(file_path)

    # Get the path to the Envira file
    file_path = abs_path('data/MER2015 - Doc29 - Lden y1974.dat')

    # Create a grid object from the data file
    grid = Grid.read_envira(file_path)

    # Add the interpolated Lden values from the grid
    wbs.add_noise_from_grid(grid)

    # Select the Lden values above 40
    s = wbs.select_above(40, 'Lden').values

    assert isinstance(s, np.ndarray)


@raises(KeyError)
def test_select_above_wrong_unit():
    # Get the path to the WBS file
    file_path = abs_path('data/wbs2005.h5')

    # Create a wbs object from the data file
    wbs = WBS.read_file(file_path)

    # Get the path to the Envira file
    file_path = abs_path('data/MER2015 - Doc29 - Lden y1974.dat')

    # Create a grid object from the data file
    grid = Grid.read_envira(file_path)

    # Add the interpolated Lden values from the grid
    wbs.add_noise_from_grid(grid)

    # Select the Lnight values above 48
    wbs.select_above('Lnight', 40)


def test_count_above():
    # Get the path to the WBS file
    file_path = abs_path('data/wbs2005.h5')

    # Create a wbs object from the data file
    wbs = WBS.read_file(file_path)

    # Get the path to the Envira file
    file_path = abs_path('data/MER2015 - Doc29 - Lden y1974.dat')

    # Create a grid object from the data file
    grid = Grid.read_envira(file_path)

    # Add the interpolated Lden values from the grid
    wbs.add_noise_from_grid(grid)

    # Select the Lden values above 40
    s = wbs.count_above(40, 'Lden')

    assert isinstance(s, np.int64)


def test_count_homes_above():
    # Get the path to the WBS file
    file_path = abs_path('data/wbs2005.h5')

    # Create a wbs object from the data file
    wbs = WBS.read_file(file_path)

    # Get the path to the Envira file
    file_path = abs_path('data/MER2015 - Doc29 - Lden y1974.dat')

    # Create a grid object from the data file
    grid = Grid.read_envira(file_path)

    # Add the interpolated Lden values from the grid
    wbs.add_noise_from_grid(grid)

    # Count the homes with Lden values above 40
    s = wbs.count_homes_above(40, 'Lden')

    assert isinstance(s, float)


def test_count_annoyed_people():
    # Get the path to the WBS file
    file_path = abs_path('data/wbs2005.h5')

    # Create a wbs object from the data file
    wbs = WBS.read_file(file_path)

    # Get the path to the Envira file
    file_path = abs_path('data/MER2015 - Doc29 - Lden y1974.dat')

    # Create a grid object from the data file
    grid = Grid.read_envira(file_path)

    # Add the interpolated Lden values from the grid
    wbs.add_noise_from_grid(grid)

    # Count the annoyed people
    s = wbs.count_annoyed_people()

    assert isinstance(s, float)


def test_count_sleep_disturbed_people():
    # Get the path to the WBS file
    file_path = abs_path('data/wbs2005.h5')

    # Create a wbs object from the data file
    wbs = WBS.read_file(file_path)

    # Get the path to the Envira file
    file_path = abs_path('data/GP2018 - Lnight y2016.dat')

    # Create a grid object from the data file
    grid = Grid.read_envira(file_path)

    # Add the interpolated Lnight values from the grid
    wbs.add_noise_from_grid(grid)

    # Count the sleep disturbed people
    s = wbs.count_sleep_disturbed_people()

    assert isinstance(s, float)


def abs_path(rel_path):
    return os.path.join(os.path.dirname(__file__), rel_path)
