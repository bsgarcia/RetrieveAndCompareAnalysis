import pandas as pd
import pingouin as pg
import pymc3 as pm
import matplotlib.pyplot as plt
import statsmodels.api as sm
import seaborn as sns
from sklearn.preprocessing import PolynomialFeatures
import numpy as np
import scipy.stats as stats


def main():
    infos = [dict(dv='RT', name='RT_FIT')]
        #dict(dv='RT', name='RT_E_D_EE'), dict(dv='RT', name='RT_H_LE_BOTH_NONE') ]

    polyfit(infos)

def polyfit_full(infos):
    for info in infos:
        # ------------------------------------------------------ #
        name = info['name']
        dv = info['dv']
        print('*' * 5, name, '*' * 5)
        df = pd.read_csv(f'../data/stats/{name}.csv')
        pd.set_option('display.max_columns', None)
        pd.set_option('max_columns', None)

        # x1 = df[df['modality']=='ED_d']['p']
        # y1 = df[df['modality']=='ED_d']['RT']
        # x2 = df[df['modality'] == 'ED_e']['p']
        # y2 = df[df['modality'] == 'ED_e']['RT']
        #
        # x = pd.concat([x1, x2], axis=1)
        # y = pd.concat([y1, y2], axis=1)#np.array([y1, y2]).reshape(len(y1), 2)
        x = np.array([df['p1'], df['p2']]).T
        y = np.array(df['RT'])


        # x['p1'].fillna(x['p1'].mean(), inplace=True)
        # y.fillna(y.mean(), inplace=True)

        polynomial_features = PolynomialFeatures(degree=2)
        xp = polynomial_features.fit_transform(x)

        import pdb;pdb.set_trace()
        model = sm.OLS(y, xp, missing='drop').fit()
        # ypred = model.predict(xp)

        # y = []
        # for p in np.unique(x):
        #     y.append(np.mean(ypred[p==x.flatten()]))
        #
        # y = np.array(y)
        # x = np.unique(x)
        #
        # plt.scatter(x,
        #             df[df['modality']=='ED_d']
        #             .groupby('p')['RT'].mean())
        #
        # plt.plot(x, y)
        # plt.fill_between(x, y1=y-sem, y2=y+sem, alpha=.6)
        # plt.ylim([1000, 2000])
        # plt.show()
        #
        print(model.summary())


def polyfit(infos):
    for info in infos:
        # ------------------------------------------------------ #
        name = info['name']
        dv = info['dv']
        print('*' * 5, name ,'*' * 5)
        df = pd.read_csv(f'../data/stats/{name}.csv')
        pd.set_option('display.max_columns', None)
        pd.set_option('max_columns', None)

        x = df[df['modality']=='ED_d']['p']
        y = df[df['modality']=='ED_d']['RT']

        x = np.array(x).reshape(len(x), 1)
        y = np.array(y).reshape(len(y), 1)

        polynomial_features = PolynomialFeatures(degree=2)
        xp = polynomial_features.fit_transform(x)

        model = sm.OLS(y, xp, missing='drop').fit()
        ypred = model.predict(xp)

        y = []
        for p in np.unique(x):
            y.append(np.mean(ypred[p==x.flatten()]))
        #
        y = np.array(y)
        x = np.unique(x)

        plt.scatter(x,
                    df[df['modality']=='ED_d']
                    .groupby('p')['RT'].mean())

        plt.plot(x, y)
        # plt.fill_between(x, y1=y-sem, y2=y+sem, alpha=.6)
        plt.ylim([1000, 2000])
        plt.show()
        #
        print(model.summary())

        # ------------------------------------------------------ #
        print('*' * 20, 'EE')
        x = df[df['modality']=='EE']['p']
        y = df[df['modality']=='EE']['RT']

        x = np.array(x).reshape(len(x), 1)
        y = np.array(y).reshape(len(y), 1)

        polynomial_features = PolynomialFeatures(degree=2)
        xp = polynomial_features.fit_transform(x)

        model = sm.OLS(y, xp, missing='drop').fit()
        ypred = model.predict(xp)

        y = []
        for p in np.unique(x):
            y.append(np.mean(ypred[p==x.flatten()]))

        y = np.array(y)
        x = np.unique(x)

        plt.scatter(x,
                    df[df['modality']=='EE']
                    .groupby('p')['RT'].mean())

        plt.plot(x, y)
        # plt.fill_between(x, y1=y-sem, y2=y+sem, alpha=.6)
        plt.ylim([1000, 2000])
        plt.show()
        #
        print(model.summary())

        x = df[df['modality']=='EE']['p'].unique()
        y = df[df['modality']=='EE'].groupby('p')['RT'].mean()
        model = sm.OLS.from_formula('RT~p', data=df[df['modality']=='EE']).fit()
        ypred = model.predict(df[df['modality']=='EE']['p'])

        y2 = []
        for p in x:
            y2.append(np.mean(ypred[df[df['modality']=='EE']['p']==p]))

        plt.scatter(x, y)
        plt.plot(x, y2)
        plt.ylim([1000, 2500])
        plt.show()

        print(model.summary())

        # ------------------------------------------------------ #
def anova(infos):
    for info in infos:
        name = info['name']
        dv = info['dv']
        print('*' * 5, name ,'*' * 5)
        df = pd.read_csv(f'../data/stats/{name}.csv')
        pd.set_option('display.max_columns', None)
        pd.set_option('max_columns', None)

        res = pg.rm_anova(data=df, dv='RT', within=['p_symbol', 'p_lottery'], subject='subject')

        # model = sm.GLM.from_formula('RT ~ p1*p2', data=df).fit()
        # print(model.summary())

        pg.print_table(res, floatfmt='.6f', tablefmt='latex')

        # res= pg.friedman(data=df, dv='RT', within='p1', subject='subject')
        # pg.print_table(res, floatfmt='.6f')
        # res= pg.friedman(data=df, dv='RT', within='p2', subject='subject')
        # pg.print_table(res, floatfmt='.6f')


def lme(infos):
    for info in infos:
        name = info['name']
        dv = info['dv']
        print('*' * 5, name ,'*' * 5)
        df = pd.read_csv(f'../data/stats/{name}.csv')
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


def pairwise_ttests(infos):
    for info in infos:
        name = info['name']
        dv = info['dv']
        print('*' * 5, name ,'*' * 5)
        df = pd.read_csv(f'../data/stats/{name}.csv')
        pd.set_option('display.max_columns', None)
        pd.set_option('max_columns', None)
        res = pg.pairwise_ttests(
            dv=dv, within='modality', between='exp_num', subject='subject',
            data=df, padjust='bonf', within_first=False, parametric=True)

        pg.print_table(res, floatfmt='.6f')

        # res = pg.anova(data=df[df['modality']==''], dv=dv, between='exp_num')

        # pg.print_table(res, floatfmt='.6f')
        #
        # print('ED')
        # res = pg.anova(data=df[df['modality']=='ED'], dv='RT', between='exp_num')
        # pg.print_table(res, floatfmt='.6f')
        #
        # print('LE')
        # res = pg.anova(data=df[df['modality']=='LE'], dv='RT', between='exp_num')
        # pg.print_table(res, floatfmt='.6f')
        #
        # res = pg.mixed_anova(data=df, dv='RT', between='exp_num', within='modality', subject='subject')
        #
        # pg.print_table(res, floatfmt='.6f')


if __name__ == '__main__':
    main()
