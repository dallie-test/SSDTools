import os
import re

import numpy as np
from nose.tools import raises
from scipy.interpolate import RectBivariateSpline

from ssdtools.grid import Grid, read_envira, meteotoeslag_years, extract_year_from_file_name


def test_read_envira():
    # Get the path to the Envira file
    file_path = abs_path('data/GP2018 - Lnight y2016.dat')

    # Create a grid object from the data file
    grid = Grid.read_envira(file_path)

    assert grid.data.shape == (grid.info['y_number'], grid.info['x_number'])


@raises(ValueError)
def test_read_envira_header_incorrect():
    # Get the path to the Envira file
    file_path = abs_path('data/GP2018 - Lnight y2016e.dat')

    # Create a grid object from the data file
    Grid.read_envira(file_path)


def test_read_envira_other_shape():
    # Get the path to the Envira file
    file_path = abs_path('data/GP2018 - Lnight y2016h.dat')

    # Create a grid object from the data file
    grid = Grid.read_envira(file_path)

    assert grid.data.shape == (grid.info['y_number'], grid.info['x_number'])


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


def test_to_shapefile():
    # Get the path to the Envira file
    file_path = abs_path('data/GP2018 - Lnight y2016.dat')

    # Create a grid object from the data file
    grid = Grid.read_envira(file_path)

    # Refine the grid and export as shapefile
    grid.refine(20).to_shapefile(abs_path('data/GP2018 - Lnight y2016.shp'), 48)


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
    meteotoeslag_years('empirical', 'Lnight')


@raises(KeyError)
def test_meteotoeslag_years_hybrid_lnight():
    # Determine the years to include for hybrid Lnight
    meteotoeslag_years('hybrid', 'Lnight')


@raises(KeyError)
def test_meteotoeslag_years_hybride_lnight_lowercase():
    # Determine the years to include for hybrid lnight
    meteotoeslag_years('hybride', 'lnight')


@raises(KeyError)
def test_meteotoeslag_years_hybride_lnight_uppercase():
    # Determine the years to include for hybrid LNIGHT
    meteotoeslag_years('hybride', 'LNIGHT')


def test_meteotoeslag_from_method():
    # Get the path to the Envira files
    file_paths = abs_path('data/MINIMER2015')

    # Set the pattern
    pattern = r'[\w\d\s]+\.dat'

    # Create a grid object from the data file
    grid = Grid.read_enviras(file_paths, pattern)

    # Calculate the meteotoeslag
    meteotoeslag, meteo_years = grid.meteotoeslag_from_method('hybride')

    # Check if the data is processed correctly
    assert meteo_years.shape == (32,)
    assert grid.data[0].shape == meteotoeslag.shape
    assert np.all(grid.data[0] <= meteotoeslag)


@raises(LookupError)
def test_meteotoeslag_from_years():
    # Get the path to the Envira files
    file_paths = abs_path('data/MINIMER2015')

    # Set the pattern
    pattern = r'[\w\d\s]+\.dat'

    # Create a grid object from the data file
    grid = Grid.read_enviras(file_paths, pattern)

    # Calculate the meteotoeslag
    grid.meteotoeslag_from_years([1981, 1984, 1993, 1994, 1996, 2000, 2002, 2010])


@raises(LookupError)
def test_meteotoeslag_from_years_nonexistent():
    # Get the path to the Envira files
    file_paths = abs_path('data/MINIMER2015')

    # Set the pattern
    pattern = r'[\w\d\s]+\.dat'

    # Create a grid object from the data file
    grid = Grid.read_enviras(file_paths, pattern)

    # Calculate the meteotoeslag
    grid.meteotoeslag_from_years(np.ones((32,), dtype=int))


@raises(LookupError)
def test_meteotoeslag_from_years_doubles():
    # Get the path to the Envira files
    file_paths = abs_path('data/MINIMER2015')

    # Set the pattern
    pattern = r'[\w\d\s]+\.dat'

    # Create a grid object from the data file
    grid = Grid.read_enviras(file_paths, pattern)

    # Calculate the meteotoeslag
    grid.meteotoeslag_from_years(np.ones((32,), dtype=int) * 1981)


def test_hg():
    # Get the path to the Envira file
    file_path = abs_path('data/GP2018 - Lnight y2016.dat')

    # Create a grid object from the data file
    grid = Grid.read_envira(file_path)

    # Calculate the Hoeveelheid Geluid
    hg = grid.hg()

    assert isinstance(hg, float)


