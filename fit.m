% -------------------------------------------------------------------%
% This script finds the best fitting Values for each exp             %
% then plots the figs                                                %
% -------------------------------------------------------------------%
init;
% -------------------------------------------------------------------%

%selected_exp = [3, 4, 5.1, 5.2, 6.1, 6.2, 7.1, 7.2];
selected_exp = [3]%, 5.2, 6.2, 7.2];

sessions = [0, 1];

learning_model = [1];
post_test_model = [1, 2];


fit_folder = 'data/fit/';


nfpm = [2, 4];

force = 0;

for exp_num = selected_exp
    
    fprintf('Fitting exp. %s \n', num2str(exp_num));
    
    % -------------------------------------------------------------------%
    % LEARNING
    % -------------------------------------------------------------------%
    idx1 = (exp_num - round(exp_num)) * 10;
    idx1 = idx1 + (idx1==0);
    sess = sessions(uint64(idx1));
        
    % load data
    exp_name = char(filenames{round(exp_num)});

    [cho, cfcho, out, cfout, corr, con, p1, p2, rew, rtime, ev1, ev2] = ...
        DataExtraction.extract_learning_data(...
            d.(exp_name).data, d.(exp_name).sub_ids, idx, sess);
    
    % set parameters
    fit_params.cho = cho;
    fit_params.cfcho = cfcho;
    fit_params.out = out;
    fit_params.cfout = cfout;
    fit_params.con = con;
    fit_params.fit_cf = (exp_num > 2);
    fit_params.ntrials = size(cho, 2);
    fit_params.models = learning_model;
    fit_params.nsub = d.(exp_name).nsub;
    fit_params.sess = sess;
    fit_params.exp_num = num2str(exp_num);
    fit_params.decision_rule = 3;
    
    save_params.fit_file = sprintf(...
        '%s%s%s%d', fit_folder, exp_name,  '_learning_', sess);
    
    % fmincon params
    fmincon_params.init_value = {[0, .5], [0, .5, .5],[0, .5]};
    fmincon_params.lb = {[0, 0], [0, 0, 0], [0, 0]};
    fmincon_params.ub = {[100, 1], [100, 1, 1], [100, 1]};
    
    try
        data = load(save_params.fit_file);
        
        %lpp = data.data('lpp');
        parameters = data.data('parameters');  %% Optimization parameters
        ll = data.data('ll');
        %hessian = data.data('hessian');
        if force
            error('Force = True');
        end
    catch
        [parameters, ll] = runfit_learning(...
            fit_params, save_params, fmincon_params);
        
    end
    
        
    Q = get_qvalues(...
        exp_name, sess,...
        fit_params.cho, fit_params.cfcho, fit_params.con, fit_params.out,...
        fit_params.cfout, fit_params.ntrials, fit_params.fit_cf, 1); 
    
    figure('Position', [1,1,900,600]);
    plot_Q(Q, p1, p2, blue_color, exp_num, 1);

    return 
    
    clear ll
    
    ll = zeros(2, 2, d.(exp_name).nsub);
    
    [a, cont1, cont2, p1, p2, ev1, ev2, ll(1, 2, :)] = sim_exp_ED(...
       exp_name, exp_num, d, idx, sess, 5);
    
    [a, cont1, cont2, p1, p2, ev1, ev2, ll(2, 2, :)] = sim_exp_ED(...
        exp_name, exp_num, d, idx, sess,  4);
    
    [a, cont1, cont2, p1, p2, ev1, ev2, ll(1, 1, :)] = sim_exp_EE(...
       exp_name, exp_num, d, idx, sess, 5);
    
    [a, cont1, cont2, p1, p2, ev1, ev2, ll(2, 1, :)] = sim_exp_EE(...
        exp_name, exp_num, d, idx, sess,  4);
    
    
    % --------------------------------------------------------------------
    % MODEL SELECTION PROCEDURE
    % --------------------------------------------------------------------
    % Compute information criteria
    % -------------------------------------------------------------------- 
