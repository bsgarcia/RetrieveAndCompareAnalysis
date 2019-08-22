clear all
%------------------------------------------------------------------------
old_data = load('data/pay');
old_data = old_data.learningdatarandc(:, :);
old_sub_ids = unique(old_data{:, 'VarName2'});

% data = load('data/blockfirst_pay');
% data = data.blockfirst(:, :);
% sub_ids = unique(data{:, 'prolific'});
% disp(sub_ids);
% return
data = load('zouleba');
data = data.zouleba;
sub_ids = unique(data{:, 'prolific'});

extract_learning_data(data, old_sub_ids, sub_ids);


function extract_learning_data(data, old_sub_ids, sub_ids)
i = 1;
for id = 1:length(sub_ids)
    sub = sub_ids(id);
    mask_sub = data{:, 'prolific'} == sub;
        if ismember(sum(mask_sub), [258, 288, 259])
                %mask_cond = data(:, idx.cond) == cond;
                mask_sess = ismember(data{:, 'VarName21'}, [0]);
                %mask_eli = data(:, idx.elic) == -1;
                mask = logical(mask_sub .* mask_sess);
                %prolid = unique(data{mask, 'prolific'});
                %disp(sum(data{mask, 'prolific'} == prolid));

                fprintf('%s,%.2f \n', sub, 2.5+sum(data{mask, 'out'}, 'all')* (2.5/98));
                %disp(i);
                %disp(sum(data{mask, 'out'}, 'all'));
                %disp(i);
            i = i+1;
        else
            disp(sum(mask_sub));
            disp(sub);
        end
end
end