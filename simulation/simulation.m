% function running classic RL simulations
function Q = simulation(sim_params)

    Q = zeros(sim_params.nsub , sim_params.ncond, sim_params.noptions)+.5; 
    
    for sub = 1:sim_params.nsub    
        
        switch sim_params.model
            case 1
                alpha1 = sim_params.params{2}(sub);
            case 2
                alpha1 = sim_params.params{2}(sub);
                alpha2 = sim_params.params{3}(sub);
        end
        
        s = sim_params.con(sub, :);
        cfr = sim_params.cfout(sub, :);
        r = sim_params.out(sub, :);
        a = sim_params.cho(sub, :);
        cfa = sim_params.cfcho(sub, :);
        
        for t = 1:sim_params.ntrials
            
            deltaI = (r(t)==1) - Q(sub, s(t), a(t));
            
            if cfa(t) ~= -2
                cfdeltaI = (cfr(t)==1) - Q(sub, s(t), cfa(t));
            end
            switch sim_params.model
                case 1
                    Q(sub, s(t), a(t)) = Q(sub, s(t), a(t)) + alpha1 * deltaI;
                    if cfa(t) ~= -2
                        Q(sub, s(t), cfa(t)) = Q(sub, s(t), cfa(t)) + alpha1 * cfdeltaI;
                    end
                case 2
                    Q(sub, s(t), a(t)) = ...
                        Q(sub, s(t), a(t)) + alpha1 * (deltaI>0) + alpha2 * (deltaI<0);
                    if cfa(t) ~= -2
                        Q(sub, s(t), cfa(t)) = ...
                            Q(sub, s(t), cfa(t)) + alpha1 * (cfdeltaI<0) + alpha2 * (cfdeltaI>0);
                    end
            end
        end
        
    end
end


   
function p = softmaxfn(Q, b)
    p = exp(Q.*b)./ sum(exp(Q.*b));
end

