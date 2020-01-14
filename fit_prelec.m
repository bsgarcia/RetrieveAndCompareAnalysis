% --------------------------------------------------------------------
% This script finds the best fitting model/parameters               
% --------------------------------------------------------------------
% 1: Prelec PWF
% 2: Prelec PWF -/+
% % 3: loss aversion
% --------------------------------------------------------------------
close all
clear all

init;

% --------------------------------------------------------------------
% Set parameters
% --------------------------------------------------------------------
exp_num = 1;
for exp_name = filenames
    
    if ismember(exp_num, [5, 6, 7])
       session = [0, 1];
    else
       session = 0;
    end
    
    %subplot(2, 3, exp_num);
    name = char(exp_name);
    data = d.(name).data;
    sub_ids = d.(name).sub_ids;
    
    [corr, cho, out2, p1, p2, ev1, ev2, ctch, cont1, cont2, dist] = ...
        DataExtraction.extract_sym_vs_lot_post_test(...
            data, sub_ids, idx, session);
    
    nsub = size(cho, 1);
    
    flatten = 1;

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

    fit_filename = sprintf('prelec_exp_%d', exp_num);
    
    try
        data = load(sprintf('%s%s', fit_folder, fit_filename));
        ll = data.data('ll');
        parameters = data.data('parameters');  %% Optimization parameters 
        pp(exp_num, :, :) = parameters(1, :, :);
        answer = question(...
        'There is already a fit file, would you like to use it or to rerun analyses (the old file will be replaced)',...
            'Use existent fit file', 'Rerun and erase');
        if strcmp(answer, 'Rerun and erase')
                [ll, parameters(exp_num, :, :, :)] = runfit(...
            [1, 3],...
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
        [ll, parameters(exp_num, :, :, :)] = runfit(...
            [1, 3],...
            cho,...
            p1,...
            p2,...
            ntrials,...
            nsub,...
            fit_folder,...
            fit_filename);
    end
    
    exp_num = exp_num + 1;
end


% --------------------------------------------------------------------
% Plot PWF
% --------------------------------------------------------------------
%i = exp_num;
figure('Position', [1,1,900,600]);
x = linspace(0, 1, 100);
    plot(x, x, 'Color', 'k', 'LineStyle', '--',...
        'LineWidth', 1.2, 'HandleVisibility','off');

for i = 1:exp_num-1
     
    y_exp = exp(-pp(i, 1, 1).*(-log(x)).^pp(i, 2, 1));
    y_desc = exp(-pp(i, 3, 1).*(-log(x)).^pp(i, 4, 1));
    hold on
    pl1 = plot(x, y_desc, 'Color', orange_color, 'LineWidth', 1.9);
    hold on
    pl2 = plot(x, y_exp, 'Color', blue_color,  'LineWidth', 1.9);
    hold on
    
    pl1.Color(4) = .5;
    pl2.Color(4) = .5;
    
    %clear y_exp y_desc
    
end

y_exp = exp(mean(-pp(:, 1, 1)).*(-log(x)).^mean(pp(:, 2, 1)));
y_desc = exp(mean(-pp(:, 3, 1)).*(-log(x)).^mean(pp(:, 4, 1)));
hold on
pl1 = plot(x, y_desc, 'Color', orange_color, 'LineWidth', 3);
hold on
pl2 = plot(x, y_exp, 'Color', blue_color,  'LineWidth', 3);
hold on
legend({'Description', 'Experience'},'Location', 'southeast');
xlabel('p');
ylabel('W(p)');
set(gca, 'FontSize', 21);
box off
     
set(gca,'TickDir','out')
title(sprintf('All Exp.', exp_num));

mkdir('fig/exp', 'prelec');
saveas(gcf, sprintf('fig/exp/prelec/all.png', exp_num));

% --------------------------------------------------------------------
% Plot PWF Loss Aversion
% --------------------------------------------------------------------
figure('Position', [1,1,900,600]);
x = linspace(0, 1, 100);
    plot(x, x, 'Color', 'k', 'LineStyle', '--',...
        'LineWidth', 1.2, 'HandleVisibility','off');

for i = 1:exp_num-1
     
    y_exp = exp(-pp(i, 1, 3).*(-log(x)).^pp(i, 2, 3));
    y_desc = exp(-pp(i, 3, 3).*(-log(x)).^pp(i, 4, 3));
    hold on
    pl1 = plot(x, y_desc, 'Color', orange_color, 'LineWidth', 1.9);
    hold on
    pl2 = plot(x, y_exp, 'Color', blue_color,  'LineWidth', 1.9);
    hold on
    
    pl1.Color(4) = .5;
    pl2.Color(4) = .5;
    
    %clear y_exp y_desc
    
end

y_exp = exp(mean(-pp(:, 1, 3)).*(-log(x)).^mean(pp(:, 2, 3)));
y_desc = exp(mean(-pp(:, 3, 3)).*(-log(x)).^mean(pp(:, 4, 3)));
hold on
pl1 = plot(x, y_desc, 'Color', orange_color, 'LineWidth', 3);
hold on
pl2 = plot(x, y_exp, 'Color', blue_color,  'LineWidth', 3);
hold on
legend({
        sprintf('Description, \\lambda=%.2f', mean(pp(:, 9, 3))),...
        sprintf('Experience, \\lambda=%.2f', mean(pp(:, 10, 3)))...
       },'Location', 'southeast');
xlabel('p');
ylabel('W(p)');
set(gca, 'FontSize', 21);
box off
     
set(gca,'TickDir','out')
title(sprintf('All Exp.', exp_num));

mkdir('fig/exp', 'prelec');
saveas(gcf, sprintf('fig/exp/prelec/all_loss_aversion.png', exp_num));

%     
%     figure('Position', [1,1,900,600]);
%     x = linspace(0, 1, 100);
%     plot(x, x, 'Color', 'k', 'LineStyle', '--',...
%         'LineWidth', 0.8, 'HandleVisibility','off');
% 
%     y_exp = exp(-parameters(i, 1, 3).*(-log(x)).^parameters(i, 2, 3));
%     y_desc = exp(-parameters(i, 3, 3).*(-log(x)).^parameters(i, 4, 3));
%     hold on
%     pl1 = plot(x, y_desc, 'Color', orange_color, 'LineWidth', 1.9);
%     hold on
%     pl2 = plot(x, y_exp, 'Color', blue_color,  'LineWidth', 1.9);
% 
%     legend({
%         sprintf('Description, \\lambda=%.2f', parameters(1, 9, 3)),...
%         sprintf('Experience, \\lambda=%.2f', parameters(1, 10, 3))...
%        },'Location', 'southeast');
%     xlabel('p');
%     ylabel('W(p)');
%     title(sprintf('Exp. %d', exp_num));
%         set(gca, 'FontSize', 21);
% 
%     box off
%     
%     set(gca,'TickDir','out')
% 
%     mkdir('fig/exp', 'prelec');
%     saveas(gcf, sprintf('fig/exp/prelec/fig_loss_aversion_exp_%d.png', exp_num));
% 
%     exp_num = exp_num + 1;

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

% if flatten
%     figure('visible', displaywin)
%     titles = {'Gain', 'Loss'};
%     params = {
%         parameters(1, 1:4, 2),...
%         parameters(1, 5:8, 2)...
%     };
%     x = linspace(0, 1, 100);
%     y_exp = exp(-params{1}(1).*(-log(x)).^params{1}(2));
%     y_desc = exp(-params{1}(3).*(-log(x)).^params{1}(4));
%     plot(x, x, 'Color', 'k', 'LineStyle', '--', 'LineWidth', 0.8, 'HandleVisibility','off');
%     hold on
%     plot(x, y_exp, 'Color', colors(9, :), 'LineWidth', 1.5);
%     hold on
%     plot(x, y_desc, 'Color', colors(10, :), 'LineWidth', 1.5);
%     y_exp = exp(-params{2}(1).*(-log(x)).^params{2}(2));
%     y_desc = exp(-params{2}(3).*(-log(x)).^params{2}(4));
%     title('Prelec PWF Gain and Loss');
%     hold on
%     plot(x, y_exp, 'Color', colors(9, :), 'LineWidth', 1.5, 'LineStyle', '--');
%     hold on
%     plot(x, y_desc, 'Color', colors(10, :), 'LineWidth', 1.5, 'LineStyle', '--');
%     legend(...
%         {'Gain Experience', 'Gain Description', 'Loss Experience',...
%         'Loss Description'}, 'Location', 'southeast');
%     xlabel('real p');
%     ylabel('W(p)');
%     box off
%     saveas(gcf, sprintf('fig/fit/%s/%s.png', fit_filename, 'g_and_l_prelec'));
% end
% 
% % --------------------------------------------------------------------
% % MODEL SELECTION PROCEDURE  
% % --------------------------------------------------------------------
% % Compute information criteria
% % --------------------------------------------------------------------
% i = 0;
% nfpm = [4, 8, 6];
% 
% for n = whichmodel
%     i = i + 1;
%     bic(i, :) = -2 * -ll(:, n) + nfpm(n) * log(ntrials);
%     aic(i, :)= -2 * -ll(:, n) + 2 * nfpm(n);
% end
% 
% % --------------------------------------------------------------------
% % Model competition
% % --------------------------------------------------------------------
% figNames = {'AIC', 'BIC'};
% i = 0;
% for criterium = {aic, bic}
%     i = i + 1;
% 
%     %options.modelNames = models{whichmodel};
%     options.figName = figNames{i};
%     if strcmp(displaywin, 'off')
%         options.DisplayWin = 1;
%     end
%    
%     VBA_groupBMC(-cell2mat(criterium), options);
%     
%     saveas(gcf, sprintf('fig/fit/%s/%s.png', fit_filename, figNames{i}));
% end

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
                [ones(8, 1) .* 0.01; [0.01, 0.01]'],...
                [ones(8, 1) .* 3; [10, 10]'],...
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
