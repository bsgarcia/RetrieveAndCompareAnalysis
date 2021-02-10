%-------------------------------------------------------------------------
init;
%-------------------------------------------------------------------------
selected_exp = [5, 6.1, 6.2];
displayfig = 'on';

figure('Renderer', 'painters','Units', 'centimeters',...
    'Position', [0,0,5.3*length(selected_exp), 5.3/1.25], 'visible', displayfig)
num = 0;

for exp_num = selected_exp
 
    num = num + 1;
    
    data = de.extract_EE(exp_num);
    sess = de.get_sess_from_exp_num(exp_num);
       
    param = load(...
        sprintf('data/post_test_fitparam_ED_exp_%d_%s',...
        round(exp_num), num2str(sess)));
    midpoints1 = param.midpoints;
    
    param = load(...
        sprintf('data/post_test_fitparam_EE_exp_%d_%s',...
        round(exp_num), num2str(sess)));
    midpoints2 = param.midpoints;
    beta2 = param.beta1;
    
    ev = unique(data.p1)'.*100; 
    varargin = ev;
    x_values = ev;
    x_lim = [0, 100];
    
    subplot(1, length(selected_exp), num)

    slope1 = add_linear_reg(midpoints1.*100, ev, orange_color);   
    hold on
    slope2 = add_linear_reg(midpoints2.*100, ev, green_color);
    hold on
    
    brick_comparison_plot2(...
        midpoints2'.*100,midpoints1'.*100,...
        green_color, orange_color, ...
        [-8, 108], 11,...
        '',...
        '',...
        '', varargin, 1, x_lim, x_values);
    
    if num == 1
        ylabel('Estimated p(win) (%)')
    end
    
    xlabel('Symbol p(win) (%)');
    box off
    hold on

    set(gca, 'fontsize', fontsize);
    set(gca,'tickdir','out')
    
end

mkdir('fig/exp', 'brickplot');
saveas(gcf, ...
    'fig/exp/brickplot/EE_ED.svg');