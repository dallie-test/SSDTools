from ssdtools.grid import Grid
from ssdtools.wbs import WBS
import pandas as pd
import numpy as np

from tests.test_grid import abs_path


def test_grid_gelijkwaardigheid():
    # Get the path to the Envira files
    file_paths = abs_path('data/H_500_00_doc29')

    # Get the validation data
    matlab_df = pd.read_csv(abs_path('data/gwcvalues.csv'))

    # Create a dict for the grids
    grids = {}

    # Create a dict for the meteotoeslag
    meteotoeslag = {}

    for unit in ['Lden', 'Lnight']:
        # Set the pattern
        pattern = r'[\w\d\s]+{}[\w\d\s]+\.dat'.format(unit)

        # Create a grid object from the data file
        grids[unit] = Grid.read_enviras(file_paths, pattern)

        # Calculate the meteotoeslag
        meteotoeslag[unit] = grids[unit].meteotoeslag_grid_from_method('hybride')

    # Get the path to the WBS file
    wbs_file = abs_path('../../20180907 Berekeningen - TC/doc29py/wbs2018.h5')

    # Create a wbs object from the data file
    wbs = WBS.read_file(wbs_file)

    # Add the meteotoeslag Lden and Lnight noise levels
    wbs.add_noise_from_grid(meteotoeslag['Lden'])
    wbs.add_noise_from_grid(meteotoeslag['Lnight'])

    # Calculate the number of houses with >58dBA Lden and >48dBA Lnight
    w58den = wbs.count_homes_above(58, 'Lden')
    w48n = wbs.count_homes_above(48, 'Lnight')

    # Calculate the number of annoyed and sleep disturbed people
    eh48den = wbs.count_annoyed_people(48)
    sv40n = wbs.count_sleep_disturbed_people(40)

    df = pd.DataFrame({
        'year': ['1971-2016mm'],
        'w58den': [np.round(w58den, 0)],
        'eh48den': [np.round(eh48den, 0)],
        'w48n': [np.round(w48n, 0)],
        'sv40n': [np.round(sv40n, 0)]
    })

    for year in grids['Lden'].years:
        # Add the meteotoeslag Lden and Lnight noise levels
        wbs.add_noise_from_grid(grids['Lden'].grid_from_year(year))
        wbs.add_noise_from_grid(grids['Lnight'].grid_from_year(year))

        # Calculate the number of houses with >58dBA Lden and >48dBA Lnight
        w58den = wbs.count_homes_above(58, 'Lden')
        w48n = wbs.count_homes_above(48, 'Lnight')

        # Calculate the number of annoyed and sleep disturbed people
        eh48den = wbs.count_annoyed_people(48)
        sv40n = wbs.count_sleep_disturbed_people(40)

        df = df.append({
            'year': year,
            'w58den': np.round(w58den, 0),
            'w48n': np.round(w48n, 0),
            'eh48den': np.round(eh48den, 0),
            'sv40n': np.round(sv40n, 0)
        }, ignore_index=True)

    np.testing.assert_array_equal(df['year'], matlab_df['year'])
    np.testing.assert_allclose(df['w58den'], matlab_df['w58den'], rtol=0, atol=50)
    np.testing.assert_allclose(df['eh48den'], matlab_df['eh48den'], rtol=0, atol=250)
    np.testing.assert_allclose(df['w48n'], matlab_df['w48n'], rtol=0, atol=50)
    np.testing.assert_allclose(df['sv40n'], matlab_df['sv40n'], rtol=0, atol=250)
