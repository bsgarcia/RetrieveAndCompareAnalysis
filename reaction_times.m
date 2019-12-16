% --------------------------------------------------------------------
% This script finds the best fitting Values for each exp
% then plots the article figs
% --------------------------------------------------------------------
init;

%------------------------------------------------------------------------
% Plot fig 2.A
%------------------------------------------------------------------------
f = {filenames{[1, 2, 3]}};
plot_reaction_times_1_2_3(d, idx, orange_color, blue_color, f)
saveas(gcf, 'fig/exp/all/reaction_times_1_2_3.png');

f = {filenames{[4, 5]}};
plot_reaction_times_4_5_6(d, idx, orange_color, blue_color, f)
saveas(gcf, 'fig/exp/all/reaction_times_4_5_6.png');


function plot_reaction_times_4_5_6(d, idx, orange_color, blue_color, exp_names)

    i = 1;
    format shortg
    figure('Position', [1,1,1900,900]);
    titles = {'Exp. 4', 'Exp. 5'};
         
    for exp_name = {exp_names{:}}
        subplot(1, 2, i);
        
        exp_name = char(exp_name);
        nsub = d.(exp_name).nsub;
     
        [corr2, cho, out, p1, p2, ev1, ev2, ctch, cont1, cont2, dist, rtime] = ...
            DataExtraction.extract_sym_vs_lot_post_test(...
            d.(exp_name).data, d.(exp_name).sub_ids, idx, [0, 1]);
        
        for sub = 1:nsub
            mask_equal_ev = logical(ev1(sub, :) ~= ev2(sub, :));
            mask_easy = logical(~ismember(ev2(sub, :), [-1, 0, 1]));
            mask_chosen_lot = logical(cho(sub, :) == 2);
            mask_chosen_sym = logical(cho(sub, :) == 1);
            d1 = rtime(sub, logical(mask_equal_ev.*mask_easy));
            d2 = rtime(sub, logical(mask_equal_ev.*mask_easy.*mask_chosen_lot));
            d3 = rtime(sub, logical(mask_equal_ev.*mask_easy.*mask_chosen_sym));
            rtime_both(sub) = median(d1);
            rtime_lot(sub) = median(d2);
            rtime_sym(sub) = median(d3);
        end        
        
        [corr1, cho, out, p1, p2, ev1, ev2, ctch, cont1, cont2, dist, rtime] = ...
            DataExtraction.extract_sym_vs_sym_post_test(...
            d.(exp_name).data, d.(exp_name).sub_ids, idx, [0, 1]);
   
        for sub = 1:nsub
            d4 = rtime(sub, :);
            rtime_sym_vs_sym(sub) = median(d4);
        end
        
        dd = {rtime_sym_vs_sym,...
             rtime_sym, rtime_lot};
        
        x = dd{1};
        y = dd{2};
        p = signrank(x,y);
        pp(1) = p;
       
        x = dd{2};
        y = dd{3};
        p = signrank(x,y);
        pp(2) = p;
        
        x = dd{1};
        y = dd{3};
        p = signrank(x,y);
        pp(3) = p;

        pp = pval_adjust(pp, 'bonferroni');
         
        for p_corr = pp 
            if p_corr < .001
                h = '***';
            elseif p_corr < .01
                h='**';
            elseif p_corr < .05
                h ='*';
            else 
                h = 'none';
            end
            fprintf('h=%s, p=%d \n', h, p_corr);
        end
        fprintf('===================== \n');

