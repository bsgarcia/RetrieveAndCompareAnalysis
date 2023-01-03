%-------------------------------------------------------------------------
init;
show_current_script_name(mfilename('fullpath'));
%-------------------------------------------------------------------------

%-------------------------------------------------------------------------%
% parameters of the script                                                %
%-------------------------------------------------------------------------%
selected_exp = [1, 2, 3, 4];
modalities = {'LE', 'ES', 'SP'};
displayfig = 'off';
colors = [blue;orange;magenta];
% filenames
filename = 'Fig2D';
figfolder = 'fig';

figname = sprintf('%s/%s.svg', figfolder, filename);
stats_filename = sprintf('data/stats/%s.csv', filename);


%-------------------------------------------------------------------------%
% prepare data                                                            %
%-------------------------------------------------------------------------%
% stats_data is table that is used to compute stats later
stats_data = table();


figure('Units', 'centimeters',...
    'Position', [0,0,5.3*length(selected_exp), 5.3/1.25], 'visible', displayfig)

num = 0;
sub_count = 0;
for exp_num = selected_exp
    num = num + 1;
    disp(num)
    
    %---------------------------------------------------------------------%
    % get data parameters                                                           %
    % --------------------------------------------------------------------%
    sess = de.get_sess_from_exp_num(exp_num);
    name = de.get_name_from_exp_num(exp_num);
    nsub = de.get_nsub_from_exp_num(exp_num);
    
    throw = de.extract_ES(exp_num);
    nsym = length(unique(throw.p1));
    p1 = unique(throw.p1)'.*100;
    
    % prepare data structure
    midpoints = nan(length(modalities), nsub, nsym);
    slope = nan(length(modalities), nsub, 2);
    reshape_midpoints = nan(nsub, nsym);
    
    sim_params.exp_num = exp_num;
    sim_params.de = de;
    sim_params.sess = sess;
    sim_params.exp_name = name;
    sim_params.nsub = nsub;
    
    for mod_num = 1:length(modalities)
        
        % get data depending on chosen modality
        switch (modalities{mod_num})
            
            case 'LE'
                sim_params.model = 1;
                [midpoints(mod_num, :, :), throw] = get_qvalues(sim_params);
                
            case {'EE', 'ES'}
               
                param = load(...
                    sprintf('data/fit/midpoints_%s_exp_%d_%d_mle',...
                    modalities{mod_num}, round(exp_num), sess));

                midpoints(mod_num, :, :) = param.midpoints;
                
            case 'SP'
                sim_params.model = 2;
                [midpoints(mod_num, :, :), throw] = get_qvalues(sim_params);
        end
                  
        % fill data
        reshape_midpoints(:, :) = midpoints(mod_num, :, :);
        slope(mod_num,:,:) = add_linear_reg(...
            reshape_midpoints.*100, p1, colors(mod_num, :));
        
        % fill data for stats
        for sub = 1:nsub
            T1 = table(...
                sub+sub_count, num, slope(mod_num, sub, 2),...
                {modalities{mod_num}}, 'variablenames',...
                {'subject', 'exp_num', 'slope', 'modality'}...
                );
            stats_data = [stats_data; T1];
        end
    end
    sub_count = sub_count+sub;
    
    %---------------------------------------------------------------------%
    % Plot                                                                %
    % --------------------------------------------------------------------%
    subplot(1, length(selected_exp), num)
        
    
    skylineplot(slope(:, :, 2), 8,...
        colors,...
        -1.2,...
        1.5,...
        fontsize,...
        '',...
        '',...
        '',...
        modalities);
    
    title(sprintf('Exp. %s', num2str(exp_num)));
    hold on 
    plot([1,length(modalities)], [0, 0], 'color', 'k', 'linestyle', ':')
    hold on 

    if num == 1; ylabel('Slope'); end
    
    %title(sprintf('Exp. %s', num2str(exp_num)));w
    set(gca, 'tickdir', 'out');
    box off
    %set(gca, 'fontname', 'arial');
    set(gca, 'fontsize', fontsize);

    
end


%-------------------------------------------------------------------------%
% Save fig and stats                                                      %
% ------------------------------------------------------------------------%
% save fig
mkdir('fig/exp', figfolder);
saveas(gcf, figname);

% save stats file
mkdir('data', 'stats');
writetable(stats_data, stats_filename);

% 
T = stats_data;
T(strcmp(T.modality, 'LE'), 'modality') = {'ES'};
T(strcmp(stats_data.modality, 'ES'), 'modality') = {'LE'};

T.exp_num = nominal(T.exp_num);
T.modality = nominal(T.modality);
% cond_ED = strcmp(T.modality, 'ES');
% cond_LE = strcmp(T.modality, 'LE');
% cond_PM = strcmp(T.modality, 'PM');
% 
%disp('********************************************');
%disp('FULL');
%disp('********************************************');
%fitlme(T, 'slope ~ exp_num*modality + (1|subject)')%, 'CategoricalVar', {'exp_num', 'modality'})
% disp('********************************************');
% return
% disp('********************************************');
% disp('LE');
% disp('********************************************');
% fitlm(T(cond_LE,:), 'slope ~ exp_num', 'CategoricalVar', {'exp_num', 'modality'})
% disp('********************************************');
% disp('********************************************');
% disp('ES');
% disp('********************************************');
% M%fitlm(T(cond_ED,:), 'slope ~ exp_num', )
% disp('********************************************');
% disp('PM');
% disp('********************************************');
% fitlm(T(cond_PM,:), 'slope ~ exp_num')
% disp('********************************************');