% --------------------------------------------------------------------
% This script finds the best fitting Values for each exp
% then plots the article figs
% --------------------------------------------------------------------

init;

%------------------------------------------------------------------------
% Plot fig
%------------------------------------------------------------------------

titles = {...
    'Exp. 1', 'Exp. 2', 'Exp. 3', 'Exp. 4', 'Exp. 5', 'Exp. 6', 'Exp. 7'};

i = 1;


for exp_name = filenames
    %subplot(2, 3, i);
    if ismember(i, [5, 6, 7])
        session = [0, 1];
    else
        session = 0;
    end
    exp_name = char(exp_name);
    
    [cho, out, cfout, corr2, con, p1, p2, rew] = ...
        DataExtraction.extract_learning_data(...
        d.(exp_name).data, d.(exp_name).sub_ids, idx, session);
    
    nsub = size(cho, 1);
    quest_filename = sprintf('data/questionnaire_%s', exp_name);
    % ------------------------------------------------------------------------
    % Correlate corr choice rate vs quest
    % -----------------------------------------------------------------------
    quest_data = load(quest_filename);
    quest_data = quest_data.data;
    
    for j = 1:nsub
        sub = d.(exp_name).sub_ids(j);
        mask_quest = arrayfun(@(x) x==-7, quest_data{:, 'quest'});
        mask_sub = arrayfun(...
            @(x) strcmp(sprintf('%.f', x), sprintf('%.f', sub)),...
            quest_data{:, 'sub_id'});
        crt_scores(j) = sum(...
            quest_data{logical(mask_quest .* mask_sub), 'val'} == 2);
    end
    
    for sub = 1:nsub
        d1 = corr2(sub, :);
        corr_rate_learning(sub) = mean(d1);
    end
    figure('Position', [1,1,700,500]);

    scatterCorr(...
        (crt_scores./7)',....
        (corr_rate_learning)',...
        blue_color,...
        0.7,...
        1,...
        1,...
        'w',...
        0 ...
        );
    ylabel('Correct choice rate (Test)');
    xlabel('CRT score');
    ylim([.4, 1])
    title(titles{i});
    clear crt_scores
    clear corr_rate_learning
    
    mkdir('fig/exp/', 'correlations');
    saveas(gcf, sprintf('fig/exp/correlations/crt_Learning_exp_%d.png', i));
    
    
    i = i + 1;
    clear crt_scores
    clear corr_rate_desc_vs_exp
    
end


count_quest = 1;
count_lot = 1;
for exp_name = filenames
    exp_name = char(exp_name);
    
    [cho, out, cfout, corr2, con, p1, p2, rew] = ...
        DataExtraction.extract_learning_data(...
        d.(exp_name).data, d.(exp_name).sub_ids, idx, [0, 1]);
    quest_filename = sprintf('data/questionnaire_%s', exp_name);
    % ------------------------------------------------------------------------
    % Correlate corr choice rate vs quest
    % -----------------------------------------------------------------------
    quest_data = load(quest_filename);
    quest_data = quest_data.data;
    nsub = size(cho, 1);
    
    for j = 1:nsub
        sub = d.(exp_name).sub_ids(j);
        mask_quest = arrayfun(@(x) x==-7, quest_data{:, 'quest'});
        mask_sub = arrayfun(...
            @(x) strcmp(sprintf('%.f', x), sprintf('%.f', sub)),...
            quest_data{:, 'sub_id'});
        crt_scores(count_quest) = sum(...
            quest_data{logical(mask_quest .* mask_sub), 'val'} == 2);
        count_quest = count_quest + 1;
        
    end
    
    for sub = 1:nsub
        d1 = corr2(sub, :);
        corr_rate_learning(count_lot) = mean(d1);
        count_lot = count_lot + 1;
    end
    
    
end

figure('Position', [1,1,700,500]);

scatterCorr(...
    (crt_scores./7)',....
    (corr_rate_learning)',...
    blue_color,...
    0.7,...
    1,...
    1,...
    'w',...
    0 ...
    );


ylabel('Correct choice rate (Test)');
xlabel('CRT score');

set(gca,'TickDir','out')
ylim([.4, 1])
title('All Exp.');
mkdir('fig/exp/', 'correlations');
saveas(gcf, sprintf('fig/exp/correlations/crt_Learning_all_exp.png'));