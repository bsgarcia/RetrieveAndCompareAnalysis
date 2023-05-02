%-------------------------------------------------------------------------
init2;
show_current_script_name(mfilename('fullpath'));
%-------------------------------------------------------------------------
selected_exp = [5, 6.1, 6.2, 7.1 ,7.2, 8.1, 8.2, 9.1, 9.2];
save_name = ['data/fit/', 'midpoints_EE_%s_session_%d'];
displayfig = 'on';
force = true;
num = 0;
for exp_num = selected_exp
    num = num+ 1;
    fprintf('Fitting exp. %s \n', num2str(exp_num));
    sess =  de.get_sess_from_exp_num(exp_num);
    
    data = de.extract_EE(exp_num);

    % ---------------------------------------------------------------------
    % Compute for each subject, the probability of choosing one experienced cue
    %  of choosingsing depending on  cue value
    % --------------------------------------------------------------------
    p_sym = unique(data.p1)';
    nsub = size(data.cho,1);
    
    chose_experience = nan(nsub, length(p_sym), length(p_sym));
    for i = 1:nsub
        for j = 1:length(p_sym)
            count = 0;
            for k = 1:length(p_sym)
                if j ~= k
                    count = count + 1;
                    temp = ...
                        data.cho(...
                            i, logical((data.p2(i, :) == p_sym(k))...
                        .* (data.p1(i, :) == p_sym(j))));
                     chose_experience(i, j, k) = temp == 1;
                end
            end
        end
    end

%    midpoints = nan(nsub, length(p_sym));
    params = nan(nsub, length(p_sym)+1);
 %   beta1 = nan(nsub, 1);
    nll = nan(nsub, 1);
    
    for sub = 1:nsub
                             
        X = zeros(length(p_sym), length(p_sym)-1);
        Y = zeros(length(p_sym), length(p_sym)-1);
        
        for i = 1:length(p_sym)
            rm = 1:length(p_sym);
            y = reshape(chose_experience(sub, i, :), [], 1);
            y = y(rm~=i);
            x = p_sym;
            x = x(rm~=i);
            Y(i, :) = y;
            X(i, :) = x;
        end
        
        
        %disp();
        try 
            if force 
                error('fitting');
            end
             param = load(sprintf(save_name,...
                data.exp_name, sess));
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
        
        save(sprintf(save_name,...
            data.name, sess),...
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
        ll = ll + (1/numel(yhat)) * nansum(log(yhat) .* Y(i,:) + log(1-yhat).*(1-Y(i,:))); 
    end
    if isnan(ll)
        error('is nan')
    end
    nll = -ll;
end

function p = logfun(x, midpoint, temp)
    p = 1./(1+exp(temp.*(x-midpoint)));
end

 