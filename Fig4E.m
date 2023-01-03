%-------------------------------------------------------------------------
init;
show_current_script_name(mfilename('fullpath'));
%-------------------------------------------------------------------------

%-------------------------------------------------------------------------%
% parameters of the script                                                %
%-------------------------------------------------------------------------%
selected_exp = [7];
modalities = {'ES', 'EE'};
displayfig = 'on';
colors = [orange;green];
% filenames
filename = 'Fig4E';
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
                    modalities{mod_num}, round(exp_num), sess(1)));
                
                midpoints(mod_num, :, :) = param.midpoints;
                
            case 'PM'
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
                sub+sub_count, exp_num, slope(mod_num, sub, 2),...
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
    modalities2 = {'ES', 'EE'};
    skylineplot(slope(:, :, 2), 8,...
        colors,...
        -1.2,...
        1.5,...
        fontsize,...
        '',...
        '',...
        '',...
        modalities2);
        
    
    if num == 1; ylabel('Slope'); end
    plot([1,length(modalities)], [0, 0], 'color', 'k', 'linestyle', ':')

    %title(sprintf('Exp. %s', num2str(exp_num)));w
    set(gca, 'tickdir', 'out');
    box off
    
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
% T = stats_data;
% cond_ED = strcmp(T.modality, 'ED');
% cond_EE = strcmp(T.modality, 'EE');
% cond_exp = ismember(T.exp_num, [6.1, 6.2]);
% cond_exp1 = ismember(T.exp_num, [6.1]);
% cond_exp2 = ismember(T.exp_num, [6.2]);
% 
% disp('********************************************');
% disp('FULL');
% disp('********************************************');
% fitlm(T(cond_exp, :), 'slope ~ modality*exp_num', 'CategoricalVars', {'exp_num', 'modality'})
% 
% disp('********************************************');
% disp('EE');
% disp('********************************************');
% fitlm(T(logical(cond_exp.*cond_EE), :), 'slope ~ modality*exp_num', 'CategoricalVars', {'exp_num', 'modality'})
% disp('********************************************');
% disp('ES');
% disp('********************************************');
% fitlm(T(logical(cond_exp.*cond_ED),:), 'slope ~ modality*exp_num', 'CategoricalVars', {'exp_num', 'modality'})
% return
% disp('********************************************');
% disp('EE - 6.1/6.2');
% disp('********************************************');
% fitlm(T(logical(cond_exp.*cond_EE),:), 'slope ~  exp_num')
% disp('********************************************');
% disp('ED - 6.1/6.2');
% disp('********************************************');
% fitlm(T(logical(cond_ED.*cond_exp),:), 'slope ~ exp_num')
% disp('********************************************');
% disp('ED vs EE - 6.1');
% disp('********************************************');
% fitlm(T(logical(cond_exp1),:), 'slope ~ modality')
% disp('********************************************');
% disp('ED vs EE - 6.2');
% disp('********************************************');
% fitlm(T(logical(cond_exp2),:), 'slope ~ modality')