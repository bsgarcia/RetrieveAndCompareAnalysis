%-------------------------------------------------------------------------
init;
%-------------------------------------------------------------------------

selected_exp = [1, 2, 3, 4];
sessions = [0, 1];

displayfig = 'off';

figure('Renderer', 'painters',...
    'Position', [145,157,3312,600], 'visible', displayfig)

num = 0;
for exp_num = selected_exp
    num = num + 1;
    
    clear qvalues b pY2 ind_point Y
    
    idx1 = (exp_num - round(exp_num)) * 10;
    idx1 = idx1 + (idx1==0);
    sess = sessions(uint64(idx1));
    % load data
    name = char(filenames{round(exp_num)});
    
    data = d.(name).data;
    sub_ids = d.(name).sub_ids;
    nsub = d.(name).nsub;
    
    [corr, cho, out, p1, p2, ev1, ev2, ctch, cont1, cont2, dist, rtime] = ...
        DataExtraction.extract_estimated_probability_post_test...
        (data, sub_ids, idx, sess);
    
    for sub = 1:nsub
        i = 1;
        
        for p = unique(p1)'
            qvalues(sub, i) = cho(sub, (p1(sub, :) == p))./100;
            i = i + 1;
        end
    end
        
    ev = unique(p1);
    varargin = ev;
    x_values = ev;
    x_lim = [0, 1];
   
    
    subplot(1, length(selected_exp), num)
    
    add_linear_reg(qvalues.*100, ev.*100, magenta_color);
    brickplot2(...
        qvalues'.*100,...
        magenta_color.*ones(length(ev), 1),...
        [0, 100], 11,...
        '',...
        '',...
        '', varargin.*100, 1, x_lim.*100, x_values.*100, .18);
    
    if num == 1
        ylabel('Estimated probability (%)');
    end
    
    xlabel('Symbol p(win) (%)');

    box off
    hold on
    
    %set(gca, 'ytick', [0:10]./10);
    set(gca,'TickDir','out')
    set(gca, 'fontsize', fontsize);
    
    clear pp p_lot p_sym temp err_prop prop i p1 p2 cho
    
        
end

mkdir('fig/exp', 'post_test_PM');
        saveas(gcf, ...
            sprintf('fig/exp/post_test_PM/full.svg',...
            num2str(exp_num)));