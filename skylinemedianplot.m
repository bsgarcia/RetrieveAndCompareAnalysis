function [Nbar,Nsub] = skylinemedianplot(DataCell,Colors,Yinf,Ysup,Font,Title,LabelX,LabelY,varargin)

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
    clear jitter jitterstrength
    DataMatrix = DataCell{n,:}';
    
    % number of subjects
    Nsub = length(DataMatrix(~isnan(DataMatrix)));

    r = quantile(DataMatrix', 3);
    q1 = r(1); curve = r(2); q2 = r(3);
      
    % PLOT THE VIOLINS
    
    % calculate kernel density estimation for the violin
    [density, value] = ksdensity(...
        DataMatrix, 'Bandwidth', 0.9 * min(std(DataMatrix),...
        iqr(DataMatrix)/1.34) * Nsub^(-1/5)); % change Bandwidth for violin shape.
                                              % Default MATLAB: std(DataMatrix)*(4/(3*Nsub))^(1/5)
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
    fill([n n+density*width n],...
        [value(1) value value(end)],...
        Colors(n,:),...
        'EdgeColor', 'none',...%trace,...
        'FaceAlpha',0.2);
    hold on
    
    % INDIVIDUAL DOTS
    if length(density) > 1
        jitterstrength = interp1(value, density*width, DataMatrix);
    else % all data is identical
        jitterstrength = density*width;
    end

    jitter=abs(zscore(1:length(DataMatrix))'/max(zscore(1:length(DataMatrix))'));
    
	scatter(n - Wbar/10 - jitter.*(Wbar/2- Wbar/10), DataMatrix, 10,...
        Colors(n,:),'filled',...
        'marker','o',...
        'MarkerFaceAlpha',0.4);
    hold on
    
    % ERROR BARS
    errorbar(n+Wbar/4,curve, abs(curve-q1),abs(curve-q2),...
        'Color', Colors(n,:),...
        'LineStyle',':',...  'CapSize',3,...
        'LineWidth',1.3);
    
    hold on
    scatter(n+Wbar/4, curve, 80,...
        'MarkerFaceColor', 'w',...
        'MarkerEdgeColor', Colors(n, :),...
        'LineWidth', 1.3);
%     xMean = [n ; n + Wbar/2];
%     yMean = [curve; curve];
%     plot(xMean,yMean,'-','LineWidth',5,'Color', Colors(n, :));
%     hold on
%     plot(n+Wbar/4, , 80,...
%         'MarkerFaceColor', 'w',...
%         'MarkerEdgeColor', Colors(n, :),...
%         'LineWidth', 1.3);
   
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













