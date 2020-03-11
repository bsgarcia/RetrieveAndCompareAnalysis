%-------------------------------------------------------------------------
init;
%-------------------------------------------------------------------------

selected_exp = [1, 2, 8, 3];
sessions = [0, 1];

displayfig = 'on';

count_sub = 0;
count_sub2 = 0;
for exp_num = selected_exp
    
    idx1 = (exp_num - round(exp_num)) * 10;
    if idx1 == 0
        idx1 = 1;
    end
    sess = sessions(uint64(idx1));
    
    % load data
    name = char(filenames{round(exp_num)});
    
    data = d.(name).data;
    sub_ids = d.(name).sub_ids;
    nsub = d.(name).nsub;
    
    [corr, cho_, out, p1_, p2_, ev1, ev2, ctch, cont1, cont2, dist, rtime] = ...
        DataExtraction.extract_estimated_probability_post_test(data, sub_ids, idx, sess);
    if exp_num == 8
        order = [1, 4, 5, 8];
    else
        order = 1:8;
    end
    for sub = 1:nsub
        i = 1;
        count_sub = count_sub + 1;
        for p = unique(p1_)'
            qvalues(count_sub, order(i)) = cho_(sub, (p1_(sub, :) == p))./100;
            i = i + 1;
        end
    end
    if exp_num == 8
        qvalues(:, [2, 3, 6, 7]) = NaN;
    end
    
    [corr, cho1, out2, p1_1, p2_1, ev1, ev2, ctch, cont1, cont2, dist] = ...
        DataExtraction.extract_sym_vs_lot_post_test(...
        data, sub_ids, idx, sess);
    for sub = 1:size(cho1, 1)
        count_sub2 = count_sub2 + 1;
        
        if exp_num == 8
            cho(count_sub2, 1:44) = cho1(sub, :);
            cho(count_sub2, 45:end) = NaN;
            p1(count_sub2, 1:44) = p1_1(sub,:);
            p2(count_sub2, 1:44) = p2_1(sub,:);
            p1(count_sub2, 45:end) = NaN;      
            p2(count_sub2, 45:end) = NaN;
            
        else
            cho(count_sub2, :) = cho1(sub, :);
            p1(count_sub2, :) = p1_1(sub,:);
            p2(count_sub2, :) = p2_1(sub,:);
            
        end
    end
end
%     if exp_num == 8
%         exp_num = 4;
%     end
figure('Position', [1,1,900,600]);

y0 = yline(0.5, 'LineStyle', ':', 'LineWidth', 0.3);
hold on
ev = unique(p1_);
x_values = unique(p1_);
varargin = x_values;
x_lim = [0, 1];

p0 = plot(linspace(0, 1, 10), linspace(0, 1, 10), 'LineStyle', '--', 'Color', 'k');
p0.Color(4) = .5;
hold on

brickplot2(...
    qvalues',...
    magenta_color.*ones(length(x_values), 1),...
    [0, 1], 11,...
    '',...
    'P(win)',...
    'PM Estimated P(win)', varargin, 1, x_lim, x_values);

box off
hold on

set(gca,'TickDir','out')

% x_lim = get(gca, 'XLim');
% y_lim = get(gca, 'YLim');
% 
% x = linspace(x_lim(1), x_lim(2), 10);
% y = linspace(y_lim(1), y_lim(2), 10);


for sub = 1:size(qvalues, 1)
    
    Y = qvalues(sub, :);
    
    if any(isnan(Y))
        X = [.1, .4, .6, .9];
        Y = qvalues(sub, [1, 4, 5, 8]);
        b = glmfit(X, Y);
        pY2(sub, [1, 4, 5, 8]) = glmval(b,X, 'identity');
        pY2(sub, [2, 3, 6, 7]) = NaN;
        
    else
        X = ev;
        b = glmfit(X, Y);
        pY2(sub, :) = glmval(b,X, 'identity');
    end
    
    
end


mn2 = nanmean(pY2, 1);
err2 = nanstd(pY2, 1)./sqrt(size(qvalues, 1));

curveSup2 = (mn2 + err2);
curveInf2 = (mn2 - err2);

%     pl1 = plot(ev, mn2, 'LineWidth', 1.7, 'Color', magenta_color);
%     hold on
%
%     pl2 = fill([...
%          (ev); flipud((ev))],...
%         [curveInf2'; flipud(curveSup2')],...
%         magenta_color, ...
%         'lineWidth', 1, ...
%         'LineStyle', 'none',...
%         'Facecolor', magenta_color, ...
%         'Facealpha', 0.25);
%     hold on
%
box off
set(gca, 'fontsize', 22);

