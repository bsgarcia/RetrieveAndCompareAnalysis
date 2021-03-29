addpath './fit'
addpath './plot'
addpath './data'
addpath './'
addpath './utils'
addpath './simulation'

clear all
close all

nsub = 80;
x = [.1 .2 .3 .4 .6 .7 .8 .9];

midpoints = nan(nsub, length(x));
noise = 80; % / 100
beta1 = 10;

for i = 1:length(x)
    for j = 1:nsub
        cond = rand > .5;
        midpoints(j, i) = abs(...
            x(i) + (randi(noise)./100) * cond...
            - (randi(noise)./100) * (cond==0));
    end
end


figure('Renderer', 'painters');

alpha = linspace(.15, .95, length(x));
lin1 = plot(...
    linspace(x(1), x(end), 12), ones(12,1).*.5,...
    'LineStyle', ':', 'Color', 'k');

for i = 1:length(x)
    
    hold on
    
    for sub = 1:nsub
        y(sub,:) = logfun(x, midpoints(sub, i), beta1);
    end
    
    
    lin2 = plot(...
        x,  mean(y), 'Color', 'blue',...
        'LineWidth', 4.5...% 'LineStyle', '--' ...
        );
    
    
    lin2.Color(4) = alpha(i);
    
    hold on
    
    [xout, yout] = intersections(lin2.XData, lin2.YData, lin1.XData, lin1.YData);
    try
        xx(i) = xout;
    catch
        xx(i) = 0;
    end
    sc2 = scatter(xout, yout, 200, 'MarkerFaceColor', lin2.Color,...
        'MarkerEdgeColor', 'w');
    sc2.MarkerFaceAlpha = alpha(i);
    
    
end


set(gca,'TickDir','out')

xlim([-0.08, 1.08])
ylim([-0.08, 1.08])
% set(gca,'Visible','off')
% axes('Position',get(gca,'Position'),...
%  'XAxisLocation','bottom',...
%  'YAxisLocation','left',...
%  'Color','none',...
%  'XTickLabel',get(gca,'XTickLabel'),...
%  'YTickLabel',get(gca,'YTickLabel'),...
%  'XColor','k','YColor','k',...
%  'TickDir','out')%, 'XLim', [-0.08, 1.08], 'YLim',[-0.08, 1.08]);
% xlim([-0.08, 1.08])
% ylim([-0.08, 1.08])
xlabel('Symbol^j p(win)');
ylabel('P choose symbol^i')
box off

fprintf('Average midpoints:\n %s \n', num2str(mean(midpoints)));
fprintf('Average indifference points:\n %s \n', num2str(xx));

function p = logfun(x, midpoint, temp)
p = 1./(1+exp(temp.*(x-midpoint)));
end