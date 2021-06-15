close all
clear all

% data
p_sym = [0:10]'./10;

y = p_sym;

x = p_sym;

scatter(x, y);
hold on 

fitlm(x, y)