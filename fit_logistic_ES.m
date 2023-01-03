%-------------------------------------------------------------------------
init;
show_current_script_name(mfilename('fullpath'));
%-------------------------------------------------------------------------
selected_exp = [10.1, 10.2];

displayfig = 'on';
force = true;

for exp_num = selected_exp
    
    disp(exp_num);
    sess =  de.get_sess_from_exp_num(exp_num);
    
    data = de.extract_ES(exp_num);
    % ---------------------------------------------------------------------
    % Compute for each symbol p of chosing depending on described cue value
    % ---------------------------------------------------------------------

    p_sym = unique(data.p1)';
    p_lot = unique(data.p2)';
    nsub = size(data.cho,1);
    
    chose_symbol = zeros(nsub, length(p_sym), length(p_lot));
    for i = 1:nsub
        for j = 1:length(p_sym)
            for k = 1:length(p_lot)
                    temp = ...
                        data.cho(...
                            i, logical((data.p2(i, :) == p_lot(k))...
                        .* (data.p1(i, :) == p_sym(j))));
                        chose_symbol(i, j, k) = temp == 1;
                
            end
        end
    end

    midpoints = nan(nsub, length(p_sym));
    params = nan(nsub, length(p_sym)+1);
    beta1 = nan(nsub, 1);
    nll = nan(nsub, 1);
    
    for sub = 1:nsub
                             
        X = zeros(length(p_sym), length(p_lot));
        Y = zeros(length(p_sym), length(p_lot));
        
        for i = 1:length(p_sym)
            Y(i, :) = reshape(chose_symbol(sub, i, :), [], 1);
            X(i, :) = p_lot;
        end
        
        try 
            if force 
                error('fitting');
            end
             param = load(...
                 sprintf('data/fit/midpoints_ES_exp_%d_%d_mle.mat',...
                 round(exp_num), sess ...
             ));
             beta1 = param.beta1;
             midpoints = param.midpoints;
             nll = param.nll;
             tosave = false;
        catch
            tosave = true;
            options = optimset(...
                'Algorithm',...
                'interior-point',...
                'Display', 'off',...
                'MaxIter', 10000,...
                'MaxFunEval', 10000);

            [params(sub, :), nll(sub)] = fmincon(...
                @(x) mle(x, X, Y),...
                [1, ones(1, length(p_sym)) .* .5],...
                [], [], [], [],...
                [0.01, zeros(1, length(p_sym))],...
                [inf, ones(1, length(p_sym))],...
                [],...
                options...
            );
             
        end
        
    end
    
    midpoints = params(:, 2:length(p_sym)+1);
    beta1 = params(:, 1);
    if tosave
        param.midpoints = midpoints;
        param.beta1 = beta1;
        param.nll = nll;
        
        save(sprintf('data/fit/midpoints_ES_exp_%d_%d_mle.mat',...
            round(exp_num), sess),...
            '-struct', 'param');
    end
    
end



function nll = mle(params, X, Y)
    options = optimset('Display','off');
    temp = params(1);
    midpoints = params(2:end);
    ll = 0;
    for i = 1:size(Y, 1)
        yhat = logfun(X(i,:), midpoints(i), temp);
        ll = ll + (1/numel(yhat)) * sum(log(yhat) .* Y(i,:) + log(1-yhat).*(1-Y(i,:))); 
    end
    nll = -ll;
end

function p = logfun(x, midpoint, temp)
    p = 1./(1+exp(temp.*(x-midpoint)));
end

 