%-------------------------------------------------------------------------%
init;
show_current_script_name(mfilename('fullpath'));

%-------------------------------------------------------------------------%
% parameters of the script                                                %
%-------------------------------------------------------------------------%
selected_exp = [1, 2, 3, 4, 5, 6];
displayfig = 'on';
colors = [red; dark_blue; pink; black];

%filenames
filename = 'Fig5D';
figfolder = 'fig';

figname = sprintf('%s/%s.svg', figfolder, filename);
stats_filename = sprintf('data/stats/%s.csv', filename);

% %  
% figure('Renderer', 'Painter', 'Units', 'centimeters',...
%     'Position', [0,0,5.3, 5.3/1.25], 'visible', displayfig)

sub_count = 0;
stats_data = table();
num = 0;

for exp_num = selected_exp
    
    num = num + 1;
    
    
    %---------------------------------------------------------------------%
    % get data parameters                                                 %
    % --------------------------------------------------------------------%
    sess = de.get_sess_from_exp_num(exp_num);
    name = de.get_name_from_exp_num(exp_num);
    nsub = de.get_nsub_from_exp_num(exp_num);
    
    data = de.extract_ES(exp_num);
    symp = unique(data.p1);
    heur = heuristic(data);
    le = [];
    
    % get le q values estimates
    for i = 1:length(sess)
        sim_params.de = de;
        sim_params.sess = sess(i);
        sim_params.exp_name = name;
        sim_params.exp_num = exp_num;
        sim_params.nsub = nsub;
        sim_params.model = 1;
        
        if length(sess) == 2
            d = de.extract_ES(str2num(sprintf('%d.%d', exp_num, sess(i)+1)));
        else
            d = data;
        end
        
        [Q, tt] = get_qvalues(sim_params);

        le = [le argmax_estimate(d, symp, Q)];
        
    end
    
    for sub = 1:nsub
        s = sub + sub_count;
        
        S1 = mean(logical((...
                data.cho(sub,:)== heur(sub,:)) .* (data.cho(sub,:)~=le(sub,:))));
        S2 = mean(logical((...
                data.cho(sub,:)~= heur(sub,:)) .* (data.cho(sub,:)==le(sub,:))));
           
        o_heur(s,1) = median(...
            data.rtime(sub, logical((...
                data.cho(sub,:)== heur(sub,:)) .* (data.cho(sub,:)~=le(sub,:)))));
        o_le(s,1) = median(...
            data.rtime(sub,logical(...
            (data.cho(sub,:)~= heur(sub,:)) .* (data.cho(sub,:)==le(sub,:)))));
        
        none(s,1) = median(...
            data.rtime(sub,logical(...
            (data.cho(sub,:)~=heur(sub,:)).*(data.cho(sub,:)~=le(sub,:)))));
        both(s,1) = median(...
            data.rtime(sub,logical(...
            (data.cho(sub,:)==heur(sub,:)).*(data.cho(sub,:)==le(sub,:)))));
        
        modalities = {'heur', 'le', 'both', 'none'};
        
        %dd = {o_heur(s,1); o_le(s,1);...
        %    both(s,1); none(s,1)};
        
        %score = {S1, S2, NaN, NaN};
        rt2 = median(data.rtime(sub, :));
        
        %for mod_num = 1:4
            T1 = table(...
                s, exp_num, o_heur(s,1), {'H'}, ...
                 'variablenames',...
                {'subject', 'exp_num', 'RT', 'modality'}...
                );
            stats_data = [stats_data; T1];
      
            T1 = table(...
                s, exp_num, o_le(s,1), {'LE'}, ...
                 'variablenames',...
                {'subject', 'exp_num', 'RT', 'modality'}...
                );
             stats_data = [stats_data; T1];

    end
    
    sub_count = sub_count + sub;
    
  
end


y1 = 0;
y2 = 6500;
x1 = o_heur;
x2 = o_le;
x3 = both;
x4 = none;

labely = 'Median reaction time per subject (ms)';

% x = stats_data;
% x1 = x.S1;
% x2 =  x.S2;
% y1 = x.RT;
% y2 = x.RT;
% 
% 
% labelx = 'Heuristic score';
% subplot(1, 2, 1)
% scatterCorr(x1, y1, red, .6, 1, 2, 'w'); 
% % xlim([-0.05, .4])
% % ylim([300, 5000])
% xlabel(labelx);
% 
% set(gca, 'tickdir', 'out')
% 
% 
% labelx = 'LE estimates score';
% subplot(1, 2, 2)
% % ylim([300, 5000])
% labelx = 'LE estimates score';
% 
% scatterCorr(x2, y2, dark_blue, .6, 1, 2, 'w'); 
% xlabel(labelx);
% % xlim([-0.05, .4])
set(gca, 'tickdir', 'out')
figure('Units', 'centimeters',...
    'Position', [0,0,5.3, 5.3/1.25*1.2], 'visible', displayfig)
brickplot({x1; x2}, ...
    colors,...
    [1500, 2500],...
    fontsize,...
    'Exp. 1:6',...
    'Choices exclusively explained by',...
    labely,...
    {'Experiential neglect', 'LE estimates'}, 1, [0, 20], [5, 15], 1, 0);
% 
% skylineplot({x1'; x2'},  3, ...
%     colors,...
%     0,...
%     6500,...
%     fontsize,...
%     '',...
%     'Choices exclusively explained by',...
%     labely,...
%     {'Experiential neglect', 'LE estimates'});
set(gca, 'tickdir', 'out');
set(gca, 'fontsize', fontsize)
yticks(1500:200:2500)
set(gca, 'fontname', 'arial')
box off;

saveas(gcf, figname);

% save stats file
mkdir('data', 'stats');
writetable(stats_data, stats_filename);


% ------------------------------------------------------------------------%

function score = heuristic(data)

for sub = 1:size(data.cho,1)
    
    for t = 1:size(data.cho,2)
        
        
        if data.p2(sub,t) >= .5
            prediction = 2;
        else
            prediction = 1;
        end
        
        score(sub, t) = prediction;
        
    end
end
end


function score = argmax_estimate(data, symp, values)
for sub = 1:size(data.cho,1)
    
    for t = 1:size(data.cho,2)
        
        
        if data.p2(sub,t) >= values(sub, symp==data.p1(sub,t))
            prediction = 2;
        else
            prediction = 1;
        end
        
        score(sub, t) = prediction;
        
    end
end
end




        