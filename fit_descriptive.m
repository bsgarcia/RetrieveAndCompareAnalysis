%% --------------------------------------------------------------------
%% This script finds the best fitting model/parameters               
%% --------------------------------------------------------------------
% 1: Prelec PWF
% 2: Prelec PWF -/+
%% TODO: check mapping sym/Qvalue/cont  for fitting
% --------------------------------------------------------------------
close all
clear all

addpath './fit'
addpath './plot'
addpath './data'
addpath './'

% --------------------------------------------------------------------
% Set parameters
% --------------------------------------------------------------------
conf = 'block';
feedback = 'complete_mixed';

whichmodel = [1, 2, 3];
% flatten data and treat it as one subject
flatten = 1 ;

displaywin = 'on';
catch_threshold = 1.;
rtime_threshold = 100000;

folder = 'data/';
data_filename = sprintf('%s_%s', conf, feedback);
fit_folder = 'data/fit/';
fit_filename = sprintf('%s_descriptive_%d', data_filename, flatten);
colors = [0.3963    0.2461    0.3405;...
    1 0 0;...
    0.7875    0.1482    0.8380;...
    0.4417    0.4798    0.7708;...
    0.5992    0.6598    0.1701;...
    0.7089    0.3476    0.0876;...
    0.2952    0.3013    0.3569;...
    0.1533    0.4964    0.2730;...
    0.8500 0.3250 0.0980;...
    0 0.4470 0.7410];
blue_color = [0.0274 0.427 0.494];


% --------------------------------------------------------------------
% Load experiment data
% --------------------------------------------------------------------
[data, sub_ids, idx] = DataExtraction.get_data(...
    sprintf('%s%s', folder, data_filename));

% --------------------------------------------------------------------
% Set exclusion criteria
% --------------------------------------------------------------------
n_best_sub = 0;
optimism = 0;
allowed_nb_of_rows = [258, 288, 255, 285, 376, 470];

%------------------------------------------------------------------------
% Exclude subjects and retrieve data 
%------------------------------------------------------------------------
[sub_ids, corr_catch] = DataExtraction.exclude_subjects(...
    data, sub_ids, idx, catch_threshold, rtime_threshold,...
    n_best_sub, allowed_nb_of_rows);

[corr, cho, out, p1, p2, ev1, ev2, ctch, cont1, cont2] = ...
    DataExtraction.extract_elicitation_data(...
    data, sub_ids, idx, 0);

%flatten 
if flatten
    cho = reshape(cho, [], 1)';
    p1 = reshape(p1, [], 1)';
    p2 = reshape(p2, [], 1)';
    
    ntrials = length(cho);
    nsub = 1;
else 
    ntrials = size(cho, 2);
    nsub = size(cho, 1);
end



% --------------------------------------------------------------------
% Run
% --------------------------------------------------------------------
fprintf('N = %d \n', length(sub_ids));
fprintf('NTrial = %d \n', ntrials);
fprintf('Catch threshold = %.2f \n', catch_threshold);
fprintf('Fit filename = %s \n', fit_filename);


try
    data = load(sprintf('%s%s', fit_folder, fit_filename));
    ll = data.data('ll');
    parameters = data.data('parameters');  %% Optimization parameters 
    answer = question(...
    'There is already a fit file, would you like to use it or to rerun analyses (the old file will be replaced)',...
        'Use existent fit file', 'Rerun and erase');
    if strcmp(answer, 'Rerun and erase')
            [ll, parameters] = runfit(...
        whichmodel,...
        cho,...
        p1,...
        p2,...
        ntrials,...
        nsub,...
        fit_folder,...
        fit_filename);
    end
%         
catch
    [ll, parameters] = runfit(...
        whichmodel,...
        cho,...
        p1,...
        p2,...
        ntrials,...
        nsub,...
        fit_folder,...
        fit_filename);
end


% --------------------------------------------------------------------
% Plot PWF
% --------------------------------------------------------------------
figure('visible', displaywin)
x = linspace(0, 1, 100);
plot(x, x, 'Color', 'k', 'LineStyle', '--', 'LineWidth', 1.2, 'HandleVisibility','off');

