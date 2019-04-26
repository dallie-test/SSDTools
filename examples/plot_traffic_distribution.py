import os
import pandas as pd
import matplotlib.pyplot as plt

from gptools.figures import TrafficDistributionPlot
from gptools.traffic import Traffic, Bracket
from matplotlib import rc


def example_1():
    # Get the path to the sir TAF file
    file_path = os.path.join(os.path.dirname(__file__), '../tests/data/traffic.csv')

    # Set the read_csv arguments for this file
    file_kwargs = {
        'usecols': [0, 1, 2],
        'parse_dates': [1],
        'names': ['d_lt', 'd_schedule', 'd_date'],
        'skiprows': 1,
        'delimiter': ','
    }

    # Create a new traffic object
    aggregate = Traffic.read_taf_file(file_path, **file_kwargs)

    # Create a new traffic distribution plot, set the colors
    plot = TrafficDistributionPlot(takeoff_color='#fdbb4b', landing_color='#4a8ab7')

    # Add the traffic distribution from the traffic aggregate
    plot.add_traffic_bracket(aggregate.get_bracket())

    # Add the custom y-labels
    plot.add_takeoff_landing_label('starts', 'landingen')

    # Add the traffic legend
    plot.add_traffic_legend('verkeer')

    # Save the figure
    plot.save('figures/plot_traffic_distribution_example_1.pdf')

    # Show the plot
    plot.show()


def example_2():
    # Get the path to the Casper file
    file_path = os.path.join(os.path.dirname(__file__), '../tests/data/traffic-Daisy.txt')

    # Create a new traffic object
    aggregate = Traffic.read_daisy_weekday_file(file_path)

    # Create a new traffic distribution plot, set the colors
    plot = TrafficDistributionPlot(takeoff_color='#fdbb4b', landing_color='#4a8ab7')

    # Add the traffic distribution from the traffic aggregate
    plot.add_traffic_bracket(aggregate.get_bracket())

    # Add the custom y-labels
    plot.add_takeoff_landing_label('starts', 'landingen')

    # Add the traffic legend
    plot.add_traffic_legend('verkeer')

    # Save the figure
    plot.save('figures/plot_traffic_distribution_example_2.pdf')

    # Show the plot
    plot.show()


def example_3():
    # Get the path to the Casper file
    file_path = os.path.join(os.path.dirname(__file__), '../tests/data/traffic-Daisy.txt')

    # Create a new traffic object
    aggregate = Traffic.read_daisy_weekday_file(file_path)

    # Get the path to the TAF bracket file
    file_path = os.path.join(os.path.dirname(__file__), '../tests/data/bracketlijst.xlsx')

    # Create a new bracket object
    bracket = Bracket.read_taf_bracket_excel_file(file_path, sheet_name='106110', usecols=[0, 5, 6],
                                                  names=['bracket', 'L', 'T'])

    # Create a new traffic distribution plot, set the colors
    plot = TrafficDistributionPlot(takeoff_color='#fdbb4b', landing_color='#4a8ab7')

    # Add the TAF brackets as the capacity
    plot.add_capacity_bracket(bracket)

    # Add the traffic distribution from the traffic aggregate
    plot.add_traffic_bracket(aggregate.get_bracket())

    # Add the custom y-labels
    plot.add_takeoff_landing_label('starts', 'landingen')

    # Add the traffic legend
    plot.add_capacity_legend('baancapaciteit')

    # Add the traffic legend
    plot.add_traffic_legend('verkeer')

    # Save the figure
    plot.save('figures/plot_traffic_distribution_example_3.pdf')

    # Show the plot
    plt.show()


