%------------------------------------------------------------------------
init;
%------------------------------------------------------------------------

for name = filenames
    name = name{:};
    try
        data = readtable(sprintf('data/csv/learning_data_%s.csv', name));
    catch
        data = readtable(sprintf('data/csv/learning_%s.csv', name));
    end

    data = data.data;
    sub_ids = unique(data{:, 'VarName2'});
    i = 1;
    for id = 1:length(sub_ids)
        sub = sub_ids(id);
        mask_sub = data{:, 'prolific'} == sub;
        if ismember(sum(mask_sub), allowed_nb_of_rows)       %[258, 288, 259, 28, 470, 376])
            mask_sess = ismember(data{:, 'VarName2'}, [0, 1]);
            mask = logical(mask_sub .* mask_sess);

            pays(i, 1) = 2.5+sum(data{mask, 'out'}, 'all')* (2.5/77);
            i = i + 1;

        end

    end

end

function print_session_0_gain(data, old_sub_ids, sub_ids)
    i = 1;
    for id = 1:length(sub_ids)     
        sub = sub_ids(id);
        mask_sub = data{:, 'prolific'} == sub;
%         disp(sum(mask_sub));
        if ismember(sum(mask_sub), allowed_nb_of_rows)       %[258, 288, 259, 28, 470, 376])
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
