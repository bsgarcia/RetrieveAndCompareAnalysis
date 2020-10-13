clear all
rng(0);
i = 0;
figure('renderer','painters');
xlim([-0.08,1.08])
ylim([-0.08,1.08])

x = linspace(0, 1, 12);

for midpoint = unidrnd(99, [1, 100])./100
    i = i + 1;
 
    y(i,:) = logfun(x', midpoint, 1000);
    p = plot(y(i,:), 'color', 'k', 'linewidth', 2);
    hold on
    p.Color(4) = .2;
    [xout(i), yout] = intersections(x, y(i,:), x, ones(1, 12)*0.5);
end


yy = mean(y);
[xout2, yout] = intersections(x, yy, x, ones(1, 12)*0.5);

figure
ylim([-0.05, .05])
bar(mean(xout) - xout2);


function p = logfun(x, midpoint, temp)
    p = 1./(1+exp(-temp.*(midpoint(1)-x)));
end