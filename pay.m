clear all
%------------------------------------------------------------------------
data = load('data/pay');
data = data.learningdatarandc(:, :);
sub_ids = unique(data{:, 'VarName2'});

extract_learning_data(data, sub_ids);


function extract_learning_data(data, sub_ids)
i = 1;
for id = 1:length(sub_ids)
    sub = sub_ids(id);
    mask_sub = data{:, 'VarName2'} == sub;
    if ismember(sum(mask_sub), [255, 285])
            %mask_cond = data(:, idx.cond) == cond;
            mask_sess = ismember(data{:, 'VarName21'}, [0]);
            %mask_eli = data(:, idx.elic) == -1;
            mask = logical(mask_sub .* mask_sess);
            prolid = unique(data{mask, 'prolific'});
            %disp(sum(data{mask, 'prolific'} == prolid));
            
            fprintf('%s,%.2f\n', prolid, 2.5+sum(data{mask, 'out'}, 'all')* (2.5/98));
            %disp(sum(data{mask, 'out'}, 'all'));
            %disp(i);
        i = i+1;
    end
end
end