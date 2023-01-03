clear all
T = readtable('incentivize_bonus.csv');
%T = T(strcmp(T.exp, 'incentivize') , :);
subs = unique(T.id);

for i = 1:numel(subs)
    s = subs{i};
    if i == 102
        continue
    end
    tot(i) = T.sum(logical((strcmp(T.id,s)).* (T.session==1).*(T.phase==2)));
    fprintf('%s,%.2f \n', s, (tot(i)*.62)+2.5)
end

disp(mean(tot)*.62+2.5)
disp(std(tot.*.62+2.5))