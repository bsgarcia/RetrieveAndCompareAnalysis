% ----------------------------------------------------------------------%
% This script finds the best fitting Values for each exp                %
% then plots the article figs                                           %
% ----------------------------------------------------------------------%
init;

%------------------------------------------------------------------------%
% Plot                                                                   %
%------------------------------------------------------------------------%
i = 1;
for exp_name = filenames
    
    if ismember(i, [5, 6, 7])
        session = 0
    else
        session = 0;
    end
    
    plot_learning_qvalues(d, idx, blue_color, exp_name, i);
    
    i = i + 1;
end


% --------------------------------------------------------------------%
% FUNCTIONS USED IN THIS SCRIPT                                       %
% --------------------------------------------------------------------%
function plot_learning_qvalues(d, idx, blue_color, exp_name, exp_num)
    i = 1;
    fit_folder = 'data/fit/';
    figure('Position', [1,1,900,600]);
    exp_name = char(exp_name);
    
    [cho, out, cfout, corr, con, p1, p2, rew, rtime, ev1, ev2] = ...
        DataExtraction.extract_learning_data(...
        d.(exp_name).data, d.(exp_name).sub_ids, idx, [0, 1]);
    
    % set ntrials
    ntrials = size(cho, 2);
    subjecttot = size(cho, 1);   
    a = cho;
    cfa = cho + 1;
    cfa(cfa == 3) = 1;
    
    % if feedback is not complete
    if exp_num < 3
        cfout = zeros(size(cfout));
    end
    s = con;
    
    [alphas, ll] = runfit(...
        subjecttot,...
        a,...
        s,...
        out,...
        cfa,...
        cfout,...
        ntrials,...
        fit_folder,...
        sprintf('exp_%d_qvalues', exp_num));        
    
    qvalues = get_qvalues_from_alpha(alphas, a, out, s, cfa, cfout);
    
    qvalues = reshape(qvalues, [size(qvalues, 1), 8]);
    qvalues(:, 1:8) = qvalues(:, [5:8 fliplr(1:4) ]);
    
    ev1 = unique(ev1)';
    ev2 = unique(ev2)';
    ev = sort([ev1 ev2]);
    
    x_values = ev;
    varargin = [-.8, -.6, -.4, -.2, .2, .4, .6, .8];
    x_lim = [-1, 1];
    
    brickplot2(...
        qvalues',...
        blue_color.*ones(8, 1),...
        [-1, 1], 11,...
        '',...
        'Symbol Expected Value',...
        'Q-value', varargin, 1, x_lim, x_values);
%     brickplot(...
%         qvalues',...
%         blue_color.*ones(8, 1),...
%         [-1, 1], 11,...
%         '',...
%         'Symbol Expected Value',...
%         'Q-value', ev, 1);
    box off
    hold on
    
    set(gca,'TickDir','out')

%     if ismember(exp_num, [5, 6, 7])
%         title(sprintf('Exp. %d Sess. %d', exp_num, session+1));
%     else
        title(sprintf('Exp. %d', exp_num));
%     end

    y0 = yline(0, 'LineStyle', ':', 'LineWidth', 2);
    hold on
    
    x_lim = get(gca, 'XLim');
    y_lim = get(gca, 'YLim');
    
    x = linspace(x_lim(1), x_lim(2), 10);
    
    y = linspace(y_lim(1), y_lim(2), 10);
    p0 = plot(x, y, 'LineStyle', '--', 'Color', 'k');
    hold on
    
    for sub = 1:subjecttot
        X = ev;
        Y = qvalues(sub, :);
        [r(i, sub, :), thrw1, thrw2] = glmfit(X, Y);
        b = glmfit(ev, Y);
        pY2(sub, :) = glmval(b,ev, 'identity');
    end
    
    mn2 = mean(pY2, 1);
    err2 = std(pY2, 1)./sqrt(subjecttot);
    
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
    
    mkdir('fig/exp', 'qvalues_test');
%     
%     if ismember(exp_num, [5, 6, 7])
%         saveas(gcf, sprintf('fig/exp/qvalues_test/exp_%d_sess_%d.png', exp_num, session));
%     else
        saveas(gcf, sprintf('fig/exp/qvalues_test/exp_%d.png', exp_num));

%     end
end


function [parameters, ll] = ...
    runfit(subjecttot, a, s, out, cfa, cfout, ntrials, folder, fit_filename)

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
    
    if all(cfout == 0)
        fit_counterfactual = 0;
    else
        fit_counterfactual = 1;
    end    
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
                @(x) getll(...
                x,...
                s(sub, :),...
                a(sub, :),...
                cfa(sub, :),...
                out(sub, :),...
                cfout(sub, :),...
                [], ones(1, ntrials), [], 1, fit_counterfactual, ntrials),...
                ones(1, 9) .* 5,...
                [], [], [], [],...
                zeros(1, 9),...
                ones(1, 9),...
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

