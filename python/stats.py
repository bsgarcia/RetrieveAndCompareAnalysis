import scipy.io as sio
import numpy as np
import pandas as pd
import pandas as pd
import pingouin as pg


def main():
    df = pd.read_csv('../data/LT_anova.csv')
    pd.set_option('display.max_columns', None)
    pd.set_option('max_columns', None)
    # Compute the two-way mixed-design ANOVA
   # df['subject'][df['subject']>320] = np.arange(1, 321)
    print(df)
    aov = pg.anova(dv='corr',  between='exp_num', data=df)
    res = pg.pairwise_ttests(dv='corr', within='exp_num', subject='subject', data=df)

    # x = df['slope'][(df['modality'] == 0) * (df['exp_num'] == 1)]
    # y = df['slope'][(df['modality'] == 0) * (df['exp_num'] == 4)]
    # Pretty printing of ANOVA summary
    pg.print_table(aov, floatfmt='.6f')
    pg.print_table(res, floatfmt='.6f')
    # res = pg.ttest(x, y)
    # pg.print_table(res)

if __name__ == '__main__':
    main()
