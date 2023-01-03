function [ RHO PVAL b stats ] = scatterCorr(X, Y, color, alpha, stat,...
    markersize, markeredgecolor, noscatter)

% Corr
[RHO, PVAL] = corr(X, Y, 'rows','complete');



% Text variable
if stat == 1
    test = ['coef= ' num2str(RHO) ' / P= ' num2str(round(PVAL,10))];
elseif stat==2
    % RobustFit
	[b, stats] = robustfit(X, Y);
    test = ['RobustFit pval= ' num2str(stats.p(2,1))];
else
    test = ['no test performed'];
end


P = polyfit(X(~isnan(Y)), Y(~isnan(Y)), 1);
disp(P);
Yf = polyval(P, X);

if exist('noscatter') && noscatter
else
    scat = scatter(X, Y,120, 'MarkerEdgeColor', markeredgecolor,...
        'MarkerFaceColor', color, 'MarkerEdgeAlpha', 1,...
        'MarkerFaceAlpha', alpha, 'linewidth', 1);
end

hold on
plot(X,Yf, 'color', color, 'LineWidth', 2);

% Scatter
xPoint = xlim;
yPoint = ylim;
x = (xPoint(1,1) + xPoint(1,2))/2;
y = (yPoint(1,1) + yPoint(1,2))/1.2;
%x=.75;
%y=.75;
text(x, y, test, 'BackgroundColor', [1 1 1],...
    'FontSize', 12);
set(gca,'FontSize',12)

ylim([min(Y)-0.2 max(Y)+0.2]);
xlim([min(X)-0.2 max(X)+0.2]);

end
