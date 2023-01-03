%-------------------------------------------------------------------------
init;
%-------------------------------------------------------------------------

%-------------------------------------------------------------------------%
% parameters of the script                                                %
%-------------------------------------------------------------------------%
selected_exp = [5, 6];
displayfig = 'off';
colors = [green];
% filenames
filename = 'Fig3B';
figfolder = 'fig';

figname = sprintf('%s/%s.svg', figfolder, filename);
stats_filename = sprintf('data/stats/%s.csv', filename);


figure('Renderer', 'painters','Units', 'centimeters',...
    'Position', [0,0,5.3*length(selected_exp), 5.3/1.25], 'visible', displayfig)

num = 0;
for exp_num = selected_exp
    num = num + 1;
    
    data = de.extract_EE(exp_num);
    
    nsub = data.nsub;
    p1 = data.p1;
    p2 = data.p2;
    cho = data.cho;
   
    % ----------------------------------------------------------------------
    % Compute for each symbol p of chosing depending on described cue value
    % ------------------------------------------------------------------------
    
    pcue = unique(p2)';
    psym = unique(p1)';
    
    chose_symbol = nan(nsub, length(pcue), length(psym));
    for i = 1:nsub
        for j = 1:length(pcue)
            for k = 1:length(psym)
                temp = ...
                    cho(i, logical((data.p2(i, :) == pcue(j)) .* (data.p1(i, :) == psym(k))));
                
            end
        end
    end
    
    nsub = size(cho, 1);
    k = 1:nsub;
    
    temp1 = data.cho(k, :);
    prop = nan(length(psym), length(pcue));
    for j = 1:length(pcue)
        for l = 1:length(psym)
            temp = temp1(...
                logical((data.p2(k, :) == pcue(j)) .* (data.p1(k, :) == psym(l))));
            prop(l, j) = mean(temp == 1);
            err_prop(l, j) = std(temp == 1)./sqrt(length(temp));
            
        end
    end

    subplot(1, length(selected_exp), num)
    %prop = nanmean(prop, 1);

    pwin = psym;
    alpha = linspace(.15, .95, length(psym));
    lin1 = plot(...
        linspace(psym(1)*100, psym(end)*100, 12), ones(12,1)*50,...
        'LineStyle', ':', 'Color', [0, 0, 0], 'HandleVisibility', 'off');
    
    for i = 1:length(pwin)
        
        hold on
        
        
        lin3 = plot(...
            pcue(isfinite(prop(i, :))).*100,  prop(i,isfinite(prop(i, :))).*100,...
            'Color', colors(1,:), 'LineWidth',1.5...% 'LineStyle', '--' ...
            );
        
        
        lin3.Color(4) = alpha(i);
        
        hold on      
        
        [xout, yout] = intersections(lin3.XData, lin3.YData, lin1.XData, lin1.YData);
        try
            xx(i) = xout;
            yy(i) = yout;
        catch
            fprintf('Intersection p(%d): No indifferent point \n', pwin(i));
            
        end
        sc2 = scatter(xout, yout, 15, 'MarkerFaceColor', lin3.Color,...
            'MarkerEdgeColor', 'w');
        sc2.MarkerFaceAlpha = alpha(i);
        
        ylabel('P(choose E-option) (%)');
        
        xlabel('E-option p(win) (%)');
        
        ylim([-0.08*100, 1.08*100]);
        xlim([-0.08*100, 1.08*100]);
        xticks(0:20:100)

        box off
    end
    

    set(gca,'TickDir','out')
    set(gca, 'FontSize', fontsize);

    clear pp pcue psym temp err_prop prop i
end
saveas(gcf, figname);
