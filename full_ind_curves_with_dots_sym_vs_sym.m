init;   

selected_exp = [4, 5.1, 5.2,  6.1, 6.2, 7.1,  7.2];
selected_exp = selected_exp(end-1);
displayfig = 'on';
sessions = [0, 1];
def = 0;
nagent = 100;

for exp_num = selected_exp
    

    idx1 = (exp_num - round(exp_num)) * 10;
    idx1 = idx1 + (idx1==0);
    sess = sessions(uint64(idx1));
   
   
    % load data
    name = char(filenames{round(exp_num)});

    data = d.(name).data;
    sub_ids = d.(name).sub_ids;
    
    [corr, cho, out2, p1, p2, ev1, ev2, ctch, cont1, cont2, dist] = ...
        DataExtraction.extract_sym_vs_sym_post_test(...
            data, sub_ids, idx, sess);
    nsub = size(cho, 1);
    
    % ----------------------------------------------------------------------
    
    % Compute for each symbol p of chosing depending on described cue value
    % ------------------------------------------------------------------------
  
    pcue = unique(p2)';
    psym = unique(p1)';
    
    chose_symbol = zeros(d.(name).nsub, length(pcue), length(psym), 1);
    for i = 1:nsub
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
    
    X = reshape(...
        repmat(pcue, size(k, 2), size(chose_symbol, 4)), [], 1....
    );

    pp = zeros(length(psym), length(pcue));
    
    for i = 1:length(psym)
        Y = reshape(chose_symbol(k, :, i, :), [], 1);
        [logitCoef, dev] = glmfit(...
            X, Y, 'binomial','logit');
        pp(i, :) = glmval(logitCoef, pcue', 'logit');
    end
    
    figure(...
        'Renderer', 'painters',...
        'Position', [961, 1, 900, 550],...
        'visible', displayfig)
    
    pwin = psym;
    alpha = [fliplr(linspace(.3, 1, 4)), linspace(.3, 1, 4)];
    
    lin1 = plot(...
        linspace(0, 1, 12), ones(12)*0.5,...
        'LineStyle', ':', 'Color', [0, 0, 0], 'HandleVisibility', 'off');
    
    for i = 1:length(pwin)
        
        if ~ismember(i, [1, 8])
            continue
        end
%         
        if pwin(i) < .5
            color = red_color;
        else
            color = blue_color;
        end
        
        hold on
        
        pcue1 = pcue;
        pcue1(i) = [];
        prop1 = prop(i, :);
        prop1(i) = [];
        
        lin3 = plot(...
                pcue1,  prop1,... 
                'Color', color, 'LineWidth', 4.5 ...
                );
        
        lin3.Color(4) =  0;
        
        sc1 = scatter(pcue, prop(i, :), 180,...
            'MarkerEdgeColor', 'w',...
            'MarkerFaceColor', color, 'MarkerFaceAlpha', 0.65);
        hold on
        errorbar(sc1.XData, prop(i, :), err_prop(i, :), 'Color', color, 'LineStyle', 'none', 'LineWidth', 1.7);%, 'CapSize', 2);
        hold on         
        ylabel('P(choose experienced cue)', 'FontSize', 26);
        xlabel('Experienced cue win probability', 'FontSize', 26);
        
        ylim([-0.08, 1.08]);
        xlim([-0.08, 1.08]);
%         
%         text(...
%                 ind_point + (0.05) * (1 + (-4 * (i == 1))) ,...
%                 .55, sprintf('%.2f', ind_point), 'Color', 'k', 'FontSize', 25);
        
        box off
        set(gca, 'Fontsize', 23);
        
        %plot(pwin(i) .*  ones(10, 1), linspace(.2, .8, 10), 'Color', color, 'LineStyle', ':', 'LineWidth', 5);
        disp(pwin(i));
        hold on
        
    end

%     s1 = title(titles{exp_num});
%     set(s1, 'Fontsize', 20)
    set(gca,'TickDir','out')
    
    clear pp pcue psym temp err_prop prop i

    [cho, cont1, cont2, p1, p2, ev1, ev2] = sim_exp_EE(name, d, idx, sess, def, nagent);
    
    nsub = size(cho, 1);
    
    % ----------------------------------------------------------------------
    
    % Compute for each symbol p of chosing depending on described cue value
    % ------------------------------------------------------------------------
  
    pcue = unique(p2)';
    psym = unique(p1)';
    
    chose_symbol = zeros(d.(name).nsub, length(pcue), length(psym), 1);
    for i = 1:nsub
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
    
    X = reshape(...
        repmat(pcue, size(k, 2), size(chose_symbol, 4)), [], 1....
    );

    pp = zeros(length(psym), length(pcue));
    
    for i = 1:length(psym)
        Y = reshape(chose_symbol(k, :, i, :), [], 1);
        [logitCoef, dev] = glmfit(...
            X, Y, 'binomial','logit');
        pp(i, :) = glmval(logitCoef, pcue', 'logit');
    end
    
    pwin = psym;
    alpha = [fliplr(linspace(.3, 1, 4)), linspace(.3, 1, 4)];
    
    lin1 = plot(...
        linspace(0, 1, 12), ones(12)*0.5,...
        'LineStyle', ':', 'Color', [0, 0, 0], 'HandleVisibility', 'off');
    
    for i = 1:length(pwin)
        
        if ~ismember(i, [1, 8])
            continue
        end
%         
        if pwin(i) < .5
            color = red_color;
        else
            color = blue_color;
        end
        
        hold on
        
        pcue1 = pcue;
        pcue1(i) = [];
        prop1 = prop(i, :);
        prop1(i) = [];
        
        lin3 = plot(...
                pcue1,  prop1,... 
                'Color', color, 'LineWidth', 4.5 ...
                );
        
        lin3.Color(4) =  0.5;
        box off
        
    end
    
    clear pp pcue psym temp err_prop prop i

%     s1 = title(titles{exp_num});
%     set(s1, 'Fontsize', 20)
    set(gca,'TickDir','out')
%   
    title(sprintf('Exp. %s', num2str(exp_num)));
    mkdir('fig/exp', 'ind_curves');
    saveas(gcf, ...
        sprintf('fig/exp/ind_curves/exp_%s_sym_vs_sym.png',...
        num2str(exp_num)));
    
%     exp_num = exp_num + 1;
%     
    
end

