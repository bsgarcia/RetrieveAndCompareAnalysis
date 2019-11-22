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
for conf1 = {'block', 'interleaved'}
    for feedback1 = {'complete', 'incomplete'}
        conf = conf1{:};
        feedback = feedback1{:};
        if strcmp(conf, 'interleaved') && strcmp(feedback, 'complete')
        else
            name = sprintf('%s_%s', conf, feedback);
            optimism = 1;
            rtime_threshold = 100000;
            catch_threshold = 1;
            n_best_sub = 0;
            allowed_nb_of_rows = [258, 288, 255, 285];
            displayfig = 'on';
            
            colors = [0.3963    0.2461    0.3405;...
                1 0 0;...
                0.7875    0.1482    0.8380;...
                0.4417    0.4798    0.7708;...
                0.5992    0.6598    0.1701;...
                0.7089    0.3476    0.0876;...
                0.2952    0.3013    0.3569;...
                0.1533    0.4964    0.2730];
            
            %---------------------------------------------------------------
            
            folder = 'data/';
            data_filename = name;
            fit_folder = 'data/fit/';
            fit_filename = name;
            quest_filename = sprintf('data/questionnaire_%s', name);
            
            %------------------------------------------------------------------------
            [data, sub_ids, exp, sim] = DataExtraction.get_data(...
                sprintf('%s%s', folder, data_filename));
            
            %------------------------------------------------------------------------
            % Exclude subjects and retrieve data
            %------------------------------------------------------------------------
            [sub_ids, corr_catch] = DataExtraction.exclude_subjects(...
                data, sub_ids, exp, catch_threshold, rtime_threshold, n_best_sub,...
                allowed_nb_of_rows...
                );
            
            nsub = length(sub_ids);
            fprintf('name = %s \n', name);

            fprintf('N = %d \n', nsub);
            fprintf('Catch threshold = %.2f \n', catch_threshold);
            
            [cho1, out1, cfout1, corr1, con1, p11, p21, rew] = ...
                DataExtraction.extract_learning_data(data, sub_ids, exp);
            
            [corr, cho, out2, p1, p2, ev1, ev2, ctch, cont1, cont2, dist] = ...
                DataExtraction.extract_elicitation_data(data, sub_ids, exp, 0);
            
            [corr3, cho3, out3, p13, p23, ev13, ev23, ctch3, cont13, cont23, dist3] = ...
                DataExtraction.extract_elicitation_data(data, sub_ids, exp, 2);
            
            %-------------------------------------------------------------
            % Optimism
            %-------------------------------------------------------------
            if optimism
                data2 = load(sprintf('%s%s', fit_folder, fit_filename));
                parameters = data2.data('parameters');
                d_alpha = parameters(:, 2, 2) - parameters(:, 3, 2);
                for sub = 1:size(d_alpha, 1)
                    i_opt = i_opt + 1;
                    delta_alpha(i_opt) = parameters(sub, 2, 2) - parameters(sub, 3, 2);
                    a1(i_opt) = parameters(sub, 2, 2);
                    a2(i_opt) = parameters(sub, 3, 2);
                end
            end
            %------------------------------------------------------------------------
            % Compute corr choice rate learning
            %------------------------------------------------------------------------
            %corr_rate_learning = zeros(size(corr1, 1), size(corr1, 2)/4, 4);
            
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