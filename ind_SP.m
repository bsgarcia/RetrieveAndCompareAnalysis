init
selected_exp = [1.1];

figure('Renderer', 'painters','Units', 'centimeters',...
    'Position', [0,0,5.45*length(selected_exp), 5.3/1.25], 'visible', 'on')
num = 0;

for exp_num = selected_exp
    num = num + 1;
    SP = de.extract_SP(exp_num);

    sim_params.exp_num = exp_num;
    sim_params.de = de;
    sim_params.sess = SP.sess;
    sim_params.exp_name = SP.name;
    sim_params.nsub = SP.nsub;

    sim_params.model = 2;
    [midpoints, throw] = get_qvalues(sim_params);
    
    ev = unique(SP.p1).*100;
    varargin = ev;
    x_values = ev;
    x_lim = [0, 100];
   
    subplot(1, length(selected_exp), num)

    slope1 = add_linear_reg(midpoints.*100, ev', magenta);  
    hold on

    brickplot(...
        midpoints'.*100,...
        magenta.*ones(size(midpoints', 1),3), ...
        [-8, 108], fontsize,...
        '',...
        '',...
        '', varargin, 0, x_lim, x_values, 0.9, 0);
    hold on
     ylabel('Estimated p(win) (%)')
   
    xlabel('E-option p(win) (%)');
    box off
    
    set(gca,'tickdir','out')
    hold off
end

saveas(gcf, 'ind_SP.svg')