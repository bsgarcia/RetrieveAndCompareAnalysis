function [newcurve, sem] = surfaceplot(data, chancelvl, color, lw, ...
    alpha, ylow, yhigh, font, titlelabel, xaxislabel, yaxislabel)

    [ntrial, nsub] = size(data);
    
    
    curve = nanmean(data, 2);
    sem = nanstd(data')'/ sqrt(nsub);
    
    curveSup = (curve + sem);
    curveInf = (curve - sem);

    for n = 1:ntrial
        chance(n, 1) = chancelvl(1);
        chance(n, 2) = chancelvl(2);
        chance(n, 3) = chancelvl(3);
    end
    
    if nsub > 1
        plot(curve+sem, ...
            'color', color, ...
            'lineWidth', lw);
        hold on
        plot(curve-sem, ...
            'color', color, ...
            'lineWidth', lw);
        hold on
    end
    newcurve = plot(curve, 'B', ...
        'color', color, ...
        'lineWidth', lw*2);
    hold on

    plot(chance, 'k:', ...
        'lineWidth', lw/4);
    
    axis([0, ntrial + 1, ylow, yhigh]);
    set(gca, 'fontsize', font);
    set(gca, 'TickLength', [0, 0]);

    title(titlelabel);
    xlabel(xaxislabel);
    ylabel(yaxislabel);

    if nsub > 1
        % Fill curve
        fill([1:ntrial, flipud([1:ntrial]')'], [curveSup', flipud(curveInf)'],...
            color, ...
            'lineWidth', 1, ...
            'lineStyle', 'none', ...
            'Facecolor', color, ...
            'Facealpha', alpha);
    end
    
    box off
end
