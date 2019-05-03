import numpy as np
import pandas as pd
from ssdtools.meteo import Meteo


def test_meteo_from_knmi():
    meteo = Meteo.from_knmi('2019-01-01 00:00', '2019-01-31 23:59')

    assert isinstance(meteo, Meteo)
    assert isinstance(meteo.data, pd.DataFrame)
    assert meteo.data.shape == (31 * 24, 6)


def test_get_windrose():
    meteo = Meteo.from_knmi('2019-01-01 00:00', '2019-01-31 23:59')

    windrose = meteo.get_windrose()

    assert windrose.shape[0] <= 12 * 5 + 1
    assert meteo.data.shape[0] == 31 * 24
    assert np.all(windrose.index.get_level_values(0).isin(np.arange(0, 390, 30)))
    assert np.all(windrose.index.get_level_values(1).isin(np.arange(0, 30, 5)))
