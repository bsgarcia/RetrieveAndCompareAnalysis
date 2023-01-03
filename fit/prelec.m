function lik = prelec(params, a, p1, p2, model, ntrials)
    
    % -----------------------------------------------------------%
    lik = 0;
   
    
    % -----------------------------------------------------------%
    switch model
        case 1
           delta1 = params(1);
           gamma1 = params(2);
           beta1 = params(3);
        case 2
            delta_exp1 = params(1);
            gamma_exp1 = params(2);
            delta_desc1 = params(3);
            gamma_desc1 = params(4);
            beta1 = params(5);

       
        otherwise
            error('model not found');
    end
    % -----------------------------------------------------------%
    
    for t = 1:ntrials
        
        pp = [p1(t), p2(t)];
        
        % -----------------------------------------------------------% 
        
        switch model
            
            
            case 1
              
                param = [delta1, gamma1];
                
                % prelec PWF
                p_def = exp(...
                    -param(2) .* (-log(pp)).^param(1)...
                );
                
                % Compute EV
                ev = (1 .* p_def) + (-1.*(1 - p_def));
       % -----------------------------------------------------------% 

            case 2
                param = [...
                    [delta_exp1, delta_desc1];...
                    [gamma_exp1, gamma_desc1];...
                ];
                
                % prelec PWF
                p_def = exp(...
                    -param(2, :) .* (-log(pp)).^param(1, :)...
                );
                
                % Compute EV
                ev = (1 .* p_def) + (-1.*(1 - p_def));
                
            
        % -----------------------------------------------------------%
                            
               
        end
        
        % -----------------------------------------------------------%

        %lik = lik + ev(a(t)).*5 - log(sum(exp(ev.*5)));
        p = exp(ev(a(t)).*beta1)./sum(exp(ev.*beta1));
        lik = lik + log(p);
    end
   
    lik = -lik;
    
end
