%-------------------------------------------------------------------------%
init;
show_current_script_name(mfilename('fullpath'));

%-------------------------------------------------------------------------%
% parameters of the script                                                %
%-------------------------------------------------------------------------%
selected_exp = [5,6.2];%, 6.2, 7.1, 7.2];
displayfig = 'off';
zscored = 1;

num = 0;
%
ed = cell(length(selected_exp),1);
pm = cell(length(selected_exp), 1);
mean_heur = cell(length(selected_exp), 1);


for exp_num = selected_exp
    
    num = num + 1;
    
    %---------------------------------------------------------------------%
    % get data parameters                                                 %
    % --------------------------------------------------------------------%   
    throw = de.extract_ED(exp_num);
    symp = unique(throw.p1);
    lotp = unique(throw.p2);
    
    if zscored
        de.zscore_RT(exp_num);
    end
    data = de.extract_ED(exp_num);
    
    for sub = 1:data.nsub
        for i = 1:length(symp)
            ed{num}(sub,i) = -nanmean(data.rtime(sub, logical(...
                (data.p1(sub,:)==symp(i)).*(data.cho(sub,:)==1))) );     
        end
    end
    
    data = de.extract_EE(exp_num);
    
    for sub = 1:data.nsub
        for i = 1:length(symp)
            ee{num}(sub,i) = -nanmean(data.rtime(sub, logical(...
                (data.p1(sub,:)==symp(i)).*(data.cho(sub,:)==1) +...
                (data.p2(sub,:)==symp(i)).*(data.cho(sub,:)==2))));     
        end
    end
    
    sim_params.de = de;
    sim_params.sess = data.sess;
    sim_params.exp_name = data.name;
    sim_params.exp_num = data.exp_num;
    sim_params.nsub = data.nsub;
    sim_params.model = 1;
    
    [Q, tt] = get_qvalues(sim_params);
    le{num,1} = Q; 
%              
    sim_params.model = 2;
    [Q, tt] = get_qvalues(sim_params);

    pm{num,1} = Q;
    
%     param = load(...
%         sprintf('data/post_test_fitparam_EE_exp_%d_%s',...
%         round(exp_num), num2str(sess)));
%     Q = param.midpoints;
% 
%     ee{num,1} = mean(argmax_estimate(data, symp, lotp, Q),2); 



end

%-------------------------------------------------------------------------%
% plot                                                                    %
% ------------------------------------------------------------------------%

%x1 = reshape(vertcat(mean_heur{:}), [], 1);
x1 = reshape(vertcat(le{:}), [], 1);
x2 = reshape(vertcat(pm{:}), [], 1);

y1 = reshape(vertcat(ed{:}), [],1);
y2 = reshape(vertcat(ee{:}), [],1);


figure('Position', [0, 0, 1500, 1600], 'visible', 'on', 'Renderer', 'painter');
subplot(2,2, 1)

scatterCorr(x1, y1, orange_color, .5, 1, 50, 'w', 0);
xlabel('LE estimates');
%xlim([.2, 1.08])
ylabel('-RT ED (ms)');
box off
set(gca, 'tickdir', 'out');

subplot(2,2, 2)

scatterCorr(x2, y1, orange_color, .5, 1, 50, 'w', 0);
xlabel('PM estimates');
ylabel('-RT ED (ms)');
%xlim([.2, 1.08])

box off
set(gca, 'tickdir', 'out');
subplot(2,2, 3)

scatterCorr(x1, y2, green_color, .5, 1, 50, 'w', 0);
xlabel('LE estimates');
%xlim([.2, 1.08])
ylabel('-RT EE (ms)');
box off
set(gca, 'tickdir', 'out');

subplot(2,2, 4)

scatterCorr(x2, y2, green_color, .5, 1, 50, 'w', 0);
xlabel('PM estimates');
ylabel('-RT EE (ms)');
%xlim([.2, 1.08])

box off
set(gca, 'tickdir', 'out');

% subplot(1,3, 3)
% 
% scatterCorr(x3, y, magenta_color, .5, 1, 50, 'w', 0);
% xlabel('PM estimates-explained score');
% ylabel('-RT (ms)');
% xlim([.2, 1.08])
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


suptitle(sprintf('Estimates predict -RT (ms) / Pooled Exp. %.1f', selected_exp(:)));

saveas(gcf, 'fig/score_RT_1234.svg');


% ------------------------------------------------------------------------%

function score = heuristic(data, symp,lotp)

    for sub = 1:size(data.cho,1)
        count = 0;

        for j = 1:length(symp)
            
            for k = 1:length(lotp)
                count = count + 1;
                actual_choice = data.cho(sub, logical(...
                    (data.p1(sub,:)==symp(j)).*(data.p2(sub,:)==lotp(k))));
                
                if lotp(k) >= .5 
                    prediction = 2;
                else
                    prediction = 1;
                end
                
               score(sub, count) = prediction == actual_choice;
               
            end
        end
    end
    
end


function score = argmax_estimate(data, symp, lotp, values)

    for sub = 1:size(data.cho,1)
        count = 0;

        for j = 1:length(symp)
            
            for k = 1:length(lotp)
                count = count + 1;
                actual_choice = data.cho(sub, logical(...
                    (data.p1(sub,:)==symp(j)).*(data.p2(sub,:)==lotp(k))));
                
                if lotp(k) >= values(sub,j)
                    prediction = 2;
                else
                    prediction = 1;
                end
                
               score(sub, count) = prediction == actual_choice;
            end
        end
    end
    
end


        