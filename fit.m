% -------------------------------------------------------------------%
% This script finds the best fitting Values for each exp             %
% then plots the option value                                        %
% -------------------------------------------------------------------%
init;
% -------------------------------------------------------------------%

selected_exp = [9.2];
%selected_exp = selected_exp(1);
sessions = [0, 1];

learning_model = [1];
post_test_model = [1, 2];

fit_folder = 'data/fit/';


nfpm = [2, 4];

force = 1;

for exp_num = selected_exp
    
    fprintf('Fitting exp. %s \n', num2str(exp_num));
    
    % -------------------------------------------------------------------%
    % LEARNING
    % -------------------------------------------------------------------%
    data = de.extract_LE(exp_num);
    % set parameters
    fit_params.cho = data.cho;
    fit_params.cfcho = data.cfcho;
    fit_params.out = data.out==1;
    fit_params.cfout = data.cfout==1;
    fit_params.con = data.con;
    fit_params.fit_cf = (exp_num>2);
    fit_params.ntrials = size(data.cho, 2);
    fit_params.models = learning_model;
    fit_params.model = 1;
    fit_params.nsub = data.nsub;
    fit_params.sess = data.sess;
    fit_params.exp_num = num2str(exp_num);
    fit_params.decision_rule = 1;
    fit_params.q = 0.5;
    fit_params.noptions = 2;
    fit_params.ncond = length(unique(data.con));
    
    save_params.fit_file = sprintf(...
        '%s%s%s%d', fit_folder, data.name,  '_learning_', data.sess);
    
    % fmincon params
    fmincon_params.init_value = {[1, .5], [0, .5, .5],[0, .5]};
    fmincon_params.lb = {[0.001, 0.001], [0, 0, 0], [0, 0]};
    fmincon_params.ub = {[100, 1], [100, 1, 1], [100, 1]};
    
    try
        data = load(save_params.fit_file);
        
        %lpp = data.data('lpp');
        fit_params.params = data.data('parameters');  %% Optimization parameters
        ll = data.data('ll');
        %hessian = data.data('hessian');
        
        if force
            error('Force = True');
        end
    catch
        [fit_params.params, ll] = runfit_learning(...
            fit_params, save_params, fmincon_params);
        
    end
    
%     fit_params.alpha1 = fit_params.params{1}(:, 2);
%     
%     Q = get_qvalues(fit_params); 
%     
%     figure('Position', [1,1,900,600]);
%     plot_Q(Q, p1, p2, blue_color, exp_num, 1);
end

    
function [parameters,ll] = ...
    runfit_learning(fit_params, save_params, fmincon_params)

   
    options = optimset(...
        'Algorithm',...
        'interior-point',...
        'Display', 'off',...
        'MaxIter', 10000,...
        'MaxFunEval', 10000);

    w = waitbar(0, 'Fitting subject');
    
    tStart = tic;
    for sub = 1:fit_params.nsub
        
        waitbar(...
            sub/fit_params.nsub,...  % Compute progression
            w,...
            sprintf('%s%d%s%s', 'Fitting subject ', sub, ' in Exp. ', fit_params.exp_num)...
            );
        
        for model = fit_params.models
         
            
            [
                p1,...
                l1,...
                rep1,...
                grad1,...
                hess1,...
            ] = fmincon(...
                @(x) getlpp_learning(...
                    x,...
                    fit_params.con(sub, :),...
                    fit_params.cho(sub, :),...
                    fit_params.cfcho(sub, :),...
                    fit_params.out(sub, :),...
                    fit_params.cfout(sub, :),...
                    fit_params.q,...
                    fit_params.ntrials, model, fit_params.decision_rule,...
                    fit_params.fit_cf),...
                fmincon_params.init_value{model},...
                [], [], [], [],...
                fmincon_params.lb{model},...
                fmincon_params.ub{model},...
                [],...
                options...
                );
            
            parameters{model}(sub, :) = p1;
            ll(model, sub) = l1;

        end
    end
   toc(tStart);
    % Save the data
   %data = load(save_params.fit_file);
      
   %hessian = data.data('hessian');
   data = containers.Map({'parameters', 'll'},...
            {parameters, ll});
   save(save_params.fit_file, 'data');
     close(w);
%     
end

