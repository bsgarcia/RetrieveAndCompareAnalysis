init;

selected_exp = [6];

count = 0;
for exp_num = selected_exp
    count = count + 1;
    name = de.get_name_from_exp_num(exp_num);
    T = readtable(sprintf('data/demographics/%s.csv', name));
    T = T(strcmp(T.status, 'APPROVED'),:);
    m(count) = round(nanmean(T.time_taken/60), 2);
    %disp(m(count));
end