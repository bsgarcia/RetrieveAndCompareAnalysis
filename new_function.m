%-------------------------------------------------------------------------
init;
%-------------------------------------------------------------------------

selected_exp = [3];

displayfig = 'off';
sessions = [0, 1];

figure('Renderer', 'painters',...
    'Position', [145,157,1200,900], 'visible', 'on')

for exp_num = selected_exp
    
    idx1 = (exp_num - round(exp_num)) * 10;
    idx1 = idx1 + (idx1==0);
    sess = sessions(uint64(idx1));
    
    % load data
    name = char(filenames{round(exp_num)});
    
    data = d.(name).data;
    sub_ids = d.(name).sub_ids;
    
    [corr, cho, out2, p1, p2, ev1, ev2, ctch, cont1, cont2, dist] = ...
        DataExtraction.extract_sym_vs_lot_post_test(...
        data, sub_ids, idx, sess);
    
    % ----------------------------------------------------------------------
    % Compute for each symbol p of chosing depending on described cue value
    % ------------------------------------------------------------------------
    
    pcue = unique(p2)';
    psym = unique(p1)';
    
    chose_symbol = zeros(d.(name).nsub, length(pcue), length(psym), 1);
    for i = 1:d.(name).nsub
        for j = 1:length(pcue)
            for k = 1:length(psym)
                temp = ...
                    cho(i, logical((p2(i, :) == pcue(j)) .* (p1(i, :) == psym(k))));
                for l = 1:length(temp)
                    chose_symbol(i, j, k, l) = temp(l) == 1;
                end
            end
        end
    end
    
    nsub = size(cho, 1);
    k = 1:nsub;
    
    prop = zeros(length(psym), length(pcue));
    temp1 = cho(k, :);
    for j = 1:length(pcue)
        for l = 1:length(psym)
            temp = temp1(...
                logical((p2(k, :) == pcue(j)) .* (p1(k, :) == psym(l))));
            prop(l, j) = mean(temp == 1);
            err_prop(l, j) = std(temp == 1)./sqrt(length(temp));
            
        end
    end
    
    pp = zeros(nsub, length(psym), length(pcue));
    
    for sub = 1:nsub
        
        disp(sub);
        
        for i = 1:length(psym)
            Y(i, :) = reshape(chose_symbol(sub, :, i, 1), [], 1);
            X(i, :) = pcue-psym(i);
        end
        
        options = optimset(...
            'Algorithm',...
            'interior-point',...
            'Display', 'off',...
            'MaxIter', 10000,...
            'MaxFunEval', 10000);
        
        beta1(sub) = fmincon(...
            @(x) tofit(x, X, Y),...
            [1],...
            [], [], [], [],...
            [0],...
            [inf],...
            [],...
            options...
        );
        
        options = optimset('Display','off');
        
        for i = 1:length(psym)
            shift(sub, i) = lsqcurvefit(...
                @(shift, x) (fun(x, shift, beta1(sub))),...
                [0], X(i, :)', Y(i, :)', [-1], [1], options);
            pp(sub, i, :) = fun(X(i, :)', shift(sub, i), beta1(sub));
        end
        
    end
    
    for i = 1:length(psym)
        pp1(i, :) = mean(pp(:, i, :));
    end
    
    pwin = psym;
    
    alpha = linspace(.15, .95, length(psym));
    lin1 = plot(...
        linspace(psym(1), psym(end), 12), ones(12)*0.5,...
        'LineStyle', ':', 'Color', [0, 0, 0], 'HandleVisibility', 'off');
    hold on
    
    subplot(1, 2, 1)
    for i = 1:length(pwin)
               
        lin3 = plot(...
            pcue,  prop(i, :),...
            'Color', orange_color, 'LineWidth', 4.5...% 'LineStyle', '--' ...
            );
        
        lin3.Color(4) = alpha(i);
        
        hold on

        ylim([-0.08, 1.08]);
        xlim([-0.08, 1.08]);
        box off
    end

    
    subplot(1, 2, 2)
    for i = 1:length(pwin)
               
        lin3 = plot(...
            pcue,  pp1(i, :),...
            'Color', orange_color, 'LineWidth', 4.5...% 'LineStyle', '--' ...
            );
        
        lin3.Color(4) = alpha(i);
        
        hold on

        ylim([-0.08, 1.08]);
        xlim([-0.08, 1.08]);
        box off
        
    end
    
    set(gca,'TickDir','out')
    %set(gca, 'FontSize', fontsize);
    
    clear pp pcue psym temp err_prop prop i
    
end


function sumres = tofit(temp, X, Y)
    options = optimset('Display','off');
    for i = 1:size(Y, 1)
        [throw, throw2, residuals(i, :)] = lsqcurvefit(...
            @(shift, x) (fun(x, shift, temp)),...
            [0], X(i, :)', Y(i, :)', [-1], [1], options);

    end
    sumres = sum(residuals.*residuals, 'all');
end

function p = fun(x, shift, temp)
    p = 1./(1+exp(temp.*(x+shift(1))));
end