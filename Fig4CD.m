%-------------------------------------------------------------------------
init;
%-------------------------------------------------------------------------

%-------------------------------------------------------------------------

selected_exp = [6, 7];

stats_filename = 'data/stats/Fig4CD.csv';

displayfig = 'on';
%-------------------------------------------------------------------------

stats_data = table();

num = 0;
sub_count = 0;
for exp_num = selected_exp
    num = num + 1;
    
    dED = de.extract_ES(exp_num);
    dEE = de.extract_EE(exp_num);
    
    corrED = mean(dED.corr,2)';
    corrEE = mean(dEE.corr,2)';
    mean(corrED)
    % add ED exp_%num
    CCR{num, 1} = corrED;
    
    % add EE exp_%num
    CCR{num, 2} = corrEE;
    
    for sub = 1:dED.nsub        
        modalities = {'ED', 'EE'};
        dd = {corrED, corrEE};
        for mod_num = 1:2
        T1 = table(...
                    sub+sub_count, exp_num, dd{mod_num}(sub),...
                    {modalities{mod_num}}, 'variablenames',...
                    {'subject', 'exp_num', 'score', 'modality'}...
                    );
         stats_data = [stats_data; T1];
        end
    end

    dcorr = [];
    p_sym = unique(dED.p1)';
    p_lot = unique(dED.p2)';
    for i = 1:length(p_sym)
        for j = 1:length(p_lot)
            dcorr(i, j) = ...
                (p_lot(j) < .5) * (p_sym(i) >= p_lot(j)) ...
                + (p_lot(j) > .5) * (p_sym(i) <= p_lot(j)) ;
        end
    end
    m(num) = mean(dcorr, 'all');
    
    sub_count = sub_count + sub;
end

% save stats file
mkdir('data', 'stats');
writetable(stats_data, stats_filename);


% filenames
filename = 'Fig4C1';
figfolder = 'fig';
figname = sprintf('%s/%s.svg', figfolder, filename);

figure('Units', 'centimeters',...
    'Position', [0,0,5.3, 5.3/1.25], 'visible', displayfig)

x1 = CCR{1, 1};
x2 = CCR{2, 1};
skylineplot({x1;x2},8,...
    [orange; orange],...
    0,...
    1,...
    fontsize,...
    '',...
    '',...
    'Correct choice rate',...
    {'Exp. 6', 'Exp. 7'},...
    0);


hold on
scatter([1], [m(1)], 'markerfacecolor', 'black', 'markeredgecolor', 'w');
box off
hold on
scatter([2], [m(2)], 'markerfacecolor', 'black', 'markeredgecolor', 'w');
box off
hold on
plot([1, 2], [.5, .5], 'color', 'k', 'LineStyle',':')
set(gca, 'tickdir', 'out');

saveas(gcf, figname)

% filenames
filename = 'Fig4C2';
figfolder = 'fig';
figname = sprintf('%s/%s.svg', figfolder, filename);

figure('Units', 'centimeters',...
    'Position', [0,0,5.3, 5.3/1.25], 'visible', displayfig)

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
plot([1, 2], [.5, .5], 'color', 'k', 'LineStyle',':')


box off
set(gca, 'tickdir', 'out');

saveas(gcf, figname)
