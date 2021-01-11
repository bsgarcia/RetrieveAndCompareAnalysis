import pandas as pd
import pingouin as pg
import pymc3 as pm
import matplotlib.pyplot as plt

def main():
    tests = ['LE_ED']#['LE_ED_PM', 'ED_EE', 'LE_ED_EE_PM']
    tests = ['LE_ED_PM']

    bayesian_hm(tests)


def pairwise_ttests(tests):
    for t_name in tests:
        print('*' * 5, t_name, '*' * 5)
        df = pd.read_csv(f'../data/stats/{t_name}.csv')
        pd.set_option('display.max_columns', None)
        pd.set_option('max_columns', None)
        res = pg.pairwise_ttests(
            dv='slope', within='modality', between='exp_num', subject='subject',
            data=df, padjust='bonf', within_first=True, parametric=True)

        pg.print_table(res, floatfmt='.6f')

        res = pg.anova(data=df[df['modality']=='LE'], dv='slope', between='exp_num')

        pg.print_table(res, floatfmt='.6f')
        
        print('ED')
        res = pg.anova(data=df[df['modality']=='ED'], dv='slope', between='exp_num')
        pg.print_table(res, floatfmt='.6f')

        print('LE')
        res = pg.anova(data=df[df['modality']=='LE'], dv='slope', between='exp_num')
        pg.print_table(res, floatfmt='.6f')

        res = pg.mixed_anova(data=df, dv='slope', between='exp_num', within='modality', subject='subject')

        pg.print_table(res, floatfmt='.6f')


def bayesian_hm(tests):
    df = pd.read_csv(f'../data/stats/{tests[0]}.csv')
    pd.set_option('display.max_columns', None)
    pd.set_option('max_columns', None)
    with pm.Model() as model:
        # Hyperpriors
        mu_a = pm.Normal('mu_a', mu=.5, sigma=.4)
        sigma_a = pm.HalfNormal('sigma_a', .5)

        mu_b = pm.Normal('mu_b', mu=.5, sigma=.4)
        sigma_b = pm.HalfNormal('sigma_b', .5)

        # Intercept
        a = pm.Normal('a', mu=mu_a, sigma=sigma_a, shape=4)  # Slope
        b = pm.Normal('b', mu=mu_b, sigma=sigma_b, shape=4)

        # Model error
        eps = pm.HalfCauchy('eps', .05)

        # Model
        y_hat = a['* df['slope']

        # Likelihood
        y_like = pm.Normal('y_like', mu=y_hat, sigma=eps, observed=math)


if __name__ == '__main__':
    main()