def example_4():
    # Get the path to the Casper file
    file_path = os.path.join(os.path.dirname(__file__), '../tests/data/traffic-Daisy.txt')

    # Create a new traffic object
    aggregate = Traffic.read_daisy_weekday_file(file_path)

    # Get periods from a Daisy file and get the scaled capacity
    periods = pd.read_excel(os.path.join(os.path.dirname(__file__), '../tests/data/periods-Daisy.xls'))
    capacity = pd.read_excel(os.path.join(os.path.dirname(__file__), '../tests/data/capaciteit.xlsx'))

    # Scale the capacity
    capacity[['Lcap', 'Tcap']] = capacity[['Lcap', 'Tcap']] / 3

    # Create a new bracket object
    bracket = Bracket.from_periods_and_capacity(periods, capacity)

    # Create a new traffic distribution plot, set the colors
    plot = TrafficDistributionPlot(takeoff_color='#fdbb4b', landing_color='#4a8ab7')

    # Add the TAF brackets as the capacity
    plot.add_capacity_bracket(bracket)

    # Add the traffic distribution from the traffic aggregate
    plot.add_traffic_bracket(aggregate.get_bracket())

    # Add the custom y-labels
    plot.add_takeoff_landing_label('starts', 'landingen')

    # Add the traffic legend
    plot.add_capacity_legend('baancapaciteit')

    # Add the traffic legend
    plot.add_traffic_legend('verkeer')

    # Save the figure
    plot.save('figures/plot_traffic_distribution_example_4.pdf')

    # Show the plot
    plt.show()


def example_5():
    # Get the path to the Casper file
    file_path = os.path.join(os.path.dirname(__file__), '../tests/data/traffic-Daisy.txt')

    # Create a new traffic aggregate object
    aggregate = Traffic.read_daisy_weekday_file(file_path)

    # Add taxi delays
    t = pd.to_datetime(aggregate.data['d_schedule'], format="%H:%M")
    t[aggregate.data['d_lt'] == 'L'] -= pd.Timedelta(10, unit='minute')
    t[aggregate.data['d_lt'] == 'T'] += pd.Timedelta(10, unit='minute')
    aggregate.data['d_schedule'] = t.dt.strftime('%H:%M')

    # Get periods from a Daisy file and get the scaled capacity
    periods = pd.read_excel(os.path.join(os.path.dirname(__file__), '../tests/data/periods-Daisy.xls'))
    capacity = pd.read_excel(os.path.join(os.path.dirname(__file__), '../tests/data/capaciteit.xlsx'))

    # Convert the capacity per hour to capacity per 20 minutes
    capacity[['Lcap', 'Tcap']] = capacity[['Lcap', 'Tcap']] / 3

    # Create a new bracket object
    bracket = Bracket.from_periods_and_capacity(periods, capacity)

    # Create a new traffic distribution plot, set the colors
    plot = TrafficDistributionPlot(takeoff_color='#fdbb4b', landing_color='#4a8ab7')

    # Add the TAF brackets as the capacity
    plot.add_capacity_bracket(bracket)

    # Add the traffic distribution from the traffic aggregate
    plot.add_traffic_bracket(aggregate.get_bracket(percentile=.95))

    # Set the ylim
    plot.ax.set_ylim([-45, 35])

    # Add the custom y-labels
    plot.add_takeoff_landing_label('starts', 'landingen')

    # Add the traffic legend
    plot.add_capacity_legend('baancapaciteit')

    # Add the traffic legend
    plot.add_traffic_legend('verkeer')

    # Save the figure
    plot.save('figures/plot_traffic_distribution_example_5.pdf')

    # Show the plot
    plt.show()


if __name__ == "__main__":
    # Define the axes branding to use
    axes = {
        'facecolor': '#e3e1d3',
        'edgecolor': '#757575',
        'linewidth': 0.5
    }

    # Configure the styling
    rc('axes', **axes)

    # Define the axes branding to use
    grid = {
        'color': 'white',
        'linewidth': 0.5
    }

    # Configure the styling
    rc('grid', **grid)

    example_1()
    example_2()
    example_3()
    example_4()
    example_5()
