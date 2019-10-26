%% --------------------------------------------------------------------
%% This script finds the best fitting model/parameters               
%% --------------------------------------------------------------------
% 1: basic df=2
% 2: asymmetric neutral df=3
% 3: asymmetric pessimistic df=3
% 4: priors df=3
% 5: impulsive perseveration df=3
% 6: gradual perseveration df=3
% 7: full df=5
% 8: Bayesian df=3
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
feedback = 'complete';
fit_counterfactual = 1;
fit_elicitation = 0;

whichmodel = [1, 2, 5];
displaywin = 'on';
catch_threshold = 1.;
rtime_threshold = 100000;

folder = 'data/';
data_filename = sprintf('%s_%s', conf, feedback);
fit_folder = 'data/fit/';
if fit_elicitation
    fit_filename = data_filename;
else
    fit_filename = sprintf('%s_0', data_filename);
end
colors = [0.3963    0.2461    0.3405;...
    1 0 0;...
    0.7875    0.1482    0.8380;...
    0.4417    0.4798    0.7708;...
    0.5992    0.6598    0.1701;...
    0.7089    0.3476    0.0876;...
    0.2952    0.3013    0.3569;...
    0.1533    0.4964    0.2730];

% --------------------------------------------------------------------
% Load experiment data
% --------------------------------------------------------------------
[data, sub_ids, idx] = DataExtraction.get_data(...
    sprintf('%s%s', folder, data_filename));

% --------------------------------------------------------------------
% Set exclusion criteria
% --------------------------------------------------------------------
n_best_sub = 0;
optimism = 1;
allowed_nb_of_rows = [258, 288, 255, 285];

%------------------------------------------------------------------------
% Exclude subjects and retrieve data 
%------------------------------------------------------------------------
[sub_ids, corr_catch] = DataExtraction.exclude_subjects(...
    data, sub_ids, idx, catch_threshold, rtime_threshold,...
    n_best_sub, allowed_nb_of_rows);

[cho1,  out1, cfout1, corr1, con1, p11, p21, rew] = ...
    DataExtraction.extract_learning_data(...
    data, sub_ids, idx);

[corr2, cho2, out2, p1, p2, ev1, ev2, ctch, cont1, cont2] = ...
    DataExtraction.extract_elicitation_data(...
    data, sub_ids, idx, 0);

% concat
cho = horzcat(cho1, cho2);
cfcho = (cho1 == 1) + 1;
con = horzcat(con1, cont1);
phase = vertcat(ones(size(con1, 2), 1), ones(size(cont1, 2), 1) .* 2);
out = out1;
cfout = cfout1;
ev = horzcat(ones(size(con1)) .* -1, ev2);

% set ntrials
ntrials = size(cho1, 2) + size(cho2, 2) * fit_elicitation;
% mapping cont/con
map = [2 4 6 8 -1 7 5 3 1];

% --------------------------------------------------------------------
% Run
% --------------------------------------------------------------------
fprintf('N = %d \n', length(sub_ids));
fprintf('NTrial = %d \n', ntrials);
fprintf('Catch threshold = %.2f \n', catch_threshold);
fprintf('Fit filename = %s \n', fit_filename);

nmodel = length(whichmodel);
subjecttot = size(cho, 1);

models = {'RW', 'RW\pm',...
    'RW\pm_{\omega^-}', 'RW_\omega', 'RW_\phi',...
    'RW_{\tau}', 'Full', 'Bayesian'};

paramlabels = {
    '\beta', '\alpha+', '\alpha-', '\omega', '\phi',...
    '\tau', '\sigma_{xi}', '\sigma_{\epsilon}', '\alpha_{U}'}; 
nparam = length(paramlabels);

try
    data = load(sprintf('%s%s', fit_folder, fit_filename));
    lpp = data.data('lpp');
    parameters = data.data('parameters');  %% Optimization parameters 
    ll = data.data('ll');
    hessian = data.data('hessian');
    answer = question(...
        'There is already a fit file, would you like to use it or to rerun analyses (the old file will be replaced)',...
        'Use existent fit file', 'Rerun and erase');
    if strcmp(answer, 'Rerun and erase')
        [parameters, ll, lpp, hessian] = runfit(...
        subjecttot,...
        nparam,...
        nmodel,...
        whichmodel,...
        con,...
        cho,...
        cfcho,...
        out,...
        cfout,...
        ev,...
        phase,...
        map,...
        fit_counterfactual,...
        ntrials,...
        fit_folder,...
        fit_filename);
    end
catch
    [parameters, ll, lpp, hessian] = runfit(...
        subjecttot,...
        nparam,...
        nmodel,...
        whichmodel,...
        con,...
        cho,...
        cfcho,...
        out,...
        cfout,...
        ev,...
        phase,...
        map,...
        fit_counterfactual,...
        ntrials,...
        fit_folder,...
        fit_filename);
    
