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
CRT_LE = [];
slopes_ES = [];

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
            CRT_LE =mean(LE.corr, 2);
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

    [throw, idx_sorted] = sort(CRT_LE);
    A1 = idx_sorted(1:end/2);
    A2 = idx_sorted(end/2+1:end);
    poor_LE = shuffle(CRT_LE(A1));
    good_LE = shuffle(CRT_LE(A2));

    poor_ES = CRT_ES(A1);
    good_ES = CRT_ES(A2);
%     
%     subplot(7, 2, num)
%     ind(ES.p1(A1,:), ES.p2(A1, :), ES.cho(A1,:), orange);
%     title('poor');
%     subplot(7, 2, num+1)
%     ind(ES.p1(A2,:), ES.p2(A2, :), ES.cho(A2,:), orange);
%     title('good');
%     num = num + 2;
    %---------------------------------------------------------------------%
    % Plot                                                                %
    %--------------------------------------------------------------------%
    subplot(7, 3, num)

    skylineplot([poor_LE'; good_LE'], 8,...
        [blue;blue],...
        0,...
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
        yticks(0:.2:1);

    %if num == 1; ylabel('Slope'); end
    set(gca, 'tickdir', 'out');
    box off
    set(gca, 'fontname', 'arial');


    %---------------------------------------------------------------------%
    % Plot                                                                %
%     %--------------------------------------------------------------------%
    subplot(7, 3, num+1)

    skylineplot([poor_ES'; good_ES'], 8,...
        [orange; orange],...
        0,...
        1,...
        fontsize,...
        '',...
        'Learners',...
        'Accuracy',...
        {'Poor', 'Good'});

    %title('Exp. 5, 6');
    hold on
    plot([1,length(modalities)], [0.5, 0.5], 'color', 'k', 'linestyle', ':')
    hold on

    %if num == 1; ylabel('Slope'); end
    %title('Stated Probability phase');
    set(gca, 'tickdir', 'out');
    box off
    yticks(0:.2:1);
    set(gca, 'fontname', 'arial');
    %

    %---------------------------------------------------------------------%
    % Plot                                                                %
    %--------------------------------------------------------------------%
    subplot(7, 3, num+2)

    scatterplot(CRT_LE, CRT_ES, 10, grey, [0, 1], [0, 1], 'Accuracy LE', 'Accuracy ES','')
    num = num + 3;


end


return 

%---------------------------------------------------------------------%
% Plot                                                                %
%--------------------------------------------------------------------%
subplot(1, 2, 1)


skylineplot([poor_LE'; good_LE'], 8,...
    [blue;blue],...
    0.4,...
    1,...
    fontsize,...
    '',...
    'Learners',...
    'Slope',...
    {'Poor', 'Good'});

%title('Learning phase');
hold on
plot([1,length(modalities)], [0.5, 0.5], 'color', 'k', 'linestyle', ':')
hold on

%if num == 1; ylabel('Slope'); end
set(gca, 'tickdir', 'out');
box off
set(gca, 'fontname', 'arial');


%---------------------------------------------------------------------%
% Plot                                                                %
%--------------------------------------------------------------------%
subplot(1, 2, 2)

skylineplot([poor_ES'; good_ES'], 8,...
    [orange; orange],...
    0.4,...
    1,...
    fontsize,...
    '',...
    'Learners',...
    '',...
    {'Poor', 'Good'});

%title('Exp. 5, 6');
hold on
plot([1,length(modalities)], [0.5, 0.5], 'color', 'k', 'linestyle', ':')
hold on

%if num == 1; ylabel('Slope'); end
%title('Stated Probability phase');
set(gca, 'tickdir', 'out');
box off
set(gca, 'fontname', 'arial');
%-------------------------------------------------------------------------%
% Save fig and stats                                                      %
% ------------------------------------------------------------------------%
% save fig
mkdir('fig/exp', figfolder);
saveas(gcf, figname);

%
% disp('********************************************');
% disp('FULL');
% disp('********************************************');
% fitlme(T, 'slope ~ exp_num*modality + (1|subject)')% 'CategoricalVar', {'exp_num', 'modality'})
% disp('********************************************');
% return
% disp('********************************************');
% disp('LE');
% disp('********************************************');
% fitlm(T(cond_LE,:), 'slope ~ exp_num', 'CategoricalVar', {'exp_num', 'modality'})
% disp('********************************************');
% disp('********************************************');
% disp('ES');
% disp('********************************************');
% M%fitlm(T(cond_ED,:), 'slope ~ exp_num', )
% disp('********************************************');
% disp('PM');
% disp('********************************************');
% fitlm(T(cond_PM,:), 'slope ~ exp_num')
% disp('********************************************');

function ind(p1, p2, cho, orange)

 % ---------------------------------------------------------------------
    % Compute for each symbol p of chosing depending on described cue value
    % ---------------------------------------------------------------------
    p_lot = unique(p2)';
    p_sym = unique(p1)';
   
    prop = zeros(length(p_sym), length(p_lot));
    for i = 1:length(p_sym)
        for j = 1:length(p_lot)
            temp = cho(...
                logical((p2 == p_lot(j)) .* (p1== p_sym(i))));
            prop(i, j) = mean(temp == 1);
            
        end
    end
      
    alpha = linspace(.15, .95, length(p_sym));
    lin1 = plot(...
        linspace(p_sym(1)*100, p_sym(end)*100, 12), ones(12,1)*50,...
        'LineStyle', ':', 'Color', [0, 0, 0], 'HandleVisibility', 'off');
   
    for i = 1:length(p_sym)
       
        hold on
       
        lin3 = plot(...
            p_lot.*100,  prop(i, :).*100,...
            'Color', orange, 'LineWidth', 1.5 ...% 'LineStyle', '--' ...
            );
        
        lin3.Color(4) = alpha(i);
       
        hold on      
       
        [xout, yout] = intersections(lin3.XData, lin3.YData, lin1.XData, lin1.YData);
       
        sc2 = scatter(xout, yout, 15, 'MarkerFaceColor', lin3.Color,...
            'MarkerEdgeColor', 'w');
        sc2.MarkerFaceAlpha = alpha(i);
%        
%         if num == 1
%             ylabel('P(choose E-option) (%)');
%         end
        xlabel('S-option p(win) (%)');
       
        ylim([-0.08*100, 1.08*100]);
        xlim([-0.08*100, 1.08*100]);
       
        box off
    end
      
    set(gca,'TickDir','out')
    xticks([0:20:100])
    xtickangle(0)
    %set(gca,'fontname','monospaced')  % Set it to times

    %axis equal
end