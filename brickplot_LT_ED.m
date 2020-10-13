%-------------------------------------------------------------------------
init;
%-------------------------------------------------------------------------
selected_exp = [1,2,3,4];
displayfig = 'on';

figure('Renderer', 'painters',...
    'Position', [145,157,828*length(selected_exp),600], 'visible',...
    displayfig)
num = 0;

for exp_num = selected_exp
 
    num = num + 1;
    
    sess = round((exp_num - round(exp_num)) * 10 - 1);
    sess = sess .* (sess ~= -1);
        
    % load data
    name = char(filenames{round(exp_num)});
    
    data = d.(name).data;
    sub_ids = d.(name).sub_ids;
    nsub = d.(name).nsub;
       
    param = load(...
        sprintf('data/post_test_fitparam_ED_exp_%d_%d',...
        round(exp_num), sess));
    midpoints2 = param.midpoints;
      
    [corr, cho, out2, p1, p2, ev1, ev2, ctch, cont1, cont2, dist] = ...
        DataExtraction.extract_sym_vs_lot_post_test(...
        data, sub_ids, idx, sess);
    
    ev = unique(p1)'.*100;
    varargin = ev;
    x_values = ev;
    x_lim = [0, 100];
    
    sim_params.d = d;
    sim_params.idx = idx;
    sim_params.sess = sess;
    sim_params.exp_name = name;
    sim_params.exp_num = exp_num;
    sim_params.model = 1;
    sim_params.nsub = d.(name).nsub;
    
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
        [0, 100], 11,...
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




