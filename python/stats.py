import scipy.io as sio
import numpy as np
import pandas as pd
import pandas as pd
import pingouin as pg


def main():
    df = pd.read_csv('../data/LT_ED_anova.csv')
    # Compute the two-way mixed-design ANOVA
    aov = pg.mixed_anova(dv='slope', within='modality', between='exp_num', subject='subject', data=df)
    res = pg.pairwise_ttests(dv='slope', within='modality', between='exp_num', subject='subject', data=df)

    # x = df['slope'][(df['modality'] == 0) * (df['exp_num'] == 1)]
    # y = df['slope'][(df['modality'] == 0) * (df['exp_num'] == 4)]
    # Pretty printing of ANOVA summary
    pg.print_table(aov)
    pg.print_table(res)
    # res = pg.ttest(x, y)
    # pg.print_table(res)

if __name__ == '__main__':
    main()