end


% --------------------------------------------------------------------
% Plots Param and Model Comparison
% --------------------------------------------------------------------
figure('Renderer', 'painters',...
    'Position', [25,40,1886,1039], 'visible', displaywin)

if fit_counterfactual
    params = {...
        [2, 9],...
        [2, 3],... %2
        [2, 3],... % 3
        [2, 4],...% 4
        [2, 9, 5],...% 5
        [2, 9, 5, 6],...% 6
        [2, 3, 5],... % 7
        [2, 3, 5, 6] % 8
    };
paramlabels = {
    {'\alpha_{c}', '\alpha_{u}'},...
    {'\alpha_{con}', '\alpha_{dis}'},...
    {'\alpha_{con}', '\alpha_{dis}'},...
    {'\alpha_{con}', '\alpha_{dis}'},...
    {'\alpha_{c}', '\alpha_{u}', '\phi'},...
    {'\alpha_{c}', '\alpha_{u}', '\phi', '\tau'},...
    {'\alpha_{con}', '\alpha_{dis}', '\phi'}};

else
    params = {...
        [2],...
        [2, 3],... %2
        [2, 3],... % 3
        [2, 4],...% 4
        [2, 5],...% 5
        [2, 5, 6],...% 6
        [2, 3, 5],... % 7
        [2, 3, 5, 6] % 8
    };
paramlabels = {
    {'\alpha'},...
    {'\alpha_{+}', '\alpha_{-}'},...
    {'\alpha_{+}', '\alpha_{-}'},...
    {'\alpha_{+}', '\alpha_{-}'},...
    {'\alpha', '\phi'},...
    {'\alpha', '\phi', '\tau'},...
    {'\alpha_{+}', '\alpha_{-}', '\phi'}};

end
alternatives = whichmodel(1:end);
j = 0;

for i = alternatives
    j = j +1; 
    subplot(2, length(whichmodel), j)
%     violinplot_param_comparison(...
%         parameters, params{i}, i, paramlabels, models, 0.5, colors);
    barplot_param_comparison(...
       parameters, params{i}, i, paramlabels{i}, models, 0.5);
end

% --------------------------------------------------------------------
% Parameters correlations
% --------------------------------------------------------------------
bias1 = (parameters(:, 2, 2) - parameters(:, 3, 2))./...
    (parameters(:, 2, 2) + parameters(:, 3, 2)) ;
%bias2 = (parameters(:, 2, 3) - parameters(:, 3, 3)) ./...
%    (parameters(:, 2, 3) + parameters(:, 3, 3));
perse = parameters(:, 5, 5);
% tau = (parameters(:, 5, 6) .* parameters(:, 6, 6)) ./...
% (parameters(:, 5, 6) + parameters(:, 6, 6));
prior = parameters(:, 5, 4);
color = [107/255 196/255 103/255];

subplot(2, 3, 5)
scatterCorr(bias1, perse, color, 0.8, 2, 1, 'w');
if fit_counterfactual
    xlabel('\alpha_{con} > \alpha_{dis}', 'FontSize', 20);
else
    xlabel('\alpha_{+} > \alpha_{-}', 'FontSize', 20);
end

ylabel('\phi', 'FontSize', 20);
title('')
set(gca, 'Fontsize', 30);
% subplot(2, 2, 4)
% scatterCorr(bias1, tau, color, 0.5, 2, 1);
% xlabel( '\alpha+ > \alpha-', 'FontSize', 20);
% ylabel('\phi x \tau', 'FontSize', 20);
% title('')
% set(gca, 'Fontsize', 30);
saveas(gcf, sprintf('fig/fit/%s/fit_bar.png', fit_filename));

% --------------------------------------------------------------------
% MODEL SELECTION PROCEDURE  
% --------------------------------------------------------------------
% Compute information criteria
% --------------------------------------------------------------------
i = 0;
    
      %[Q1, Asy, Asy Pes, Pri,  Per, Grad. Pers, Full, Kalman]
nfpm = [2,   3,     3,     3,   3,      4,         4,    4] + ...
    ...%[Q1,               Asy, Asy Pes, Pri,  
       [fit_counterfactual, 0,   0,       0,...
    ...Per,               Grad. Pers,        Full,     Kalman]
    fit_counterfactual, fit_counterfactual,   0,         0] ;

