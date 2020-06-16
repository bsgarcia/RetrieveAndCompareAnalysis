%-------------------------------------------------------------------------
init;
%-------------------------------------------------------------------------

selected_exp = [6.2];
sessions = [0, 1];

displayfig = 'on';

figure('Renderer', 'painters',...
    'Position', [145,157,3312-3312/4,600], 'visible', 'on')

num = 0;
for exp_num = selected_exp
    num = num + 1;
    
    clear qvalues b pY2 ind_point Y
    
    idx1 = (exp_num - round(exp_num)) * 10;
    idx1 = idx1 + (idx1==0);
    sess = sessions(uint64(idx1));
    % load data
    name = char(filenames{round(exp_num)});
    
    data = d.(name).data;
    sub_ids = d.(name).sub_ids;
    nsub = d.(name).nsub;
    
    [corr, cho, out, p1, p2, ev1, ev2, ctch, cont1, cont2, dist, rtime] = ...
        DataExtraction.extract_estimated_probability_post_test...
        (data, sub_ids, idx, sess);
    
    for sub = 1:nsub
        i = 1;
        
        for p = unique(p1)'
            qvalues(sub, i) = cho(sub, (p1(sub, :) == p))./100;
            i = i + 1;
        end
    end
    
    %figure('Position', [1,1,900,600], 'renderer', 'painters');
        
    ev = unique(p1);
    varargin = ev;
    x_values = ev;
    x_lim = [0, 1];
    
    %     if exp_num == 4
    %
    %     end
    
    
    brickplot2(...
        qvalues',...
        magenta_color.*ones(length(ev), 1),...
        [0, 1], 11,...
        '',...
        '',...
        '', varargin, 1, x_lim, x_values, .18);
    
    if exp_num == 1
        ylabel('Probability matching');
    end
    
    xlabel('Experienced cue win probability');
    %     brickplot(...
    %         qvalues',...
    %         blue_color.*ones(8, 1),...
    %         [-1, 1], 11,...
    %         '',...
    %         'Symbol Expected Value',...
    %         'Q-value', ev, 1);
    box off
    hold on
    
    %set(gca, 'ytick', [0:10]./10);
    set(gca,'TickDir','out')
    
    
    %     if ismember(exp_num, [5, 6, 7])
    %         title(sprintf('Exp. %d Sess. %d', exp_num, session+1));
    %     else
    %title(sprintf('Exp. %s', num2str(exp_num)));
    %     end
    
    x_lim = get(gca, 'XLim');
    y_lim = get(gca, 'YLim');
    
    y0 = plot(linspace(x_lim(1), x_lim(2), 10),...
        ones(10).*0.5, 'LineStyle', ':', 'Color', [0 0 0]);
    
    hold on
    
    x = linspace(x_lim(1), x_lim(2), 10);
    
    y = linspace(y_lim(1), y_lim(2), 10);
    p0 = plot(x, y, 'LineStyle', '--', 'Color', 'k');
    p0.Color(4) = .45;
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
    
    pl1 = plot(ev, mn2, 'LineWidth', 1.7, 'Color', magenta_color);
    hold on
    
    pl2 = fill([...
        (ev); flipud((ev))],...
        [curveInf2'; flipud(curveSup2')],...
        magenta_color, ...
        'lineWidth', 1, ...
        'LineStyle', 'none',...
        'Facecolor', magenta_color, ...
        'Facealpha', 0.25);
    hold on
    
    box off
    set(gca, 'fontsize', fontsize);
    
   
    clear pp p_lot p_sym temp err_prop prop i p1 p2 cho
    
    %     mkdir('fig/exp', 'post_test_PM');
    %     saveas(gcf, ...
    %         sprintf('fig/exp/post_test_PM/exp_%s_2.png',...
    %         num2str(exp_num)));
end