%% PARAMETERS 

%-------------------------------------------------------------------------
init;
%-------------------------------------------------------------------------

% figure params
figure('Renderer', 'painters', 'position', [0, 0, 500*4, 350],...
    'visible', 'on')
fontsize = 10;


% Simulations params
%-------------------------------------------------------------------------
% force fitting 
force = false;

% what exp to use to simulate the data
exp_num = 3;

% 1 = no neglect; 2 = neglect sym; 3 = neglect lot
sim_exp_num = 3;

sess = 0;
model = 1;
decision_rule = 1;
nagent = 1;

beta_params = {...
    {[6, 2], [6, 2]}, {[6,2], [2, 6]}, {[2,6], [6,2]}...
    };

% load data
name = char(filenames{round(exp_num)});
data = d.(name).data;
sub_ids = d.(name).sub_ids;
d.(name).nsub = 10;

% generate parameter distributions
beta_dist = [1, 1];
gam_dist = [1.2, 5];

options.alpha1 = ones(d.(name).nsub, 2) .* 0.3;%betarnd(beta_dist(1),...
    %beta_dist(2), [d.(name).nsub, 1]);
options.beta1 = ones(d.(name).nsub, 2) .* 2; %gamrnd(gam_dist(1),...
    %gam_dist(2), [d.(name).nsub, 1]);

options.random = true;

options.degradors = ones(d.(name).nsub, 2);

options.degradors(:, 2) = ones(d.(name).nsub, 1) .* 0.2; %betarnd(beta_params{3}{1}(1),...
    %beta_params{3}{1}(2), [d.(name).nsub, 1]);

%options.degradors(:, 1) = %betarnd(beta_params{3}{2}(1),...
    %beta_params{3}{2}(2), [d.(name).nsub, 1]);

%% COMPUTATION

% Run simulations
% ------------------------------------------------------------------------
[cho, cont1, cont2, p1, p2, ev1, ev2] = sim_exp_ED(...
    name, exp_num, d, idx, sess, model, decision_rule, nagent, options);

nsub = size(cho, 1);
psym = unique(p1)';
p_lot = unique(p2)';
% Compute mean p(choose symbol) (plot BHV DATA)
%-------------------------------------------------------------------------
prop = zeros(length(psym), length(p_lot));
for j = 1:length(p_lot)
    for l = 1:length(psym)
        temp = cho(...
            logical((p2 == p_lot(j)) .* (p1 == psym(l))));
        prop(l, j) = mean(temp == 1);
        err_prop(l, j) = std(temp == 1)./sqrt(nsub);
        
    end
end

% Compute p(choose symbol) for each sub and each symbol
%-------------------------------------------------------------------------
chose_symbol = zeros(nsub, length(p_lot), length(psym));
for i = 1:nsub
    for j = 1:length(p_lot)
        for k = 1:length(psym)
            temp = cho(i, logical(...
                        (p2(i, :) == p_lot(j)) .* (p1(i, :) == psym(k))));
            chose_symbol(i, j, k) = temp == 1;
        end
    end
   
end


% Fit a 2 param logistic function to each symbol choice sequence for each 
% sub
%-------------------------------------------------------------------------
fitted_p_choose_symbol = zeros(nsub, length(psym), length(p_lot));

