%-------------------------------------------------------------------------
init;
%-------------------------------------------------------------------------
selected_exp = [1, 2, 3, 4];
displayfig = 'on';

figure('Renderer', 'painters','Units', 'centimeters',...
    'Position', [0,0,5.3*length(selected_exp), 5.3/1.25], 'visible', displayfig)
num = 0;

for exp_num = selected_exp
 
    num = num + 1;
    
    sess = de.get_sess_from_exp_num(exp_num);
    name = de.get_name_from_exp_num(exp_num);
    nsub = de.get_nsub_from_exp_num(exp_num);
  
    param = load(...
        sprintf('data/post_test_fitparam_ED_exp_%d_%d',...
        round(exp_num), sess));
    midpoints2 = param.midpoints;
  
    data = de.extract_LE(exp_num);
    ev = unique([data.p1 data.p2])'.*100;
    varargin = ev;
    x_values = ev;
    x_lim = [0, 100];
    
    sim_params.de = de;
    sim_params.sess = sess;
    sim_params.exp_name = name;
    sim_params.exp_num = exp_num;
    sim_params.nsub = nsub;
    sim_params.model = 1;
    
    subplot(1, length(selected_exp), num)
    midpoints1 = get_qvalues(sim_params); 
   
    sim_params.model = 2;
    [midpoints3, throw] = get_qvalues(sim_params);
    
    slope1 = add_linear_reg(midpoints1.*100, ev, blue_color);   
    hold on
    slope2 = add_linear_reg(midpoints2.*100, ev, orange_color);
    hold on
    
    brick_comparison_plot2(...
        midpoints2'.*100,midpoints1'.*100,...
        orange_color, blue_color, ...
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
    'fig/exp/brickplot/LT_ED.svg');




