%-------------------------------------------------------------------------%
init;
show_current_script_name(mfilename('fullpath'));
%-------------------------------------------------------------------------%

%-------------------------------------------------------------------------%
% parameters of the script                                                %
%-------------------------------------------------------------------------%
selected_exp = [5,6.1,6.2];%, 6.2, 7.1, 7.2];
displayfig = 'off';
x = 'lottery_{pwin}';
zscored = 1;

% ------------------------------------------------------------------------%
median = zscored ~= 1;


ed1 = cell(50, 1);
ed2 = cell(50, 1);

num = 0;

T = table();

sub_count = 0;
for exp_num = selected_exp
    num = num + 1;
  
    sess = de.get_sess_from_exp_num(exp_num);
    name = de.get_name_from_exp_num(exp_num);
    nsub = de.get_nsub_from_exp_num(exp_num);
    
    if zscored
        de.zscore_RT(exp_num);
    end
    
    data_ed = de.extract_EE(exp_num);
    ntrials = size(data_ed.cho, 2);

    % fill data for stats
    for i = 1:nsub
    T1 = table(...
            repelem(sub_count+i, ntrials)', (1:ntrials)',data_ed.p1(i,:)', data_ed.p2(i,:)', data_ed.rtime(i,:)',...
            'variablenames',...
            {'sub', 'trial' 'p1', 'p2', 'RT'}...
            );
    T = [T; T1];

    end
    sub_count = sub_count + nsub;
    
       
    [ed1, X1] = measure('symbol_{pwin}', data_ed, ed1);
    disp(ed1)
   
    %[ed2, X2] = measure('lottery_{pwin}', data_ed, ed2);
    
      
end

      

ed1 = ed1(~cellfun('isempty',ed1));

%-------------------------------------------------------------------------%
% plot fig                                             %
% ------------------------------------------------------------------------%

x_lim = [0 100];

if zscored
    y_lim = [-.5, .5];
else
    y_lim = [-2500, -500];
end

figure('Position', [0, 0, 1400, 800], 'visible', 'on')
subplot(1, 2, 1)


varrgin = X1;
x_values = 5:100/length(X1):110;

brickplot(ed1, green_color.*ones(length(ed1),1), y_lim, fontsize+5,...
    'E', 'symbol_{pwin}', 'zscore(-RT)', varrgin, 1, x_lim, x_values,.18, median);
set(gca, 'tickdir', 'out');
box off
% 
% 
% varrgin = X2;
% x_values = 5:100/length(X2):110;
% 
% subplot(1, 2, 2)
% brickplot(ed2, orange_color.*ones(length(ed2),1), y_lim, fontsize+5,...
%     'D', 'lottery_{pwin}', 'zscore(-RT)', varrgin, 1, x_lim, x_values,.18, median);
% 
% set(gca, 'tickdir', 'out');
% box off

suptitle('Pooled exp. 5,6.1,6.2');

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
                %                 ee{i} = [ee{i,:}; -data_ee.rtime(round(data_ee.ev1+data_ee.ev2, 1)==sum_ev(i))];

            end

        case 'abs(ev1-ev2)'
            abs_ev = unique(round(abs(data_ed.ev1-data_ed.ev2), 1));

            X = abs_ev;
            for i = 1:length(abs_ev)
                ed{i} = [ed{i,:}; -data_ed.rtime(...
                    round(abs(data_ed.ev1-data_ed.ev2), 1)==abs_ev(i)...
                    )];
                %                 ee{i} = [ee{i,:}; -data_ee.rtime(...
                %                     round(abs(data_ee.ev1-data_ee.ev2), 1)==abs_ev(i)...
                %                     )];
            end
        case 'chosenSymbol_{pwin}'
            sym_p = unique([data_ed.p1]);
            X = sym_p;

            for i = 1:length(sym_p)
                ed{i} = [ed{i}; -data_ed.rtime(logical(...
                    (data_ed.cho==1).*(data_ed.p1==sym_p(i))))];
                %                 ee{i} = [ee{i}; -data_ee.rtime(logical(...
                %                     (data_ee.cho==1).*(data_ee.p1==sym_p(i)) + (data_ee.cho==2).*(data_ee.p2==sym_p(i))))];
            end

        case 'symbol_{pwin}'
            sym_p = unique([data_ed.p1]);
            X = sym_p;

            for i = 1:length(sym_p)
                ed{i} = [ed{i, :}; -data_ed.rtime(logical(...
                    (data_ed.p1==sym_p(i))+(data_ed.p2==sym_p(i))))];
                %                 ee{i} = [ee{i, :}; -data_ee.rtime(logical(...
                %                     (data_ee.p1==sym_p(i)) + (data_ee.p2==sym_p(i))))];
                %
            end

        case 'lottery_{pwin}'
            sym_p = unique(data_ed.p2);
            X = sym_p;

            for i = 1:length(sym_p)
                ed{i} = [ed{i, :}; -data_ed.rtime(logical(...
                    (data_ed.p2==sym_p(i))))];
                %                 ee{i} = [ee{i, :}; -data_ee.rtime(logical(...
                %                     (data_ee.p1==sym_p(i)) + (data_ee.p2==sym_p(i))))];

            end
    end
%
end

