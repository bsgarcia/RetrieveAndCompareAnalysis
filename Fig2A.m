%-------------------------------------------------------------------------
init;
%-------------------------------------------------------------------------

% ------------------------------------------------------------------------
% customizable parameters
% ------------------------------------------------------------------------
selected_exp = [1, 2, 3, 4];
modality = 'LE';
color = blue;
displayfig = 'on';
filename = 'Fig2A';

% ------------------------------------------------------------------------
% fixed parameters
% ------------------------------------------------------------------------
T_exp = table();
T_con = table();

% filenames

figfolder = 'fig';

figname = sprintf('%s/%s.svg', figfolder, filename);
stats_filename = sprintf('data/stats/%s.csv', filename);
stats_filename2 = sprintf('data/stats/exp_%s.csv', filename);


figure('Renderer', 'painters','Units', 'centimeters',...
    'Position', [0,0,5.3*length(selected_exp), 5.3/1.25], ...
    'visible', displayfig)


sub_count = 0;
num = 0;
for exp_num = selected_exp
    clear dd
    num = num + 1;

    data = de.extract_LE(exp_num);
    data_ed = de.extract_ES(exp_num);

    if exp_num == 4
        data.con(data.con == 2) = 4;
    end
    ncon = length(unique(data.con));

    dd = NaN(ncon, data.nsub);
    cons = flip(unique(data.con));

    for i = 1:ncon
        for sub = 1:data.nsub

            dd(i, sub) = mean(...
                data.corr(sub, data.con(sub,:)==cons(i)));
            %if ismember(cons(i), [1, 4])
            complete = ismember(exp_num, [3, 4]);
            block = ismember(exp_num, [2, 3, 4]);
            less_cues = exp_num == 4;


            T3 = table(...
                sub+sub_count, exp_num,  complete,  block, less_cues, dd(i, sub), cons(i), ...
                'variablenames',...
                {'subject', 'exp_num', 'complete', 'block','less_cues', 'score', 'cond'}...
                );

            T_con = [T_con; T3];
            % end
        end
    end

    for sub = 1:data.nsub
        s1 = mean(data.corr(sub, :));
        s2 = mean(data_ed.corr(sub, :));

        complete = int32(ismember(exp_num, [3, 4]));
        block = int32(ismember(exp_num, [2, 3, 4]));
        less_cues = int32(exp_num == 4);

        T1 = table(...
            sub+sub_count, exp_num, complete,  block, less_cues, s1, {'LE'}, ...
            'variablenames',...
            {'subject', 'exp_num', 'complete', 'block','less_cues', 'score', 'modality'}...
            );

        T_exp = [T_exp; T1];
    end

    sub_count = sub_count + sub;

    subplot(1, length(selected_exp), num)

    if num == 1
        labely = 'Correct choice rate (%)';
    else
        labely = '';
    end

    plot([10, 85], [50, 50], 'color', 'k', 'linestyle', ':')

    if exp_num == 4
        xvalues = [10, 85];
        varargin = {'60/40', '90/10'};
    else
        xvalues = [10, 35, 60, 85];
        varargin = {'60/40','70/30', '80/20', '90/10'};
    end
    brickplot(...
        dd.*100,...                             %data
        color.*ones(4, 3),...                   %color
        [-0.08*100, 1.08*100], fontsize,...     %ylim     % fontsize
        '',...                                  %title
        '',...                                  %xlabel
        '',...                                  %ylabel
        varargin,...                            %varargin
        0,...                                   %noscatter
        [-10, 105],...                          %xlim
        xvalues,...                    %xvalues
        5, ...                                  %barwidth
        0 ...                                   %median
        );

    plot([10, 85], [50, 50], 'color', 'k', 'linestyle', ':')
    xlabel('E-options pairs');
    ylabel(labely);

    box off
    hold on

    %set(gca, 'ytick', [0:10]./10);
    set(gca,'TickDir','out')
    set(gca, 'fontsize', fontsize);

end
saveas(gcf, figname);

writetable(T_con, stats_filename);
writetable(T_exp, stats_filename2);


