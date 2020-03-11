function [Q, params] = get_qvalues(exp_name, sess, sim_params, model)

    
    data = load(sprintf('data/fit/%s_learning_manual_%d', exp_name, sess));
    parameters = data.data('parameters');
    
    switch model
        case {1, 3}
            alpha1 = parameters{model}(:, 2);
            beta1 = parameters{model}(:, 1);
            params = {beta1, alpha1};
        case 2
            beta1 = parameters{model}(:, 1);
            alpha1 = parameters{model}(:, 2);
            alpha2 = parameters{model}(:, 3);
            params = {beta1, alpha1, alpha2};
    end
    
 
    % ----------------------------------------------------------%
    % Parameters                                                %
    % ----------------------------------------------------------%

    sim_params.show_window = true;
    %sim_params.beta1 = beta1;
    sim_params.params = params;
    sim_params.model = model;
    
    Q = simulation(sim_params);
    % ---------------------------------------------------------%
end


function Q = simulation(sim_params)

    Q = ones(sim_params.nsub , sim_params.ncond, sim_params.noptions)...
        .*sim_params.q;    
    
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
                deltaI = r(t) - cfr(t) - Q(sub, s(t), a(t));          
            else
                deltaI = r(t) - Q(sub, s(t), a(t));
            end
          
            if fit_cf && (sim_params.model ~= 3)
                cfdeltaI = cfr(t) - Q(sub, s(t), cfa(t));
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

