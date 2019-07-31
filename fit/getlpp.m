function lpp = getlpp(params, s, a, r, model)

    addpath './'

    p = getp(model, params);
   
    p = -sum(p);

    l = getll(params, s, a, r, model);

    lpp = p + l;
end


function p = getp(model, params)

    %% log prior of parameters
    beta1 = params(1); % choice temphiature
    alpha1 = params(2); % policy or factual learning rate
    alpha2 = params(3); % counterfactual or fictif learning rate
    pri = params(4); % priors
    phi = params(5);  % impulsive perseveration
    tau = params(6); % perseveration choice trace
    sig_xi = params(7); % variance innovation
    sig_eps = params(8); % noise variance

    %% the parameters based on the first optimzation
    pbeta1 = log(gampdf(beta1, 1.2, 5.0));
    palpha1 = log(betapdf(alpha1, 1.1, 1.1));
    palpha2 = log(betapdf(alpha2, 1.1, 1.1));
    ppri = log(unifpdf(pri, -1, 1));
    pphi = log(unifpdf(phi, -2, 2));
    ptau = log((unifpdf(tau, 0, 1)));
    psig_xi = log(unifpdf(sig_xi, 0, 1));
    psig_eps = log(unifpdf(sig_eps, 0, 1));
    
    pp = {...
        [pbeta1, palpha1], ... % Sym
        [pbeta1, palpha1, palpha2],... % Asym
        [pbeta1, palpha1, palpha2],... % Asym. Pess
        [pbeta1, palpha1, ppri],... % Prior
        [pbeta1, palpha1, pphi],... % Perse
        [pbeta1, palpha1, pphi, ptau],... %GradPerse
        [pbeta1, palpha1, palpha2, pphi],... % Semifull
        [pbeta1, palpha1, palpha2, pphi, ptau],... % Full
        [pbeta1, palpha1, psig_xi, psig_eps],... % Kalman
    };
    p = pp{model};
    
end

function v = rescale1(x, xmin, xmax, vmin, vmax)
    v = (vmax - vmin) * (x - xmin)/(xmax - xmin) + vmin;
end

