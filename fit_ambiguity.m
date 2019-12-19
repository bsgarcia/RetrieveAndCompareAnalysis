% --------------------------------------------------------------------
% This script finds the best fitting Values for each exp
% then plots the article figs
% --------------------------------------------------------------------
init;

%------------------------------------------------------------------------
% Plot fig 2.A
%------------------------------------------------------------------------
exp_names = {filenames{6}};
plot_fitted_value_according_to_amb(d, idx, fit_folder, green_color, exp_names);

% --------------------------------------------------------------------
% FUNCTIONS USED IN THIS SCRIPT
% --------------------------------------------------------------------
function plot_fitted_value_according_to_amb(d, idx, fit_folder, green_color, exp_names)

    i = 1;

    figure('Position', [1,1,1920,1090]);

    for exp_name = {exp_names{end}}
        
        session = [0, 1];
        %subplot(2, 3, i);
        exp_name = char(exp_name);
        
        [corr1, cho, out, p1, p2, ev1, ev2, ctch, cont1, cont2, dist, rtime] = ...
            DataExtraction.extract_lot_vs_amb_post_test(...
            d.(exp_name).data, d.(exp_name).sub_ids, idx, session);

        % set ntrials
        ntrials = size(cho, 2);
        subjecttot = length(d.(exp_name).sub_ids);
        nz = [1, 1];
        cont1 = ev1;
        cont2 = zeros(size(cont2));
        type = 4;
        arg = 0;

        [parameters, ll] = runfit(...
            subjecttot,...
            cont1,...
            cont2,...
            cho,...
            ntrials,...
            nz,...
            type,...
            arg,...
            fit_folder,...
            sprintf('%s%s%s', exp_name, '_desc_vs_amb'));
        
        amb_value = mean(parameters);
        
        [corr1, cho, out, p1, p2, ev1, ev2, ctch, cont1, cont2, dist, rtime] = ...
            DataExtraction.extract_sym_vs_amb_post_test(...
            d.(exp_name).data, d.(exp_name).sub_ids, idx, session);

        % set ntrials
        ntrials = size(cho, 2);
        subjecttot = length(d.(exp_name).sub_ids);
        nz = [8, 1];
        cont1(ismember(cont1, [6, 7, 8, 9])) = ...
            cont1(ismember(cont1, [6, 7, 8, 9]))-1;
        for sub = 1:subjecttot
            cont2(sub, :) = ones(size(cont2, 2), 1) .* parameters(sub);
        end
        type = 5;

        [parameters, ll] = runfit(...
            subjecttot,...
            cont1,...
            cont2,...
            cho,...
            ntrials,...
            nz,...
            type,...
            arg,...
            fit_folder,...
            sprintf('%s%s%s', exp_name, '_exp_vs_amb'));
        
        ev = [-.8, -.6, -.4, -.2, .2, .4, .6, .8];
        Y2 = parameters(: , 1:8)';

        %x = linspace(min(xlim), max(yl), 10);
        brickplot(...
            Y2,...
            green_color.*ones(8, 1),...
            [-1, 1], 11,...
            '',...
            'Symbol Expected Value',...
            'Fitted value', ev, 1);

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
            Y = Y2(:, sub);
            [r(i, sub, :), thrw1, thrw2] = glmfit(X, Y);
            b = glmfit(1:length(ev), Y);
            pY2(sub, :) = glmval(b, 1:length(ev), 'identity');
        end

        mn2 = mean(pY2, 1);
        err2 = std(pY2, 1)./sqrt(subjecttot);

        curveSup2 = (mn2 + err2);
        curveInf2 = (mn2 -err2);

        p1 = plot(1:length(ev), mn2, 'LineWidth', 1.7, 'Color', green_color);

        hold on
        p2 = fill([(1:length(ev))'; flipud((1:length(ev))')],[curveInf2'; flipud(curveSup2')],...
            green_color, ...
            'lineWidth', 1, ...
            'LineStyle', 'none',...
            'Facecolor', green_color, ...
            'Facealpha', 0.55);
        hold on
        i = i + 1;

        box off

        %uistack(p1, 'bottom');
        %uistack(p2, 'bottom');
    end
    
