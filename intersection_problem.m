clear all

%% DATA GENERATION
% data params
%-------------------------------------------------------------------------
orange_color = [0.8500, 0.3250, 0.0980];
force = true;
nsub = 10;
ntrial = 88;

p_sym = [.1, .2, .3, .4, .6, .7, .8, .9];
p_lot = 0:.1:1;

% generate random choices according to probabilities of each cues
chose_symbol = zeros(nsub, length(p_sym), length(p_lot));
for sub = 1:nsub
    for p1 = 1:length(p_sym)
        for p2 = 1:length(p_lot)
             chose_symbol(sub, p1, p2) =...
                 randsample([0, 1], 1, true, [p_lot(p2), p_sym(p1)]);        
        end
    end
end


% average and reshape from (1, 8, 11) to (8, 11)
% i.e one curve of 11 points (number of lotteries) for each symbol (8)
mean_chose_symbol = reshape(mean(chose_symbol, 1), [8,11]);


%% Fitting
% Fit a 2 param logistic function to each symbol choice sequence for each 
% sub
%-------------------------------------------------------------------------
fitted_chose_symbol = zeros(nsub, length(p_sym), length(p_lot));
fitted_chose_symbol2 = zeros(nsub, length(p_sym), length(p_lot));


for sub = 1:nsub
    
    fprintf('Fitting sub %d \n', sub);
    
    for i = 1:length(p_sym)
        Y(i, :) = reshape(chose_symbol(sub, i, :), [], 1);
        X(i, :) = p_lot;
    end
    
    try
        if force
            error('fitting');
        end
        param = load('data/method_xp_fit.mat');
        beta1 = param.beta1;
        midpoint = param.midpoint;
        tosave = false;
    catch
        tosave = true;
        options = optimset(...
            'Algorithm',...
            'interior-point',...
            'Display', 'off',...
            'MaxIter', 10000,...
            'MaxFunEval', 10000);
        
        [params(sub,:), res(sub)] = fmincon(...
            @(x) tofit2(x, X, Y),...
            [1, .5, .5, .5, .5, .5, .5, .5, .5],...
            [], [], [], [],...
            [0.01, 0, 0, 0, 0, 0, 0, 0 ,0],...
            [inf, 1, 1, 1, 1, 1, 1, 1, 1],...
            [],...
            options...
        );
    
        [beta2(sub), res(sub)] = fmincon(...
            @(x) tofit(x, X, Y),...
            [1],...
            [], [], [], [],...
            [0.01],...
            [inf],...
            [],...
            options...
        );
        beta1(sub) = params(sub, 1);
        midpoint(sub, :) = params(sub, 2:9);
        options = optimset('Display','off');
        
        for i = 1:length(p_sym)
            midpoint2(sub, i) = lsqcurvefit(...
                @(midpoint2, x) (logfun(x, midpoint2, beta2(sub))),...
                [0], X(i, :)', Y(i, :)', [0], [1], options);
        end
        
    end
    
    for i = 1:length(p_sym)
        fitted_chose_symbol(sub, i, :) = ...
            logfun(X(i, :)', midpoint(sub, i), beta1(sub));
        fitted_chose_symbol2(sub, i, :) = ...
            logfun(X(i, :)', midpoint2(sub, i), beta2(sub));
    end
    
end

if tosave
    param.midpoint = midpoint;
    param.beta1 = beta1;
    param.res = res;
    
    save('data/method_xp_fit.mat',...
       '-struct', 'param');
end


%% PLOTS
% figure params
figure('Renderer', 'painters', 'position', [0, 0, 500*4, 700],...
    'visible', 'on')
fontsize = 10;

% Indifference curves bhv
% -----------------------  ------------------------------------- %
subplot(2, 3, 1)

alpha = linspace(.15, .95, length(p_sym));

lin1 = plot(...
    p_lot, ones(length(p_lot),1).*.5,...
    'LineStyle', ':', 'Color', [0, 0, 0], 'HandleVisibility', 'off');
hold on

for i = 1:length(p_sym)
        
    lin3 = plot(...
        p_lot, mean_chose_symbol(i,:),...
        'Color', orange_color, 'LineWidth', 4.5);
    
    lin3.Color(4) = alpha(i);
    
    hold on
    
    [xout1, yout] = intersections(p_lot, mean_chose_symbol(i,:),...
        p_lot, ones(length(p_lot),1).*.5);
    
    sc2 = scatter(xout1, yout, 80, 'MarkerFaceColor', lin3.Color,...
        'MarkerEdgeColor', 'w');
    sc2.MarkerFaceAlpha = alpha(i);
    
     
    ylim([-0.08, 1.08]);
    xlim([-0.08, 1.08]);
    
    box off
end
title('Averaged bhv');
% Indifference curves aggregation of fits
% -----------------------  ------------------------------------- %
subplot(2, 3, 2)

alpha = linspace(.15, .95, length(p_sym));

lin1 = plot(...
    p_lot, ones(11,1).*.5,...
    'LineStyle', ':', 'Color', [0, 0, 0], 'HandleVisibility', 'off');
hold on

for i = 1:length(p_sym)
    
    Y = reshape(mean(fitted_chose_symbol(:, i, :), 1), [], 1);
    
    lin3 = plot(...
        p_lot, Y,...
        'Color', orange_color, 'LineWidth', 4.5);
    
    lin3.Color(4) = alpha(i);
    
    hold on
    
    [xout2(i), yout] = intersections(p_lot, Y,...
        p_lot, ones(11,1).*.5);
    
    sc2 = scatter(xout2(i), yout, 80, 'MarkerFaceColor', lin3.Color,...
        'MarkerEdgeColor', 'w');
    sc2.MarkerFaceAlpha = alpha(i);
    
     
    ylim([-0.08, 1.08]);
    xlim([-0.08, 1.08]);
    
    box off
end


title('Averaged fitted curves');


% Brickplot midpoint based on fit
% ------------------------------------------------------------------- %
subplot(2, 3, 3)

varargin = p_sym;
x_values = p_sym;
x_lim = [0, 1];

add_linear_reg(midpoint, p_sym, orange_color);
hold on

brickplot2(...
    midpoint', 0.02,...
    orange_color.*ones(3, 8)', ...
    [0, 1], fontsize,...
    '',...
    '',...
    '', varargin, 1, x_lim, x_values);
box off

title('Fitted midpoints');

% Brickplot midpoint based on fit 2
% ------------------------------------------------------------------- %
subplot(2, 3, 4)

slope1 = add_linear_reg(midpoint2, p_sym, orange_color);
hold on


brickplot2(...
    midpoint2', 0.02,...
    orange_color.*ones(3, 8)', ...
    [0, 1], fontsize,...
    '',...
    '',...000
    '', varargin, 1, x_lim, x_values);
box off

title('Fitted midpoints 2');


%Brickplot midpoint based on actual intersections 
%-----------------------  ------------------------------------- %
subplot(2, 3, 5)

y1 = ones(1, 11).* .5;
x = linspace(0, 1, 11);

hold on

for sub = 1:nsub
    for i = 1:length(p_sym)
        
        y2 = reshape(fitted_chose_symbol2(sub, i, :), [], 1);
        [xout3(sub, i), yout] = intersections(x, y2, x, y1);

        box off
    end
end

slope1 = add_linear_reg(xout3, p_sym, orange_color);


brickplot2(...
    xout3',  0.02,...
    orange_color.*ones(3, 8)', ...
    [0, 1], fontsize,...
    '',...
    '',...
    '', varargin, 1, x_lim, x_values);
box off
title('Intersection midpoints');



title('Averaged fitted curves');
% Indifference curves aggregation of fits


% comparison
% -----------------------  ------------------------------------- %
subplot(2, 3, 6)

plot(mean(xout3), xout2, 'color', orange_color,...
    'markerfacecolor', orange_color, 'linestyle', '--', 'marker', 'o');
title('comparison of ind and agg. intersections')



%% side functions
% fit functions
% ------------------------------------------------------------------------
function sumres = tofit2(params, X, Y)
    options = optimset('Display','off');
    temp = params(1);
    midpoints = params(2:end);
    for i = 1:size(Y, 1)
        residuals(i,:) = logfun(X(i,:)', midpoints(i), temp) - Y(i,:)';
    end
    sumres = sum(residuals.^2, 'all');
end

function sumres = tofit(temp, X, Y)
    options = optimset('Display','off');
    for i = 1:size(Y, 1)
        [throw, throw2, residuals(i, :)] = lsqcurvefit(...
            @(midpoint, x) (logfun(x, midpoint, temp)),...
            [0], X(i, :)', Y(i, :)', [0], [1], options);

    end
    sumres = sum(residuals.^2, 'all');
end

function p = logfun(x, midpoint, temp)
    p = 1./(1+exp(temp.*(x-midpoint(1))));
end
