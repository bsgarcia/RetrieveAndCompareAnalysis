close all
clear all

addpath './'
addpath './plot'

%------------------------------------------------------------------------
% Set parameters
%------------------------------------------------------------------------
i_learn = 0;
i_eli = 0;
i_quest = 0;
i_opt = 0;
for exp_num = selected_exp
    selected_exp = [1, 2, 3, 4];
%selected_exp = [4];
model = [1];

displayfig = 'on';
sessions = [0, 1];
nagent = 10;

for exp_num = selected_exp
    
        idx1 = (exp_num - round(exp_num)) * 10;   
        idx1 = idx1 + (idx1==0);

        sess = sessions(uint64(idx1));

        % load data
        exp_name = char(filenames{round(exp_num)});

        data = d.(exp_name).data;
        sub_ids = d.(exp_name).sub_ids;

        [cho, cfcho, out, cfout, corr1, con1, p1, p2, rew, rtime, ev1, ev2,...
            error_exclude] = ...
            DataExtraction.extract_learning_data(data, sub_ids, idx, sess);
            
            for sub = 1:size(corr1, 1)
                i_learn = i_learn + 1;
                corr_rate_learning(i_learn) = mean(corr1(sub, :, :), 'all');         
            end
            
            %------------------------------------------------------------------------
            % Compute corr choice rate elicitation
            %------------------------------------------------------------------------
            %corr_rate_elicitation = zeros(size(corr, 1), 1);
            %corr_rate_elicitation_sym = zeros(size(corr, 1), 8);
            %dist_ordered = zeros(size(corr, 1), 8);
            
            for sub = 1:size(corr, 1)
                i_eli = i_eli + 1;
                mask_equal_ev = logical(ev1(sub, :) ~= ev2(sub, :));
                d = corr(sub, mask_equal_ev);
                corr_rate_elicitation(i_eli) = mean(d);
            end
            
            
            % ------------------------------------------------------------------------
            % Correlate corr choice rate vs quest
            % -----------------------------------------------------------------------
            quest_data = load(quest_filename);
            quest_data = quest_data.data;
            
            for i = 1:length(sub_ids)
                i_quest = i_quest + 1;
                sub = sub_ids(i);
                mask_quest = arrayfun(@(x) x==-7, quest_data{:, 'quest'});
                mask_sub = arrayfun(...
                    @(x) strcmp(sprintf('%.f', x), sprintf('%.f', sub)),...
                    quest_data{:, 'sub_id'});
                crt_scores(i_quest) = sum(...
                    quest_data{logical(mask_quest .* mask_sub), 'val'});
            end


        end
    end
end
%------------------------------------------------------------------------
% Plot correlations 
% -----------------------------------------------------------------------
% LEARNING PHASE
% -----------------------------------------------------------------------
% figure('visible', displayfig)
% scatterCorr(...
%     corr_rate_learning,...
%     crt_scores./14,...
%     [0.4660    0.6740    0.1880],...
%     0.6,...
%     2,...
%     2,...
%     'w');
% ylabel('CRT Score');
% xlabel('Correct choice rate learning');
% saveas(gcf, 'fig/exp/pooled/corr_learning_crt.png');
% 
% %------------------------------------------------------------------------
% % ELICITATION PHASE
% % -----------------------------------------------------------------------
% figure('visible', displayfig)
% scatterCorr(...
%     corr_rate_elicitation,...
%     crt_scores./14,...
%     [0.4660    0.6740    0.1880],...
%     0.6,...
%     2,...
%     2,...
%     'w');
% ylabel('CRT Score');
% xlabel('Correct choice rate elicitation');
% saveas(gcf,'fig/exp/pooled/corr_elicitation_crt.png');
% 
% %------------------------------------------------------------------------
% % ELICITATION VS LEARNING 
% % -----------------------------------------------------------------------
% figure('visible', displayfig)
% scatterCorr(...
%     corr_rate_elicitation,...
%     corr_rate_learning,...
%     [0.4660    0.6740    0.1880],...
%     0.6,...
%     2,...
%     2,...
%     'w');
% ylabel('Correct choice rate learning');
% xlabel('Correct choice rate elicitation');
% saveas(gcf, 'fig/exp/pooled/corr_elicitation_learning.png');

% Normalize optimism 
%delta_alpha = delta_alpha ./ max(delta_alpha);


%------------------------------------------------------------------------
% CRT VS OPTIMISM
% -----------------------------------------------------------------------
figure('Renderer', 'painters', 'Position', [326,296,1064,691], 'visible', displayfig)
skylineplot(...
    vertcat(a1, a2), colors,...
    0, 1, 13, '' , '',...
    '');
yline(0, 'LineStyle', ':');
%saveas(gcf, sprintf('fig/exp/%s/median_outcome.png', name));

%------------------------------------------------------------------------
% CRT VS OPTIMISM
% -----------------------------------------------------------------------
figure('visible', displayfig)
scatterCorr(...
    delta_alpha,...
    crt_scores./14,...
    [0.4660    0.6740    0.1880],...
    0.6,...
    2,...
    2,...
    'w');
ylabel('CRT Score');
xlabel('\alpha_+ > \alpha_-');
saveas(gcf,'fig/exp/pooled/corr_optimism_crt.png');


%------------------------------------------------------------------------
% ELICITATION VS OPTIMISM
% -----------------------------------------------------------------------
figure('visible', displayfig)
scatterCorr(...
    delta_alpha,...
    corr_rate_elicitation,...
    [0.4660    0.6740    0.1880],...
    0.6,...
    2,...
    2,...
    'w');
xlabel('\alpha_+ > \alpha_-');
ylabel('Correct choice rate elicitation');
saveas(gcf, 'fig/exp/pooled/corr_optimism_elicitation.png');