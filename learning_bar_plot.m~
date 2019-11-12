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
% get parameters
%------------------------------------------------------------------------
ncond = max(data(:, 13));
nsession = max(data(:, 20));

sim = 1;
choice = 2;

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

[cho1, out1, cfout1, corr1, con1, p11, p21, rew] = ...
    DataExtraction.extract_learning_data(data, sub_ids, exp);


%------------------------------------------------------------------------
% Compute corr choice rate learning
%------------------------------------------------------------------------
corr_rate_learning = zeros(size(corr1, 1), 4);

for sub = 1:size(corr1, 1)
    for j = 1:4
        d = corr1(sub, con1(sub, :) == j);
        corr_rate_learning(sub, j) = mean(d);
    end
end
mn = mean(corr_rate_learning, 1);
err = std(corr_rate_learning, 1, 1)/sqrt(size(corr_rate_learning, 2));
nsub = size(corr1, 1);

figure('Renderer', 'painters',...
    'Position', [927,131,726,447], 'visible', displaywin)
ylabel('Correct choice rate');

b = bar(mn, 'EdgeColor', 'w', 'FaceAlpha', 0.6, 'FaceColor', 'flat');
hold on
b.CData(:, :) = blue_color_gradient(flip(2:2:9), :);
ax1 = gca;
set(gca, 'XTickLabel', {'90/10', '80/20', '70/30', '60/40'});
ylim([0, 1.07])
ylabel('Correct choice rate');
e = errorbar(1:4, mn, err, 'LineStyle', 'none',...
   'LineWidth', 2.5, 'Color', 'k', 'HandleVisibility','off');
set(gca, 'Fontsize', 23);

for i = 1:4
    ax(i) = axes('Position',get(ax1,'Position'),'XAxisLocation','top',...
        'YAxisLocation','right','Color','none','XColor','k','YColor','k');
    
    hold(ax(i), 'all');
    
    X = ones(1, nsub)-Shuffle(linspace(-0.15, 0.15, nsub));
    s = scatter(...
        X + (i-1),...
        corr_rate_learning(:, i),...
        'filled', 'Parent', ax1, 'MarkerFaceAlpha', 0.75,...
        'MarkerEdgeAlpha', 1,...
        'MarkerFaceColor', b.CData(i, :),...
        'MarkerEdgeColor', 'w');
    box off
    
     set(gca, 'xtick', []);
     set(gca, 'box', 'off');
     set(ax(i), 'box', 'off');
    
    set(gca, 'ytick', []);
    ylim([0, 1.15]);
    
    box off
end    
box off
uistack(e, 'top');


box off
hold off
ylim([0, 1.15]);
box off
saveas(gcf, sprintf('fig/exp/%s/learning_bar_plot.png', name));



