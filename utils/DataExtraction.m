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

            sub_ids = unique(data(:, 1));
            sub_ids = sub_ids(~isnan(sub_ids));


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
            idx.prolific_id = 2;
            idx.dbtime = 30;

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
                    %mask_eli = data(:, idx.elic) == -1;
                    mask = logical(mask_sub .* mask_sess);

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
                catch e
                    error_exclude(length(error_exclude) + 1) = i;

                    fprintf(1, '\n There has been an error while treating subject %d \n', i);
                    fprintf(1,'\n The identifier was: %s \n',e.identifier);
                    fprintf(1,'\n The message was: %s \n',e.message);
                end
            end
        end


        function to_keep = exclude_subjects(data, sub_ids, idx,...
                ES_catch_threshold, PM_catch_threshold, PM_corr_threshold, rtime_threshold, n_best_sub, allowed_nb_of_rows)
            to_keep = [];
            sums = [];
            i = 1;
            n_complete = 0;
            possible_eli = [0, 2, -1];
            for id = 1:length(sub_ids)
                sub = sub_ids(id);
                sums(id) = sum(data(:, idx.sub) == sub);

                if ismember(sum(data(:, idx.sub) == sub), allowed_nb_of_rows)
                    n_complete = n_complete + 1;
                    for eli = 1:length(possible_eli)

                        % if EE, ED, PM
                        if possible_eli(eli) ~= -1
                            mask_eli = data(:, idx.elic) == possible_eli(eli);

                            mask_sub = data(:, idx.sub) == sub;
                            mask_catch = data(:, idx.catch) == 1;
                            mask_sess = ismember(data(:, idx.sess), [0, 1]);
                            mask = logical(mask_sub .* mask_sess .* mask_catch .* mask_eli);
                            [noneed, trialorder] = sort(data(mask, idx.trial));

                            if eli == 2
                                temp_p1 = data(mask, idx.p1);
                                temp_cho = data(mask, idx.cho);
                                temp_corr = abs(temp_p1 - temp_cho./100) < PM_corr_threshold;

                            else
                                temp_corr = data(mask, idx.corr);
                            end

                            corr_catch{i, eli} = temp_corr;

                            mask = logical(mask_sub .* mask_sess .* mask_eli);
                            rtime{i, eli} = data(mask, idx.rtime);
                        
                        % if LE
                        else
                            mask_sub = data(:, idx.sub) == sub;
                            mask_sess = ismember(data(:, idx.sess), [0, 1]);
                            mask_eli = data(:, idx.elic) == eli;
                            mask = logical(mask_sub .* mask_sess .* mask_eli);
                            rtime{i, eli} = data(mask, idx.rtime);

                        end
                    end
                    
                    
                    if (mean(corr_catch{i, 1}) >= ES_catch_threshold) &&...%(mean(corr_catch{i, 2}) >= PM_catch_threshold)...                     
                            (sum(vertcat(rtime{i, :}) > rtime_threshold) < 1) % && (sum(corr1{i, 3}) > 0)
                        to_keep(length(to_keep) + 1) = sub;

                    end
                    i = i + 1;
                    
                end

            end
            fprintf('N = %d \n', length(sub_ids)); 
            fprintf('N complete = %d \n', n_complete); 
            fprintf('N after exclusion = %d \n', length(to_keep)); 


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
                if (length(num2str(exp_num)) == 1) && (exp_num >= 6)
                    sess = [0,1];
                else

                    sess = round((exp_num - round(exp_num)) * 10 - 1);
                    sess = sess .* (sess ~= -1);
                end

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

        function finalstruct = merge2sess(obj, structlist)
            f = fieldnames(structlist(1));
            for i = 1:length(f)
                if ~ismember(f{i}, {'sess', 'nsub', 'name', 'exp_num'})
                    structlist(1).(f{i}) = [structlist(1).(f{i}) structlist(2).(f{i})];
                end
            end
            finalstruct = structlist(1);
        end

        function [data, sub_ids, sess, name, nsub] = prepare(obj, exp_num)
            sess = obj.get_sess_from_exp_num(exp_num);
            name = obj.get_name_from_exp_num(exp_num);
            nsub = obj.get_nsub_from_exp_num(exp_num);
            data = obj.d.(name).data;
            sub_ids = obj.d.(name).sub_ids;
        end

        function new_data = extract_LE(obj, exp_num)
            [data, sub_ids, session, name,nsub] = prepare(obj, exp_num);
            new_data = struct();

            new_data.sess = session;
            new_data.name = name;
            new_data.nsub = nsub;
            new_data.exp_num = exp_num;
            new_data.sub_ids = sub_ids;


            for isess = 1:length(session)
                i = 1;

                for id = 1:length(sub_ids)
                    try
                        sub = sub_ids(id);

                        mask_eli = data(:, obj.idx.elic) == -1;
                        mask_sub = data(:, obj.idx.sub) == sub;
                        mask_cond = data(:, obj.idx.cond) ~= -1;

                        mask_sess = data(:, obj.idx.sess) ==  session(isess);
                        mask = logical(mask_sub .* mask_sess .* mask_eli .* mask_cond);

                        trialorder = data(mask, obj.idx.trial);

                        if ~issorted(trialorder)
                            [noneed, trialorder] = sort(data(mask, obj.idx.trial));
                        else
                            trialorder = 1:length(trialorder);
                        end

                        temp_corr = data(mask, obj.idx.corr);
                        new_data.corr(i, :) = temp_corr(trialorder);

                        temp_cho = data(mask, obj.idx.cho);
                        new_data.cho(i, :) = temp_cho(trialorder);

                        new_data.cfcho(i, :) = 3 - new_data.cho(i, :);

                        temp_out = data(mask, obj.idx.out);
                        new_data.out(i, :) = temp_out(trialorder);

                        temp_cfout = data(mask, obj.idx.cfout);
                        new_data.cfout(i, :) = temp_cfout(trialorder);

                        temp_con = data(mask, obj.idx.cond);
                        new_data.con(i, :) = temp_con(trialorder)+1;

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

                        temp_trial = data(mask, obj.idx.trial);
                        new_data.real_trial(i, :) = temp_trial(trialorder);

                        %new_data.prolific_id(i, :) = data(mask, obj.idx.prolific_id);


                        i = i + 1;

                    catch e
                        fprintf(1, '\n There has been an error while treating subject %d \n', i);
                        fprintf(1,'The identifier was:\n%s',e.identifier);
                        fprintf(1,'There was an error! The message was:\n%s',e.message);
                    end
                end

                structlist(isess) = new_data;

            end

            if length(session) > 1
                new_data = obj.merge2sess(structlist);
            end

        end

        function new_data = extract_nofixed_LE(obj, exp_num)
            [data, sub_ids, session, name,nsub] = prepare(obj, exp_num);
            new_data = struct();

            new_data.sess = session;
            new_data.name = name;
            new_data.nsub = nsub;
            new_data.exp_num = exp_num;


            for isess = 1:length(session)
                i = 1;

                for id = 1:length(sub_ids)
                    try
                        sub = sub_ids(id);

                        mask_eli = data(:, obj.idx.elic) == -1;
                        mask_sub = data(:, obj.idx.sub) == sub;
                        mask_cond = data(:, obj.idx.cond) == -1;

                        mask_sess = data(:, obj.idx.sess) ==  session(isess);
                        mask = logical(mask_sub .* mask_sess .* mask_eli .* mask_cond);

                        trialorder = data(mask, obj.idx.trial);

                        if ~issorted(trialorder)
                            [noneed, trialorder] = sort(data(mask, obj.idx.trial));
                        else
                            trialorder = 1:length(trialorder);
                        end

                        temp_corr = data(mask, obj.idx.corr);
                        new_data.corr(i, :) = temp_corr(trialorder);

                        temp_cho = data(mask, obj.idx.cho);
                        new_data.cho(i, :) = temp_cho(trialorder);

                        new_data.cfcho(i, :) = 3 - new_data.cho(i, :);

                        temp_out = data(mask, obj.idx.out);
                        new_data.out(i, :) = temp_out(trialorder);

                        temp_cfout = data(mask, obj.idx.cfout);
                        new_data.cfout(i, :) = temp_cfout(trialorder);

                        temp_con = data(mask, obj.idx.cond);
                        new_data.con(i, :) = temp_con(trialorder)+1;

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

                        temp_trial = data(mask, obj.idx.trial);
                        new_data.real_trial(i, :) = temp_trial(trialorder);

                        %new_data.prolific_id(i, :) = data(mask, obj.idx.prolific_id);


                        i = i + 1;

                    catch e
                        fprintf(1, '\n There has been an error while treating subject %d \n', i);
                        fprintf(1,'The identifier was:\n%s',e.identifier);
                        fprintf(1,'There was an error! The message was:\n%s',e.message);
                    end
                end

                structlist(isess) = new_data;

            end

            if length(session) > 1
                new_data = obj.merge2sess(structlist);
            end

        end

        function new_data = extract_ES(obj, exp_num)
            [data, sub_ids, session, name,nsub] = prepare(obj, exp_num);
            new_data = struct();

            new_data.sess = session;
            new_data.name = name;
            new_data.nsub = nsub;
            new_data.exp_num = exp_num;
            new_data.id = sub_ids;


            for isess = 1:length(session)
                i = 1;

                for id = 1:length(sub_ids)
                    try
                        sub = sub_ids(id);

                        mask_eli = data(:, obj.idx.elic) == 0;
                        mask_sub = data(:, obj.idx.sub) == sub;
                        mask_catch = data(:, obj.idx.catch) == 0;
                        mask_ycatch = data(:, obj.idx.catch) == 1;

                        % before exp. 5 op2 has value -1 in ED while after it
                        % takes value 0 (because there were no EE before)
                        mask_vs_lot = ismember(data(:, obj.idx.op2), [0, -1]);
                        mask_sa = ismember(data(:, obj.idx.op1), [1,-1]);

                        mask_sess = data(:, obj.idx.sess) ==  session(isess);
                        mask = logical(mask_sub .* mask_sess .* mask_eli .* mask_catch .* mask_vs_lot.* mask_sa);
                        mask2 = logical(mask_sub .* mask_sess .* mask_eli .* mask_vs_lot .* mask_ycatch.* mask_vs_lot);

                        trialorder = data(mask, obj.idx.trial);

                        if ~issorted(trialorder)
                            [noneed, trialorder] = sort(data(mask, obj.idx.trial));
                        else
                            trialorder = 1:length(trialorder);
                        end
