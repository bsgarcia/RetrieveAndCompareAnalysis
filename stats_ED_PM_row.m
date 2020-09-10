%-------------------------------------------------------------------------
init;
%-------------------------------------------------------------------------

selected_exp = [1, 2, 3, 4];
sessions = [0, 1];

displayfig = 'on';
    
figure('Renderer', 'painters',...
    'Position', [145,157,3312,600], 'visible', 'off')

num = 0;
for exp_num = selected_exp
    num = num + 1;
    
    clear qvalues b pY2 ind_point Y pp pp1 dd
    
    idx1 = (exp_num - round(exp_num)) * 10;
    idx1 = idx1 + (idx1==0);
    sess = sessions(uint64(idx1));
    % load data
    name = char(filenames{round(exp_num)});
    
    data = d.(name).data;
    sub_ids = d.(name).sub_ids;
    nsub = d.(name).nsub;
    
    try
         param = load(...
            sprintf('data/post_test_fitparam_ED_exp_%d_%d',...
            round(exp_num), sess));
    catch 

         param = load(...
            sprintf('data/post_test_fitparam_ED_exp_%d',...
            round(exp_num)));
    end
    
    shift1 = param.shift;
    
    params.exp_name = name;
    params.exp_num = exp_num;
    params.model = 2;
    params.d = d;
    params.idx = idx;
    params.sess = sess;
    [shift2, throw] = get_qvalues(params);
    
    if size(shift1) ~= size(shift2)
        error('ERROR');
        
    end
    
    [corr, cho, out2, p1, p2, ev1, ev2, ctch, cont1, cont2, dist] = ...
        DataExtraction.extract_sym_vs_lot_post_test(...
        data, sub_ids, idx, sess);
    
    ev = unique(p1);
    varargin = ev;
    x_values = ev;
    x_lim = [0, 1];
   

    subplot(1, 4, num)
    
    slope1 = add_linear_reg(shift1, ev, orange_color);
    hold off
    slope2 = add_linear_reg(shift2, ev, magenta_color);  
    hold off
%     brick_comparison_plot2(...
%         shift1',shift2',...
%         orange_color, magenta_color, ...
%         [0, 1], fontsize,...
%         '',...
%         '',...
%         '', varargin, 1, x_lim, x_values);
%     
%     if exp_num == 1
%     ylabel('Indifference point')
%     end
%         
%      if size(slope1) ~= size(slope2)
%         error('ERROR');
%         
%     end
%    
%     xlabel('P(win)');
%     box off
%     hold on
%     
    
    %set(gca, 'ytick', [0:10]./10);
    set(gca,'TickDir','out')
%     
%     title(sprintf('Exp. %s', num2str(exp_num)));
%     
%     
%     figure('Renderer', 'painters',...
%     'Position', [145,157,700,650], 'visible', 'on')
%     
    dd(1, :) = slope1(:, 2)';
    dd(2, :) = slope2(:, 2)';
%       
%     bigdd{1, num} = dd(1,:);
%     bigdd{2, num} = dd(2, :);
%     
    skylineplot(dd,...
        [orange_color; magenta_color],...
        -.7,...
        1.7,...
        20,...
        '',...
        '',...
        '',...
        {'ED', 'PM'},...
        0);
    
    if exp_num == 1
        ylabel('Slope');
    end
    
    set(gca, 'tickdir', 'out');
    set(gca, 'fontsize', fontsize);

    box off
%     
%     title(sprintf('Exp. %s', num2str(exp_num)));
%     
%    figure('Renderer', 'painters',...
%     'Position', [145,157,700,650], 'visible', 'on')
%     dd(1, :) = beta1';
%     dd(2, :) = beta2';
%     skylineplot(log(dd),...
%         [orange_color; magenta_color],...
%         min(log(dd),[],'all')-.08,...
%         max(log(dd),[],'all')+.08,...
%         20,...
%         '',...
%         '',...
%         '',...
%         {'ED','PM'},...
%         0);
%     
%     ylabel('Stochasticity');
%     set(gca, 'tickdir', 'out');
%     box off
%     
%     title('Exp. 6.2');
  
end
mkdir('fig/exp', 'post_test_PM');
        saveas(gcf, ...
            sprintf('fig/exp/post_test_PM/full4.svg',...
            num2str(exp_num)));
return

% figure('Renderer', 'painters',...
%     'Position', [145,157,700,650], 'visible', 'on')
% 
% skyline_comparison_plot({bigdd{1,:}}',{bigdd{2,:}}',...
%     [orange_color; magenta_color],...
%     -0.7,...
%     1.75,...
%     20,...
%     '',...
%     '',...
%     '',...
%     1:4,...
%     0);
% ylabel('Slope');
% set(gca, 'tickdir', 'out');
% box off

% 

slope_ed = {bigdd{1,:}}';
slope_pm = {bigdd{2,:}}';

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
    for row = 1:length(slope_pm{c})
        i = i + 1;
        T1 = table(i, c, slope_pm{c}(row), 1, 'variablenames',...
            {'subject', 'exp_num', 'slope', 'modality'});
        T = [T; T1];
    end
end

writetable(T, 'data/ED_PM_anova.csv');
    
