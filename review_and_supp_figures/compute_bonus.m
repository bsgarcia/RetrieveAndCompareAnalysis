T = readtable("evoutcome_not_recoded.csv");
T = T(strcmp(T.EXP, 'EvOutcome2'),:);  
T = T(ismember(T.SESSION, [0,1]),:);  
T = T(ismember(T.ELIC, [-1,0]),:);  

subs = unique(T.ID);
disp(size(subs))
count = 0;
for s = subs'
    count = count + 1;
    T2 = T(strcmp(T.ID, s), :);
    bonus(count) = sum(T2.OUT, 'all') * 0.0109 + 2.5;

    fprintf('%s,%.2f\n', string(s(:)), bonus(count))
end

% 
%         s = sum([ES.out(i, :); EE.out(i, :) LE.out(i, :)], 'all');
%         b(i) = s * 0.0109 + 2.5;
