%-------------------------------------------------------------------------
init;
%-------------------------------------------------------------------------

selected_exp = [5, 6.2, 7.2];
modality = 'ED';
color = orange_color;

displayfig = 'on';

figure('Renderer', 'painters',...
    'Position', [145,157,828*length(selected_exp),600], 'visible', displayfig)

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
    
    sim_params.d = d;
    sim_params.idx = idx;
    sim_params.sess = sess;
    sim_params.exp_name = name;
    sim_params.exp_num = exp_num;
    sim_params.nsub = d.(name).nsub;
    
    % get data depending on chosen modality
    switch (modality)
        
        case 'LE'
            sim_params.model = 1;
            [midpoints, throw] = get_qvalues(sim_params);
            
        case {'EE', 'ED'}
            
            param = load(...
                sprintf('data/post_test_fitparam_%s_exp_%d_%d',...
                modality, round(exp_num), sess));
            midpoints = param.midpoints;
            
            
        case 'PM'
            sim_params.model = 2;
            [midpoints, throw]  = get_qvalues(sim_params);
            
        otherwise 
            error('modality does not exist');
    end
    
    [corr, cho, out, p1, p2, ev1, ev2, ctch, cont1, cont2, dist, rtime] = ...
        DataExtraction.extract_estimated_probability_post_test...
        (data, sub_ids, idx, sess);
    
    ev = unique(p1)'.*100;
    varargin = ev;
    x_values = ev;
    x_lim = [0, 100];
   
    
    subplot(1, length(selected_exp), num)
    
    add_linear_reg(midpoints.*100, ev, color);
    brickplot2(...
        midpoints'.*100,...
        color.*ones(length(ev), 1),...
        [0, 100], 11,...
        '',...
        '',...
        '', varargin, 1, x_lim, x_values, .18);
    
    if num == 1
        ylabel('Estimated p(win) (%)');
    end
    
    xlabel('Symbol p(win) (%)');

    box off
    hold on
    
    %set(gca, 'ytick', [0:10]./10);
    set(gca,'TickDir','out')
    set(gca, 'fontsize', fontsize);    
        
end
% 
mkdir('fig/exp', 'brickplot');
        saveas(gcf, ...
            sprintf('fig/exp/brickplot/%s.svg',...
            modality));