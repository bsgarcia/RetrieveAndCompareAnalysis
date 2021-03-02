%-------------------------------------------------------------------------%
init;
show_current_script_name(mfilename('fullpath'));
%-------------------------------------------------------------------------%

%-------------------------------------------------------------------------%
% parameters of the script                                                %
%-------------------------------------------------------------------------%
selected_exp = [5, 6.1, 6.2];%, 6.2, 7.1, 7.2];
displayfig = 'off';

%-------------------------------------------------------------------------%
% prepare data                                                            %
%-------------------------------------------------------------------------%
x = 'chosen_pwin';
zscored = 0;

ee = cell(50, 1);
ed = cell(50, 1);

for exp_num = selected_exp
    num = num + 1;
    %---------------------------------------------------------------------%
    % get data parameters                                                 %
    % --------------------------------------------------------------------%
    sess = de.get_sess_from_exp_num(exp_num);
    name = de.get_name_from_exp_num(exp_num);
    nsub = de.get_nsub_from_exp_num(exp_num);
            
    if zscored
        de.zscore_RT(exp_num);
    end
        
    switch x
            case 'pavlovian'
                sum_ev = unique(round(data.ev1+data.ev2, 1));
          
                X = sum_ev;
                for i = 1:length(sum_ev)
                    dd{i} = [dd{i}; -data.rtime(round(data.p1+data.p2, 1)==sum_ev(i))];           
                end
            
            case 'difficulty'
                abs_ev = unique(round(abs(data.ev1-data.ev2), 1));
                        
                X = abs_ev;
                for i = 1:length(abs_ev)
                    dd{i} = [dd{i}; -data.rtime(...
                        round(abs(data.ev1-data.ev2), 1)==abs_ev(i)...
                        )];            
                end
            case 'chosen_pwin'
                sym_p = unique([data.p1 data.p2]);
                X = sym_p;
       
                for i = 1:length(sym_p)
                    dd{i} = [dd{i}; -data.rtime(logical(...
                        (data.cho==1).*(data.p1==sym_p(i)) + (data.cho==2).*(data.p2==sym_p(i))))];            

                end
                
            case 'pwin'
                sym_p = unique([data.p1 data.p2]);
                X = sym_p;

                for i = 1:length(sym_p)
                    dd{i} = [dd{i, :}; -data.rtime(logical(...
                        (data.p1==sym_p(i)) + (data.p2==sym_p(i))))];            

                end
            end
        
                % get data depending on chosen modality
        switch (modalities{mod_num})
            case 'EE'
                ee = dd;
            case 'ED'
                ed = dd;
        end
        
    end
        
end
    
 
%-------------------------------------------------------------------------%
% Save fig and stats                                                      %
% ------------------------------------------------------------------------%
% save fig
ed = ed(~cellfun('isempty',ed));
ee = {ee{1:length(ed)}}';

varrgin = X;
x_values = 5:100/length(X):110;
x_lim = [0 100];

figure('Position', [0, 0, 1350, 800], 'visible', 'off')
subplot(1, 2, 1)

if zscored
    y_lim = [-2, 2];
else
    y_lim = [-3000, -500];
end

brickplot(ed, orange_color.*ones(length(ed),1), y_lim, fontsize+5, 'ED', x, '-RT (ms)', varrgin, 1, x_lim, x_values,.18);
 set(gca, 'tickdir', 'out');
box off

subplot(1, 2, 2)

brickplot(ee, green_color.*ones(length(ee),1), y_lim, fontsize+5,...
    'EE', 'p(win)', '-RT (ms)', varrgin, 1, x_lim, x_values,.18);

 set(gca, 'tickdir', 'out');
box off


suptitle('Pooled exp. 5, 6.1, 6.2');


mkdir('fig/exp', figfolder);
saveas(gcf, figname);

% % save stats file
% mkdir('data', 'stats');
% writetable(stats_data, stats_filename);

function arr = normalize(arr)
arr = (arr - min(arr(:)))./(max(arr(:))-min(arr(:)));
end

function arr = flatten()
% for i = 1:length(ev)
%    x1{i} = ev(i).* ones(size(ed{i}));
%    x2{i} = ev(i).* ones(size(ee{i}));
% end
% x1 = vertcat(x1{:});
% y1 = vertcat(ed{:});
% x2 = vertcat(x2{:});
% y2 = vertcat(ee{:});
arr = 1;
end