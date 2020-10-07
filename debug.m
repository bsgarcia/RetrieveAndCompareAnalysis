clear all

i = 0;
j = 0;

for midpoint = [1:9]./10
    i = i + 1;
    disp(i);
    for temp = linspace(0.01, 1000, 50)
        j = j + 1;
       
        x = linspace(0, 1, 12);
        y = logfun(x', midpoint, temp);

        [xout, yout] = intersections(x, y, x, ones(1, 12)*0.5);
        
        deviation(i, j) = abs(midpoint - xout);
    end
end

figure('Renderer', 'painters', 'visible', 'on');

h = heatmap(deviation');
xlabel('midpoint');
ylabel('temperature');
h.XData = string([1:9]./10);


function p = logfun(x, midpoint, temp)
    p = 1./(1+exp(-temp.*(midpoint(1)-x)));
end