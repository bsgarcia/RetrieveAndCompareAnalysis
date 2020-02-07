function [a, cont1, cont2, p1, p2, ev1, ev2] = sim_exp_ED(exp_name, d, idx, sess, def, nagent, varargin)
    
    %[a, out, con, p1, p2, ev1, ev2, Q] = sim_exp_learning(exp_name, d, idx, sess);
    
    [cho, cfcho, out, cfout, corr, con, p1, p2, rew, rtime, ev1, ev2] = ...
        DataExtraction.extract_learning_data(...
            d.(exp_name).data, d.(exp_name).sub_ids, idx, sess);
        
    data = load(sprintf('data/fit/%s_learning_%d', exp_name, sess));
    parameters = data.data('parameters');
    
    alpha1 = parameters(1, :, 2);
    ntrials = size(cho, 2);
    beta1 = parameters(1, :, 1);
    
    if def
        data = load(sprintf('data/fit/%s_PT_%d', exp_name, sess));
        parameters = data.data('parameters');
        lambda_desc = parameters(2, :, 1);
        
    else
        lambda_desc = 0;
    end
    
    if numel(varargin)
        Q = cell2mat(varargin); 
    else
        Q = get_qvalues(alpha1, cfcho, cho, con, out, cfout, ntrials);
    end
    
    clear cho cfcho out cfout corr con p1 p2 rew rtime ev1 ev2
    
    [corr, cho, out, p1, p2, ev1, ev2, ctch, cont1, cont2, dist] = ...
        DataExtraction.extract_sym_vs_lot_post_test(...
            d.(exp_name).data, d.(exp_name).sub_ids, idx, sess);
            
    %parameters = load(sprintf('data/fit/%s', exp_name));
    %beta1 = parameters(1, :, 1);
    %beta1 = 1;
    nsub = d.(exp_name).nsub;
    ntrials = length(cho(1, :));
     
     % map con to contingencies number
    map = [2 4 6 8 -1 7 5 3 1];
    i = 1;
    for nagent = 1:nagent
        
        for sub = 1:nsub
            
            b = beta1(sub);
                      
            Qsub(1:4, 1:2) = Q(sub, :, :);
                
            
            flatQ = reshape(Qsub', [], 1);
            flatQ = 1.*flatQ + -1.*(1-flatQ);
            flatQ = flatQ .* (1-lambda_desc);
            s1 = cont1(sub, :);
            s2 = ev2(sub, :);
            
            
            for t = 1:ntrials
                
                v = [flatQ(map(s1(t))), s2(t)];
           
                pp = softmaxfn(v, b);
                
                a(i, t) = randsample(...
                    [1, 2],... % randomly drawn action 1 or 2
                    1,... % number of element picked
                    true,...% replacement
                    pp... % probabilities
                    );
                %
                
            end
            
            i = i + 1;
        end
        
    end
    
        cont1 = repmat(cont1, 20, 1);
        cont2 = repmat(cont2, nagent, 1);
        p1 = repmat(p1, nagent, 1);
        p2 = repmat(p2, nagent, 1);
        ev1 = repmat(ev1, nagent, 1);
        ev2 = repmat(ev2, nagent, 1);

end


   
function p = softmaxfn(Q, b)
    p = exp(Q.*b)./ sum(exp(Q.*b));
end


