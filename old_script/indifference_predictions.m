%-------------------------------------------------------------------------
init;
%-------------------------------------------------------------------------
selected_exp = [1, 2, 3, 4];
displayfig = 'on';
sessions = [0, 1];
nagent = 10;
    
figure('Renderer', 'painters',...
        'Position', [145,157,3312,600], 'visible', 'off')
%-------------------------------------------------------------------------

for exp_num = selected_exp
    
    idx1 = (exp_num - round(exp_num)) * 10;
    idx1 = idx1 + (idx1==0);
    sess = sessions(uint64(idx1));
    
    % load data
    exp_name = char(filenames{round(exp_num)});
    
    [cho, cont1, cont2, p1, p2, ev1, ev2] = sim_exp_ED(exp_name, exp_num, d, idx, sess, 1, 2, nagent);
        % ----------------------------------------------------------------------
    % Compute for each symbol p of chosing depending on described cue value
    % ------------------------------------------------------------------------
    p_lot = unique(p2)';
    p_sym = unique(p1)';
    
    nsub = size(cho, 1);
    
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
    
%     figure(...
%         'Renderer', 'painters',...
%         'Position', [961, 1, 900, 600],...
%         'visible', displayfig)
    
    %alpha = [fli linspace(.5, 1, 2)];
    
    subplot(1, 4, exp_num);
    
    lin1 = plot(...
        linspace(0, 1, 12), ones(12)*0.5,...
        'LineStyle', ':', 'Color', [0, 0, 0], 'HandleVisibility', 'off');
    
    for i = 1:length(p_sym)
        if ~ismember(i, [1, length(p_sym)])
            continue
        end
        if p_sym(i) < .5
            color = red_color;
        else
            color = blue_color;
        end
        
        hold on
        hv = 'on';
        
        lin3 = plot(...
            p_lot,  pp(i, :),...
            'Color', color, 'LineWidth', 4.5,...% 'LineStyle', '--' ...
            'handlevisibility', hv);
        
        lin3.Color(4) = 0;
        
        hold on
        
        if i == 8
            hv = 'on';
        else
            hv = 'off';
        end
        
        sc1 = scatter(p_lot, prop(i, :), 180,...
            'MarkerEdgeColor', 'w',...
            'MarkerFaceColor', color, 'MarkerFaceAlpha', 0.65,...
            'handlevisibility', 'off');
        
        hold on
        
        errorbar(sc1.XData, prop(i, :), err_prop(i, :),...
            'Color', color, 'LineStyle', 'none', 'LineWidth', 1.7,...
            'handlevisibility', 'off');%, 'CapSize', 2);
        
        try
            ind_point = interp1(lin3.YData, lin3.XData, 0.5);
        catch
            
        end
        
        sc2 = scatter(ind_point, 0.5, 200, 'MarkerFaceColor', 'k',...
            'MarkerEdgeColor', 'w', 'handlevisibility', 'off');
        
        if exp_num == 1
            ylabel('P(choose experienced cue)');
        end
        xlabel('Described cue win probability');
        
        ylim([-0.08, 1.08]);
        xlim([-0.08, 1.08]);
        
        text(...
            ind_point + (0.05) * (1 + (-4 * (i == 1))) ,...
            .55, sprintf('%.2f', ind_point), 'Color', 'k', 'FontSize', 25);
        
        box off
        set(gca, 'Fontsize', 23);
        
        plot(p_sym(i) .*  ones(10, 1), linspace(.2, .8, 10), 'Color', color,...
            'LineStyle', ':', 'LineWidth', 3.5, 'handlevisibility', 'off');
        hold on
        
    end
    
    clear prop cho pp p_sym p_lot err_prop
    
    
     
    [cho, cont1, cont2, p1, p2, ev1, ev2] = sim_exp_ED(exp_name, exp_num, d, idx, sess, 1, 2, nagent);
        % ----------------------------------------------------------------------
    % Compute for each symbol p of chosing depending on described cue value
    % ------------------------------------------------------------------------
    p_lot = unique(p2)';
    p_sym = unique(p1)';
    
    nsub = size(cho, 1);
    
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
    
    figure(...
        'Renderer', 'painters',...
        'Position', [961, 1, 900, 600],...
        'visible', displayfig)
    
    %alpha = [fli linspace(.5, 1, 2)];
    
    lin1 = plot(...
        linspace(0, 1, 12), ones(12)*0.5,...
        'LineStyle', ':', 'Color', [0, 0, 0], 'HandleVisibility', 'off');
    
    for i = 1:length(p_sym)
        if ~ismember(i, [1, length(p_sym)])
            continue
        end
        if p_sym(i) < .5
            color = red_color;
        else
            color = blue_color;
        end
        
        hold on
        hv = 'on';
        
        lin3 = plot(...
            p_lot,  pp(i, :),...
            'Color', color, 'LineWidth', 4.5,...% 'LineStyle', '--' ...
            'handlevisibility', hv);
        
        lin3.Color(4) = 0;
        
        hold on
        
        if i == 8
            hv = 'on';
        else
            hv = 'off';
        end
        
        sc1 = scatter(p_lot, prop(i, :), 180,...
            'MarkerEdgeColor', 'w',...
            'MarkerFaceColor', color, 'MarkerFaceAlpha', 0.65,...
            'handlevisibility', 'off');
        
        hold on
        
        errorbar(sc1.XData, prop(i, :), err_prop(i, :),...
            'Color', color, 'LineStyle', 'none', 'LineWidth', 1.7,...
            'handlevisibility', 'off');%, 'CapSize', 2);
        
        try
            ind_point = interp1(lin3.YData, lin3.XData, 0.5);
        catch
            
        end
        
        sc2 = scatter(ind_point, 0.5, 200, 'MarkerFaceColor', 'k',...
            'MarkerEdgeColor', 'w', 'handlevisibility', 'off');
        
        ylabel('P(choose experienced cue)', 'FontSize', 26);
        xlabel('Described cue win probability', 'FontSize', 26);
        
        ylim([-0.08, 1.08]);
        xlim([-0.08, 1.08]);
        
        text(...
            ind_point + (0.05) * (1 + (-4 * (i == 1))) ,...
            .55, sprintf('%.2f', ind_point), 'Color', 'k', 'FontSize', 25);
        
        box off
        set(gca, 'Fontsize', 23);
        
        plot(p_sym(i) .*  ones(10, 1), linspace(.2, .8, 10), 'Color', color,...
            'LineStyle', ':', 'LineWidth', 3.5, 'handlevisibility', 'off');
        hold on
        
    end
    
    clear prop cho pp p_sym p_lot err_prop

