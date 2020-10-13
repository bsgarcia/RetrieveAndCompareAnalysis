%-------------------------------------------------------------------------
init;
%-------------------------------------------------------------------------

selected_exp = [8.2];

displayfig = 'off';
force = true;

for exp_num = selected_exp
    
    disp(exp_num);
    % retrieve session
    sess = round((exp_num - round(exp_num)) * 10 - 1);
    sess = sess .* (sess ~= -1);
        
    % load data
    name = char(filenames{round(exp_num)});
    
    data = d.(name).data;
    sub_ids = d.(name).sub_ids;
    
    [corr, cho, out2, p1, p2, ev1, ev2, ctch, cont1, cont2, dist] = ...
        DataExtraction.extract_sym_vs_lot_post_test(...
        data, sub_ids, idx, sess);
    
    % ---------------------------------------------------------------------
    % Compute for each symbol p of chosing depending on described cue value
    % ---------------------------------------------------------------------

    p_lot = unique(p2)';
    p_sym = unique(p1)';
    nsub = d.(name).nsub;
    
    chose_symbol = zeros(d.(name).nsub, length(p_lot), length(p_sym));
    for i = 1:nsub
        for j = 1:length(p_lot)
            for k = 1:length(p_sym)
                temp = ...
                    cho(i, logical(...
                    (p2(i, :) == p_lot(j)) .* (p1(i, :) == p_sym(k))));
                    chose_symbol(i, j, k) = temp == 1;
            end
        end
    end

    midpoints = nan(nsub, length(p_sym));
    params = nan(nsub, length(p_sym)+1);
    beta1 = nan(nsub, 1);
    err = nan(nsub, 1);
    
    for sub = 1:nsub
                             
        X = zeros(length(p_sym), length(p_lot));
        Y = zeros(length(p_sym), length(p_lot));
        
        for i = 1:length(p_sym)
            Y(i, :) = reshape(chose_symbol(sub, :, i), [], 1);
            X(i, :) = p_lot;
        end
        
        try 
            if force 
                error('fitting');
            end
             param = load(...
                 sprintf('data/post_test_fitparam_ED_exp_%d_%d.mat',...
                 round(exp_num), sess...
             ));
             beta1 = param.beta1;
             midpoints = param.midpoints;
             tosave = false;
        catch
            tosave = true;
            options = optimset(...
                'Algorithm',...
                'interior-point',...
                'Display', 'off',...
                'MaxIter', 10000,...
                'MaxFunEval', 10000);

            [params(sub, :), err(sub)] = fmincon(...
                @(x) tofit(x, X, Y),...
                [1, ones(1, length(p_sym)) .* .5],...
                [], [], [], [],...
                [0.01, zeros(1, length(p_sym))],...
                [inf, ones(1, length(p_sym))],...
                [],...
                options...
            );
      
        end
        
        midpoints = params(:, 2:length(p_sym)+1);
        beta1 = params(:, 1);
        
    end
    
    if tosave
        param.midpoints = midpoints;
        param.beta1 = beta1;
        param.err = err;
        
        save(sprintf('data/post_test_fitparam_ED_exp_%d_%d.mat',...
            round(exp_num), sess),...
            '-struct', 'param');
    end
    
end


function err = tofit(params, X, Y)
    options = optimset('Display','off');
    temp = params(1);
    midpoints = params(2:end);
    for i = 1:size(Y, 1)
        residuals(i,:) = logfun(X(i,:), midpoints(i), temp) - Y(i,:);
    end
    err = sum(residuals.^2, 'all');
end

function p = logfun(x, midpoint, temp)
    p = 1./(1+exp(temp.*(x-midpoint)));
end

 