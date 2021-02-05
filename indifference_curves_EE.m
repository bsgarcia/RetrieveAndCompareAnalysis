%-------------------------------------------------------------------------
init;
%-------------------------------------------------------------------------

selected_exp = [5];

displayfig = 'on';
sessions = [0, 1];

figure('Renderer', 'painters',...
    'Position', [145,157,828*length(selected_exp)/37,600/37], 'visible', displayfig)

num = 0;
for exp_num = selected_exp
    num = num + 1;
    idx1 = (exp_num - round(exp_num)) * 10;
    idx1 = idx1 + (idx1==0);
    sess = sessions(uint64(idx1));
    
    % load data
    name = char(filenames{round(exp_num)});
    
    data = d.(name).data;
    sub_ids = d.(name).sub_ids;
    
    data = de.extract_EE(exp_num);
    
    
    d.(name).nsub = size(data.cho, 1);
    % ----------------------------------------------------------------------
    % Compute for each symbol p of chosing depending on described cue value
    % ------------------------------------------------------------------------
    
    pcue = unique(data.p2)';
    psym = unique(data.p1)';
    
    chose_symbol = nan(d.(name).nsub, length(pcue), length(psym), 2);
    for i = 1:d.(name).nsub
        for j = 1:length(pcue)
            for k = 1:length(psym)
                temp = ...
                    cho(i, logical((data.p2(i, :) == pcue(j)) .* (data.p1(i, :) == psym(k))));
                for l = 1:length(temp)
                    chose_symbol(i, j, k, l) = temp(l) == 1;
                end
            end
        end
    end
    
    nsub = size(data.cho, 1);
    k = 1:nsub;
    
    prop = zeros(length(psym), length(pcue));
    temp1 = data.cho(k, :);
    for j = 1:length(pcue)
        for l = 1:length(psym)
            temp = temp1(...
                logical((data.p2(k, :) == pcue(j)) .* (data.p1(k, :) == psym(l))));
            prop(l, j) = mean(temp == 1);
            err_prop(l, j) = std(temp == 1)./sqrt(length(temp));
            
        end
    end
    
    X = reshape(...
        repmat(pcue, size(k, 2), size(chose_symbol, 4)), [], 1....
        );
    
    pp = zeros(length(psym), length(pcue));
    
    for i = 1:length(psym)
        Y = reshape(chose_symbol(k, :, i, :), [], 1);
        [logitCoef, dev] = glmfit(...
            X, Y, 'binomial','logit');
        pp(i, :) = glmval(logitCoef, pcue', 'logit');
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
            pcue(isfinite(prop(i, :))).*100,  prop(i,isfinite(prop(i, :))).*100,...
            'Color', green_color, 'LineWidth', 4.5...% 'LineStyle', '--' ...
            );
        
        
        lin3.Color(4) = alpha(i);
        
        hold on      
        
        [xout, yout] = intersections(lin3.XData, lin3.YData, lin1.XData, lin1.YData);
        try
        xx(i) = xout;
        yy(i) = yout;
        catch
            disp('tt');
            
        end
        sc2 = scatter(xout, yout, 200, 'MarkerFaceColor', lin3.Color,...
            'MarkerEdgeColor', 'w');
        sc2.MarkerFaceAlpha = alpha(i);
        
        if num == 1
            ylabel('P(choose symbol) (%)');
        end
        xlabel('Lottery p(win) (%)');
        
        ylim([-0.08*100, 1.08*100]);
        xlim([-0.08*100, 1.08*100]);
        
        box off
    end
    

    set(gca,'TickDir','out')
    set(gca, 'FontSize', fontsize);

    clear pp pcue psym temp err_prop prop i
    
end
mkdir('fig/exp', 'ind_curves_bhv');
saveas(gcf, ...
    sprintf('fig/exp/ind_curves_bhv/full_ED.svg'));
