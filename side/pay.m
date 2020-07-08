%------------------------------------------------------------------------

clear all
close all
%------------------------------------------------------------------------

name = 'block_complete_simple';

data = load(sprintf('data/%s_pay', name));
data = data.data;
sub_ids = unique(data{:, 'prolific'});

print_session_0_gain(data, [], sub_ids);


function print_session_0_gain(data, old_sub_ids, sub_ids)
    i = 1;
    for id = 1:length(sub_ids)     
        sub = sub_ids(id);
        mask_sub = data{:, 'prolific'} == sub;
%         disp(sum(mask_sub));
        if ismember(sum(mask_sub), [216, 258])       %[258, 288, 259, 28, 470, 376])
            mask_sess = ismember(data{:, 'VarName21'}, [0, 1]);
            mask = logical(mask_sub .* mask_sess);
            
            fprintf('%s,%.2f\n', sub, 2.5+sum(data{mask, 'out'}, 'all')* (2.5/77));
            i = i + 1;
%             if mod(i, 10) == 0
%                 fprintf('\n');
%             end
        end
       
    end
    disp(i);
end
