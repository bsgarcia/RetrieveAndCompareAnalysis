%-------------------------------------------------------------------------
init;
%-------------------------------------------------------------------------

%-------------------------------------------------------------------------
% parameters of the script
%-------------------------------------------------------------------------
selected_exp = [1, 2, 3, 4];
modalities = {'LE', 'ED', 'EE', 'PM'};
displayfig = 'on';
colors = [blue_color; orange_color; green_color; magenta_color];

%-------------------------------------------------------------------------
% prepare data
%-------------------------------------------------------------------------
% stats_data is table that is used to compute stats later
stats_data = table();

% filenames
filename = [cell2mat(strcat(modalities(1:end-1), '_')), modalities{end}];
figfolder = 'violinplot';
figname = sprintf('fig/exp/%s/%s.svg', figfolder, filename);
stats_filename = sprintf('data/stats/%s.csv', filename);

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
    
    
    [corr, cho, out2, p1, p2, ev1, ev2, ctch, cont1, cont2, dist] = ...
        DataExtraction.extract_sym_vs_lot_post_test(...
        data, sub_ids, idx, sess);
    
    ev = unique(p1).*100;
    varargin = ev;
    x_values = ev;
    x_lim = [0, 100];
    
    sim_params.d = d;
    sim_params.idx = idx;
    sim_params.sess = sess;
    sim_params.exp_name = name;
    sim_params.exp_num = exp_num;
    sim_params.nsub = d.(name).nsub;
    
    % prepare data structure
    midpoints = nan(length(modalities), nsub, length(ev));
    slope = nan(length(modalities), nsub, 2);
    reshape_midpoints = nan(nsub, length(ev));
    
    
    for mod_num = 1:length(modalities)        
        
        % get data depending on chosen modality
        switch (modalities{mod_num})
            
            case 'LE'
                sim_params.model = 1;
                [midpoints(mod_num, :, :), throw] = get_qvalues(sim_params); 

            case {'EE', 'ED'}
                
                param = load(...
                    sprintf('data/post_test_fitparam_%s_exp_%d_%d',...
                    modalities{mod_num}, round(exp_num), sess));
                midpoints(mod_num, :, :) = param.midpoints;
            
                
            case 'PM'
                sim_params.model = 2;
                [midpoints(mod_num, :, :), throw]  = get_qvalues(sim_params); 
        end
        
        % fill data
        reshape_midpoints(:, :) = midpoints(mod_num, :, :);
        slope(mod_num,:,:) = add_linear_reg(...
            reshape_midpoints.*100, ev', colors(mod_num, :));   
        
        % fill data for stats
        for sub = 1:nsub
            T1 = table(...
                sub, num, slope(mod_num, sub, 2), mod_num, 'variablenames',...
                {'subject', 'exp_num', 'slope', 'modality'});
            stats_data = [stats_data; T1];
        end
    end
    
    
    subplot(1, length(selected_exp), num)
    
    skylineplot(slope(:, :, 2), 60,...
        colors,...
        -1,...
        1.7,...
        20,...
        '',...
        '',...
        '',...
        modalities,...
        0);
    if num == 1
        ylabel('Slope');
    end
    title(sprintf('Exp. %s', num2str(exp_num)));
    set(gca, 'tickdir', 'out');
    box off

end

% save fig
mkdir('fig/exp', figfolder);
saveas(gcf, figname);

% save stats file
mkdir('data', 'stats');
writetable(stats_data, stats_filename);