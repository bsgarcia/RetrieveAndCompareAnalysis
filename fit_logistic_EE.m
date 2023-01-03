%-------------------------------------------------------------------------
init;
show_current_script_name(mfilename('fullpath'));
%-------------------------------------------------------------------------
selected_exp = [1, 2, 3, 4, 5, 6.1, 6.2, 7.1 ,7.2, 8.1, 8.2, 9.1, 9.2, 10.1, 10.2];

displayfig = 'on';
force = true;
num = 0;
for exp_num = selected_exp
    num = num+ 1;
    disp(exp_num);
    sess =  de.get_sess_from_exp_num(exp_num);
    
    data = de.extract_EE(exp_num);
    % ---------------------------------------------------------------------
    % Compute for each symbol p of chosing depending on described cue value
    % ---------------------------------------------------------------------

    p_sym = unique(data.p1)';
    nsub = size(data.cho,1);
    
    chose_symbol = nan(nsub, length(p_sym), length(p_sym));
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
                        chose_symbol(i, j, k) = temp == 1;
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
            y = reshape(chose_symbol(sub, i, :), [], 1);
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
             param = load(...
                 sprintf('data/fit/midpoints_EE_exp_%d_%d_mle.mat',...
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
        
        save(sprintf('data/fit/midpoints_EE_exp_%d_%d_mle.mat',...
            round(exp_num), sess),...
            '-struct', 'param');
    end
%     return
%     figure
%     subplot(1, length(selected_exp), num);
%     
%     pwin = p_sym;
%     alpha = linspace(.15, .95, length(pwin));
%     lin1 = plot(...
%         linspace(pwin(1)*100, pwin(end)*100, 12), ones(12,1)*50,...
%         'LineStyle', ':', 'Color', [0, 0, 0], 'HandleVisibility', 'off');
%     
%     for i = 1:length(pwin)
% 
%         prop(i, :) = mean(logfun(pwin, midpoints(:,i), beta1));
%         
%         hold on
%         
%         
%         lin3 = plot(...
%             pwin(isfinite(prop(i, :))).*100,  prop(i,isfinite(prop(i, :))).*100,...
%             'Color', green, 'LineWidth',1.5...% 'LineStyle', '--' ...
%             );
%         
%         
%         %lin3.Color(4) = alpha(i);
%         
%         hold on      
%         
%         [xout, yout] = intersections(lin3.XData, lin3.YData, lin1.XData, lin1.YData);
%         try
%             xx(i) = xout;
%             yy(i) = yout;
%         catch
%             fprintf('Intersection p(%d): No indifferent point \n', pwin(i));
%             
%         end
%         sc2 = scatter(xout, yout, 15, 'MarkerFaceColor', lin3.Color,...
%             'MarkerEdgeColor', 'w');
%         sc2.MarkerFaceAlpha = alpha(i);
%         
%         if num == 1
%             ylabel('P(choose E-option) (%)');
%         end
%         xlabel('E-option p(win) (%)');
%         
%         ylim([-0.08*100, 1.08*100]);
%         xlim([-0.08*100, 1.08*100]);
%         xticks(0:20:100)
% 
%         box off
%     end
%     
% 
%     set(gca,'TickDir','out')
%     set(gca, 'FontSize', fontsize);
% 

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

 