function lik = value(params, s1, s2, a, nz, ntrials, type, arg)

Q = reshape(params, nz);
lik = 0;


for t = 1:ntrials
    switch type 
        case 1
  
            lik = lik + Q(s(t), a(t))- log(sum(exp(Q(s(t), :))));
        
        case 2
            % sym vs lot
            choice = [s2(t), Q(s1(t))];
            value = choice((a(t) == 1) + 1);
            lik = lik + value - log(sum(exp(choice)));
        case 3
            % sym vs sym
            choice = [Q(s2(t)), Q(s1(t))];
            value = choice((a(t) == 1) + 1);
            lik = lik + value - log(sum(exp(choice)));       
        case 4
            % amb vs lot
            choice = [Q(1), s1(t)];
            value = choice((a(t) == 1) + 1);
            lik = lik + value - log(sum(exp(choice)));
        case 5
            % sym vs amb
            choice = [s2(t), Q(s1(t))];
            value = choice((a(t) == 1) + 1);
            lik = lik + value - log(sum(exp(choice)));
    end
    
end

lik = -lik; % LL vector taking into account both the likelihood
end

