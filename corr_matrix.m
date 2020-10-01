%-------------------------------------------------------------------------
init;
%-------------------------------------------------------------------------

selected_exp = [1, 2, 3, 4, 5, 6.2, 7.2];
sessions = [0, 1];

displayfig = 'on';


figure('Renderer', 'painters',...
    'Position', [145,157,828*3,900], 'visible', 'off')
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
  
    [cho, cfcho, out, cfout, corr1, con1, p1, p2, rew, rtime, ev1, ev2,...
            error_exclude] = ...
            DataExtraction.extract_learning_data(data, sub_ids, idx, sess);
    
    [corr2, cho, out2, p1, p2, ev1, ev2, ctch, cont1, cont2, dist] = ...
        DataExtraction.extract_sym_vs_lot_post_test(...
        data, sub_ids, idx, sess);
    
    ev = unique(p1);
    varargin = ev;
    x_values = ev;
    x_lim = [0, 1];
    
    sim_params.d = d;
    sim_params.idx = idx;
    sim_params.sess = sess;
    sim_params.exp_name = name;
    sim_params.exp_num = exp_num;
    sim_params.model = 1;
    
        
    subplot(2, 4, num)
% 
    shift1 = get_qvalues(sim_params); 
   
    sim_params.model = 2;
    [shift3, throw] = get_qvalues(sim_params);
    corr3 = throw.corr;
    
    %shift2(nsub+1:end, :) = [];
    slope1 = add_linear_reg(shift1, ev, blue_color);
    hold off
    slope2 = add_linear_reg(shift2, ev, orange_color);   
    hold off
    slope3 = add_linear_reg(shift3, ev, magenta_color);
    hold off
    if exp_num > 4
        
        param = load(...
            sprintf('data/post_test_fitparam_EE_exp_%d_%d',...
            round(exp_num), sess));
        shift4 = param.shift;
        [corr4, cho, out2, p1, p2, ev1, ev2, ctch, cont1, cont2, dist] = ...
            DataExtraction.extract_sym_vs_sym_post_test(...
            data, sub_ids, idx, sess);
        
        
        slope4 = add_linear_reg(shift4, ev, magenta_color);
        hold off
    end
%     
%     brick_comparison_plot2(...
%         shift1',shift2',...
%         orange_color, blue_color, ...
%         [0, 1], 11,...
%         '',...
%         '',...
%         '', varargin, 1, x_lim, x_values);
%     
%     if exp_num == 1
%     ylabel('Indifference point')
%     end
%     
%    
%     xlabel('P(win)');
%     box off
%     hold on
%     
    set(gca, 'fontsize', fontsize);
    
    %set(gca, 'ytick', [0:10]./10);
    set(gca,'TickDir','out')
    
%     title(sprintf('Exp. %s', num2str(exp_num)));

    
%     figure('Renderer', 'painters',...
%     'Position', [145,157,700,650], 'visible', 'on')
%     
    dd(1, :) = mean(corr1, 2);%slope2(:, 2)';
    dd(2, :) = mean(corr2, 2);%slope1(:, 2)';
    dd(3, :) = mean(corr3, 2);%slope3(:, 2)';
    label{1} = 'LE';
    label{2} = 'ED';
    label{3} = 'PM';
    
    if exist('corr4')
        dd(4, :) = mean(corr4, 2);%slope4(:, 2)';
        label{4} = 'EE';
    end
    
    heatmap(corrcoef(dd'))
    set(gca, 'xdata', label);
    set(gca, 'ydata', label);
    title(sprintf('Exp. %s', num2str(exp_num)));

   
     bigdd{1, num} = dd(1, :)';
     bigdd{2, num} = dd(2, :)';
     bigdd{3, num} = dd(3, :)';
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

mkdir('fig/exp', 'corr_matrix');
        saveas(gcf, ...
            sprintf('fig/exp/corr_matrix/matrix.svg',...
            num2str(exp_num)));



% figure('Renderer', 'painters',...
%     'Position', [145,157,700,650], 'visible', 'on')
%    
slope_lt = {bigdd{1,:}}';
slope_ed = {bigdd{2,:}}';
slope_pm = {bigdd{3,:}}';

% C=slope_ed;
% maxLengthCell=max(cellfun('size',C,1));  %finding the longest vector in the cell array
% for i=1:length(C)
%     for j=cellfun('size',C(i),1)+1:maxLengthCell
%         C{i}(j)=NaN;   %zeropad the elements in each cell array with a length shorter than the maxlength
%     end
% end
% slope_ed=cell2mat(C'); %A is your matrix
% slope_ed(:, 5) = 1;
% 
% C=slope_lt;
% maxLengthCell=max(cellfun('size',C,1));  %finding the longest vector in the cell array
% for i=1:length(C)
%     for j=cellfun('size',C(i),1)+1:maxLengthCell
%         C{i}(j)=NaN;   %zeropad the elements in each cell array with a length shorter than the maxlength
%     end
% end
% slope_lt = cell2mat(C');
% slope_lt(:, 5) = 0;

% T = array2table([slope_lt; slope_ed],...
% 'variablenames', {'exp_1', 'exp_2', 'exp_3', 'exp_4', 'modality'});
T = table();
i = 0;
for c = 1:4
    for row = 1:length(slope_ed{c})
        i = i +1;
        T1 = table(i, c, slope_ed{c}(row), 2, 'variablenames',...
            {'subject', 'exp_num', 'slope', 'modality'});
        T = [T; T1];
    end
end
% end
i = 0;
for c = 1:4
    for row = 1:length(slope_lt{c})
        i = i + 1;
        T1 = table(i, c, slope_lt{c}(row), 1, 'variablenames',...
            {'subject', 'exp_num', 'slope', 'modality'});
        T = [T; T1];
    end
end
i = 0;
for c = 1:4
    for row = 1:length(slope_pm{c})
        i = i + 1;
        T1 = table(i, c, slope_pm{c}(row), 3, 'variablenames',...
            {'subject', 'exp_num', 'slope', 'modality'});
        T = [T; T1];
    end
end

writetable(T, 'data/LT_anova.csv');
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
% T = cell2table(slope_ed, 'VariableNames', {'exp_1', 'exp_2', 'exp_3', 'exp_4'});
