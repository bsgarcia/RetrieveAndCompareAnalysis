%-------------------------------------------------------------------------%
init;
show_current_script_name(mfilename('fullpath'));

%-------------------------------------------------------------------------%
% parameters of the script                                                %
%-------------------------------------------------------------------------%
selected_exp = [5, 6];%, 6.2, 7.1, 7.2];
displayfig = 'on';
colors = blue;
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

sub_count = 0;
for exp_num = selected_exp
    
    num = num + 1;
    
    %---------------------------------------------------------------------%
    % get data parameters                                                 %
    % --------------------------------------------------------------------%
    sess = de.get_sess_from_exp_num(exp_num);
    name = de.get_name_from_exp_num(exp_num);
    
    data_ed = de.extract_ED(exp_num);
    data_ee = de.extract_EE(exp_num);
    
    nsub = size(data_ed.cho, 1);
    mat_ed = nan(length(lotp), length(symp));
    mat_ee = nan(length(symp), length(symp));
%     data_ed.rtime = normalize(data_ed.rtime);
%     data_ee.rtime = normalize(data_ee.rtime);
%     for sub = 1:nsub
%         [throw, a] = sort(data_ed.rtime(sub,:));
%         [throw, b] = sort(data_ee.rtime(sub,:));
% 
%         data_ed.rtime(sub, :) = a./max(a);
%         data_ee.rtime(sub, :) = b./max(b);
%     end
    
    for p2 = 1:length(lotp)
        for p1 = 1:length(symp)
            mask = (data_ed.p1==symp(p1)) .* (data_ed.p2==lotp(p2));
            mat_ed(p2,p1) = mean(...
                data_ed.rtime(logical(mask)));
        end
    end
    
    for p2 = 1:length(symp)
        for p1 = 1:length(symp)
            
            mask = (data_ee.p1==symp(p1)) .* (data_ee.p2==symp(p2));
            mat_ee(p2,p1) = mean(...
                data_ee.rtime(logical(mask)));
            
        end
    end
    figure('Position', [0, 0, 1800, 600]);
    subplot(1, 2, 1);   
    
    title('ES');
    h = heatmap(mat_ed);
    ylabel('lottery')
    xlabel('blocked sym')

    h.Colormap = redblue(5);
    subplot(1, 2, 2);   
    
    title('EE');

    h = heatmap(mat_ee);
     ylabel('sym against')
    xlabel('blocked sym')
    h.Colormap = redblue(5);

    sgtitle(sprintf('Exp. %.0f', exp_num));
    saveas(gcf, sprintf('RT_heatmap_exp_%d.png', exp_num))

end
return

labely = 'Median reaction time per subject (ms)';
labelx = 'P(lottery) (%)';
x_lim = [0,100];
x_values = 5:100/11:100;

subplot(1, 3, 1)
brickplot(d',...
    orange.*ones(11, 3),...
    [1000, 2500],...
    fontsize,...
    '',...
    '',...
    labely,...
    lotp.*100,1,[0,100], x_values, 2,0);

plot_poly(x_values, d, orange, 2);
set(gca, 'tickdir', 'out');
%set(gca,'XTick',0:20:100);
%set(gca,'XTickLabels',0:20:100);
set(gca, 'ytick', 1000:200:2500);
set(gca,'yTickLabels',1000:200:2500);
box off;
xtickangle(0)
xlabel(labelx)

% - ------------------------------ ---------------------------------------%

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


% - ----------------------------------------------------------------------%
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

function norm_data = normalize(bla)
    norm_data = (bla - min(bla, [], 'all')) ./ ( max(bla, [], 'all') - min(bla, [], 'all') );
end