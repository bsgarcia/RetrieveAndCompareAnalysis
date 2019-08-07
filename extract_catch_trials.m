function [corr_catch] = extract_catch_trials(data, sub_ids, idx)
i = 1;
for id = 1:length(sub_ids)
    sub = sub_ids(id);
    if ismember(sum(data(:, 1) == sub), [255, 285])
        for eli = [0, 2]
            
            mask_eli = data(:, idx.elic) == eli;
            if eli == 0
                eli = 1;
            end
            mask_sub = data(:, idx.sub) == sub;
            mask_catch = data(:, idx.catch) == 1;
            mask_sess = ismember(data(:, idx.sess), [0]);
            mask = logical(mask_sub .* mask_sess .* mask_catch .* mask_eli);
            [noneed, trialorder] = sort(data(mask, idx.trial_idx));
            temp_corr = data(mask, idx.corr);
            corr_catch{i, eli} = temp_corr(trialorder);
        end
        i = i + 1;
    end
end
end