delta_exp1 = 2.7;
delta_desc1 = .3;
gamma_exp1 = .9;
gamma_desc1 = .6;

param = [...
    [delta_exp1, delta_desc1];...
    [gamma_exp1, gamma_desc1];...
];
p = 0.1:.01:1;
count = 0;
for x = p
    count = count + 1;
% prelec PWF
    p_def(count,:) = exp(...
    -param(2, :) .* (-log([x, x])).^param(1, :)...
    );
end

figure
plot(p, p_def);
