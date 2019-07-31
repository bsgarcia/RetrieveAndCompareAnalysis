%% Model Free Analysis of the Impact of Past Reward and their Interactions on the Current Choice 


close all
clear all

addpath './simulation'
addpath './fit'
addpath './utils'

%% Load experiment data
% --------------------------------------------------------------------
[con, con2, cho, out, nsubs] = load_data('sim', 'conf');
%[cho, out, con] = getdata('data/data_online_exp/learningdata');

% get triplets where choice at t-1 and t-2 is the same
triplets = gettriplets(cho, out, con, length(cho));

% determinate the relation between the outcomes obtained at t-1 and t-2 and
% the current choice
[estimates, errors] = fit(triplets);
barplot(estimates, errors);


function [estimates, errors] = fit(triplets)
    data = array2table([...
        triplets(:, 1),...
        triplets(:, 2),...
        triplets(:, 3)...
    ], 'Var', {'Stay', 'R1', 'R2'});

    tabl = fitglm(data, 'Stay ~ R1 * R2', 'Distribution', 'binomial');
    % display table
    disp(tabl);
    estimates = tabl.Coefficients.Estimate;
    errors = tabl.Coefficients.SE;
end

function barplot(estimates, errors)
    figure
    bar(estimates);
    hold on
    errorbar(...
        estimates,...
        errors,...
        'Color', 'black',...
        'LineWidth', 2,...
        'LineStyle',...
        'none');
    set(gca,...
        'xticklabels', {...
        'Intercept', 'R(t-1)', 'R(t-2)', 'R(t-1)*R(t-2)'});
    ylim([-1.3, 2])
end


function triplets = gettriplets(cho, out, con, nsubs)
    % nb of raw will be incrementally increased
    triplets = zeros(1, 3);
    i = 1;
    for sub = 1:nsubs
        [con{sub}, trialorder] = sort(con{sub});
        disp(trialorder);
        cho{sub} = cho{sub}(trialorder);
        for t = 3:length(cho{sub})
            if (cho{sub}(t-1) == cho{sub}(t-2)) && ... 
                (con{sub}(t) == con{sub}(t-1) == con{sub}(t-2))          
                triplets(i, 1) = cho{sub}(t) == cho{sub}(t-1);
                triplets(i, 2) = out{sub}(t-1) == 1;
                triplets(i, 3) = out{sub}(t-2) == 1;
                i = i + 1;              
            end
        end
    end
end


function [cho, out, con] = getdata(file)
    data = load(file);
    data = data.learningdata(:, 1:18);
    ncond = max(data(:, 13));
    nsession = max(data(:, 18)) -1 ;
    sub_ids = unique(data(:, 2));
    i = 1;
    k = 1;
    tmaxsession = 60;
    for id = 1:length(sub_ids)
        sub = sub_ids(id);
        mask_sub = data(:, 2) == sub;
        if ismember(sum(mask_sub), [213, 228])
            t = 1;
            for sess = 0:nsession
                mask_sess = data(:, 18) == sess;
                mask = logical(mask_sub .* mask_sess);
                [noneed, trialorder] = sort(data(mask, 12));

                tempcho = data(mask, 9); 
                tempcho = tempcho(trialorder);
                tempout = data(mask, 7); 
                tempout = tempout(trialorder);
                tempcon = data(mask, 13);
                tempcon = tempcon(trialorder);

                for j = 1:tmaxsession

                    cho{i}(t) = tempcho(j);
                    out{i}(t) = tempout(j);
                    con{i}(t) = tempcon(j) + 1;

                    t = t + 1;
                end
            end
            if length(cho{i}) ~= 180
                error('No good length');
            end
%             if (sum(out{i}(:)) < 4)
%                 best_ids(k) = i;
%                 k = k + 1;
%             end
            i = i + 1;
        end 
    end
end







