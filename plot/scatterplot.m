function scatterplot(x, y, color, xlimits, ylimits, xlabel1, ylabel1, title1)
    scatter(x, y, 90,'MarkerEdgeColor', 'w', ...
        'MarkerFaceColor', color, 'MarkerFaceAlpha', 0.6);
    xlim(xlimits);
    ylim(ylimits);
    xlabel(xlabel1);
    ylabel(ylabel1);
    hold on
    plot(linspace(xlimits(1), xlimits(2), 10),...
         linspace(ylimits(1), ylimits(2), 10), 'linestyle', '--', 'color', 'k');
    annotatewithcorr(x, y, xlim, ylim);
    title(title1, 'fontsize', 20);
end


function annotatewithcorr(x, y, xlimits, ylimits)
    [r, p] = corr(x,y);
    ymin = ylimits(1);
    xmax = xlimits(2);
    vert_spacing = ylimits(2)/20;  %may have to experiment with this #
    text(xmax-xmax/3, ymin+vert_spacing*2, sprintf('rho=%.3f', r));
    text(xmax-xmax/3, ymin+vert_spacing*1, sprintf('p=%d', p));
end