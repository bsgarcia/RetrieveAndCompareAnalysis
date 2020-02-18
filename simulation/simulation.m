% function running classic RL simulations
function Q = simulation(sim_params)

    Q = zeros(sim_params.nsub , sim_params.ncond, sim_params.noptions)+.5; 

    for sub = 1:sim_params.nsub    
        
        switch sim_params.model
            case {1, 3}
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
        fit_cf = sim_params.fit_cf;
        
        for t = 1:sim_params.ntrials
            
            if sim_params.model == 3
                deltaI = (r(t)==1) - (cfr(t)==1) - Q(sub, s(t), a(t));          
            else
                deltaI = (r(t)==1) - Q(sub, s(t), a(t));
            end
          
            if fit_cf && (sim_params.model ~= 3)
                cfdeltaI = (cfr(t)==1) - Q(sub, s(t), cfa(t));
            end
            
            switch sim_params.model
                case {1, 3}
                    Q(sub, s(t), a(t)) = Q(sub, s(t), a(t)) + alpha1 * deltaI;
                    if fit_cf && (sim_params.model ~= 3)
                        Q(sub, s(t), cfa(t)) = Q(sub, s(t), cfa(t)) + alpha1 * cfdeltaI;
                    end
                case 2

                    Q(sub, s(t), a(t)) = Q(sub, s(t), a(t)) + ...
                         alpha1 * deltaI * (deltaI>0) + alpha2 * deltaI * (deltaI<0);
                    if fit_cf
                        Q(sub, s(t), cfa(t)) = Q(sub, s(t), cfa(t)) + ...
                            alpha1 * cfdeltaI * (cfdeltaI<0) + alpha2 * cfdeltaI * (cfdeltaI>0);
                    end
                    
            end
            
        end
        
    end
    
end


   
function p = softmaxfn(Q, b)
    p = exp(Q.*b)./ sum(exp(Q.*b));
end
