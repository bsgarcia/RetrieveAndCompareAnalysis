
import scipy.io as sio
import numpy as np
import pandas as pd
import pandas as pd
import pingouin as pg


def main():
    tests = ['LE_ED_PM', 'ED_EE']

    for t_name in tests:
        print('*' * 5, t_name, '*' * 5)
        df = pd.read_csv(f'../data/{t_name}.csv')
        pd.set_option('display.max_columns', None)
        pd.set_option('max_columns', None)
        # Compute the two-way mixed-design ANOVA
       # df['subject'][df['subject']>320] = np.arange(1, 321)
        #import pdb; pdb.set_trace()
        res = pg.pairwise_ttests(
            dv='slope', within='modality', between='exp_num', subject='subject',
            data=df, padjust='bonf', within_first=False, parametric=True)

        # x = df['slope'][(df['modality'] == 0) * (df['exp_num'] == 1)]
        # Pretty printing of ANOVA summary
        pg.print_table(res, floatfmt='.6f')
        # res = pg.ttest(x, y)
        # pg.print_table(res)

def plot():
    midpoint = .5;
    % steepness / scale / growth
    rate
    temp = 100000;

    x = linspace(0, 1, 12);
    y = logfun(x
    ', midpoint, temp);

    figure('Renderer', 'painters');

    lin1 = plot(x, ones(1, 12) * 0.5, 'linestyle', '--');
    hold
    on

    lin2 = plot(x, y);

    [xout, yout] = intersections(lin2.XData, lin2.YData, lin1.XData, lin1.YData);

    sc2 = scatter(xout, yout, 80, 'MarkerFaceColor', lin2.Color, ...
    'MarkerEdgeColor', 'w');
    ylim([0, 1])
    xlim([0, 1])

    function
    p = logfun(x, midpoint, temp)
    p = 1. / (1 + exp(-temp. * (midpoint(1) - x)));
    end
if __name__ == '__main__':
    main()
