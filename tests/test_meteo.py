import pandas as pd
from gptools.meteo import Meteo


def test_meteo_from_knmi():
    meteo = Meteo.from_knmi('2019-01-01 00:00', '2019-01-31 23:59')

    assert isinstance(meteo, Meteo)
    assert isinstance(meteo.data, pd.DataFrame)
    assert meteo.data.shape == (1, 2)
