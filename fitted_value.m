% --------------------------------------------------------------------
% This script finds the best fitting Values for each exp
% then plots the article figs
% --------------------------------------------------------------------

close all
clear all

addpath './fit'
addpath './plot'
addpath './data'
addpath './'

%------------------------------------------------------------------------
% Set parameters
%------------------------------------------------------------------------

% filenames and folders
filenames = {
    'interleaved_incomplete', 'block_incomplete', 'block_complete',...
    'block_complete_mixed', 'block_complete_mixed_2s'};

folder = 'data';

% exclusion criteria
rtime_threshold = 100000;
catch_threshold = 1;
n_best_sub = 0;
allowed_nb_of_rows = [258, 288, 255, 285, 376, 470, 648, 742];

% colors
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

orange_color = [0.8500, 0.3250, 0.0980];

% display figures
displayfig = 'on';

fit_folder = 'data/fit/qvalues/';

%-------------------------------------------------------------------------
% Load Data (do cleaning stuff)
%-------------------------------------------------------------------------
[d, idx] = load_data(filenames, folder, rtime_threshold, catch_threshold, ...
    n_best_sub, allowed_nb_of_rows);

show_loaded_data(d);


%------------------------------------------------------------------------
% Plot fig 2.A
%------------------------------------------------------------------------
exp_names = {filenames{1:3}};
%plot_fitted_values_desc_vs_exp(d, idx, fit_folder, orange_color, exp_names);

exp_names = {filenames{4:5}};
plot_fitted_values_all(d, idx, fit_folder, orange_color, blue_color, exp_names);


% --------------------------------------------------------------------
% FUNCTIONS USED IN THIS SCRIPT
% --------------------------------------------------------------------
function plot_fitted_values_desc_vs_exp(d, idx, fit_folder, orange_color, exp_names)

    i = 1;
    figure('Position', [1,1,1920,1090]);
    
    for exp_name = exp_names
        
        subplot(2, 3, i);
        exp_name = char(exp_name);
        [corr1, cho, out, p1, p2, ev1, ev2, ctch, cont1, cont2, dist, rtime] = ...
            DataExtraction.extract_sym_vs_lot_post_test(...
            d.(exp_name).data, d.(exp_name).sub_ids, idx, 0);

        % set ntrials
        ntrials = size(cho, 2);
        subjecttot = length(d.(exp_name).sub_ids);
        nz = [8, 1];
        cont1(ismember(cont1, [6, 7, 8, 9])) = ...
            cont1(ismember(cont1, [6, 7, 8, 9]))-1;
        cont2 = ev2;

        [parameters, ll] = runfit(...
            subjecttot,...
            cont1,...
            cont2,...
            cho,...
            ntrials,...
            nz,...
            fit_folder,...
            exp_name);
        
        ev = [-0.8, -0.6, -0.4, -0.2, 0.2, 0.4, 0.6, 0.8];
        Y = parameters(:, 1:8)';
        X = (ones(size(parameters)) .* [1:length(ev)])';
        
        %x = linspace(min(xlim), max(yl), 10);
        brickplot(...
            Y,...
            orange_color.*ones(8, 1),...
            [-1, 1], 11,...
            sprintf('Exp. %d', i),...
            'Symbol Expected Value',...
            'Fitted value', ev, 1);
        
        yline(0, 'LineStyle', ':', 'LineWidth', 2);
        x_lim = get(gca, 'XLim');
        y_lim = get(gca, 'YLim');
        
        x = linspace(x_lim(1), x_lim(2), 10);
        y = linspace(y_lim(1), y_lim(2), 10);
        plot(x, y, 'LineStyle', '--', 'Color', 'k');
        hold on
        
        flat_X = reshape(X, [], 1);
        flat_Y = reshape(Y, [], 1);
        [rho, pvalue] = corr(flat_X, flat_Y);
        
        P(i, :) = polyfit(flat_X, flat_Y, 1);
        pY = polyval(P(i,:), flat_X);
      
        plot(flat_X, ones(size(pY)) .* pY, 'k', 'LineWidth', 1.8, 'Color', orange_color);
        test = sprintf('coeff=%d, p=%d', rho, pvalue);
        
        xPoint=x_lim;
        yPoint=y_lim;
        x=(xPoint(1,1)+xPoint(1,2))/2;
        y= y_lim(1) + 0.1;
        hold on
        text(x, y, test, 'BackgroundColor', [1 1 1]);
        
        %set(gca, 'FontSize', 25);
        %saveas(gcf, sprintf('fig/fit/%s/fitted_value.png', filenames{i}));
        i = i + 1;
        
    end
    
    titles = {'Slope', 'Intercept'};
    sub_plot = [3, 4]
    for j = 1:size(P, 2)
        subplot(2, 2, sub_plot(j))
        
        b = bar(P(:, j), 'EdgeColor', 'w', 'FaceAlpha', 0.6, 'FaceColor', 'flat');
        hold on
        b.CData(:, :) = orange_color .* ones(3, 1);
        ax1 = gca;
        set(gca, 'XTickLabel', {'Exp. 1', 'Exp. 2', 'Exp. 3'});
        ylabel('Value');
        title(titles{j});
    end