%     
%     for n = post_test_model
%         bic(n, :) = -2 * -ll(n, :) + nfpm(n) * log(ntrials);
%         aic(n, :) = -2 * -ll(n, :) + 2 * nfpm(n);
%     end
%    
    %models = {'RW', 'RW_{degradation}'};
    
    figNames = {'AIC', 'BIC', 'log_{LL}'};
    i = 0;
    clear post mn err eF
%     for criterium = {-ll}
%         i = i + 1;
%         
% %         options.modelNames = models{post_test_model};
% %         options.figName = figNames{i};
% %         options.DisplayWin = 0;
% %       
%         [postr, out] = VBA_groupBMC(cell2mat(criterium));%, options);
%         
%         post(i, :, :) = postr.r;
%         mn(i, :) = mean(postr.r, 2);
%         err(i, :) = std(postr.r, 1, 2)/sqrt(size(postr.r, 2));
%         eF(i, :) = out.Ef;
%     end
%     
    % --------------------------------------------------------------------
    % Plot P(M|D)
    % --------------------------------------------------------------------
%     figure(...%'Renderer', 'painters',...
%         'Position', [927,131,726,447])
%     mn = mean(ll, 3);
%     err(1) = std(ll(1, :))/sqrt(d.(exp_name).nsub);
%     err(2) = std(ll(2, :))/sqrt(d.(exp_name).nsub);
%     err = err';
%     
%       cc = [0    0.4470    0.7410;
%         0.8500    0.3250    0.0980;
%         0.9290    0.6940    0.1250];
%     
% 
%     %err = err';
%     b = bar(mn, 'EdgeColor', 'w', 'FaceAlpha', 0.55);
%     b.CData(1, :) = cc(1, :);
%     b.CData(2, :) = cc(3, :);
% 
%     hold on 
%     
%         
%     box off
%     nsub = d.(exp_name).nsub;
%     hold on
%     ax1 = gca;
%    
%   
%     for i = 1:2
% %         ax(i) = axes('Position',get(ax1,'Position'),'XAxisLocation','top',...
% %                 'YAxisLocation','right','Color','none','XColor','k','YColor','k');
% %         
% %         hold(ax(i), 'all');
% %         
%         X = ones(1, nsub)-Shuffle(linspace(-0.2, 0.2, nsub));
%         s = scatter(...
%                 X + (i-1),...
%                 ll(i, :), 115,...
%                 'filled', 'Parent', ax1,...
%                 'MarkerFaceAlpha', 0.65, 'MarkerEdgeAlpha', 1,...
%                 'MarkerFaceColor', cc(1, :),...
%                 'MarkerEdgeColor', 'w', 'HandleVisibility','off');
%         box off
%     end
%     clear ax
%     
%     errorbar(mn, err, 'LineStyle', 'none', 'LineWidth',...
%             2.5, 'Color', 'k', 'HandleVisibility','off');
%    
%     box off
%     set(gca, 'XTickLabel', {'P. Trace', 'D. Trace'});
%     ylabel('Likelihood');
%     set(gca, 'Fontsize', 20);
%     title(sprintf('Exp. %s', num2str(exp_num)));

    figure('Renderer', 'painters',...
        'Position', [927,131,726,447], 'visible', 'on')
        nsub = d.(exp_name).nsub;

    mn = mean(ll, 3);
    err = std(ll, 0, 3)/sqrt(nsub);
    
    b = bar(mn, 'EdgeColor', 'w', 'FaceAlpha', 0.55, 'FaceColor', 'Flat');
    hold on
    ngroups = 2;
    nbars = 2;
    % Calculating the width for each bar group
    groupwidth = min(0.8, nbars/(nbars + 1.5));
    cc = [0    0.4470    0.7410;
        0.8500    0.3250    0.0980;
        0.9290    0.6940    0.1250];
    count = 0;
    for i = 1:nbars
        x = (1:ngroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*nbars);
        hold on
        for j = 1:length(x)
            count = count + 1;
            b(i).CData(j, :) = cc(i, :);
            s = scatter(...
                x(j).*ones(1, nsub)-Shuffle(linspace(-0.07, 0.07, nsub)),...
                ll(j, i, :), 115,...
                'MarkerFaceAlpha', 0.65, 'MarkerEdgeAlpha', 1,...
                'MarkerFaceColor', cc(i, :),...
                'MarkerEdgeColor', 'w', 'HandleVisibility','off');
        end
        errorbar(x, mn(:, i), err(:,i), 'LineStyle', 'none', 'LineWidth',...
            2.5, 'Color', 'k', 'HandleVisibility','off');
    end
    hold off
    %ylim([0, 1.08]);
 
    box off
    set(gca, 'XTickLabel', {'P. Trace', 'D. Trace'});
    ylabel('Likelihood');
    set(gca, 'Fontsize', 20);
    set(gca,'TickDir','out'); % The only other option is 'in'
    
