%-------------------------------------------------------------------------
init;
%-------------------------------------------------------------------------

selected_exp = [6, 8];
sessions = [0, 1];

displayfig = 'on';

figure('Units', 'centimeters',...
    'Position', [0,0,5.3, 5.3/1.25], 'visible', displayfig)
num = 0;

for exp_num = selected_exp
    num = num + 1;
    
    corr1 = de.extract_ED(exp_num).corr;
    corr2 = de.extract_EE(exp_num).corr;
    
    % add ED exp_%num
    CCR{num, 1} = mean(corr1,2)';
    
    % add EE exp_%num
    CCR{num, 2} = mean(corr2,2)';
    
    
    
end

x1 = CCR{1, 2};
x2 = CCR{2, 2};

skylineplot({x1;x2},8,...
    [green; green],...
    0,...
    1,...
    fontsize,...
    '',...
    '',...
    'Correct choice rate',...
    {'Exp. 6', 'Exp. 7'},...
    0);
hold on
scatter([1], [.8], 'markerfacecolor', 'black', 'markeredgecolor', 'w');
box off
hold on
set(gca, 'tickdir', 'out');