%     [cho, cont1, cont2, p1, p2, ev1, ev2] = ...
%         sim_exp_ED(name, exp_num, d, idx, sess, 1);
%     
%     
%     nsub = size(cho, 1);
%     % ----------------------------------------------------------------------
%     % Compute for each symbol p of chosing depending on described cue value
%     % ------------------------------------------------------------------------
%     p_lot = unique(p2)';
%     p_sym = unique(p1)';
%     
%     chose_symbol = zeros(nsub, length(p_lot), length(p_sym));
%     for i = 1:nsub
%         for j = 1:length(p_lot)
%             for k = 1:length(p_sym)
%                 temp = ...
%                     cho(i, logical((p2(i, :) == p_lot(j)) .* (p1(i, :) == p_sym(k))));
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
%     prop = zeros(length(p_sym), length(p_lot));
%     err_prop = zeros(size(prop));
%     temp1 = cho(k, :);
%     for j = 1:length(p_lot)
%         for l = 1:length(p_sym)
%             temp = temp1(...
%                 logical((p2(k, :) == p_lot(j)) .* (p1(k, :) == p_sym(l))));
%             prop(l, j) = mean(temp == 1);
%             err_prop(l, j) = std(temp == 1)./sqrt(length(temp));
%             
%         end
%     end
%     
%     X = reshape(...
%         repmat(p_lot, size(k, 2), size(chose_symbol, 4)), [], 1....
%         );
%     
%     pp = zeros(length(p_sym), length(p_lot));
%     
%     for i = 1:length(p_sym)
%         Y = reshape(chose_symbol(k, :, i, :), [], 1);
%         [logitCoef, dev] = glmfit(...
%             X, Y, 'binomial','logit');
%         pp(i, :) = glmval(logitCoef, p_lot', 'logit');
%     end
%     
%     pwin = p_sym;
%     
%     for i = 1:length(pwin)
%         
%         if ~ismember(i, [1, length(p_sym)])
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
%         if i == 8
%             hv = 'on';
%         else
%             hv = 'off';
%         end
%         
%         lin3 = plot(...
%             p_lot,  pp(i, :),...
%             'Color', color, 'LineWidth', 4.5, 'LineStyle', '--',...
%             'handlevisibility', hv...
%             );
%         
%         lin3.Color(4) = 0.6;
%         
%         hold on
%     end
%     
     %s1 = title(sprintf('Exp. %s', num2str(exp_num)));
%     set(s1, 'Fontsize', 20)
%     set(gca,'TickDir','out')
%     set(gca, 'FontSize', 23);
%     mkdir('fig/exp', 'ind_curves_sym_vs_lot_with_likert');
%     saveas(gcf, ...
%         sprintf('fig/exp/ind_curves_sym_vs_lot_with_likert/exp_%s_sym_vs_lot.svg',...
%         num2str(exp_num)));
%     
%     %     exp_num = exp_num + 1;
    clear prop cho pp p_sym p_lot err_prop
    
end
mkdir('fig/exp', 'ind_curves_sym_vs_lot_with_likert');
 saveas(gcf, ...
    sprintf('fig/exp/ind_curves_sym_vs_lot_with_likert/full.svg',...
    ));

