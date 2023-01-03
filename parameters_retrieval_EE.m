%-------------------------------------------------------------------------
init;
show_current_script_name(mfilename('fullpath'));
%-------------------------------------------------------------------------

selected_exp = [9.1, 9.2];%, 5, 6.1, 6.2, 7.1, 7.2, 8.1, 8.2];

displayfig = 'off';
force = 1;
num = 0;

mids_1 = [];
mids_2 = [];
beta_1 = [];
beta_2 = [];
for exp_num = selected_exp
    num = num + 1;
    disp(exp_num);
    sess = de.get_sess_from_exp_num(exp_num);
    
    data = de.extract_EE(exp_num);
    
    % ---------------------------------------------------------------------
    % Compute for each symbol p of chosing depending on described cue value
    % ---------------------------------------------------------------------

    p_sym = unique(data.p1)';
    nsub = size(data.cho, 1);
    param = load(sprintf('data/midpoints_EE_exp_%d_%d_mle.mat',...
                 round(exp_num), sess));
             
    init_midpoints = param.midpoints;         
    init_beta = param.beta1;
    decision_rule = 'argmax';
    cho = compute_cho(data.p1, data.p2, init_midpoints, init_beta, decision_rule);
    
    cho_matching{num} = mean(cho==data.cho, 'all');
    
    chose_symbol = nan(nsub, length(p_sym), length(p_sym)-1);

    for i = 1:nsub
        for j = 1:length(p_sym)
            count = 1;
            for k = 1:length(p_sym)
                
                if j~=k
                    temp = ...
                        cho(i, logical(...
                        (data.p2(i, :) == p_sym(k)) .* (data.p1(i, :) == p_sym(j))));
                    chose_symbol(i, j, count) = temp == 1;
                    count = count + 1;
                end
            end
        end
    end
    
    disp(size(chose_symbol));
    
    midpoints = nan(nsub, length(p_sym));
    params = nan(nsub, length(p_sym)+1);
    beta1 = nan(nsub, 1);
    nll = nan(nsub, 1);
    
    for sub = 1:nsub
                             
        X = zeros(length(p_sym), length(p_sym)-1);
        Y = zeros(length(p_sym), length(p_sym)-1);
        
        for i = 1:length(p_sym)
            
            Y(i, :) = reshape(chose_symbol(sub, i, :), [], 1);
            X(i, :) = p_sym(p_sym(i)~=p_sym);
        end
        
        try 
            if force 
                error('fitting');
            end
             param = load(...
                 sprintf('data/midpoints_PR_EE_exp_%d_%d_mle.mat',...
                 round(exp_num), sess ...
             ));
             beta1 = param.beta1;
             midpoints = param.midpoints;
             nll = param.nll;
             tosave = false;
        catch
            tosave = true;
            options = optimset(...
                'Algorithm',...
                'interior-point',...
                'Display', 'off',...
                'MaxIter', 10000,...
                'MaxFunEval', 10000);

            [params(sub, :), nll(sub)] = fmincon(...
                @(x) tofit_mle2(x, X, Y),...
                [1, ones(1, length(p_sym)) .* .5],...
                [], [], [], [],...
                [0.01, zeros(1, length(p_sym))],...
                [inf, ones(1, length(p_sym))],...
                [],...
                options...
            );
      
        end
        if tosave
            midpoints = params(:, 2:length(p_sym)+1);
            beta1 = params(:, 1);
        end
        
    end
    
    if tosave
        param.midpoints = midpoints;
        param.beta1 = beta1;
        param.nll = nll;
        
        save(sprintf('data/midpoints_PR_EE_exp_%d_%d_mle.mat',...
            round(exp_num), sess), '-struct', 'param');
    end
    if exp_num == 4
        new(:, [1, 4, 5, 8]) = init_midpoints(:, :);
        new(:, [2, 3, 6, 7]) = NaN;
        init_midpoints = new;
        new2(:, [1, 4, 5, 8]) = midpoints(:, :);
        new2(:, [2, 3, 6, 7]) = NaN;
        midpoints = new2;
    end
    mids_1 = [mids_1; init_midpoints];
    mids_2 = [mids_2; midpoints];
    beta_1 = [beta_1; init_beta];
    beta_2 = [beta_2; beta1];