for n = whichmodel
    i = i + 1;
    bic(i, :) = -2 * -ll(:, n) + nfpm(n) * log(ntrials);
    aic(i, :)= -2 * -ll(:, n) + 2 * nfpm(n);
    try
        me(i, :) = -lpp(:, n) + (nfpm(n)/2)*log(2*pi) - .5*log(...
        arrayfun(@(x) det(cell2mat(x)), {hessian{:, n}})');
    catch 
        me(i, :) = -lpp(:, n) + (nfpm(n)/2)*log(2*pi) - .5*log(...
        hessian(:, n));
    end
end

% --------------------------------------------------------------------
% Model competition
% --------------------------------------------------------------------
figNames = {'AIC', 'ME', 'BIC'};
i = 0;
for criterium = {aic, me, bic}
    i = i + 1;

    options.modelNames = models{whichmodel};
    options.figName = figNames{i};
    if strcmp(displaywin, 'off')
        options.DisplayWin = 1;
    end
    if strcmp('ME', figNames{i})
        VBA_groupBMC(cell2mat(criterium), options);
    else
        VBA_groupBMC(-cell2mat(criterium), options);
    end
    saveas(gcf, sprintf('fig/fit/%s/%s.png', fit_filename, figNames{i}));
end

% --------------------------------------------------------------------
% FUNCTIONS USED IN THIS SCRIPT
% --------------------------------------------------------------------
function [parameters, ll, lpp, hessian] = ...
    runfit(subjecttot, nparam, nmodel, whichmodel, con, cho, cfcho, out,...
    cfout,ev, phase, map, fit_counterfactual, ntrials, folder, fit_filename)

    parameters = zeros(subjecttot, nparam, nmodel);
    ll = zeros(subjecttot, nmodel);
    lpp = zeros(subjecttot, nmodel);
    report = zeros(subjecttot, nmodel);
    gradient = cell(subjecttot, nmodel);
    hessian = zeros(subjecttot, nmodel);
    options = optimset(...
        'Algorithm',...
        'interior-point',...
        'Display', 'off',...
        'MaxIter', 10000,...
        'MaxFunEval', 10000);

    w = waitbar(0, 'Fitting subject');
    
    for nsub = 1:subjecttot
        
        waitbar(...
            nsub/subjecttot,...  % Compute progression
            w,...
            sprintf('%s%d', 'Fitting subject ', nsub)...
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
                @(x) getlpp(...
                    x,...
                    con(nsub, :),...
                    cho(nsub, :),...
                    cfcho(nsub, :),...
                    out(nsub, :),...
                    cfout(nsub, :),...
                    ev(nsub, :),...
                    phase,...
                    map,...
                    model, fit_counterfactual, ntrials),...
                [1, .5, .5, 0, 0, .5, .15, .15, .5],...
                [], [], [], [],...
                [0, 0, 0, -1, -5,  0, 0, 0, 0],...
                [Inf, 1, 1, 1, 5, 1, 1, 1, 1],...
                [],...
                options...
                );
            parameters(nsub, :, model) = p;
            lpp(nsub, model) = l;
            report(nsub, model) = rep;
            gradient{nsub, model} = grad;
            hessian(nsub, model)= det(hess);
            
            [
                p1,...
                l1,...
                rep1,...
                grad1,...
                hess1,...
            ] = fmincon(...
                @(x) getll(...
                    x,...
                    con(nsub, :),...
                    cho(nsub, :),...
                    cfcho(nsub, :),...
                    out(nsub, :),...
                    cfout(nsub, :),...
                    ev(nsub, :),...
                    phase,...
                    map,...
                    model, fit_counterfactual, ntrials),...
                [1, .5, .5, 0, 0, .5, .15, .15, .5],...
                [], [], [], [],...
                [0, 0, 0, -1, -5,  0, 0, 0, 0],...
                [Inf, 1, 1, 1, 5, 1, 1, 1, 1],...
                [],...
                options...
                );
            ll(nsub, model) = l1;

        end
    end
    %% Save the data
    data = containers.Map({'parameters', 'lpp' 'll', 'hessian'},...
        {parameters, lpp, ll, hessian});
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
    if length(param_idx) == 3
        b.CData(2, :) = [149/255 230/255 146/255];
        
        b.CData(3, :) = [149/255 240/255 146/255];
        set(gca, 'XTickLabel',{labels{1}, labels{2}, labels{3}});
    elseif length(param_idx) == 4
        b.CData(2, :) = [149/255 230/255 146/255];

        b.CData(3, :) = [149/255 240/255 146/255];
        b.CData(4, :) = [60/255 240/255 146/255];
        set(gca, 'XTickLabel',{labels{1},...
            labels{2}, labels{3}, labels{4}});
    elseif length(param_idx) == 2
        b.CData(2, :) = [149/255 230/255 146/255];

        set(gca, 'XTickLabel',{labels{1},...
            labels{2}});
    else
        set(gca, 'XTickLabel',{labels{1}});
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
