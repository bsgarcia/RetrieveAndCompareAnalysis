function scatterplot(x, y, markersize, color, xlimits, ylimits, xlabel1, ylabel1, title1)  
    xlim(xlimits);
    ylim(ylimits);
    xlabel(xlabel1);
    ylabel(ylabel1);
    hold on
    plot(linspace(xlimits(1), xlimits(2), 10),...
         linspace(ylimits(1), ylimits(2), 10), 'linestyle', ':', 'color', 'k', 'linewidth', .8);
     scatter(x, y, markersize,'MarkerEdgeColor', 'w', ...
        'MarkerFaceColor', color, 'MarkerFaceAlpha', 0.6);
    annotatewithcorr(x, y, xlim, ylim);
    title(title1, 'fontsize', 20);
end


function annotatewithcorr(x, y, xlimits, ylimits)
    [r, p] = corr(x,y);
    ymin = ylimits(1);
    xmax = xlimits(2);
    vert_spacing = ylimits(2)/20;  %may have to experiment with this #
    text(xmax-xmax/3, ymin+vert_spacing*3.5, ['\rho ' sprintf('= %.2f', r)], 'fontsize', 7);
    p1 = 'p > 0.5';
    if p < .05
        p1 = 'p < 0.5';
    end
    if p < 0.01
        p1 = 'p < 0.01';
    end
    if p < 0.001
        p1 = 'p < 0.001';
    end
    text(xmax-xmax/3, ymin+vert_spacing*1.6, p1, 'fontsize', 7);
end