for i = 1:size(parameters, 1)
    y_exp = exp(-parameters(i, 1, 1).*(-log(x)).^parameters(i, 2, 1));
    y_desc = exp(-parameters(i, 3, 1).*(-log(x)).^parameters(i, 4, 1));
    hold on
    pl1 = plot(x, y_desc, 'Color', colors(9, :), 'LineWidth', 1.9);
    hold on
    pl2 = plot(x, y_exp, 'Color', blue_color,  'LineWidth', 1.9);
    if size(parameters, 1) > 1
        pl1.Color(4) = 0.2;
        pl2.Color(4) = 0.2;
    end
end

legend({'Description', 'Experience'},'Location', 'southeast');
xlabel('p');
ylabel('W(p)');
%title('Prelec PWF');
set(gca, 'FontSize', 21);
box off

saveas(gcf, sprintf('fig/fit/%s/%s.png', fit_filename, 'prelec'));
return
figure('visible', displaywin)
x = linspace(0, 1, 100);
plot(x, x, 'Color', 'k', 'LineStyle', '--', 'LineWidth', 0.8, 'HandleVisibility','off');

for i = 1:size(parameters, 1)
    y_exp = exp(-parameters(i, 1, 3).*(-log(x)).^parameters(i, 2, 3));
    y_desc = exp(-parameters(i, 3, 3).*(-log(x)).^parameters(i, 4, 3));
    hold on
    pl1 = plot(x, y_desc, 'Color', colors(9, :), 'LineWidth', 1.5);
    hold on
    pl2 = plot(x, y_exp, 'Color', colors(10, :),  'LineWidth', 1.5);
    if size(parameters, 1) > 1
        pl1.Color(4) = 0.2;
        pl2.Color(4) = 0.2;
    end
end
legend({
    sprintf('Experience, \\lambda=%.2f', parameters(1, 9, 3)),...
    sprintf('Description, \\lambda=%.2f', parameters(1, 10, 3))...
   },'Location', 'southeast');
