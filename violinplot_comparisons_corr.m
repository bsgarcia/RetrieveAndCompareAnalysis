%-------------------------------------------------------------------------
init;
%-------------------------------------------------------------------------

%-------------------------------------------------------------------------%
% parameters of the script                                                %
%-------------------------------------------------------------------------%
selected_exp = [1, 2, 3, 4];
modalities = {'LE', 'ED'};
displayfig = 'on';
colors = [blue_color; orange_color];

%-------------------------------------------------------------------------%
% prepare data                                                            %
%-------------------------------------------------------------------------%
% stats_data is table that is used to compute stats later
T = table();

% filenames
% name = modality1_modality2_modalityN
filename = [cell2mat(strcat(modalities(1:end-1), '_')), modalities{end}];
figfolder = 'violinplot';

figname = sprintf('fig/exp/%s/%s.svg', figfolder, filename);
stats_filename = sprintf('data/stats/%s.csv', filename);

figure('Renderer', 'painters','Units', 'centimeters',...
    'Position', [0,0,5.3*length(selected_exp), 5.3/1.25], 'visible', displayfig)

num = 0;
sub_count = 0;
for exp_num = selected_exp
    num = num + 1;
    
    %---------------------------------------------------------------------%
    % get data                                                            %
    % --------------------------------------------------------------------%
    sess = round((exp_num - round(exp_num)) * 10 - 1);
    sess = sess .* (sess ~= -1);
    
    % load data
    name = char(filenames{round(exp_num)});
    
    data = d.(name).data;
    sub_ids = d.(name).sub_ids;
    nsub = d.(name).nsub;
    
    [corr{2}, cho, out2, p1, p2, ev1, ev2, ctch, cont1, cont2, dist] = ...
        DataExtraction.extract_sym_vs_lot_post_test(...
        data, sub_ids, idx, sess);
    
    [cho, cfcho, out, cfout, corr{1}, con1, p1, p2, rew, rtime, ev1, ev2,...
        error_exclude] = ...
        DataExtraction.extract_learning_data(data, sub_ids, idx, sess);
    
    for mod_num = 1:length(modalities)
     
        % fill data for stats
        for sub = 1:nsub
            T1 = table(...
                sub+sub_count, num, mean(corr{mod_num}(sub,:)), mod_num-1, 'variablenames',...
                {'subject', 'exp_num', 'CRT', 'modality'}...
                );
            T = [T; T1];
        end
    end
    sub_count = sub_count + sub;
    
    %---------------------------------------------------------------------%
    % Plot
    % %a
    % --------------------------------------------------------------------%
    subplot(1, length(selected_exp), num)
    
    skylineplot([mean(corr{1}, 2)'; mean(corr{2}, 2)'] , 4.5,...
        colors,...
        0,...
        1,...
        fontsize,...
        '',...
        '',...
        '',...
        modalities,...
        0);
    
    if num == 1;ylabel('Correct choice rate');end
    
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
writetable(T, stats_filename);