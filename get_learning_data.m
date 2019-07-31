function [cho, out, con, corr, rew] = get_learning_data(data, ncond, nsession, sub_ids, idx)
    i = 1;
    for id = 1:length(sub_ids)
        sub = sub_ids(id);
        mask_sub = data(:,1) == sub;
        if ismember(sum(data(:,1) == sub), [255, 285])
            %for cond = 0:ncond 
                % = data(:, idx.cond) == cond;
                mask_sess = ismember(data(:, idx.sess), [0]);
                mask_eli = data(:, idx.elic) == -1;
                mask = logical(mask_sub.* mask_sess .* mask_eli);
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
            %end
       i = i+1;
        end
    end
end
