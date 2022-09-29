d = readtable('evoutcome_not_recoded.csv');

mask = logical(strcmp(d.EXP, 'EvOutcome2'));
i2 = d(mask, :);
mask2 = logical(i2.SESSION == 1);
mask1 = logical(i2.SESSION == 0);

i2.SESSION(mask1) = 1;
i2.SESSION(mask2) = 0;
d(mask, :) = i2;

writetable(d, 'evoutcome_recoded.csv')