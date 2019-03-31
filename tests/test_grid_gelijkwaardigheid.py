from gptools.grid import Grid
from gptools.wbs import WBS
from tests.test_grid import abs_path


def test_grid_gelijkwaardigheid():
    # Get the path to the Envira files
    file_paths = abs_path('data/H_500_00_doc29')

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
    file_path = abs_path('data/wbs2005.h5')

    # Create a wbs object from the data file
    wbs = WBS.read_file(file_path)

    # Add the meteotoeslag Lden and Lnight noise levels
    wbs.add_noise_from_grid(meteotoeslag['Lden'])
    wbs.add_noise_from_grid(meteotoeslag['Lnight'])

    # Calculate the number of houses with >58dBA Lden and >48dBA Lnight
    w58den = wbs.count_homes_above(58, 'Lden')
    w48n = wbs.count_homes_above(48, 'Lnight')

    # Calculate the number of annoyed and sleep disturbed people
    eh48den = wbs.count_annoyed_people(48)
    sv40n = wbs.count_sleep_disturbed_people(40)

    print('   mm/year     w58den       w48n    eh48den      sv40n')
    print('---------- ---------- ---------- ---------- ----------')
    print('  incl. mm {:10.0f} {:10.0f} {:10.0f} {:10.0f}'.format(w58den, w48n, eh48den, sv40n))

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

        print('      {:04d} {:10.0f} {:10.0f} {:10.0f} {:10.0f}'.format(year, w58den, w48n, eh48den, sv40n))
