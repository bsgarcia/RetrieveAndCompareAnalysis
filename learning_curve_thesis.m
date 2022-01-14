%-------------------------------------------------------------------------
init;
%-------------------------------------------------------------------------
selected_exp = [1,2,3];
displayfig = 'on';

%figure('Renderer', 'painters','Units', 'centimeters',...
%    'Position', [0,0,5.3*length(selected_exp), 5.3/1.25], 'visible', displayfig)
num = 0;
m = {};
% filenames
filename = 'corr';
figfolder = 'fig';

figname = sprintf('%s/%s.svg', figfolder, filename);
stats_filename = sprintf('data/stats/%s.csv', filename);
T = table();
subcount = 0;
for exp_num = selected_exp
    num = num + 1;

    
    %---------------------------------------------------------------------%
    % get data parameters                                                 %
    % --------------------------------------------------------------------%
    sess = de.get_sess_from_exp_num(exp_num);
    name = de.get_name_from_exp_num(exp_num);
    nsub = de.get_nsub_from_exp_num(exp_num);
    
    data = de.extract_LE(exp_num);
    
    for sub = 1:nsub
        subcount = subcount + 1;
        d=data.corr(sub, data.con(sub, :)==2);

        for t = 1:30
            a(t, subcount) = d(t);
        end
      
    end 

 end

    surfaceplot(a, [.5, .5, .5], 'k', 1, ...
    0.5, 0, 1, 10, 'Learning', 'trials', 'Correct choice rate')


saveas(gcf, 'test.svg')


%avg = mean(m, 


