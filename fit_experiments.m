% --------------------------------------------------------------------
% This function finds the best fitting model/parameters               
% --------------------------------------------------------------------
% 1: basic df=2
% 2: asymmetric neutral df=3
% 3: asymmetric pessimistic df=3
% 4: priors df=3
% 5: impulsive perseveration df=3
% 6: gradual perseveration df=3
% 7: full df=5
% 8: Bayesian df=3
% --------------------------------------------------------------------
close all
clear all

addpath './fit'
addpath './data'
addpath './'

% --------------------------------------------------------------------
% Load experiment data
% --------------------------------------------------------------------
folder = 'data/';
data_filename = 'interleavedfull';
fit_folder = 'data/fit/';
fit_filename = 'interleaved';

[data, ncond, nsession, sub_ids, idx] = DataExtraction.get_parameters(...
    sprintf('%s%s', folder, data_filename));

% --------------------------------------------------------------------
% Set exclusion criteria
% --------------------------------------------------------------------
catch_threshold = 1.;
n_best_sub = 0;
allowed_nb_of_rows = [258, 288, 255, 285];

%------------------------------------------------------------------------
% Exclude subjects and retrieve data 
%------------------------------------------------------------------------
[sub_ids, corr_catch] = DataExtraction.exclude_subjects(data, sub_ids, idx,...
    catch_threshold, n_best_sub, allowed_nb_of_rows);

fprintf('N = %d \n', length(sub_ids));
fprintf('Catch threshold = %.2f \n', catch_threshold);

[cho1, out1, corr1, con1] = ...
    DataExtraction.extract_learning_data(...
    data, sub_ids, idx);

[corr2, cho2, out2, p1, p2, ev1, ev2, ctch, cont1, cont2] = ...
    DataExtraction.extract_elicitation_data(...
    data, sub_ids, idx, 0);

% concat
cho = horzcat(cho1, cho2);
con = horzcat(con1, cont1);
phase = vertcat(ones(size(con1, 2), 1), ones(size(cont1, 2), 1) .* 2);
out = out1;
ev = horzcat(ones(size(con1)) .* -1, ev2);

% mapping cont/con
map = [2 4 6 8 -1 7 5 3 1];

% --------------------------------------------------------------------
% Modifiable variables
% --------------------------------------------------------------------
whichmodel = [1, 2, 5, 6, 7];

% --------------------------------------------------------------------
% Run
% --------------------------------------------------------------------
nmodel = length(whichmodel);
subjecttot = size(cho, 1);

models = {'RW', 'RW\pm',...
    'RW\pm_{\omega^-}', 'RW_\omega', 'RW_\phi',...
    'RW_{\tau}', 'Full', 'Bayesian'};

paramlabels = {
    '\beta', '\alpha+', '\alpha-', '\omega', '\phi',...
    '\tau', '\sigma_{xi}', '\sigma_{\epsilon}'}; 
nparam = length(paramlabels);

try
    data = load(sprintf('%s%s', fit_folder, fit_filename));
    lpp = data.data('lpp');
    parameters = data.data('parameters');  %% Optimization parameters 
    ll = data.data('ll');
    hessian = data.data('hessian');
catch
    runfit(subjecttot, nparam, nmodel, whichmodel, con, cho, out, ev,...
        phase, map, fit_folder, fit_filename);
end


%parametersfitbarplot(parameters, nmodel, whichmodel, models) 

% --------------------------------------------------------------------
% Plots Param and Model Comparison
% --------------------------------------------------------------------
figure
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
alternatives = whichmodel(2:end);
j = 0;
for i = alternatives
    j = j +1; 
    subplot(2, 4, j)
    barplot_param_comparison(...
        parameters, params{i}, i, paramlabels, models, 0.5);
end

% --------------------------------------------------------------------
% Parameters correlations
% --------------------------------------------------------------------
bias1 = (parameters(:, 2, 2) - parameters(:, 3, 2))./...
    (parameters(:, 2, 2) + parameters(:, 3, 2)) ;
%bias2 = (parameters(:, 2, 3) - parameters(:, 3, 3)) ./...
%    (parameters(:, 2, 3) + parameters(:, 3, 3));
perse = parameters(:, 5, 5);
tau = (parameters(:, 5, 6) .* parameters(:, 6, 6)) ./...
(parameters(:, 5, 6) + parameters(:, 6, 6));
prior = parameters(:, 5, 4);
color = [107/255 196/255 103/255];

subplot(2, 2, 3)
scatterCorr(bias1, perse, color, 0.5, 2, 1);
xlabel('\alpha+ > \alpha-', 'FontSize', 20);
ylabel('\phi', 'FontSize', 20);
title('')
set(gca, 'Fontsize', 30);
subplot(2, 2, 4)
scatterCorr(bias1, tau, color, 0.5, 2, 1);
xlabel( '\alpha+ > \alpha-', 'FontSize', 20);
ylabel('\phi x \tau', 'FontSize', 20);
title('')
set(gca, 'Fontsize', 30);

