%-------------------------------------------------------------------------
init;
%-------------------------------------------------------------------------

selected_exp = [6.1, 8.1];
sessions = [0, 1];

displayfig = 'on';

figure('Renderer', 'painters',...
    'Position', [145,157, 2*550,600], 'visible', displayfig)
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
    
    
    [corr1, cho, out2, p1, p2, ev1, ev2, ctch, cont1, cont2, dist] = ...
        DataExtraction.extract_sym_vs_lot_post_test(...
        data, sub_ids, idx, sessions);
    
    [corr2, cho, out2, p1, p2, ev1, ev2, ctch, cont1, cont2, dist] = ...
        DataExtraction.extract_sym_vs_sym_post_test(...
        data, sub_ids, idx, sessions);
    
    % add ED exp_%num
    CCR{num, 1} = mean(corr1,2)';
    
    % add EE exp_%num
    CCR{num, 2} = mean(corr2,2)';
    
end


skylineplot(reshape(CCR, [4,1]),60,...
    [orange_color; orange_color;green_color;green_color],...
    0,...
    1,...
    20,...
    '',...
    '',...
    'Correct choice rate',...
    {'Exp. 6', 'Exp. 7'},...
    0);

box off
hold on

set(gca, 'fontsize', fontsize);
set(gca,'TickDir','out')

ED = {CCR{:,1}}';
EE = {CCR{:,2}}';

T = table();
i = 0;
for c = 1:length(selected_exp)
    for row = 1:length(ED{c})
        i = i +1;
        T1 = table(i, c, ED{c}(row), {'ED'}, 'variablenames',...
            {'subject', 'exp_num', 'slope', 'modality'});
        T = [T; T1];
    end
end
i = 0;
for c = 1:length(selected_exp)
    for row = 1:length(EE{c})
        i = i + 1;
        T1 = table(i, c, EE{c}(row), {'EE'}, 'variablenames',...
            {'subject', 'exp_num', 'slope', 'modality'});
        T = [T; T1];
    end
end

writetable(T, 'data/stats/ED_EE_corr.csv');