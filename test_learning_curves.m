%---------------------------------------------------------
% This script
% computes correct choice rate then plots the article figs
% --------------------------------------------------------------------
init;
%filenames = {filenames{3}, filenames{4}, filenames{5},...
%   filenames{5} , filenames{6}, filenames{6}};
%filenames{6}= 'block_complete_mixed_2s';
%filenames{7}= 'block_complete_mixed_2s_amb';
filenames = {filenames{[3, 4, 5]}};

%------------------------------------------------------------------------
% Plot fig
%------------------------------------------------------------------------
i = 1;
sub = 1;
nsub = 0;

for exp_name = {filenames{:}}

    session = 0;
   
    exp_name = char(exp_name);
    nsub = nsub + d.(exp_name).nsub;
   
    [cho, out, cfout, corr1, con, p1, p2, rew, rtime] = ...
        DataExtraction.extract_learning_data(...
        d.(exp_name).data, d.(exp_name).sub_ids, idx, session);
   
    for isub = 1:d.(exp_name).nsub
        for icond = 1:4
            dd = corr1(isub, (con(isub, :) == icond));
            for t = 1:30
                new_corr(icond, t, sub) = dd(t);
            end
           
        end
        sub = sub + 1;
    end
   
   
    i = i + 1;
end

titles = {'90/10', '80/20', '70/30', '60/40'};
for icond = 1:4
    dd = reshape(new_corr(icond, :, :), [30, size(new_corr(icond, :, :), 3)]);
    figure('Position', [0, 0, 1000, 700]);
    surfaceplot(dd, 0.5 .* ones(3, 1), blue_color_gradient(4, :, :), 1, 0.4,...
        -0.08 , 1.08, 20, sprintf('Cond %s', titles{icond}), 'trials', 'Correct choice rate');
    saveas(gcf, sprintf('%i.png', icond));
end