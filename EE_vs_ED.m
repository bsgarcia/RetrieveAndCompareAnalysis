% -------------------------------------------------------------------%
% This script finds the best fitting Values for each exp             %
% then plots the figs                                                %
% -------------------------------------------------------------------%
init;
% -------------------------------------------------------------------%

selected_exp = [1, 2, 3, 4, 8];

sessions = [0, 1];

starting = 1;

for exp_num = selected_exp 
    % -------------------------------------------------------------------%
    % LEARNING
    % -------------------------------------------------------------------%
    idx1 = (exp_num - round(exp_num)) * 10;
    idx1 = idx1 + (idx1==0);
    sess = sessions(uint64(idx1));
    
    % load data
    exp_name = char(filenames{round(exp_num)});
    
    if exist('ending')
        ending = ending + d.(exp_name).nsub;
    else
        ending = d.(exp_name).nsub;
    end
    
     [corrx, cho(starting:ending, :), out2, p1(starting:ending, :), p2(starting:ending, :), ev1, ev2, ctch, cont1, cont2, dist] = ...
        DataExtraction.extract_sym_vs_lot_post_test(...
        d.(exp_name).data, d.(exp_name).sub_ids, idx, sess);
    
       [corrx, choxx, out, p12, p21, ev1, ev2, ctch, cont1, cont2, dist, rtime] = ...
                DataExtraction.extract_estimated_probability_post_test(d.(exp_name).data, d.(exp_name).sub_ids, idx, sess);
    arr = starting:ending ;    
    for sub = 1:size(choxx, 1)
            i = 1;      

        for p = unique(p12)'
            cho_PM(arr(sub), i) = choxx(sub, (p12(sub, :) == p))./100;
            i = i + 1;          
        end
    end
%     
    [cho12, cfcho, out, cfout, corr(starting:ending, :), con, p1222, p222222, rew, rtime, ev1, ev2] = ...
        DataExtraction.extract_learning_data(...
            d.(exp_name).data, d.(exp_name).sub_ids, idx, sess);
    
    [a, cont1, cont2, p11, p22, ev1, ev2, ll(1, 1, starting:ending)] = ...
        sim_exp_ED(exp_name, exp_num, d, idx, sess, 1);
    
    [a, cont1, cont2, p12, p22, ev1, ev2, ll(1, 2, starting:ending)] = ...
        sim_exp_ED(exp_name, exp_num, d, idx, sess,  6);
    
%     [a, cont1, cont2, p1, p2, ev1, ev2, ll(2, 1, starting:ending)] = ...
%         sim_exp_EE(exp_name, exp_num, d, idx, sess, 1);
%     
%     [a, cont1, cont2, p1, p2, ev1, ev2, ll(2, 2, starting:ending)] = ...
%         sim_exp_EE(exp_name, exp_num, d, idx, sess,  6);
    
    nsub = d.(exp_name).nsub;
    
    starting = starting + nsub;
    % -------------------------------------------------------------------%
end
