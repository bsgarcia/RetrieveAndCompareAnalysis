%-------------------------------------------------------------------------%
init;
show_current_script_name(mfilename('fullpath'));

%-------------------------------------------------------------------------%
% parameters of the script                                                %
%-------------------------------------------------------------------------%
selected_exp = [5,6.1,6.2];%, 6.2, 7.1, 7.2];
displayfig = 'on';
colors = [orange_color; orange_color; green_color];
zscored = 0;

num = 0;

mean_heur = cell(length(selected_exp), 1);
lotp = [0, .1, .2, .3, .4, .5,.6, .7, .8, .9, 1];
sub_count = 0;
for exp_num = selected_exp
    
    num = num + 1;
    
    %---------------------------------------------------------------------%
    % get data parameters                                                 %
    % --------------------------------------------------------------------%
    sess = de.get_sess_from_exp_num(exp_num);
    name = de.get_name_from_exp_num(exp_num);
    nsub = de.get_nsub_from_exp_num(exp_num);
    
    data_ed = de.extract_ED(exp_num);
    data_ee = de.extract_EE(exp_num);
    
    for sub = 1:nsub
        mask_lot = (ismember(data_ed.p2(sub,:), lotp));
        mask_cho1 = (data_ed.cho(sub,:)==1);
        mask_cho2 = (data_ed.cho(sub,:)==2);
        e(sub+sub_count) = median(data_ed.rtime(sub, logical(mask_lot.*mask_cho1)));
        d(sub+sub_count) = median(data_ed.rtime(sub, logical(mask_lot.*mask_cho2)));

        ee(sub+sub_count) = median(data_ee.rtime(sub,:));
    end
    
    sub_count = sub_count + sub;

end

figure('Units', 'centimeters',...
    'Position', [0,0,5.3, 5.3/1.25], 'visible', displayfig)

if zscored
    y1 = -3;
    y2 = 1;
else
    y1 = 0;
    y2 = 6500;
end


x1 = e';
x2 = d';
x3 = ee';

labely = 'Median reaction time per subject';
    
skylineplot({x1'; x2'; x3'}, 5,...
    colors,...
    y1,...
    y2,...
    fontsize,...
    '',...
    '',...
    labely,...
    {'ED_{e}', 'ED_{d}', 'EE'});

set(gca, 'tickdir', 'out');
box off;
return

% %-------------------------------------------------------------------------%
% % plot                                                                    %
% % ------------------------------------------------------------------------%
% 
% x1 = reshape(vertcat(o_heur{:}), [], 1);
% x2 = reshape(vertcat(o_le{:}), [], 1);
% x4 = reshape(vertcat(none{:}), [], 1);
% x3 = reshape(vertcat(both{:}), [], 1);
% 
% y = reshape(vertcat(ed{:}), [],1);
% 
% 

% subplot(1,3, 1)
% 
% scatterCorr(x1, y, orange_color, .5, 1, 50, 'w', 0);
% xlabel('Heuristic-explained score');
% %xlim([.2, 1.08])
% ylabel('-RT (ms)');
% box off
% set(gca, 'tickdir', 'out');
% 
% subplot(1,3, 2)
% 
% scatterCorr(x2, y, blue_color, .5, 1, 50, 'w', 0);
% xlabel('LE estimates-explained score');
% ylabel('-RT (ms)');
% %xlim([.2, 1.08])
% 
% box off
% set(gca, 'tickdir', 'out');
% 
% subplot(1,3, 3)
% 
% scatterCorr(x3, y, magenta_color, .5, 1, 50, 'w', 0);
% xlabel('PM estimates-explained score');
% ylabel('-RT (ms)');
% %xlim([.2, 1.08])
% 
% box off
% set(gca, 'tickdir', 'out');

% subplot(1,4, 4)
% 
% scatterCorr(x4, y, green_color, .5, 1, 50, 'white', 0);
% xlabel('EE estimates-explained score');
% ylabel('-RT (ms)');
% xlim([0, 1.08])
% 
% box off
% set(gca, 'tickdir', 'out');


suptitle('Pooled Exp. 5,6.1,6.2,7.1,7.2');

saveas(gcf, 'fig/score_RT_1234.svg');


% ------------------------------------------------------------------------%

function score = heuristic(data, symp,lotp)

for sub = 1:size(data.cho,1)
    count = 0;
    
    for t = 1:size(data.cho,2)
        
        count = count + 1;
        
        if data.p2(sub,t) >= .5
            prediction = 2;
        else
            prediction = 1;
        end
        
        score(sub, count) = prediction;
        
    end
end
end


function score = argmax_estimate(data, symp, lotp, values)
for sub = 1:size(data.cho,1)
    count = 0;
    
    for t = 1:size(data.cho,2)
        
        count = count + 1;
        
        if data.p2(sub,t) >= values(sub, symp==data.p1(sub,t))
            prediction = 2;
        else
            prediction = 1;
        end
        
        score(sub, count) = prediction;
        
    end
end
end




        