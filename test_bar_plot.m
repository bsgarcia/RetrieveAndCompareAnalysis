% --------------------------------------------------------------------
% This script 
% computes correct choice rate then plots the article figs
% --------------------------------------------------------------------

init;
filenames{6} = 'block_complete_mixed_2s';

%------------------------------------------------------------------------
% Plot fig
%------------------------------------------------------------------------
plot_bar_plot_corr_choice_rate_contingencies(d, idx, blue_color_gradient, filenames)
saveas(gcf, 'fig/exp/all/correct_choice_rate_learning_cont.png');

plot_bar_plot_correct_choice_rate_exp(d, idx,  blue_color_gradient, filenames)
saveas(gcf, 'fig/exp/all/correct_choice_rate_learning_exp.png');



function plot_bar_plot_correct_choice_rate_exp(...
    d, idx,  blue_color_gradient, exp_names)
   
    titles = {'Exp. 1', 'Exp. 2', 'Exp. 3',...
        'Exp. 4', 'Exp. 5 Sess. 1', 'Exp. 5 Sess. 2'};
    
    i = 1;

    sub = 1;
    nsub = 0;
    colors = blue_color_gradient(3:8, :, :);
    
    figure('Position', [1,1,1650,900]);
         
    for exp_name = {exp_names{:}}
        if i == 6
            session = 1;
        else
            session = 0;
        end
        
        exp_name = char(exp_name);
        nsub = nsub + d.(exp_name).nsub;
     
        [cho, out, cfout, corr, con, p1, p2, rew] = ...
            DataExtraction.extract_learning_data(...
            d.(exp_name).data, d.(exp_name).sub_ids, idx, session);
        
        for isub = 1:d.(exp_name).nsub
            corr_rate{i}(isub) = mean(corr(isub, :));
        end
        
        i = i + 1;

    end
    
    for j = 1:length(corr_rate)
        mn(j) = mean(corr_rate{j});
        err(j) = std(corr_rate{j})/sqrt(size(corr_rate{j}, 2));
    end
    
    b = bar(mn, 'EdgeColor', 'k', 'FaceAlpha', 0.6, 'FaceColor', 'flat');
    b.CData(:, :) = colors;
    hold on
    
    ax1 = gca;
    set(gca, 'XTickLabel', titles);
    
    ylim([0, 1.07])
    ylabel('Correct choice rate');
    e = errorbar(mn, err, 'LineStyle', 'none',...
        'LineWidth', 3, 'Color', 'k', 'HandleVisibility','off');
    set(gca, 'Fontsize', 18);
    
    for j = 1:6
        ax(j) = axes('Position',get(ax1,'Position'),'XAxisLocation','top',...
            'YAxisLocation','right','Color','none','XColor','k','YColor','k');
        
        hold(ax(j), 'all');
        nsub = length(corr_rate{j});
        X = ones(1, nsub)-Shuffle(linspace(-0.15, 0.15, nsub));
        s = scatter(...
            X + (j-1),...
            corr_rate{j},...
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
    
end

function plot_bar_plot_corr_choice_rate_contingencies(...
    d, idx, blue_color_gradient, exp_names)

    i = 1;
    sub = 1;
    nsub = 0;
    colors = blue_color_gradient(2:2:8, :, :);
    
    figure('Position', [1,1,1300,900]);
         
    for exp_name = {exp_names{:}}
        if i == 6
            session = 1;
        else
            session = 0;
        end
        
        exp_name = char(exp_name);
        nsub = nsub + d.(exp_name).nsub;
     
        [cho, out, cfout, corr, con, p1, p2, rew] = ...
            DataExtraction.extract_learning_data(...
            d.(exp_name).data, d.(exp_name).sub_ids, idx, session);
        
        for isub = 1:d.(exp_name).nsub
            for icond = 1:4
                corr_rate(sub, icond) = mean(corr(isub, (con(isub, :) == icond)));
            end
            sub = sub+1;
        end
        i = i + 1;
    end
    corr_rate = fliplr(corr_rate);
    mn = mean(corr_rate, 1);
    err = std(corr_rate, 1)/sqrt(size(corr_rate, 1));
    
    b = bar(mn, 'EdgeColor', 'k', 'FaceAlpha', 0.6, 'FaceColor', 'flat');
    b.CData(:, :) = colors;
    hold on
    
    ax1 = gca;
    set(gca, 'XTickLabel', {'60/40', '70/30','80/20','90/10'});
    
    ylim([0, 1.07])
    ylabel('Correct choice rate');
    e = errorbar(mn, err, 'LineStyle', 'none',...
        'LineWidth', 3, 'Color', 'k', 'HandleVisibility','off');
    set(gca, 'Fontsize', 18);
    
    for j = 1:4
        ax(j) = axes('Position',get(ax1,'Position'),'XAxisLocation','top',...
            'YAxisLocation','right','Color','none','XColor','k','YColor','k');
        
        hold(ax(j), 'all');
        
        X = ones(1, nsub)-Shuffle(linspace(-0.15, 0.15, nsub));
        s = scatter(...
            X + (j-1),...
            corr_rate(:, j),...
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
     
end

