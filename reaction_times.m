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
data_filename = sprintf('%s/%s', folder, name);

folder = 'data/';
data_filename = name;
fit_folder = 'data/fit/';
fit_filename = name;
quest_filename = sprintf('data/questionnaire_%s', name);

optimism = 0;
rtime_threshold = 30000;
catch_threshold = 1;
n_best_sub = 0;
allowed_nb_of_rows = [258, 288, 255, 285, 376, 326, 470];
displayfig = 'on';
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
len = 11;
blue_color_gradient = zeros(len, 3);
blue_color_gradient(:, 1) = linspace(blue_color_min(1),blue_color(1),len)';
blue_color_gradient(:, 2) = linspace(blue_color_min(2),blue_color(2),len)';
blue_color_gradient(:, 3) = linspace(blue_color_min(3),blue_color(3),len)';


%------------------------------------------------------------------------
[data, sub_ids, exp, sim] = DataExtraction.get_data(...
    sprintf('%s/%s', folder, data_filename));

%------------------------------------------------------------------------
% Exclude subjects and retrieve data 
%------------------------------------------------------------------------
[sub_ids] = DataExtraction.exclude_subjects(...
    data, sub_ids, exp, catch_threshold, rtime_threshold, n_best_sub,...
    allowed_nb_of_rows...
);

nsub = length(sub_ids);
fprintf('N = %d \n', nsub);
fprintf('Catch threshold = %.2f \n', catch_threshold);


%------------------------------------------------------------------------
% Plot corr P(win described cue) vs RT
%------------------------------------------------------------------------
[corr, cho, out, p1, p2, ev1, ev2, ctch, cont1, cont2, dist, rtime] = ...
    DataExtraction.extract_sym_vs_lot_post_test(data, sub_ids, exp, 0);

psym = [1:9]./10;
psym(5) = [];
plot = [0:10]./10;

figure
for i = 1:length(psym)
    subplot(4, 2, i)
    mask = logical(p1 == psym(i));
    for j = 1:length(plot)
        d(j, :) = rtime(logical(...
            mask.*logical(plot(j) == p2)...
            ));
    end
    
    skylineplot(...
        d, blue_color_gradient,...
        -0.08, 5000, 9,  psym(i), 'P(win described cue)',...
        'Reaction time (ms)', plot...
        );
    %xlim([0, 12]);
    scatterCorr(...
        reshape(repmat(plot.*10, 1, size(d, 2)), [], 1),...
        reshape(d, [], 1),...
        'w',...
        0,...
        2,...
        0,...
        'w', 1);
    clear d
    set(gca, 'FontSize', 10);

end


%------------------------------------------------------------------------
% Plot corr P(win learned cue) vs RT
%------------------------------------------------------------------------
[corr, cho, out, p1, p2, ev1, ev2, ctch, cont1, cont2, dist, rtime] = ...
    DataExtraction.extract_sym_vs_sym_post_test(data, sub_ids, exp);

clear d
figure
for i = 1:length(psym)
    
    subplot(4, 2, i)
    mask = logical(p1 == psym(i));
    
    k = 1;
    for j = 1:length(psym)
        if i ~= j
            d(k, :) = rtime(logical(...
                mask.*logical(psym(j) == p2)...
                ));
            k = k + 1;
        end
    end

    skylineplot(...
        d, blue_color_gradient,...
        -0.08, 5000, 9, psym(i), 'P(win learned cue)',...
        'Reaction time (ms)', psym(psym ~= psym(i))...
    );
    
    scatterCorr(...
        reshape(repmat(psym(psym ~= psym(i)).*10, 1, size(d, 2)), [], 1),...
        reshape(d, [], 1),...
        'w',...
        0,...
        2,...
        0,...
        'w',...
        1);
    clear d
    set(gca, 'FontSize', 10);

end

