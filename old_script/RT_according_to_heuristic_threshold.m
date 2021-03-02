%-------------------------------------------------------------------------%
init;
show_current_script_name(mfilename('fullpath'));
%-------------------------------------------------------------------------%

%-------------------------------------------------------------------------%
% parameters of the script                                                %
%-------------------------------------------------------------------------%
selected_exp = [5, 6.1, 6.2];%, 6.2, 7.1, 7.2];
modalities = {'ED', 'EE'};
displayfig = 'off';
colors = [orange_color;orange_color;orange_color;green_color;magenta_color];

%-------------------------------------------------------------------------%
% prepare data                                                            %
%-------------------------------------------------------------------------%
% stats_data is table that is used to compute stats later
stats_data = table();

% filenames
% name = modality1_modality2_modalityN
filename = [cell2mat(strcat(modalities(1:end-1), '_')), modalities{end}];
figfolder = 'violinplot';

figname = sprintf('fig/exp/%s/RT_%s.svg', figfolder, filename);
stats_filename = sprintf('data/stats/RT_%s.csv', filename);

figure('Renderer', 'painters','Units', 'centimeters',...
    'Position', [0,0,5.3*length(selected_exp), 5.3/1.25], 'visible', displayfig)

num = 0;
sub_count = 0;
%
ee = cell(8, 1);
ed = cell(10,1);
e = cell(8,1);
d = cell(8,1);

for exp_num = selected_exp
    num = num + 1;
    %---------------------------------------------------------------------%
    % get data parameters                                                 %
    % --------------------------------------------------------------------%
    sess = de.get_sess_from_exp_num(exp_num);
    name = de.get_name_from_exp_num(exp_num);
    nsub = de.get_nsub_from_exp_num(exp_num);
    throw = de.extract_ED(exp_num);
    symp = unique(throw.p1);
    lotp = unique(throw.p2);
    sum_ev = unique(round(abs(throw.ev1 - throw.ev2),1));
    
    heur = heuristic(throw, symp, lotp);
    ids = find(mean(heur,2)<.8);
    ids = 1:nsub;
    
    for mod_num = 1:length(modalities)
        
        % get data depending on chosen modality
        switch (modalities{mod_num})
            
            case 'LE'
                data = de.extract_LE(exp_num);
                le = mean(data.rtime, 2);
                dd = le;
                
            case 'EE'
                data = de.extract_EE(exp_num);
                data.rtime = data.rtime(ids,:);
                data.p1 = data.p1(ids,:);
                data.p2 = data.p2(ids,:);
                data.cho = data.cho(ids,:);
%                 
%                 for i = 1:size(data.rtime,1)
%                     data.rtime(i, :) = zscore(data.rtime(i,:));
%                 end
                for i = 1:length(symp)
%                     ee{i} = [ee{i,:}; -data.rtime(logical(...
%                         ((data.cho==1).*(data.p1==symp(i)) + ((data.cho==2).*(data.p2==symp(i))))))];
                     ee{i} = [ee{i,:}; -data.rtime(logical(...
                         (data.p1==symp(i))+(data.p2==symp(i))))];
                    
                end
            
            case 'ED'
                data = de.extract_ED(exp_num);
                data.rtime = data.rtime(ids,:);
                data.p1 = data.p1(ids,:);
                data.p2 = data.p2(ids,:);
                data.cho = data.cho(ids,:);

%                 for i = 1:size(data.rtime,1)
%                     data.rtime(i, :) = zscore(data.rtime(i,:));
%                 end
                for i = 1:length(symp)
%                     ed{i} =  [ed{i,:}; -data.rtime(logical(...
%                         ((data.cho==1).*(data.p1==symp(i)) + ((data.cho==2).*(data.p2==symp(i))))))];
                     %ed{i} = [ed{i,:}; -data.rtime(round(abs(data.ev1-data.ev2),1)==sum_ev(i))];
                     e{i} = [e{i,:}; -data.rtime(logical(...
                          data.p1==symp(i).*(data.cho==1)))];
                     d{i} = [d{i,:}; -data.rtime(logical(...
                          data.p2==symp(i).*(data.cho==2)))];

                end
                
            case 'ED_e'
                data = de.extract_ED(exp_num);
                for i = 1:length(symp)
                    e(i) = mean(data.rtime(i,data.cho(i,:) == 1),2);
                end
                
            case 'ED_d'
                data = de.extract_ED(exp_num);
                for i = 1:nsub
                    d(i) = mean(data.rtime(:,data.cho(i,:) == 2),2);
                end
                dd = d;
                
            case 'PM'
                data = de.extract_PM(exp_num);
                if size(data.rtime, 2) == 0
                    pm = zeros(size(data.rtime, 1), 1)';
                else
                    pm = mean(data.rtime, 2);
                end
                
        end
        %
        %         for sub = 1:nsub
        %             T1 = table(...
        %                 sub+sub_count, num, dd(sub),...
        %                 {modalities{mod_num}}, 'variablenames',...
        %                 {'subject', 'exp_num', 'slope', 'modality'}...
        %                 );
        %             stats_data = [stats_data; T1];
        %         end
    end
    %     sub_count = sub_count+sub;
    
    %---------------------------------------------------------------------%
    % Plot                                                                %
    % --------------------------------------------------------------------%
    
    
    
    %     skylineplot([e; d; ed';ee'], 4.5,...
    %         colors,...
    %         -.08,...
    %         8000,...
    %         fontsize,...
    %         '',...
    %         '',...
    %         '',...
    %         modalities,...
    %         0);
    
    
