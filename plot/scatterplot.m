function scatterplot(x, y, markersize, color, xlimits, ylimits, xlabel1, ylabel1, title1, location, fit_curve)  
    if ~exist('location')
        location = 'bottomright';
    end

    if ~exist('fit_curve')
        fit_curve = true;
    end
    xlim(xlimits);
    ylim(ylimits);
    xlabel(xlabel1);
    ylabel(ylabel1);
    hold on
    plot(linspace(xlimits(1), xlimits(2), 10),...
         linspace(ylimits(1), ylimits(2), 10), 'linestyle', ':', 'color', 'k', 'linewidth', .8);
     scatter(x, y, markersize,'MarkerEdgeColor', 'w', ...
        'MarkerFaceColor', color, 'MarkerFaceAlpha', 0.6);
    annotatewithcorr(x, y, xlim, ylim, location);

    if fit_curve
        P = polyfit(x, y, 1);
        yhat = polyval(P, x);
        plot(x, yhat, 'color', color, 'LineWidth', 1.3);
    end
    title(title1);
end


function annotatewithcorr(x, y, xlimits, ylimits, location)
    [r, p] = corr(x,y);
    ymin = ylimits(1);
    ymax = ylimits(2);
    xmin = xlimits(1);
    xmax = xlimits(2);


    p1 = 'p > 0.05';
    if p < .05
        p1 = 'p < 0.05';
    end
    if p < 0.01
        p1 = 'p < 0.01';
    end
    if p < 0.001
        p1 = 'p < 0.001';
    end
    vert_spacing = ylimits(2)/20;  %may have to experiment with this #


    if strcmp(location, 'bottomright')
        x_text = xmax-xmax/3;
        y_text1 = ymin+vert_spacing*3.5;
        y_text2 = ymin+vert_spacing*1.6;
    else
        x_text = xmin+xmax/6;
        y_text1 = ymax-vert_spacing*3.5;
        y_text2 = ymax-vert_spacing*1.6;

    end


    text(x_text, y_text1, ['\rho ' sprintf('= %.2f', r)], 'fontsize', 7);
   
    text(x_text, y_text2, p1, 'fontsize', 7);
end