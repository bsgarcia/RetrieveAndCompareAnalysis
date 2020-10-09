function slope = add_linear_reg(data, X, color)

for sub = 1:size(data, 1)
    Y = data(sub, :);
    [slope(sub, :), thrw1, thrw2] = glmfit(X, Y);
    b = glmfit(X, Y);
    pY2(sub, :) = glmval(b,X, 'identity');
end

mn2 = mean(pY2, 1);
err2 = std(pY2, 1)./sqrt(size(data, 1));

curveSup2 = (mn2 + err2);
curveInf2 = (mn2 -err2);

plot(X, mn2, 'LineWidth', 1.7, 'Color', color);
hold on


fill([...
    (X); flipud((X))],...
    [curveInf2; flipud(curveSup2)],...
    color, ...
    'lineWidth', 1, ...
    'LineStyle', 'none',...
    'Facecolor', color, ...
    'Facealpha', 0.25);
hold on

box off

end

