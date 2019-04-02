import numpy as np
from nose.tools import raises
from gptools.grid import read_envira, Shape
from test_grid import abs_path


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

    assert shape_dict == {
        'x_number': 11,
        'x_start': 84000,
        'x_step': (155000 - 84000)/10,
        'x_stop': 155000,
        'y_number': 143,
        'y_start': 455000,
        'y_step': 500,
        'y_stop': 526000
    }

    # todo: Confirm x_number tests


@raises(ValueError)
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


@raises(ValueError)
def test_set_x_number_nan():
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

    # Set the y number to NaN
    shape.set_x_number(np.nan)
    assert False


def test_set_x_step():
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

    # Set the x_step to 250
    shape.set_x_step(250)

    # Extract the dict from the Shape object
    shape_dict = shape.to_dict()

    # Compare with the desired input
    assert shape_dict == {
        'x_number': 285,
        'x_start': 84000,
        'x_step': 250,
        'x_stop': 155000,
        'y_number': 143,
        'y_start': 455000,
        'y_step': 500,
        'y_stop': 526000
    }
    # todo: Confirm x_step tests


@raises(ValueError)
def test_set_x_step_nan():
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

    # Set the x_step to nan
    step = np.nan
    shape.set_x_step(step)
    assert False


@raises(ValueError)
def test_set_x_step_inf():
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

    # Set the x_step to nan
    step = np.inf
    shape.set_x_step(step)
    assert False


def test_refine_x():
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

    # Refine shape with factor 2
    shape.refine_x(2)

    # Extract the dict from the Shape object
    shape_dict = shape.to_dict()

    assert shape_dict == {
        'x_number': 285,
        'x_start': 84000,
        'x_step': 250,
        'x_stop': 155000,
        'y_number': 143,
        'y_start': 455000,
        'y_step': 500,
        'y_stop': 526000
    }

    # todo: Confirm refine_x tests


@raises(ValueError)
def test_refine_x_nan():
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

    # Refine the shape with factor NaN
    factor = np.nan
    shape.refine_x(factor)
    assert False


@raises(ValueError)
def test_refine_x_inf():
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

    # Refine the shape with factor NaN
    factor = np.inf
    shape.refine_x(factor)
    assert False


def test_get_x_coordinates():
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

    x = shape.get_x_coordinates()

    assert len(x) == shape.x_number

    # todo: Confirm get_x_coordinates tests


@raises(OverflowError)
def test_get_x_coordinates_inf():
    shape = Shape({
        'x_number': np.inf,
        'x_start': 84000,
        'x_step': 500,
        'x_stop': 155000,
        'y_number': 143,
        'y_start': 455000,
        'y_step': 500,
        'y_stop': 526000
    })

    x = shape.get_x_coordinates()
    assert False


@raises(ValueError)
def test_get_x_coordinates_nan():
    shape = Shape({
        'x_number': np.nan,
        'x_start': 84000,
        'x_step': 500,
        'x_stop': 155000,
        'y_number': 143,
        'y_start': 455000,
        'y_step': 500,
        'y_stop': 526000
    })

    x = shape.get_x_coordinates()
    assert False


def test_set_y_step():
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

    # Set the y_step to 250
    shape.set_y_step(250)

    # Extract the dict from the Shape object
    shape_dict = shape.to_dict()

    # Compare with the desired input
    assert shape_dict == {
        'x_number': 143,
        'x_start': 84000,
        'x_step': 500,
        'x_stop': 155000,
        'y_number': 285,
        'y_start': 455000,
        'y_step': 250,
        'y_stop': 526000
    }

    # todo: Confirm y_step tests


@raises(ValueError)
def test_set_y_step_nan():
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

    # Set the x_step to nan
    step = np.nan
    shape.set_y_step(step)
    assert False


@raises(ValueError)
def test_set_y_step_inf():
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

    # Set the x_step to nan
    step = np.inf
    shape.set_y_step(step)
    assert False


@raises(ValueError)
def test_set_y_number_1():
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
    shape.set_y_number(1)
    assert False


def test_set_y_number_2():
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

    # Set the y number to 2
    shape.set_y_number(2)

    # Extract the dict from the Shape object
    shape_dict = shape.to_dict()

    assert shape_dict == {
        'x_number': 143,
        'x_start': 84000,
        'x_step': 500,
        'x_stop': 155000,
        'y_number': 2,
        'y_start': 455000,
        'y_step': 526000 - 455000,
        'y_stop': 526000
    }


def test_set_y_number_11():
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

    # Set the y number to 11
    shape.set_y_number(11)

    # Extract the dict from the Shape object
    shape_dict = shape.to_dict()

    # todo: Compare with the desired output

    assert shape_dict == {
        'x_number': 143,
        'x_start': 84000,
        'x_step': 500,
        'x_stop': 155000,
        'y_number': 11,
        'y_start': 455000,
        'y_step': (526000 - 455000)/10,
        'y_stop': 526000
    }


@raises(ValueError)
def test_set_y_number_inf():
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

    # Set the y number to inf
    shape.set_y_number(np.inf)
    assert False


@raises(ValueError)
def test_set_y_number_nan():
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

    # Set the y number to NaN
    shape.set_y_number(np.nan)
    assert False


def test_refine_y():
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

    # Refine shape with factor 2
    shape.refine_y(2)

    # Extract the dict from the Shape object
    shape_dict = shape.to_dict()

    assert shape_dict == {
        'x_number': 143,
        'x_start': 84000,
        'x_step': 500,
        'x_stop': 155000,
        'y_number': 285,
        'y_start': 455000,
        'y_step': 250,
        'y_stop': 526000
    }

    # todo: Confirm refine_y tests


@raises(ValueError)
def test_refine_y_nan():
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

    # Refine the shape with factor NaN
    factor = np.nan
    shape.refine_y(factor)
    assert False

@raises(ValueError)
def test_refine_y_inf():
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

    # Refine the shape with factor NaN
    factor = np.inf
    shape.refine_y(factor)
    assert False


def test_get_y_coordinates():
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

    y = shape.get_y_coordinates()

    assert len(y) == shape.y_number

    # todo: Confirm get_y_coordinates tests


@raises(OverflowError)
def test_get_y_coordinates_inf():
    shape = Shape({
        'x_number': 500,
        'x_start': 84000,
        'x_step': 500,
        'x_stop': 155000,
        'y_number': np.inf,
        'y_start': 455000,
        'y_step': 500,
        'y_stop': 526000
    })

    y = shape.get_y_coordinates()
    assert False


@raises(ValueError)
def test_get_y_coordinates_nan():
    shape = Shape({
        'x_number': 500,
        'x_start': 84000,
        'x_step': 500,
        'x_stop': 155000,
        'y_number': np.nan,
        'y_start': 455000,
        'y_step': 500,
        'y_stop': 526000
    })

    y = shape.get_y_coordinates()
    assert False


def test_refine():
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

    # Refine shape with factor 2
    shape.refine(2)

    # Extract the dict from the Shape object
    shape_dict = shape.to_dict()

    assert shape_dict == {
        'x_number': 285,
        'x_start': 84000,
        'x_step': 250,
        'x_stop': 155000,
        'y_number': 285,
        'y_start': 455000,
        'y_step': 250,
        'y_stop': 526000
    }

    # todo: Confirm refine tests


@raises(ValueError)
def test_refine_nan():
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

    # Refine the shape with factor NaN
    factor = np.nan
    shape.refine(factor)
    assert False


@raises(ValueError)
def test_refine_inf():
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

    # Refine the shape with factor NaN
    factor = np.inf
    shape.refine(factor)
    assert False