%
%d.(name).nsub = size(cho, 1);
% ----------------------------------------------------------------------
% Compute for each symbol p of chosing depending on described cue value
% ------------------------------------------------------------------------
p_lot = unique(p2(~isnan(p2)))';
p_sym = unique(p1(~isnan(p1)))';
nsub = size(cho, 1);
chose_symbol = zeros(nsub, length(p_lot), length(p_sym));

for i = 1:nsub
    for j = 1:length(p_lot)
        for k = 1:length(p_sym)
            temp = ...
                cho(i, logical(...
                (p2(i, :) == p_lot(j)) .* (p1(i, :) == p_sym(k))));
            
            try
                chose_symbol(i, j, k) = temp == 1;
            catch
                chose_symbol(i, j, k) = NaN;
            end

        end
    end
end

prop = zeros(length(p_sym), length(p_lot));
temp1 = cho(:, :);
for i = 1:length(p_sym)
    for j = 1:length(p_lot)
        temp = temp1(...
            logical((p2(:, :) == p_lot(j)) .* (p1(:, :) == p_sym(i))));
        prop(i, j) = mean(temp == 1);
        err_prop(i, j) = std(temp == 1)./sqrt(length(temp));
        
    end
end

X = reshape(...
    repmat(p_lot, nsub, 1), [], 1....
    );

pp = zeros(length(p_sym), length(p_lot));

