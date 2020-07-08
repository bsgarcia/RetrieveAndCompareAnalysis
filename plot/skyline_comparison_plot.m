function [Nbar,Nsub] = skyline_comparison_plot(DataCell, Model_DataCell1, Colors,Yinf,Ysup,Font,Title,LabelX,LabelY,varargin, noscatter)

% Sophie Bavard - December 2018
% Creates a violin plot with mean, error bars, confidence interval, kernel density.
% Warning: the function can accept any number of arguments > 9.
% After the Title, LabelX, LabelY : varargin for bar names under X-axis

% transforms the Data matrix into cell format if needed
if iscell(DataCell)==0
    DataCell = num2cell(DataCell,2);
end
if iscell(Model_DataCell1)==0
    Model_DataCell1 = num2cell(Model_DataCell1', 1)';
end

% number of factors/groups/conditions
Nbar = size(DataCell,1);
% bar size
Wbar = 0.75;
% middle space
space = Wbar/20;

% confidence interval
ConfInter = 0.95;

% color of the box + error bar
trace = [0 0 0];

for n = 1:Nbar
    
    clear DataMatrix DataModel
    clear jitter jitterstrength
    
    DataMatrix = [DataCell{n,:}]';
    DataModel  = [Model_DataCell1{n,:}]';
    
    % number of subjects
    Nsub = length(DataMatrix(~isnan(DataMatrix)));
    
    curve = nanmean(DataMatrix);
    sem   = nanstd(DataMatrix')'/sqrt(Nsub);
    conf  = tinv(1 - 0.5*(1-ConfInter),Nsub);
    
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
    fill([n-space n-density*width-space n-space],...
        [value(1) value value(end)],...
        Colors(1,:),...
        'EdgeColor', 'none',...%trace,...
        'FaceAlpha',0.3);
    hold on
    
    % CONFIDENCE INTERVAL
    inter = unique(DataMatrix(DataMatrix<curve+sem*conf & DataMatrix>curve-sem*conf),'stable')';
    if length(density) > 1
        d = interp1(value, density*width, [curve-sem*conf sort(inter) curve+sem*conf]);
    else % all data is identical
        d = repmat(density*width,1,2);
    end
    fill([n-space n-d-space n-space],...
        [curve-sem*conf curve-sem*conf sort(inter) curve+sem*conf curve+sem*conf],...
        Colors(1,:),...
        'EdgeColor', 'none',...%trace,...
        'FaceAlpha',0.4);
    hold on
    
    % MEAN HORIZONTAL BAR
    xMean = [n-Wbar/2-space ; n-space];
    yMean = [curve; curve];
    plot(xMean,yMean,'-','LineWidth',1,'Color','k');
    hold on
    
    % ERROR BARS
    errorbar(n-Wbar/4-Wbar/40,curve,sem,...
        'Color','k',...Colors(n,:),...
        'LineStyle','none',...  'CapSize',3,...
        'LineWidth',1);
    hold on    
        
    % CONFIDENCE INTERVAL RECTANGLE
    rectangle('Position',[n-Wbar/2-space, curve - sem*conf, Wbar/2, sem*conf*2],...
        'EdgeColor',Colors(1,:),...
        'LineWidth',1);
    hold on
    
    %% PLOT THE MODEL SIMULATIONS  
    
    clear density value
    
    curve = nanmean(DataModel);
    sem   = nanstd(DataModel')'/sqrt(Nsub);
    conf  = tinv(1 - 0.5*(1-ConfInter),Nsub);
    
    % calculate kernel density estimation for the violin
    [density, value] = ksdensity(DataModel, 'Bandwidth', 0.9 * min(std(DataModel), iqr(DataModel)/1.34) * Nsub^(-1/5)); % change Bandwidth for violin shape. Default MATLAB: std(DataModel)*(4/(3*Nsub))^(1/5)
    density = density(value >= min(DataModel) & value <= max(DataModel));
    value = value(value >= min(DataModel) & value <= max(DataModel));
    value(1) = min(DataModel);
    value(end) = max(DataModel);
    
    % all data is identical
    if min(DataModel) == max(DataModel)
        density = 1; value = 1;
    end
    width = Wbar/2/max(density);
    
    % plot the violin
    fill([n+space n+density*width+space n+space],...
        [value(1) value value(end)],...
        Colors(2, :),...
        'EdgeColor', 'none',...%trace,...
        'FaceAlpha',0.3);
    hold on
    
    % CONFIDENCE INTERVAL
    inter = unique(DataModel(DataModel<curve+sem*conf & DataModel>curve-sem*conf),'stable')';
    if length(density) > 1
        d = interp1(value, density*width, [curve-sem*conf sort(inter) curve+sem*conf]);
    else % all data is identical
        d = repmat(density*width,1,2);
    end
    fill([n+space n+d+space n+space],...
        [curve-sem*conf curve-sem*conf sort(inter) curve+sem*conf curve+sem*conf],...
        Colors(2, :),...
        'EdgeColor', 'none',...%trace,...
        'FaceAlpha',0.4);
    hold on
    
    % MEAN HORIZONTAL BAR
    xMean = [n+space ; n+Wbar/2+space];
    yMean = [curve; curve];
    plot(xMean,yMean,'-','LineWidth',1,'Color','k');
    hold on
    
    % ERROR BARS
    errorbar(n+Wbar/4+Wbar/40,curve,sem,...
        'Color','k',...trace,...
        'LineStyle','none',...  'CapSize',3,...
        'LineWidth',1);
    hold on    
        
    % CONFIDENCE INTERVAL RECTANGLE
    rectangle('Position',[n+space, curve - sem*conf, Wbar/2, sem*conf*2],...
        'EdgeColor',trace,...
        'LineWidth',1);
    hold on
    
end

% axes and stuff
ylim([Yinf Ysup]);
set(gca,'FontSize',Font,...
    'XLim',[0 Nbar+1],...
    'XTick',1:Nbar,...
    'XTickLabel',varargin);
yline(0);

title(Title);
xlabel(LabelX);
ylabel(LabelY);

