function [bars, nbar, nsub] = brickplot2(data,colors,y_lim,fontsize,mytitle, ... 
    x_label,y_label,varargin, noscatter, x_lim, x_values, width1)

% Sophie Bavard - December 2018
% Creates a violin plot with mean, error bars, confidence interval, kernel density.
% Warning: the function can accept any number of arguments > 9.
% After the Title, LabelX, LabelY : varargin for bar names under X-axis

% transforms the Data matrix into cell format if needed
if iscell(data)==0
    data = num2cell(data,2);
end

if ~exist('noscatter')
    noscatter = 0;
end

if ~exist('width1')
    width1 = .8;
    
end

% number of factors/groups/conditions
nbar = size(data,1);
% bar size
Wbar = 0.75;

% confidence interval
ConfInter = 0.95;

% color of the box + error bar
trace = [0.5 0.5 0.5];

for n = 1:nbar
    
    clear DataMatrix
    clear jitter jitterstrength
    DataMatrix = data{n,:}';
    
    % number of subjects
    nsub = length(DataMatrix(~isnan(DataMatrix)));
    
    curve = nanmean(DataMatrix);
    sem   = nanstd(DataMatrix')'/sqrt(nsub);
    mystd = nanstd(DataMatrix);
    conf  = tinv(1 - 0.5*(1-ConfInter),nsub);
    
    width = x_lim(2)*width1/5;
    
    fill([x_values(n)-width x_values(n)+width x_values(n)+width x_values(n)-width],...
        [curve-sem curve-sem curve+sem curve+sem],...
        colors(n,:),...
        'EdgeColor', 'none',...%trace,...
        'FaceAlpha',0.5);
    hold on
    
    
    fill([x_values(n)-width x_values(n)+width x_values(n)+width x_values(n)-width],...
        [curve-sem*conf curve-sem*conf curve+sem*conf curve+sem*conf],...
        colors(n,:),...
        'EdgeColor', 'none',...%trace,...
        'FaceAlpha',0.23);
    hold on
    
%     fill([n-width n+width n+width n-width],...
%         [curve-mystd curve-mystd curve+mystd curve+mystd],...
%         colors(n,:),...
%         'EdgeColor', 'none',...%trace,...
%         'FaceAlpha',0.25);
%     hold on
%         
    if ~noscatter
        try
        scatter((ones(size(DataMatrix)).*n)+Shuffle(linspace(-0.1, .1, nsub))', DataMatrix, 10,...
            colors(n,:),'filled',...
            'marker','o',...
            'MarkerFaceAlpha',0.4);
        catch
            
        
        end
        
        hold on
    end
    
    xMean = [x_values(n)-width ; x_values(n) + width];
    yMean = [curve; curve];
    plot(xMean,yMean,'-','LineWidth',2,'Color',colors(n, :));
    hold on
    
    % ERROR BARS
%     errorbar(n,curve,sem,...
%         'Color','k',...Colors(n,:),...
%         'LineStyle','none',...
%         'LineWidth',1);
    hold on
end

% axes and stuff
ylim(y_lim);

if ~exist('x_lim')
    x_lim = [0, nbar+1];
end
if ~exist('x_values')
    x_values = 1:nbar;
end
disp(fontsize);
set(gca,'FontSize',fontsize,...
    'XLim', x_lim ,...
    'XTick',varargin,...
    'XTickLabel',varargin);

title(mytitle);
xlabel(x_label);
ylabel(y_label);













