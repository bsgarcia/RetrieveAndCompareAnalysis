%-------------------------------------------------------------------------
init;
show_current_script_name(mfilename('fullpath'));
%-------------------------------------------------------------------------

%-------------------------------------------------------------------------%
% parameters of the script                                                %
%-------------------------------------------------------------------------%
selected_exp = [1, 2, 3, 4, 5, 6.1, 7.1];
modalities = {'LE', 'ES'};
displayfig = 'on';
colors = [blue;orange;green;magenta];
% filenames
filename = 'review_poor_good';
figfolder = 'fig';

figname = sprintf('%s/%s.svg', figfolder, filename);
stats_filename = sprintf('data/stats/%s.csv', filename);


%-------------------------------------------------------------------------%
% prepare data                                                            %
%-------------------------------------------------------------------------%
% stats_data is table that is used to compute stats later
stats_data = table();


figure('Units', 'centimeters',...
    'Position', [0,0,5.3*2, 5.3/1.25*length(selected_exp)], 'visible', displayfig)

num = 1;
sub_count = 0;
slopes_LE = [];
slopes_ES = [];
T = table();
mat = [];

for exp_num = selected_exp

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
%         hold on
        if mod_num == 1
            slopes_LE =mean(LE.corr, 2);
        else
            CRT_ES =mean(ES.corr, 2);
            slopes_ES = squeeze(slopes(2,:,2));
        end



        %         % fill data for stats
        %         for sub = 1:nsub
        %             T1 = table(...
        %                 sub+sub_count, num, slopes(mod_num, sub, 2),...
        %                 {modalities{mod_num}}, 'variablenames',...
        %                 {'subject', 'exp_num', 'slope', 'modality'}...
        %                 );
        %             stats_data = [stats_data; T1];
        %         end
    end
%    sub_count = sub_count+sub;

    [throw, idx_sorted] = sort(slopes_LE);
    A1 = idx_sorted(1:end/2);
    A2 = idx_sorted(end/2+1:end);
    poor_LE = shuffle(slopes_LE(A1));
    good_LE = shuffle(slopes_LE(A2));

    poor_ES = CRT_ES(A1);
    good_ES = CRT_ES(A2);

    mat = [mat poor_ES good_ES];

    T1 = table(num, mean(poor_LE).*100, mean(good_LE).*100, mean(good_LE).*100 -  mean(poor_LE).*100 , ...
         mean(poor_ES).*100, mean(good_ES).*100, mean(good_ES).*100 -  mean(poor_ES).*100 , ...
         'variablenames', {'Exp.', 'Low LE', 'High LE', '% difference 1', 'Low ES', 'High ES', '% difference 2'});
    T = [T; T1];
end

ttest_bonf(mat, [1, 2; 3, 4; 5, 6; 7, 8])
