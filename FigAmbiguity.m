%-------------------------------------------------------------------------%
init;
show_current_script_name(mfilename('fullpath'));

%-------------------------------------------------------------------------%
% parameters of the script                                                %
%-------------------------------------------------------------------------%
selected_exp = [7];
displayfig = 'on';
colors = black;

%filenames
filename = 'FigAmb';
figfolder = 'fig';

figname = sprintf('%s/%s.svg', figfolder, filename);
stats_filename = sprintf('data/stats/%s.csv', filename);

symp = [.1, .2, .3, .4, .6, .7, .8, .9];
%
figure('Renderer', 'painters','Units', 'centimeters',...
    'Position', [0,0,5.3, 5.3*2], 'visible', displayfig)

sub_count = 0;
stats_data = table();
num = 0;

for exp_num = selected_exp
    
    num = num + 1;
    
    
    %---------------------------------------------------------------------%
    % get data parameters                                                 %
    % --------------------------------------------------------------------%
    sess = de.get_sess_from_exp_num(exp_num);
    name = de.get_name_from_exp_num(exp_num);
    nsub = de.get_nsub_from_exp_num(exp_num);
    
    dataSA = de.extract_SA(exp_num);
    dataEA = de.extract_EA(exp_num);
    
    EA_a = [];
    SA_a = [];
    for sub = 1:nsub
        for i = 1:length(symp)
            EA_a(sub, i) = mean(dataEA.cho(sub, dataEA.p1(sub,:)==symp(i))==2);%./sqrt(numel(dataEA.cho(dataEA.p1==symp(i))));
            SA_a(sub, i) = mean(dataSA.cho(sub, dataSA.p1(sub,:)==symp(i))==2);%./sqrt(numel(dataSA.cho(dataSA.p1==symp(i))));
        end
    end
    
    for i = 1:length(symp)
        EA(i) = mean(dataEA.cho(dataEA.p1==symp(i))==2);
        EA_e(i) = std(EA_a(:, i))./sqrt(nsub);
        SA_e(i) = std(SA_a(:, i))./sqrt(nsub);
        SA(i) = mean(dataSA.cho(dataSA.p1==symp(i))==2);
    end
    EA_e(i)
    
    subplot(2, 1, 1);
    
    psym = symp;
    pwin = symp;
    alpha = linspace(.15, .95, length(psym));
    lin1 = plot(...
        linspace(psym(1)*100, psym(end)*100, 12), ones(12,1)*50,...
        'LineStyle', ':', 'Color', [0, 0, 0], 'HandleVisibility', 'off');
    
    
    hold on
    
    lin3 = plot(...
        symp.*100,  EA.*100,...
        'Color', colors, 'LineWidth', 1.5 ...% 'LineStyle', '--' ...
        );
    
    %lin3.Color(4) = alpha(i);
    
    hold on
    
    [xout, yout] = intersections(lin3.XData, lin3.YData, lin1.XData, lin1.YData);
    
    errorbar(symp.*100, EA.*100, EA_e.*100, 'Color', set_alpha(colors, .8), 'marker', '.', 'linestyle', 'none');
    hold on
    
    sc2 = scatter(xout, yout, 22, 'MarkerFaceColor', set_alpha(colors, .8),...
        'MarkerEdgeColor', 'w');
    %sc2.MarkerFaceAlpha = alpha(i);
    hold on
    sc2 = scatter(symp.*100, EA.*100, 15, 'MarkerFaceColor', set_alpha(colors, .8),...
        'MarkerEdgeColor', 'w');
    %sc2.MarkerFaceAlpha = .4;
    
    hold on
    
    if num == 1
        ylabel('P(choose A-option) (%)');
    end
    xlabel('E-option p(win) (%)');
    
    ylim([-0.08*100, 1.08*100]);
    xlim([-0.08*100, 1.08*100]);
    
    box off
    set(gca,'TickDir','out')
    set(gca, 'FontSize', fontsize);
    xticks([0:20:100])
    xtickangle(0)
    title('Exp. 8')
    %set(gca,'fontname','monospa
    
    subplot(2, 1, 2);
    
    psym = symp;
    pwin = symp;
    alpha = linspace(.15, .95, length(psym));
    lin1 = plot(...
        linspace(psym(1)*100, psym(end)*100, 12), ones(12,1)*50,...
        'LineStyle', ':', 'Color', [0, 0, 0], 'HandleVisibility', 'off');
    
    
    
    hold on
    
    
    lin3 = plot(...
        symp.*100,  SA.*100,...
        'Color', colors, 'LineWidth', 1.5 ...% 'LineStyle', '--' ...
        );
    
    %lin3.Color(4) = alpha(i);
    
    hold on
    
    [xout, yout] = intersections(lin3.XData, lin3.YData, lin1.XData, lin1.YData);
    
    errorbar(symp.*100, SA.*100, SA_e.*100, 'Color', set_alpha(colors, .8), 'marker', '.', 'linestyle', 'none');
    hold on
    
    sc2 = scatter(xout, yout, 22, 'MarkerFaceColor', set_alpha(colors, .8),...
        'MarkerEdgeColor', 'w');
    %sc2.MarkerFaceAlpha = alpha(i);
    hold on
    sc2 = scatter(symp.*100, SA.*100, 15, 'MarkerFaceColor', set_alpha(colors, .8),...
        'MarkerEdgeColor', 'w');
    %sc2.MarkerFaceAlpha = .4;
    
    hold on
    
    if num == 1
        ylabel('P(choose A-option) (%)');
    end
    xlabel('S-option p(win) (%)');
    
    ylim([-0.08*100, 1.08*100]);
    xlim([-0.08*100, 1.08*100]);
    
    box off
    
    
    set(gca,'TickDir','out')
    set(gca, 'FontSize', fontsize);
    xticks([0:20:100])
    xtickangle(0)
    title('Exp. 8')
    
    %set(gca,'fontname','monospaced')  % Set it to times
    
    %axis equal
    
    clear pp p_lot psym temp err_prop prop i
    
    
    
end

saveas(gcf, figname);

