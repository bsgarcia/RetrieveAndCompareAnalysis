%-------------------------------------------------------------------------
init;
%-------------------------------------------------------------------------
selected_exp = [9.2];
displayfig = 'on';

figure('Renderer', 'painters','Units', 'centimeters',...
    'Position', [0,0,5.3*length(selected_exp), 5.3/1.25], 'visible', displayfig)
num = 0;

for exp_num = selected_exp
    num = num + 1;

    
    %---------------------------------------------------------------------%
    % get data parameters                                                           %
    % --------------------------------------------------------------------%
    sess = de.get_sess_from_exp_num(exp_num);
    name = de.get_name_from_exp_num(exp_num);
    nsub = de.get_nsub_from_exp_num(exp_num);
    
    throw = de.extract_ED(exp_num);
    nsym = length(unique(throw.p1));
    p1 = unique(throw.p1)'.*100;
 
    
    sim_params.exp_num = exp_num;
    sim_params.de = de;
    sim_params.sess = sess;
    sim_params.exp_name = name;
    sim_params.nsub = nsub;
                    
    sim_params.model = 2;
    [midpoints2, throw] = get_qvalues(sim_params);
                                
    param = load(...
                    sprintf('data/midpoints_%s_exp_%d_%d_mle',...
                    'ED', round(exp_num), sess));
                
    midpoints1 = param.midpoints;
    
    ev = unique(p1);
    varargin = ev;
    x_values = ev;
    x_lim = [0, 100];
   
    subplot(1, length(selected_exp), num)
    
    slope1 = add_linear_reg(midpoints1.*100, ev, orange);
    hold on
    slope2 = add_linear_reg(midpoints2.*100, ev, magenta);  
    hold on
    
    brick_comparison_plot(...
        midpoints1'.*100,midpoints2'.*100,...
        orange, magenta, ...
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
