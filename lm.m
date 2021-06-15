close all
clear all

% data
p_lot = [0:10]'./10;

y = [1000, 1100, 1300, 1600, 1800, 1900, 1740, 1600, 1350, 1100, 1000]';
y = [1000, 1100, 1200, 1200, 1200, 1200, 1300, 1100, 1150, 1100, 1000]';

x = p_lot;

scatter(x, y);
hold on 

p = polyfit(x, y, 2);
plot(x, polyval(p,x));
ylim([1000 2000])