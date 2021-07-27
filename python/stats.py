import pandas as pd
import pingouin as pg
# import pymc3 as pm
import matplotlib.pyplot as plt
import statsmodels.api as sm
import seaborn as sns
from sklearn.preprocessing import PolynomialFeatures
import numpy as np
import scipy.stats as stats


def main():
    infos = [dict(dv='slope', name='Fig2E')]
    # polyfit([infos[0]])
    pairwise_ttests([infos[0]])


def polyfit_full(infos):
    for info in infos:
        # ------------------------------------------------------ #
        name = info['name']
        dv = info['dv']
        print('*' * 5, name, '*' * 5)
        df = pd.read_csv(f'../data/stats/{name}.csv')
        pd.set_option('display.max_columns', None)
        pd.set_option('max_columns', None)

        # y2 = df[df['modality'] == 'ED_e']['RT']
        #
        # x = pd.concat([x1, x2], axis=1)
        # y = pd.concat([y1, y2], axis=1)#np.array([y1, y2]).reshape(len(y1), 2)
        x = np.array([df['p_lottery'], df['p_symbol']]).T
        y = np.array(df['RT'])

        # x['p1'].fillna(x['p1'].mean(), inplace=True)
        # y.fillna(y.mean(), inplace=True)

        polynomial_features = PolynomialFeatures(degree=2)
        xp = polynomial_features.fit_transform(x)

        model = sm.OLS(y, xp, missing='drop').fit()
        # ypred = model.predict(xp)

        print(model.summary())


def polyfit(infos):
    for info in infos:
        # ------------------------------------------------------ #
        name = info['name']
        dv = info['dv']
        print('*' * 5, name, '*' * 5)
        df = pd.read_csv(f'../data/stats/{name}.csv')
        pd.set_option('display.max_columns', None)
        pd.set_option('max_columns', None)

        # --------------------------------------------------------- #
        print('*' * 20, 'ED_d')
        data = df[df['modality'] == 'ED_d']
        x = data['p']
        y = data['RT']

        x = np.array(x).reshape(len(x), 1)
        y = np.array(y).reshape(len(y), 1)

        polynomial_features = PolynomialFeatures(degree=2)
        xp = polynomial_features.fit_transform(x)

        model = sm.OLS(y, xp, missing='drop').fit()
        lmodel = sm.OLS.from_formula('RT ~ p', data=data).fit()
        ypred = model.predict(xp)

        y = []
        for p in np.unique(x):
            y.append(np.mean(ypred[p == x.flatten()]))
        #
        y = np.array(y)
        x = np.unique(x)

        plt.scatter(x, data.groupby('p')['RT'].mean(), alpha=.6, color='C1')

        plt.plot(x, y, color='C1')
        plt.plot(x, lmodel.predict(pd.DataFrame({'p': x})), color='C4')
        # plt.fill_between(x, y1=y-sem, y2=y+sem, alpha=.6)
        plt.ylim([1000, 2000])
        plt.title('$ED_d$')
        plt.text(x=.5, y=1800, s=f'$R^2$ = {np.round(model.rsquared, 3)}'
                                 f'\n$R$= {np.round(np.sqrt(model.rsquared), 2)}'
                                 f'\np(x1), p(x2) = {np.round(model.pvalues[[1, 2]], 10)}')
        plt.xlabel('P(lottery)')
        plt.ylabel('RT')

        print(model.summary())
        print(lmodel.summary())

        plt.show()
        # import pdb;pdb.set_trace()

        # ------------------------------------------------------ #
        print('*' * 20, 'ED_e')
        x = df[df['modality'] == 'ED_e']['p']
        y = df[df['modality'] == 'ED_e']['RT']

        x = np.array(x).reshape(len(x), 1)
        y = np.array(y).reshape(len(y), 1)

        polynomial_features = PolynomialFeatures(degree=2)
        xp = polynomial_features.fit_transform(x)

        model = sm.OLS(y, xp, missing='drop').fit()
        lmodel = sm.OLS.from_formula('RT ~ p', data=df[df['modality'] == 'ED_e']).fit()
        ypred = model.predict(xp)

        y = []
        for p in np.unique(x):
            y.append(np.mean(ypred[p == x.flatten()]))

        y = np.array(y)
        x = np.unique(x)

        plt.scatter(x,
                    df[df['modality'] == 'ED_e']
                    .groupby('p')['RT'].mean(), alpha=.6, color='C1')

        plt.plot(x, y, color='C1')
        # plt.fill_between(x, y1=y-sem, y2=y+sem, alpha=.6)

        plt.ylim([1000, 2000])
        plt.title('$ED_e$')
        plt.text(x=.55, y=1800, s=f'$R^2$ = {np.round(model.rsquared, 3)}'
                                  f'\n$R$= {np.round(np.sqrt(model.rsquared), 2)}'
                                  f'\np(x1), p(x2) = {np.round(model.pvalues[[1, 2]], 5)}')

        plt.plot(x, lmodel.predict(pd.DataFrame({'p': x})), color='C4')
        plt.xlabel('P(symbol)')
        plt.ylabel('RT')
        #
        print(model.summary())
        print(lmodel.summary())

        plt.show()

        # --------------------------------------------------------- #

        print('*' * 20, 'EE')

        x = df[df['modality'] == 'EE']['p'].unique()
        y = df[df['modality'] == 'EE'].groupby('p')['RT'].mean()
        model = sm.OLS.from_formula('RT~p', data=df[df['modality'] == 'EE']).fit()
        ypred = model.predict(df[df['modality'] == 'EE']['p'])

        y2 = []
        for p in x:
            y2.append(np.mean(ypred[df[df['modality'] == 'EE']['p'] == p]))

        plt.scatter(x, y, alpha=.6, color='C2')
        plt.plot(x, y2, color='C2')
        plt.ylim([1000, 2500])
        plt.title('EE')
        plt.text(x=.6, y=2000, s=f'$R^2$ = {np.round(model.rsquared, 3)}'
                                 f'\n$R$= {np.round(np.sqrt(model.rsquared), 2)}'
                                 f'\np = {np.round(model.pvalues[-1], 10)}')
        plt.xlabel('P(symbol)')
        plt.ylabel('RT')
        plt.show()

        print(model.summary())
        # ------------------------------------------------------ #