%     figure('Position', [1,1,900,600]);
% 
%     plot_Q(Q, p1, p2, blue_color, exp_num, 1);

%     alpha1 = parameters{2}(:, 2);
%     alpha2 = parameters{2}(:, 3);
%     beta1 = parameters{2}(:, 1);
%           
%     Q = get_qvalues(...
%         exp_name, sess,...
%         fit_params.cho, fit_params.cfcho, fit_params.con, fit_params.out,...
%         fit_params.cfout, fit_params.ntrials, fit_params.fit_cf, 2);
%     
%     figure('Position', [1,1,900,600]);
% 
%     plot_Q(Q, p1, p2, blue_color, exp_num, 2);
    clear cho con out cfcho cfout
end
    % -------------------------------------------------------------------%
    % POST-TEST
    % -------------------------------------------------------------------%
%     [corr1, cho1, out1, p1, p2, ~, ev2, ctch, cont11, cont21, dist, rtime] = ...
%         DataExtraction.extract_sym_vs_lot_post_test(...
%             d.(exp_name).data, d.(exp_name).sub_ids, idx, sess);
%              
%     [corr2, cho2, out2, p1, p2, ev1, ev21, ctch, cont12, cont22, dist, rtime] = ...
%         DataExtraction.extract_sym_vs_sym_post_test(...
%             d.(exp_name).data, d.(exp_name).sub_ids, idx, sess);
%                
%     % map con to contingencies number
%     map = [2 4 6 8 -1 7 5 3 1];
% 
%     cho = horzcat(cho1, cho2);
%     phase = vertcat(ones(size(cont11, 2), 1),...
%         ones(size(cont12, 2), 1) .* 2);
%     
%     % translate
%     i = 1;
%     for cont = {cont11, cont12, cont22}
%         cont = cont{:};
%         for sub = 1:size(cont, 1)
%             for t = 1:length(cont(sub, :))
%                 cont(sub, t) = map(cont(sub, t));
%             end
%         end
%         con_temp{i} = cont;
%         i = i+1;
%     end
%     clear i
%             
%     con{1} = horzcat(con_temp{1}, con_temp{2});
%     con{2} = horzcat(ev2, con_temp{3});
%     
%     % set parameters
%     ntrials = size(cho, 2);    
%     nmodel = length(post_test_model);
%     
%     init_value = {[1, 1], [0, 0]};
%     lb = {[1, 1], [0, 0]};
%     ub = {[1, 1], [1, 1]};
%     try
%         clear ll parameters
%         data = load(sprintf('%s%s_PT_%d', fit_folder, fit_filename, sess));
%         %lpp = data.data('lpp');
%         parameters = data.data('parameters');  %% Optimization parameters
%         ll = data.data('ll');
%         if force
%             error('Force = True');
%         end
% 
%         %hessian = data.data('hessian');
%     catch
%         [parameters, ll] = runfit_post_test(...
%                 nsub,...
%                 post_test_model,...
%                 Q,...
%                 con{1},...
%                 con{2},...
%                 cho,...
%                 phase,...
%                 ntrials,...
%                 init_value,...
%                 lb,...
%                 ub,...
%                 beta1,...
%                 fit_folder,...
%                 fit_filename, sess);
%         
%     end
% 
%     % --------------------------------------------------------------------
%     % MODEL SELECTION PROCEDURE
%     % --------------------------------------------------------------------
%     % Compute information criteria
%     % -------------------------------------------------------------------- 
% %     
% %     for n = post_test_model
% %         bic(n, :) = -2 * -ll(n, :) + nfpm(n) * log(ntrials);
% %         aic(n, :) = -2 * -ll(n, :) + 2 * nfpm(n);
% %     end
% %    
% %     %models = {'RW', 'RW_{degradation}'};
% %     
% %     figNames = {'AIC', 'BIC', 'log_{LL}'};
% %     i = 0;
% %     for criterium = {-aic, -bic, -ll}
% %         i = i + 1;
% %         
% % %         options.modelNames = models{post_test_model};
% % %         options.figName = figNames{i};
% % %         options.DisplayWin = 0;
% % %       
% %         [postr, out] = VBA_groupBMC(cell2mat(criterium));%, options);
% %         
% %         post(i, :, :) = postr.r;
% %         mn(i, :) = mean(postr.r, 2);
% %         err(i, :) = std(postr.r, 1, 2)/sqrt(size(postr.r, 2));
% %         eF(i, :) = out.Ef;
% %     end
% %     
% %     % --------------------------------------------------------------------
% %     % Plot P(M|D)
% %     % --------------------------------------------------------------------
% %     figure('Renderer', 'painters',...
% %         'Position', [927,131,726,447], 'visible', 'on')
% %     
% %     b = bar(mn, 'EdgeColor', 'w', 'FaceAlpha', 0.55);
% %     hold on
% %     ngroups = i;
% %     nbars = 2;
% %     nsub = size(postr.r, 2);
% %     % Calculating the width for each bar group
% %     groupwidth = min(0.8, nbars/(nbars + 1.5));
% %     cc = [0    0.4470    0.7410;
% %         0.8500    0.3250    0.0980j
% %         0.9290    0.6940    0.1250];
% %     for i = 1:nbars
% %         x = (1:ngroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*nbars);
% %         hold on
% %         for j = 1:length(x)
% %             s = scatter(...
% %                 x(j).*ones(1, nsub)-Shuffle(linspace(-0.07, 0.07, nsub)),...
% %                 post(j, i, :), 115,...
% %                 'MarkerFaceAlpha', 0.65, 'MarkerEdgeAlpha', 1,...
% %                 'MarkerFaceColor', cc(i, :),...
% %                 'MarkerEdgeColor', 'w', 'HandleVisibility','off');
% %         end
% %         errorbar(x, mn(:, i), err(:,i), 'LineStyle', 'none', 'LineWidth',...
% %             2.5, 'Color', 'k', 'HandleVisibility','off');
% %     end
% %     hold off
% %     ylim([0, 1.08]);
% %  
% %     box off
% %     set(gca, 'XTickLabel', figNames);
% %     ylabel('p(M|D)');
% %     set(gca, 'Fontsize', 20);
%     
%     % --------------------------------------------------------------------
%     % Plot parameters
%     % --------------------------------------------------------------------
%     clear err mn
%     
%     % compute
%     desc_ =  parameters(2, :, 1);
%     exp_ = parameters(2, :, 2);
%    
%     mn = [mean(desc_), mean(exp_)];
%     err(1) = std(desc_)/sqrt(nsub);
%     err(2) = std(exp_)/sqrt(nsub);
%       
%     figure('Renderer', 'painters',...
%         'Position', [927,131,726,447], 'visible', 'on')
%     
%     % ---------------------------------------------------------------- % 
%      cc = [
%         0.8500    0.3250    0.0980;
%         0    0.4470    0.7410;
%         0.9290    0.6940    0.1250];
%     ci = 1;
%     for m = mn       
%         b = bar(ci, m, 'EdgeColor', 'w',...
%             'FaceAlpha', 0.55, 'FaceColor', cc(ci, :));         
%         hold on
%         ci = ci + 1;
%     end
%     % ---------------------------------------------------------------- % 
% 
%     ngroups = 2;
%     nbars = 1;
%     
%     % Calculating the width for each bar group
%     groupwidth = min(0.8, nbars/(nbars + 1.5));
%     
%     for i = 1:nbars
%         x = (1:ngroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*nbars);
%         hold on
%         for j = 1:length(x)
%             s = scatter(...
%                 x(j).*ones(1, nsub)-Shuffle(linspace(-0.15, 0.15, nsub)),...
%                 parameters(2, :, j), 130,...
%                 'MarkerFaceAlpha', 0.65, 'MarkerEdgeAlpha', 1,...
%                 'MarkerFaceColor', cc(j, :),...
%                 'MarkerEdgeColor', 'w', 'HandleVisibility','off');
%         end
%         errorbar(x, mn, err, 'LineStyle', 'none', 'LineWidth', 2.5,...
%             'Color', 'k', 'HandleVisibility','off');
%     end
%     hold off
%     ylim([0, 1.08]);
%    
%     box off
%     %xticklabels({'Experience', 'Description'});
%     set(gca,'XTick',[]);
%     set(gca,'XTick', [1, 2]);
%     set(gca, 'XTickLabel', {'\lambda_{D}', '\lambda_{E}'});
%     ylabel('\lambda');
%     set(gca, 'Fontsize', 20);
% end
% --------------------------------------------------------------------
% FUNCTIONS USED IN THIS SCRIPT
% --------------------------------------------------------------------
function [parameters,ll] = ...
    runfit_learning(fit_params, save_params, fmincon_params)

   
    options = optimset(...
        'Algorithm',...
        'interior-point',...
        'Display', 'off',...
        'MaxIter', 10000,...
        'MaxFunEval', 10000);

    w = waitbar(0, 'Fitting subject');
    
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
    % Save the data
   %data = load(save_params.fit_file);
      
   %hessian = data.data('hessian');
   data = containers.Map({'parameters', 'll'},...
            {parameters, ll});
   save(save_params.fit_file, 'data');
     close(w);
