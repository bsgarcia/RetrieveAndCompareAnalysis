import pandas as pd
import pingouin as pg
import pymc3 as pm
import matplotlib.pyplot as plt
import statsmodels.api as sm
import seaborn as sns


def main():
    tests = ['ED_EE_corr']#['LE_ED_PM', 'ED_EE', 'LE_ED_EE_PM']

    pairwise_ttests(tests)


def lme(tests):
    for t_name in tests:
        print('*' * 5, t_name, '*' * 5)
        df = pd.read_csv(f'../data/stats/{t_name}.csv')
        pd.set_option('display.max_columns', None)
        pd.set_option('max_columns', None)

        # model = sm.MixedLM.from_formula('CRT~ exp_num*modality', data=df[df['modality']==0], groups=df['exp_num'][df['modality']==0]).fit()
        model = sm.OLS.from_formula('CRT~ exp_num', data=df[df['modality']==0], groups=df['exp_num'][df['modality']==0]).fit()
        print(model.summary())

        df["y_predict"] = model.predict(df)

        sns.set_style('darkgrid')
        grid = sns.lmplot(x="exp_num", y="y_predict", col="modality", sharey=False, col_wrap=2, data=df,
                          height=4, scatter_kws={'alpha':0, 'edgecolors': 'white'})
        grid.set(ylim=(0.1, 1))
        grid.set(xlim=(0, 5))

        grid.axes[0].scatter(df[df['modality']==0]['exp_num'], df[df['modality']==0]['CRT'], alpha=.2, color='C0', edgecolors='w')
        grid.axes[1].scatter(df['exp_num'][df['modality']==1], df['CRT'][df['modality']==1], alpha=.2, color='C0', edgecolors='w')

        plt.show()


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


if __name__ == '__main__':
    main()
