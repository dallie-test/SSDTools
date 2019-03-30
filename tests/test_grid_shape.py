import numpy as np
from nose.tools import raises
from gptools.grid import read_envira, Shape
from tests.test_grid import abs_path


def test_read_envira_shape():
    # Get the path to the envira file
    file_path = abs_path('data/GP2018 - Lnight y2016.dat')

    # Read the data from the envira file
    header, data = read_envira(file_path)

    # Create a Shape object from the header
    shape = Shape(header)

    assert shape.x_number == 143
    assert shape.x_start == 84000
    assert shape.x_step == 500
    assert shape.x_stop == 155000
    assert shape.y_number == 143
    assert shape.y_start == 455000
    assert shape.y_step == 500
    assert shape.y_stop == 526000


def test_shape_to_dict():
    # Get the path to the envira file
    file_path = abs_path('data/GP2018 - Lnight y2016.dat')

    # Read the data from the envira file
    header, data = read_envira(file_path)

    # Create a Shape object from the header
    shape = Shape(header)

    # Extract the dict from the Shape object
    shape_dict = shape.to_dict()

    assert shape_dict == {
        'x_number': 143,
        'x_start': 84000,
        'x_step': 500,
        'x_stop': 155000,
        'y_number': 143,
        'y_start': 455000,
        'y_step': 500,
        'y_stop': 526000
    }


@raises(ValueError)
def test_set_x_number_1():
    # Create a Shape object from the header
    shape = Shape({
        'x_number': 143,
        'x_start': 84000,
        'x_step': 500,
        'x_stop': 155000,
        'y_number': 143,
        'y_start': 455000,
        'y_step': 500,
        'y_stop': 526000
    })

    # Set the x number to 1
    shape.set_x_number(1)


def test_set_x_number_2():
    # Create a Shape object from the header
    shape = Shape({
        'x_number': 143,
        'x_start': 84000,
        'x_step': 500,
        'x_stop': 155000,
        'y_number': 143,
        'y_start': 455000,
        'y_step': 500,
        'y_stop': 526000
    })

    # Set the x number to 2
    shape.set_x_number(2)

    # Extract the dict from the Shape object
    shape_dict = shape.to_dict()

    assert shape_dict == {
        'x_number': 2,
        'x_start': 84000,
        'x_step': 155000 - 84000,
        'x_stop': 155000,
        'y_number': 143,
        'y_start': 455000,
        'y_step': 500,
        'y_stop': 526000
    }


def test_set_x_number_11():
    # Create a Shape object from the header
    shape = Shape({
        'x_number': 143,
        'x_start': 84000,
        'x_step': 500,
        'x_stop': 155000,
        'y_number': 143,
        'y_start': 455000,
        'y_step': 500,
        'y_stop': 526000
    })

    # Set the x number to 11
    shape.set_x_number(11)

    # Extract the dict from the Shape object
    shape_dict = shape.to_dict()

    # todo: Compare with the desired output
    assert shape_dict == False


def test_set_x_number_inf():
    # Create a Shape object from the header
    shape = Shape({
        'x_number': 143,
        'x_start': 84000,
        'x_step': 500,
        'x_stop': 155000,
        'y_number': 143,
        'y_start': 455000,
        'y_step': 500,
        'y_stop': 526000
    })

    # Set the x number to 2
    shape.set_x_number(np.inf)

    # Extract the dict from the Shape object
    shape_dict = shape.to_dict()

    assert shape_dict == {
        'x_number': np.inf,
        'x_start': 84000,
        'x_step': 0,
        'x_stop': 155000,
        'y_number': 143,
        'y_start': 455000,
        'y_step': 500,
        'y_stop': 526000
    }


def test_set_x_step():
    # todo: implement tests
    assert False


def test_refine_x():
    # todo: implement tests
    assert False


def test_get_x_coordinates():
    # todo: implement tests
    assert False


def test_set_y_step():
    # todo: implement tests
    assert False


def test_set_y_number():
    # todo: implement tests
    assert False


def test_refine_y():
    # todo: implement tests
    assert False


def test_get_y_coordinates():
    # todo: implement tests
    assert False


def test_refine():
    # todo: implement tests
    assert False
