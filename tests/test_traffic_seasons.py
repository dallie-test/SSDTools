import numpy as np
import datetime
from nose.tools import raises

from gptools.traffic import start_winter_season
from gptools.traffic import start_summer_season
from gptools.traffic import get_year_of_use


def test_start_summer_nominal():
    nominal = np.arange(1996, 2099, 1)
    for y in nominal:
        summer_start = start_summer_season(y)
        assert isinstance(summer_start, datetime.date)
    pass


@raises(TypeError)
def test_start_summer_type():
    # Type error expected for float input
    summer_start = start_summer_season(2000.)
    assert False


@raises(ValueError)
def test_start_summer_edge_1995():
    # Value error expected when out of bounds case is input
    summer_start = start_summer_season(1995)
    assert False


@raises(ValueError)
def test_start_summer_edge_2100():
    # Value error expected when out of bounds case is input
    summer_start = start_summer_season(2100)
    assert False


def test_start_winter_nominal():
    nominal = np.arange(1996, 2099, 1)
    for y in nominal:
        winter_start = start_winter_season(y)
        assert isinstance(winter_start, datetime.date)
    pass


@raises(TypeError)
def test_start_winter_type():
    winter_start = start_winter_season(2000.)
    assert False


@raises(ValueError)
def test_start_winter_edge_1995():
    winter_start = start_winter_season(1995)
    assert False


@raises(ValueError)
def test_start_winter_edge_2100():
    winter_start = start_winter_season(2100)
    assert False


def test_year_of_use_nominal():
    nominal = np.arange(1997, 2099, 1)
    for y in nominal:
        info = get_year_of_use(y)
        assert isinstance(info, dict)
    pass


@raises(ValueError)
def test_year_of_use_edge_1996():
    info = get_year_of_use(1996)
    assert False


@raises(ValueError)
def test_year_of_use_edge_2100():
    info = get_year_of_use(2100)
    assert False


@raises(TypeError)
def test_year_of_use_type():
    info = get_year_of_use(2000.)
    assert False
