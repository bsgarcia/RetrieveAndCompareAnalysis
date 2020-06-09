% --------------------------------------------------------------------
% This script
% computes correct choice rate then plots the article figs
% --------------------------------------------------------------------
init;

plot_bar_plot_correct_choice_rate_exp(d, idx,  blue_color_gradient, {filenames{[1, 2, 3, 4, end]}})
return


selected_exp = [1, 2, 3, 4, 5.2 6.2, 7.2];
sessions = [0, 1];
selected_exp = [8];

for exp_num = selected_exp
    
    idx1 = (exp_num - round(exp_num)) * 10;
    idx1 = idx1 + (idx1==0);
    
    sess = sessions(uint64(idx1));
    
    exp_name = char(filenames{round(exp_num)});
    
    data = d.(exp_name).data;
    sub_ids = d.(exp_name).sub_ids;
    
    [cho, cfcho, out, cfout, corr1, con1, p1, p2, rew, rtime, ev1, ev2,...
        error_exclude] = ...
        DataExtraction.extract_learning_data(data, sub_ids, idx, sess);
    
    corr{1} = corr1;
    i = 2;
    for m = [4]
        [corr{i}, con2] = ...
            sim_exp_learning(exp_name, exp_num, d, idx, sess, m);
        i = i + 1;
    end
    
    for i = [1, 2]
        for sub = 1:d.(exp_name).nsub
            corr3{i}(sub) = mean(corr{i}(sub, :));
        end
        mn(i) = mean(corr3{i});
        err(i) = std(corr3{i})/sqrt(d.(exp_name).nsub);
    end
    
    % ------------------------------------------------------------------------
    % Plot fig
    % ------------------------------------------------------------------------
    
    figure('Renderer', 'painters',...
        'Position', [927,131,726,447], 'visible', 'on')
    
    nsub = d.(exp_name).nsub;
    b = bar(mn, 'EdgeColor', 'w', 'FaceAlpha', 0.55, 'FaceColor', 'Flat');
    hold on
    ngroups = 1;
    nbars = 2;
%    Calculating the width for each bar group
    groupwidth = min(0.8, ngroups/(ngroups + 1.5));
    cc = [0    0.4470    0.7410;
        0.8500    0.3250    0.0980;
        0.9290    0.6940    0.1250];
    
    for i = 1:ngroups
        x = (1:nbars) - groupwidth/2 + (2*i-1) * groupwidth / (2*ngroups);
        hold on
        for j = 1:length(x)
            b(i).CData(j, :) = cc(j, :);
            try
                s = scatter(...
                    x(j).*ones(1, nsub)-Shuffle(linspace(-0.20, 0.20, nsub)),...
                    corr3{j}, 115,...
                    'MarkerFaceAlpha', 0.65, 'MarkerEdgeAlpha', 1,...
                    'MarkerFaceColor', cc(j, :),...
                    'MarkerEdgeColor', 'w', 'HandleVisibility','off');
            catch
                
            end
            errorbar(x(j), mn(j), err(j), 'LineStyle', 'none', 'LineWidth',...
                2.5, 'Color', 'k', 'HandleVisibility','off');
        end
        
    end
    hold off
    ylim([0, 1.08]);
    xticklabels({'Data', 'PM'});
    ylabel('Correct choice rate');
    title(sprintf('Exp. %s', num2str(exp_num)));
    
    
    saveas(gcf, ...
        sprintf('fig/exp/exp_%s.png', num2str(exp_num)));
    
    clear mn err corr3 corr corr2
    
end

% plot_bar_plot_corr_choice_rate_contingencies(d, idx, blue_color_gradient, filenames, selected_exp)
% mkdir('fig/exp', 'bar_plot_correct_choice_rate');
% saveas(gcf, ...
%     sprintf('fig/exp/bar_plot_correct_choice_rate/fig_cond_exp_1.png', to_add));
% 
%saveas(gcf,...
%    sprintf('fig/exp/bar_plot_correct_choice_rate/fig_exp_1_2_3.png', to_add));
% 

