function lpp = getlpp_learning(params, s, a, cfa, r, cfr, ntrials, model)

    addpath './'
    
    p = getp(params, model);
   
    p = -sum(p);

    l = getll_learning(params, s, a, cfa, r, cfr, ntrials, model);
    lpp = p + l;
end


function p = getp(params, model)
    %% log prior of parameters
    switch model
        case 1
            beta1 = params(1); % choice temphiature
            alpha1 = params(2); % policy or factual learning rate
            %% the parameters based on the first optimzation
            pbeta1 = log(gampdf(beta1, 1.2, 5.0));
            palpha1 = log(betapdf(alpha1, 1.1, 1.1));
            p = [pbeta1, palpha1];
        case 2
            beta1 = params(1); % choice temphiature
            alpha1 = params(2); % policy or factual learning rate
            alpha2 = params(3); % policy or factual learning rate
            pbeta1 = log(gampdf(beta1, 1.2, 5.0));
            palpha1 = log(betapdf(alpha1, 1.1, 1.1));
            palpha2 = log(betapdf(alpha2, 1.1, 1.1));
            p = [pbeta1, palpha1, palpha2];

    end
  
end

function v = rescale1(x, xmin, xmax, vmin, vmax)
    v = (vmax - vmin) * (x - xmin)/(xmax - xmin) + vmin;
end

