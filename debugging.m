close all
clear all

addpath './'
addpath './plot'

%------------------------------------------------------------------------
% Set parameters
%------------------------------------------------------------------------
conf = 'block';
feedback = 'complete_mixed';
folder = 'data';
name = sprintf('%s_%s', conf, feedback);
optimism = 0;
rtime_threshold = 100000;
catch_threshold = 1;
n_best_sub = 0;
allowed_nb_of_rows = [258, 288, 255, 285, 376, 470];
displaywin = 'on';
colors = [0.3963    0.2461    0.3405;...
    1 0 0;...
    0.7875    0.1482    0.8380;...
    0.4417    0.4798    0.7708;...
    0.5992    0.6598    0.1701;...
    0.7089    0.3476    0.0876;...
    0.2952    0.3013    0.3569;...
    0.1533    0.4964    0.2730];
blue_color = [0.0274 0.427 0.494];
blue_color_min = [0 0.686 0.8];

% create a default color map ranging from blue to dark blue
len = 8;
blue_color_gradient = zeros(len, 3);
blue_color_gradient(:, 1) = linspace(blue_color_min(1),blue_color(1),len)';
blue_color_gradient(:, 2) = linspace(blue_color_min(2),blue_color(2),len)';
blue_color_gradient(:, 3) = linspace(blue_color_min(3),blue_color(3),len)';


%-----------------------------------------------------------------------

%------------------------------------------------------------------------
[data, sub_ids, exp, sim] = DataExtraction.get_data(...
    sprintf('%s/%s', folder, name));

%------------------------------------------------------------------------
% Exclude subjects and retrieve data
%------------------------------------------------------------------------
[sub_ids, corr_catch] = DataExtraction.exclude_subjects(...
    data, sub_ids, exp, catch_threshold, rtime_threshold, n_best_sub,...
    allowed_nb_of_rows...
    );

nsub = length(sub_ids);
fprintf('N = %d \n', nsub);
fprintf('Catch threshold = %.2f \n', catch_threshold);

  
[corr1, cho1, out2, p1, p2, ev1, ev2, ctch, cont1, cont2, dist] = ...
                DataExtraction.extract_elicitation_data(data, sub_ids, exp, 0);

[corr2, cho2, out2, p1, p2, b, c, ctch, cont1, cont2, dist] = ...
                DataExtraction.extract_sym_vs_sym_post_test(data, sub_ids, exp);
            
for sub = 1:size(corr1, 1)
    mask_equal_ev = ev1(sub, :) ~= ev2(sub, :);
    mask_no_easy = ismember(ev2(sub, :), [-1, 1]);
    d = corr1(sub, logical(mask_equal_ev.*mask_no_easy));
    corr_rate_lot(sub) = mean(d);
end

corr_rate_sym = mean(corr2, 2);

figure
skylineplot(...
    [corr_rate_sym, corr_rate_lot']',...
    blue_color_gradient([2, 8], :),...
    -0.08,...
    1.08,...
    18,...
    '', '', 'Correct choice rate',  {'Exp. vs Exp', 'Desc. vs Exp.'}, 0 ...
);
saveas(gcf, sprintf('fig/exp/%s/lot_sym_vs_sym_sym_correct_choice_rate.png', name));

% mn1 = mean(corr_rate_learning);
% mn2 = mean(corr_rate_elicitation);
% mn = [mn1, mn2];
% err1 = std(corr_rate_learning, 1, 1)/sqrt(size(corr_rate_learning, 1));
% err2 = std(corr_rate_elicitation, 1, 2)/sqrt(size(corr_rate_elicitation, 2));
% err = [err1, err2];
% figure('Renderer', 'painters',...
%     'Position', [927,131,726,447], 'visible', displaywin)
% ylabel('Correct choice rate');
% 
% b = bar(mn, 'EdgeColor', 'w', 'FaceAlpha', 0.6, 'FaceColor', 'flat');
% hold on
% b.CData(:, :) = blue_color_gradient([2, 8], :);
% ax1 = gca;
% set(gca, 'XTickLabel', {'Exp. vs Exp', 'Desc. vs Exp.'});
% ylim([0, 1.07])
% ylabel('Correct choice rate');
% e = errorbar(mn, err, 'LineStyle', 'none',...
%    'LineWidth', 2.5, 'Color', 'k', 'HandleVisibility','off');
% set(gca, 'Fontsize', 18);
% 
% for i = 1:2
%     ax(i) = axes('Position',get(ax1,'Position'),'XAxisLocation','top',...
%         'YAxisLocation','right','Color','none','XColor','k','YColor','k');
%     
%     hold(ax(i), 'all');
%     if (i == 1)
%         d = corr_rate_learning;
%     else
%         d = corr_rate_elicitation;
%     end
%     X = ones(1, nsub)-Shuffle(linspace(-0.15, 0.15, nsub));
%     s = scatter(...
%         X + (i-1),...
%         d,...
%         'filled', 'Parent', ax1, 'MarkerFaceAlpha', 0.75,...
%         'MarkerEdgeAlpha', 1,...
%         'MarkerFaceColor', b.CData(i, :),...
%         'MarkerEdgeColor', 'w');
%     box off
%     
%      set(gca, 'xtick', []);
%      set(gca, 'box', 'off');
%      set(ax(i), 'box', 'off');
%     
%     set(gca, 'ytick', []);
%     ylim([0, 1.15]);
%     
%     box off
% end    
% box off
% uistack(e, 'top');
% 
% 
% box off
% hold off
% ylim([0, 1.15]);
% box off

