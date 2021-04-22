%-------------------------------------------------------------------------%
init;
show_current_script_name(mfilename('fullpath'));

%-------------------------------------------------------------------------%
% parameters of the script                                                %
%-------------------------------------------------------------------------%
selected_exp = [5, 6];
displayfig = 'on';
colors = [red; dark_blue; pink; black];

%

symp = [.1, .2, .3, .4, .6, .7, .8, .9];
%  
figure('Renderer', 'Painter', 'Units', 'centimeters',...
    'Position', [0,0,5.3*2, 5.3/1.25*2], 'visible', displayfig)

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
    
    data = de.extract_ED(exp_num);
 
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
            d = de.extract_ED(str2num(sprintf('%d.%d', exp_num, sess(i)+1)));
        else
            d = data;
        end
        
        [Q, tt] = get_qvalues(sim_params);

        le = [le argmax_estimate(d, symp, Q)];
        
    end
    
    for sub = 1:nsub
        s = sub + sub_count;
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
        
        dd = {o_heur(s,1); o_le(s,1);...
            both(s,1); none(s,1)};

        for mod_num = 1:4
                T1 = table(...
                    s, exp_num, dd{mod_num},...
                    {modalities{mod_num}}, 'variablenames',...
                    {'subject', 'exp_num', 'RT', 'modality'}...
                    );
                stats_data = [stats_data; T1];
        end
    end
    
    sub_count = sub_count + sub;
    
  
end


 y1 = 0;
y2 = 6500;
x1 = o_heur;
x2 = o_le;
x3 = both;
x4 = none;

labely = 'Median reaction time per subject';


skylineplot({x1'; x2'; x3'; x4'},  5*2, ...
    colors,...
    y1,...
    y2,...
    fontsize,...
    '',...
    'Choices exclusively explained by',...
    labely,...
    {'Heuristic', 'LE estimates', 'Both', 'None'});
set(gca, 'tickdir', 'out');
set(gca, 'fontsize', fontsize)
box off;

mkdir('fig', 'violinplot');
mkdir('fig/violinplot/', 'RT');
saveas(gcf, 'fig/violinplot/RT/explained.pdf');

% save stats file
mkdir('data', 'stats');
stats_filename = 'data/stats/RT_H_LE_BOTH_NONE.csv';
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




        