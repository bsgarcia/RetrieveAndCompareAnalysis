import pandas as pd
import pingouin as pg
import pymc3 as pm
import matplotlib.pyplot as plt
import numpy as np
from statsmodels.formula.api import ols
from sklearn.preprocessing import LabelEncoder


def plot_data(df, ax=None, color='grey', grp_id=None, **kwargs):
    if not ax:
        fig, ax = plt.subplots()
    ax.scatter(df['exp_num'], df['slope'], color=color, **kwargs)
    return ax


def line(slope, intercept, ax=None, **kwargs):
    """Plot a line from slope and intercept"""
    axes = ax if ax else plt.gca()
    x_vals = np.array([1, 4])
    y_vals = intercept + slope * x_vals
    axes.plot(x_vals, y_vals, **kwargs)


def posterior_plot(df, trace, ax, grp_id, alpha, color=None):
    grp_label = mod_le.transform([grp_id])[0]
    m_p = trace['b'][:, grp_label]
    c_p = trace['a'][:, grp_label]

    plot_posterior_regression_lines(m_p, c_p, ax, color='grey', alpha=0.05, lw=0.8)

    pooled_model = ols('slope ~ exp_num', df).fit()
    pooled_params = pooled_model.params

    mp = pooled_params['exp_num']
    cp = pooled_params['Intercept']

    plot_data(df, ax, grp_id=grp_id, color=colors[grp_id], zorder=3, alpha=alpha)
    line(m, c, ax, linestyle='--', color=red, label='unpooled fit', zorder=4)
    line(mp, cp, ax, color=colors[grp_id], label='pooled fit', zorder=4)


def plot_posterior_regression_lines(m_p, c_p, ax=None, **kwargs):
        """
            m_p, c_p : posterior samples of slope and intercept respectively
        """
        if not ax:
            fig, ax = plt.subplots()

        for m, c in zip(m_p, c_p):
            line(m, c, ax, **kwargs)


if __name__ == '__main__':

    # load data
    data = pd.read_csv('../data/stats/LE_ED_PM.csv')

    # colors from BMH style
    red = '#A60628'
    blue = '#0072B2'
    green = '#467821'
    violet = '#7A68A6'
    orange = '#D55E00'
    pink = '#CC79A7'

    colors = {'ED': orange, 'LE': blue, 'PM': violet}
    # ---------------------------------------------------------------------------------------------------------------- #

    mod_le = LabelEncoder()
    mod = mod_le.fit_transform(data['modality'])
    n_mod = len(mod_le.classes_)
    slope = data.slope
    exp_num = data.exp_num

    with pm.Model() as model:
        # hyperpriors
        mu_intercept = pm.Normal('mu_intercept', mu=.25, sigma=.4)
        sigma_intercept = pm.HalfNormal('sigma_intercept', .4)

        mu_slope = pm.Normal('mu_slope', mu=.07, sigma=.4)
        sigma_slope = pm.HalfNormal('sigma_slope', .4)

        # Intercept
        intercept_dist = pm.Normal('intercept_dist', mu=mu_intercept, sigma=sigma_intercept, shape=n_mod)
        # Slope
        slope_dist = pm.Normal('slope_dist', mu=mu_slope, sigma=sigma_slope, shape=n_mod)
        # Model error
        eps = pm.HalfCauchy('eps', .5)

        y_hat = intercept_dist[mod] + slope_dist[mod] * exp_num

        # Likelihood
        y_like = pm.Normal('y_like', mu=y_hat, sigma=eps, observed=slope)

    g = pm.model_to_graphviz(model)
    g.view()

    with model:
        step = pm.NUTS()
        trace = pm.sample(960, tune=30000)

    pm.traceplot(trace)

    # plt.show()

    # ---------------------------------------------------------------------------------------------------------------- #

    fig, ax = plt.subplots(1, 2, sharey=True, constrained_layout=True)

    sch_ids = mod_le.classes_[::-1]

    pm.forestplot(trace, var_names=['intercept_dist'],
                  combined=True,
                  ridgeplot_overlap=2,
                  colors='black',
                  ax=ax[0])
    ax[0].set_title('Intercepts')
    ax[0].set_yticklabels(sch_ids)
    ax[0].grid()
    pm.forestplot(trace, var_names=['slope_dist'],
                  combined=True,
                  ridgeplot_overlap=2,
                  colors='black',
                  ax=ax[1])
    ax[1].set_title('Slope')
    ax[1].set_yticklabels(sch_ids)
    ax[1].grid()
    fig.text(-0.02, 0.5, 'Modality', va='center', rotation='vertical', fontsize=14)

    # ---------------------------------------------------------------------------------------------------------------- #

    fig, ax = plt.subplots(1, 3, figsize=(16, 8),
                           sharex=True, sharey=True,
                           constrained_layout=True)

    groups = data.groupby('modality')
    grp_ids = list(groups.groups)

    for i in range(0, 3):
        grp_id = grp_ids[i]

        grp_label = mod_le.transform([grp_id])[0]
        m_p = np.random.choice(trace['intercept_dist'][:, grp_label], 100, replace=False)
        c_p = np.random.choice(trace['slope_dist'][:, grp_label], 100, replace=False)

        plot_posterior_regression_lines(m_p, c_p, ax[i], color='dimgray', alpha=0.05, lw=0.8)

        pooled_model = ols('slope ~ exp_num', data).fit()
        pooled_params = pooled_model.params

        m = pooled_params['exp_num']
        c = pooled_params['Intercept']

        unpooled_model = ols('slope ~ exp_num', data[data['modality'] == grp_id]).fit()
        unpooled_params = unpooled_model.params

        mp = unpooled_params['exp_num']
        cp = unpooled_params['Intercept']

        line(m, c, ax[i], linestyle='--', color=red, label='unpooled fit')
        line(mp, cp, ax[i], color=colors[grp_id], label='pooled fit')

        plot_data(groups.get_group(grp_id), ax[i], grp_id=grp_id, alpha=.3, color=colors[grp_id])
        ax[i].set_title('modality: ' + str(grp_id), fontweight='bold')
        ax[i].set_ylabel('slope')
        ax[i].set_xlabel('exp_num')
        ax[i].set_xticks(range(1, 5))

    fig.text(0.5, -0.03, 'exp_num', ha='center', fontsize=16)
    fig.text(-0.02, 0.5, 'slope', va='center', rotation='vertical', fontsize=16)
    handles, labels = ax[0].get_legend_handles_labels()
    fig.legend(handles, labels, loc='upper right', bbox_to_anchor=(0.98, 0.98))
    plt.show()
