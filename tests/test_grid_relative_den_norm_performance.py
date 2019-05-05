import numpy as np
from ssdtools.grid import Grid, gwc, relative_den_norm_performance
from ssdtools.wbs import WBS
from scipy.optimize import brentq
from tests.test_grid import abs_path


def test_grid_scale_per_time_interval():
    # ------------------------------------------------------------------------
    # Directories and paths
    # ------------------------------------------------------------------------
    forecast_directory = abs_path('data/MER2019 H_500_doc29_VVR')
    wbs_file = abs_path('../data/wbs2018.h5')

    # ------------------------------------------------------------------------
    # Read Grid
    # ------------------------------------------------------------------------

    # Create a grid object from the data file
    den_grids = Grid.read_enviras(forecast_directory, r'[\w\d\s]+{}[\w\d\s]+\.dat'.format('Lden'))

    # Calculate the meteotoeslag
    den_meteotoeslag = den_grids.meteotoeslag_grid_from_method('hybride')

    # Create a grid object from the Lnight data file
    night_grids = Grid.read_enviras(forecast_directory, r'[\w\d\s]+{}[\w\d\s]+\.dat'.format('Lnight'))

    # Calculate the meteotoeslag
    night_meteotoeslag = night_grids.meteotoeslag_grid_from_method('hybride')

    # ------------------------------------------------------------------------
    # Read the WBS file
    # ------------------------------------------------------------------------

    # Create a wbs object from the data file
    wbs = WBS.read_file(wbs_file)

    # ------------------------------------------------------------------------
    # Interpolate the noise levels for the WBS
    # ------------------------------------------------------------------------

    wbs.add_noise_from_grid(den_meteotoeslag)
    wbs.add_noise_from_grid(night_meteotoeslag)

    # ------------------------------------------------------------------------
    # Get the optimal scaling factor that fits within the GWC
    # ------------------------------------------------------------------------
    norm = gwc['doc29_2018'].copy()

    # Run the function a single time for testing
    a = relative_den_norm_performance(1, norm, wbs, den_meteotoeslag)
    b = relative_den_norm_performance(3, norm, wbs, den_meteotoeslag)
    c = relative_den_norm_performance(3, norm, wbs, den_meteotoeslag, night_grid=night_meteotoeslag, scale_de=1,
                                      apply_lnight_time_correction=False)

    # Run the brentq function
    scale = brentq(relative_den_norm_performance, 1.0, 3.0, rtol=0.0001,
                   args=(norm, wbs, den_meteotoeslag, night_meteotoeslag, 1, None, False))

    assert scale < 3
    assert scale > 1


