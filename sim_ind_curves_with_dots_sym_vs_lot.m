%-------------------------------------------------------------------------
init;
%-------------------------------------------------------------------------

   
titles = {
        'Exp. 4'};
selected_exp = [1, 2, 3, 4, 5.1, 5.2, 6.1, 6.2, 7.1, 7.2];
sessions = [0, 1];
def = 0;
nagent = 100;

displayfig = 'on';

for exp_num = selected_exp
    
    % -------------------------------------------------------------------%
    % LEARNING
    % -------------------------------------------------------------------%
    idx1 = (exp_num - round(exp_num)) * 10;
    if idx1 == 0
        idx1 = 1;
    end
    idx1 = idx1 * ((idx==0) + 1);
    sess = sessions(uint64(idx1));
   
    % load data
    name = char(filenames{round(exp_num)});

    data = d.(name).data;
    sub_ids = d.(name).sub_ids;
    
    [cho, cont1, cont2, p1, p2, ev1, ev2] = sim_exp_ED(name, d, idx, sess, def, nagent);
    
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
                'Color', color, 'LineWidth', 4.5 ...
                );
        
        lin3.Color(4) = alpha(i);
        
        hold on
       
        sc1 = scatter(pcue, prop(i, :), 180,...
            'MarkerEdgeColor', 'w',...
            'MarkerFaceColor', color, 'MarkerFaceAlpha', 0.65);
        hold on
        errorbar(sc1.XData, prop(i, :), err_prop(i, :), 'Color', color,...
            'LineStyle', 'none', 'LineWidth', 1.7);%, 'CapSize', 2);
        hold on         

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
        
        plot(pwin(i) .*  ones(10, 1), linspace(.2, .8, 10), 'Color', color, 'LineStyle', ':', 'LineWidth', 5);
        disp(pwin(i));
        hold on
        
    end

  s1 = title(sprintf('Sim. (RL fitted P(win)) Exp. %.1f', exp_num));
   set(s1, 'Fontsize', 20)
    set(gca,'TickDir','out')

    mkdir('fig/exp', 'sim_RL_ind_curves');
    saveas(gcf, ...
        sprintf('fig/exp/sim_RL_ind_curves/ind_curve_with_dots_exp_%d_sym_vs_lot.png',...
        exp_num));
    
    
end