%         t = table(
%         [p,tbl,stats] = ranova(cell2mat(dd')');
%         [c,~,~,gnames] = multcompare(stats);
        mn = [mean(rtime_sym_vs_sym),...
            mean(rtime_sym), mean(rtime_lot)];
        
        err1 = std(rtime_sym_vs_sym)/sqrt(length(rtime_sym_vs_sym));
        %err2 = std(rtime_both)/sqrt(length(rtime_both));
        err3 = std(rtime_sym)/sqrt(length(rtime_sym));
        err4 = std(rtime_lot)/sqrt(length(rtime_lot));
        err = [err1, err3, err4];
            %err2, 
            
        b = bar(mn, 'EdgeColor', 'k', 'FaceAlpha', 0.6, 'FaceColor', 'flat');
        
        hold on
        b.CData(1, :) = blue_color;
        b.CData(2, :) = orange_color;
        b.CData(3, :) = orange_color;
        %b.CData(4, :) = orange_color;
  
        ax1 = gca;
        set(gca, 'XTickLabel', {'EE', 'E_{chosen}', 'D_{chosen}'});
        
        ylim([0, 3500])
        ylabel('Reaction time (ms)');
        
        e = errorbar(mn, err, 'LineStyle', 'none',...
            'LineWidth', 2.5, 'Color', 'k', 'HandleVisibility','off');
        set(gca, 'Fontsize', 18);
        
        title(titles{i});
        
        for j = 1:3
            ax(j) = axes('Position',get(ax1,'Position'),'XAxisLocation','top',...
                'YAxisLocation','right','Color','none','XColor','k','YColor','k');
            
            hold(ax(j), 'all');
           
            X = ones(1, nsub)-Shuffle(linspace(-0.15, 0.15, nsub));
            s = scatter(...
                X + (j-1),...
                dd{j}, 110,...
                'filled', 'Parent', ax1, 'MarkerFaceAlpha', 0.75,...
                'MarkerEdgeAlpha', 1,...
                'MarkerFaceColor', b.CData(j, :),...
                'MarkerEdgeColor', 'w');
            box off
            
            set(gca, 'xtick', []);
            set(gca, 'box', 'off');
            set(ax(j), 'box', 'off');
            
            set(gca, 'ytick', []);
            %ylim([0, 1.15]);
            
            box off
        end
        box off
        uistack(e, 'top');
        
        i = i + 1;
        
        clear dd X mn err err1 err2 err3 err4 nsub ev1 ev2 cho rtime
        clear rtime_sym_vs_sym rtime_sym rtime_both rtime_lot
    end
end

function plot_reaction_times_1_2_3(d, idx, orange_color, blue_color, exp_names)

    i = 1;
    
    figure('Position', [1,1,1900,900]);
    titles = {'Exp. 1', 'Exp. 2', 'Exp. 3'};
         
    for exp_name = {exp_names{:}}
        subplot(1, 3, i);
        
        exp_name = char(exp_name);
        nsub = d.(exp_name).nsub;
     
        [corr2, cho, out, p1, p2, ev1, ev2, ctch, cont1, cont2, dist, rtime] = ...
            DataExtraction.extract_sym_vs_lot_post_test(...
            d.(exp_name).data, d.(exp_name).sub_ids, idx, 0);
        
        for sub = 1:nsub
            mask_equal_ev = logical(ev1(sub, :) ~= ev2(sub, :));
            mask_easy = logical(~ismember(ev2(sub, :), [-1, 0, 1]));
            mask_chosen_lot = logical(cho(sub, :) == 2);
            mask_chosen_sym = logical(cho(sub, :) == 1);
            d1 = rtime(sub, logical(mask_equal_ev.*mask_easy));
            d2 = rtime(sub, logical(mask_equal_ev.*mask_easy.*mask_chosen_lot));
            d3 = rtime(sub, logical(mask_equal_ev.*mask_easy.*mask_chosen_sym));
            rtime_both(sub) = median(d1);
            rtime_lot(sub) = median(d2);
            rtime_sym(sub) = median(d3);
        end        
       
        dd = {rtime_sym, rtime_lot};
        
        x = dd{1};
        y = dd{2};
        p = signrank(x,y);
     
        if p < .001
            h = '***';
        elseif p < .01
            h='**';
        elseif p < .05
            h ='*';
        else
            h = 'none';
        end
        fprintf('h=%s, p=%d \n', h, p);     
        fprintf('===================== \n');
        mn = [
            nanmean(rtime_sym), mean(rtime_lot)];
        
        %err2 = std(rtime_both)/sqrt(length(rtime_both));
        err3 = nanstd(rtime_sym)/sqrt(length(rtime_sym));
        err4 = std(rtime_lot)/sqrt(length(rtime_lot));
        err = [err3, err4];
            
        b = bar(mn, 'EdgeColor', 'k', 'FaceAlpha', 0.6, 'FaceColor', 'flat');
        
        hold on
        b.CData(1, :) = orange_color;
        b.CData(2, :) = orange_color;
        %b.CData(3, :) = orange_color;
  
        ax1 = gca;
        set(gca, 'XTickLabel', {'E_{chosen}', 'D_{chosen}'});
        
        ylim([0, 3500])
        ylabel('Reaction time (ms)');
        e = errorbar(mn, err, 'LineStyle', 'none',...
            'LineWidth', 2.5, 'Color', 'k', 'HandleVisibility','off');
        set(gca, 'Fontsize', 18);
        title(titles{i});
        
        for j = 1:2
            ax(j) = axes('Position',get(ax1,'Position'),'XAxisLocation','top',...
                'YAxisLocation','right','Color','none','XColor','k','YColor','k');
            
            hold(ax(j), 'all');
           
            X = ones(1, nsub)-Shuffle(linspace(-0.15, 0.15, nsub));
            s = scatter(...
                X + (j-1),...
                dd{j},110,...
                'filled', 'Parent', ax1, 'MarkerFaceAlpha', 0.75,...
                'MarkerEdgeAlpha', 1,...
                'MarkerFaceColor', b.CData(j, :),...
                'MarkerEdgeColor', 'w');
            box off
            
            set(gca, 'xtick', []);
            set(gca, 'box', 'off');
            set(ax(j), 'box', 'off');
            
            set(gca, 'ytick', []);
            %ylim([0, 1.15]);
            
            box off
        end
        box off
        uistack(e, 'top');
        
        i = i + 1;
        
        clear dd X mn err err1 err2 err3 err4 nsub ev1 ev2 cho rtime
        clear rtime_sym_vs_sym rtime_sym rtime_both rtime_lot
        clear b
    end
end