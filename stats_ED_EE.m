%-------------------------------------------------------------------------
init;
%-------------------------------------------------------------------------

selected_exp = [5, 6.2, 7.2];
sessions = [0, 1];

% displayfig = 'on';
%     
%     figure('Renderer', 'painters',...
%     'Position', [145,157,3312-3312/4,600], 'visible', 'off')
num = 0;
for exp_num = selected_exp
    num = num + 1;
    
    clear qvalues b pY2 ind_point Y dd slope1 slope2 
    
    idx1 = (exp_num - round(exp_num)) * 10;
    idx1 = idx1 + (idx1==0);
    sess = sessions(uint64(idx1));
    % load data
    name = char(filenames{round(exp_num)});
    
    data = d.(name).data;
    sub_ids = d.(name).sub_ids;
    nsub = d.(name).nsub;
       
    param = load(...
        sprintf('data/post_test_fitparam_ED_exp_%d_%d',...
        round(exp_num), sess));
    shift1 = param.shift;
    beta1 = param.beta1;
      
    param = load(...
        sprintf('data/post_test_fitparam_EE_exp_%d_%d',...
        round(exp_num), sess));
    shift2 = param.shift;
    beta2 = param.beta1;
    
    [corr, cho, out2, p1, p2, ev1, ev2, ctch, cont1, cont2, dist] = ...
        DataExtraction.extract_sym_vs_lot_post_test(...
        data, sub_ids, idx, sess);
    
    ev = unique(p1);
    varargin = ev;
    x_values = ev;
    x_lim = [0, 1];
    
    subplot(1, 3, num)
    
    
    slope1 = add_linear_reg(shift1, ev, orange_color);
    slope2 = add_linear_reg(shift2, ev, blue_color);      
    
    brick_comparison_plot2(...
        shift1',shift2',...
        orange_color, blue_color, ...
        [0, 1], 11,...
        '',...
        '',...
        '', varargin, 1, x_lim, x_values);
    
    if num == 1
        ylabel('Indifference point')
    end
    
   
    xlabel('Experienced cue win probability');
    box off
    hold on
    
    set(gca, 'fontsize', fontsize);
    
    %set(gca, 'ytick', [0:10]./10);
    set(gca,'TickDir','out')
    
%     title(sprintf('Exp. %s', num2str(exp_num)));
%     
%     
%     figure('Renderer', 'painters',...
%     'Position', [145,157,700,650], 'visible', 'on')
%     
%     dd(1, :) = slope1(:, 2)';
%     dd(2, :) = slope2(:, 2)';
%     
%      bigdd{1, num} = dd(1,:);
%     bigdd{2, num} = dd(2, :);
%     skylineplot(dd,...
%         [orange_color; blue_color],...
%         min(dd,[],'all')-.08,...
%         max(dd,[],'all')+.08,...
%         20,...
%         '',...
%         '',...
%         '',...
%         {'ED', 'EE'},...
%         0);
%     ylabel('Slope');
%     set(gca, 'tickdir', 'out');
%     box off
%     
%     title('Exp. 6.2');
%     
%      figure('Renderer', 'painters',...
%     'Position', [145,157,700,650], 'visible', 'on')
%     dd(1, :) = beta1';
%     dd(2, :) = beta2';
%     skylineplot(log(dd),...
%         [orange_color; blue_color],...
%         min(log(dd),[],'all')-.08,...
%         max(log(dd),[],'all')+.08,...
%         20,...
%         '',...
%         '',...
%         '',...
%         {'ED','EE'},...
%         0);
%     
%     ylabel('Stochasticity');
%     set(gca, 'tickdir', 'out');
%     box off
%     
%     title(sprintf('Exp. %s', num2str(exp_num)));
%     
%     
% end
end
mkdir('fig/exp', 'post_test_PM');
        saveas(gcf, ...
            sprintf('fig/exp/post_test_PM/full2.svg',...
            num2str(exp_num)));

return

figure('Renderer', 'painters',...
    'Position', [145,157,700,650], 'visible', 'on')

skyline_comparison_plot({bigdd{1,:}}',{bigdd{2,:}}',...
    [orange_color; blue_color],...
    -0.7,...
    1.75,...
    20,...
    '',...
    '',...
    '',...
    1:4,...
    0);
ylabel('Slope');
set(gca, 'tickdir', 'out');
box off



slope_ed = {bigdd{1,:}}';
slope_ee = {bigdd{2,:}}';

T = table();
i = 0;
for c = 1:length(selected_exp)
    for row = 1:length(slope_ed{c})
        i = i +1;
        T1 = table(i, c, slope_ed{c}(row), 0, 'variablenames',...
            {'subject', 'exp_num', 'slope', 'modality'});
        T = [T; T1];
    end
end
i = 0;
for c = 1:length(selected_exp)
    for row = 1:length(slope_ee{c})
        i = i + 1;
        T1 = table(i, c, slope_ee{c}(row), 1, 'variablenames',...
            {'subject', 'exp_num', 'slope', 'modality'});
        T = [T; T1];
    end
end

writetable(T, 'data/ED_EE_anova.csv');