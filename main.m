clear all
%------------------------------------------------------------------------
data = load('data');
data = data.learningdatarandc6(:, :);

% get parameters
%------------------------------------------------------------------------
ncond = max(data(:, 13));
nsession = max(data(:, 20));
sub_ids = unique(data(:, 1));
sub_ids = sub_ids(2);

%------------------------------------------------------------------------
% Define idx columns
%------------------------------------------------------------------------
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
idx.ev1 = 23;
idx.ev2 = 24;
idx.cont1 = 14;
idx.cont2 = 15;
%------------------------------------------------------------------------

corr_catch = extract_catch_trials(data, sub_ids, idx);
[cho1, out1, corr, rew] = extract_learning_data(...
    data, ncond, nsession, sub_ids, idx);
[corr, cho, out, ev1, ev2, ctch, cont1, cont2] = extract_elicitation_data(...
    data, sub_ids, idx);

%------------------------------------------------------------------------
% Compute corr choice rate
% %------------------------------------------------------------------------
% corr_rate = zeros(length(sub_ids), 30, 4);
% 
% for k = 1:length(sub_ids)
%     for i = 1:30
%         for j = 1:4
%             corr_rate(k, i, j) = sum(corr(k, 1:i, j) == 1) ./ i;
%         end
%     end
% end

%------------------------------------------------------------------------
% PLOT
%------------------------------------------------------------------------
i = 1;
for cond = 1:4
    subplot(1, 4, i)
    i = i + 1;
        reversalplot(...
            corr_rate(:, :, cond)',... %data
            [],... %time when reversal occurs
            [],... %time when cond changes
            ones(3) * 0.5,... % chance lvl
            [0    0.4470    0.7410],... %curve color
            0.9,... %linewidth
            0.3,... % alpha
            0, 1,... % ylims
            15,... %fontsizemat,
            sprintf('Cond %d', cond),... %title,
            'trials',... %xlabel
            'correct choice rate'... % ylabel
    );
end

function [cho, out, corr, rew] = extract_learning_data(data, ncond, nsession, sub_ids, idx)
    i = 1;
    for id = 1:length(sub_ids)
        sub = sub_ids(id);
        mask_sub = data(:,1) == sub;
            for cond = 0:ncond 
                mask_cond = data(:, idx.cond) == cond;
                mask_sess = ismember(data(:, idx.sess), [0]);
                mask = logical(mask_sub .* mask_cond .* mask_sess);
                [noneed, trialorder] = sort(data(mask, idx.trial_idx));
                tempcho = data(mask, idx.cho); 
                cho(i, 1:30, cond+1) = tempcho(trialorder);
                tempout = data(mask, idx.out); 
                out(i, 1:30, cond+1) = tempout(trialorder);
                tempcorr = data(mask, idx.corr);
                corr(i, 1:30, cond+1) = tempcorr(trialorder);   
                temprew = data(mask, idx.rew);
                rew(i, 1:30, cond+1) = temprew(trialorder);
            end
       i = i+1;
    end
end

function [corr_catch] = extract_catch_trials(data, sub_ids, idx)
   i = 1;
    for id = 1:length(sub_ids)
        for eli = [0, 2]
            sub = sub_ids(id);
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
function [corr, cho, out, ev1, ev2, ctch, cont1, cont2] = extract_elicitation_data(data, sub_ids, idx)
   i = 1;
    for id = 1:length(sub_ids)
        for eli = [0, 2]
            sub = sub_ids(id);
            mask_eli = data(:, idx.elic) == eli;
            if eli == 0
                eli = 1;
            end
            mask_sub = data(:, idx.sub) == sub;
            %mask_catch = data(:, idx.catch) == 1;
            mask_sess = ismember(data(:, idx.sess), [0]);
            mask = logical(mask_sub .* mask_sess .* mask_eli);
            [noneed, trialorder] = sort(data(mask, idx.trial_idx));
            temp_corr = data(mask, idx.corr);
            corr{i, eli} = temp_corr(trialorder);
            temp_cho = data(mask, idx.cho);
            cho{i, eli} = temp_cho(trialorder);
            temp_out = data(mask, idx.out);
            out{i, eli} = temp_out(trialorder);
            temp_ev1 = data(mask, idx.ev1);
            ev1{i, eli} = temp_ev1(trialorder);
            temp_catch = data(mask, idx.catch);
            ctch{i, eli} = temp_catch(trialorder);
            temp_cont1 = data(mask, idx.cont1);
            cont1{i, eli} = temp_cont1(trialorder);
            if eli == 1
                temp_ev2 = data(mask, idx.ev2);
                ev2{i, eli} = temp_ev2(trialorder);
                temp_cont2 = data(mask, idx.cont2);
                cont2{i, eli} = temp_cont2(trialorder);
            end
            
        end
        i = i + 1;
    end
end