@raises(TypeError)
def test_hg_multigrid():
    # Get the path to the Envira files
    file_paths = abs_path('data/MINIMER2015')

    # Set the pattern
    pattern = r'[\w\d\s]+\.dat'

    # Create a grid object from the data file
    grid = Grid.read_enviras(file_paths, pattern)

    # Calculate the Hoeveelheid Geluid
    grid.hg()


def test_scale():
    # Get the path to the Envira file
    file_path = abs_path('data/GP2018 - Lnight y2016.dat')

    # Create a grid object from the data file
    grid = Grid.read_envira(file_path)

    # Copy the data
    d = grid.data.copy()

    # Calculate the meteotoeslag
    grid.scale(2.)

    np.testing.assert_equal(grid.data, d + 10 * np.log10(2))


def test_scale_multigrid():
    # Get the path to the Envira files
    file_paths = abs_path('data/MINIMER2015')

    # Set the pattern
    pattern = r'[\w\d\s]+\.dat'

    # Create a grid object from the data file
    grid = Grid.read_enviras(file_paths, pattern)

    # Calculate the meteotoeslag
    meteotoeslag, meteo_years = grid.meteotoeslag_from_method('hybride')

    # Calculate the meteotoeslag
    grid.scale(2.)

    # Calculate the meteotoeslag
    scaled_meteotoeslag, scaled_meteo_years = grid.meteotoeslag_from_method('hybride')

    assert np.all(meteo_years == scaled_meteo_years)
    np.testing.assert_equal(scaled_meteotoeslag, meteotoeslag + 10 * np.log10(2))


def test_scale_multigrid_int():
    # Get the path to the Envira files
    file_paths = abs_path('data/MINIMER2015')

    # Set the pattern
    pattern = r'[\w\d\s]+\.dat'

    # Create a grid object from the data file
    grid = Grid.read_enviras(file_paths, pattern)

    # Calculate the meteotoeslag
    meteotoeslag, meteo_years = grid.meteotoeslag_from_method('hybride')

    # Calculate the meteotoeslag
    grid.scale(2)

    # Calculate the meteotoeslag
    grid.scale(2.)

    # Calculate the meteotoeslag
    scaled_meteotoeslag, scaled_meteo_years = grid.meteotoeslag_from_method('hybride')

    assert np.all(meteo_years == scaled_meteo_years)
    np.testing.assert_equal(scaled_meteotoeslag, meteotoeslag + 10 * np.log10(4))


def test_statistics_multigrid():
    # Get the path to the Envira files
    file_paths = abs_path('data/MINIMER2015')

    # Set the pattern
    pattern = r'[\w\d\s]+\.dat'

    # Create a grid object from the data file
    grid = Grid.read_enviras(file_paths, pattern)
    stats = Grid.statistics(grid)

    assert isinstance(stats, dict)


@raises(TypeError)
def test_statistics_type():
    # Get the path to the Envira files
    file_paths = abs_path('data/MINIMER2015')

    # Set the pattern
    pattern = r'[\w\d\s]+\.dat'

    # Create a grid object from the data file
    grid = Grid.read_enviras(file_paths, pattern)

    # Modify the data
    grid.data = float(20)

    # Check if the statistics can be calculated
    Grid.statistics(grid)


@raises(TypeError)
def test_statistics_nan():
    # Get the path to the Envira files
    file_paths = abs_path('data/MINIMER2015')

    # Set the pattern
    pattern = r'[\w\d\s]+\.dat'

    # Create a grid object from the data file
    grid = Grid.read_enviras(file_paths, pattern)

    # Modify the data
    grid.data = np.nan

    # Check if the statistics can be calculated
    Grid.statistics(grid)


def test_interpolation_function_nominal():
    # Get the path to the Envira file
    file_path = abs_path('data/GP2018 - Lnight y2016.dat')

    # Create a grid object from the data file
    grid = Grid.read_envira(file_path)
    interpolation = grid.interpolation_function()

    assert isinstance(interpolation, RectBivariateSpline)


@raises(TypeError)
def test_interpolation_function_multigrid():
    # Get the path to the Envira file
    file_path = abs_path('data/GP2018 - Lnight y2016.dat')

    # Create a grid object from the data file
    grid = Grid.read_envira(file_path)
    grid.data = []
    grid.interpolation_function()


@raises(AttributeError)
def test_interpolation_function_nan():
    # Get the path to the Envira file
    file_path = abs_path('data/GP2018 - Lnight y2016.dat')

    # Create a grid object from the data file
    grid = Grid.read_envira(file_path)
    grid.data = np.nan
    grid.interpolation_function()


