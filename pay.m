clear all
close all
%------------------------------------------------------------------------

name = 'block_complete_mixed';

data = load(sprintf('data/%s_pay', name));
data = data.data;
sub_ids = unique(data{:, 'prolific'});

extract_learning_data(data, [], sub_ids);


function extract_learning_data(data, old_sub_ids, sub_ids)
    i = 1;
    for id = 1:length(sub_ids)
        sub = sub_ids(id);
        mask_sub = data{:, 'prolific'} == sub;
        if ismember(sum(mask_sub), [258, 288, 259, 28, 470, 376])
            mask_sess = ismember(data{:, 'VarName21'}, [0]);
            mask = logical(mask_sub .* mask_sess);

            fprintf('%s,%.2f \n', sub, 2.5+sum(data{mask, 'out'}, 'all')* (2.5/115));
                        i = i+1;


%         else
%             mask_sess = ismember(data{:, 'VarName21'}, [0]);
%             mask = logical(mask_sub .* mask_sess);
%             fprintf('%s,%.2f \n', sub, 2.5+sum(data{mask, 'out'}, 'all')* (2.5/98));
        end

    end
    disp(i);
end