%     
end

% --------------------------------------------------------------------
function [parameters,ll] = ...
    runfit_post_test(nsub, whichmodel, Q, con1, con2, cho, phase,...
    ntrials, init_value, lb, ub, beta1, folder, fit_filename, sess)

   
    options = optimset(...
        'Algorithm',...
        'interior-point',...
        'Display', 'off',...
        'MaxIter', 10000,...
        'MaxFunEval', 10000);

    w = waitbar(0, 'Fitting subject');
    
    for sub = 1:nsub
        
        waitbar(...
            sub/nsub,...  % Compute progression
            w,...
            sprintf('%s%d', 'Fitting subject ', sub)...
            );
        
        Qsub(1:4, 1:2) = Q(sub, :, :);
       
        for model = whichmodel
            
            
            [
                p1,...
                l1,...
                rep1,...
                grad1,...
                hess1,...
            ] = fmincon(...
                @(x) getll_post_test(...
                    x,...
                    beta1(sub),...
                    Qsub,...
                    con1(sub, :),...
                    con2(sub, :),...
                    cho(sub, :),...
                    phase,...
                    model,...
                    ntrials),...
                init_value{model},...
                [], [], [], [],...
                lb{model},...
                ub{model},...
                [],...
                options...
                );
            parameters(model, sub, :) = p1;
            ll(model, sub) = l1;

        end
    end
%    Save the data
    data = containers.Map({'parameters', 'll'},...
        {parameters, ll});
    save(sprintf('%s%s_PT_%d', folder, fit_filename, sess), 'data');
     close(w);
    
end

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