xlabel('p');
ylabel('W(p)');
title('Prelec Probability Weighting Function');
box off
saveas(gcf, sprintf('fig/fit/%s/%s.png', fit_filename, 'prelec_loss'))
% figure('visible', displaywin)
% %title('Prelec (1998)');
% x = linspace(0, 1, 100);
% y_exp = exp(-parameters(1, 1).*(-log(x)).^parameters(2, 1)) -  exp(-parameters(3, 1).*(-log(x)).^parameters(4, 1));
% %y_desc = x - exp(-parameters(3, 1).*(-log(x)).^parameters(4, 1));
% hold on
% plot(x, y_exp, 'LineWidth', 1.5);
% hold on
% plot(x, zeros(length(x), 1), 'Color', 'k', 'LineStyle', ':');
% %hold on
% %plot(x, y_desc, 'Color', colors(10, :),  'LineWidth', 1.5);
% %legend('Experience', 'Descr%     if size(parameters, 1) > 1
%         pl1.Color(4) = 0.2;
%         pl2.Color(4) = 0.2;
%     end
%iption');
% xlabel('real p');
% ylabel('W_{exp}(p) - W_{desc}(p) ');

if flatten
    figure('visible', displaywin)
    titles = {'Gain', 'Loss'};
    params = {
        parameters(1, 1:4, 2),...
        parameters(1, 5:8, 2)...
    };
    x = linspace(0, 1, 100);
    y_exp = exp(-params{1}(1).*(-log(x)).^params{1}(2));
    y_desc = exp(-params{1}(3).*(-log(x)).^params{1}(4));
    plot(x, x, 'Color', 'k', 'LineStyle', '--', 'LineWidth', 0.8, 'HandleVisibility','off');
    hold on
    plot(x, y_exp, 'Color', colors(9, :), 'LineWidth', 1.5);
    hold on
    plot(x, y_desc, 'Color', colors(10, :), 'LineWidth', 1.5);
    y_exp = exp(-params{2}(1).*(-log(x)).^params{2}(2));
    y_desc = exp(-params{2}(3).*(-log(x)).^params{2}(4));
    title('Prelec PWF Gain and Loss');
    hold on
    plot(x, y_exp, 'Color', colors(9, :), 'LineWidth', 1.5, 'LineStyle', '--');
    hold on
    plot(x, y_desc, 'Color', colors(10, :), 'LineWidth', 1.5, 'LineStyle', '--');
    legend(...
        {'Gain Experience', 'Gain Description', 'Loss Experience',...
        'Loss Description'}, 'Location', 'southeast');
    xlabel('real p');
    ylabel('W(p)');
    box off
    saveas(gcf, sprintf('fig/fit/%s/%s.png', fit_filename, 'g_and_l_prelec'));
end

% --------------------------------------------------------------------
% MODEL SELECTION PROCEDURE  
% --------------------------------------------------------------------
% Compute information criteria
% --------------------------------------------------------------------
i = 0;
nfpm = [4, 8, 6];

for n = whichmodel
    i = i + 1;
    bic(i, :) = -2 * -ll(:, n) + nfpm(n) * log(ntrials);
    aic(i, :)= -2 * -ll(:, n) + 2 * nfpm(n);
end

% --------------------------------------------------------------------
% Model competition
% --------------------------------------------------------------------
figNames = {'AIC', 'BIC'};
i = 0;
for criterium = {aic, bic}
    i = i + 1;

    %options.modelNames = models{whichmodel};
    options.figName = figNames{i};
    if strcmp(displaywin, 'off')
        options.DisplayWin = 1;
    end
   
    VBA_groupBMC(-cell2mat(criterium), options);
    
    saveas(gcf, sprintf('fig/fit/%s/%s.png', fit_filename, figNames{i}));
end

% --------------------------------------------------------------------
% FUNCTIONS USED IN THIS SCRIPT
% --------------------------------------------------------------------
function [ll, parameters] = runfit(whichmodel, cho, p1, p2, ntrials, nsub, folder, fit_filename)

    options = optimset(...
        'Algorithm',...
        'interior-point',...
        'Display', 'off',...
        'MaxIter', 10000,...
        'MaxFunEval', 10000);

    w = waitbar(0, 'Fitting');
        
    j = 0;
    for sub = 1:nsub
        waitbar(...
            sub/nsub,...  % Compute progression
            w,...
            sprintf('%s %d', 'Fitting sub', sub)...
            );
        
        for model = whichmodel



            [
                p,...
                l,...
                rep,...
                output,...
                lmbda,...
                grad,...
                hess,...
                ] = fmincon(...
                @(x) prelec(...
                x,...
                cho(sub, :),...
                p1(sub, :),...
                p2(sub, :),...
                model,  ntrials),...
                [ones(8, 1) .* 0.01; [0, 0]'],...
                [], [], [], [],...
                [ones(8, 1) .* 0.01; [-inf, -inf]'],...
                [ones(8, 1) .* 2.5; [inf, inf]'],...
                [],...
                options...
                );
            parameters(sub, :, model) = p;
            ll(sub, model) = l;
            j = j + 1;

        end
    end
    %% Save the data
    data = containers.Map({'parameters', 'll'},...
        {parameters, ll});
    save(sprintf('%s%s', folder, fit_filename), 'data');
    close(w);
    
end

% --------------------------------------------------------------------
function parametersfitbarplot(parameters, nmodel, whichmodel, models) 
    % %% to correct
    nfpm = [3, 4, 4, 4, 4, 5, 7, 4];
    parameters(:, 1, :) = 1/parameters(:, 1, :);
    y = zeros(nmodel, max(nfpm(whichmodel)));
    i = 0;
    for model = whichmodel
        i = i + 1;
        switch model
            case 1
                y(i, 1:nfpm(model), 1) = mean(parameters(:, [1, 2, 4], model), 1);
                s(i, 1:nfpm(model), 1) = sem(parameters(:, [1, 2, 4], model));
            case {2, 3, 7}
                y(i, 1:nfpm(model), 1) = mean(parameters(:, 1:nfpm(model), model), 1);
                s(i, 1:nfpm(model), 1) = sem(parameters(:, 1:nfpm(model), model));
            case 4
                y(i, 1:nfpm(model), 1) = mean(parameters(:, [1, 2, 4, 5], model), 1);
                s(model, 1:nfpm(model), 1) = sem(parameters(:, [1, 2, 4, 5], model));
            case 5
                y(i, 1:nfpm(model), 1) = mean(parameters(:, [1, 2, 4, 6], model), 1);
                s(i, 1:nfpm(model), 1) = sem(parameters(:, [1, 2, 4, 6], model));
            case 6
                y(i, 1:nfpm(model), 1) = mean(parameters(:, [1, 2, 4, 6, 7], model), 1);
                s(i, 1:nfpm(model), 1) = sem(parameters(:, [1, 2, 4, 6, 7], model));
            case 8 
                y(i, 1:nfpm(model), 1) = mean(parameters(:, [1, 8, 9], model), 1);
                s(i, 1:nfpm(model), 1) = sem(parameters(:, [1, 8, 9], model));
        end
    end
    figure
    hBar = bar(y, 'FaceAlpha', 0.7);
    set(gca, 'XTickLabels', {models{whichmodel}});
    hold on

    % Finding the number of groups and the number of bars in each group
    ngroups = size(y, 2);
    nbars = size(y, 1);
    % Calculating the width for each bar group
    groupwidth = min(0.8, nbars/(nbars + 1.5));
    % Set the position of each error bar in the centre of the main bar
    % Based on barweb.m by Bolu Ajiboye from MATLAB File Exchange
    
    for i = 1:nbars
        % Calculate center of each bar
        x = (1:ngroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*nbars);
        errorbar(x, y(:, i, 1), s(:, i, 1), 'k', 'linestyle', 'none', 'linewidth', 1);
    end
    
    
    box off
end


function matrix = computeposterior(criterion, nmodel, models, whichmodel)
    %set options
    options.modelNames = {models{whichmodel}};
    options.DisplayWin = true;

    [posterior, outcome] = VBA_groupBMC(-criterion'./2, options);
    for fittedmodel = 1:nmodel
        matrix(fittedmodel, 1, 1) = mean(posterior.r(fittedmodel, :));
    end
end

function violinplot_param_comparison(parameters, param_idx, model_idx, labels, models, ymax, colors)
    nsub = size(parameters, 1);
    params = {};
    for i = 1:length(param_idx)
        y(i, :) = reshape(parameters(:, param_idx(i), model_idx), [], 1);
        param_labels{i} = labels{param_idx(i)};
    end
    skylinemedianplot(...
        y, colors,...
        min(y, [], 'all')-0.08, max(y, [], 'all')+0.08, 20,  models{model_idx},'',...
        '', []...
    );
    xticklabels(param_labels);

end

function barplot_param_comparison(parameters, param_idx, model_idx, labels, models, ymax)
    %hold on
    nsub = size(parameters, 1);
    for i = 1:length(param_idx)
        y(i, :) = reshape(parameters(:, param_idx(i), model_idx), [], 1);
        means(i) = mean(y(i, :));
        errors(i) = sem(y(i, :));
       % param_labels{i} = labels{param_idx(i)};
    end
    b = bar(means, 'EdgeColor', 'black');
    hold on
    e = errorbar(means, errors, 'Color', 'black', 'LineWidth', 2, 'LineStyle', 'none');
    %hold off
    box off
    b.FaceColor = 'flat';
    b.CData(1, :) = [107/255 196/255 103/255];
    b.CData(2, :) = [149/255 230/255 146/255];
    if length(param_idx) == 3
        b.CData(3, :) = [149/255 240/255 146/255];
        set(gca, 'XTickLabel',{labels{1}, labels{2}, labels{3}});
    elseif length(param_idx) == 4
        b.CData(3, :) = [149/255 240/255 146/255];
        b.CData(4, :) = [60/255 240/255 146/255];
        set(gca, 'XTickLabel',{labels{1},...
            labels{2}, labels{3}, labels{4}});
    else
        set(gca, 'XTickLabel',{labels{1}, labels{2}});
    end
    
    set(gca, 'FontSize', 20);
    
    %xticklabels(param_labels);

    title(models{model_idx});
    y1 = ylim;
    ax1 = gca;

    for i = 1:length(param_idx)   

        ax(i) = axes('Position',get(ax1,'Position'),'XAxisLocation','top',...
         'YAxisLocation','right','Color','none','XColor','k','YColor','k');
          
        hold(ax(i), 'all');
        
        X = ones(1, nsub)-Shuffle(linspace(-0.15, 0.15, nsub));
        s = scatter(...
            X + (i-1),...
            y(i, :),...
             'filled', 'Parent', ax1, 'MarkerFaceAlpha', 0.75, 'MarkerEdgeAlpha', 1,...
             'MarkerFaceColor', [107/255 220/255 103/255],...
             'MarkerEdgeColor', 'w');
        set(gca, 'xtick', []);
        set(gca, 'box', 'off');
        set(ax(i), 'box', 'off');
        
        set(gca, 'ytick', []);
        box off
    end
    uistack(e, 'top');
    box off;
end
