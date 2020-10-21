%-------------------------------------------------------------------------
init;
%-------------------------------------------------------------------------

displayfig = 'off';
figure('Renderer', 'painters','Units', 'centimeters',...
    'Position', [0,0,5.6*3, 5.15/1.25], 'visible', displayfig)

degradors = {[.9, .9]', [.2, .9]', [.9, .2]'};

p_sym = [.1, .2, .3, .4, .6, .7, .8, .9];
p_lot = 0:.1:1;
beta1 = 5;


for num = [1, 2, 3]
    
    xout = zeros(length(p_sym), 1);
    yout = zeros(length(p_sym), 1);

    % ------------------------------------------------------------------- %
    subplot(1, 3, num)
        
    alpha = linspace(.15, .95, length(p_sym));
    
    lin1 = plot(...
        linspace(p_sym(1)*100-10, p_sym(end)*100+10, 12), ones(12,1)*50,...
        'LineStyle', ':', 'Color', [0, 0, 0], 'HandleVisibility', 'off');
    
    for i = 1:length(p_sym)
        
        hold on
        
        ev1 = (p_sym(i)-1*(1-p_sym(i))) .* ones(length(p_lot), 1);
        ev2 = p_lot-1.*(1-p_lot);
        Y = softmax1(ev1, ev2', beta1, degradors{num});
        
        if num == 3
            if i < 4
                Y2 = zeros(length(Y)+1, 1);
                Y2(1) = 0.5;
                Y2(2:end) = Y;
                Y = Y2;
                X = zeros(length(Y), 1);
                X(1:2) = [0, 0.05];
                X(3:end) = p_lot(2:end);
            elseif (i > 5)
                Y2 = zeros(length(Y)+1, 1);
                Y2(end) = 0.5;
                Y2(1:end-1)= Y;
                Y = Y2;
                X = zeros(length(Y), 1);
                X(end-1:end) = [.95, 1];
                X(1:end-2) = p_lot(1:end-1);
            else
                X = p_lot;
            end
        else
            X = p_lot;
        end

        lin3 = plot(...
            X.*100,  Y.*100,...
            'Color', orange_color, 'LineWidth', 1.5...
            );
        
        
        lin3.Color(4) = alpha(i);
        
        hold on
        
        [xout1, yout1] = intersections(...
            X.*100, ones(length(X), 1).*50, X.*100, Y.*100);
        try
        xout(i) = xout1;
        yout(i) = yout1;
        sc2 = scatter(xout(i), yout(i), 15, 'MarkerFaceColor', lin3.Color,...
            'MarkerEdgeColor', 'w');
        sc2.MarkerFaceAlpha = alpha(i);
        catch
        end
        
        xlabel('Lottery p(win) (%)');
        
        ylim([-0.08*100, 1.08*100]);
        xlim([-0.08*100, 1.08*100]);
        
        set(gca, 'tickdir', 'out');
        
        box off
    end
    if num == 1
        ylabel('P(choose symbol) (%)');
    end
    set(gca, 'fontsize', fontsize);
    xticks(0:20:100);

    
    % ------------------------------------------------------------------- %
    
%     subplot(2, 3, num+3)
%    
%     scatter(p_sym.*100, xout, 230,...
%         'markerfacecolor', set_alpha(orange_color, .7), 'markeredgecolor', 'w');% 'markerfacealpha', 0.7);
%     hold on
%     
%     
%     x_lim = [0, 100];
%     y_lim = [0, 100];
%     
%     y0 = plot(linspace(x_lim(1), x_lim(2), 10),...
%         ones(10,1).*y_lim(2)/2, 'LineStyle', '--', 'Color', 'k', 'linewidth', 2.5);
%     y0.Color(4) = .45;
%     uistack(y0, 'bottom');
% 
%     hold on
% 
%     x = linspace(x_lim(1), x_lim(2), 10);
% 
%     y = linspace(y_lim(1), y_lim(2), 10);
%     p0 = plot(x, y, 'linewidth', 2.5, 'LineStyle', '--', 'Color', 'k');
% 
%     p0.Color(4) = .45;
%     hold on
%     uistack(p0, 'bottom');
%     
%     xlim([-10, 110]);
%     ylim([-10, 110]);
%     
%     xticks([]);
%     yticks([]);
%     box on
%     
end

saveas(gcf, 'fig/exp/brickplot/hypotheses.svg');


function p = softmax1(v1, v2, beta1, degradors)
    p = 1./(1+exp(beta1.*([v2*degradors(2) - v1*degradors(1)])));
end

