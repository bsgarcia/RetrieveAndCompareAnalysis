%-------------------------------------------------------------------------
init;
%-------------------------------------------------------------------------
selected_exp = [5, 6.2, 7.2];
displayfig = 'on';

figure('Renderer', 'painters','Units', 'centimeters',...
    'Position', [0,0,5.3*length(selected_exp), 5.3/1.25], 'visible', displayfig)
num = 0;

for exp_num = selected_exp
    num = num + 1;
    lg
       
    param = load(...
        sprintf('data/post_test_fitparam_ED_exp_%d_%d',...
        round(exp_num), sess));
    midpoints1 = param.midpoints;
       
    params.exp_name = name;
    params.exp_num = exp_num;
    params.model = 2;
    params.d = d;
    params.idx = idx;
    params.sess = sess;
    params.nsub = d.(name).nsub;
    
    [midpoints2, throw] = get_qvalues(params);
    
    [corr, cho, out2, p1, p2, ev1, ev2, ctch, cont1, cont2, dist] = ...
        DataExtraction.extract_sym_vs_lot_post_test(...
        data, sub_ids, idx, sess);
    
    ev = unique(p1).*100;
    varargin = ev;
    x_values = ev;
    x_lim = [0, 100];
   
    subplot(1, length(selected_exp), num)
    
    slope1 = add_linear_reg(midpoints1.*100, ev', orange_color);
    hold on
    slope2 = add_linear_reg(midpoints2.*100, ev', magenta_color);  
    hold on
    
    brick_comparison_plot2(...
        midpoints1'.*100,midpoints2'.*100,...
        orange_color, magenta_color, ...
        [-8, 108], fontsize,...
        '',...
        '',...
        '', varargin, 1, x_lim, x_values);
%     
    if num == 1
        ylabel('Estimated p(win) (%)')
    end
   
    xlabel('Symbol p(win) (%)');
    box off
    hold on
    
    set(gca,'tickdir','out')

end
mkdir('fig/exp', 'brickplot');
        saveas(gcf, ...
            sprintf('fig/exp/brickplot/ED_PM.svg',...
            num2str(exp_num)));