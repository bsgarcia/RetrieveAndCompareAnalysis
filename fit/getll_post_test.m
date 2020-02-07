function lik = getll_post_test(params, beta1, Q, s1, s2, a, phase, model, ntrials)

    % get parameters depending on the model
    switch model
        case 1
 

        case 2
            lambda_desc = params(1);
            lambda_exp = params(2);
      
        otherwise
            error('Model does not exist');

    end

    % initial previous aice
    lik = 0;
    beta1 = 1;
    flatQ = reshape(Q', [], 1);
    flatQ = 1.*flatQ + -1.*(1-flatQ);
    for t = 1:ntrials

        switch phase(t)
            
            case 1
                              
                switch model
                    case 1
                        % find qvalue using contingency number 
                        Q1 = flatQ(s1(t));
                        Q2 = s2(t);
                        v = [Q1 Q2];

                    case 2
                        
                        flatQdef = flatQ .* (1-lambda_desc);
                        
                        Q1 = flatQdef(s1(t));
                        Q2 = s2(t);
                        v = [Q1 Q2];
                end
             

            case 2
                
                switch model
                    case 1
                        % find qvalue using contingency number 
                        Q1 = flatQ(s1(t));
                        Q2 = flatQ(s2(t));
                        v = [Q1 Q2];

                    case 2
                        
                        flatQdef = flatQ .* (1-lambda_exp);
                        
                        Q1 = flatQdef(s1(t));
                        Q2 = flatQ(s2(t));
                        
                        v = [Q1 Q2];

                end
                
        end
        
        lik = lik + (beta1*v(a(t))) -  log(...
                            exp(Q1*beta1)...
                            + exp(Q2*beta1));
    end

lik = -lik; % LL vector taking into account both the likelihood
end