end


function plot_fitted_values_all(d, idx, fit_folder, orange_color, blue_color, exp_names)

    i = 1;
    
    figure('Position', [1,1,1920,1090]);
    titles = {'Exp. 4', 'Exp. 5 Sess. 1', 'Exp. 5 Sess. 2'};
    
    for exp_name = {exp_names{:} exp_names{end}}
        if i == 3
            session = 1;
            to_add = '_sess_2';
        else
            session = 0;
            to_add = '_sess_1';
        end
        subplot(2, 3, i);
        exp_name = char(exp_name);
        [corr1, cho, out, p1, p2, ev1, ev2, ctch, cont1, cont2, dist, rtime] = ...
            DataExtraction.extract_sym_vs_sym_post_test(...
            d.(exp_name).data, d.(exp_name).sub_ids, idx, session);

        % set ntrials
        ntrials = size(cho, 2);
        subjecttot = length(d.(exp_name).sub_ids);
        nz = [8, 1];
        cont1(ismember(cont1, [6, 7, 8, 9])) = ...
            cont1(ismember(cont1, [6, 7, 8, 9]))-1;
       cont2(ismember(cont2, [6, 7, 8, 9])) = ...
            cont2(ismember(cont2, [6, 7, 8, 9]))-1;

        [parameters, ll] = runfit(...
            subjecttot,...
            cont1,...
            cont2,...
            cho,...
            ntrials,...
            nz,...
            fit_folder,...
            sprintf('%s%s%s', exp_name, '_exp_vs_exp', to_add));
        
        ev = [-0.8, -0.6, -0.4, -0.2, 0.2, 0.4, 0.6, 0.8];
        
        Y1 = parameters(:, 1:8)';
        
        [corr1, cho, out, p1, p2, ev1, ev2, ctch, cont1, cont2, dist, rtime] = ...
            DataExtraction.extract_sym_vs_lot_post_test(...
            d.(exp_name).data, d.(exp_name).sub_ids, idx, session);

        % set ntrials
        ntrials = size(cho, 2);
        subjecttot = length(d.(exp_name).sub_ids);
        nz = [8, 1];
        cont1(ismember(cont1, [6, 7, 8, 9])) = ...
            cont1(ismember(cont1, [6, 7, 8, 9]))-1;
        cont2 = ev2;

        [parameters, ll] = runfit(...
            subjecttot,...
            cont1,...
            cont2,...
            cho,...
            ntrials,...
            nz,...
            fit_folder,...
            sprintf('%s%s%s', exp_name, '_desc_vs_exp', to_add));
        
        Y2 = parameters(: , 1:8)';
         
        %x = linspace(min(xlim), max(yl), 10);
        brick_comparison_plot(...
            Y1,...
            Y2,...
            blue_color,...
            orange_color,...
            [-1, 1], 11,...
            titles{i},...
            'Symbol Expected Value',...
            'Fitted value', ev, 1);
        %legend('Description vs Experience', 'Experience vs Experience', 'Location', 'southeast');
        hold on
        
        yline(0, 'LineStyle', ':', 'LineWidth', 2);
        hold on
         
        x_lim = get(gca, 'XLim');
        y_lim = get(gca, 'YLim');
        
        x = linspace(x_lim(1), x_lim(2), 10);
        
        y = linspace(y_lim(1), y_lim(2), 10);
        plot(x, y, 'LineStyle', '--', 'Color', 'k');
        hold on
        
        
        for sub = 1:subjecttot
            X = ev;
            Y = Y1(:, sub);
            [r(1, i, sub, :), thrw1, thrw2] = glmfit(X, Y);
            b = glmfit(1:length(ev), Y);
            pY1(sub, :) = glmval(b, 1:length(ev), 'identity');
            X = ev;
            Y = Y2(:, sub);
            [r(2, i, sub, :), thrw1, thrw2] = glmfit(X, Y);
            b = glmfit(1:length(ev), Y);
            pY2(sub, :) = glmval(b, 1:length(ev), 'identity');
        end
        
        mn1 = mean(pY1, 1);
        mn2 = mean(pY2, 1);
        err1 = std(pY1, 1)./sqrt(subjecttot);
        err2 = std(pY2, 1)./sqrt(subjecttot);
        
        curveSup1 = (mn1 + err1);
        curveSup2 = (mn2 + err2);
        curveInf1 = (mn1 - err1);
        curveInf2 = (mn2 -err2);
        
        plot(1:length(ev), mn1, 'LineWidth', 1.7, 'Color', blue_color);
        hold on
        plot(1:length(ev), mn2, 'LineWidth', 1.7, 'Color', orange_color);
        hold on
        fill([(1:length(ev))'; flipud((1:length(ev))')], [curveInf1'; flipud(curveSup1')],...
            blue_color, ...
            'lineWidth', 1, ...
            'LineStyle', 'none',...
            'Facecolor', blue_color, ...
            'Facealpha', 0.55);     
        hold on
        fill([(1:length(ev))'; flipud((1:length(ev))')],[curveInf2'; flipud(curveSup2')],...
            orange_color, ...
            'lineWidth', 1, ...
            'LineStyle', 'none',...
            'Facecolor', orange_color, ...
            'Facealpha', 0.55); 
        hold on
        i = i + 1;
        
    end
    
    titles2 = {'Intercept', 'Slope'};
    sub_plot = [4, 3];
    for j = 1:2
        subplot(2, 2, sub_plot(j))
        for k = 1:3
            rsize = reshape(r(:, k, :, j), [size(r, 3), 2]);
            mn(k, :) = mean(rsize);
            err(k, :) = std(rsize)./sqrt(size(r, 3));
        end
        b = bar(mn);% 'EdgeColor', 'w', 'FaceAlpha', 0.6, 'FaceColor', 'flat');
        hold on
        
        b(1).FaceColor = orange_color;
        b(2).FaceColor = blue_color;
        b(1).FaceAlpha = 0.7;
        b(2).FaceAlpha = 0.7;
        
        ax1 = gca;
        set(gca, 'XTickLabel', titles);
        ylabel('Value');
        title(titles2{j});
        legend('Description vs Experience', 'Experience vs Experience',  'Location', 'southeast');
        errorbar(b(1).XData+b(1).XOffset, mn(:, 1), err(:, 1), 'LineStyle', 'none',...
            'LineWidth', 2, 'Color', 'k', 'HandleVisibility','off');
        hold on
        errorbar(b(2).XData+b(2).XOffset, mn(:, 2), err(:, 2), 'LineStyle', 'none',...
            'LineWidth', 2, 'Color', 'k', 'HandleVisibility','off');

    end
    saveas(gcf, 'fig/fit/all/fitted_value_exp_4_5.png')          