for i = 1:length(p_sym)
    
    Y = reshape(chose_symbol(:, :, i), [], 1);
    
    [logitCoef, dev] = glmfit(X, Y, 'binomial','logit');
    
    pp(i, :) = glmval(logitCoef, p_lot', 'logit');
    
end


for i = 1:length(p_sym)
    
    
    lin3 = plot(...
        p_lot,  pp(i, :),...
        'Color', [1 1 1], 'LineWidth', 4.5,...% 'LineStyle', '--' ...
        'handlevisibility', 'off');
    
    lin3.Color(4) = 0.0;
    
    ind_point(i) = interp1(lin3.YData, lin3.XData, 0.5);
    
    s = scatter(x_values(i), ind_point(i), 120, 'MarkerEdgeColor', 'w', ...
        'MarkerFaceColor', 'k');
    s.MarkerFaceAlpha = 0.7;
    hold on
    
    
end

%     X = x_values;
%     Y = ind_point;
%     b = glmfit(x_values, Y);
%     values = glmval(b,X, 'identity');
%
%     mn2 = mean(pY2, 1);
%     err2 = std(pY2, 1)./sqrt(size(qvalues, 1));
%
%     curveSup2 = (mn2 + err2);
%     curveInf2 = (mn2 -err2);

%     pl1 = plot(x_values, values, 'LineWidth', 1.7, 'Color', 'k');
%     pl1.Color(4) = .6;
hold on
clear pp p_lot p_sym temp err_prop prop i p1 p2 cho

mkdir('fig/exp', 'post_test_p_likert_2');
saveas(gcf, ...
    sprintf('fig/exp/post_test_p_likert_2/exp_%s.png',...
    num2str(exp_num)));

%
%     figure('Position', [1,1,900,600]);
%
%     for i = 1:d.(name).nsub
%         p = plot(unique(p1), qvalues(i, :), 'Color', red_color);
%         p.Color(4) = 0.5;
%         hold on
%     end
%
%     p = plot(unique(p1), mean(qvalues, 1), 'Color', red_color, 'linewidth', 4);
%     hold on
%
%


%
%     for sub = 1:nsub
%         Q(sub, 1, 1) = qvalues(sub, 8);
%         Q(sub, 1, 2) = qvalues(sub, 1);
%         Q(sub, 2, 1) = qvalues(sub, 7);
%         Q(sub, 2, 2) = qvalues(sub, 2);
%         Q(sub, 3, 1) = qvalues(sub, 6);
%         Q(sub, 3, 2) = qvalues(sub, 3);
%         Q(sub, 4, 1) = qvalues(sub, 5);
%         Q(sub, 4, 2) = qvalues(sub, 4);
%     end
%     nagent = 100;
%     [cho, cont1, cont2, p1, p2, ev1, ev2] = sim_exp_ED(name, d, idx, sess, 0, nagent, Q);
%
%     nsub = size(cho, 1);
%     % ----------------------------------------------------------------------
%     % Compute for each symbol p of chosing depending on described cue value
%     % ------------------------------------------------------------------------
%
%     pcue = unique(p2)';
%     psym = unique(p1)';
%
%     chose_symbol = zeros(nsub, length(pcue), length(psym));
%     for i = 1:nsub
%         for j = 1:length(pcue)
%             for k = 1:length(psym)
%                 temp = ...
%                     cho(i, logical((p2(i, :) == pcue(j)) .* (p1(i, :) == psym(k))));
%                 for l = 1:length(temp)
%                     chose_symbol(i, j, k, l) = temp(l) == 1;
%
%                 end
%             end
%         end
%     end
%
%     nsub = size(cho, 1);
%     k = 1:nsub;
%
%     prop = zeros(length(psym), length(pcue));
%     temp1 = cho(k, :);
%     for j = 1:length(pcue)
%         for l = 1:length(psym)
%             temp = temp1(...
%                 logical((p2(k, :) == pcue(j)) .* (p1(k, :) == psym(l))));
%             prop(l, j) = mean(temp == 1);
%             err_prop(l, j) = std(temp == 1)./sqrt(length(temp));
%
%         end
%     end
%
%     X = reshape(...
%         repmat(pcue, size(k, 2), size(chose_symbol, 4)), [], 1....
%     );
%
%     pp = zeros(length(psym), length(pcue));
%
%     for i = 1:length(psym)
%         Y = reshape(chose_symbol(k, :, i, :), [], 1);
%         [logitCoef, dev] = glmfit(...
%             X, Y, 'binomial','logit');
%         pp(i, :) = glmval(logitCoef, pcue', 'logit');
%     end
%
%     figure(...
%         'Renderer', 'painters',...
%         'Position', [961, 1, 900, 550],...
%         'visible', displayfig)
%
%     pwin = psym;
%     alpha = [fliplr(linspace(.5, 1, 4)), linspace(.5, 1, 4)];
%
%     lin1 = plot(...
%         linspace(0, 1, 12), ones(12)*0.5,...
%         'LineStyle', ':', 'Color', [0, 0, 0], 'HandleVisibility', 'off');
%
%     for i = 1:length(pwin)
%
%         if ~ismember(i, [1, 8])
%             continue
%         end
%
%         if pwin(i) < .5
%             color = red_color;
%         else
%             color = blue_color;
%         end
%
%         hold on
%
%         lin3 = plot(...
%                 pcue,  pp(i, :),...
%                 'Color', color, 'LineWidth', 4.5 ...
%                 );
%
%         lin3.Color(4) = alpha(i);
%
%         hold on
%
%         sc1 = scatter(pcue, prop(i, :), 180,...
%             'MarkerEdgeColor', 'w',...
%             'MarkerFaceColor', color, 'MarkerFaceAlpha', 0.65);
%         hold on
%         errorbar(sc1.XData, prop(i, :), err_prop(i, :), 'Color', color,...
%             'LineStyle', 'none', 'LineWidth', 1.7);%, 'CapSize', 2);
%         hold on
%
%         ind_point = interp1(lin3.YData, lin3.XData, 0.5);
%
%         sc2 = scatter(ind_point, 0.5, 200, 'MarkerFaceColor', 'k',...
%                 'MarkerEdgeColor', 'w');
%
%         ylabel('P(choose experienced cue)', 'FontSize', 26);
%         xlabel('Described cue win probability', 'FontSize', 26);
%
%         ylim([-0.08, 1.08]);
%         xlim([-0.08, 1.08]);
%
%         text(...
%                 ind_point + (0.05) * (1 + (-4 * (i == 1))) ,...
%                 .55, sprintf('%.2f', ind_point), 'Color', 'k', 'FontSize', 25);
%
%         box off
%         set(gca, 'Fontsize', 23);
%
%         plot(pwin(i) .*  ones(10, 1), linspace(.2, .8, 10), 'Color', color, 'LineStyle', ':', 'LineWidth', 5);
%         disp(pwin(i));
%         hold on
%
%     end
%
%   s1 = title(sprintf('Sim (likert estimated P(win)) Exp. %.1f', exp_num));
%    set(s1, 'Fontsize', 20)
%     set(gca,'TickDir','out')
%
%     mkdir('fig/exp', 'sim_Likert_ind_curves');
%     saveas(gcf, ...
%         sprintf('fig/exp/sim_Likert_ind_curves/ind_curve_with_dots_exp_%d_sym_vs_lot.png',...
%         exp_num));
%
% end