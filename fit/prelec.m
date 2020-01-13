function lik = prelec(params, a, p1, p2, model, ntrials)
    
    % -----------------------------------------------------------%
    lik = 0;
    delta_exp1 = params(1);
    gamma_exp1 = params(2);
    delta_desc1 = params(3);
    gamma_desc1 = params(4);
    delta_exp2 = 0;
    gamma_exp2 = 0;
    delta_desc2 = 0;
    gamma_desc2 = 0;
    loss_aversion_exp = 0;
    loss_aversion_desc = 0;
    
    % -----------------------------------------------------------%
    switch model
        case 1
           % do nothing
        case 2
           delta_exp2 = params(5);
           gamma_exp2 = params(6);
           delta_desc2 = params(7);
           gamma_desc2 = params(8);
        case 3
            loss_aversion_exp = params(9);
            loss_aversion_desc = params(10);
        otherwise
            error('model not found');
    end
    % -----------------------------------------------------------%
    
    for t = 1:ntrials
        
        pp = [p1(t), p2(t)];
        
        % -----------------------------------------------------------% 
        
        switch model
            
            
            case 1
                
                param = [...
                    [delta_exp1, delta_desc1];...
                    [gamma_exp1, gamma_desc1];...
                ];
                
                % prelec PWF
                p_def = exp(...
                    -param(1, :) .* (-log(pp)).^param(2, :)...
                );
                
                % Compute EV
                ev = p_def -(1 - p_def);
            
       % -----------------------------------------------------------% 

            case 2
                
                param = [...
                    [delta_exp1, delta_desc1] .* (pp >= 0.5);...
                    [gamma_exp1, gamma_desc1] .* (pp >= 0.5);...
                    [delta_exp2, delta_desc2] .* (pp < 0.5);...
                    [gamma_exp2, gamma_desc2] .* (pp < 0.5);...
                ];
            
                param(param == 0) = [];
                param = reshape(param, [2, 2]);
                
                % prelec PWF
                p_def = exp(...
                    -param(1, :) .* (-log(pp)).^param(2, :)...
                );
                
                % Compute EV
                ev = p_def -(1 - p_def);
            
        % -----------------------------------------------------------%
            
            case 3
                
                param = [...
                    [delta_exp1, delta_desc1];...
                    [gamma_exp1, gamma_desc1];...
                    [loss_aversion_exp, loss_aversion_desc]
                ];
                
                % prelec PWF
                p_def = exp(...
                    -param(1, :) .* (-log(pp)).^param(2, :)...
                );
                
                % Compute EV and apply loss aversion parameter
                  %cond = ((param(3, :)) .* (pp < .5));
%                 %disp(cond);
                  %cond(cond == 0) = cond(cond == 0) + 1;
%                 if any(cond == 0) 
%                     error('error');
%                 end
                ev = (p_def -(1 - p_def));%(param(3, :)) .* (pp < .5) ;
                
                cond(1) = param(3, 1) * (ev(1) < 0);
                cond(2) = param(3, 2) * (ev(2) < 0);
                
                cond(cond==0) = cond(cond==0)+1;

                ev = [ev(1) .* cond(1),...
                    ev(2) .* cond(2)];
        end
        
        % -----------------------------------------------------------%

        lik = lik + ev(a(t)) - log(sum(exp(ev)));
        
    end
   
    lik = -lik;
    
end
