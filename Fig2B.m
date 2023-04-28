%-------------------------------------------------------------------------
init2;
%-------------------------------------------------------------------------

%-------------------------------------------------------------------------%
% parameters of the script                                                %
%-------------------------------------------------------------------------%
selected_exp = [5];
displayfig = 'on';
colors = [orange];
% filenames
filename = 'Fig2B';
figfolder = 'fig';

figname = sprintf('%s/%s.svg', figfolder, filename);
stats_filename = sprintf('data/stats/%s.csv', filename);


figure('Renderer', 'painters','Units', 'centimeters',...
    'Position', [0,0,5.3*length(selected_exp), 5.3/1.25], 'visible', displayfig)

num = 0;
for exp_num = selected_exp
    num = num + 1;
    
    data = de.extract_ES(exp_num);
    disp(data)
    nsub = data.nsub;
    p1 = data.p1;
    p2 = data.p2;

    cho = data.cho;
   
    % ---------------------------------------------------------------------
    % Compute for each symbol p of chosing depending on described cue value
    % ---------------------------------------------------------------------
    p_lot = unique(p2)';
    p_sym = unique(p1)';
   
    prop = zeros(length(p_sym), length(p_lot));
    for i = 1:length(p_sym)
        for j = 1:length(p_lot)
            temp = cho(...
                logical((p2 == p_lot(j)) .* (p1== p_sym(i))));
            prop(i, j) = mean(temp == 1);
            
        end
    end
   
    subplot(1, length(selected_exp), num);
   
    alpha = linspace(.15, .95, length(p_sym));
    lin1 = plot(...
        linspace(p_sym(1)*100, p_sym(end)*100, 12), ones(12,1)*50,...
        'LineStyle', ':', 'Color', [0, 0, 0], 'HandleVisibility', 'off');
   
    for i = 1:length(p_sym)
       
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
    yticks([0:20:100])

    xtickangle(0)
    %set(gca,'fontname','monospaced')  % Set it to times

    %axis equal

    clear pp p_lot p_sym temp err_prop prop i
   
end
saveas(gcf, figname);
