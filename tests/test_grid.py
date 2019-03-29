import os
import re

import numpy as np
from nose.tools import raises

from gptools.grid import Grid, read_envira, meteotoeslag_years


def test_read_envira():
    # Get the path to the Envira file
    file_path = abs_path('data/GP2018 - Lnight y2016.dat')

    # Create a grid object from the data file
    grid = Grid.read_envira(file_path)

    assert grid.data.shape == (grid.info['ny'], grid.info['nx'])


@raises(ValueError)
def test_read_envira_header_incorrect():
    # Get the path to the Envira file
    file_path = abs_path('data/GP2018 - Lnight y2016e.dat')

    # Create a grid object from the data file
    grid = Grid.read_envira(file_path)


def test_read_envira_other_shape():
    # Get the path to the Envira file
    file_path = abs_path('data/GP2018 - Lnight y2016h.dat')

    # Create a grid object from the data file
    grid = Grid.read_envira(file_path)

    assert grid.data.shape == (grid.info['ny'], grid.info['nx'])


@raises(ValueError)
def test_read_envira_row_missing():
    # Get the path to the Envira file
    file_path = abs_path('data/GP2018 - Lnight y2016r.dat')

    # Create a grid object from the data file
    grid = Grid.read_envira(file_path)


def test_read_enviras():
    # Get the path to the Envira files
    file_paths = abs_path('data/')

    # Set the pattern
    pattern = r'GP2018 - Lnight y201[67].dat'

    # Create a grid object from the data file
    grid = Grid.read_enviras(file_paths, pattern)

    # Check if the data is stored correctly
    assert isinstance(grid.data, list) and len(grid.data) == 2
    assert isinstance(grid.info, list) and len(grid.data) == 2


def test_read_enviras_inconsistent_info():
    # Get the path to the Envira files
    file_paths = abs_path('data/')

    # Set the pattern
    pattern = r'GP2018 - Lnight y2016h?.dat'

    try:
        # Create a grid object from the data file
        grid = Grid.read_enviras(file_paths, pattern)

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
        grid = Grid.read_enviras(file_paths, pattern)

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
        grid = Grid(data=cls_data, info=[cls_info[0]], unit='Lnight')

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
        grid = Grid(data=cls_data, info=cls_info[0], unit='Lnight')

        # If the test reaches this point, the method is not working properly
        assert False
    except TypeError:

        # Check if the file names are correct
        assert file_names == ['GP2018 - Lnight y2016.dat', 'GP2018 - Lnight y2017.dat']


def test_to_envira():
    # Get the path from the original Envira file
    original_file_path = abs_path('data/GP2018 - Lnight y2016.dat')

    # Create a grid object from the data file
    grid = Grid.read_envira(original_file_path)

    # Set the path to the new Envira file
    new_file_path = abs_path('data/envira-test.dat')

    # Export the grid to the new file
    grid.to_envira(new_file_path)

    # Create a grid object from the new data file
    grid_new = Grid.read_envira(new_file_path)

    # Test if the headers of the files are the same
    assert grid_new.info == grid.info

    # Check if the data is still correct
    np.testing.assert_equal(grid_new.data, grid.data)


def test_meteotoeslag_years_empirisch_lden():
    # Determine the years to include for empirical Lden
    actual = meteotoeslag_years('empirisch', 'Lden')

    # Set the desired output
    desired = np.array([1971, 1973, 1974, 1975, 1977, 1978, 1979, 1980, 1982, 1983, 1984, 1985, 1986, 1987, 1988, 1989,
                        1991, 1992, 1993, 1995, 1997, 1998, 1999, 2001, 2002, 2004, 2005, 2006, 2007, 2008, 2009, 2010])

    # Check if the data is stored correctly
    np.testing.assert_equal(actual, desired)


def test_meteotoeslag_years_empirisch_lnight():
    # Determine the years to include for empirical Lnight
    actual = meteotoeslag_years('empirisch', 'Lnight')

    # Set the desired output
    desired = np.array([1971, 1972, 1974, 1975, 1976, 1977, 1978, 1980, 1981, 1982, 1983, 1984, 1986, 1987, 1988, 1990,
                        1991, 1992, 1993, 1997, 1998, 1999, 2000, 2001, 2003, 2004, 2005, 2006, 2007, 2008, 2009, 2010])

    # Check if the data is stored correctly
    np.testing.assert_equal(actual, desired)


def test_meteotoeslag_years_hybride_lden():
    # Determine the years to include for hybrid Lden
    actual = meteotoeslag_years('hybride', 'Lden')

    # Set the desired output
    desired = np.array([1971, 1972, 1973, 1974, 1975, 1976, 1977, 1978, 1979, 1980, 1982, 1983, 1985, 1986, 1987, 1988,
                        1989, 1990, 1991, 1992, 1995, 1997, 1998, 1999, 2001, 2003, 2004, 2005, 2006, 2007, 2008, 2009])

    # Check if the data is stored correctly
    np.testing.assert_equal(actual, desired)


def test_meteotoeslag_years_hybride_lnight():
    # Determine the years to include for hybrid Lnight
    actual = meteotoeslag_years('hybride', 'Lnight')

    # Set the desired output
    desired = np.array([1971, 1972, 1974, 1975, 1977, 1978, 1979, 1981, 1982, 1983, 1984, 1985, 1986, 1988, 1989, 1990,
                        1991, 1992, 1993, 1997, 1998, 1999, 2000, 2001, 2002, 2003, 2004, 2005, 2006, 2007, 2008, 2009])

    # Check if the data is stored correctly
    np.testing.assert_equal(actual, desired)


@raises(KeyError)
def test_meteotoeslag_years_empirical_lnight():
    # Determine the years to include for empirical Lnight
    actual = meteotoeslag_years('empirical', 'Lnight')


@raises(KeyError)
def test_meteotoeslag_years_hybrid_lnight():
    # Determine the years to include for hybrid Lnight
    actual = meteotoeslag_years('hybrid', 'Lnight')


@raises(KeyError)
def test_meteotoeslag_years_hybride_lnight_lowercase():
    # Determine the years to include for hybrid lnight
    actual = meteotoeslag_years('hybride', 'lnight')


@raises(KeyError)
def test_meteotoeslag_years_hybride_lnight_uppercase():
    # Determine the years to include for hybrid LNIGHT
    actual = meteotoeslag_years('hybride', 'LNIGHT')


def test_meteotoeslag_from_method():
    # Get the path to the Envira files
    file_paths = abs_path('data/MINIMER2015')

    # Set the pattern
    pattern = r'[\w\d\s]+\.dat'

    # Create a grid object from the data file
    grid = Grid.read_enviras(file_paths, pattern)

    # Check if the data is stored correctly
    assert False


def test_meteotoeslag_from_years():
    # Get the path to the Envira files
    file_paths = abs_path('data/MINIMER2015')

    # Set the pattern
    pattern = r'[\w\d\s]+\.dat'

    # Create a grid object from the data file
    grid = Grid.read_enviras(file_paths, pattern)

    # Check if the data is stored correctly
    assert False


def abs_path(rel_path):
    return os.path.join(os.path.dirname(__file__), rel_path)
