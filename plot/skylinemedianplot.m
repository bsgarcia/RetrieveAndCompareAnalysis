function [Nbar, Nsub] = skylinemedianplot(...
    DataCell, MarkerSize, Colors, Yinf, Ysup, Font, Title, LabelX, LabelY, varargin)

    % -------------------------------------------------------------------
    % Basile Garcia based on Sophie Bavard's skylineplot.m script
    % December 2018
    % Creates a violin plot with median, quartile 1, quartile 3, 
    % kernel density.
    % Warning: the function can accept any number of arguments > 9.
    % After the Title, LabelX, LabelY : varargin for bar names under X-axis
    % -------------------------------------------------------------------

    % transforms the Data matrix into cell format if needed
    if iscell(DataCell)==0
        DataCell = num2cell(DataCell,2);
    end

    % number of factors/groups/conditions
    Nbar = size(DataCell,1);
    % bar size
    Wbar = 0.75;

    for n = 1:Nbar

        clear DataMatrix
        clear jitter jitterstrength
        DataMatrix = DataCell{n,:}';

        % number of subjects
        Nsub = length(DataMatrix(~isnan(DataMatrix)));

        r = quantile(DataMatrix', 3);
        q1 = r(1); med = r(2); q3 = r(3);
        
        % ----------------------------------------------------------------
        % PLOT THE VIOLINS
        % ----------------------------------------------------------------
        % calculate kernel density estimation for the violin
        % change Bandwidth for violin shape.
        % Default MATLAB:
        % std(DataMatrix)*(4/(3*Nsub))^(1/5)
        [density, value] = ksdensity(...
            DataMatrix, 'Bandwidth', 0.9 * min(std(DataMatrix),...
            iqr(DataMatrix)/1.34) * Nsub^(-1/5)); 
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
        
        % ----------------------------------------------------------------
        % INDIVIDUAL DOTS
        % ----------------------------------------------------------------
        jitter = abs(zscore(1:length(DataMatrix))'...
            /max(zscore(1:length(DataMatrix))'));
        scatter(n - Wbar/10 - jitter.*(Wbar/2- Wbar/10), DataMatrix, 10,...
            Colors(n,:), 'filled',...
            'marker','o',...
            'MarkerFaceAlpha',0.4);
        hold on
        
        % ----------------------------------------------------------------
        % QUARTILE BARS
        % ----------------------------------------------------------------
        errorbar(n+Wbar/4, med, abs(med-q1),abs(med-q3),...
            'Color', Colors(n,:),...
            'LineStyle',':',...  'CapSize',3,...
            'LineWidth',1.3);
        
        % ----------------------------------------------------------------
        % MEDIAN DOT
        % ----------------------------------------------------------------
        hold on
        scatter(n+Wbar/4, med, 80,...
            'MarkerFaceColor', 'w',...
            'MarkerEdgeColor', Colors(n, :),...
            'LineWidth', 1.3);

    end

    % axes and stuff
    disp(varargin{:})
    ylim([Yinf Ysup]);
    set(gca,'FontSize',Font,...
        'XLim',[0 Nbar+1],...
        'XTick',1:Nbar,...
        'XTickLabel',varargin{:});

    title(Title);
    xlabel(LabelX);
    ylabel(LabelY);

end












