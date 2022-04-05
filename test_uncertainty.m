X = 0.01:.01:0.99;
y = betapdf(X,1,1);

p = .8;

sample = rand(100, 1) < .8;

y2 = betapdf(X, sum(sample), sum(sample==0));

figure
plot(X, y2, 'color', 'k');


figure
px = postp(sample);
plot(X, px, 'color', 'k');

function px = postp(out)
    
    %Compute the discretized posterior probability distribution (discretization
    %step = 0.01). Here we assume that the prior over value is flat:
    prop = 0.01:.01:0.99;
    logpx = sum(out.*log(prop) + (1-out) .* log(1-prop),1);

    px = exp(logpx)./(sum(exp(logpx)));

end