end
%-------------------------------------------------------------------------%
% Save fig and stats                                                      %
% ------------------------------------------------------------------------%
% save fig

% ev = sum_ev;
% varrgin = ev;
% x_values = 1:100/length(ev):100;
% x_lim = [-10 100];
% figure('Position', [0, 0, 1600, 800], 'visible', 'off');
% subplot(1, 2, 1)
% 
% for i = 1:length(ev)
%    x1{i} = ev(i).* ones(size(ed{i}));
%    x2{i} = ev(i).* ones(size(ee{i}));
% end
% x1 = vertcat(x1{:});
% y1 = vertcat(ed{:});
% x2 = vertcat(x2{:});
% y2 = vertcat(ee{:});
% 

ev = symp;
varrgin = ev;
x_values = 5:100/length(ev):110;
x_lim = [0 100];
figure('Position', [0, 0, 1350, 800], 'visible', 'off');
subplot(1, 3, 1)
for i = 1:length(ev)
    x1{i} = ev(i).* ones(size(e{i}));
%    x2{i} = ev(i).* ones(size(ee{i}));
end
% x1 = vertcat(x1{:});
% y1 = vertcat(ed{:});
% x2 = vertcat(x2{:});
% y2 = vertcat(ee{:});

%y_mean = mean(ed')';
brickplot(e, orange_color.*ones(length(e),1), [-2500,-500], fontsize+5, 'E_{chosen}', 'p(win)', '-RT (ms)', varrgin, 0, x_lim, x_values,.18);
 set(gca, 'tickdir', 'out');

 box off

subplot(1, 3, 2)

brickplot(d, orange_color.*ones(length(d),1), [-2500,-500], fontsize+5, 'D_{chosen}', 'p(win)', '-RT (ms)', varrgin, 0, x_lim, x_values,.18);
 set(gca, 'tickdir', 'out');
box off




subplot(1, 3, 3)
brickplot(ee, green_color.*ones(length(ee),1), [-2500,-500], fontsize+5,...
    'EE', 'p(win)', '-RT (ms)', varrgin, 0, x_lim, x_values,.18);


set(gca, 'tickdir', 'out');
box off

suptitle('Pooled exp. 5, 6.1, 6.2 (CHOSEN OPTION VALUE)');
%y_mean = mean(ed')';
% brickplot(ed, orange_color.*ones(length(ed),1), [-3000,-1000], fontsize+5, 'ED', 'abs(EV1-EV2)', '-RT (ms)', varrgin, 0, x_lim, x_values,.18);
%  set(gca, 'tickdir', 'out');
% box off
% 
% 
% 
% subplot(1, 2, 2)
% brickplot(ee, green_color.*ones(length(ee),1), [-3000,-1000], fontsize+5,...
%     'EE', 'abs(EV1-EV2)', '-RT (ms)', varrgin, 0, x_lim, x_values,.18);
% 
% 
% set(gca, 'tickdir', 'out');
% box off
% 
% suptitle('Pooled exp. 5, 6.1, 6.2');
% 
% 
% mkdir('fig/exp', figfolder);
% saveas(gcf, figname);
% 
% save stats file
% mkdir('data', 'stats');
% writetable(stats_data, stats_filename);

function arr = normalize(arr)
arr = (arr - min(arr(:)))./(max(arr(:))-min(arr(:)));
end

function heur = heuristic(data, symp,lotp)
    for i = 1:size(data.cho,1)
             count = 0;

        for j = 1:length(symp)
            
            for k = 1:length(lotp)
                count = count + 1;
                temp = data.cho(i, logical((data.p1(i,:)==symp(j)).*(data.p2(i,:)==lotp(k))));
                
                if lotp(k) >= .5 
                    pred = 2;
                else
                    pred = 1;
                end
               heur(i, count) = pred == temp;
            end
        end
    end
end

        