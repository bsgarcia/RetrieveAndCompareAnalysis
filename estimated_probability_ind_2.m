%-------------------------------------------------------------------------
init;
%-------------------------------------------------------------------------

selected_exp = [5];
sessions = [0, 1];

nagent = 10;
EE_points = 1;
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
    
    subplot(1, 2, num);
    
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
    
    if EE_points
        idx1 = (exp_num - round(exp_num)) * 10;
        idx1 = idx1 + (idx1==0);
        sess = sessions(uint64(idx1));
        
        % load data
        name = char(filenames{round(exp_num)});
        
        data = d.(name).data;
        sub_ids = d.(name).sub_ids;
        
        [corr, cho, out2, p1, p2, ev1, ev2, ctch, cont1, cont2, dist] = ...
            DataExtraction.extract_sym_vs_lot_post_test(...
            data, sub_ids, idx, sess);
        %
        %d.(name).nsub = size(cho, 1);
        % ----------------------------------------------------------------------
        % Compute for each symbol p of chosing depending on described cue value
        % ------------------------------------------------------------------------
        p_lot = unique(p2)';
        p_sym = unique(p1)';
        nsub = d.(name).nsub;
        chose_symbol = zeros(nsub, length(p_lot), length(p_sym));
        for i = 1:nsub
            for j = 1:length(p_lot)
                for k = 1:length(p_sym)
                    temp = ...
                        cho(i, logical(...
                        (p2(i, :) == p_lot(j)) .* (p1(i, :) == p_sym(k))));
                    chose_symbol(i, j, k) = temp == 1;
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
            
            s = scatter(x_values(i), ind_point(i), 80, 'MarkerEdgeColor', 'w', ...
                'MarkerFaceColor', orange_color);
            s.MarkerFaceAlpha = 0.7;
            hold on
        end
        
        clear pp p_lot p_sym temp err_prop prop i p1 p2 cho
        
        [corr, cho, out2, p1, p2, ev1, ev2, ctch, cont1, cont2, dist] = ...
            DataExtraction.extract_sym_vs_sym_post_test(...
            data, sub_ids, idx, sess);
        %
        %d.(name).nsub = size(cho, 1);
        % ----------------------------------------------------------------------
        % Compute for each symbol p of chosing depending on described cue value
        % ------------------------------------------------------------------------
        p_lot = unique(p2)';
        p_sym = unique(p1)';
        nsub = d.(name).nsub;
        chose_symbol = zeros(nsub, length(p_lot), length(p_sym));
        for i = 1:nsub
            for j = 1:length(p_lot)
                for k = 1:length(p_sym)
                    temp = ...
                        cho(i, logical(...
                        (p2(i, :) == p_lot(j)) .* (p1(i, :) == p_sym(k))));
                    if length(temp)
                        chose_symbol(i, j, k) = temp == 1;
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
        
        
        for i = 1:8
            
%             
%             lin3 = plot(...
%                 p_lot,  prop(i, :),...
%                 'Color', [1 1 1], 'LineWidth', 4.5,...% 'LineStyle', '--' ...
%                 'handlevisibility', 'off');
%             
%             lin3.Color(4) = 0.0;
            try
            pp1 = unique(prop(i, isfinite(prop(i,:))), 'stable');        
            ind_point(i) = interp1(pp1, linspace(0, 1, length(pp1)), 0.5);
            
            s = scatter(x_values(i), ind_point(i), 80, 'MarkerEdgeColor', 'w', ...
                'MarkerFaceColor', blue_color);
            s.MarkerFaceAlpha = 0.7;
            hold on
            catch
            end
            
        end
        
        for i = 1:8
            
            try
            ind_point(i) = interp1(pp(i,:), linspace(0, 1, length(pp(i,:))), 0.5);
            
            s = scatter(x_values(i), ind_point(i), 80, 'MarkerEdgeColor', 'w', ...
                'MarkerFaceColor', blue_color);
            s.MarkerFaceAlpha = 0.7;
            hold on
            catch
            end
            
        end
        
        
        %         X = ev;
        %         Y = ind_point;
        %         b = glmfit(ev, Y);
        %         values = glmval(b,X, 'identity');
        %     %
        %     %     mn2 = mean(pY2, 1);
        %     %     err2 = std(pY2, 1)./sqrt(size(qvalues, 1));
        %     %
        %     %     curveSup2 = (mn2 + err2);²
        %     %     curveInf2 = (mn2 -err2);
        %
        %         pl1 = plot(ev, values, 'LineWidth', 1.7, 'Color', 'k');
        %         pl1.Color(4) = .6;
        %         hold on
    end
    
    clear pp p_lot p_sym temp err_prop prop i p1 p2 cho
    
    %     mkdir('fig/exp', 'post_test_PM');
    %     saveas(gcf, ...
    %         sprintf('fig/exp/post_test_PM/exp_%s_2.png',...
    %         num2str(exp_num)));
end

mkdir('fig/exp', 'post_test_PM');
saveas(gcf, ...
    sprintf('fig/exp/post_test_PM/full_figure3.svg'));