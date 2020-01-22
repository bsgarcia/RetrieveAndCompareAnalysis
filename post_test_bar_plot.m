% --------------------------------------------------------------------
% This script computes the correct choice rate for each exp
% then plots the article figs
% --------------------------------------------------------------------
% run init script 
init;

% overwrite filenames variable
filenames = {
    'block_complete_mixed_2s',...
    'block_complete_mixed_2s_amb_final',...
    'block_complete_mixed_2s_amb_heuristic'...
};

%------------------------------------------------------------------------
% Plot fig
%------------------------------------------------------------------------
i = 5;
for exp_name = filenames
    ttl = sprintf('Exp. %d', i);
    session = [0, 1];
    plot_bar_plot_correct_choice_rate(d, idx, orange_color, blue_color, exp_name, ttl, session);
    mkdir('fig/exp', 'bar_plot_correct_choice_rate_post_test');
    saveas(gcf, sprintf('fig/exp/bar_plot_correct_choice_rate_post_test/exp_%d.png', i));
    i = i + 1;
end

% for exp_name = filenames
%     session = [0, 1];
%     for sess = session
%         ttl = sprintf('Exp. %d Sess. %d', i, sess+1);
%         plot_bar_plot_correct_choice_rate(d, idx, orange_color, blue_color, exp_name, ttl, sess);
%         mkdir('fig/exp', 'bar_plot_correct_choice_rate_post_test');
%         saveas(gcf,...
%             sprintf(...
%             'fig/exp/bar_plot_correct_choice_rate_post_test/exp_%d_sess_%d.png',...
%             i, sess+1));
%     end
%     i = i + 1;
% end


function plot_bar_plot_correct_choice_rate(d, idx, orange_color,...
    blue_color, exp_name, ttl, session)

    
    figure('Position', [1,1,600, 900]);
    titles = {'Exp. 4', 'Exp. 5', 'Exp. 6', 'Exp. 7'};
         
        
        exp_name = char(exp_name);
     
        [corr2, cho, out, p1, p2, ev1, ev2, ctch, cont1, cont2, dist, rtime] = ...
            DataExtraction.extract_sym_vs_lot_post_test(...
            d.(exp_name).data, d.(exp_name).sub_ids, idx, [0, 1]);
        
        nsub = size(cho, 1);
        
        ev2 = ev2(~ismember(ev2, [-1, 0, 1]));
        %ev2(ismember(ev2, [-1, 0, 1])) = [];

        corr_heuristic = simulate_heuristic(unique(ev1), unique(ev2));

        for sub = 1:nsub
            mask_equal_ev = logical(ev1(sub, :) ~= ev2(sub, :));
            mask_easy = logical(~ismember(ev2(sub, :), [-1, 0, 1]));
            d1 = corr2(sub, logical(mask_equal_ev.*mask_easy));
            corr_rate_desc_vs_exp(sub) = mean(d1);
        end
        
        [corr1, cho, out, p1, p2, ev1, ev2, ctch, cont1, cont2, dist, rtime] = ...
            DataExtraction.extract_sym_vs_sym_post_test(...
            d.(exp_name).data, d.(exp_name).sub_ids, idx, session);
   
        for sub = 1:nsub
            d2 = corr1(sub, :);
            corr_rate_exp_vs_exp(sub) = mean(d2);
        end
        
        mn1 = mean(corr_rate_exp_vs_exp);
        mn2 = mean(corr_rate_desc_vs_exp);
        mn = [mn1, mn2];
        err1 = ...
            std(corr_rate_exp_vs_exp)/sqrt(size(corr_rate_exp_vs_exp, 2));
        err2 = ...
            std(corr_rate_desc_vs_exp)/sqrt(size(corr_rate_desc_vs_exp, 2));
        
        err = [err1, err2];
                
        b = bar(mn, 'EdgeColor', 'w', 'FaceAlpha', 0.6, 'FaceColor', 'flat');
        box off
        hold on
        b.CData(1, :) = blue_color;
        b.CData(2, :) = orange_color;
        
        ax1 = gca;
        set(gca, 'XTickLabel', {'EE', 'ED'});
        
        ylim([0, 1.07])
        ylabel('Correct choice rate');
        e = errorbar(mn, err, 'LineStyle', 'none',...
            'LineWidth', 3, 'Color', 'k', 'HandleVisibility','off');
        set(gca, 'Fontsize', 18);
        set(gca, 'box', 'off');

        title(ttl);
        
        yline(.5, 'LineStyle', '--');
        hold on
        
        for j = 1:2
            ax(j) = axes('Position',get(ax1,'Position'),'XAxisLocation','top',...
                'YAxisLocation','right','Color','none','XColor','k','YColor','k');
            
            hold(ax(j), 'all');
            if (j == 1)
                d3 = corr_rate_exp_vs_exp;
            else
                d3 = corr_rate_desc_vs_exp;
            end
            X = ones(1, nsub)-Shuffle(linspace(-0.15, 0.15, nsub));
            s = scatter(...
                X + (j-1),...
                d3, 125,...
                'filled', 'Parent', ax1, 'MarkerFaceAlpha', 0.75,...
                'MarkerEdgeAlpha', 1,...
                'MarkerFaceColor', b.CData(j, :),...
                'MarkerEdgeColor', 'w');
            box off
            
            set(gca, 'xtick', []);
            set(gca, 'box', 'off');
            set(ax(j), 'box', 'off');
            
            set(gca, 'ytick', []);
            ylim([0, 1.15]);
            
            box off
        end
        box off
        uistack(e, 'top');
        
        xlim([0, 3]);
           
        p2_1 = plot([1.55, 2.35],...
            ones(1, 2) .* mean(corr_heuristic),...
            'Color', orange_color, 'LineStyle', '-', 'LineWidth', 3);
        
        legend([p2_1], {'Sim. Heuristic'},...
            'Location', 'southwest');

        box off
        hold off
        ylim([0, 1.08]);
        box off
        set(gca, 'box', 'off');

        clear corr_rate_exp_vs_exp
        clear corr_rate_desc_vs_exp
        clear nsub
        clear d1 d2 d3
        clear err1 err2 err
        clear mn1 mn2 mn
    
