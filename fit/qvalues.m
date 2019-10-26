function lik = qvalues(params, s, a, ev, nz, ntrials)

Q = reshape(params, nz);
lik = 0;

for t = 1:ntrials
    if isnan(ev(t))
        lik = lik + Q(s(t), a(t))- log(sum(exp(Q(s(t), :))));        
        
    else
        choice = [ev(t), Q(s(t))];
        value = choice((a(t) == 1) + 1);
        lik = lik + value - log(sum(exp(choice)));
    end
end

lik = -lik; % LL vector taking into account both the likelihood
end