def test_refine():
    """
    Test various use cases for consistency
    """
    # Get the path to the Envira file
    file_path = abs_path('data/GP2018 - Lnight y2016.dat')

    # Create a grid object from the data file
    grid2 = Grid.read_envira(file_path)

    # Refine the grid with a factor 2
    grid2.refine(2)

    # Check if the shape of the data matches the changed input
    assert grid2.data.shape == (285, 285)
    assert grid2.shape.x_number == 285
    assert grid2.shape.y_number == 285

    # Create a grid object from the data file
    grid05 = Grid.read_envira(file_path)

    # Refine the grid with a factor 0.5
    grid05.refine(0.5)

    # Check if the shape of the data matches the changed input
    assert grid05.data.shape == (72, 72)
    assert grid05.shape.x_number == 72
    assert grid05.shape.y_number == 72

    # Create a grid object from the data file
    grid35 = Grid.read_envira(file_path)

    # Refine the grid with a factor 3.5
    grid35.refine(3.5)

    assert grid35.data.shape == (498, 498)
    assert grid35.shape.x_number == 498
    assert grid35.shape.y_number == 498


@raises(AttributeError)
def test_refine_type():
    # Get the path to the Envira file
    file_path = abs_path('data/GP2018 - Lnight y2016.dat')

    # Create a grid object from the data file
    grid = Grid.read_envira(file_path)

    grid.data = []
    grid.refine(2)


@raises(ValueError)
def test_refine_value():
    # Get the path to the Envira file
    file_path = abs_path('data/GP2018 - Lnight y2016.dat')

    # Create a grid object from the data file
    grid = Grid.read_envira(file_path)
    factor = np.nan
    grid.refine(factor)


def test_resize():
    # Get the path to the Envira file
    file_path = abs_path('data/GP2018 - Lnight y2016.dat')

    # Create a grid object from the data file
    grid = Grid.read_envira(file_path)

    # Create an alternative shape
    shape = grid.shape.copy()

    # Change a few settings
    shape.set_x_number(201)
    shape.set_y_number(79)

    # Resize the grid
    grid.resize(shape)

    # Check if the shape of the data matches the changed input
    assert grid.data.shape == (79, 201)
    assert grid.shape.x_number == 201
    assert grid.shape.y_number == 79
    assert isinstance(grid.info, dict)


def test_scale_per_time_interval():
    # Get the path to the Envira files
    file_paths = abs_path('data/H_500_00_doc29')

    # Create a dict for the meteotoeslag grids
    meteotoeslag = {}

    for unit in ['Lden', 'Lnight']:
        # Set the pattern
        pattern = r'[\w\d\s]+{}[\w\d\s]+\.dat'.format(unit)

        # Create a meteotoeslag grid object from the data file
        meteotoeslag[unit] = Grid.read_enviras(file_paths, pattern).meteotoeslag_grid_from_method('hybride')

    # Scale the Lnight
    meteotoeslag_ln_scaled = meteotoeslag['Lden'].copy().scale_per_time_interval(meteotoeslag['Lnight'], scale_n=1.021)

    # The Lden data should increase due to the increase of Lnight
    assert (meteotoeslag_ln_scaled.data > meteotoeslag['Lden'].data).all()

    # Scale the Lden
    meteotoeslag_lde_scaled = meteotoeslag['Lden'].copy().scale_per_time_interval(meteotoeslag['Lnight'],
                                                                                  scale_de=1.031)

    # The Lden data should increase due to the increase of Lde
    assert (meteotoeslag_lde_scaled.data > meteotoeslag['Lden'].data).all()

    # Scale both Lden and Lnight
    meteotoeslag_lden_scaled = meteotoeslag['Lden'].copy().scale_per_time_interval(meteotoeslag['Lnight'],
                                                                                   scale_n=1.021,
                                                                                   scale_de=1.031)

    # The Lden data should increase due to the scaling factors
    assert (meteotoeslag_lden_scaled.data > meteotoeslag['Lden'].data).all()
    assert (meteotoeslag_lden_scaled.data > meteotoeslag_lde_scaled.data).all()
    assert (meteotoeslag_lden_scaled.data > meteotoeslag_ln_scaled.data).all()


