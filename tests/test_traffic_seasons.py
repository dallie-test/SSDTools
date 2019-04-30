import numpy as np
import pandas as pd
import datetime
from nose.tools import raises

from ssdtools.traffic import start_winter_season
from ssdtools.traffic import start_summer_season
from ssdtools.traffic import get_year_of_use


def test_start_summer_nominal():
    nominal = np.arange(1900, 2100)
    for y in nominal:
        summer_start = start_summer_season(y)
        assert isinstance(summer_start, datetime.date)
        assert summer_start.weekday() == 6


def test_start_summer_nominal_2019():
    assert start_summer_season(2019) == pd.Timestamp(2019, 3, 31)


def test_start_summer_nominal_2018():
    assert start_summer_season(2018) == pd.Timestamp(2018, 3, 25)


@raises(TypeError)
def test_start_summer_type():
    # Type error expected for float input
    start_summer_season(2000.)


def test_start_winter_nominal():
    nominal = np.arange(1900, 2100)
    for y in nominal:
        winter_start = start_winter_season(y)
        assert isinstance(winter_start, datetime.date)
        assert winter_start.weekday() == 6


def test_start_winter_nominal_2019():
    assert start_winter_season(2019) == pd.Timestamp(2019, 10, 27)


def test_start_winter_nominal_2018():
    assert start_winter_season(2018) == pd.Timestamp(2018, 10, 28)


@raises(TypeError)
def test_start_winter_type():
    start_winter_season(2000.)


def test_year_of_use_nominal():
    nominal = np.arange(1997, 2099, 1)
    for y in nominal:
        info = get_year_of_use(y)
        assert isinstance(info, dict)


@raises(TypeError)
def test_year_of_use_type():
    get_year_of_use(2000.)