% 

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

                        new_data.ctch_p1(i, :) = data(mask2, obj.idx.p1);

                        new_data.ctch_p2(i, :) = data(mask2, obj.idx.p2);

                        new_data.ctch_corr(i, :) = data(mask2, obj.idx.corr);

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

                        temp_trial = data(mask, obj.idx.trial);
                        new_data.real_trial(i, :) = temp_trial(trialorder);

                        new_data.catch(i, :) = data(mask2, obj.idx.catch);                        

                        i = i + 1;

                    catch e
                        fprintf(1, '\n There has been an error while treating subject %d \n', i);
                        fprintf(1,'The identifier was:\n%s',e.identifier);
                        fprintf(1,'There was an error! The message was:\n%s',e.message);
                    end
                end

                structlist(isess) = new_data;

            end

            if length(session) > 1
                new_data = obj.merge2sess(structlist);
            end

        end

        function new_data = extract_EE(obj, exp_num)
            [data, sub_ids, session, name,nsub] = prepare(obj, exp_num);

            [data, sub_ids, session, name,nsub] = prepare(obj, exp_num);
            new_data = struct();

            new_data.sess = session;
            new_data.name = name;
            new_data.nsub = nsub;
            new_data.exp_num = exp_num;
            new_data.id = sub_ids;

            
            for isess = 1:length(session)
                i = 1;

                for id = 1:length(sub_ids)
                    try
                        sub = sub_ids(id);

                        mask_eli = data(:, obj.idx.elic) == 0;
                        mask_sub = data(:, obj.idx.sub) == sub;
                        mask_catch = data(:, obj.idx.catch) == 0;
                        mask_vs_lot = data(:, obj.idx.op2) == 1;
                      
                        mask_sess = data(:, obj.idx.sess) ==  session(isess);
                        mask = logical(mask_sub .* mask_sess .* mask_eli .* mask_catch .* mask_vs_lot);

                        trialorder = data(mask, obj.idx.trial);

                        if ~issorted(trialorder)
                            [noneed, trialorder] = sort(data(mask, obj.idx.trial));
                        else
                            trialorder = 1:length(trialorder);
                        end
                        %data = obj.randomize(data, mask, trialorder);

                        
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

                        temp_trial = data(mask, obj.idx.trial);
                        new_data.real_trial(i, :) = temp_trial(trialorder);


                        i = i + 1;

                    catch e
                        fprintf(1, '\n There has been an error while treating subject %d \n', i);
                        fprintf(1,'The identifier was:\n%s',e.identifier);
                        fprintf(1,'There was an error! The message was:\n%s',e.message);
                    end
                end

                structlist(isess) = new_data;

            end

            if length(session) > 1
                new_data = obj.merge2sess(structlist);
            end

        end

        function new_data = extract_EA(obj, exp_num)
            [data, sub_ids, session, name,nsub] = prepare(obj, exp_num);
            new_data = struct();

            new_data.sess = session;
            new_data.name = name;
            new_data.nsub = nsub;
            new_data.exp_num = exp_num;


            for isess = 1:length(session)
                i = 1;

                for id = 1:length(sub_ids)
                    try
                        sub = sub_ids(id);

                        mask_eli = data(:, obj.idx.elic) == 0;
                        mask_sub = data(:, obj.idx.sub) == sub;
                        mask_catch = data(:, obj.idx.catch) == 0;
                        mask_vs_amb = data(:, obj.idx.op2) == 2;
                        mask_vs_sym = data(:, obj.idx.op1) == 1;

                        mask_sess = data(:, obj.idx.sess) ==  session(isess);
                        mask = logical(mask_sub .* mask_sess .* mask_eli .* mask_catch .* mask_vs_sym .* mask_vs_amb);


                        trialorder = data(mask, obj.idx.trial);

                        if ~issorted(trialorder)
                            [noneed, trialorder] = sort(data(mask, obj.idx.trial));
                        else
                            trialorder = 1:length(trialorder);
                        end
                        
                        %data = obj.randomize(data, mask, trialorder);

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

                        temp_trial = data(mask, obj.idx.trial);
                        new_data.real_trial(i, :) = temp_trial(trialorder);


                        i = i + 1;

                    catch e
                        fprintf(1, '\n There has been an error while treating subject %d \n', i);
                        fprintf(1,'The identifier was:\n%s',e.identifier);
                        fprintf(1,'There was an error! The message was:\n%s',e.message);
                    end
                end

                structlist(isess) = new_data;

            end

            if length(session) > 1
                new_data = obj.merge2sess(structlist);
            end

        end
        function new_data = extract_SA(obj, exp_num)
            [data, sub_ids, session, name,nsub] = prepare(obj, exp_num);
            new_data = struct();

            new_data.sess = session;
            new_data.name = name;
            new_data.nsub = nsub;
            new_data.exp_num = exp_num;


            for isess = 1:length(session)
                i = 1;

                for id = 1:length(sub_ids)
                    try
                        sub = sub_ids(id);

                        mask_eli = data(:, obj.idx.elic) == 0;
                        mask_sub = data(:, obj.idx.sub) == sub;
                        mask_catch = data(:, obj.idx.catch) == 0;
                        mask_vs_amb = data(:, obj.idx.op2) == 2;
                        mask_vs_sym = data(:, obj.idx.op1) == 0;

                        mask_sess = data(:, obj.idx.sess) ==  session(isess);
                        mask = logical(mask_sub .* mask_sess .* mask_eli .* mask_catch .* mask_vs_sym .* mask_vs_amb);

                        trialorder = data(mask, obj.idx.trial);

                        if ~issorted(trialorder)
                            [noneed, trialorder] = sort(data(mask, obj.idx.trial));
                        else
                            trialorder = 1:length(trialorder);
                        end

                        %data = obj.randomize(data, mask, trialorder);


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

                        temp_trial = data(mask, obj.idx.trial);
                        new_data.real_trial(i, :) = temp_trial(trialorder);


                        i = i + 1;

                    catch e
                        fprintf(1, '\n There has been an error while treating subject %d \n', i);
                        fprintf(1,'The identifier was:\n%s',e.identifier);
                        fprintf(1,'There was an error! The message was:\n%s',e.message);
                    end
                end

                structlist(isess) = new_data;

            end

            if length(session) > 1
                new_data = obj.merge2sess(structlist);
            end

        end

        function new_data = extract_SP(obj, exp_num)
            
            [data, sub_ids, session, name,nsub] = prepare(obj, exp_num);
            
            new_data = struct();

            new_data.sess = session;
            new_data.name = name;
            new_data.nsub = nsub;
            new_data.exp_num = exp_num;

         
            i = 1;
            for id = 1:length(sub_ids)
                try
                    sub = sub_ids(id);

                    mask_eli = data(:, obj.idx.elic) == 2;
                    mask_sub = data(:, obj.idx.sub) == sub;
                    mask_catch = (data(:, obj.idx.catch) ~= 1);
                    mask_ycatch = (data(:, obj.idx.op1) == 0);

                    %mask_vs_lot = ismember(data(:, obj.idx.op2), [0, -1]);
                    mask_sess = ismember(data(:, obj.idx.sess), session);
                    mask = logical(mask_sub .* mask_sess .* mask_eli .* mask_catch);
                    mask2 = logical(mask_sub .* mask_sess .* mask_eli .* mask_ycatch);


                    [noneed, trialorder] = sort(data(mask, obj.idx.trial));
                    %[noneed, trialorder] = sort(data(mask, obj.idx.trial));


                    new_data.ctch_p1(i, :) = data(mask2, obj.idx.p1);

                    new_data.ctch_corr(i, :) = data(mask2, obj.idx.corr);
                    new_data.ctch_cho(i, :) = data(mask2, obj.idx.cho);


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

                    new_data.catch(i, :) = data(mask2, obj.idx.catch);


                    i = i + 1;
                catch
                    fprintf('There has been an error while treating subject %d \n', i);
                end
            end
        end
    end

end
