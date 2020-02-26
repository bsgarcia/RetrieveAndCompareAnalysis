%-------------------------------------------------------------------------
init;
%-------------------------------------------------------------------------

titles = {
        'Exp. 4'};
selected_exp = [1, 2, 3, 4, 5.2, 6.2, 7.2];
%selected_exp = selected_exp(1);
sessions = [0, 1];


displayfig = 'on';


for exp_num = selected_exp
    
    disp(exp_num);
    
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
    
    [corr, cho, out, p1, p2, ev1, ev2, ctch, cont1, cont2, dist, rtime] = ...
                DataExtraction.extract_estimated_probability_post_test(data, sub_ids, idx, sess);
            
    for sub = 1:nsub
            i = 1;      

        for p = unique(p1)'
            qvalues(sub, i) = cho(sub, (p1(sub, :) == p))./100;
            i = i + 1;          
        end
    end
    
    figure('Position', [1,1,900,600]);

    
    ev = unique(p1);
    x_values = unique(p1);
    varargin = [.1, .2, .3, .4, .6, .7, .8, .9];
    x_lim = [0, 1];
    
    brickplot2(...
        qvalues',...
        red_color.*ones(8, 1),...
        [0, 1], 11,...
        '',...
        'P(win)',...
        'Likert Estimated P(win)', varargin, 1, x_lim, x_values);
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
        title(sprintf('Exp. %s', num2str(exp_num)));
%     end

    y0 = yline(0.5, 'LineStyle', ':', 'LineWidth', 2);
    hold on
    
    x_lim = get(gca, 'XLim');
    y_lim = get(gca, 'YLim');
    
    x = linspace(x_lim(1), x_lim(2), 10);
    
    y = linspace(y_lim(1), y_lim(2), 10);
    p0 = plot(x, y, 'LineStyle', '--', 'Color', 'k');
    hold on
    
    for sub = 1:size(qvalues, 1)
        X = ev;
        Y = qvalues(sub, :);
        [r(1, sub, :), thrw1, thrw2] = glmfit(X, Y);
        b = glmfit(ev, Y);
        pY2(sub, :) = glmval(b,ev, 'identity');
    end
    
    mn2 = mean(pY2, 1);
    err2 = std(pY2, 1)./sqrt(size(qvalues, 1));
    
    curveSup2 = (mn2 + err2);
    curveInf2 = (mn2 -err2);
    
    pl1 = plot(ev, mn2, 'LineWidth', 1.7, 'Color', red_color);
    hold on
    
    pl2 = fill([...
         (ev); flipud((ev))],...
        [curveInf2'; flipud(curveSup2')],...
        red_color, ...
        'lineWidth', 1, ...
        'LineStyle', 'none',...
        'Facecolor', red_color, ...
        'Facealpha', 0.55);
    hold on
        
    box off
    set(gca, 'fontsize', 22);
    
    mkdir('fig/exp', 'post_test_p_likert');
    saveas(gcf, ...
        sprintf('fig/exp/post_test_p_likert/exp_%s.png',...
        num2str(exp_num)));
    
   
    figure('Position', [1,1,900,600]);
    
    for i = 1:d.(name).nsub
        p = plot(unique(p1), qvalues(i, :), 'Color', red_color);
        p.Color(4) = 0.5;
        hold on
    end
    
    p = plot(unique(p1), mean(qvalues, 1), 'Color', red_color, 'linewidth', 4);
    hold on

    
    
end
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