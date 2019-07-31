function lik = getll(params, s, a, r, model)

    beta1 = params(1); % choice temperature
    alpha1 = 0; % first learning rate
    alpha2 = 0; % second learning rate
    pri = 0; % priors applied on Q values t == 1
    phi = 0; % perseveration
    tau = 0;

    % 1: basic df=2
    % 2: asymmetric neutral df=3
    % 3: asymmetric pessimistic df=3
    % 4: priors df=3
    % 5: perseveration df=3
    % 6: perseveration tau df=4
    % 7: full df=5
    % 8: 
    
    % get parameters depending on the model
    switch model
        case 1
            alpha1 = params(2);
        case 2
            alpha1 = params(2);
            alpha2 = params(3);
        case 3
            alpha1 = params(2);
            alpha2 = params(3);
            pri = -2;
        case 4
            alpha1 = params(2);
            pri = params(4);
        case 5
            alpha1 = params(2);
            phi = params(5);
            tau = 1;
        case 6
            alpha1 = params(2);
            phi = params(5);
            tau = params(6);
        case 7
            alpha1 = params(2);
            alpha2 = params(3);
            %pri = params(4);
            phi = params(5);
            tau = 1;
        case 8 
            alpha1 = params(2);
            alpha2 = params(3);
            %pri = params(4);
            phi = params(5);
            tau = params(6);
        case 9
            % innovation variance
            sig_xi = params(7);
            % noise variance
            sig_eps = params(8);
    end

    % initial previous aice
    lik = 0;
    ncond = max(s);
    Q = zeros(ncond, 2) + pri; %  Q-values
    preva = zeros(ncond, 1); % prev action
    kg = zeros(ncond, 2); % kalman gain
    mu = zeros(ncond, 2); % mean reward of each option
    v = zeros(ncond, 2); % variance
    c = zeros(ncond, 2); % choicetrace
    
    for t = 1:length(a)
        
        if not(ismember(a(t), [1, 2, 1.5]))
            error('choice = %d', a(t));
        end
            
        if a(t) ~= 1.5 % if a choice was performed in time at the first level
            
            if ismember(model, 1:7); V = Q(:, :, :); else; V = mu(:, :, :); end 
            
             lik = lik + (beta1 * V(s(t), a(t))) + (phi * c(s(t), a(t)))...
                - log([...
                exp((beta1 * V(s(t), 1)) + (phi * c(s(t), 1)))...
                + exp((beta1 * V(s(t), 2)) + (phi * c(s(t), 2)))...
            ]);
                    
            % compute PE
            deltaI = r(t) - Q(s(t), a(t));

            switch model
                case {1, 4, 5, 6} % regular learning rule                
                    Q(s(t), a(t)) = Q(s(t), a(t)) + alpha1 * deltaI;
                case {2, 3, 7, 8} % asymmetric learning rule
                    % compute PE
                    Q(s(t), a(t)) = Q(s(t), a(t)) + alpha1 * deltaI * ...
                        (deltaI > 0) + alpha2 * deltaI * (deltaI < 0);
                case 9 % Kalman filter
                    kg(s(t), a(t)) = (v(s(t), a(t)) + sig_xi)./...
                        (v(s(t), a(t)) + sig_xi + sig_eps);  
                    mu(s(t), a(t)) = mu(s(t), a(t)) + kg(s(t), a(t)) *...
                        (r(t) - mu(s(t), a(t)));
                    v(s(t), a(t)) = (1-kg(s(t), a(t))) * (v(s(t), a(t)) + sig_xi);
                otherwise
                    error('Model does not exists');
            end
        end
        c = updatechoicetrace(s, a, c, t, tau);

        
        preva(s(t)) = a(t);  % save the choice
                             % for the next round (perseverations)
    end
       
    lik = -lik; % LL vector taking into account both the likelihood
end

function c = updatechoicetrace(s, a, c, t, tau)
    c(s(t), 1) =  (1 - tau) * c(s(t), 1) + tau * (a(t) == 1); 
    c(s(t), 2) =  (1 - tau) * c(s(t), 2) + tau * (a(t) == 2); 
end


