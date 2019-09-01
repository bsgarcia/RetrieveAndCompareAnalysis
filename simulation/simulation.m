% function running simulations
function data = simulation(fit_params, sim_params)

    nsub = length(fit_params(:, 1, 1));
    nmodel = length(sim_params.models);
    models = sim_params.models;
    
    % Get simulation parameters
    % ---------------------------------
    % total agent = nagent * nsub
    nagent = sim_params.nagent;
    tmax = sim_params.tmax;
    conds = sim_params.conds;
    ncond = sim_params.ncond;
    phase = sim_params.phase;
    sym = sim_params.sym;
    ev = sim_params.ev;
    p1 = sim_params.p1;
    p2 = sim_params.p2;
    
    % rewards for each timestep
    r = sim_params.r;
    % probability for each timestep
    p = sim_params.p;

    % we save 6 variables: choice, outcome, cond, psoftmax, correct choice;
    % qvalue, deltaq
    % in a matrix for each subject
    % data{sub}(tmax, var, nmodel)
    data = repelem({zeros(tmax, 7, nmodel)}, nsub*nagent);
    
    i = 0;
    if sim_params.show_window
        w = waitbar(0, '');
    end

    for sub = 1:nsub

        for agent = 1:nagent

            i = i + 1;
            if ~(mod(i, 10)) && sim_params.show_window
                waitbar(i/(nagent*nsub),...  % Compute progression
                    w,...
                    sprintf(...
                    '%s %s \n %s%d',...
                    'Cond',...
                    sim_params.name,...
                    'Running agent ',...
                    i)...
                );
            end

            for model = models
                
                params = fit_params(sub, :, model);
                Q = initqvalues(ncond, params, model);
                a = zeros(tmax, 1, 1);
                out = zeros(tmax, 1, 1);
                s = conds;
                softmaxp = zeros(tmax, 2);
                correct = zeros(tmax, 1, 1);
                qvalues = zeros(tmax, 2);
                deltaq = zeros(tmax, 1, 1);
                
                % choice trace
                c = zeros(tmax, 2);
                % BAYESIAN
                % kalman gain
                kg = zeros(ncond, 2);
                % mean 
                mu = zeros(ncond, 2);
                % variance
                v = zeros(ncond, 2);
                sig_xi = params(7);
                sig_eps = params(8);
                     
                for t = 1:tmax
                    
                    if phase(t) == 1
                        qvalues(t, :) = Q(s(t), :);
                        deltaq(t) = abs(qvalues(t, 1)-qvalues(t, 2));
                        % save probabilities
                        if ismember(model, 1:7); V = Q; else; V = mu;end
                        
                        softmaxp(t, :) = getprob(V, s, c, t, model, params);
                        
                        a(t) = randsample(...
                            [1, 2],... % randomly drawn action 1 or 2
                            1,... % number of element picked
                            true,...% replacement
                            softmaxp(t, :)... % probabilities
                            );
                        
                        out(t) = randsample(...
                            r{t}{a(t)},...
                            1,...
                            true,...
                            p{t}{a(t)}...
                            );
                        
                        Q = learn(Q, s, a, t, out, model, params);
                        % Expected utility of chosen option
                        c1 = [r{t}{a(t)}] .* [p{t}{a(t)}];
                        % Expected utility of unchosen option
                        c2 = [r{t}{1 + (a(t) == 1)}] .* [p{t}{1 + (a(t) == 1)}];
                        
                        correct(t) = sum(c1) > sum(c2);
                        
                        % update values
                        % update choice trace
                        if ismember(model, [5, 6, 7, 8])
                            % if model has only phi (5, 7)
                            % then tau = 1
                            taus = [params(6) 1];
                            c = updatechoicetrace(s, a, c, t, taus(1 + ((model==5) + (model==7))));
                        end

                    else 
                        flat1 = reshape(Q', [], 1);
                        V1 = flat1(sym(t-120));
                        V2 = ev(t-120);
                        softmaxp(t, :) = softmaxfn([V1, V2] .* params(1));
                        
                        a(t) = randsample(...
                            [1, 2],... % randomly drawn action 1 or 2
                            1,... % number of element picked
                            true,...% replacement
                            softmaxp(t, :)... % probabilities
                        );
                    
                        % Expected utility of symbol option
                        c1 = sum([r{t}] .* [p{t}]);
                        % Expected utility of lottery option
                        c2 = V2;
                        C = [c1, c2];
                        correct(t) =  C(a(t)) >= C(1 + (a(t) == 1));
                        
                    end

                    
                end
                
                data{i}(:, 1, model) = a;
                data{i}(:, 2, model) = out;
                data{i}(:, 3, model) = s;
                data{i}(:, 4, model) = softmaxp(:, 2);
                data{i}(:, 5, model) = correct;
                data{i}(1:8, 6, model) = reshape(Q', [], 1);
                data{i}(:, 7, model) = deltaq;
                data{i}(end-numel(p1)+1:end, 8, model) = p1;
                data{i}(end-numel(p1)+1:end, 9, model) = p2;
                data{i}(end-numel(p1)+1:end, 10, model) = ev;
                data{i}(:, 11, model) = phase;
                
                % flush data
                clear a;
                clear out;
                clear s;
                clear softmaxp;
                clear correct;
                clear qvalues;
                clear deltaq;
                clear c;

            end
        end
    end
    
    if sim_params.show_window
        close(w);
    end
end


function Q = initqvalues(ncond, params, model)
    
    Q = zeros(ncond, 2);
    
    switch model
        case 3
            % stable negative priors
            Q = Q - 1;
  
        case 4
            % apply priors
            Q = Q + params(4);
        otherwise
            % do nothing
            
    end
end
    

function Q = learn(Q, s, a, t, out, model, params)

    % 1: basic df=2
    % 2: asymmetric neutral df=3
    % 3: asymmetric pessimistic df=3
    % 4: perseveration df=3
    % 5: priors df=3
    % 6: full df=5

    switch model
        case {1, 4, 5, 6} % rescorla wagner
            alpha1 = params(2);
            deltaI = out(t) - Q(s(t), a(t));
            Q(s(t), a(t)) = Q(s(t), a(t)) + alpha1 * deltaI;
        case {2, 3, 7, 8} % asymmetric 
            alpha1 = params(2);
            alpha2 = params(3); 
            deltaI = out(t) - Q(s(t), a(t));
            Q(s(t), a(t)) = Q(s(t), a(t)) + alpha1 * deltaI * (deltaI > 0) ...
                + alpha2 * deltaI * (deltaI < 0);
        case 8 % Kalman filter
%             kg = Q(1);
%             mu = Q(2);
%             v = Q(3);
%             kg(s(t), a(t)) = (v(s(t), a(t)) + sig_xi)./...
%                                         (v(s(t), a(t)) + sig_xi + sig_eps);  
%             mu(s(t), a(t)) = mu(s(t), a(t)) + kg(s(t), a(t)) *...
%                             (out(t) - mu(s(t), a(t)));
%             v(s(t), a(t)) = (1-kg(s(t), a(t))) * (v(s(t), a(t)) + sig_xi);
%             Q = [kg, mu, v];
        otherwise
            error('Model does not exists');
    end
end


function c = updatechoicetrace(s, a, c, t, tau)
    c(s(t), 1) =  (1 - tau) * c(s(t), 1) + tau * (a(t) == 1); 
    c(s(t), 2) =  (1 - tau) * c(s(t), 2) + tau * (a(t) == 2); 
end


function p = getprob(Q, s, c, t, model, params)

    beta1 = params(1);
    switch model

        case {1, 2, 3, 4}
            p = softmaxfn(Q(s(t), :)*beta1);

        case {5, 6, 7, 8}
            % if new context use standard softmax
            if (t == 1) || (s(t) ~= s(t-1))
                p = softmaxfn(Q(s(t), :)*beta1);
            % else take into account the last choice
            else
                phi = params(5);
              
                % if impulsive perseveration tau = 1;
                p = softmaxfn(beta1*Q(s(t), :) + phi*c(s(t), :));
            end
            
        otherwise
            error('Model does not exist');
    end
end


function p = softmaxfn(Q)
    % softmax function is built-in
    % so we call this func softmaxfn to avoid shadownaming
    p = exp(Q) ./ sum(exp(Q));
end

