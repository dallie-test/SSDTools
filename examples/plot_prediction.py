import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from gptools.figures import plot_prediction

if __name__ == "__main__":
    # Set the branding to use
    plt.style.use('../gptools/branding/schiphol_default.rc')

    # Create some random historic data
    historic_years = pd.Series(np.arange(2001, 2019), name='years')
    historic_data = pd.Series(np.arange(0, 18) / 2 + np.random.rand(18), name='data')
    history = pd.concat([historic_years, historic_data], axis=1)

    # Create some random predicted data
    predicted_year = pd.Series(2020 + np.zeros(20, dtype=int), name='years')
    predicted_data = pd.Series(9 + 2 * np.random.rand(20), name='data')
    prediction_2020 = pd.concat([predicted_year, predicted_data], axis=1)

    predicted_year = pd.Series(2025 + np.zeros(20, dtype=int), name='years')
    predicted_data = pd.Series(9 + 5 * np.random.rand(20), name='data')
    prediction_2025 = pd.concat([predicted_year, predicted_data], axis=1)

    # Create a prediction plot
    fig, ax = plot_prediction(history, pd.concat([prediction_2020, prediction_2025], axis=0),
                              history_plot_kwargs={'label': 'realisatie'},
                              prediction_errorbar_kwargs={'label': 'prognose'})

    plt.savefig('figures/plot_prediction.pdf')

    plt.show()
