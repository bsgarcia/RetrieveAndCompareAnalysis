%-------------------------------------------------------------------------
init;
%-------------------------------------------------------------------------


selected_exp = [1, 2, 3, 4, 5.2, 6.2, 7.2];
%selected_exp = selected_exp(7);
displayfig = 'on';
sessions = [0, 1];

for exp_num = selected_exp
    
    
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
    
    d.(name).nsub = size(cho, 1);
    % ----------------------------------------------------------------------
    % Compute for each symbol p of chosing depending on described cue value
    % ------------------------------------------------------------------------
    
    pcue = unique(p2)';
    psym = unique(p1)';
    
    chose_symbol = zeros(d.(name).nsub, length(pcue), length(psym), 1);
    for i = 1:d.(name).nsub
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
    
    nsub = size(cho, 1);
    k = 1:nsub;
    
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
    
    X = reshape(...
        repmat(pcue, size(k, 2), size(chose_symbol, 4)), [], 1....
        );
    
    pp = zeros(length(psym), length(pcue));
    
    for i = 1:length(psym)
        Y = reshape(chose_symbol(k, :, i, :), [], 1);
        [logitCoef, dev] = glmfit(...
            X, Y, 'binomial','logit');
        pp(i, :) = glmval(logitCoef, pcue', 'logit');
    end
    
    figure(...
        'Renderer', 'painters',...
        'Position', [961, 1, 900, 550],...
        'visible', displayfig)
    
    pwin = psym;
    alpha = [fliplr(linspace(.5, 1, 4)), linspace(.5, 1, 4)];
    
    lin1 = plot(...
        linspace(0, 1, 12), ones(12)*0.5,...
        'LineStyle', ':', 'Color', [0, 0, 0], 'HandleVisibility', 'off');
    
    for i = 1:length(pwin)
        
        if ~ismember(i, [1, 8])
            continue
        end
        
        if pwin(i) < .5
            color = red_color;
        else
            color = blue_color;
        end
        
        hold on
        
        lin3 = plot(...
            pcue,  pp(i, :),...
            'Color', color, 'LineWidth', 4.5...% 'LineStyle', '--' ...
            );
        
        lin3.Color(4) = 0;
        
        hold on
        
        sc1 = scatter(pcue, prop(i, :), 180,...
            'MarkerEdgeColor', 'w',...
            'MarkerFaceColor', color, 'MarkerFaceAlpha', 0.65);
        
        hold on
        try
            errorbar(sc1.XData, prop(i, :), err_prop(i, :), 'Color', color, 'LineStyle', 'none', 'LineWidth', 1.7);%, 'CapSize', 2);
        catch
            
            
            
        end
        ind_point = interp1(lin3.YData, lin3.XData, 0.5);
        
        sc2 = scatter(ind_point, 0.5, 200, 'MarkerFaceColor', 'k',...
            'MarkerEdgeColor', 'w');
        
        ylabel('P(choose experienced cue)', 'FontSize', 26);
        xlabel('Described cue win probability', 'FontSize', 26);
        
        ylim([-0.08, 1.08]);
        xlim([-0.08, 1.08]);
        
        text(...
            ind_point + (0.05) * (1 + (-4 * (i == 1))) ,...
            .55, sprintf('%.2f', ind_point), 'Color', 'k', 'FontSize', 25);
        
        box off
        set(gca, 'Fontsize', 23);
        
        plot(pwin(i) .*  ones(10, 1), linspace(.2, .8, 10), 'Color', color, 'LineStyle', ':', 'LineWidth', 3.5);
        hold on
        
    end
    clear pp pcue psym temp err_prop prop i
    
    
    [corr, cho, out, p1, p2, ev1, ev2, ctch, cont1, cont2, dist, rtime] = ...
        DataExtraction.extract_estimated_probability_post_test(data, sub_ids, idx, sess);
    nsub = size(cho, 1);
    for sub = 1:nsub
        i = 1;
        
        for p = unique(p1)'
            qvalues(sub, i) = cho(sub, (p1(sub, :) == p))./100;
            i = i + 1;
        end
    end
    
    
    for sub = 1:nsub
        Q(sub, 1, 1) = qvalues(sub, 8);
        Q(sub, 1, 2) = qvalues(sub, 1);
        Q(sub, 2, 1) = qvalues(sub, 7);
        Q(sub, 2, 2) = qvalues(sub, 2);
        Q(sub, 3, 1) = qvalues(sub, 6);
        Q(sub, 3, 2) = qvalues(sub, 3);
        Q(sub, 4, 1) = qvalues(sub, 5);
        Q(sub, 4, 2) = qvalues(sub, 4);
    end
    nagent = 100;
    [cho, cont1, cont2, p1, p2, ev1, ev2] = sim_exp_ED(name, exp_num, d, idx, sess, 0, 1, Q, 1);
    
    nsub = size(cho, 1);
    % ----------------------------------------------------------------------
    % Compute for each symbol p of chosing depending on described cue value
    % ------------------------------------------------------------------------
    
    pcue = unique(p2)';
    psym = unique(p1)';
    
    chose_symbol = zeros(nsub, length(pcue), length(psym));
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
    
    nsub = size(cho, 1);
    k = 1:nsub;
    
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
    
    X = reshape(...
        repmat(pcue, size(k, 2), size(chose_symbol, 4)), [], 1....
        );
    
    pp = zeros(length(psym), length(pcue));
    
    for i = 1:length(psym)
        Y = reshape(chose_symbol(k, :, i, :), [], 1);
        [logitCoef, dev] = glmfit(...
            X, Y, 'binomial','logit');
        pp(i, :) = glmval(logitCoef, pcue', 'logit');
    end
    
    
    for i = 1:length(pwin)
        
        if ~ismember(i, [1, 8])
            continue
        end
        
        if pwin(i) < .5
            color = red_color;
        else
            color = blue_color;
        end
        
        hold on
        
        lin3 = plot(...
            pcue,  pp(i, :),...
            'Color', color, 'LineWidth', 4.5...
            );
        
        lin3.Color(4) = 0.8;
        
        hold on
    end
    s1 = title(sprintf('Exp. %s', num2str(exp_num)));
    set(s1, 'Fontsize', 20)
    set(gca,'TickDir','out')
    set(gca, 'FontSize', 23);
    mkdir('fig/exp', 'ind_curves_with_likert');
    saveas(gcf, ...
        sprintf('fig/exp/ind_curves_with_likert/exp_%s_sym_vs_lot.png',...
        num2str(exp_num)));
    
    %     exp_num = exp_num + 1;
    
    clear pp pcue psym temp err_prop prop i
    
end

