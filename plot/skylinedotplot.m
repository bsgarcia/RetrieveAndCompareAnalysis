function [Nbar, Nsub] = skylineboxplot(DataCell, error, markersize, Colors,Yinf,Ysup,Font,Title,LabelX,LabelY,varargin)

% Sophie Bavard - December 2018 / Modified Basile Garcia
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
Wbar = 0.7;

% confidence interval
ConfInter = 0.95;

for n = 1:Nbar
    
    clear DataMatrix
    clear jitter jitterstrength
    
    DataMatrix = DataCell{n,:}';
     
    % number of subjects
    Nsub = length(DataMatrix(~isnan(DataMatrix)));
    
    curve = nanmean(DataMatrix);
    switch error
        case 'sem'
            sem   = nanstd(DataMatrix')'/sqrt(Nsub);
        case 'std'
            sem  = nanstd(DataMatrix')';
        otherwise 
            disp('Error estimator not recognized! Available estimators: "sem", "std"');
    end
    conf  = tinv(1 - 0.5*(1-ConfInter),Nsub);
    
    % PLOT THE VIOLINS
    
    % calculate kernel density estimation for the violin
    [density, value] = ksdensity(DataMatrix, 'Bandwidth', 0.9 * min(std(DataMatrix),...
        iqr(DataMatrix)/1.34) * Nsub^(-1/5)); % change Bandwidth for violin shape. Default MATLAB: std(DataMatrix)*(4/(3*Nsub))^(1/5)
    
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
        set_alpha(Colors(n,:), .3), 'linewidth', .2,...
        'EdgeColor', 'none'...%trace,...
        );
    hold on
    
    % CONFIDENCE INTERVAL    
    inter = unique(DataMatrix(DataMatrix<curve+sem*conf & DataMatrix>curve-sem*conf),'stable')';
    if length(density) > 1
        d = interp1(value, density*width, [curve-sem*conf sort(inter) curve+sem*conf]);
    else % all data is identical
        d = repmat(density*width,1,2);
    end 
%     fill([n-(Wbar/10) n-(Wbar/10)+ones(1,length(d)).*(Wbar/5) n-(Wbar/10)],...
%         [curve-sem curve-sem sort(inter) curve+sem curve+sem],...
%         set_alpha(Colors(n,:), .7),...
%         'EdgeColor', 'none'...%trace,...
%     );
%     hold on
    
        % CONFIDENCE INTERVAL
%     rectangle('Position',[n-(Wbar/10), curve-sem, Wbar/5, sem*2],...
%         'EdgeColor','k',...
%         'LineWidth',0.5);
%     hold on
%     
    % INDIVIDUAL DOTS
    if length(density) > 1
        jitterstrength = interp1(value, density*width, DataMatrix);
    else % all data is identical
        jitterstrength = density*width;
    end

    jitter=abs(zscore(1:length(DataMatrix))'/max(zscore(1:length(DataMatrix))'));
    
    s = scatter(n - Wbar/6 - jitter.*(Wbar/2- Wbar/8), DataMatrix, markersize,...
        Colors(n,:),'filled',...
        'marker','o', 'linewidth', .2,...
        'MarkerEdgeColor','w',...
        'MarkerFaceAlpha',0.6);
    hold on
    
    
    
    plot([n, n], [curve, curve+sem], 'color',  set_alpha(Colors(n,:), .8), 'linewidth', 2);
    hold on
    plot([n, n], [curve, curve-sem], 'color',  set_alpha(Colors(n,:), .8), 'linewidth', 2);
    hold on
    plot([n, n], [curve+sem, curve+sem*conf], 'color', set_alpha(Colors(n,:), .8));
    hold on
    plot([n, n], [curve-sem, curve-sem*conf], 'color',  set_alpha(Colors(n,:), .8));
    hold on

    xMean = [n];
    yMean = [curve];
    scatter(xMean,yMean, 12, 'markerfacecolor', 'w', 'markeredgecolor',set_alpha(Colors(n,:), .8));
    hold on
    hold on
    uistack(s, 'top');
    

end

% axes and stuff
ylim([Yinf Ysup]);
disp(Font);
set(gca,'FontSize',Font,...
    'XLim',[0 Nbar+1],...
    'XTick',1:Nbar,...
    'XTickLabel',varargin{:});

title(Title);
xlabel(LabelX);
ylabel(LabelY);













