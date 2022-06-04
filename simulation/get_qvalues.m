function [Q, params] = get_qvalues(sim_params)
   
    % ----------------------------------------------------------%
    % Parameters                                                %
    % ----------------------------------------------------------%

    sim_params.show_window = true;
    
    switch sim_params.model
        case 1
            
            data = sim_params.de.extract_LE(sim_params.exp_num);

            params.cho = data.cho;
            params.cfcho = data.cfcho;
            params.con = data.con;
            params.out = data.out==1;
            params.cfout = data.cfout==1;
            params.ntrials = size(data.cho, 2);
            params.fit_cf = (sim_params.exp_num>2);
            params.model = sim_params.model;
            params.ncond = length(unique(data.con));
            params.noptions = 2;
            params.decision_rule = 1;
            params.nsub = sim_params.nsub;
            params.q = 0.5;
            if isfield(params, 'random')
                params.random = sim_params.random;
            else
                params.random = false;
            end
            if isfield(sim_params, 'nagent')
                params.nagent = sim_params.nagent;
            else
                params.nagent = 1;
            end
            
            if ~isfield(sim_params, 'alpha1')
                data = load(sprintf('data/fit/%s_learning_%d', ...
                    sim_params.exp_name, sim_params.sess));
                parameters = data.data('parameters');

                params.alpha1 = parameters{1}(:, 2);
                params.beta1 = parameters{1}(:, 1);
            else
                params.alpha1 = sim_params.alpha1;
                params.beta1 = sim_params.beta1;
            end
            
            Q = sort_Q(simulation(params));

        case 2
            data = sim_params.de.extract_SP(sim_params.exp_num);
     
            for sub = 1:size(data.cho, 1)
                i = 1;      

                for p = unique(data.p1)'
                    Q(sub, i) = mean(data.cho(sub, (data.p1(sub, :) == p))./100);
                    params.corr(sub, i) = abs(Q(sub, i) -  p) <= .1;
                    i = i + 1;          
                end

            end
            
        case 3
            
            [corr, cho, out2, p1, p2, ev1, ev2, ctch, cont1, cont2, dist] = ...
        DataExtraction.extract_sym_vs_amb_post_test(...
                sim_params.d.(sim_params.exp_name).data,...
                sim_params.d.(sim_params.exp_name).sub_ids, sim_params.idx, sim_params.sess);
             
            p_sym = unique(p1)';
            for i = 1:sim_params.nsub
                for j = 1:length(p_sym)
                    temp = ...
                    cho(i, logical(...
                    (p1(i, :) == p_sym(j))));
                    Q(i, j) = mean(temp == 1);
            
                end
            end
            data = load(sprintf('data/fit/%s_learning_%d', ...
                sim_params.exp_name, sim_params.sess));
            parameters = data.data('parameters');

            params.alpha1 = parameters{1}(:, 2);
            params.beta1 = parameters{1}(:, 1);
            
               
            [corr, cho, out2, p1, p2, ev1, ev2, ctch, cont1, cont2, dist] = ...
            DataExtraction.extract_lot_vs_amb_post_test(...
                sim_params.d.(sim_params.exp_name).data,...
                sim_params.d.(sim_params.exp_name).sub_ids, sim_params.idx, sim_params.sess);
             
            p_lot = unique(p1)';
            for i = 1:sim_params.nsub
                for j = 1:length(p_lot)
                    temp = ...
                    cho(i, logical(...
                    (p1(i, :) == p_lot(j))));
                    lot(i, j) = mean(temp == 1);
            
                end
            end
            params.lot = lot;
    end
end
         % ---------------------------------------------------------%


function Q = simulation(sim_params)
    
    Q = ones(sim_params.nsub*sim_params.nagent, sim_params.ncond, sim_params.noptions)...
        .*sim_params.q;    
    i = 0;
    
    for agent = 1:sim_params.nagent
        for sub = 1:sim_params.nsub    
            i = i + 1;
            s = sim_params.con(sub, :);
            cfr = sim_params.cfout(sub, :);
            r = sim_params.out(sub, :);
            a = sim_params.cho(sub, :);
            cfa = sim_params.cfcho(sub, :);

            if sim_params.random        
                order = randperm(length(a));
                s = s(order);
                cfr = cfr(order);
                r = r(order);
                a = a(order);
                cfa = cfa(order);
            end
            fit_cf = sim_params.fit_cf;

            qlearner = models.QLearning([NaN, sim_params.alpha1(sub)], sim_params.q,...
               sim_params.ncond, sim_params.noptions,...
               sim_params.ntrials, sim_params.decision_rule);

            for t = 1:sim_params.ntrials            
                 qlearner.learn(s(t), a(t), r(t));
                 if fit_cf
                     qlearner.learn(s(t), cfa(t), cfr(t));
                 end                         
            end

            Q(i, :, :) = qlearner.Q(:, :);

        end
    end
       
end

