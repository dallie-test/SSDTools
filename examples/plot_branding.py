import matplotlib.pyplot as plt

if __name__ == "__main__":
    # Set the branding to use
    plt.style.use('../ssdtools/branding/schiphol_default.rc')

    # Plot the various colors as bars
    for x in range(11):
        plt.bar(x, 10, label='Color {}'.format(x))

    # Add a legend to show the labels
    plt.legend()

    # Show the figure
    plt.show()