def mixed_anova(infos):
    for info in infos:
        name = info['name']
        dv = info['dv']
        print('*' * 5, name, '*' * 5)
        df = pd.read_csv(f'../data/stats/{name}.csv')
        pd.set_option('display.max_columns', None)
        pd.set_option('max_columns', None)

        res = pg.mixed_anova(
            data=df, dv=dv, between='exp_num', within='modality', subject='subject'
        )

        pg.print_table(res, floatfmt='.6f')


def anova(infos):
    for info in infos:
        name = info['name']
        dv = info['dv']
        print('*' * 5, name, '*' * 5)
        df = pd.read_csv(f'../data/stats/{name}.csv')
        pd.set_option('display.max_columns', None)
        pd.set_option('max_columns', None)
        df = df[(df['exp_num'] == 2) + (df['exp_num'] == 3) + (df['exp_num'] == 4)]

        for modality in ('LE', 'ED'):
            print('*' * 5, modality, '*' * 5)

            res = pg.anova(
                data=df[df['modality'] == modality], dv=dv, between='exp_num', detailed=True
            )
            pg.print_table(res, floatfmt='.6f')


def lm(infos):
    for info in infos:
        name = info['name']
        dv = info['dv']
        print('*' * 5, name, '*' * 5)
        df = pd.read_csv(f'../data/stats/{name}.csv')
        pd.set_option('display.max_columns', None)
        pd.set_option('max_columns', None)
        df = df.drop(columns=['subject'])
        # df['score'][df['modality']=='ED'] = df['score'][df['modality']=='LE']

        # model = sm.MixedLM.from_formula('CRT~ exp_num*modality', data=df[df['modality']==0], groups=df['exp_num'][df['modality']==0]).fit()
        model = sm.OLS.from_formula('score ~ exp_num*modality', data=df).fit()
        print(model.summary())


def lme(infos):
    for info in infos:
        name = info['name']
        dv = info['dv']
        print('*' * 5, name, '*' * 5)
        df = pd.read_csv(f'../data/stats/{name}.csv')
        pd.set_option('display.max_columns', None)
        pd.set_option('max_columns', None)

        # model = sm.MixedLM.from_formula('CRT~ exp_num*modality', data=df[df['modality']==0], groups=df['exp_num'][df['modality']==0]).fit()
        model = sm.OLS.from_formula('CRT~ exp_num', data=df[df['modality'] == 0],
                                    groups=df['exp_num'][df['modality'] == 0]).fit()
        print(model.summary())

        df["y_predict"] = model.predict(df)

        sns.set_style('darkgrid')
        grid = sns.lmplot(x="exp_num", y="y_predict", col="modality", sharey=False, col_wrap=2, data=df,
                          height=4, scatter_kws={'alpha': 0, 'edgecolors': 'white'})
        grid.set(ylim=(0.1, 1))
        grid.set(xlim=(0, 5))

        grid.axes[0].scatter(df[df['modality'] == 0]['exp_num'], df[df['modality'] == 0]['CRT'], alpha=.2, color='C0',
                             edgecolors='w')
        grid.axes[1].scatter(df['exp_num'][df['modality'] == 1], df['CRT'][df['modality'] == 1], alpha=.2, color='C0',
                             edgecolors='w')

        plt.show()


def pairwise_ttests(infos):
    for info in infos:
        name = info['name']
        dv = info['dv']
        print('*' * 5, name, '*' * 5)
        df = pd.read_csv(f'../data/stats/{name}.csv')
        pd.set_option('display.max_columns', None)
        pd.set_option('max_columns', None)
        res = pg.pairwise_ttests(
            dv=dv, within='modality', between='exp_num', subject='subject',
            data=df, padjust='bonf', within_first=False, parametric=True)

        pg.print_table(res, floatfmt='.6f')


if __name__ == '__main__':
    main()