%     for i = 1:size(midpoints, 2)
%         x = init_midpoints(:, i);
%         y = midpoints(:, i);
%         color = orange;
%         xlimits = [0 1];
%         ylimits = xlimits;
%         xlabel1 = 'Fitted indifference point';
%         if i == 1
%             ylabel1 = 'Retrieved indifference point';
%         else
%             ylabel1 = '';
%         end
%         title1 = sprintf('p=%.1f', round(p_sym(i), 1));
%         subplot(2, 4, i)
%         set(gca, 'tickdir', 'out');
%         scatterplot(x, y, color, xlimits, ylimits, xlabel1, ylabel1, title1)
%         %saveas(gcf, sprintf('midpoints_Exp_%d.png', exp_num));
%     end
%         x = init_beta;
%         y = beta1;
%         color = blue;
%         xlimits = [0, 100];
%         ylimits = xlimits;
%         xlabel1 = 'Fitted temperature';
%         ylabel1 = 'Retrieved temperature';
%         title1 = sprintf('Exp.%d', exp_num);
%         figure('Renderer', 'painters')
%         set(gca, 'tickdir', 'out');
%         scatterplot(x, y, color, xlimits, ylimits, xlabel1, ylabel1, title1)
%         %saveas(gcf, sprintf('temperature_Exp_%d.png', exp_num));

end

% figure('Units', 'centimeters',...
%     'Position', [0,0,19.8, 9.5], 'visible', 'on')
% 
figure('Units', 'centimeters',...
    'Position', [0,0,19.8, 9.5], 'visible', 'on')
for i = 1:size(mids_1, 2)
        x = mids_1(:, i).*100;
        y = mids_2(:, i).*100;
        color = green;
    
        xlimits = [0 100];
        ylimits = xlimits;
        xlabel1 = 'E-option estimated p(win) (%)';
        if (i == 1) ||(i == 5)
            ylabel1 =  'Recovered p(win) (%)';
        else
            ylabel1 = '';
        end
        title1 = sprintf('E-option p(win) = %d%%', round(p_sym(i).*100, 1));
        subplot(2, 4, i)
        set(gca, 'tickdir', 'out');
        scatterplot(x, y, 15, color, xlimits, ylimits, xlabel1, ylabel1, title1)
        set(gca, 'fontsize', fontsize);
        xticks([0:20:100]);
        saveas(gcf, 'midpoints_ExpEE.svg');
end
    return

    
figure('Units', 'centimeters',...
    'Position', [0,0,8, 7], 'visible', 'on')
x = normalize(beta_1);
y = normalize(beta_2);
color = green;
xlimits = [0, 1];
ylimits = xlimits;
xlabel1 = 'First fitted temperature \beta';
ylabel1 = 'Retrieved temperature \beta';
title1 = 'Exp. 5, 6.1, 6.2';
set(gca, 'tickdir', 'out');
 scatterplot(x, y, 20, color, xlimits, ylimits, xlabel1, ylabel1, title1)
 %xticks(0:10);
        %saveas(gcf, sprintf('temperature_Exp_%d.png', exp_num));
set(gca, 'fontsize', fontsize)

% figure
% skylineplot(cho_matching', 8,...
%         ones(4, 3).*blue,...
%         0,...
%         1,...
%         fontsize,...
%         '',...
%         'Exp.',...
%         '',...
%         1:4);
%       
%     
%     
% saveas(gcf, sprintf('cho_matching.png', exp_num));


function nll = tofit_mle2(params, X, Y)
    options = optimset('Display','off');
    temp = params(1);
    midpoints = params(2:end);
    ll = 0;
    for i = 1:size(Y, 1)
        yhat = logfun(X(i,:), midpoints(i), temp);
        ll = ll + (1/numel(yhat)) * sum(log(yhat) .* Y(i,:) + log(1-yhat).*(1-Y(i,:))); 
    end
    nll = -ll;
end



function p = logfun(x, midpoint, temp)
    p = 1./(1+exp(temp.*(x-midpoint)));
end


function cho = compute_cho(p_sym, p_lot, midpoints, beta1, decision_rule)
    sym = unique(p_sym);
    
    for sub = 1:size(p_sym,1)
        for t = 1:size(p_sym,2)
            
            v = midpoints(sub, p_sym(sub, t)==sym);
            
            if strcmp(decision_rule, 'argmax')
                if p_lot(sub,t) >= v
                    prediction = 2;
                else
                    prediction = 1;
                end

                cho(sub, t) = prediction;
            else
                try
                cho(sub, t) = randsample(...
                    [1, 2], 1, true,...
                    smax([v, p_lot(sub, t)]-max([v, p_lot(sub,t)]), beta1(sub)));
                catch
                    disp('err');
                end
            end
        end
    end
end

function p = smax(x, beta1)
    p = exp(beta1 .* x)./sum(exp(beta1 .* x));
end

function x = normalize(arr)
    x = (arr - min(arr)) / ( max(arr) - min(arr) );
end
