function slope = add_linear_reg(data, X, color)

    for sub = 1:size(data, 1)
        Y = data(sub, :);
        [slope(sub, :), thrw1, thrw2] = glmfit(X, Y);
        b = glmfit(X, Y);
        pY2(sub, :) = glmval(b,X, 'identity');
    end

    mn = mean(pY2, 1);
    err = std(pY2)./sqrt(size(data, 1));

    curveSup = (mn + err);
    curveInf = (mn - err);

    plot(X, mn, 'LineWidth', .4, 'Color', color);
    hold on

    fill([...
        X'; flipud(X')],...
        [curveInf'; flipud(curveSup')],...
        color, ...
        'lineWidth', 1, ...
        'LineStyle', 'none',...
        'Facecolor', color, ...
        'Facealpha', 0.25);
    hold on

    box off

end