% % --------------------------------------------------------------------
% function [parameters,ll] = ...
%     runfit_post_test(nsub, whichmodel, Q, con1, con2, cho, phase,...
%     ntrials, init_value, lb, ub, beta1, folder, fit_filename, sess)
% 
%    
%     options = optimset(...
%         'Algorithm',...
%         'interior-point',...
%         'Display', 'off',...
%         'MaxIter', 10000,...
%         'MaxFunEval', 10000);
% 
%     w = waitbar(0, 'Fitting subject');
%     
%     for sub = 1:nsub
%         
%         waitbar(...
%             sub/nsub,...  % Compute progression
%             w,...
%             sprintf('%s%d', 'Fitting subject ', sub)...
%             );
%         
%         Qsub(1:4, 1:2) = Q(sub, :, :);
%        
%         for model = whichmodel
%             
%             
%             [
%                 p1,...
%                 l1,...
%                 rep1,...
%                 grad1,...
%                 hess1,...
%             ] = fmincon(...
%                 @(x) getll_post_test(...
%                     x,...
%                     beta1(sub),...
%                     Qsub,...
%                     con1(sub, :),...
%                     con2(sub, :),...
%                     cho(sub, :),...
%                     phase,...
%                     model,...
%                     ntrials),...
%                 init_value{model},...
%                 [], [], [], [],...
%                 lb{model},...
%                 ub{model},...
%                 [],...
%                 options...
%                 );
%             parameters(model, sub, :) = p1;
%             ll(model, sub) = l1;
% 
%         end
%     end
% %    Save the data
%     data = containers.Map({'parameters', 'll'},...
%         {parameters, ll});
%     save(sprintf('%s%s_PT_%d', folder, fit_filename, sess), 'data');
%      close(w);
%     
% end

% --------------------------------------------------------------------



function barplot_model_comparison(post) 
    nsub = size(post, 3);
    for i = 1:size(post, 2)
        means(:,i) = mean(y(i, :));
        errors(i) = sem(y(i, :));
       % param_labels{i} = labels{param_idx(i)};
    end

    b = bar(means, 'EdgeColor', 'w');
    hold on
    e = errorbar(means, errors, 'Color', 'black', 'LineWidth', 2, 'LineStyle', 'none');
    %hold off
    box off
    
    
    set(gca, 'FontSize', 20);
    
    %xticklabels(param_labels);

    title(ttl);
    ax1 = gca;

    for i = 1:length(means)   

        ax(i) = axes('Position',get(ax1,'Position'),'XAxisLocation','top',...
         'YAxisLocation','right','Color','none','XColor','k','YColor','k');
          
        hold(ax(i), 'all');
        
        X = ones(1, nsub)-Shuffle(linspace(-0.15, 0.15, nsub));
        s = scatter(...
            X + (i-1),...
            y(i, :),...
             'filled', 'Parent', ax1, 'MarkerFaceAlpha', 0.75, 'MarkerEdgeAlpha', 1,...
             'MarkerFaceColor', colors(i, :),...
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


function plot_Q(qvalues, p1, p2, blue_color, exp_num, model)
    
    qvalues = sort_Q(qvalues);
    
    x_values = sort([unique(p2), unique(p1)]);
    
    varargin = [.1, .2, .3, .4, .6, .7, .8, .9];
    x_lim = [0, 1];
    ev  = varargin;
    
    brickplot2(...
        qvalues',...
        blue_color.*ones(8, 1),...
        [0, 1], 11,...
        '',...
        'P(win)',...
        'Fitted P(win)', varargin, 1, x_lim, x_values);

    box off
    hold on
    
    set(gca,'TickDir','out')

    title(sprintf('Exp. %s', num2str(exp_num)));

    y0 = yline(0.5, 'LineStyle', ':', 'LineWidth', 1.2);
    hold on
    
    x_lim = get(gca, 'XLim');
    y_lim = get(gca, 'YLim');
    
    x = linspace(x_lim(1), x_lim(2), 10);
    
    y = linspace(y_lim(1), y_lim(2), 10);
    p0 = plot(x, y, 'LineStyle', '--', 'Color', 'k');
    hold on
    
    for sub = 1:size(qvalues, 1)
        X = varargin;
        Y = qvalues(sub, :);
        [r(1, sub, :), thrw1, thrw2] = glmfit(X, Y);
        b = glmfit(ev, Y);
        pY2(sub, :) = glmval(b,ev, 'identity');
    end
    
    mn2 = mean(pY2, 1);
    err2 = std(pY2, 1)./sqrt(size(qvalues, 1));
    
    curveSup2 = (mn2 + err2);
    curveInf2 = (mn2 -err2);
    
    p1 = plot(ev, mn2, 'LineWidth', 1.7, 'Color', blue_color);
    hold on
    
    p2 = fill([...
         (ev)'; flipud((ev)')],...
        [curveInf2'; flipud(curveSup2')],...
        blue_color, ...
        'lineWidth', 1, ...
        'LineStyle', 'none',...
        'Facecolor', blue_color, ...
        'Facealpha', 0.55);
    hold on
        
    box off
    set(gca, 'FontSize', 22);
    mkdir('fig/exp', 'test_fitted_p');
    saveas(gcf, sprintf('fig/exp/test_fitted_p/exp_%s_model_%d.png', num2str(exp_num), model));
 end

