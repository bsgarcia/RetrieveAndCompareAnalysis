close all
clear all

% data
p_lot = [0:10]./10;


% simulate a rational agent
% 1 = chose symbol
% 0 = chose lottery
% row = n symbol
% col = n choice per sym
p_sym = [.1 .2 .3 .4 .6 .7 .8 .9];

for i = 1:length(p_sym)
    for j = 1:length(p_lot)
        Y(i, j) = p_sym(i) > p_lot(j);
    end
end
% 
% for i = 1:length(p_sym)
%     count = 0;
%     for j = 1:length(p_sym)
%         if i ~= j
%             count = count + 1;
% 
%             Y(i, count) = p_sym(i) > p_sym(j);
%         end
%     end
% end


X = p_lot;
% considering one symbol p = .1


% FIT 
options = optimset(...
    'Algorithm',...
    'interior-point',...
    'Display', 'off',...
    'MaxIter', 10000,...
    'MaxFunEval', 10000);
[params, nll] = fmincon(...
    @(x) tofit_mle2(x, X, Y),...
    [1, ones(1, length(p_sym)) .* .5],...
    [], [], [], [],...
    [0.01, zeros(1, length(p_sym))],...
    [inf, ones(1, length(p_sym))],...
    [],...
    options...
    );

% plot behavioral data
figure
plot(X, Y, 'linewidth', 2);
title('Behavior');


% plot fitted curves
figure
for i = 1:length(p_sym)
    plot(X, logfun(X, params(i+1), params(1)), 'linewidth', 2);
    hold on
end
title('Fit');

%p.Color(4) = .8;


% plot estimates
figure
title('Estimates');
scatter(p_sym, params(2:end));
xlim([0 1])
ylim([0 1])


        
function nll = tofit_mle2(params, X, Y)

    options = optimset('Display','off');
    temp = params(1);
    midpoints = params(2:end);
    ll = 0;
    for i = 1:size(Y, 1)
        yhat = logfun(X, midpoints(i), temp);
        ll = ll + (1/numel(yhat)) * nansum(log(yhat) .* Y(i,:) + log(1-yhat).*(1-Y(i,:))); 
    end
    if isnan(ll)
        error('is nan')
    end
    nll = -ll;
end



function nll = tofit(params, X, Y)
    options = optimset('Display','off');
    temp = params(1);
    midpoints = params(2:end);
    ll = 0;
    for i = 1:size(Y, 1)
        yhat = logfun(X(i,:)', midpoints(i), temp);
        ll = ll + nansum(log(yhat) .* Y(i,:)' + log(1-yhat).*(1-Y(i,:)')); 
    end
    nll = -ll;
end

function p = logfun(x, midpoint, temp)
    p = 1./(1+exp(temp.*(x-midpoint)));
end
