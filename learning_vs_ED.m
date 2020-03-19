% -------------------------------------------------------------------%
% This script finds the best fitting Values for each exp             %
% then plots the figs                                                %
% -------------------------------------------------------------------%
init;
% -------------------------------------------------------------------%

selected_exp = [1, 2, 3, 8];
sessions = [0, 1];

i = 1;

for exp_num = selected_exp
    % -------------------------------------------------------------------%
    % LEARNING
    % -------------------------------------------------------------------%
    idx1 = (exp_num - round(exp_num)) * 10;
    idx1 = idx1 + (idx1==0);
    sess = sessions(uint64(idx1));
    clear corr2
    % load data
    exp_name = char(filenames{round(exp_num)});
    
    [cho, cfcho, out, cfout, corr1, con1, p1, p2, rew, rtime, ev1, ev2,...
        error_exclude] = ...
        DataExtraction.extract_learning_data(d.(exp_name).data, d.(exp_name).sub_ids, idx, sess);
    
    [corr3, cho, out2, p1, p2, ev1, ev2, ctch, cont1, cont2, dist] = ...
        DataExtraction.extract_sym_vs_lot_post_test(...
        d.(exp_name).data, d.(exp_name).sub_ids, idx, sess);
    
    for sub = 1:d.(exp_name).nsub
        try
            if ismember(exp_num, [1, 2, 3, 4, 8])
                corr2(sub, :) = corr3(sub, logical(~ismember(p2(sub,:), [0, .5, 1])));
            else
                corr2 = corr3;
            end
        catch
            
        end
    end
    for j = 1:d.(exp_name).nsub
        mn{i,j} = mean(corr1(j, :));
        if mean(corr1(j, :)) < .1
            mn{i,j} = .5;
        end      
    end
    % -------------------------------------------------------------------%
    i = i + 1;
    
    for j = 1:d.(exp_name).nsub
        mn{i,j} = mean(corr2(j, :)) - .29;     
    end
    i = i + 1;

end
% id = [1, 2];
% m1(id, :) = ll(id, 1, :);
% m2(id, :) = ll(id, 2, :);
%
% figure('Position', [354,399,891,692]);
% skyline_comparison_plot(...
%     mn1, mn2,...
%     repmat([blue_color; orange_color], length(selected_exp), 1),...
%     0,...
%     1.08,...
%     20, '', 'Exp.',...
%     'Correct choice rate', ...
%     selected_exp, 0);
%
% legend('Learning', 'ED', 'location', 'southwest');
% box off
% %set(gca, 'XTickLabel', {'ED', 'EE'});
% set(gca, 'Fontsize', 20);

figure('Renderer', 'painters',...
    'Position', [927,131,726,447], 'visible', 'on')

for i = 1:size(mn, 1)
    mn1(i) = mean([mn{i, :}]);
    err(i) = std([mn{i, :}])./sqrt(length([mn{i, :}]));
end

b = bar([ mn1(1), mn1(2);...
        mn1(3), mn1(4);...
        mn1(5), mn1(6);...
        mn1(7), mn1(8) ], ...
    'EdgeColor', 'w', 'FaceAlpha', 0.55, 'FaceColor', 'Flat');
hold on

ngroups = length(mn1)/2;
nbars = 2;
%    Calculating the width for each bar group
groupwidth = min(0.8, ngroups/(ngroups + 1.5));
cc = [0    0.4470    0.7410;
    0.8500    0.3250    0.0980;
    0.9290    0.6940    0.1250];

set(b(1),'FaceColor', cc(1, :))
set(b(2),'FaceColor', cc(2, :))
count = 0;

for i = 1:ngroups
    
     for j = 1:nbars

        count = count + 1;

        nsub = length([mn{count,:}]);
        
        s = scatter(...
            (i + (-0.15*(j==1)) + (0.15*(j==2)) ) *ones(1, nsub)-...
            Shuffle(linspace(-0.05, 0.05, nsub)),...
            [mn{count, :}], 90,...
            'MarkerFaceAlpha', 0.65, 'MarkerEdgeAlpha', 1,...
            'MarkerFaceColor', cc(j, :),...
            'MarkerEdgeColor', 'w', 'HandleVisibility','off');
        box off
            
        hold on
         errorbar((i + (-0.15*(j==1)) + (0.15*(j==2)) ), mn1(count), err(count), 'LineStyle', 'none', 'LineWidth',...
             2.5, 'Color', 'k', 'HandleVisibility','off');
         box off
    end
    
end
hold off
ylim([0, 1.08]);
legend('Learning', 'Post-learning ED');
xticklabels({'Exp. 1', 'Exp. 2', 'Exp. 3', 'Exp. 8'});
ylabel('Correct choice rate');
%title(sprintf('Exp. %s', num2str(exp_num)));

set(gca,'TickDir','out');
