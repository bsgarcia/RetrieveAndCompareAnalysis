init;

titles = {...
    'Exp. 6 Sess. 1', 'Exp. 6 Sess. 1', 'Exp. 6 Sess. 2'};
exp_num = 1;
figure(...
    'Renderer', 'painters',...
    'Position', [961, 1, 2200, 1500],...
    'visible', displayfig)
sub_plot = [1, 3, 2, 4];


for f = {filenames{end}, filenames{end}}
    subplot(2, 2, sub_plot(exp_num));
    if exp_num >= 2
        session = 1;
    else
        session = 0;
    end
    name = char(f);
    data = d.(name).data;
    sub_ids = d.(name).sub_ids;
    
    [corr, cho, out2, p1, p2, ev1, ev2, ctch, cont1, cont2, dist] = ...
        DataExtraction.extract_sym_vs_amb_post_test(data, sub_ids, idx, session);
    
    % ----------------------------------------------------------------------
    % Compute for each symbol p of chosing depending on described cue value
    % ------------------------------------------------------------------------
    pcue = [0.1, 0.2, 0.3, 0.4, 0.6, 0.7, 0.8, 0.9];
    psym = [0.1, 0.2, 0.3, 0.4, 0.6, 0.7, 0.8, 0.9];
    for i = 1:size(cho, 1)
        for j = 1:length(pcue)
            temp = cho(i, logical((p1(i, :) == psym(j))));
            
            chose_symbol(i, j, :) = temp == 1;
        end
    end
    
    
    nsub = size(cho, 1);
    % ----------------------------------------------------------------------
    % PLOT P(learnt value) vs Described Cue
    % ------------------------------------------------------------------------
    
    k = 1:nsub;
    
    temp1 = cho(k, :);
    for l = 1:length(psym)
        temp = temp1(...
            logical((p1(k, :) == psym(l))...
            ));
        prop(l) = mean(temp == 1);
    end
    
    X = reshape(...
        repmat(psym, size(k, 2), 2), [], 1....
        );
    Y = reshape(chose_symbol(k, :, :), [], 1);
    [logitCoef, dev] = glmfit(...
        X, Y, 'binomial','logit');
    pp = glmval(logitCoef, pcue', 'logit');
    
    lin1 = plot(...
        linspace(0, 1, 12), ones(12)*0.5,...
        'LineStyle', ':', 'Color', [0, 0, 0], 'HandleVisibility', 'off');
    
    hold on
    
    lin3 = plot(...
        pcue,  pp,... %'bs', pcue, pp(i, :),  'b-', 'MarkerEdgeColor',...
        'Color', green_color, 'LineWidth', 3 ...
        );
    
    
    %lin3.Color(4) = 0.7;
    hold on
    sc1 = scatter(pcue, prop, 180,...
        'MarkerEdgeColor', 'w',...
        'MarkerFaceColor', green_color, 'MarkerFaceAlpha', 0.6);
    
    %s.MarkerFaceAlpha = alpha(i);
    
    hold on
    ind_point = interp1(lin3.YData, lin3.XData, 0.5);
    
    sc2 = scatter(ind_point, 0.5, 200, 'MarkerFaceColor', 'k',...
        'MarkerEdgeColor', 'w');
    
    %sc2.MarkerFaceAlpha = alpha(i);
    
    ylabel('P(choose experienced cue)', 'FontSize', 26);
    
    xlabel('Experienced cue win probability', 'FontSize', 26);
    
    ylim([-0.08, 1.08]);
    xlim([-0.08, 1.08]);
    text(ind_point + (0.05), .55, sprintf('%.2f', ind_point), 'Color', 'k', 'FontSize', 25);
    
    box off
    set(gca, 'Fontsize', 23);
    
    
    s1 = title(titles{exp_num});
    set(s1, 'Fontsize', 20)
    
    exp_num = exp_num + 1;
    
    
    subplot(2, 2, sub_plot(exp_num));
    
    name = char(f);
    data = d.(name).data;
    sub_ids = d.(name).sub_ids;
    
    [corr, cho, out2, p1, p2, ev1, ev2, ctch, cont1, cont2, dist] = ...
        DataExtraction.extract_lot_vs_amb_post_test(data, sub_ids, idx, session);
    
    % ----------------------------------------------------------------------
    % Compute for each symbol p of chosing depending on described cue value
    % ------------------------------------------------------------------------
    clear chose_symbol
    clear pp
    clear prop
    pcue = [0.1, 0.2, 0.3, 0.4, 0.6, 0.7];
    psym = [0.1, 0.2, 0.3, 0.4, 0.6, 0.7];
    for i = 1:size(cho, 1)
        for j = 1:length(pcue)
            temp = cho(i, logical((p1(i, :) == psym(j))));
            chose_symbol(i, j) = mean(temp == 1);
        end
    end
    
    nsub = size(cho, 1);
    % ----------------------------------------------------------------------
    % PLOT P(learnt value) vs Described Cue
    % ------------------------------------------------------------------------
    
    k = 1:nsub;
    
    temp1 = cho(k, :);
    for l = 1:length(psym)
        temp = temp1(...
            logical((p1(k, :) == psym(l))...
            ));
        prop(l) = mean(temp == 1);
    end
    
    X = reshape(...
        repmat(psym, size(k, 2), 1), [], 1....
        );
    Y = reshape(chose_symbol(k, :), [], 1);
    
    [logitCoef, dev] = glmfit(...
        X, Y, 'binomial','logit');
    pp = glmval(logitCoef, pcue', 'logit');
    
    lin1 = plot(...
        linspace(0, 1, 12), ones(12)*0.5,...
        'LineStyle', ':', 'Color', [0, 0, 0], 'HandleVisibility', 'off');
    
    hold on
    
    lin3 = plot(...
        pcue,  pp,... %'bs', pcue, pp(i, :),  'b-', 'MarkerEdgeColor',...
        'Color', green_color, 'LineWidth', 3 ...
        );
    
    
    hold on
    sc1 = scatter(pcue, prop, 180,...
        'MarkerEdgeColor', 'w',...
        'MarkerFaceColor', green_color, 'MarkerFaceAlpha', 0.6);
    
    
    hold on
    ind_point = interp1(lin3.YData, lin3.XData, 0.5);
    
    sc2 = scatter(ind_point, 0.5, 200, 'MarkerFaceColor', 'k',...
        'MarkerEdgeColor', 'w');
    
    %sc2.MarkerFaceAlpha = alpha(i);
    
    ylabel('P(choose described cue)', 'FontSize', 26);
    
    xlabel('Described cue win probability', 'FontSize', 26);
    
    ylim([-0.08, 1.08]);
    xlim([-0.08, 1.08]);
    text(ind_point + (0.05), .55, sprintf('%.2f', ind_point), 'Color', 'k', 'FontSize', 25);
    
    box off
    set(gca, 'Fontsize', 23);
    
    
    %s1 = title(titles{exp_num});
    %set(s1, 'Fontsize', 20)
    
    exp_num = exp_num + 1;
    
    clear chose_symbol
    clear pp
    clear prop
    
end
saveas(gcf, sprintf('fig/exp/all/amb_curve.png'));

