function [nbar, nsub] = brick_comparison_plot2(data1, data2, color1, color2, y_lim,fontsize,mytitle, ... 
    x_label,y_label,varargin, noscatter, x_lim, x_values)
% Sophie Bavard - December 2018
% Creates a violin plot with mean, error bars, confidence interval, kernel density.
% Warning: the function can accept any number of arguments > 9.
% After the Title, LabelX, LabelY : varargin for bar names under X-axis

% transforms the Data matrix into cell format if needed
if iscell(data1)==0
    data1 = num2cell(data1,2);
end
if iscell(data2)==0
    data2 = num2cell(data2,2);
end

if ~exist('noscatter')
    noscatter = 0;
end

% number of factors/groups/conditions
nbar = size(data1,1);
% bar size
Wbar = .025.*100;
%disp(Wbar)

% confidence interval
ConfInter = 0.95;

% color of the box + error bar
trace = [0.5 0.5 0.5];
% 

for n = 1:nbar
    
    clear Data1Matrix Data2Matrix
    clear jitter jitterstrength
    Data1Matrix = data1{n,:}';
    Data2Matrix = data2{n, :}';
    
    % -- 1st dataset

    % number of subjects
    nsub = length(Data1Matrix(~isnan(Data1Matrix)));
    
    curve = nanmean(Data1Matrix);
    sem   = nanstd(Data1Matrix')'/sqrt(nsub);
    mystd = nanstd(Data1Matrix);
    conf  = tinv(1 - 0.5*(1-ConfInter),nsub);
    
    width = Wbar/15;
    
    fill([x_values(n)+width x_values(n)+Wbar x_values(n)+Wbar x_values(n)+width],...
        [curve-sem*conf curve-sem*conf curve+sem*conf curve+sem*conf],...
        set_alpha(color1, .7), 'linewidth', .3, 'edgecolor', color1);
 
    hold on
       
        
    if ~noscatter
        scatter(n - Wbar/10 - jitter.*(Wbar/2- Wbar/10), Data1Matrix, 10,...
            colors(n,:),'filled',...
            'marker','o',...
            'MarkerFaceAlpha',0.4);
        hold on
    end
    
    xMean = [x_values(n)+width ; x_values(n)+Wbar];
    yMean = [curve; curve];
    plot(xMean,yMean,'-','LineWidth',.3,'Color','black');
    hold on
    
     % ERROR BARS
    % ERROR BARS
    errorbar(x_values(n)+Wbar/2,curve,sem,...
        'Color','k',...Colors(n,:),...
        'LineStyle','none','CapSize',.5,...
        'LineWidth',.3);
    hold on    

    % -- 2nd dataset
    
    % number of subjects
    nsub = length(Data2Matrix(~isnan(Data2Matrix)));
    
    curve = nanmean(Data2Matrix);
    sem   = nanstd(Data2Matrix')'/sqrt(nsub);
    mystd = nanstd(Data2Matrix);
    conf  = tinv(1 - 0.5*(1-ConfInter),nsub);
    
    
        
    fill([x_values(n)-width x_values(n)-Wbar x_values(n)-Wbar x_values(n)-width],...
        [curve-sem*conf curve-sem*conf curve+sem*conf curve+sem*conf],...
        set_alpha(color2, .7), 'linewidth', .2, 'edgecolor', color2);%,...
     
    hold on
%     

    if ~noscatter
        scatter(n - Wbar/10 - jitter.*(Wbar/2- Wbar/10), Data2Matrix, 10,...
            colors(n,:),'filled',...
            'marker','o',...    
            'MarkerFaceAlpha',0.4);
        hold on
    end
    xMean = [x_values(n)-width ; x_values(n)-Wbar];
    yMean = [curve; curve];
    plot(xMean,yMean,'-','LineWidth',.3,'Color','black');
    hold on
     % ERROR BARS
    % ERROR BARS
    errorbar(x_values(n)-Wbar/2,curve,sem,...
        'Color','k',...Colors(n,:),...
        'LineStyle','none','CapSize',.5,...
        'LineWidth',.3);
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
set(gca,'FontSize',fontsize,...
    'XLim', x_lim ,...
    'XTick',varargin,...
    'XTickLabel',varargin);

title(mytitle);
xlabel(x_label);
ylabel(y_label);

x_lim = [min(varargin), max(varargin)];%get(gca, 'YLim');get(gca, 'XLim');
y_lim = [min(varargin), max(varargin)];%get(gca, 'YLim');

y0 = plot(linspace(x_lim(1), x_lim(2), 10),...
    ones(10,1).*50, 'LineStyle', '--', 'Color', 'k', 'linewidth', .4);
y0.Color(4) = .45;
uistack(y0, 'bottom');

hold on

x = linspace(x_lim(1), x_lim(2), 10);

y = linspace(y_lim(1), y_lim(2), 10);
p0 = plot(x, y, 'linewidth', .4, 'LineStyle', '--', 'Color', 'k');

p0.Color(4) = .45;
hold on
uistack(p0, 'bottom');