import os
import numpy as np
import pandas as pd
from nose.tools import raises

from ssdtools.grid import Grid
from ssdtools.wbs import WBS


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


def test_gwc():
    # Get the validation data
    matlab_df = pd.read_csv(abs_path('data/gwcvalues.csv'), index_col=[0])

    # Get the path to the WBS file
    file_path = abs_path('../../20180907 Berekeningen - TC/doc29py/wbs2018.h5')

    # Create a wbs object from the data file
    wbs = WBS.read_file(file_path)

    # Get the path to the Envira files
    file_paths = abs_path('data/GP2018')

    # Create a dict for the grids
    grids = {}

    # Create a dict for the meteotoeslag grids
    meteotoeslag = {}

    for unit in ['Lden', 'Lnight']:
        # Set the pattern
        pattern = r'[\w\d\s]+{}[\w\d\s]+\.dat'.format(unit)

        # Create a grid object from the data file
        grids[unit] = Grid.read_enviras(file_paths, pattern)

        # Calculate the meteotoeslag
        meteotoeslag[unit] = grids[unit].meteotoeslag_grid_from_method('hybride')

    # Scale the Lden grid
    grids['Lden'].scale(1.025)

    # Calculate the gelijkwaardigheidscriteria (GWC)
    gwc = wbs.gwc(grids['Lden'], grids['Lnight'])

    # Calculate the gelijkwaardigheidscriteria (GWC)
    meteo_gwc = wbs.gwc(lden_grid=meteotoeslag['Lden'], lnight_grid=meteotoeslag['Lnight'])

    np.testing.assert_allclose(gwc['w58den'], matlab_df['w58den'], rtol=0, atol=50)
    np.testing.assert_allclose(gwc['eh48den'], matlab_df['eh48den'], rtol=0, atol=250)
    np.testing.assert_allclose(gwc['w48n'], matlab_df['w48n'], rtol=0, atol=50)
    np.testing.assert_allclose(gwc['sv40n'], matlab_df['sv40n'], rtol=0, atol=250)

    assert gwc.shape == (40, 4)

    assert meteo_gwc.shape == (4,)


def abs_path(rel_path):
    return os.path.join(os.path.dirname(__file__), rel_path)