% --------------------------------------------------------------------
% Compute information criteria
% --------------------------------------------------------------------
i = 0;
nfpm = [2, 3, 3, 3, 4, 5, 7, 4];

for n = whichmodel
    i = i + 1;
   % bic(1:85, i) = -2 * -ll(:, n) + nfpm(n) * log(96);
    bic(:, i) = -2 * -ll(:, n) + nfpm(n) * log(120);
    aic(:, i)= -2 * -ll(:, n)...
            + 2*nfpm(n);
    me(:, i) = -lpp(:, n) + (nfpm(n)/2)*log(2*pi) - (1/2)*log(...
       arrayfun(@(x) det(cell2mat(x)), {hessian{:, n}})');
    %
end
% --------------------------------------------------------------------
% figure
% bar(mean(aic, 1));
% ylabel('AIC');
%VBA_groupBMC(-aic');
VBA_groupBMC(-me');


% --------------------------------------------------------------------
% Functions
% --------------------------------------------------------------------
function runfit(subjecttot, nparam, nmodel, whichmodel, con, cho, out,...
    ev, phase, map, folder, fit_filename)

    parameters = zeros(subjecttot, nparam, nmodel);
    ll = zeros(subjecttot, nmodel);
    lpp = zeros(subjecttot, nmodel);
    report = zeros(subjecttot, nmodel);
    gradient = cell(subjecttot, nmodel);
    hessian = cell(subjecttot, nmodel);
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
                    out(nsub, :),...
                    ev(nsub, :),...
                    phase,...
                    map,...
                    model),...
                [1, .5, .5, 0, 0, .5, .15, .15],...
                [], [], [], [],...
                [0, 0, 0, -1, -5,  0, 0, 0],...
                [Inf, 1, 1, 1, 5, 1, 1, 1],...
                [],...
                options...
                );
            parameters(nsub, :, model) = p;
            lpp(nsub, model) = l;
            report(nsub, model) = rep;
            gradient{nsub, model} = grad;
            hessian{nsub, model}= hess;
            
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
                    out(nsub, :),...
                    ev(nsub, :),...
                    phase,...
                    map,...
                    model),...
                [1, .5, .5, 0, 0, .5, .15, .15],...
                [], [], [], [],...
                [0, 0, 0, -1, -5,  0, 0, 0],...
                [Inf, 1, 1, 1, 5, 1, 1, 1],...
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

function barplot_param_comparison(parameters, param_idx, model_idx, labels, models, ymax)
    %hold on
    nsub = size(parameters, 1);
    for i = 1:length(param_idx)
        y(i, :) = reshape(parameters(:, param_idx(i), model_idx), [], 1);
        means(i) = mean(y(i, :));
        errors(i) = sem(y(i, :));
    end
    b = bar(means, 'EdgeColor', 'black');
    hold on
    e = errorbar(means, errors, 'Color', 'black', 'LineWidth', 3, 'LineStyle', 'none');
    %hold off
    box off
    b.FaceColor = 'flat';
    b.CData(1, :) = [107/255 196/255 103/255];
    b.CData(2, :) = [149/255 230/255 146/255];
    if length(param_idx) == 3
        b.CData(3, :) = [149/255 240/255 146/255];
        set(gca, 'XTickLabel',{labels{param_idx(1)}, labels{param_idx(2)}, labels{param_idx(3)}});
        set(gca, 'FontSize', 25);
    elseif length(param_idx) == 4
        b.CData(3, :) = [149/255 240/255 146/255];
        b.CData(4, :) = [60/255 240/255 146/255];
        set(gca, 'XTickLabel',{labels{param_idx(1)},...
            labels{param_idx(2)}, labels{param_idx(3)}, labels{param_idx(4)}});
        set(gca, 'FontSize', 25);
    else
        set(gca, 'XTickLabel',{labels{param_idx(1)}, labels{param_idx(2)}});
        set(gca, 'FontSize', 25);
    end

    title(models{model_idx});
    y1 = ylim;
    %disp(ymin(1));
    %ylim([y1(1) - 0.01, y1(2) + 0.01]); 
    box off
    ax1 = gca;
    hold(ax1, 'all');
    set(ax1, 'box', 'off');

    for i = 1:length(param_idx)   
        box off

        ax(i) = axes('Position',get(ax1,'Position'),'XAxisLocation','top',...
         'YAxisLocation','right','Color','none','XColor','k','YColor','k');
          
        hold(ax(i), 'all');
        
        X = ones(1, nsub)-Shuffle(linspace(-0.15, 0.15, nsub));
        scatter(...
            X + (i-1),...
            y(i, :),...
             'filled', 'Parent', ax1, 'MarkerFaceAlpha', 0.5, 'MarkerEdgeAlpha', 1,...
             'MarkerFaceColor', [107/255 220/255 103/255],...
             'MarkerEdgeColor', [107/255 220/255 103/255]);
        set(gca, 'xtick', []);
        set(gca, 'box', 'off');
        set(ax(i), 'box', 'off');
        %set(ax, 'bof', 'off');
        %set(ax2, 'ytick', []);
        box off
    end
    uistack(e, 'top');
    box off;
end