end


function [parameters, ll] = ...
    runfit(subjecttot, cont1, cont2, cho, ntrials, nz, folder, fit_filename)
    
    try
        disp(sprintf('%s%s', folder, fit_filename));
        data = load(sprintf('%s%s', folder, fit_filename));
        parameters = data.data('parameters');  %% Optimization parameters 
        ll = data.data('ll');
        answer = question(...
            'There is already a fit file, would you like to use it or to rerun analyses (the old file will be replaced)',...
             'Use existent fit file', 'Rerun and erase');
        if strcmp(answer, 'Use existent fit file')
            return 
        end
    catch
    end
    parameters = zeros(subjecttot, 8);
    ll = zeros(subjecttot, 1);
    
    options = optimset(...
        'Algorithm',...
        'interior-point',...
        'Display', 'off',...
        'MaxIter', 10000,...
        'MaxFunEval', 10000);

    w = waitbar(0, 'Fitting subject');
    for sub = 1:subjecttot
        
        waitbar(...
            sub/subjecttot,...  % Compute progression
            w,...
            sprintf('%s%d', 'Fitting subject ', sub)...
            );
           
            [
                p,...
                l,...
                rep,...
                output,...
                lmbda,...
                grad,...
                hess,...
            ] = fmincon(...
                @(x) qvalues(...
                    x,...
                    cont1(sub, :),...
                    cont2(sub, :),...
                    cho(sub, :),...
                    nz,...
                   ntrials),...
                zeros(8, 1),...
                [], [], [], [],...
                ones(8, 1) .* -1,...
                ones(8, 1),...
                [],...
                options...
                );
            parameters(sub, :) = p;
            ll(sub) = l;

    end
    %% Save the data
    data = containers.Map({'parameters', 'll'},...
        {parameters, ll});
    save(sprintf('%s%s', folder, fit_filename), 'data');
    close(w);
    
end

function [d, idx] = load_data(filenames, folder,  rtime_threshold,...
    catch_threshold, n_best_sub, allowed_nb_of_rows)

    d = struct();
    i = 1;
    for f = filenames
        [dd{i}, sub_ids{i}, idx] = DataExtraction.get_data(...
            sprintf('%s/%s', folder, char(f)));
        i = i + 1;
    end
    
    i = 1;
    for f = filenames
        d = setfield(d, char(f), struct());
        new_d = getfield(d, char(f));
        new_d.sub_ids = ...
            DataExtraction.exclude_subjects(...
            dd{i}, sub_ids{i}, idx, catch_threshold, rtime_threshold,...
            n_best_sub, allowed_nb_of_rows);
        new_d.data = dd{i};
        new_d.nsub = length(new_d.sub_ids);
        d = setfield(d, char(f), new_d);

        i = i + 1;
    end
    
end

function show_loaded_data(d)
    disp('Loaded struct with fields: ');
    filenames = fieldnames(d);
    disp(filenames);
    disp('N sub:');
    for f = filenames'
        f = f{:};
        if ~strcmp(f, 'idx')
            fprintf('%s: N=%d \n', f, d.(f).nsub);
        end
    end
end