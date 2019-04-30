import os
import matplotlib.pyplot as plt
from gptools.figures import plot_runway_usage
from gptools.traffic import Traffic

if __name__ == "__main__":
    # Set the branding to use
    plt.style.use('../gptools/branding/schiphol_default.rc')

    # Get the path to the Daisy file
    file_path = os.path.join(os.path.dirname(__file__), '../tests/data/traffic 1971-2016 - mean.txt')

    # Create a traffic object from the data file
    mean_aggregate = Traffic.read_daisy_mean_file(file_path)

    # Get the runway usage for the mean traffic aggregate
    runway_usage = mean_aggregate.get_runway_usage('D|E')

    # Get the path to the Daisy file
    file_path = os.path.join(os.path.dirname(__file__), '../tests/data/traffic 1971-2016 - years.txt')

    # Create a traffic object from the data file
    myear_aggregate = Traffic.read_daisy_meteoyear_file(file_path)

    # Get the runway usage statistics for the meteoyear traffic aggregate
    runway_usage_statistics = myear_aggregate.get_runway_usage_statistics('D|E')

    # Create a aircraft type plot with the data in it
    fig, ax = plot_runway_usage(myear_aggregate, labels=['myear aggregate'])

    # Save the figure
    plt.savefig('figures/plot_runway_usage.pdf', dpi=300, bbox_inches='tight')

    # Show the figure
    plt.show()