%     titles2 = {'Performance', 'Slope'};
%     sub_plot = [4, 3];
%     for j = 1:2
%         subplot(2, 2, sub_plot(j))
%         
%         for k = 1:3
%             if j == 1
%                 rsize{k}  = mean(corr1{k}, 2)';              
%                 mn(k, :) = mean(rsize{k});
%                 err(k, :) = std(rsize{k})./sqrt(length(rsize{k}));      
%             else
%                 rsize{k} = reshape(r(k, :, j), [size(r, 2), 1]);
%                 mn(k, :) = mean(rsize{k});
%                 err(k, :) = std(rsize{k})./sqrt(length(rsize{k}));            
%             end
%         end
%         
%         dd = rsize;
%         
%         x = dd{1};
%         y = dd{2};
%         p = ranksum(x,y);
%         pp(1) = p;
%        
%         x = dd{2};
%         y = dd{3};
%         p = ranksum(x,y);
%         pp(2) = p;
%   
%         x = dd{1};
%         y = dd{3};
%         p = ranksum(x,y);
%         pp(3) = p;
% 
%         %pp = pval_adjust(pp, 'bonferroni');
%         for sp = pp 
%             if sp < .001
%                 h = '***';
%             elseif sp < .01
%                 h='**';
%             elseif sp < .05
%                 h ='*';
%             else 
%                 h = 'none';
%             end
%             fprintf('h=%s, p=%d \n', h, sp);
%         end
%         fprintf('===================== \n');
%         b = bar(mn);
%         hold on
% 
%         b.FaceColor = orange_color;
%         b.FaceAlpha = 0.7;
% 
%         ax1 = gca;
%         set(gca, 'XTickLabel', titles);
%         if j == 1
%             ylabel('Correct choice rate');
% 
%         else
%             ylabel('Value');            
%         end
% 
%         title(titles2{j});
%         e = errorbar(b.XData+b.XOffset, mn(:, 1), err(:, 1), 'LineStyle', 'none',...
%             'LineWidth', 2, 'Color', 'k', 'HandleVisibility','off');
%         
%         box off
%         ngroups = 3;
%         nbars = 1;
%         % Calculating the width for each bar group
%         groupwidth = min(0.8, nbars/(nbars + 1.5));
%         %colors = [orange_color; blue_color];
%         for b = 1:nbars
%             x = (1:ngroups) - groupwidth/2 + (2*b-1) * groupwidth / (2*nbars);
%             hold on
%             for k = 1:length(x)
% 
%                 d = reshape(rsize{k}, [], 1);
%                 nsub = length(d);
% 
%                 s = scatter(...
%                     x(k).*ones(1, nsub)-Shuffle(linspace(-0.1, 0.1, nsub)),...
%                     d', 100,...
%                     'MarkerFaceAlpha', 0.65, 'MarkerEdgeAlpha', 1,...
%                     'MarkerFaceColor', orange_color,...
%                     'MarkerEdgeColor', 'w', 'HandleVisibility','off');
%             end
%         end
%         uistack(e, 'top');
%      
%     end

    saveas(gcf, 'fig/fit/all/fitted_valueamb.png')


end


function [parameters, ll] = ...
    runfit(subjecttot, cont1, cont2, cho, ntrials, nz, type, arg, folder, fit_filename)

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
    %parameters = zeros(subjecttot, 1);
    %ll = zeros(subjecttot, 1);

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
            @(x) value(...
            x,...
            cont1(sub, :),...
            cont2(sub, :),...
            cho(sub, :),...
            nz,...
            ntrials, type, arg),...
            zeros(nz),...
            [], [], [], [],...
            ones(nz) .* -1,...
            ones(nz),...
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

