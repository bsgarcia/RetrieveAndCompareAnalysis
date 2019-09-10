classdef DataExtraction
    
    methods (Static)
        
        function [data, sub_ids, exp, sim] = get_data(filename)
            
            data = load(filename);
            
            data = data.data;
            sub_ids = unique(data(:, 1));            
            
            % EXP
            %-------------------------------------------------------------
            exp.rtime = 6;
            exp.cond = 13;
            exp.sess = 20;
            exp.trial = 12;
            exp.cho = 9;
            exp.out = 7;
            exp.cfout = 8;
            exp.corr = 10;
            exp.rew = 19;
            exp.catch = 25;
            exp.elic = 3;
            exp.sub = 1;
            exp.p1 = 4;
            exp.p2 = 5;
            exp.ev1 = 23;
            exp.ev2 = 24;
            exp.dist = 28;
            exp.plot = 29;
            exp.cont1 = 14;
            exp.cont2 = 15;
            
            % SIM
            %-------------------------------------------------------------
            sim.cho = 1;
            sim.out = 2;
            sim.cond = 3;
            sim.softmaxp = 4;
            sim.corr = 5;
            sim.q = 6;
            sim.qdelta = 7;
            sim.p1 = 8;
            sim.p2 = 9;
            sim.ev = 10;
            sim.phase = 11;

        end
        
        
        function [cho, out, cfout, corr, con, p1, p2, rew] = extract_learning_data(data, sub_ids, exp)
            i = 1;
            for id = 1:length(sub_ids)
                sub = sub_ids(id);
                mask_sub = data(:, exp.sub) == sub;
                mask_sess = ismember(data(:, exp.sess), [0]);
                mask_eli = data(:, exp.elic) == -1;
                mask = logical(mask_sub .* mask_sess .* mask_eli);
                
                [noneed, trialorder] = sort(data(mask, exp.trial));
                
                tempcho = data(mask, exp.cho);
                cho(i, :) = tempcho(trialorder);
                
                tempout = data(mask, exp.out);
                out(i, :) = tempout(trialorder);
                tempcorr = data(mask, exp.corr);
                
                corr(i, :) = tempcorr(trialorder);
                temprew = data(mask, exp.rew);
                
                rew(i, :) = temprew(trialorder);
                
                tempcon = data(mask, exp.cond);
                con(i, :) = tempcon(trialorder) + 1;
                
                tempcfout = data(mask, exp.cfout);
                cfout(i, :) = tempcfout(trialorder);
                
                temp_p1 = data(mask, exp.p1);
                p1(i, :) = temp_p1(trialorder);
                
                temp_p2 = data(mask, exp.p2);
                p2(i, :) = temp_p2(trialorder);
                
                
                i = i + 1;
            end
        end
        
        function [to_keep, corr_catch] = exclude_subjects(data, sub_ids, exp,...
                catch_threshold, rtime_threshold, n_best_sub, allowed_nb_of_rows)
            to_keep = [];
            i = 1;
            for id = 1:length(sub_ids)
                sub = sub_ids(id);
                if ismember(sum(data(:, exp.sub) == sub), allowed_nb_of_rows) %255, 285,
                    for eli = [0, 2, -1]
                        if eli ~= -1
                            mask_eli = data(:, exp.elic) == eli;
                            if eli == 0
                                eli = 1;
                            end
                            mask_sub = data(:, exp.sub) == sub;
                            mask_catch = data(:, exp.catch) == 1;
                            mask_no_catch = data(:, exp.catch) == 0;
                            mask_sess = ismember(data(:, exp.sess), [0]);
                            mask = logical(mask_sub .* mask_sess .* mask_catch .* mask_eli);
                            [noneed, trialorder] = sort(data(mask, exp.trial));
                            temp_corr = data(mask, exp.corr);
                            corr_catch{i, eli} = temp_corr(trialorder);

                            mask = logical(mask_sub .* mask_sess .* mask_eli);
                            rtime{i, eli} = data(mask, exp.rtime);
                        else
                            mask_eli = data(:, exp.elic) == eli;
                            mask = logical(mask_sub .* mask_sess .* mask_eli);
                            rtime{i, 3} = data(mask, exp.rtime);
                        end
                    end
                    
                    if (mean(corr_catch{i}) >= catch_threshold)...
                            && (sum(rtime{i} > rtime_threshold) < 1)
                        to_keep(length(to_keep) + 1) = sub;
                        
                    end
                    i = i + 1;
                    
                end
                
            end
            for j = 1:length(to_keep)
                mask_sub = data(:, exp.sub) == to_keep(j);
                mask_eli = ismember(data(:, exp.elic), [-1, 0, 2]);
                mask_corr = logical(mask_sub .* mask_sess .* mask_eli .* mask_no_catch);
                corr(j) = mean(data(mask_corr, exp.corr));
            end
            [throw, sorted_exp] = sort(corr);
            to_keep = to_keep(sorted_exp);
            if n_best_sub ~= 0
                to_keep = to_keep(end-n_best_sub+1:end);
            else
            end
        end
        
        function [corr, cho, out, p1, p2, ev1, ev2, ctch, cont1, cont2, dist] = ...
                extract_elicitation_data(data, sub_ids, exp, eli)
            i = 1;
            for id = 1:length(sub_ids)
                sub = sub_ids(id);
                
                mask_eli = data(:, exp.elic) == eli;
                mask_sub = data(:, exp.sub) == sub;
                mask_catch = data(:, exp.catch) == 0;
                mask_sess = ismember(data(:, exp.sess), [0]);
                mask = logical(mask_sub .* mask_sess .* mask_eli .* mask_catch);
                
                [noneed, trialorder] = sort(data(mask, exp.trial));
                
                temp_corr = data(mask, exp.corr);
                corr(i, :) = temp_corr(trialorder);
                
                temp_cho = data(mask, exp.cho);
                cho(i, :) = temp_cho(trialorder);
                
                temp_out = data(mask, exp.out);
                out(i, :) = temp_out(trialorder);
                
                temp_ev1 = data(mask, exp.ev1);
                ev1(i, :) = temp_ev1(trialorder);
                
                temp_catch = data(mask, exp.catch);
                ctch(i, :) = temp_catch(trialorder);
                
                temp_cont1 = data(mask, exp.cont1);
                cont1(i, :) = temp_cont1(trialorder);
                
                temp_ev2 = data(mask, exp.ev2);
                ev2(i, :) = temp_ev2(trialorder);
                
                temp_cont2 = data(mask, exp.cont2);
                cont2(i, :) = temp_cont2(trialorder);
                
                temp_p1 = data(mask, exp.p1);
                p1(i, :) = temp_p1(trialorder);
                
                temp_p2 = data(mask, exp.p2);
                p2(i, :) = temp_p2(trialorder);
                
                temp_dist = data(mask, exp.dist);
                dist(i, :) = temp_dist(trialorder)./100;
                
                i = i + 1;
            end
        end
        
        function [cho, out, corr, con, q, p1, p2, ev, phase] = extract_sim_data(...
                data, models, sim)
            
            for i = 1:length(data)
                for j = models
                
                    cho(i, j, :) = data{i}(:, sim.cho, j);
                    out(i, j, :) = data{i}(:, sim.out, j);
                    con(i, j, :) = data{i}(:, sim.cond, j);
                    corr(i, j, :) = data{i}(:, sim.corr, j);
                    p1(i, j, :) = data{i}(:, sim.p1, j);
                    p2(i, j, :) = data{i}(:, sim.p2, j);
                    ev(i, j, :) = data{i}(:, sim.ev, j);
                    q(i, j, :) = data{i}(:, sim.q, j);
                    phase(i, j, :) = data{i}(:, sim.phase, j);

                    
                end
            end
            
        end
                
    end
end
