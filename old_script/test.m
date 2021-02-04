clear all
fun = @(x, temp, shift) (1./(1+exp(-temp.*(x-shift(1)))));

psym = [.1 .2 .3 .4 .6 .7 .8 .9];
pcue = 0:.1:1;
temp = 10;
shift = 0.1;
d = [1 1 1 1 1 1 1 0 0 0 0 ];
% 
% for i = 1:length(psym)
%     Y(i,:) = fun(pcue, temp, shift);
% end
for i = 1:length(psym)
  Y(i, :) = 1./(1+exp(temp.*(pcue-shift)));
end

plot(pcue, Y(1,:))

ylim([0 1])