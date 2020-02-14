% --------------------------------------------------------------------
init;

%------------------------------------------------------------------------
% Plot fig
%------------------------------------------------------------------------
selected_exp = [3, 4, 5.1, 5.2 6.1, 6.2, 7.1, 7.2];
model = [1, 2, 3];

displayfig = 'on';
sessions = [0, 1];
nagent = 1;

for exp_num = selected_exp
    
        idx1 = (exp_num - round(exp_num)) * 10;   
        idx1 = idx1 + (idx1==0);

        sess = sessions(uint64(idx1));

        % load data
        exp_name = char(filenames{round(exp_num)});

        data = d.(exp_name).data;
        sub_ids = d.(exp_name).sub_ids;

        [cho, cfcho, out, cfout, corr1, con1, p1, p2, rew, rtime, ev1, ev2,...
            error_exclude] = ...
            DataExtraction.extract_learning_data(data, sub_ids, idx, sess);
       

        for isub = 1:d.(exp_name).nsub

            for icond = 1:4
                dd1 = corr1(isub, (con1(isub, :) == icond));
                for t = 1:30
                    bhv_corr(icond, isub, t) = dd1(t);

                end

            end
        end
        
        figure('Position', [0, 0, 1000, 600]);
        %alphas = fliplr(linspace(0.2, 0.9, 4));
        titles = {'90/10', '80/20', '70/30', '60/40'};

        %dd1 = reshape(bhv_corr(icond, :, :), [30, size(bhv_corr(icond, :, :), 3)]);
        %dd2 = reshape(sim_corr(icond, :, :), [30, size(sim_corr(icond, :, :), 3)]);
        dd1 = reshape(mean(bhv_corr, 1), [d.(exp_name).nsub, 30]);

        mn = mean(dd1);
        err = std(dd1)./sqrt(size(dd1, 1));

        sc1 = scatter(1:30, mn, 180,...
            'LineWidth', 1.7,...
            'MarkerEdgeColor', 'w',...
            'MarkerFaceColor', 'k', 'MarkerFaceAlpha', 0.7);

        hold on

        errorbar(1:30, mn, err, 'Color',  'k',... %'Alpha', alphas(i),...
            'LineStyle', 'none', 'LineWidth', 1.7, 'HandleVisibility', 'off');%, 'CapSize', 2);
        hold on
        
        cc = {blue_color, green_color, red_color};
        
        for m = model
            
            color = cc{m};

            [corr2, con2] = ...
                sim_exp_learning(exp_name, exp_num, d, idx, sess, nagent, m);
            
            for isub = 1:size(corr2, 1)
                for icond = 1:4
                    dd2 = corr2(isub, (con2(isub, :) == icond));
                    for t = 1:30
                        sim_corr(icond, isub, t) = dd2(t);
                    end
                end
            end
            
            dd2 = reshape(mean(sim_corr, 1), [size(corr2, 1), 30]);

            surfaceplot(dd2', 0.5 .* ones(3, 1), color, 1, 0.4,...
                -0.08 , 1.08, 20, '', 'Trial', 'Correct choice rate');
            hold on
            
            clear bhv_corr sim_corr dd1 dd2 corr1 corr2

        end
        
        legend('data', 'RW', 'RW_{+-}', 'RW_r', 'location', 'SouthEast');

        title(sprintf('Exp. %s', num2str(exp_num)));
        mkdir('fig/exp', 'learning_curves');
        saveas(gcf, ...
            sprintf('fig/exp/learning_curves/exp_%s.png',...
            num2str(exp_num)));
    end
    

% i = 1;
% sub = 1;
% nsub = 0;

% for exp_name = {filenames{:}}
%
%     session = 0;
%
%     exp_name = char(exp_name);
%     nsub = nsub + d.(exp_name).nsub;
%
%     [cho, out, cfout, corr1, con, p1, p2, rew, rtime] = ...
%         DataExtraction.extract_learning_data(...
%         d.(exp_name).data, d.(exp_name).sub_ids, idx, session);
%
%     for isub = 1:d.(exp_name).nsub
%         for icond = 1:4
%             dd = corr1(isub, (con(isub, :) == icond));
%             for t = 1:30
%                 new_corr(icond, t, sub) = dd(t);
%             end
%
%         end
%         sub = sub + 1;
%     end
%
%
%     i = i + 1;
% end