for sub = 1:nsub
    
    fprintf('Fitting sub %d \n', sub);
    
    for i = 1:length(psym)
        Y(i, :) = reshape(chose_symbol(sub, :, i), [], 1);
        X(i, :) = p_lot;
    end
    
    try
        if force
            error('fitting');
        end
        param = load(sprintf('data/method_xp_%d.mat', sim_exp_num));
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
        
        [beta1(sub), res(sub)] = fmincon(...
            @(x) tofit(x, X, Y),...
            [1],...
            [], [], [], [],...
            [0.01],...
            [inf],...
            [],...
            options...
        );
        
        options = optimset('Display','off');
        
        for i = 1:length(psym)
            midpoint(sub, i) = lsqcurvefit(...
                @(midpoint, x) (logfun(x, midpoint, beta1(sub))),...
                [0], X(i, :)', Y(i, :)', [0], [1], options);
        end
        
    end
    
    for i = 1:length(psym)
        fitted_p_choose_symbol(sub, i, :) = ...
            logfun(X(i, :)', midpoint(sub, i), beta1(sub));
    end
    
end

if tosave
    param.midpoint = midpoint;
    param.beta1 = beta1;
    param.res = res;
    
    save(sprintf('data/method_xp_%d.mat', sim_exp_num),...
        '-struct', 'param');
end


%% PLOTS

% Brickplot midpoint based on fit
% ------------------------------------------------------------------- %
subplot(1, 4, 1)
ev = unique(p1);
varargin = ev;
x_values = ev;
x_lim = [0, 1];

slope1 = add_linear_reg(param.midpoint, ev, orange_color);
hold on

% fixed sem
if ~exist('sem')
    sem = nanstd(param.midpoint)'./sqrt(nsub);
    sem = sem(1);
end

brickplot2(...
    param.midpoint', sem,...
    orange_color.*ones(3, 8)', ...
    [0, 1], fontsize,...
    '',...
    '',...
    '', varargin, 1, x_lim, x_values);
box off

title('Fitted midpoints');


% Brickplot midpoint based on actual intersections 
% -----------------------  ------------------------------------- %
subplot(1, 4, 2)

y1 = ones(1, 11).* .5;
x = linspace(0, 1, 11);

hold on

for sub = 1:nsub
    for i = 1:length(psym)
        
        y2 = reshape(fitted_p_choose_symbol(sub, i, :), [], 1);
        [xout(sub, i), yout] = intersections(x, y2, x, y1);

        box off
    end
end

slope1 = add_linear_reg(xout, ev, orange_color);


brickplot2(...
    xout', sem,...
    orange_color.*ones(3, 8)', ...
    [0, 1], fontsize,...
    '',...
    '',...
    '', varargin, 1, x_lim, x_values);
box off
title('Intersection midpoints');


% Indifference curves aggregation of fits
% -----------------------  ------------------------------------- %
subplot(1, 4, 3)

alpha = linspace(.15, .95, length(psym));

lin1 = plot(...
    linspace(0, 1, 10), ones(10,1).*.5,...
    'LineStyle', ':', 'Color', [0, 0, 0], 'HandleVisibility', 'off');
hold on

for i = 1:length(psym)
    
    Y = reshape(mean(fitted_p_choose_symbol(:, i, :), 1), [], 1);
    
    lin3 = plot(...
        p_lot, Y,...
        'Color', orange_color, 'LineWidth', 4.5);
    
    lin3.Color(4) = alpha(i);
    
    hold on
    
    [xout2, yout] = intersections(lin3.XData, lin3.YData,...
        lin1.XData, lin1.YData);
    
    sc2 = scatter(xout2, yout, 80, 'MarkerFaceColor', lin3.Color,...
        'MarkerEdgeColor', 'w');
    sc2.MarkerFaceAlpha = alpha(i);
    
     
    ylim([-0.08, 1.08]);
    xlim([-0.08, 1.08]);
    
    box off
end

title('Averaged fitted curves');


% Indifference curves bhv
% -----------------------  ------------------------------------- %
subplot(1, 4, 4)

lin1 = plot(...
    linspace(psym(1), psym(end), 12), ones(12,1)*0.5,...
    'LineStyle', ':', 'Color', [0, 0, 0], 'HandleVisibility', 'off');
hold on 

for i = 1:length(psym)
    
    lin3 = plot(...
        p_lot, prop(i, :),...
        'Color', orange_color, 'LineWidth', 4.5);
    
    
    lin3.Color(4) = alpha(i);
    
    hold on
    
    [xout3, yout] = intersections(lin3.XData, lin3.YData, lin1.XData, lin1.YData);
    
    sc2 = scatter(xout3, yout, 80, 'MarkerFaceColor', lin3.Color,...
        'MarkerEdgeColor', 'w');
    sc2.MarkerFaceAlpha = alpha(i);
       
    ylim([-0.08, 1.08]);
    xlim([-0.08, 1.08]);
    
    box off
end

title('Averaged bhv');

%% side functions
% fit functions
% ------------------------------------------------------------------------
function sumres = tofit(temp, X, Y)
    options = optimset('Display','off');
    for i = 1:size(Y, 1)
        [throw, throw2, residuals(i, :)] = lsqcurvefit(...
            @(midpoint, x) (logfun(x, midpoint, temp)),...
            [0], X(i, :)', Y(i, :)', [0], [1], options);

    end
    sumres = sum(residuals.*residuals, 'all');
end

function p = logfun(x, midpoint, temp)
    p = 1./(1+exp(temp.*(x-midpoint(1))));
end
