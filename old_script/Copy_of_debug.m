clear all

rng(0);

midpoint = .48; 
temp = 50;

figure('renderer','painters');

x = 0:.1:1; %linspace(.001,1,10);
%
%x = x+.01;
%x(5) = [];
nx = length(x);

y = logfun(x', midpoint, temp);
p = plot(x, y, 'linewidth', 1);
hold on

plot(x, ones(1, nx)*.5);

[xout, yout] = intersections(x, y, x, ones(1, nx)*.5);
scatter(xout, yout, 'markerfacecolor', 'k');

fprintf('midpoint parameter: %d \n', midpoint);
fprintf('intersection (xout): %d \n', xout);

xlim([-0.08,1.08])
ylim([-0.08,1.08])

function p = logfun(x, midpoint, temp)
p = 1./(1+exp(-temp.*(midpoint-x)));
end