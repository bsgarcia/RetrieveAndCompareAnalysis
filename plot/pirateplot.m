function [Nbar,Nsub] = pirateplot(DataCell,Colors,Yinf,Ysup,Font,Title,LabelX,LabelY,varargin)

% Sophie Bavard - December 2018
% Creates a violin plot with mean, error bars, confidence interval, kernel density.
% Warning: the function can accept any number of arguments > 9.
% After the Title, LabelX, LabelY : varargin for bar names under X-axis

% transforms the Data matrix into cell format if needed
if iscell(DataCell)==0
    DataCell = num2cell(DataCell,2);
end

% number of factors/groups/conditions
Nbar = size(DataCell,1);
% bar size
Wbar = 0.75;

% confidence interval
ConfInter = 0.95;

% color of the box + error bar
trace = [0.5 0.5 0.5];

for n = 1:Nbar
    
    clear DataMatrix
    DataMatrix = DataCell{n,:}';
    
    % number of subjects
    Nsub = length(DataMatrix(~isnan(DataMatrix)));
    
    curve = nanmean(DataMatrix);
    sem   = nanstd(DataMatrix')'/sqrt(Nsub);
    conf  = tinv(1 - 0.5*(1-ConfInter),Nsub);
    
    % COLORED BARS
    % bar(n,curve,...
    %     'FaceColor',Colors(n,:),...
    %     'EdgeColor','none',...
    %     'BarWidth',Wbar,...
    %     'LineWidth',1,...
    %     'FaceAlpha',0.15);
    % hold on
    
    % MEAN HORIZONTAL BAR
    xMean = [n - Wbar/2; n + Wbar/2];
    yMean = [curve; curve];
    hold on, plot(xMean,yMean,'-','LineWidth',2,'Color',Colors(n,:));
    
    % ERROR BARS
    errorbar(n,curve,sem,...
        'Color',Colors(n,:),...%trace-0.1,...
        'LineStyle','none',...
        'LineWidth',1);
    hold on
    
    % CONFIDENCE INTERVAL
    rectangle('Position',[n- Wbar/2, curve - sem*conf, 2*Wbar/2, sem*conf*2],...
        'EdgeColor',trace,...
        'LineWidth',1);
    hold on
    
    % error bar rectangle
    % rectangle('Position',[n- Wbar/4, curve-sem, Wbar/2, sem*2],'EdgeColor',[0.5 0.5 0.5]);
    % hold on
    
    % PLOT THE VIOLINS
    
    % calculate kernel density estimation for the violin
    [density, value] = ksdensity(DataMatrix, 'Bandwidth', 0.9 * min(std(DataMatrix), iqr(DataMatrix)/1.34) * Nsub^(-1/5)); % change Bandwidth for violin shape. Default MATLAB: std(DataMatrix)*(4/(3*Nsub))^(1/5)
    density = density(value >= min(DataMatrix) & value <= max(DataMatrix));
    value = value(value >= min(DataMatrix) & value <= max(DataMatrix));
    value(1) = min(DataMatrix);
    value(end) = max(DataMatrix);
    
    % all data is identical
    if min(DataMatrix) == max(DataMatrix)
        density = 1; value = 1;
    end
    width = Wbar/2/max(density);    
    
    % plot the violin
    fill([n+density*width n-density(end:-1:1)*width],...
        [value value(end:-1:1)],...
        Colors(n,:),...
        'EdgeColor', trace,...
        'FaceAlpha',0.15);
    hold on    
    
    % INDIVIDUAL DOTS INSIDE VIOLIN
    if length(density) > 1
        jitterstrength = interp1(value, density*width, DataMatrix);
    else % all data is identical
        jitterstrength = density*width;
    end
    jitter = 2*(rand(size(DataMatrix))-0.5);
    scatter(n + jitter.*jitterstrength, DataMatrix, 20,...
        'marker','o',...
        'LineWidth',1,...
        'MarkerEdgeColor',Colors(n,:),...
        'MarkerEdgeAlpha',.5);
end

% axes and stuff
ylim([Yinf Ysup]);
set(gca,'FontSize',Font,...
    'XLim',[0 Nbar+1],...
    'XTick',1:Nbar,...
    'XTickLabel',varargin);

title(Title);
xlabel(LabelX);
ylabel(LabelY);













