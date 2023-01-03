%-------------------------------------------------------------------------
init;
show_current_script_name(mfilename('fullpath'));
%-------------------------------------------------------------------------

%-------------------------------------------------------------------------%
% parameters of the script                                                %
%-------------------------------------------------------------------------%
selected_exp = [5, 6.2];
modalities = {'LE', 'SP'};
displayfig = 'on';
colors = [blue;orange;green;magenta];
% filenames
filename = 'review_poor_good';
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
slopes_LE = [];
slopes_ES = [];

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
    slopes = nan(length(modalities), nsub, 2);
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
        slopes(mod_num, :, :) = add_linear_reg(...
            reshape_midpoints.*100, p1, colors(mod_num, :));
        if mod_num == 1
            slopes_LE = [slopes_LE; squeeze(slopes(1, :, 2))'];
        else
            slopes_ES = [slopes_ES; squeeze(slopes(2, :, 2))'];
        end
        

        
        % fill data for stats
        for sub = 1:nsub
            T1 = table(...
                sub+sub_count, num, slopes(mod_num, sub, 2),...
                {modalities{mod_num}}, 'variablenames',...
                {'subject', 'exp_num', 'slope', 'modality'}...
                );
            stats_data = [stats_data; T1];
        end
    end
    sub_count = sub_count+sub;
    
    %---------------------------------------------------------------------%
    % Plot                                                                %
    %--------------------------------------------------------------------%
%     subplot(1, length(selected_exp), num)
%         
%     
%     skylineplot(slope(:, :, 2), 8,...
%         colors,...
%         -1.2,...
%         1.5,...
%         fontsize,...
%         '',...
%         '',...
%         '',...
%         modalities);
%     
%     title(sprintf('Exp. %s', num2str(exp_num)));
%     hold on 
%     plot([1,length(modalities)], [0, 0], 'color', 'k', 'linestyle', ':')
%     hold on 
% 
%     if num == 1; ylabel('Slope'); end
%     
%     title(sprintf('Exp. %s', num2str(exp_num)));w
%     set(gca, 'tickdir', 'out');
%     box off
%     set(gca, 'fontname', 'arial');
%     
end

[throw, idx_sorted] = sort(slopes_LE);
A1 = idx_sorted(1:end/2);
A2 = idx_sorted(end/2+1:end);
poor_LE = shuffle(slopes_LE(A1));
good_LE = shuffle(slopes_LE(A2));
poor_ES = slopes_ES(A1);
good_ES = slopes_ES(A2);


%---------------------------------------------------------------------%
% Plot                                                                %
%--------------------------------------------------------------------%
subplot(1, 2, 1)


skylineplot([poor_LE'; good_LE'], 8,...
    [blue;blue],...
    -1.2,...
    1.5,...
    fontsize,...
    '',...
    'Learners',...
    'Slope',...
    {'Poor', 'Good'});

title('Learning phase');
hold on
plot([1,length(modalities)], [0, 0], 'color', 'k', 'linestyle', ':')
hold on

%if num == 1; ylabel('Slope'); end
set(gca, 'tickdir', 'out');
box off
set(gca, 'fontname', 'arial');


%---------------------------------------------------------------------%
% Plot                                                                %
%--------------------------------------------------------------------%
subplot(1, 2, 2)

skylineplot([poor_ES'; good_ES'], 8,...
    [magenta; magenta],...
    -1.2,...
    1.5,...
    fontsize,...
   '',...
    'Learners',...
    '',...
    {'Poor', 'Good'});

title('Exp. 5, 6');
hold on
plot([1,length(modalities)], [0, 0], 'color', 'k', 'linestyle', ':')
hold on

%if num == 1; ylabel('Slope'); end
title('Stated Probability phase');
set(gca, 'tickdir', 'out');
box off
set(gca, 'fontname', 'arial');
%-------------------------------------------------------------------------%
% Save fig and stats                                                      %
% ------------------------------------------------------------------------%
% save fig
mkdir('fig/exp', figfolder);
saveas(gcf, figname);

% 
% disp('********************************************');
% disp('FULL');
% disp('********************************************');
% fitlme(T, 'slope ~ exp_num*modality + (1|subject)')% 'CategoricalVar', {'exp_num', 'modality'})
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