def test_scale_per_time_interval_no_scale():
    # Get the path to the Envira files
    file_paths = abs_path('data/H_500_00_doc29')

    # Create a dict for the meteotoeslag grids
    meteotoeslag = {}

    for unit in ['Lden', 'Lnight']:
        # Set the pattern
        pattern = r'[\w\d\s]+{}[\w\d\s]+\.dat'.format(unit)

        # Create a meteotoeslag grid object from the data file
        meteotoeslag[unit] = Grid.read_enviras(file_paths, pattern).meteotoeslag_grid_from_method('hybride')

    # Scale the meteotoeslag without actually scaling
    meteotoeslag_lden_scaled = meteotoeslag['Lden'].copy().scale_per_time_interval(meteotoeslag['Lnight'])

    # Check if the values are still the same
    np.testing.assert_almost_equal(meteotoeslag['Lden'].data, meteotoeslag_lden_scaled.data, 12)


def test_scale_per_time_interval_decrease():
    # Get the path to the Envira files
    file_paths = abs_path('data/H_500_00_doc29')

    # Create a dict for the meteotoeslag grids
    meteotoeslag = {}

    for unit in ['Lden', 'Lnight']:
        # Set the pattern
        pattern = r'[\w\d\s]+{}[\w\d\s]+\.dat'.format(unit)

        # Create a meteotoeslag grid object from the data file
        meteotoeslag[unit] = Grid.read_enviras(file_paths, pattern).meteotoeslag_grid_from_method('hybride')

    # Scale the meteotoeslag with a scaling factor below 1
    meteotoeslag_lden_scaled = meteotoeslag['Lden'].copy().scale_per_time_interval(meteotoeslag['Lnight'], scale_de=.9)

    # The Lden data should decrease due to the decrease of Lde
    assert (meteotoeslag_lden_scaled.data < meteotoeslag['Lden'].data).all()


@raises(ValueError)
def test_scale_per_time_interval_negative_scale():
    # Get the path to the Envira files
    file_paths = abs_path('data/H_500_00_doc29')

    # Create a dict for the meteotoeslag grids
    meteotoeslag = {}

    for unit in ['Lden', 'Lnight']:
        # Set the pattern
        pattern = r'[\w\d\s]+{}[\w\d\s]+\.dat'.format(unit)

        # Create a meteotoeslag grid object from the data file
        meteotoeslag[unit] = Grid.read_enviras(file_paths, pattern).meteotoeslag_grid_from_method('hybride')

    # Scale the meteotoeslag with a negative scaling factor
    meteotoeslag['Lden'].copy().scale_per_time_interval(meteotoeslag['Lnight'], scale_de=-1)


@raises(ValueError)
def test_scale_per_time_interval_zero_scale():
    # Get the path to the Envira files
    file_paths = abs_path('data/H_500_00_doc29')

    # Create a dict for the meteotoeslag grids
    meteotoeslag = {}

    for unit in ['Lden', 'Lnight']:
        # Set the pattern
        pattern = r'[\w\d\s]+{}[\w\d\s]+\.dat'.format(unit)

        # Create a meteotoeslag grid object from the data file
        meteotoeslag[unit] = Grid.read_enviras(file_paths, pattern).meteotoeslag_grid_from_method('hybride')

    # Scale the meteotoeslag with a zero scaling factor
    meteotoeslag['Lden'].copy().scale_per_time_interval(meteotoeslag['Lnight'], scale_de=0)


@raises(TypeError)
def test_scale_per_time_interval_wrong_den_grid():
    # Get the path to the Envira files
    file_paths = abs_path('data/H_500_00_doc29')

    # Create a dict for the meteotoeslag grids
    meteotoeslag = {}

    for unit in ['Lnight']:
        # Set the pattern
        pattern = r'[\w\d\s]+{}[\w\d\s]+\.dat'.format(unit)

        # Create a meteotoeslag grid object from the data file
        meteotoeslag[unit] = Grid.read_enviras(file_paths, pattern).meteotoeslag_grid_from_method('hybride')

    # Scale the meteotoeslag
    meteotoeslag['Lnight'].copy().scale_per_time_interval(meteotoeslag['Lnight'])


@raises(TypeError)
def test_scale_per_time_interval_wrong_night_grid():
    # Get the path to the Envira files
    file_paths = abs_path('data/H_500_00_doc29')

    # Create a dict for the meteotoeslag grids
    meteotoeslag = {}

    for unit in ['Lden']:
        # Set the pattern
        pattern = r'[\w\d\s]+{}[\w\d\s]+\.dat'.format(unit)

        # Create a meteotoeslag grid object from the data file
        meteotoeslag[unit] = Grid.read_enviras(file_paths, pattern).meteotoeslag_grid_from_method('hybride')

    # Scale the meteotoeslag
    meteotoeslag['Lden'].copy().scale_per_time_interval(meteotoeslag['Lden'])


