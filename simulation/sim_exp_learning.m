function [corr, con] = sim_exp_learning(...
    exp_name, exp_num, d, idx, sess, model)


    switch model
        case {1, 3}
            data = load(sprintf('data/fit/%s_learning_%d', exp_name, sess));
            parameters = data.data('parameters');

            alpha1 = parameters{model}(:, 2);
            beta1 = parameters{model}(:, 1);
            decision_rule = 1;

        case 2
            
            data = load(sprintf('data/fit/%s_learning_%d', exp_name, sess));
            parameters = data.data('parameters');

            alpha1 = parameters{2}(:, 2);
            alpha2 = parameters{2}(:, 3);
            beta1 = parameters{2}(:, 1);
            
            decision_rule = 1;

        case 4
            [corr, cho, out, p1, p2, ev1, ev2, ctch, cont1, cont2, dist, rtime] = ...
                DataExtraction.extract_estimated_probability_post_test(...
                d.(exp_name).data, d.(exp_name).sub_ids, idx, sess);

            p = fliplr(unique(p1)');
            for sub = 1:size(cho, 1)
                i = 1;
                for pp = p(1:2) 
                    Q(sub, i, 1) = cho(sub, (p1(sub, :) == pp))./100;
                    i = i + 1;
                end
                i = 1;
                for pp = fliplr(p(3:4)) 
                    Q(sub, i, 2) = cho(sub, (p1(sub, :) == pp))./100;
                    i = i + 1;
                end
            end
            
            beta1 = zeros(1, size(cho, 1));
            alpha1 = zeros(1, size(cho, 1));
            decision_rule = 3;
            
            clear corr cho out p1 p2 ev1 ev2 ctch cont1 cont2 dist rtime

    %     case 5
    %         for sub = 1:size(cho, 1)
    %             i = 1;
    %             icon = [1, 2, 3, 4, 4, 3, 2, 1];
    %             for p = [unique(p2)',  unique(p1)']
    %                 if i < 5
    %                     Q(sub, i) = mean(cho(sub, con(sub, :)==icon(i))==2);
    %                 else
    %                     Q(sub, i) = mean(cho(sub, con(sub, :)==icon(i))==1);
    %                 end
    %                 i = i + 1;
    %             end
    %         end
    end
    
   [cho, cfcho, out, cfout, corr, con, p1, p2, rew, rtime, ev1, ev2] = ...
        DataExtraction.extract_learning_data(...
        d.(exp_name).data, d.(exp_name).sub_ids, idx, sess);

    clear corr
    nsub = length(cho(:, 1));
    ntrials = length(cho(1, :));
    
    fit_cf = exp_num > 2;

    for sub = 1:nsub
        
      
        qlearner = models.QLearning([beta1(sub), alpha1(sub)], ...
            0.5, length(unique(con)), 2, ntrials, decision_rule);

        if exist('Q')
            qlearner.Q(:, :) = Q(sub, :, :);
        end

        s = con(sub, :);
        r = out(sub, :);
        cfr= cfout(sub, :);

        for t = 1:ntrials

            a(t) = qlearner.make_choice(s(t), t);

            switch model
                case 1
                    if a(t) == cho(sub, t)                  
                        r1 = r(t)==1;
                        r2 = cfr(t)==1;
                    else
                        r1 = cfr(t)==1;
                        r2 = r(t)==1;
                    end
                    qlearner.learn(s(t), a(t), r1, r2, fit_cf);
                otherwise
            end

            v = [ev1(sub, t), ev2(sub, t)];

            corr(sub, t) = v(a(t)) > v(3-a(t));

        end

    end

end


