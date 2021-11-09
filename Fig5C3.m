%-------------------------------------------------------------------------%
init;
show_current_script_name(mfilename('fullpath'));

%-------------------------------------------------------------------------%
% parameters of the script                                                %
%-------------------------------------------------------------------------%
selected_exp = [5, 6];%, 6.2, 7.1, 7.2];
displayfig = 'on';
colors = [orange; orange];
zscored = 0;

stats_data = table();
full_rt = table();
%d = cell(11, 1);
%e = cell(8, 1);
% filenames
filename = 'Fig5C';
figfolder = 'fig';

figname = sprintf('%s/%s.svg', figfolder, filename);
stats_filename = sprintf('data/stats/%s.csv', filename);


num = 0;

lotp = [0, .1, .2, .3, .4, .5,.6, .7, .8, .9, 1];
symp = [.1, .2, .3, .4,.6, .7, .8, .9];
dd1 = cell(29, 1);
dde1 = cell(29, 1);
dd2 = cell(29, 1);
dde2 = cell(29, 1);
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
    
    mask_cho2 = data_ed.cho==2;
    mask_cho1 = data_ed.cho==1;

    data_ed.ev = NaN(size(data_ed.cho));
    data_ed.ev(data_ed.cho==1) = abs(data_ed.ev1(data_ed.cho==1)-data_ed.ev2(data_ed.cho==1));
    data_ed.ev(data_ed.cho==2) = abs(data_ed.ev2(data_ed.cho==2)-data_ed.ev1(data_ed.cho==2));
    evd1 = unique(data_ed.ev);


    for i = 1:length(evd1)
        dd1{i} = [dd1{i}; data_ed.rtime(data_ed.ev==evd1(i))];
        %dd{i} = [dd{i}, data_ed.rtime(data_ed.ev==data_ed.ev(i))'];

    end
    
    data_ed.ev = NaN(size(data_ed.cho));
    data_ed.ev(data_ed.cho==1) = data_ed.ev1(data_ed.cho==1);
    data_ed.ev(data_ed.cho==2) = data_ed.ev2(data_ed.cho==2);
    evd2 = unique(data_ed.ev);


    for i = 1:length(evd2)
        dd2{i} = [dd2{i}; data_ed.rtime(data_ed.ev==evd2(i))];
        %dd{i} = [dd{i}, data_ed.rtime(data_ed.ev==data_ed.ev(i))'];

    end
    
    mask_cho2 = data_ee.cho==2;
    mask_cho1 = data_ee.cho==1;

    data_ee.ev = NaN(size(data_ee.cho));
    data_ee.ev(data_ee.cho==1) = abs(data_ee.ev1(data_ee.cho==1)-data_ee.ev2(data_ee.cho==1));
    data_ee.ev(data_ee.cho==2) = abs(data_ee.ev2(data_ee.cho==2)-data_ee.ev1(data_ee.cho==2));
    eve1 = unique(data_ee.ev);


    for i = 1:length(eve1)
        dde1{i} = [dde1{i}; data_ee.rtime(data_ee.ev==eve1(i))];
        %dd{i} = [dd{i}, data_ed.rtime(data_ed.ev==data_ed.ev(i))'];

    end
    
    data_ee.ev = NaN(size(data_ee.cho));
    data_ee.ev(data_ee.cho==1) = data_ee.ev1(data_ee.cho==1);
    data_ee.ev(data_ee.cho==2) = data_ee.ev2(data_ee.cho==2);
    eve2 = unique(data_ee.ev);
    for i = 1:length(eve2)
        dde2{i} = [dde2{i}; data_ee.rtime(data_ee.ev==eve2(i))];

    end
    

end
figure('Units', 'centimeters',...
    'Position', [0,0,5.3*11, 5.3/1.25*6], 'visible', displayfig)

ev_ed = evd1;
labely = 'RT';
labelx = 'abs(EV(chosen)-EV(unchosen))';
%x_lim = [min(ev_ed),max(ev_ed)];
x_values = ev_ed;
% = reshape(dd, [1, 29]);
y=dd1(~cellfun('isempty',dd1));
subplot(1, 2, 1)
brickplot(y,...
    orange.*ones(size(y,1), 3),...
    [0, 4000],...
    fontsize*1.5,...
    '',...
    '',...
    labely,...
    ev_ed,1, [-1, length(ev_ed)+1], 1:length(ev_ed), .3,0);

set(gca, 'tickdir', 'out');
%set(gca,'XTick',0:20:100);
%set(gca,'XTickLabels',0:20:100);
%set(gca, 'ytick', 1000:200:2500);
%set(gca,'yTickLabels',1000:200:2500);
box off;
xtickangle(0)
xlabel(labelx)

ev_ee = eve1;
labely = 'RT';
labelx = 'abs(EV(chosen)-EV(unchosen))';
%x_lim = [min(ev_ed),max(ev_ed)];
x_values = ev_ee;
% = reshape(dd, [1, 29]);
y=dde1(~cellfun('isempty',dde1));
subplot(1, 2, 2)
brickplot(y,...
    green.*ones(size(y,1), 3),...
    [0, 4000],...
    fontsize*1.5,...
    '',...
    '',...
    labely,...
    ev_ee,1, [-1, length(ev_ee)+1], 1:length(ev_ee), .3,0);

set(gca, 'tickdir', 'out');
%set(gca,'XTick',0:20:100);
%set(gca,'XTickLabels',0:20:100);
%set(gca, 'ytick', 1000:200:2500);
%set(gca,'yTickLabels',1000:200:2500);
box off;
xtickangle(0)
xlabel(labelx)
return

plot_poly(x_values, y', green, 2);


%set(gca, 'ytick', 1000:200:2500);
%set(gca,'yTickLabels',1000:200:2500);
set(gca, 'tickdir', 'out');
box off;
xtickangle(0)
xlabel(labelx)
return
% labely = 'Median reaction time per subject (ms)';
% labelx = 'P(lottery) (%)';
% x_lim = [0,100];
% x_values = 5:100/11:100;
% 
% subplot(1, 3, 1)
% brickplot(d',...
%     orange.*ones(11, 3),...
%     [1000, 2500],...
%     fontsize,...
%     '',...
%     '',...
%     labely,...
%     lotp.*100,1,[0,100], x_values, 2,0);
% 
% plot_poly(x_values, d, orange, 2);
% set(gca, 'tickdir', 'out');
% %set(gca,'XTick',0:20:100);
% %set(gca,'XTickLabels',0:20:100);
% set(gca, 'ytick', 1000:200:2500);
% set(gca,'yTickLabels',1000:200:2500);
% box off;
% xtickangle(0)
% xlabel(labelx)

% - ------------------------------ 

x_lim = [0,100];
x_values = 5:100/8:100;
labelx = 'P(symbol) (%)';

subplot(1, 3, 2)
    
brickplot(e',...
    orange.*ones(8, 3),...
    [1000, 2500],...
    fontsize,...
    '',...
    '',...
    '',...
    symp.*100,1,[0,100], x_values, 2,0);

plot_poly(x_values, e, orange, 2);


set(gca, 'ytick', 1000:200:2500);
set(gca,'yTickLabels',1000:200:2500);
set(gca, 'tickdir', 'out');
box off;
xtickangle(0)
xlabel(labelx)


% - ------------------------------ 
subplot(1, 3, 3)
labelx = 'P(chosen symbol) (%)';

x_lim = [0,100];
x_values = 5:100/8:100;

brickplot(ee',...
    green.*ones(8, 3),...
    [1000, 2500],...
    fontsize,...
    '',...
    '',...
    '',...
    symp.*100,1,[0,100], x_values, 2,0);

set(gca, 'ytick', 1000:200:2500);
set(gca,'yTickLabels',1000:200:2500);

set(gca, 'tickdir', 'out');
box off;
xtickangle(0)
xlabel(labelx)

plot_linear(x_values, ee, green);


saveas(gcf, figname);

writetable(stats_data, stats_filename);

% ------------------------------------------------------------------------%

function plot_poly(x_values, d, color, npoly)
    hold on 
    x = x_values.*ones(size(d));
    p = polyfit(x, d, npoly);
    y = polyval(p, x);
    plot(x_values, mean(y,1), 'color', color, 'linewidth', 1.5);
end

function plot_linear(x_values, d, color)
    hold on 
    d = nanmean(d);
    x = x_values;    
    b = glmfit(x, d);
    y = glmval(b, x, 'identity');  
    plot(x_values, y, 'color', color, 'linewidth', 1.5);
end