function plot_bar_plot_correct_choice_rate_exp(...
    d, idx,  blue_color_gradient, exp_names)

    titles = {'Exp. 1', 'Exp. 2', 'Exp. 3',...
        'Exp. 4', 'Exp. 8', 'Exp. 6', 'Exp. 7', 'Exp. 8'};

    n_exp = length(exp_names);
    i = 1;

    sub = 1;
    nsub = 0;
    colors = blue_color_gradient(1:8, :, :);

    figure('Position', [1,1,1650,1200]);

    for exp_name = {exp_names{:}}
        session = [0, 1];
        exp_name = char(exp_name);

          [cho, cfcho, out, cfout, corr, con, p1, p2, rew, rtime, ev1, ev2] = ...
        DataExtraction.extract_learning_data(...
        d.(exp_name).data, d.(exp_name).sub_ids, idx, session);

        nsub = nsub + size(cho, 1);

        for isub = 1:size(cho, 1)
            if mean(corr(isub, :)) < .1
                corr_rate{i}(isub) = .5;
                continue
            end
            corr_rate{i}(isub) = mean(corr(isub, :));
            reac_time{i}(isub) = median(rtime(isub, :));
        end

        i = i + 1;

    end

    for j = 1:length(corr_rate)
        mn_corr(j) = mean(corr_rate{j});
        err_corr(j) = std(corr_rate{j})/sqrt(size(corr_rate{j}, 2));
    end

    for j = 1:length(reac_time)
        mn_rt(j) = mean(reac_time{j});
        err_rt(j) = std(reac_time{j})/sqrt(size(reac_time{j}, 2));
    end
    y_label = {'Correct choice rate', 'Reaction times (ms)'};
    y_lim = {[0, 1.07], [0, 3500]};
    for j = [1]
        if j == 1
            mn = mn_corr;
            err = err_corr;
            dd = corr_rate;
        else
            mn = mn_rt;
            err = err_rt;
            dd = reac_time;
        end


        b = bar(mn, 'EdgeColor', 'w', 'FaceAlpha', 0.6, 'FaceColor', 'flat');
        box off
        b.CData(:, :) = colors(1:n_exp, :, :);
        hold on

        ax1 = gca;
        set(gca, 'XTickLabel', {titles{1:n_exp}});

        ylim(y_lim{j})
        ylabel(y_label{j});
        e = errorbar(mn, err, 'LineStyle', 'none',...
            'LineWidth', 3.5, 'Color', 'k', 'HandleVisibility','off');
        set(gca, 'Fontsize', 18);
        yline(.5, 'LineStyle', '--', 'LineWidth', 2);
        hold on
        for j = 1:n_exp

            ax(j) = axes('Position',get(ax1,'Position'),'XAxisLocation','top',...
                'YAxisLocation','right','Color','none','XColor','k','YColor','k');

            hold(ax(j), 'all');
            nsub = length(dd{j});
            X = ones(1, nsub)-Shuffle(linspace(-0.15, 0.15, nsub));
            s = scatter(...
                X + (j-1),...
                dd{j}, 200,...
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

end

function plot_bar_plot_corr_choice_rate_contingencies(...
    d, idx, blue_color_gradient, exp_names, exp_num)

i = 1;
sub = 1;
nsub = 0;
colors = blue_color_gradient(2:2:8, :, :);

figure('Position', [1,1,1300,900]);

titles = {'Exp. 1', 'Exp. 2', 'Exp. 3',...
    'Exp. 4', 'Exp. 5', 'Exp. 6', 'Exp. 7', 'All Exp.'};

for exp_name = {exp_names{:}}
    session = [0 , 1];
    
    exp_name = char(exp_name);
    
    [cho, out, cfout, corr, con, p1, p2, rew, rtime] = ...
        DataExtraction.extract_learning_data(...
        d.(exp_name).data, d.(exp_name).sub_ids, idx, session);
    
    nsub = nsub + size(cho, 1);
    
    for isub = 1:size(cho, 1)
        for icond = 1:4
            corr_rate(sub, icond) = mean(corr(isub, (con(isub, :) == icond)));
            reac_time(sub, icond) = median(rtime(isub, (con(isub, :) == icond)));
            
        end
        sub = sub+1;
    end
    i = i + 1;
end


corr_rate = fliplr(corr_rate);
reac_time = fliplr(reac_time);
y_label = {'Correct choice rate', 'Reaction times (ms)'};
y_lim = {[0, 1.07], [0, 3500]};
dd =  {corr_rate, reac_time};
for k = [1]
    mn = mean(dd{k}, 1);
    err = std(dd{k}, 1)/sqrt(size(dd{k}, 1));
    
    box off
    set(gca, 'xtick', []);
    hold on
    b = bar(mn, 'EdgeColor', 'w', 'FaceAlpha', 0.6, 'FaceColor', 'flat');
    box off
    b.CData(:, :) = colors;
    hold on
    
    ax1 = gca;
    set(gca, 'xtick');
    set(gca, 'XTickLabel', {'60/40', '70/30','80/20','90/10'});
    
    ylim(y_lim{k})
    ylabel(y_label{k});
    e = errorbar(mn, err, 'LineStyle', 'none',...
        'LineWidth', 3.5, 'Color', 'k', 'HandleVisibility','off');
    set(gca, 'Fontsize', 18);
    title(titles{exp_num});
    yline(.5, 'LineStyle', '--', 'LineWidth', 2);
    
    for j = 1:4
        ax(j) = axes('Position',get(ax1,'Position'),'XAxisLocation','top',...
            'YAxisLocation','right','Color','none','XColor','k','YColor','k');
        
        hold(ax(j), 'all');
        
        X = ones(1, nsub)-Shuffle(linspace(-0.15, 0.15, nsub));
        s = scatter(...
            X + (j-1),...
            dd{k}(:, j), 110,...
            'filled', 'Parent', ax1, 'MarkerFaceAlpha', 0.75,...
            'MarkerEdgeAlpha', 1,...
            'MarkerFaceColor', b.CData(j, :),...
            'MarkerEdgeColor', 'w');
        box off
        
        set(gca, 'xtick', []);
        set(gca, 'box', 'off');
        set(ax(j), 'box', 'off');
        
        set(gca, 'ytick', []);
        
        box off
    end
    box off
    uistack(e, 'top');
    
    clear corr_rate
    clear reac_time
end

end

