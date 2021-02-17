classdef DataExtraction < handle
    
    properties (SetAccess = public)
        idx
        d
        filenames
    end
    
    methods (Static)
        
        function [data, sub_ids, idx, sim] = get_data(filename)
            
            data = load(filename);
            
            data = data.data;
            try
                sub_ids = unique(data(:, 1));
            catch
                sub_ids = 1:length(data);
            end
            
            % idx
            %-------------------------------------------------------------
            idx.rtime = 6;
            idx.cond = 13;
            idx.sess = 20;
            idx.op1 = 21;
            idx.op2 = 22;
            idx.trial = 12;
            idx.cho = 9;
            idx.out = 7;
            idx.cfout = 8;
            idx.corr = 10;
            idx.rew = 19;
            idx.catch = 25;
            idx.elic = 3;
            idx.sub = 1;
            idx.p1 = 4;
            idx.p2 = 5;
            idx.ev1 = 23;
            idx.ev2 = 24;
            idx.dist = 28;
            idx.plot = 29;
            idx.cont1 = 14;
            idx.cont2 = 15;
            
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
        
        
        function [cho, cfcho, out, cfout, corr, con, p1, p2, rew, rtime, ev1, ev2,...
                error_exclude] = extract_learning_data(data, sub_ids, idx, session)
            i = 1;
            error_exclude = [];
            for id = 1:length(sub_ids)
                try
                    sub = sub_ids(id);
                    mask_sub = data(:, idx.sub) == sub;
                    mask_sess = ismember(data(:, idx.sess), session);
                    mask_eli = data(:, idx.elic) == -1;
                    mask = logical(mask_sub .* mask_sess .* mask_eli);
                    
                    [noneed, trialorder] = sort(data(mask, idx.trial));
                    
                    tempcho = data(mask, idx.cho);
                    cho(i, :) = tempcho(trialorder);
                    
                    cfcho(i, :) = 3 - cho(i, :);
                    
                    tempout = data(mask, idx.out);
                    out(i, :) = tempout(trialorder);
                    tempcorr = data(mask, idx.corr);
                    
                    corr(i, :) = tempcorr(trialorder);
                    temprew = data(mask, idx.rew);
                    
                    rew(i, :) = temprew(trialorder);
                    
                    tempcon = data(mask, idx.cond);
                    con(i, :) = tempcon(trialorder) + 1;
                    
                    tempcfout = data(mask, idx.cfout);
                    cfout(i, :) = tempcfout(trialorder);
                    
                    temp_p1 = data(mask, idx.p1);
                    p1(i, :) = temp_p1(trialorder);
                    
                    temp_p2 = data(mask, idx.p2);
                    p2(i, :) = temp_p2(trialorder);
                    
                    temp_rtime = data(mask, idx.rtime);
                    rtime(i, :) = temp_rtime(trialorder);
                    
                    temp_ev1 = data(mask, idx.ev1);
                    ev1(i, :) = temp_ev1(trialorder);
                    
                    temp_ev2 = data(mask, idx.ev2);
                    ev2(i, :) = temp_ev2(trialorder);
                    
                    i = i + 1;
                catch
                    error_exclude(length(error_exclude) + 1) = i;
                    fprintf('There has been an error while treating subject %d \n', i);
                end
            end
        end
        
        
        function to_keep = exclude_subjects(data, sub_ids, idx,...
                catch_threshold, rtime_threshold, n_best_sub, allowed_nb_of_rows)
            to_keep = [];
            i = 1;
            for id = 1:length(sub_ids)
                sub = sub_ids(id);
                if ismember(sum(data(:, idx.sub) == sub), allowed_nb_of_rows) %255, 285,
                    for eli = [0, 2, -1]
                        if eli ~= -1
                            mask_eli = data(:, idx.elic) == eli;
                            if eli == 0
                                eli = 1;
                            end
                            mask_sub = data(:, idx.sub) == sub;
                            mask_catch = data(:, idx.catch) == 1;
                            mask_no_catch = data(:, idx.catch) == 0;
                            mask_sess = ismember(data(:, idx.sess), [0, 1]);
                            mask = logical(mask_sub .* mask_sess .* mask_catch .* mask_eli);
                            [noneed, trialorder] = sort(data(mask, idx.trial));
                            temp_corr = data(mask, idx.corr);
                            corr_catch{i, eli} = temp_corr(trialorder);
                            
                            mask = logical(mask_sub .* mask_sess .* mask_eli);
                            rtime{i, eli} = data(mask, idx.rtime);
                        else
                            mask_eli = data(:, idx.elic) == eli;
                            mask = logical(mask_sub .* mask_sess .* mask_eli);
                            rtime{i, 3} = data(mask, idx.rtime);
                            corr_catch{i, 3} = data(mask, idx.corr);
                            %                             if  ~ismember(length(corr_catch{i, 3}), [120, 240])
                            %
                            %                                 error('wrong number of learning trials');
                            %
                            %                             end
                        end
                    end
                    
                    if (mean(corr_catch{i, 1}) >= catch_threshold)...
                            && (sum(rtime{i} > rtime_threshold) < 1)
                        to_keep(length(to_keep) + 1) = sub;
                        
                    end
                    i = i + 1;
                    
                end
                
            end
            for j = 1:length(to_keep)
                mask_sub = data(:, idx.sub) == to_keep(j);
                mask_eli = ismember(data(:, idx.elic), -1);
                mask_corr = logical(mask_sub .* mask_sess .* mask_eli .* mask_no_catch);
                corr(j) = mean(data(mask_corr, idx.corr));
            end
            [throw, sorted_idx] = sort(corr);
            
            to_keep = to_keep(sorted_idx);
            if n_best_sub ~= 0
                to_keep = to_keep(end-n_best_sub+1:end);
            else
            end
            
            %new_data = data(ismember(data(:, idx.sub), to_keep), :);
        end
    end
    
    
    methods
        
        function obj = DataExtraction(d, filenames, idx)
            obj.d = d;
            obj.filenames = filenames;
            obj.idx = idx;            
        end
        
        function name = get_name_from_exp_num(obj, exp_num)
            % load data
            name = char(obj.filenames{round(exp_num(1))});
        end
        
        function nsub = get_nsub_from_exp_num(obj, exp_num)
            nsub = obj.d.(get_name_from_exp_num(obj, exp_num)).nsub;
        end
        
        function sess = get_sess_from_exp_num(obj, exp_num)
            if length(exp_num) == 1
                sess = round((exp_num - round(exp_num)) * 10 - 1);
                sess = sess .* (sess ~= -1);
            elseif length(exp_num) == 2
                sess = [0,1];
                
            else
                error('Problem matching session');
            end
            
        end
        
        function zscore_RT(obj, exp_num)       
            [data, sub_ids, session] = prepare(obj, exp_num);
            name = obj.get_name_from_exp_num(exp_num);
            session = [0,1];
            i = 1;
            for id = 1:length(sub_ids)
                sub = sub_ids(id);
                
                mask_eli = ismember(data(:, obj.idx.elic), [-1, 0, 2]);
                mask_sub = data(:, obj.idx.sub) == sub;
                mask_catch = ismember(data(:, obj.idx.catch), [-1, 0]);
                mask_sess = ismember(data(:, obj.idx.sess), session);
                mask = logical(mask_sub .* mask_sess .* mask_eli .* mask_catch);
                
                
                obj.d.(name).data(mask, obj.idx.rtime) = zscore(data(mask, obj.idx.rtime));
                
                i = i + 1;
            end                 
         
        end
        function [data, sub_ids, sess] = prepare(obj, exp_num)
            sess = obj.get_sess_from_exp_num(exp_num);
            name = obj.get_name_from_exp_num(exp_num);
            data = obj.d.(name).data;
            sub_ids = obj.d.(name).sub_ids;
        end
        
        function new_data = extract_LE(obj, exp_num)
            new_data = struct();
            [data, sub_ids, session] = prepare(obj, exp_num);
            i = 1;
            error_exclude = [];
            for id = 1:length(sub_ids)
                try
                    sub = sub_ids(id);
                    mask_sub = data(:, obj.idx.sub) == sub;
                    mask_sess = ismember(data(:, obj.idx.sess), session);
                    mask_eli = data(:, obj.idx.elic) == -1;
                    mask = logical(mask_sub .* mask_sess .* mask_eli);
                    
                    [noneed, trialorder] = sort(data(mask, obj.idx.trial));
                    
                    tempcho = data(mask, obj.idx.cho);
                    new_data.cho(i, :) = tempcho(trialorder);
                    
                    new_data.cfcho(i, :) = 3 - new_data.cho(i, :);
                    
                    tempout = data(mask, obj.idx.out);
                    new_data.out(i, :) = tempout(trialorder);
                    tempcorr = data(mask, obj.idx.corr);
                    
                    new_data.corr(i, :) = tempcorr(trialorder);
                    temprew = data(mask, obj.idx.rew);
                    
                    new_data.rew(i, :) = temprew(trialorder);
                    
                    tempcon = data(mask, obj.idx.cond);
                    new_data.con(i, :) = tempcon(trialorder) + 1;
                    
                    tempcfout = data(mask, obj.idx.cfout);
                    new_data.cfout(i, :) = tempcfout(trialorder);
                    
                    temp_p1 = data(mask, obj.idx.p1);
                    new_data.p1(i, :) = temp_p1(trialorder);
                    
                    temp_p2 = data(mask, obj.idx.p2);
                    new_data.p2(i, :) = temp_p2(trialorder);
                    
                    temp_rtime = data(mask, obj.idx.rtime);
                    new_data.rtime(i, :) = temp_rtime(trialorder);
                    
                    temp_ev1 = data(mask, obj.idx.ev1);
                    new_data.ev1(i, :) = temp_ev1(trialorder);
                    
                    temp_ev2 = data(mask, obj.idx.ev2);
                    new_data.ev2(i, :) = temp_ev2(trialorder);
                    
                    i = i + 1;
                catch
                    error_exclude(length(error_exclude) + 1) = i;
                    fprintf('There has been an error while treating subject %d \n', i);
                end
            end
        end
        
        function new_data = extract_ED(obj, exp_num)
            new_data = struct();
            [data, sub_ids, session] = prepare(obj, exp_num);
            i = 1;
            for id = 1:length(sub_ids)
                 try
                    sub = sub_ids(id);
                    
                    mask_eli = data(:, obj.idx.elic) == 0;
                    mask_sub = data(:, obj.idx.sub) == sub;
                    mask_catch = data(:, obj.idx.catch) == 0;
                    % before exp. 5 op2 has value -1 in ED while after it
                    % takes value 0 (because there were no EE before)
                    mask_vs_lot = ismember(data(:, obj.idx.op2), [0, -1]);
                    mask_sess = ismember(data(:, obj.idx.sess), session);
                    mask = logical(mask_sub .* mask_sess .* mask_eli .* mask_catch .* mask_vs_lot);
                    
                    [noneed, trialorder] = sort(data(mask, obj.idx.trial));
                    
                    temp_corr = data(mask, obj.idx.corr);
                    new_data.corr(i, :) = temp_corr(trialorder);
                    
                    temp_cho = data(mask, obj.idx.cho);
                    new_data.cho(i, :) = temp_cho(trialorder);
                    
                    new_data.cfcho(i, :) = 3 - new_data.cho(i, :);
                    
                    temp_out = data(mask, obj.idx.out);
                    new_data.out(i, :) = temp_out(trialorder);
                    
                    temp_ev1 = data(mask, obj.idx.ev1);
                    new_data.ev1(i, :) = temp_ev1(trialorder);
                    
                    temp_catch = data(mask, obj.idx.catch);
                    new_data.ctch(i, :) = temp_catch(trialorder);
                    
                    temp_cont1 = data(mask, obj.idx.cont1);
                    new_data.cont1(i, :) = temp_cont1(trialorder);
                    
                    temp_ev2 = data(mask, obj.idx.ev2);
                    new_data.ev2(i, :) = temp_ev2(trialorder);
                    
                    temp_cont2 = data(mask, obj.idx.cont2);
                    new_data.cont2(i, :) = temp_cont2(trialorder);
                    
                    temp_p1 = data(mask, obj.idx.p1);
                    new_data.p1(i, :) = temp_p1(trialorder);
                    
                    temp_p2 = data(mask, obj.idx.p2);
                    new_data.p2(i, :) = temp_p2(trialorder);
                    
                    temp_dist = data(mask, obj.idx.dist);
                    new_data.dist(i, :) = temp_dist(trialorder)./100;
                    
                    temp_rtime = data(mask, obj.idx.rtime);
                    new_data.rtime(i, :) = temp_rtime(trialorder);
                    
                    i = i + 1;
                 catch
                     fprintf('There has been an error while treating subject %d \n', i);
                 end
            end
            
        end
        
        function new_data = extract_EE(obj, exp_num)
            new_data = struct();
            [data, sub_ids, session] = prepare(obj, exp_num);
            i = 1;
            for id = 1:length(sub_ids)
                sub = sub_ids(id);
                
                mask_eli = data(:, obj.idx.elic) == 0;
                mask_sub = data(:, obj.idx.sub) == sub;
                mask_catch = data(:, obj.idx.catch) == 0;
                mask_vs_lot = data(:, obj.idx.op2) == 1;
                mask_sess = ismember(data(:, obj.idx.sess), session);
                mask = logical(mask_sub .* mask_sess .* mask_eli .* mask_catch .* mask_vs_lot);
                
                [noneed, trialorder] = sort(data(mask, obj.idx.trial));
                
                temp_corr = data(mask, obj.idx.corr);
                new_data.corr(i, :) = temp_corr(trialorder);
                
                temp_cho = data(mask, obj.idx.cho);
                new_data.cho(i, :) = temp_cho(trialorder);
                
                new_data.cfcho(i, :) = 3 - new_data.cho(i, :);
                
                temp_out = data(mask, obj.idx.out);
                new_data.out(i, :) = temp_out(trialorder);
                
                temp_ev1 = data(mask, obj.idx.ev1);
                new_data.ev1(i, :) = temp_ev1(trialorder);
                
                temp_catch = data(mask, obj.idx.catch);
                new_data.ctch(i, :) = temp_catch(trialorder);
                
                temp_cont1 = data(mask, obj.idx.cont1);
                new_data.cont1(i, :) = temp_cont1(trialorder);
             
                
                temp_ev2 = data(mask, obj.idx.ev2);
                new_data.ev2(i, :) = temp_ev2(trialorder);
                
                temp_cont2 = data(mask, obj.idx.cont2);
                new_data.cont2(i, :) = temp_cont2(trialorder);
                %
          
                
                temp_p1 = data(mask, obj.idx.p1);
                new_data.p1(i, :) = temp_p1(trialorder);
                
                temp_p2 = data(mask, obj.idx.p2);
                new_data.p2(i, :) = temp_p2(trialorder);
                
                temp_dist = data(mask, obj.idx.dist);
                new_data.dist(i, :) = temp_dist(trialorder)./100;
                
                temp_rtime = data(mask, obj.idx.rtime);
                new_data.rtime(i, :) = temp_rtime(trialorder);
                
                i = i + 1;
            end
            
        end
        
        function [corr, cho, out, p1, p2, ev1, ev2, ctch, cont1, cont2, dist, rtime] = ...
                extract_sym_vs_amb_post_test(data, sub_ids, idx, session)
            i = 1;
            for id = 1:length(sub_ids)
                sub = sub_ids(id);
                
                mask_eli = data(:, obj.idx.elic) == 0;
                mask_sub = data(:, obj.idx.sub) == sub;
                mask_catch = data(:, obj.idx.catch) == 0;
                mask_vs_amb = data(:, obj.idx.op2) == 2;
                mask_vs_sym = data(:, obj.idx.op1) == 1;
                
                mask_sess = ismember(data(:, obj.idx.sess), session);
                mask = logical(mask_sub .* mask_sess .* mask_eli .* mask_catch .* mask_vs_sym .* mask_vs_amb);
                
                [noneed, trialorder] = sort(data(mask, obj.idx.trial));
                
                temp_corr = data(mask, obj.idx.corr);
                corr(i, :) = temp_corr(trialorder);
                
                temp_cho = data(mask, obj.idx.cho);
                cho(i, :) = temp_cho(trialorder);
                
                temp_out = data(mask, obj.idx.out);
                out(i, :) = temp_out(trialorder);
                
                temp_ev1 = data(mask, obj.idx.ev1);
                ev1(i, :) = temp_ev1(trialorder);
                
                temp_catch = data(mask, obj.idx.catch);
                ctch(i, :) = temp_catch(trialorder);
                
                temp_cont1 = data(mask, obj.idx.cont1);
                cont1(i, :) = temp_cont1(trialorder);
                
                temp_ev2 = data(mask, obj.idx.ev2);
                ev2(i, :) = temp_ev2(trialorder);
                
                temp_cont2 = data(mask, obj.idx.cont2);
                cont2(i, :) = temp_cont2(trialorder);
                
                temp_p1 = data(mask, obj.idx.p1);
                p1(i, :) = temp_p1(trialorder);
                
                temp_p2 = data(mask, obj.idx.p2);
                p2(i, :) = temp_p2(trialorder);
                
                temp_dist = data(mask, obj.idx.dist);
                dist(i, :) = temp_dist(trialorder)./100;
                
                temp_rtime = data(mask, obj.idx.rtime);
                rtime(i, :) = temp_rtime(trialorder);
                
                i = i + 1;
            end
        end
        
        function [corr, cho, out, p1, p2, ev1, ev2, ctch, cont1, cont2, dist, rtime] = ...
                extract_lot_vs_amb_post_test(data, sub_ids, idx, session)
            i = 1;
            for id = 1:length(sub_ids)
                sub = sub_ids(id);
                
                mask_eli = data(:, obj.idx.elic) == 0;
                mask_sub = data(:, obj.idx.sub) == sub;
                mask_catch = data(:, obj.idx.catch) == 0;
                mask_vs_amb = data(:, obj.idx.op2) == 2;
                mask_vs_sym = data(:, obj.idx.op1) == 0;
                
                mask_sess = ismember(data(:, obj.idx.sess), session);
                mask = logical(mask_sub .* mask_sess .* mask_eli .* mask_catch .* mask_vs_sym .* mask_vs_amb);
                
                [noneed, trialorder] = sort(data(mask, obj.idx.trial));
                
                temp_corr = data(mask, obj.idx.corr);
                corr(i, :) = temp_corr(trialorder);
                
                temp_cho = data(mask, obj.idx.cho);
                cho(i, :) = temp_cho(trialorder);
                
                temp_out = data(mask, obj.idx.out);
                out(i, :) = temp_out(trialorder);
                
                temp_ev1 = data(mask, obj.idx.ev1);
                ev1(i, :) = temp_ev1(trialorder);
                
                temp_catch = data(mask, obj.idx.catch);
                ctch(i, :) = temp_catch(trialorder);
                
                temp_cont1 = data(mask, obj.idx.cont1);
                cont1(i, :) = temp_cont1(trialorder);
                
                temp_ev2 = data(mask, obj.idx.ev2);
                ev2(i, :) = temp_ev2(trialorder);
                
                temp_cont2 = data(mask, obj.idx.cont2);
                cont2(i, :) = temp_cont2(trialorder);
                
                temp_p1 = data(mask, obj.idx.p1);
                p1(i, :) = temp_p1(trialorder);
                
                temp_p2 = data(mask, obj.idx.p2);
                p2(i, :) = temp_p2(trialorder);
                
                temp_dist = data(mask, obj.idx.dist);
                dist(i, :) = temp_dist(trialorder)./100;
                
                temp_rtime = data(mask, obj.idx.rtime);
                rtime(i, :) = temp_rtime(trialorder);
                
                i = i + 1;
            end
        end
        
        function new_data = extract_PM(obj, exp_num)            
             new_data = struct();
            [data, sub_ids, session] = prepare(obj, exp_num);
            i = 1;
            for id = 1:length(sub_ids)
                try
                    sub = sub_ids(id);
                    
                    mask_eli = data(:, obj.idx.elic) == 2;
                    mask_sub = data(:, obj.idx.sub) == sub;
                    mask_catch = data(:, obj.idx.catch) == 0;
                    %mask_vs_lot = ismember(data(:, obj.idx.op2), [0, -1]);
                    mask_sess = ismember(data(:, obj.idx.sess), session);
                    mask = logical(mask_sub .* mask_sess .* mask_eli .* mask_catch);
                    
                    [noneed, trialorder] = sort(data(mask, obj.idx.trial));
                    
                    temp_corr = data(mask, obj.idx.corr);
                    new_data.corr(i, :) = temp_corr(trialorder);
                    
                    temp_cho = data(mask, obj.idx.cho);
                    new_data.cho(i, :) = temp_cho(trialorder);
                    
                    temp_out = data(mask, obj.idx.out);
                    new_data.out(i, :) = temp_out(trialorder);
                    
                    temp_ev1 = data(mask, obj.idx.ev1);
                    new_data.ev1(i, :) = temp_ev1(trialorder);
                    
                    temp_catch = data(mask, obj.idx.catch);
                    new_data.ctch(i, :) = temp_catch(trialorder);
                    
                    temp_cont1 = data(mask, obj.idx.cont1);
                    new_data.cont1(i, :) = temp_cont1(trialorder);
                    
                    temp_ev2 = data(mask, obj.idx.ev2);
                    new_data.ev2(i, :) = temp_ev2(trialorder);
                    
                    temp_cont2 = data(mask, obj.idx.cont2);
                    new_data.cont2(i, :) = temp_cont2(trialorder);
                    
                    temp_p1 = data(mask, obj.idx.p1);
                    new_data.p1(i, :) = temp_p1(trialorder);
                    
                    temp_p2 = data(mask, obj.idx.p2);
                    new_data.p2(i, :) = temp_p2(trialorder);
                    
                    temp_dist = data(mask, obj.idx.dist);
                    new_data.dist(i, :) = temp_dist(trialorder)./100;
                    
                    temp_rtime = data(mask, obj.idx.rtime);
                    new_data.rtime(i, :) = temp_rtime(trialorder);
                    
                    i = i + 1;
                catch
                    fprintf('There has been an error while treating subject %d \n', i);
                end
            end
        end
    end
    
end