end



% function plot_bar_plot_correct_choice_rate(d, idx, orange_color, blue_color, exp_name, ttl)
% 
%     
%     figure('Position', [1,1,600, 900]);
%     titles = {'Exp. 4', 'Exp. 5', 'Exp. 6', 'Exp. 7'};
%          
%         
%         exp_name = char(exp_name);
%      
%         [corr2, cho, out, p1, p2, ev1, ev2, ctch, cont1, cont2, dist, rtime] = ...
%             DataExtraction.extract_sym_vs_lot_post_test(...
%             d.(exp_name).data, d.(exp_name).sub_ids, idx, [0, 1]);
%         
%         nsub = size(cho, 1);
%         
%         ev2 = ev2(~ismember(ev2, [-1, 0, 1]));
%         %ev2(ismember(ev2, [-1, 0, 1])) = [];
% 
%         corr_heuristic = run_simulation(unique(ev1), unique(ev2));
% 
%         for sub = 1:nsub
%             mask_equal_ev = logical(ev1(sub, :) ~= ev2(sub, :));
%             mask_easy = logical(~ismember(ev2(sub, :), [-1, 0, 1]));
%             d1 = corr2(sub, logical(mask_equal_ev.*mask_easy));
%             corr_rate_desc_vs_exp(sub) = mean(d1);
%         end
%         
%         [corr1, cho, out, p1, p2, ev1, ev2, ctch, cont1, cont2, dist, rtime] = ...
%             DataExtraction.extract_sym_vs_sym_post_test(...
%             d.(exp_name).data, d.(exp_name).sub_ids, idx, [0, 1]);
%    
%         for sub = 1:nsub
%             d2 = corr1(sub, :);
%             corr_rate_exp_vs_exp(sub) = mean(d2);
%         end
%         
%         mn1 = mean(corr_rate_exp_vs_exp);
%         mn2 = mean(corr_rate_desc_vs_exp);
%         mn = [mn1, mn2];
%         err1 = ...
%             std(corr_rate_exp_vs_exp)/sqrt(size(corr_rate_exp_vs_exp, 2));
%         err2 = ...
%             std(corr_rate_desc_vs_exp)/sqrt(size(corr_rate_desc_vs_exp, 2));
%         
%         err = [err1, err2];
%                 
%         b = bar(mn, 'EdgeColor', 'k', 'FaceAlpha', 0.6, 'FaceColor', 'flat');
%         hold on
%         b.CData(1, :) = blue_color;
%         b.CData(2, :) = orange_color;
%         
%         ax1 = gca;
%         set(gca, 'XTickLabel', {'EE', 'ED'});
%         
%         ylim([0, 1.07])
%         ylabel('Correct choice rate');
%         e = errorbar(mn, err, 'LineStyle', 'none',...
%             'LineWidth', 3, 'Color', 'k', 'HandleVisibility','off');
%         set(gca, 'Fontsize', 18);
%         title(ttl);
%         
%         for j = 1:2
%             ax(j) = axes('Position',get(ax1,'Position'),'XAxisLocation','top',...
%                 'YAxisLocation','right','Color','none','XColor','k','YColor','k');
%             
%             hold(ax(j), 'all');
%             if (j == 1)
%                 d3 = corr_rate_exp_vs_exp;
%             else
%                 d3 = corr_rate_desc_vs_exp;
%             end
%             X = ones(1, nsub)-Shuffle(linspace(-0.15, 0.15, nsub));
%             s = scatter(...
%                 X + (j-1),...
%                 d3, 125,...
%                 'filled', 'Parent', ax1, 'MarkerFaceAlpha', 0.75,...
%                 'MarkerEdgeAlpha', 1,...
%                 'MarkerFaceColor', b.CData(j, :),...
%                 'MarkerEdgeColor', 'w');
%             box off
%             
%             set(gca, 'xtick', []);
%             set(gca, 'box', 'off');
%             set(ax(j), 'box', 'off');
%             
%             set(gca, 'ytick', []);
%             ylim([0, 1.15]);
%             
%             box off
%         end
%         box off
%         uistack(e, 'top');
%         
%         xlim([0, 3]);
%            
%         p2_1 = plot([1.55, 2.35],...
%             ones(1, 2) .* mean(corr_heuristic),...
%             'Color', 'k', 'LineStyle', ':', 'LineWidth', 3);
%         
%         legend([p2_1], {'Sim. Heuristic'},...
%             'Location', 'southwest');
% 
%         box off
%         hold off
%         ylim([0, 1.08]);
%         box off
%         
%         clear corr_rate_exp_vs_exp
%         clear corr_rate_desc_vs_exp
%         clear nsub
%         clear d1 d2 d3
%         clear err1 err2 err
%         clear mn1 mn2 mn
%     
% end


