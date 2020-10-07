%-------------------------------------------------------------------------
init;
%-------------------------------------------------------------------------

figure('Renderer', 'painters', 'position', [0, 0, 828*3, 600*3],...
    'visible', 'on')

force = false;

exp_num = 3;
sess = 0;
model = 1;
decision_rule = 1;

beta_params = {...
    {[6, 2], [6, 2]}, {[6,2], [2, 6]}, {[2,6], [6,2]}...
  };
    

for num = [1, 2, 3]

    % load data
    name = char(filenames{round(exp_num)});

    data = d.(name).data;
    sub_ids = d.(name).sub_ids;

    beta_dist = [1, 1];
    gam_dist = [1.2, 5];

    options.alpha1 = betarnd(beta_dist(1),...
        beta_dist(2), [d.(name).nsub, 1]);
    options.beta1 = gamrnd(gam_dist(1),...
        gam_dist(2), [d.(name).nsub, 1]);
    options.random = true;
    
    %options.beta1 = ones(d.(name).nsub, 1);
    options.degradors = ones(d.(name).nsub, 2);
    options.degradors(:, 2) = betarnd(beta_params{num}{1}(1),...
        beta_params{num}{1}(2), [d.(name).nsub, 1]);
    options.degradors(:, 1) = betarnd(beta_params{num}{2}(1),...
        beta_params{num}{2}( 2), [d.(name).nsub, 1]);
    
    [cho, cont1, cont2, p1, p2, ev1, ev2] = sim_exp_ED(...
        name, exp_num, d, idx, sess, model, decision_rule, 1, options);

    pcue = unique(p2)';
    psym = unique(p1)';
    
    nsub = size(cho, 1);
    chose_symbol = zeros(nsub, length(pcue), length(psym), 1);
    for i = 1:nsub
        for j = 1:length(pcue)
            for k = 1:length(psym)
                temp = ...
                    cho(i, logical((p2(i, :) == pcue(j)) .* (p1(i, :) == psym(k))));
                for l = 1:length(temp)
                    chose_symbol(i, j, k, l) = temp(l) == 1;
                end
            end
        end
    end

    k = randsample(1:size(cho, 1), size(cho, 1), false);

    prop = zeros(length(psym), length(pcue));
    temp1 = cho(k, :);
    for j = 1:length(pcue)
        for l = 1:length(psym)
            temp = temp1(...
                logical((p2(k, :) == pcue(j)) .* (p1(k, :) == psym(l))));
            prop(l, j) = mean(temp == 1);
            err_prop(l, j) = std(temp == 1)./sqrt(length(temp));

        end
    end


    pp = zeros(length(k), length(psym), length(pcue));

    for sub = 1:length(k)

        for i = 1:length(psym)
            Y(i, :) = reshape(chose_symbol(sub, :, i, 1), [], 1);
            X(i, :) = pcue;
        end

        try
            if force
                error('fitting');
            end
            param = load(sprintf('data/method_xp_%d.mat', num));
            beta1 = param.beta1;
            shift = param.shift;
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
                [0],...
                [inf],...
                [],...
                options...
                );

            options = optimset('Display','off');

            for i = 1:length(psym)
                shift(sub, i) = lsqcurvefit(...
                    @(shift, x) (logfun(x, shift, beta1(sub))),...
                    [0], X(i, :)', Y(i, :)', [0], [1], options);
            end

        end

        for i = 1:length(psym)
            pp(sub, i, :) = logfun(X(i, :)', shift(sub, i), beta1(sub));
        end

    end

    if tosave
        param.shift = shift;
        param.beta1 = beta1;
        param.res = res;

        save(sprintf('data/method_xp_%d.mat', num),...
            '-struct', 'param');
    end

    ev = unique(p1).*100;
    varargin = ev;
    x_values = ev;
    x_lim = [0, 100];
    
    
    
    % ----------------------- Plot ------------------------------------- % 
    subplot(3, 3, num)

    slope1 = add_linear_reg(param.shift.*100, ev, orange_color);
    hold on
    
    if ~exist('sem')
        sem = nanstd(param.shift.*100)'/sqrt(83);
        sem = sem(1);
    end

    brickplot2(...
        param.shift'.*100, sem,...
        orange_color.*ones(3, 8)', ...
        [0, 100], fontsize,...
        '',...
        '',...
        '', varargin, 1, x_lim, x_values);
    box on
%     set(gca,'ytick',[])
%     set(gca,'yticklabel',[])
%     set(gca,'xtick',[])
%     set(gca,'xticklabel',[])

    subplot(3, 3, num+3)
    pwin = psym;
    
    alpha = linspace(.15, .95, length(psym));
    lin1 = plot(...
        linspace(psym(1), psym(end), 12), ones(12,1)*0.5,...
        'LineStyle', ':', 'Color', [0, 0, 0], 'HandleVisibility', 'off');
    hold on
    lin1 = plot(...
        linspace(psym(1)*100-10, psym(end)*100+10, 12), ones(12,1)*50,...
        'LineStyle', ':', 'Color', [0, 0, 0], 'HandleVisibility', 'off');
    
    for i = 1:length(pwin)
    
        hold on
    
    
        lin3 = plot(...
            pcue.*100, reshape(mean(pp(:, i, :)), [], 1).*100,...
            'Color', orange_color, 'LineWidth', 4.5);
    
    
        lin3.Color(4) = alpha(i);
    
        hold on
    
        [xout, yout] = intersections(lin3.XData, lin3.YData, lin1.XData, lin1.YData);
    
        sc2 = scatter(xout, yout, 80, 'MarkerFaceColor', lin3.Color,...
            'MarkerEdgeColor', 'w');
        sc2.MarkerFaceAlpha = alpha(i);
    
    
        xlabel('Lottery p(win) (%)');
    
        ylim([-0.08*100, 1.08*100]);
        xlim([-0.08*100, 1.08*100]);
    
        box off
    end
    
    subplot(3, 3, num+6)
    
    pwin = psym;
    
    alpha = linspace(.15, .95, length(psym));
    
    lin1 = plot(...
        linspace(psym(1), psym(end), 12), ones(12,1)*0.5,...
        'LineStyle', ':', 'Color', [0, 0, 0], 'HandleVisibility', 'off');
    hold on
    
    lin1 = plot(...
        linspace(psym(1)*100-10, psym(end)*100+10, 12), ones(12,1)*50,...
        'LineStyle', ':', 'Color', [0, 0, 0], 'HandleVisibility', 'off');
    
    for i = 1:length(pwin)
    
        hold on
    
    
        lin3 = plot(...
            pcue.*100, prop(i, :)*100,...
            'Color', orange_color, 'LineWidth', 4.5);
    
    
        lin3.Color(4) = alpha(i);
    
        hold on
    
        [xout, yout] = intersections(lin3.XData, lin3.YData, lin1.XData, lin1.YData);
    
        sc2 = scatter(xout, yout, 80, 'MarkerFaceColor', lin3.Color,...
            'MarkerEdgeColor', 'w');
        sc2.MarkerFaceAlpha = alpha(i);
    
    
        xlabel('Lottery p(win) (%)');
    
        ylim([-0.08*100, 1.08*100]);
        xlim([-0.08*100, 1.08*100]);
    
        box off
    end
end

%saveas(gcf, 'fig/exp/brickplot/methods.svg');


function sumres = tofit(temp, X, Y)
options = optimset('Display','off');
for i = 1:size(Y, 1)
    [throw, throw2, residuals(i, :)] = lsqcurvefit(...
        @(shift, x) (logfun(x, shift, temp)),...
        [0], X(i, :)', Y(i, :)', [0], [1], options);
    
end
sumres = sum(residuals.*residuals, 'all');
end

function p = logfun(x, shift, temp)
    p = 1./(1+exp(temp.*(x-shift(1))));
end
