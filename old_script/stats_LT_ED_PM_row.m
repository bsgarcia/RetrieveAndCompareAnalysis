%-------------------------------------------------------------------------
init;
%-------------------------------------------------------------------------

selected_exp = [5, 6.2];
sessions = [0, 1];

displayfig = 'off';


figure('Renderer', 'painters',...
    'Position', [145,157,828*length(selected_exp),600], 'visible', displayfig)
num = 0;

for exp_num = selected_exp
    disp(exp_num)
    num = num + 1;
    
    clear qvalues b pY2 ind_point Y dd slope1 slope2  dd shift1 shift2
    
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
    shift2 = param.shift;
    
     param = load(...
        sprintf('data/post_test_fitparam_EE_exp_%d_%d',...
        round(exp_num), sess));
    shift4 = param.shift;
    
    [corr, cho, out2, p1, p2, ev1, ev2, ctch, cont1, cont2, dist] = ...
        DataExtraction.extract_sym_vs_lot_post_test(...
        data, sub_ids, idx, sess);
    
    ev = unique(p1).*100;
    varargin = ev;
    x_values = ev;
    x_lim = [0, 100];
    
    sim_params.d = d;
    sim_params.idx = idx;
    sim_params.sess = sess;
    sim_params.exp_name = name;
    sim_params.exp_num = exp_num;
    sim_params.model = 1;
    
    subplot(1, length(selected_exp), num)
% 
    shift1 = get_qvalues(sim_params); 
   
    sim_params.model = 2;
    [shift3, throw] = get_qvalues(sim_params);
    
    %shift2(nsub+1:end, :) = [];
    slope1 = add_linear_reg(shift1.*100, ev, blue_color);   
    hold off
    slope2 = add_linear_reg(shift2.*100, ev, orange_color);
    hold off
    slope3 = add_linear_reg(shift3.*100, ev, magenta_color);
    hold off
    
    slope4 = add_linear_reg(shift4.*100, ev, green_color);
    hold off
%     
%     brick_comparison_plot2(...
%         shift1'.*100,shift2'.*100,...
%         orange_color, blue_color, ...
%         [0, 100], 11,...
%         '',...
%         '',...
%         '', varargin, 1, x_lim, x_values);
%     
%     if num == 1
%         ylabel('Indifference point (%)')
%     end
%     
%    
%     xlabel('Symbol p(win) (%)');
%     box off
%     hold on
% %     
%     set(gca, 'fontsize', fontsize);
%     
%     %set(gca, 'ytick', [0:10]./10);
%     set(gca,'TickDir','out')
    
%     title(sprintf('Exp. %s', num2str(exp_num)));

    
%     figure('Renderer', 'painters',...
%     'Position', [145,157,700,650], 'visible', 'on')
%     
    dd(1, :) = slope1(:, 2)';
    dd(2, :) = slope2(:, 2)';
    dd(3, :) = slope3(:, 2)';
    dd(4, :) = slope4(:, 2)';
    %
    bigdd{1, num} = dd(1, :)';
    bigdd{2, num} = dd(2, :)';
    bigdd{3, num} = dd(3, :)';
    bigdd{4, num} = dd(4, :)';
%     skylineplot(dd,...
%         [blue_color; orange_color; magenta_color],...
%         -1,...
%         1.7,...
%         20,...
%         '',...
%         '',...
%         '',...
%         {'LT', 'ED', 'PM'},...
%         0);
%     if exp_num == 1
%         ylabel('Slope');
%     end
%     set(gca, 'tickdir', 'out');
%     box off
%     
%     title(sprintf('Exp. %s', num2str(exp_num)));
%     
    
end
% mkdir('fig/exp', 'brickplot');
% saveas(gcf, ...
%     'fig/exp/brickplot/LT_ED.svg');
% return
% 

slope_lt = {bigdd{1,:}}';
slope_ed = {bigdd{2,:}}';
slope_pm = {bigdd{3,:}}';
slope_ee = {bigdd{4,:}}';
T = table();

for c = 1:length(selected_exp)
    for sub = 1:length(slope_lt{c})
        T1 = table(sub, c, slope_lt{c}(sub), 1, 'variablenames',...
            {'subject', 'exp_num', 'slope', 'modality'});
        T = [T; T1];
    end
end
for c = 1:length(selected_exp)
    for sub = 1:length(slope_ed{c})
        T1 = table(sub, c, slope_ed{c}(sub), 2, 'variablenames',...
            {'subject', 'exp_num', 'slope', 'modality'});
        T = [T; T1];
    end
end
for c = 1:length(selected_exp)
    for sub = 1:length(slope_pm{c})
        T1 = table(sub, c, slope_pm{c}(sub), 3, 'variablenames',...
            {'subject', 'exp_num', 'slope', 'modality'});
        T = [T; T1];
    end
end

writetable(T, 'data/LE_ED_PM.csv');
%     
%     skyline_comparison_plot({bigdd{1,:}}',{bigdd{2,:}}',...
%         [orange_color; blue_color],...
%         -0.7,...
%         1.75,...
%         20,...
%         '',...
%         '',...
%         '',...
%         1:4,...
%         0);
%     ylabel('Slope');
%     set(gca, 'tickdir', 'out');
%     box off
%     
%     title(sprintf('', num2str(exp_num)));
% 
