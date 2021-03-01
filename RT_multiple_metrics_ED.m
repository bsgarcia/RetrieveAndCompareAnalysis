%-------------------------------------------------------------------------%
init;
show_current_script_name(mfilename('fullpath'));
%-------------------------------------------------------------------------%

%-------------------------------------------------------------------------%
% parameters of the script                                                %
%-------------------------------------------------------------------------%
selected_exp = [1,2,3,5,6.1,6.2];
displayfig = 'off';
x = 'lottery_{pwin}';
zscored = 1;

% ------------------------------------------------------------------------%
median = zscored ~= 1;


ed1 = cell(50, 1);
ed2 = cell(50, 1);

num = 0;
sub_count = 0;

T = table();


for exp_num = selected_exp
    num = num + 1;
  
    sess = de.get_sess_from_exp_num(exp_num);
    name = de.get_name_from_exp_num(exp_num);
    nsub = de.get_nsub_from_exp_num(exp_num);
    
    if zscored
        de.zscore_RT(exp_num);
    end
    
    data_ed = de.extract_ED(exp_num);
    ntrials = size(data_ed.cho, 2);
    
    [ed1, X1] = measure('symbol_{pwin}', data_ed, ed1);
    
    [ed2, X2] = measure('lottery_{pwin}', data_ed, ed2);
    
    % fill data for stats
    for i = 1:nsub
        T1 = table(...
                repelem(sub_count+i, ntrials)', (1:ntrials)',...
                data_ed.p1(i,:)', data_ed.p2(i,:)', data_ed.rtime(i,:)',...
                'variablenames',...
                {'sub', 'trial' 'p1', 'p2', 'RT'}...
                );
        T = [T; T1];

    end
    sub_count = sub_count + nsub;
      
end

ed1 = ed1(~cellfun('isempty',ed1));
ed2 = ed2(~cellfun('isempty',ed2));

%-------------------------------------------------------------------------%
% plot fig                                             %
% ------------------------------------------------------------------------%

x_lim = [0 100];

if zscored
    y_lim = [-.3, .2];
else
    y_lim = [-2500, -500];
end

figure('Position', [0, 0, 1400, 800], 'visible', 'on')
subplot(1, 2, 1)


varrgin = X1;
x_values = 5:100/length(X1):110;

brickplot(ed1, orange_color.*ones(length(ed1),1), y_lim, fontsize+5,...
    'E', 'symbol_{pwin}', 'zscore(-RT)', varrgin, 1, x_lim, x_values,.18, median);
set(gca, 'tickdir', 'out');
box off


varrgin = X2;
x_values = 5:100/length(X2):110;

subplot(1, 2, 2)
brickplot(ed2, orange_color.*ones(length(ed2),1), y_lim, fontsize+5,...
    'D', 'lottery_{pwin}', 'zscore(-RT)', varrgin, 1, x_lim, x_values,.18, median);

set(gca, 'tickdir', 'out');
box off

suptitle('Pooled exp. 1,2,3,5,6.1,6.2');


%-------------------------------------------------------------------------%
% stats                                           
% ------------------------------------------------------------------------%
disp(fitglm(T, 'RT~p1+p2'));


%-------------------------------------------------------------------------%
% functions                                           
% ------------------------------------------------------------------------%
function [ed, X] = measure(x, data_ed, ed)

    switch x
        case 'pavlovian'
            sum_ev = unique(round(data_ed.ev1+data_ed.ev2, 1));

            X = sum_ev;
            for i = 1:length(sum_ev)
                ed{i} = [ed{i,:}; -data_ed.rtime(round(data_ed.ev1+data_ed.ev2, 1)==sum_ev(i))];

            end

        case 'abs(ev1-ev2)'
            abs_ev = unique(round(abs(data_ed.ev1-data_ed.ev2), 1));

            X = abs_ev;
            for i = 1:length(abs_ev)
                ed{i} = [ed{i,:}; -data_ed.rtime(...
                    round(abs(data_ed.ev1-data_ed.ev2), 1)==abs_ev(i)...
                    )];
               
            end
        case 'chosenSymbol_{pwin}'
            sym_p = unique([data_ed.p1]);
            X = sym_p;

            for i = 1:length(sym_p)
                ed{i} = [ed{i}; -data_ed.rtime(logical(...
                    (data_ed.cho==1).*(data_ed.p1==sym_p(i))))];
        
            end

        case 'symbol_{pwin}'
            sym_p = unique([data_ed.p1]);
            X = sym_p;

            for i = 1:length(sym_p)
                ed{i} = [ed{i, :}; -data_ed.rtime(logical(...
                    (data_ed.p1==sym_p(i))))];
          
                
            end

        case 'lottery_{pwin}'
            sym_p = unique(data_ed.p2);
            X = sym_p;

            for i = 1:length(sym_p)
                ed{i} = [ed{i, :}; -data_ed.rtime(logical(...
                    (data_ed.p2==sym_p(i))))];
      

            end
    end
%
end
