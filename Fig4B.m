%-------------------------------------------------------------------------
init;
%-------------------------------------------------------------------------

%-------------------------------------------------------------------------%
% parameters of the script                                                %
%-------------------------------------------------------------------------%
selected_exp = [5];
displayfig = 'on';
colors = [orange];
% filenames
filename = 'Fi4B';
figfolder = 'fig';

figname = sprintf('%s/%s.svg', figfolder, filename);
stats_filename = sprintf('data/stats/%s.csv', filename);


figure('Renderer', 'painters','Units', 'centimeters',...
    'Position', [0,0,5.3*length(selected_exp), 5.3/1.25], 'visible', displayfig)

num = 0;
for exp_num = selected_exp
    num = num + 1;
    
    data = de.extract_ES(exp_num);
    
    nsub = data.nsub;
    p1 = data.p1;
    p2 = data.p2;
    cho = data.cho;
    numel(cho)
    return
   
    % ---------------------------------------------------------------------
    % Compute for each symbol p of chosing depending on described cue value
    % ---------------------------------------------------------------------
    p_lot = unique(p2)';
    psym = unique(p1)';
   
    prop = zeros(length(psym), length(p_lot));
    for l = 1:length(psym)
        for j = 1:length(p_lot)
            temp = cho(...
                logical((p2 == p_lot(j)) .* (p1== psym(l))));
            prop(l, j) = mean(temp == 1);
            
        end
    end
   
    subplot(1, length(selected_exp), num);
   
    pwin = psym;
    alpha = linspace(.15, .95, length(psym));
    lin1 = plot(...
        linspace(psym(1)*100, psym(end)*100, 12), ones(12,1)*50,...
        'LineStyle', ':', 'Color', [0, 0, 0], 'HandleVisibility', 'off');
   
    for i = 1:length(pwin)
       
        hold on
       
        lin3 = plot(...
            p_lot.*100,  prop(i, :).*100,...
            'Color', colors(1,:), 'LineWidth', 1.5 ...% 'LineStyle', '--' ...
            );
        
        lin3.Color(4) = alpha(i);
       
        hold on      
       
        [xout, yout] = intersections(lin3.XData, lin3.YData, lin1.XData, lin1.YData);
       
        sc2 = scatter(xout, yout, 15, 'MarkerFaceColor', lin3.Color,...
            'MarkerEdgeColor', 'w');
        sc2.MarkerFaceAlpha = alpha(i);
       
        if num == 1
            ylabel('P(choose E-option) (%)');
        end
        xlabel('S-option p(win) (%)');
       
        ylim([-0.08*100, 1.08*100]);
        xlim([-0.08*100, 1.08*100]);
       
        box off
    end
      
    set(gca,'TickDir','out')
    set(gca, 'FontSize', fontsize);
    xticks([0:20:100])
    xtickangle(0)
    %set(gca,'fontname','monospaced')  % Set it to times

    %axis equal

    clear pp p_lot psym temp err_prop prop i
   
end
saveas(gcf, figname);
