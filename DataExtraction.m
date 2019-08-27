classdef DataExtraction
    methods (Static)
        function [data, ncond, nsession, sub_ids, idx] = get_parameters(filename)
            data = load(filename);
            if strcmp(filename, 'data/blockfull')
                data = data.blockfull;
            else
                data = data.full;
            end
            
            % get parameters
            %-------------------------------------------------------------
            ncond = max(data(:, 13));
            nsession = max(data(:, 20));
            sub_ids = unique(data(:, 1));
            %sub_ids = sub_ids(2);
 
            %-------------------------------------------------------------
            idx.rtime = 6;
            idx.cond = 13;
            idx.sess = 20;
            idx.trial_idx = 12;
            idx.cho = 9;
            idx.out = 7;
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
            %----------------------------------------------------------------------
            
        end
        
        
        function [cho, out, corr, con, rew] = extract_learning_data(data, sub_ids, idx)
            i = 1;
            for id = 1:length(sub_ids)
                sub = sub_ids(id);
                mask_sub = data(:, idx.sub) == sub;
                mask_sess = ismember(data(:, idx.sess), [0]);
                mask_eli = data(:, idx.elic) == -1;
                mask = logical(mask_sub .* mask_sess .* mask_eli);
                
                [noneed, trialorder] = sort(data(mask, idx.trial_idx));
                
                tempcho = data(mask, idx.cho);
                cho(i, :) = tempcho(trialorder);
                
                tempout = data(mask, idx.out);
                out(i, :) = tempout(trialorder);
                tempcorr = data(mask, idx.corr);
                
                corr(i, :) = tempcorr(trialorder);
                temprew = data(mask, idx.rew);
                
                rew(i, :) = temprew(trialorder);
                
                tempcon = data(mask, idx.cond);
                con(i, :) = tempcon(trialorder) + 1;
                
                i = i + 1;
            end
        end
        
        function [to_keep, corr_catch] = exclude_subjects(data, sub_ids, idx,...
                catch_threshold, n_best_sub, allowed_nb_of_rows)
            to_keep = [];
            i = 1;
            for id = 1:length(sub_ids)
                sub = sub_ids(id);
                if ismember(sum(data(:, idx.sub) == sub), allowed_nb_of_rows) %255, 285,
                    for eli = [0, 2]
                        mask_eli = data(:, idx.elic) == eli;
                        if eli == 0
                            eli = 1;
                        end
                        mask_sub = data(:, idx.sub) == sub;
                        mask_catch = data(:, idx.catch) == 1;
                        mask_no_catch = data(:, idx.catch) == 0;
                        mask_sess = ismember(data(:, idx.sess), [0]);
                        mask = logical(mask_sub .* mask_sess .* mask_catch .* mask_eli);
                        [noneed, trialorder] = sort(data(mask, idx.trial_idx));
                        temp_corr = data(mask, idx.corr);
                        corr_catch{i, eli} = temp_corr(trialorder);
                    end
                    
                    if mean(corr_catch{i}) >= catch_threshold
                        to_keep(length(to_keep) + 1) = sub;
                        
                    end
                    i = i + 1;
                    
                end
                
            end
            for j = 1:length(to_keep)
                mask_sub = data(:, idx.sub) == to_keep(j);
                mask_eli = data(:, idx.elic) == 0;
                mask_corr = logical(mask_sub .* mask_sess .* mask_eli .* mask_no_catch);
                corr(j) = mean(data(mask_corr, idx.corr));
            end
            [throw, sorted_idx] = sort(corr);
            to_keep = to_keep(sorted_idx);
            if n_best_sub ~= 0
                to_keep = to_keep(end-n_best_sub+1:end);
            else
            end
        end
        
        function [corr, cho, out, p1, p2, ev1, ev2, ctch, cont1, cont2] = ...
                extract_elicitation_data(data, sub_ids, idx, eli)
            i = 1;
            for id = 1:length(sub_ids)
                sub = sub_ids(id);
                
                mask_eli = data(:, idx.elic) == eli;
                mask_sub = data(:, idx.sub) == sub;
                mask_catch = data(:, idx.catch) == 0;
                mask_sess = ismember(data(:, idx.sess), [0]);
                mask = logical(mask_sub .* mask_sess .* mask_eli .* mask_catch);
                
                [noneed, trialorder] = sort(data(mask, idx.trial_idx));
                
                temp_corr = data(mask, idx.corr);
                corr(i, :) = temp_corr(trialorder);
                
                temp_cho = data(mask, idx.cho);
                cho(i, :) = temp_cho(trialorder);
                
                temp_out = data(mask, idx.out);
                out(i, :) = temp_out(trialorder);
                
                temp_ev1 = data(mask, idx.ev1);
                ev1(i, :) = temp_ev1(trialorder);
                
                temp_catch = data(mask, idx.catch);
                ctch(i, :) = temp_catch(trialorder);
                
                temp_cont1 = data(mask, idx.cont1);
                cont1(i, :) = temp_cont1(trialorder);
                
                temp_ev2 = data(mask, idx.ev2);
                ev2(i, :) = temp_ev2(trialorder);
                
                temp_cont2 = data(mask, idx.cont2);
                cont2(i, :) = temp_cont2(trialorder);
                
                temp_p1 = data(mask, idx.p1);
                p1(i, :) = temp_p1(trialorder);
                
                temp_p2 = data(mask, idx.p2);
                p2(i, :) = temp_p2(trialorder);
                
                i = i + 1;
            end
        end
    end
end
