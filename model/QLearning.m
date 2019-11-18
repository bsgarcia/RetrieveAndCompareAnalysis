classdef QLearning
    %QLEARNING Agent
    properties
        Q
        alpha
        beta
        ntrial
        psoftmax
        ll
        name
        a
        r
    end
    
    methods
        function obj = QLearning(params, q, nstate, naction, ntrial, name)
            % constructor
            if exist('name', 'var') 
                obj.name = name;
            else
                obj.name = 'QLearning';
            end
            obj.Q = ones(nstate, naction, ntrial) .* q;
            obj.alpha = params(1);
            obj.beta = params(2);
            obj.ntrial = ntrial;
            obj.psoftmax = zeros(nstate, naction, ntrial);
            obj.a = zeros(1, ntrial);
            obj.r = zeros(1, ntrial);
            obj.ll = 0;
        end
        
        function nll = fit(obj, s, a, r)
            for t = 1:obj.ntrial
                
                pe = r(t) - obj.Q(s(t), a(t), t);
                
                obj.Q(s(t), a(t), t+1:obj.ntrial) = ...
                    obj.Q(s(t), a(t), t) + obj.alpha * pe;
                
                obj.ll = obj.ll + (obj.beta * obj.Q(s(t), a(t), t)) ...
                - log(sum(exp(obj.beta .* obj.Q(s(t), :, t))));
            end
            nll = -obj.ll;
        end
        
        function choice = make_choice(obj, s, t)
            p = obj.get_p(t, s);
            obj.a(t) = randsample(...
                            1:length(p),... % randomly drawn action
                            1,... % number of element picked
                            true,...% replacement
                            p... % probabilities
                       );

            choice = obj.a(t);
        end
       
        function learn(obj, s, a, r, t)          
            pe = r- obj.Q(s, a, t);
            
            obj.Q(s, a, t+1:obj.ntrial) = ...
                obj.Q(s, a, t) + obj.alpha * pe;                 
        end
        
        function psoftmax = get_p(obj, s, t)
            obj.psoftmax(s, :, t) = ...
                exp(obj.beta .* obj.Q(s, :, t)) ./ ...
                sum(exp(obj.beta .* obj.Q(s, :, t)));
            
            psoftmax = obj.psoftmax(s, :, t);
        end
        
    end
end

