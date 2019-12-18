% --------------------------------------------------------------------
% This script 
% computes correct choice rate then plots the article figs
% --------------------------------------------------------------------
init;
filenames{6}= 'block_complete_mixed_2s';
filenames{7}= 'block_complete_mixed_2s_amb';
filenames{8}= 'block_complete_mixed_2s_amb';


%------------------------------------------------------------------------
% Plot fig
%------------------------------------------------------------------------
titles = {'Exp. 3',...
        'Exp. 4', 'Exp. 5 Sess. 1', 'Exp. 5 Sess. 2', 'Exp. 6 Sess. 1', 'Exp. 6 Sess. 2'};
    
   i = 1;
    sub = 1;
    nsub = 0;

    
    for exp_name = {filenames{:}}
        if ismember(i, [6, 8])
            session = 1;
        else
            session = 0;
        end
        
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
    
    for icond = 1:4
        for t = 1:30
            mn(icond, t) = mean(new_corr(icond, t, :));
            err(icond, t) = std(new_corr(icond, t, :))./sqrt(length(new_corr(icond, t, :)));
        end
    end
    
    titles = {'90/10', '80/20', '70/30', '60/40'};
    for icond = 1:4
        dd = reshape(new_corr(icond, :, :), [576, 30]);
        figure
        surfaceplot(dd', 0.5 .* ones(3, 1), blue_color, 1, 0.8,...
        -0.08 , 1.08, 20, sprintf('Cond %s', titles{icond}), 'Correct choice rate', 'trials');
    end
    