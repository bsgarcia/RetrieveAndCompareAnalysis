function [a, cont1, cont2, p1, p2, ev1, ev2] = sim_exp_EE(exp_name, exp_num, d, idx, sess, model)

    [cho, cfcho, out, cfout, corr, con, p1, p2, rew, rtime, ev1, ev2] = ...
        DataExtraction.extract_learning_data(...
            d.(exp_name).data, d.(exp_name).sub_ids, idx, sess);
   
    ntrials = size(cho, 2);   
     if model == 4
       [corr, cho, out, p1, p2, ev1, ev2, ctch, cont1, cont2, dist, rtime] = ...
                DataExtraction.extract_estimated_probability_post_test(...
                d.(exp_name).data, d.(exp_name).sub_ids, idx, sess);

        for sub = 1:size(cho, 1)
            i = 1;      

            for p = unique(p1)'
                Q(sub, i) = cho(sub, (p1(sub, :) == p))./100;
                i = i + 1;          
            end
        end
    elseif model == 5
        
        for sub = 1:size(cho, 1)
            i = 1;      
            icon = [1, 2, 3, 4, 4, 3, 2, 1];
            for p = [unique(p2)',  unique(p1)']
                if i < 5
                    Q(sub, i) = mean(cho(sub, con(sub, :)==icon(i))==2);
                else
                    Q(sub, i) = mean(cho(sub, con(sub, :)==icon(i))==1);
                end
                i = i + 1;          
            end
        end
    else
        
        [Q, params] = get_qvalues(...
            exp_name, sess, cho, cfcho, con, out, cfout, ntrials, (exp_num>2), model);
        Q = sort_Q(Q);
    end
    
    [corr, cho, out, p1, p2, ev1, ev2, ctch, cont1, cont2, dist] = ...
        DataExtraction.extract_sym_vs_sym_post_test(...
            d.(exp_name).data, d.(exp_name).sub_ids, idx, sess);
    
    nsub = d.(exp_name).nsub;

    ntrials = length(cho(1, :));
    
 
    i = 1;
%     for agent = 1:nagent
        for sub = 1:nsub    
        
            flatQ = 1.*Q(sub, :) + -1.*(1-Q(sub,:));
            p_range = 1:length(unique(p1));
            
            for t = 1:ntrials
                
                what_sym1 = p_range(p1(sub, t)==unique(p1));
                what_sym2 = p_range(p2(sub, t)==unique(p1));
                
                v = [flatQ(what_sym1), flatQ(what_sym2)];
                
                
                [throw, a(sub, t)] = max(v);

%                 
%                 pp = softmaxfn(v, b);
% 
%                 a(i, t) = randsample(...
%                     [1, 2],... % randomly drawn action 1 or 2
%                     1,... % number of element picked
%                     true,...% replacement
%                     pp... % probabilities
%                 );
    %             

            end
%             i = i + 1;

        end
%     end
    
%     cont1 = repmat(cont1, 20, 1);
%     cont2 = repmat(cont2, nagent, 1);
%     p1 = repmat(p1, nagent, 1);
%     p2 = repmat(p2, nagent, 1);
%     ev1 = repmat(ev1, nagent, 1);
%     ev2 = repmat(ev2, nagent, 1);
end


   
function p = softmaxfn(Q, b)
    p = exp(Q.*b)./ sum(exp(Q.*b));
end


