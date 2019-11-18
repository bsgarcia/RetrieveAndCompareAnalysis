function [ RHO PVAL b stats ] = scatterCorr(X, Y, color, alpha, stat, markersize, markeredgecolor, noscatter)

%Scatter Plot + corr (coef + pValue)

% Corr
[RHO,PVAL] = corr(X,Y);

% RobustFit
[b,stats] = robustfit(X, Y);

% Text variable
if stat==1
    test=['coef= ' num2str(RHO) ' / P= ' num2str(PVAL)];
elseif stat==2
    test=['RobustFit pval= ' num2str(stats.p(2,1))];
else
    test=['no test performed']
end



% title(Title,...
%     'FontSize',12)

P = polyfit(X,Y,1);
Yf = polyval(P,X);
hold on
plot(X,Yf,'k');
% Scatter
if exist('noscatter') && noscatter
else
    scat = scatter(X, Y, 'MarkerEdgeColor', markeredgecolor,...
        'MarkerFaceColor', color, 'MarkerEdgeAlpha', 1, 'MarkerFaceAlpha', alpha);
    scat.MarkerEdgeAlpha = 1;

    ylim([min(Y) - 0.1 max(Y) + 0.1]);
    xlim([min(X) - 0.1 max(X) + 0.1]);
    % Text position
end
xPoint=xlim;
yPoint=ylim;
x=(xPoint(1,1)+xPoint(1,2))/2;
 y=(yPoint(1,1)+yPoint(1,2))/2;
%x=.75;
%y=.75;
text(x,y,test,'BackgroundColor',[1 1 1],...
    'FontSize',12);
set(gca,'FontSize',12)


end
