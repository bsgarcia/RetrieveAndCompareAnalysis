classdef QLearning < handle
    %QLEARNING Agent
    properties (SetAccess = public)
        Q
        alpha
        beta
        ntrial
        psoftmax
        ll
        l
        name
        a
        r
        which_decision_rule
    end
    
    methods
        function obj = QLearning(params, q, nstate, naction, ntrial, ...
                which_decision_rule, name)
            % constructor
            if exist('name', 'var')
                obj.name = name;
            else
                obj.name = 'QLearning';
            end
            obj.Q = ones(nstate, naction) .* q;
            obj.alpha = params(2);
            obj.beta = params(1);
            obj.ntrial = ntrial;
            obj.psoftmax = zeros(nstate, naction, ntrial);
            obj.a = zeros(1, ntrial);
            obj.r = zeros(1, ntrial);
            obj.ll = 0;
            obj.l = 0;
            obj.which_decision_rule = which_decision_rule;
            
        end
        
        
        function nll = fit(obj, s, a, cfa, r, cfr, fit_cf)
            for t = 1:obj.ntrial
                
                obj.ll = obj.ll + obj.fit_decision_rule(...
                    s(t), a(t)...
                );
                
                pe = r(t) - obj.Q(s(t), a(t));
                
                obj.Q(s(t), a(t)) = ...
                    obj.Q(s(t), a(t)) + obj.alpha * pe;
                
                if fit_cf
                    pe = cfr(t) - obj.Q(s(t), cfa(t));
                    
                    obj.Q(s(t), cfa(t)) = ...
                        obj.Q(s(t), cfa(t)) + obj.alpha * pe;
                end
                
                
            end
            nll = -obj.ll;
        end
        
        function p = fit_decision_rule(obj, s, a)
            switch (obj.which_decision_rule)
                case 1
                    ev = obj.Q(s, :).*1 + -1.*(1-obj.Q(s,:));
                    % logLL softmax
                    p = (obj.beta * ev(a)) ...
                    - log(sum(exp(obj.beta .* ev)));
                case 2
                    ev = obj.Q(s, :).*1 + -1.*(1-obj.Q(s,:));
                    % LL softmax
                    p = exp(obj.beta * ev(a)) ...
                    ./sum(exp(obj.beta .* ev));
                case 3
                    % LL argmax
                    if obj.Q(s, 1) ~= obj.Q(s, 2)
                        [throw, am] = max(obj.Q(s, :));
                        p = (am == a);
                    else
                        p = 0.5;
                    end
                otherwise
                    error('not recognized decision rule');
            end
        end               
        
        function p = decision_rule(obj, s)
            switch (obj.which_decision_rule)
                case {1, 2}
                    ev = obj.Q(s, :).*1 + -1.*(1-obj.Q(s, :));
                    % LL softmax
                    p = exp(obj.beta * ev) ...
                    ./sum(exp(obj.beta .* ev));
                case 3
                    % LL argmax
                    if obj.Q(s, 1) ~= obj.Q(s, 2)
                        [throw, am] = max(obj.Q(s, :));
                        p = (am == [1, 2]);
                    else
                        p = [0.5, 0.5];
                    end
                otherwise
                    error('not recognized decision rule');
            end
        end   
        function choice = make_choice(obj, s, t)
            p = obj.decision_rule(s);
            obj.a(t) = randsample(...
                1:length(p),... % randomly drawn action
                1,... % number of element picked
                true,...% replacement
                p... % probabilities
                );
            
            choice = obj.a(t);
        end
        
        function learn(obj, s, a, r, cfr, fit_cf)
            pe = r - obj.Q(s, a);
            
            obj.Q(s, a) = obj.Q(s, a) + obj.alpha * pe;
            
            if fit_cf
                pe = cfr - obj.Q(s, 3-a);
                
                obj.Q(s, 3-a) = obj.Q(s, 3-a) + obj.alpha * pe;
            end
            
            
        end
        
        
    end
end
