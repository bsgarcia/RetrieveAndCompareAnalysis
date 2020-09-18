%-------------------------------------------------------------------------
init;
%-------------------------------------------------------------------------

selected_exp = [5, 6.1, 6.2];

displayfig = 'off';
sessions = [0, 1];
    
figure('Renderer', 'painters',...
        'Position', [145,157,828*3,600], 'visible', 'off')

num = 0;
for exp_num = selected_exp
    num = num + 1;
    
    idx1 = (exp_num - round(exp_num)) * 10;
    idx1 = idx1 + (idx1==0);
    sess = sessions(uint64(idx1));
    
    % load data
    name = char(filenames{round(exp_num)});
    
    data = d.(name).data;
    sub_ids = d.(name).sub_ids;
    
    [corr, cho, out2, p1, p2, ev1, ev2, ctch, cont1, cont2, dist] = ...
        DataExtraction.extract_sym_vs_sym_post_test(...
        data, sub_ids, idx, sess);
    
    d.(name).nsub = size(cho, 1);
    % ----------------------------------------------------------------------
    % Compute for each symbol p of chosing depending on described cue value
    % ------------------------------------------------------------------------
    
    pcue = unique(p2)';
    psym = unique(p1)';
    
    chose_symbol = nan(d.(name).nsub, length(pcue), length(psym), 1);
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
    
    subplot(1, 3, num);
    
    pwin = psym;
    %alpha = [fliplr(linspace(.4, .9, length(psym)/2)), linspace(.4, .9, length(psym)/2)];
    alpha = linspace(.15, .95, length(psym));
    lin1 = plot(...
        linspace(psym(1), psym(end), 12), ones(12,1)*0.5,...
        'LineStyle', ':', 'Color', [0, 0, 0], 'HandleVisibility', 'off');
    
    for i = 1:length(pwin)
        
%         if pwin(i) < .5
%             color = red_color;
%         else
%             color = blue_color;
%         end
%         
        
        hold on
        
               
        lin3 = plot(...
            pcue(isfinite(prop(i, :))),  prop(i, isfinite(prop(i, :))),...
            'Color', blue_color, 'LineWidth', 4.5...% 'LineStyle', '--' ...
            );
              
        
        lin3.Color(4) = alpha(i);
        
        hold on
        
        
        %         sc1 = scatter(pcue, prop(i, :), 180,...
        %             'MarkerEdgeColor', 'w',...
        %             'MarkerFaceColor', color, 'MarkerFaceAlpha', 0.65);
        %
        %         hold on
        %         try
        %             errorbar(sc1.XData, prop(i, :), err_prop(i, :), 'Color', color, 'LineStyle', 'none', 'LineWidth', 1.7);%, 'CapSize', 2);
        %         catch
        %
        %
        %
        %         end
        
%         if ismember(pwin(i), [pwin(1), pwin(end)])
%             
%             
%             ind_point = interp1(lin3.YData, lin3.XData, 0.5);
%             
%             sc2 = scatter(ind_point, 0.5, 200, 'MarkerFaceColor', 'k',...
%                 'MarkerEdgeColor', 'w');
%             
%             text(...
%                 ind_point + (0.05) * (1 + (-5 * (i == 1))) ,...
%                 .55, sprintf('%.2f', ind_point), 'Color', 'k', 'FontSize', 25);
%         end
        

        if exp_num == 5
            ylabel('P(choose symbol)');
        end
        xlabel('Symbol p(win)');
        
        ylim([-0.08, 1.08]);
        xlim([-0.08, 1.08]);
               
        box off
        
        %plot(pwin(i) .*  ones(10, 1), linspace(.2, .8, 10), 'Color', color, 'LineStyle', ':', 'LineWidth', 3.5);
        %hold on
        
    end
    
    %title(sprintf('Exp. %s', num2str(exp_num)));
    %set(s1, 'Fontsize', fontsize)
    set(gca,'TickDir','out')
    set(gca, 'FontSize', fontsize);
%     mkdir('fig/exp', 'ind_curves_bhv');
%     saveas(gcf, ...
%         sprintf('fig/exp/ind_curves_bhv/exp_%s_sym_vs_lot.png',...
%         num2str(exp_num)));
    
    %     exp_num = exp_num + 1;
    
    clear pp pcue psym temp err_prop prop i
    
end
mkdir('fig/exp', 'ind_curves_bhv');
    saveas(gcf, ...
        sprintf('fig/exp/ind_curves_bhv/full_EE.svg'));
    