def test_grid_relative_den_norm_performance():
    """
    Integration test based on the example provided to Robert Koster by Ed Gordijn on April 1st 2019.

    This example shows an efficient way to determine the maximum volume of traffic that can fit within the GWC bounds.
    It uses a routine to search for zeros, which is the case when there is no room for additional traffic.

    """

    # ------------------------------------------------------------------------
    # Directories and paths
    # ------------------------------------------------------------------------
    forecast_directory = abs_path('data/MER2019 H_500_doc29_VVR')
    wbs_file = abs_path('../data/wbs2018.h5')

    # ------------------------------------------------------------------------
    # Read Grid
    # ------------------------------------------------------------------------

    # Create a grid object from the data file
    den_grids = Grid.read_enviras(forecast_directory, r'[\w\d\s]+{}[\w\d\s]+\.dat'.format('Lden'))

    # Scale the grid with factor 1.0319
    den_grids.scale(1.0319)

    # Get the Lden data
    den_data = np.array(den_grids.data)

    # Get the Lden statistics
    den_statistics = den_grids.statistics()

    # Calculate the meteotoeslag
    den_meteotoeslag = den_grids.meteotoeslag_grid_from_method('hybride')

    # Create a grid object from the Lnight data file
    night_grids = Grid.read_enviras(forecast_directory, r'[\w\d\s]+{}[\w\d\s]+\.dat'.format('Lnight'))

    # Scale the grid with factor 1.0121
    night_grids.scale(1.0121)

    # Get the Lnight data
    night_data = np.array(night_grids.data)

    # Get the Lnight statistics
    night_statistics = night_grids.statistics()

    # Calculate the meteotoeslag
    night_meteotoeslag = night_grids.meteotoeslag_grid_from_method('hybride')

    # ------------------------------------------------------------------------
    # Get the validation data of the grid
    # ------------------------------------------------------------------------

    dat_den_500k_dat = np.fromfile(abs_path('data/validation_schaal_relatief_norm_etmaal/dat_den_500k_dat.npy'))
    dat_den_500k_mm = np.fromfile(abs_path('data/validation_schaal_relatief_norm_etmaal/dat_den_500k_mm.npy'))
    dat_den_500k_dhi = np.fromfile(abs_path('data/validation_schaal_relatief_norm_etmaal/dat_den_500k_dhi.npy'))
    dat_den_500k_dlo = np.fromfile(abs_path('data/validation_schaal_relatief_norm_etmaal/dat_den_500k_dlo.npy'))
    dat_den_500k_mean = np.fromfile(abs_path('data/validation_schaal_relatief_norm_etmaal/dat_den_500k_mean.npy'))
    dat_den_500k_std = np.fromfile(abs_path('data/validation_schaal_relatief_norm_etmaal/dat_den_500k_std.npy'))

    dat_night_500k_dat = np.fromfile(abs_path('data/validation_schaal_relatief_norm_etmaal/dat_night_500k_dat.npy'))
    dat_night_500k_mm = np.fromfile(abs_path('data/validation_schaal_relatief_norm_etmaal/dat_night_500k_mm.npy'))
    dat_night_500k_dhi = np.fromfile(abs_path('data/validation_schaal_relatief_norm_etmaal/dat_night_500k_dhi.npy'))
    dat_night_500k_dlo = np.fromfile(abs_path('data/validation_schaal_relatief_norm_etmaal/dat_night_500k_dlo.npy'))
    dat_night_500k_mean = np.fromfile(abs_path('data/validation_schaal_relatief_norm_etmaal/dat_night_500k_mean.npy'))
    dat_night_500k_std = np.fromfile(abs_path('data/validation_schaal_relatief_norm_etmaal/dat_night_500k_std.npy'))

    # ------------------------------------------------------------------------
    # Validate the grid data
    # ------------------------------------------------------------------------

    np.testing.assert_array_equal(dat_den_500k_dat.reshape(den_data.shape), den_data)
    np.testing.assert_array_equal(dat_den_500k_mm.reshape(den_meteotoeslag.data.shape), den_meteotoeslag.data)
    np.testing.assert_array_equal(dat_den_500k_dhi.reshape(den_statistics['dhi'].data.shape),
                                  den_statistics['dhi'].data)
    np.testing.assert_array_equal(dat_den_500k_dlo.reshape(den_statistics['dlo'].data.shape),
                                  den_statistics['dlo'].data)
    np.testing.assert_array_equal(dat_den_500k_mean.reshape(den_statistics['mean'].data.shape),
                                  den_statistics['mean'].data)
    np.testing.assert_array_equal(dat_den_500k_std.reshape(den_statistics['std'].data.shape),
                                  den_statistics['std'].data)

    np.testing.assert_array_equal(dat_night_500k_dat.reshape(night_data.shape), night_data)
    np.testing.assert_array_equal(dat_night_500k_mm.reshape(night_meteotoeslag.data.shape), night_meteotoeslag.data)
    np.testing.assert_array_equal(dat_night_500k_dhi.reshape(night_statistics['dhi'].data.shape),
                                  night_statistics['dhi'].data)
    np.testing.assert_array_equal(dat_night_500k_dlo.reshape(night_statistics['dlo'].data.shape),
                                  night_statistics['dlo'].data)
    np.testing.assert_array_equal(dat_night_500k_mean.reshape(night_statistics['mean'].data.shape),
                                  night_statistics['mean'].data)
    np.testing.assert_array_equal(dat_night_500k_std.reshape(night_statistics['std'].data.shape),
                                  night_statistics['std'].data)

    # ------------------------------------------------------------------------
    # Read the WBS file
    # ------------------------------------------------------------------------

    # Create a wbs object from the data file
    wbs = WBS.read_file(wbs_file)

    # ------------------------------------------------------------------------
    # Interpolate the noise levels for the WBS
    # ------------------------------------------------------------------------

    interp_den = den_meteotoeslag.interpolation_function()
    interp_night = night_meteotoeslag.interpolation_function()

    wbs.add_noise_from_grid(den_meteotoeslag)
    wbs.add_noise_from_grid(night_meteotoeslag)

    # ------------------------------------------------------------------------
    # Get the validation data of the interpolated grid data
    # ------------------------------------------------------------------------
    wbs_den = np.fromfile(abs_path('data/validation_schaal_relatief_norm_etmaal/wbs_den.npy'))
    interp_den_coeffs = np.fromfile(abs_path('data/validation_schaal_relatief_norm_etmaal/interp_den_coeffs.npy'))
    interp_den_knots_0 = np.fromfile(abs_path('data/validation_schaal_relatief_norm_etmaal/interp_den_knots_0.npy'))
    interp_den_knots_1 = np.fromfile(abs_path('data/validation_schaal_relatief_norm_etmaal/interp_den_knots_1.npy'))
    interp_den_residual = np.fromfile(abs_path('data/validation_schaal_relatief_norm_etmaal/interp_den_residual.npy'))

    wbs_night = np.fromfile(abs_path('data/validation_schaal_relatief_norm_etmaal/wbs_night.npy'))
    interp_night_coeffs = np.fromfile(abs_path('data/validation_schaal_relatief_norm_etmaal/interp_night_coeffs.npy'))
    interp_night_knots_0 = np.fromfile(abs_path('data/validation_schaal_relatief_norm_etmaal/interp_night_knots_0.npy'))
    interp_night_knots_1 = np.fromfile(abs_path('data/validation_schaal_relatief_norm_etmaal/interp_night_knots_1.npy'))
    interp_night_residual = np.fromfile(
        abs_path('data/validation_schaal_relatief_norm_etmaal/interp_night_residual.npy'))

    # ------------------------------------------------------------------------
    # Validate the interpolated grid data
    # ------------------------------------------------------------------------
    np.testing.assert_array_equal(interp_den.get_coeffs(), interp_den_coeffs)
    np.testing.assert_array_equal(interp_den.get_knots()[0], interp_den_knots_0)
    np.testing.assert_array_equal(interp_den.get_knots()[1], interp_den_knots_1)
    np.testing.assert_array_equal(interp_den.get_residual(), interp_den_residual[0])
    np.testing.assert_array_equal(wbs.data['Lden'].values, wbs_den)

    np.testing.assert_array_equal(interp_night.get_coeffs(), interp_night_coeffs)
    np.testing.assert_array_equal(interp_night.get_knots()[0], interp_night_knots_0)
    np.testing.assert_array_equal(interp_night.get_knots()[1], interp_night_knots_1)
    np.testing.assert_array_equal(interp_night.get_residual(), interp_night_residual[0])
    np.testing.assert_array_equal(wbs.data['Lnight'].values, wbs_night)

    # ------------------------------------------------------------------------
    # Get the optimal scaling factor that fits within the GWC
    # ------------------------------------------------------------------------
    norm = gwc['doc29_2018'].copy()

    # Run the function a single time for testing
    a = relative_den_norm_performance(1, norm, wbs, den_meteotoeslag)
    b = relative_den_norm_performance(3, norm, wbs, den_meteotoeslag)

    # Get the optimal scale factor to apply
    scale_1 = brentq(relative_den_norm_performance, 1.0, 3.0, rtol=0.0001, args=(norm, wbs, den_meteotoeslag))

    # Test if the result is equal to the validation case
    assert scale_1 == 1.2713069520185394

    # Apply the new scale factor to the meteotoeslag grids
    den_meteotoeslag.scale(scale_1)
    night_meteotoeslag.scale(scale_1)

    # Add the grids to the WBS
    wbs.add_noise_from_grid(den_meteotoeslag).add_noise_from_grid(night_meteotoeslag)

    # Count the number of
    wden = wbs.count_homes_above(58, 'Lden')
    egh = wbs.count_annoyed_people(48)
    wn = wbs.count_homes_above(48, 'Lnight')
    sv = wbs.count_sleep_disturbed_people(40)

    # Validate the end results
    assert wden == 12001
    np.testing.assert_almost_equal(egh, 175405.58276207035, decimal=0)
    assert wn == 11188
    np.testing.assert_almost_equal(sv, 36117.424022735766, decimal=0)
