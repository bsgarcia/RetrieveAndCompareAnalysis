function [a, cont1, cont2, p1, p2, ev1, ev2] = sim_exp_EE(...
    exp_name, exp_num, d, idx, sess, model, decision_rule, nagent)
    
    sim_params.exp_name = exp_name;
    sim_params.model = model;
    sim_params.idx = idx;
    sim_params.exp_num = exp_num;
    sim_params.sess = sess;
    sim_params.d = d;
    [Q, params] = get_qvalues(sim_params);
           
    [corr, cho, out2, p1, p2, ev1, ev2, ctch, cont1, cont2, dist] = ...
        DataExtraction.extract_sym_vs_sym_post_test(...
        d.(exp_name).data, d.(exp_name).sub_ids, idx, sess);
    
    nsub = d.(exp_name).nsub;
    ntrials = size(cho, 2);
           
    for sub = 1:nsub
        count = 0;

        for v = ev1(sub, :)
            
            count = count + 1;
            qv1(sub, count) = Q(sub, ...
                find(v == unique(ev1(sub,:))));
        end
    end
    
    i = 1;  

    for agent = 1:nagent
        for sub = 1:nsub
            
            qlearner = models.QLearning([params.beta1(sub), NaN], ...
                0.5, 8, 2, ntrials, decision_rule);
            
            v1 = 1.*qv1(sub, :) + -1.*(1-qv1(sub, :));
            v2 = ev2(sub, :);

            for t = 1:ntrials
                
                a(i, t) = qlearner.make_choice_between_two_values(...
                    v1(t), v2(t));

            end
            i = i + 1;
        end
    end
    
    cont1 = repmat(cont1, nagent, 1);
    cont2 = repmat(cont1, nagent, 1);
    p1 = repmat(p1, nagent, 1);
    p2 = repmat(p2, nagent, 1);
    ev1 = repmat(ev1, nagent, 1);
    ev2 = repmat(ev2, nagent, 1);   
    
end

