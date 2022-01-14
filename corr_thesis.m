%-------------------------------------------------------------------------
init;
%-------------------------------------------------------------------------
selected_exp = [1, 2, 3, 4, 5, 6, 8, 7];
displayfig = 'on';

%figure('Renderer', 'painters','Units', 'centimeters',...
%    'Position', [0,0,5.3*length(selected_exp), 5.3/1.25], 'visible', displayfig)
num = 0;
m = {};
s = {};
% filenames
filename = 'corr';
figfolder = 'fig';

figname = sprintf('%s/%s.svg', figfolder, filename);
stats_filename = sprintf('data/stats/%s.csv', filename);
T = table();
sub_count = 0;
for exp_num = selected_exp
    num = num + 1;

    
    %---------------------------------------------------------------------%
    % get data parameters                                                 %
    % --------------------------------------------------------------------%
    sess = de.get_sess_from_exp_num(exp_num);
    name = de.get_name_from_exp_num(exp_num);
    nsub = de.get_nsub_from_exp_num(exp_num);
    
    data = de.extract_ED(exp_num);
    
    for sub = 1:nsub
        sub_count = sub_count + 1;
        exclude = data.p2(sub, ismember(data.p2(sub,:), [0, .5, 1]));
        a = mean(data.corr(sub, :)==1, 'all');
        b = mean(data.cho(sub, :)==1, 'all');
        s{num}(sub) = b;
        m{num}(sub) = a;
        T1 = table(...
                sub_count, exp_num, a, 'variablenames',...
                {'subject', 'exp_num', 'score'}...
         );
         T = [T; T1];    
    end 
    x_scatter{num} = ones(nsub,1)' .* num;

end
x = 1:8;
for i = x
    avg(i) = mean(m{i}, 'all');
    err(i) = std(m{i})%./sqrt(length(m{i}));
end

bar(x,avg.*100, 'facecolor', set_alpha(orange, .4), 'edgecolor', 'w');    

hold on 
x_scat=horzcat(x_scatter{:});

deviation = (randi([-2, 2], numel(x_scat),1))./10;
x_scat=x_scat'+deviation;
y_scat=horzcat(m{:});

scatter(x_scat', y_scat.*100, 'markerfacecolor', orange, 'markerfacealpha', .6, 'markeredgecolor', 'w');

hold on

er = errorbar(x,avg*100,err./2.*100,err./2.*100, 'capsize', 0, 'linewidth', 1.5);    
er.Color = [0, 0, 0]; 
er.LineStyle = 'none';
box off
hold off
ylim([0, 102]);
set(gca, 'tickdir', 'out');
% save stats file
mkdir('data', 'stats');
writetable(T, stats_filename);
ylabel('Correct choice rate (%)');
xlabel('Exp.');
saveas(gcf, 'corr_heur.png');


%avg = mean(m, 