@raises(ValueError)
def test_scale_per_time_interval_incompatible_grids():
    # Get the path to the Envira files
    file_paths = abs_path('data/H_500_00_doc29')

    # Create a dict for the meteotoeslag grids
    meteotoeslag = {}

    for unit in ['Lden', 'Lnight']:
        # Set the pattern
        pattern = r'[\w\d\s]+{}[\w\d\s]+\.dat'.format(unit)

        # Create a meteotoeslag grid object from the data file
        meteotoeslag[unit] = Grid.read_enviras(file_paths, pattern).meteotoeslag_grid_from_method('hybride')

    # Scale the meteotoeslag without actually scaling
    meteotoeslag['Lden'].copy().scale_per_time_interval(meteotoeslag['Lnight'].refine(.5))


@raises(TypeError)
def test_scale_per_time_interval_lden_multigrid():
    # Get the path to the Envira files
    file_paths = abs_path('data/H_500_00_doc29')

    # Create a dict for the meteotoeslag grids
    grid = {}

    # Create a dict for the meteotoeslag grids
    meteotoeslag = {}

    for unit in ['Lden', 'Lnight']:
        # Set the pattern
        pattern = r'[\w\d\s]+{}[\w\d\s]+\.dat'.format(unit)

        # Create a grid object from the data file
        grid[unit] = Grid.read_enviras(file_paths, pattern)

        # Create a meteotoeslag grid
        meteotoeslag[unit] = grid[unit].meteotoeslag_grid_from_method('hybride')

    # Scale the meteotoeslag without actually scaling
    grid['Lden'].copy().scale_per_time_interval(meteotoeslag['Lnight'])


@raises(TypeError)
def test_scale_per_time_interval_lnight_multigrid():
    # Get the path to the Envira files
    file_paths = abs_path('data/H_500_00_doc29')

    # Create a dict for the meteotoeslag grids
    grid = {}

    # Create a dict for the meteotoeslag grids
    meteotoeslag = {}

    for unit in ['Lden', 'Lnight']:
        # Set the pattern
        pattern = r'[\w\d\s]+{}[\w\d\s]+\.dat'.format(unit)

        # Create a grid object from the data file
        grid[unit] = Grid.read_enviras(file_paths, pattern)

        # Create a meteotoeslag grid
        meteotoeslag[unit] = grid[unit].meteotoeslag_grid_from_method('hybride')

    # Scale the meteotoeslag without actually scaling
    meteotoeslag['Lden'].copy().scale_per_time_interval(grid['Lnight'])


def test_scale_per_time_interval_apply_night_time_correction():
    # Get the path to the Envira files
    file_paths = abs_path('data/H_500_00_doc29')

    # Create a dict for the meteotoeslag grids
    meteotoeslag = {}

    for unit in ['Lden', 'Lnight']:
        # Set the pattern
        pattern = r'[\w\d\s]+{}[\w\d\s]+\.dat'.format(unit)

        # Create a meteotoeslag grid object from the data file
        meteotoeslag[unit] = Grid.read_enviras(file_paths, pattern).meteotoeslag_grid_from_method('hybride')

    # Scale the meteotoeslag 2.1%
    meteotoeslag_lden_scaled_with = meteotoeslag['Lden'].copy().scale_per_time_interval(meteotoeslag['Lnight'],
                                                                                        scale_de=1.021)

    # Scale the meteotoeslag 2.1% without lnight time correction
    meteotoeslag_lden_scaled_without = meteotoeslag['Lden'].copy().scale_per_time_interval(meteotoeslag['Lnight'],
                                                                                           scale_de=1.021,
                                                                                           apply_lnight_time_correction=False)

    # Without lnight time correction, the scaled data Lden should be lower
    assert (meteotoeslag_lden_scaled_with.data > meteotoeslag_lden_scaled_without.data).all()


def test_extract_year_from_file_name_y1234():
    assert 1234 == extract_year_from_file_name('y1234')


def test_extract_year_from_file_name_1234():
    assert extract_year_from_file_name('1234') is None


def test_extract_year_from_file_name_y12345():
    assert 1234 == extract_year_from_file_name('Test for y12345.dat')


@raises(TypeError)
def test_extract_year_from_file_name_int_1234():
    assert 1234 == extract_year_from_file_name(1234)


def abs_path(rel_path):
    return os.path.join(os.path.dirname(__file__), rel_path)
