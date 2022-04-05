%-------------------------------------------------------------------------
init;
show_current_script_name(mfilename('fullpath'));
%-------------------------------------------------------------------------

%-------------------------------------------------------------------------%
% parameters of the script                                                %
%-------------------------------------------------------------------------%
selected_exp = [1, 2, 3, 4, 5, 6.1];
modalities = {'LE', 'ES'};
displayfig = 'on';
colors = [blue;orange;green;magenta];
% filenames
filename = 'review_perf_fig2';
figfolder = 'fig';

figname = sprintf('%s/%s.svg', figfolder, filename);
stats_filename = sprintf('data/stats/%s.csv', filename);


%-------------------------------------------------------------------------%
% prepare data                                                            %
%-------------------------------------------------------------------------%


figure('Units', 'centimeters',...
    'Position', [0,0,5.3*3, 5.3/1.25], 'visible', displayfig)

num = 0;
sub_count = 0;
CRT_LE = [];
CRT_ES = [];
slopes_LE = [];
slopes_ES = [];

for exp_num = selected_exp
    num = num + 1;

    %---------------------------------------------------------------------%
    % get data parameters                                                           %
    % --------------------------------------------------------------------%
    sess = de.get_sess_from_exp_num(exp_num);
    name = de.get_name_from_exp_num(exp_num);
    nsub = de.get_nsub_from_exp_num(exp_num);

    ES = de.extract_ES(exp_num);
    LE = de.extract_LE(exp_num);

    nsym = length(unique(ES.p1));
    p1 = unique(ES.p1)'.*100;

    % prepare data structure
    midpoints = nan(length(modalities), nsub, nsym);
    slopes = nan(length(modalities), nsub, 2);
    reshape_midpoints = nan(nsub, nsym);

    sim_params.exp_num = exp_num;
    sim_params.de = de;
    sim_params.sess = sess;
    sim_params.exp_name = name;
    sim_params.nsub = nsub;

    for mod_num = 1:length(modalities)

        % get data depending on chosen modality
        switch (modalities{mod_num})

            case 'LE'
                sim_params.model = 1;
                [midpoints(mod_num, :, :), throw] = get_qvalues(sim_params);

            case {'EE', 'ES'}

                param = load(...
                    sprintf('data/fit/midpoints_%s_exp_%d_%d_mle',...
                    modalities{mod_num}, round(exp_num), sess));

                midpoints(mod_num, :, :) = param.midpoints;

            case 'SP'
                sim_params.model = 2;
                [midpoints(mod_num, :, :), throw] = get_qvalues(sim_params);
        end

        % fill data
        reshape_midpoints(:, :) = midpoints(mod_num, :, :);
        slopes(mod_num, :, :) = add_linear_reg(...
            reshape_midpoints.*100, p1, colors(mod_num, :));
        if mod_num == 1
            CRT_LE = [CRT_LE; mean(LE.corr, 2)];
            slopes_LE = [slopes_LE;slopes(1, :, 2)'];
        else
            CRT_ES = [CRT_ES; mean(ES.corr, 2)];
            slopes_ES = [slopes_ES; slopes(2, :, 2)'];

        end

    end

  
end
var_LE = CRT_LE;
var_ES = slopes_ES;

[throw, idx_sorted] = sort(var_LE);
A1 = idx_sorted(1:end/2);
A2 = idx_sorted(end/2+1:end);
poor_LE = shuffle(var_LE(A1));
good_LE = shuffle(var_LE(A2));
poor_ES = var_ES(A1);
good_ES = var_ES(A2);

T1 = table(poor_LE, repmat({'LE'}, 1, length(poor_LE))', repmat({'poor'}, 1, length(poor_LE))',...
    'variablenames', {'value', 'modality', 'split'});
T4 = table(good_LE, repmat({'LE'}, 1, length(good_LE))', repmat({'good'}, 1, length(good_LE))',...
    'variablenames', {'value', 'modality', 'split'});

T2 = table(poor_ES, repmat({'ES'}, 1, length(poor_ES))', repmat({'poor'}, 1, length(poor_ES))',...
    'variablenames', {'value', 'modality', 'split'});

T3 = table(good_ES, repmat({'ES'}, 1, length(good_ES))', repmat({'good'}, 1, length(good_ES))',...
    'variablenames', {'value', 'modality', 'split'});

T = [T1;T2;T3;T4];

%---------------------------------------------------------------------%
% Plot                                                                %
%--------------------------------------------------------------------%
subplot(1, 3, 1)

skylineplot([poor_LE'; good_LE'], 8,...
    [blue;blue],...
    0.2,...
    1,...
    fontsize,...
    '',...
    'Learners',...
    'Accuracy',...
    {'Poor', 'Good'});

%title('Learning phase');
hold on
plot([1,length(modalities)], [0.5, 0.5], 'color', 'k', 'linestyle', ':')
hold on

%if num == 1; ylabel('Slope'); end
set(gca, 'tickdir', 'out');
box off
set(gca, 'fontsize', 9)

set(gca, 'fontname', 'arial');


%---------------------------------------------------------------------%
% Plot                                                                %
%--------------------------------------------------------------------%
subplot(1, 3, 2)

skylineplot([poor_ES'; good_ES'], 8,...
    [orange; orange],...
    -.5,...
    1.5,...
    fontsize,...
    '',...
    'Learners',...
    'Slope',...
    {'Poor', 'Good'});

%title('Exp. 5, 6');
hold on
plot([1,length(modalities)], [0.5, 0.5], 'color', 'k', 'linestyle', ':')
hold on

%if num == 1; ylabel('Slope'); end
%title('Stated Probability phase');
set(gca, 'tickdir', 'out');
box off
set(gca, 'fontsize', 9)



set(gca, 'fontname', 'arial');


%---------------------------------------------------------------------%
% Plot                                                                %
%--------------------------------------------------------------------%
subplot(1, 3, 3)

scatterplot(var_LE, var_ES, 10, black, [-.1, 1.1], [-.1, 1.1], 'Accuracy LE', 'Slope ES','', 'topleft')
%if num == 1; ylabel('Slope'); end
set(gca, 'tickdir', 'out');
box off
set(gca, 'fontname', 'arial');%
set(gca, 'fontsize', 9)

xticks(0:.2:1)
yticks(0:.2:1)

%-------------------------------------------------------------------------%
% Save fig and stats                                                      %
% ------------------------------------------------------------------------%
% save fig
mkdir('fig/exp', figfolder);
saveas(gcf, figname);

% save stats file
mkdir('data', 'stats');
writetable(T, stats_filename);