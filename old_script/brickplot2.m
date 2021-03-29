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
Wbar = 0.055*100;

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
    
    width = Wbar/15;
    
    fill([x_values(n)-Wbar x_values(n)+Wbar x_values(n)+Wbar x_values(n)-Wbar],...
        [curve-sem*conf curve-sem*conf curve+sem*conf curve+sem*conf],...
        set_alpha(colors(n,:), .23),...
        'edgecolor', 'black', 'linewidth', 0.1);%,...%trace,...
        %'FaceAlpha',0.23);
    hold on
      
        
    fill([x_values(n)-Wbar x_values(n)+Wbar x_values(n)+Wbar x_values(n)-Wbar],...
        [curve-sem curve-sem curve+sem curve+sem],...
        set_alpha(colors(n,:), .7),'linewidth', 0.1);%,...
       %'linewidth', 1^-10, 'edgecolor',set_alpha(color2, .7));%,...%trace,...
        %'FaceAlpha',0.5);
    hold on
    
    xMean = [x_values(n)-Wbar; x_values(n)+Wbar];
    yMean = [curve; curve];
    ppp = plot(xMean,yMean,'LineWidth',0.6,'Color',colors(n,:));
    hold on

    if ~noscatter
        try
            
        scatter(ones(size(DataMatrix)).*x_values(n)+shuffle(linspace(-3, 3,  nsub))', DataMatrix, 2.5,...
            colors(n,:),'filled',...
            'marker','o',...
            'MarkerFaceAlpha',0.4, 'markeredgecolor', 'w', 'linewidth', 0.05)   
        catch
        end
        hold on
    end
    
   
    
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
set(gca,'FontSize',fontsize,...
    'XLim', x_lim ,...
    'XTick',varargin,...
    'XTickLabel',varargin);

title(mytitle);
xlabel(x_label);
ylabel(y_label);

end

function c = set_alpha(rgb, a)
    c = (1-a).* [1, 1, 1] + rgb .* a;
end
    
 function v=shuffle(v)
     v=v(randperm(length(v)));
 end










