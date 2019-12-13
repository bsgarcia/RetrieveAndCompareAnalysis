% --------------------------------------------------------------------
% This script finds the best fitting Values for each exp
% then plots the article figs
% --------------------------------------------------------------------
init;

%------------------------------------------------------------------------
% Plot fig
%------------------------------------------------------------------------

titles = {...
    'Exp. 1', 'Exp. 2', 'Exp. 3', 'Exp. 4', 'Exp. 5', 'Pooled'};

i = 1;

figure('Position', [1,1,1900,1000]);

for exp_name = {filenames{1:5}}
    subplot(2, 3, i);
    if i == 5
        session = [0, 1];
    else
        session = 0;
    end
     exp_name = char(exp_name);
     nsub = d.(exp_name).nsub;
     
    [corr2, cho, out, p1, p2, ev1, ev2, ctch, cont1, cont2, dist, rtime] = ...
            DataExtraction.extract_sym_vs_lot_post_test(...
            d.(exp_name).data, d.(exp_name).sub_ids, idx, session);      
        
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
       mask_equal_ev = logical(ev1(sub, :) ~= ev2(sub, :));
       mask_easy = logical(~ismember(ev2(sub, :), [-1, 0, 1]));
       d1 = corr2(sub, logical(mask_equal_ev.*mask_easy));
       corr_rate_desc_vs_exp(sub) = mean(d1);
   end
        
   scatterCorr(...
        (crt_scores./7)',....
        (corr_rate_desc_vs_exp)',...
        orange_color,...
        0.7,...
        1,...
        1,...
        'w',...
        0 ...
    );
    ylabel('Correct choice rate (post-test ED)');
    xlabel('CRT score');
    ylim([.4, 1])
    title(titles{i});
    i = i + 1;
    clear crt_scores
    clear corr_rate_desc_vs_exp
    
end

subplot(2, 3, i);

count_quest = 1;
count_lot = 1;
for exp_name = filenames
    exp_name = char(exp_name);
    nsub = d.(exp_name).nsub;
    
    [corr2, cho, out, p1, p2, ev1, ev2, ctch, cont1, cont2, dist, rtime] = ...
        DataExtraction.extract_sym_vs_lot_post_test(...
        d.(exp_name).data, d.(exp_name).sub_ids, idx, [0, 1]);
    
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
        crt_scores(count_quest) = sum(...
            quest_data{logical(mask_quest .* mask_sub), 'val'} == 2);
        count_quest = count_quest + 1;
        
    end
    
    for sub = 1:nsub
        mask_equal_ev = logical(ev1(sub, :) ~= ev2(sub, :));
        mask_easy = logical(~ismember(ev2(sub, :), [-1, 0, 1]));
        d1 = corr2(sub, logical(mask_equal_ev.*mask_easy));
        corr_rate_desc_vs_exp(count_lot) = mean(d1);
        count_lot = count_lot + 1;

    end
    
    
end

scatterCorr(...
    (crt_scores./7)',....
    (corr_rate_desc_vs_exp)',...
    orange_color,...
    0.7,...
    1,...
    1,...
    'w',...
    0 ...
    );
ylabel('Correct choice rate (post-test ED)');
xlabel('CRT score');
ylim([.4, 1])
title(titles{i});

saveas(gcf, 'fig/exp/all/corr_crt.png');