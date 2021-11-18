%-------------------------------------------------------------------------%
init;
show_current_script_name(mfilename('fullpath'));

%-------------------------------------------------------------------------%
% parameters of the script                                                %
%-------------------------------------------------------------------------%
selected_exp = [5, 6.1, 6.2];%, 6.2, 7.1, 7.2];
displayfig = 'on';
colors = [blue; orange; green];
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

lotp = [.1, .2, .3, .4,.6, .7, .8, .9];
symp = [.1, .2, .3, .4,.6, .7, .8, .9];

sub_count = 0;

EE = [];
ED = [];
LE = [];

for exp_num = selected_exp

    num = num + 1;

    %---------------------------------------------------------------------%
    % get data parameters                                                 %
    % --------------------------------------------------------------------%
    sess = de.get_sess_from_exp_num(exp_num);
    name = de.get_name_from_exp_num(exp_num);

    data_ed = de.extract_ED(exp_num);
    data_ee = de.extract_EE(exp_num);
    data_le = de.extract_LE(exp_num);

    nsub = size(data_ed.cho, 1);
    disp(nsub);
    
    for sub = 1:nsub
        dED = [];
        dEE = [];
        for p2 = 1:length(lotp)
            for p1 = 1:length(symp)
                if p1 ~= p2
                    mask = (data_ed.p1(sub,:)==symp(p1)) .* (data_ed.p2(sub,:)==lotp(p2));
                    mask = (data_ee.p1(sub,:)==symp(p1)) .* (data_ee.p2(sub,:)==lotp(p2));
                    
                    dED = [dED; data_ed.rtime(sub, logical(mask))];
                    dEE = [dEE; data_ed.rtime(sub, logical(mask))];    
                end
            end
        end
         ED = [ED; mean(dED)];
         EE = [EE; mean(dEE)];
    end

    for sub = 1:nsub
        dl = [];
        for con = 1:4
            d = data_le.rtime(sub, data_le.con(sub, :)==con);
            dl = [dl; d(end-13:end)'];
        end
        LE = [LE; mean(dl)];

    end


end

figure

dd(1, :) = LE;
dd(2, :) = ED;
dd(3, :) = EE;


skylineplot(dd,8,...
    [blue; orange; green],...
    0,...
    5000,...
    fontsize,...
    '',...
    '',...
    '',...
    {'LE', 'Es', 'EE'}, 0);

ylabel('Average RT by subject')
%DataCell, Model_DataCell1, Colors,Yinf,Ysup,Font,Title,LabelX,LabelY,varargin, noscatter)


%title(sprintf('Exp. %s', num2str(exp_num)));w
set(gca, 'tickdir', 'out');
box off

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
    norm_data = (bla - min(bla, [], 'all')) ...
        ./ ( max(bla, [], 'all') - min(bla, [], 'all') );
end