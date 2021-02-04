function lik = getll(params, s1, s2, a, cfa, r, cfr, phase, model, ntrials)

    % get parameters depending on the model
    switch model
        case 1
            beta1 = params(1);
            alpha1 = params(2);

        case 2
            beta1 = params(1);
            alpha1 = params(2);
            lambda_desc = params(3);
            lambda_exp = params(4);

      
        otherwise
            error('Model does not exists');

    end

    % initial previous aice
    lik = 0;
    ncond = 4;
    Q = zeros(ncond, 2); %  Q-values
    tt1 = 0;
    tt2 = 0;

    for t = 1:ntrials

        switch phase(t)
            case 1
                
                lik = lik + (beta1 * Q(s1(t), a(t))) - log(sum(exp(Q(s1(t), :).*beta1)));
                
                deltaI = r(t) - Q(s1(t), a(t));
                cfdeltaI = cfr(t) - Q(s1(t), cfa(t)); 

                switch model
                    case {1, 2, 3} % regular learning rule
                        Q(s1(t), a(t)) = Q(s1(t), a(t)) + alpha1 * deltaI;
                        if cfr(1) ~= -2
                            Q(s1(t), cfa(t)) = Q(s1(t), cfa(t)) + alpha1 * cfdeltaI;
                        end
%                         if fit_counterfactual
%                             Q(s(t), cfa(t)) = Q(s(t), cfa(t)) + alpha3 * cfdeltaI;
%                         end

                    otherwise
                        error('Model does not exists');
                end

            case 2
                if tt1 == 0
                    flat1 = reshape(Q', [], 1);
                end
                
                switch model
                    case 1
                        % find qvalue using contingency number 
                        Q1 = flat1(s1(t));
                        Q2 = s2(t);
                        v = [Q1 Q2];

                    case 2
                        if tt1 == 0
                            flat4 = flat1 .* (1-lambda_desc);
                        end
                        tt1 = tt1 + 1;                       

                        Q1 = flat4(s1(t));
                        Q2 = s2(t);
                        v = [Q1 Q2];
                end
                lik = lik + (beta1 * v(a(t))) -  log(...
                            exp(beta1 * Q1)...
                            + exp(beta1 * Q2));

            case 3
                if tt2 == 0
                    flat2 = reshape(Q', [], 1);
                end

                switch model
                    case 1
                        % find qvalue using contingency number 
                        Q1 = flat2(s1(t));
                        Q2 = flat2(s2(t));
                        v = [Q1 Q2];

                    case 2
                        
                        if tt2 == 0
                            flat3 = flat2 .* (1-lambda_exp);
                        end
                        tt2 = tt2 + 1;

                        Q1 = flat3(s1(t));
                        Q2 = flat3(s2(t));
                        
                        v = [Q1 Q2];

                end
                lik = lik + (beta1 * v(a(t))) -  log(...
                            exp(beta1 * Q1)...
                            + exp(beta1 * Q2));

        end

    end

lik = -lik; % LL vector taking into account both the likelihood
end
