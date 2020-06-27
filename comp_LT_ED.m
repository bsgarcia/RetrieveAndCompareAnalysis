%-------------------------------------------------------------------------
init;
%-------------------------------------------------------------------------

selected_exp = [1,3,4];
sessions = [0, 1];

displayfig = 'on';

num = 0;
for exp_num = selected_exp
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
        sprintf('data/post_test_fitparam_ED_exp_%d',...
        round(exp_num)));
    shift1(1:nsub, :) = param.shift(1:nsub, :);
    
    [corr, cho, out2, p1, p2, ev1, ev2, ctch, cont1, cont2, dist] = ...
        DataExtraction.extract_sym_vs_lot_post_test(...
        data, sub_ids, idx, sess);
    
    ev = unique(p1);
    varargin = ev;
    x_values = ev;
    x_lim = [0, 1];
    
    sim_params.d = d;
    sim_params.idx = idx;
    sim_params.sess = 0;
    sim_params.exp_name = name;
    sim_params.exp_num = exp_num;
    sim_params.model = 1;
    
    shift2 = get_qvalues(sim_params);
    shift2(nsub+1:end, :) = [];
    
    
    figure('Renderer', 'painters',...
    'Position', [145,157,700,650], 'visible', 'on')
    
    
    slope1 = add_linear_reg(shift1, ev, orange_color);
    slope2 = add_linear_reg(shift2, ev, blue_color);      
    
    brick_comparison_plot2(...
        shift1',shift2',...
        orange_color, blue_color, ...
        [0, 1], 11,...
        '',...
        '',...
        '', varargin, 1, x_lim, x_values);
    
    ylabel('Indifference point')
    
   
    xlabel('Experienced cue win probability');
    box off
    hold on
    
    set(gca, 'fontsize', fontsize);
    
    %set(gca, 'ytick', [0:10]./10);
    set(gca,'TickDir','out')
    
    title(sprintf('Exp. %s', num2str(exp_num)));
    
    
    figure('Renderer', 'painters',...
    'Position', [145,157,700,650], 'visible', 'on')
    
    dd(1, :) = slope1(:, 2)';
    dd(2, :) = slope2(:, 2)';
    
    bigdd{1, num} = dd(1,:)';
    bigdd{2, num} = dd(2, :)';
    
    skylineplot(dd,...
        [orange_color; blue_color],...
        min(dd,[],'all')-.08,...
        max(dd,[],'all')+.08,...
        20,...
        '',...
        '',...
        '',...
        {'ED', 'LT'},...
        0);
    ylabel('Slope');
    set(gca, 'tickdir', 'out');
    box off
    
    title(sprintf('Exp. %s', num2str(exp_num)));
    
    
end

% figure('Renderer', 'painters',...
%     'Position', [145,157,700,650], 'visible', 'on')
%    
slope_ed = {bigdd{1,:}}';
slope_lt = {bigdd{2,:}}';

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
for c = 1:3
    for row = 1:length(slope_ed{c})
        i = i +1;
        T1 = table(i, c, slope_ed{c}(row), 1, 'variablenames', {'subject', 'exp_num', 'slope', 'modality'});
        T = [T; T1];
    end
end
for c = 1:3
    for row = 1:length(slope_lt{c})
        i = i + 1;
        T1 = table(i, c, slope_lt{c}(row), 0, 'variablenames', {'subject', 'exp_num', 'slope', 'modality'});
        T = [T; T1];
    end
end

writetable(T, 'data/LT_ED_anova.csv');
    
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
