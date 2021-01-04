import pandas as pd
import pingouin as pg


def main():
    tests = ['LE_ED']#['LE_ED_PM', 'ED_EE', 'LE_ED_EE_PM']

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

if __name__ == '__main__':
    main()
