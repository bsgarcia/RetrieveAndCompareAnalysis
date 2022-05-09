% Probability space
X = 0.01:.01:0.99;

% objective probability of the experiential cue
p = .8;

% generate a sample of outcomes (0s and 1s) according to probability of the
% experiential cue 
% The sample size corresponds to the memory span let's say
sample = rand(100, 1) < p;

% We assume flat priors!!

% one way to compute the posterior probability of the experiential cue 
% is a to assume a beta distribution. A known shortcut to update beta
% distributions is to increment the alpha parameter by the number of 
% success outcomes (1), and conversely the beta parameter by the number of 
% fails (0)
y1 = betapdf(X, sum(sample), sum(sample==0))./100;

figure
plot(X, y1, 'color', 'k');
ylabel('density')
xlabel('p')
title('Beta updating')


% Another way is what Sophie used in her code
% (and consequently I as well in our simulations)
% However I can't find the rational for this calculation (maybe I'm dumb)
% it looks a like an expected value calculation fed into a softmax, or
% perhaps it is a simple bayes rule however i did not find any equation
% online that fits this formula so far
figure
y2 = postp(sample);
plot(X, y2, 'color', 'b');
ylabel('density')
xlabel('p')
title("Sophie's way")


% after computing the posterior we can compute the probability of choosing
% the experiential cue over the symbolic cue, basically the sum of the
% density that comes after the symbolic cue objective p, as explained in
% the slide's schematic
 

function px = postp(sample)
    %(sophie's commment)
    %Compute the discretized posterior probability distribution (discretization
    %step = 0.01). Here we assume that the prior over value is flat:
    prop = 0.01:.01:0.99;
    logpx = sum(sample.*log(prop) + (1-sample) .* log(1-prop),1);
    % apply softmax
    px = exp(logpx)./(sum(exp(logpx)));
end