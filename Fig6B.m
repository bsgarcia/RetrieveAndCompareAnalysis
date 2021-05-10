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
filename = 'Fig6B';
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
    nsub = de.get_nsub_from_exp_num(exp_num);
    
    data_ed = de.extract_ED(exp_num);
    data_ee = de.extract_EE(exp_num);

    for sub = 1:nsub
        
        for p = 1:length(lotp)
            mask_lot = (data_ed.p2(sub,:)==lotp(p));
                d(sub+sub_count,p) = median(...
                data_ed.rtime(sub, logical(mask_lot)));   
            T1 = table(...
                    sub+sub_count, exp_num, d(sub+sub_count,p), lotp(p),...
                    {'ED_d'}, 'variablenames',...
                    {'subject', 'exp_num', 'RT', 'p', 'modality'}...
                    );
            stats_data = [stats_data; T1];
 
        end
        
        for p = 1:length(symp)
             mask_lot = (data_ed.p1(sub,:)==symp(p));
             mask_cho1 = data_ee.cho(sub,:) == 1;
             mask_cho2 = data_ee.cho(sub,:) == 2;
             mask_p1 = data_ee.p1(sub,:) == symp(p);
             mask_p2 = data_ee.p2(sub,:) == symp(p);
             e(sub+sub_count,p) = median(...
                data_ed.rtime(sub, logical(mask_lot)));  
            ee(sub+sub_count,p) = median(data_ee.rtime(sub, logical((mask_p1.*mask_cho1) + (mask_p2.*mask_cho2))));
            
            T1 = table(...
                    sub+sub_count, exp_num, e(sub+sub_count,p), symp(p),...
                    {'ED_e'}, 'variablenames',...
                    {'subject', 'exp_num', 'RT', 'p', 'modality'}...
                    );
            stats_data = [stats_data; T1];
            T1 = table(...
                    sub+sub_count, exp_num, ee(sub+sub_count,p), symp(p),...
                    {'EE'}, 'variablenames',...
                    {'subject', 'exp_num', 'RT', 'p', 'modality'}...
                    );
            stats_data = [stats_data; T1];
 
        end
        
        
        for t = 1:length(data_ed.p2(sub,:))
            
            T1 = table(...
                    sub+sub_count, exp_num, data_ed.rtime(sub, t), data_ed.p1(sub, t),data_ed.p2(sub, t),...
                    {'ED'}, 'variablenames',...
                    {'subject', 'exp_num', 'RT', 'p_symbol', 'p_lottery', 'modality'}...
                    );
            full_rt = [full_rt; T1];
 
        end
    end
%         for mod_num = 1:3
%             T1 = table(...
%                 sub+sub_count, exp_num, dd{mod_num},...
%                 {modalities{mod_num}}, 'variablenames',...
%                 {'subject', 'exp_num', 'RT', 'modality'}...
%                 );
%             stats_data = [stats_data; T1];
%         end
    %end
    
    sub_count = sub_count + sub;

end
figure('Units', 'centimeters',...
    'Position', [0,0,5.3*2.2, 5.3/1.25*2], 'visible', displayfig)

labely = 'Median reaction time per subject (ms)';
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
    lotp.*100,1,[0,100], x_values, .18,0);

set(gca, 'tickdir', 'out');
%set(gca,'XTick',0:20:100);
%set(gca,'XTickLabels',0:20:100);
set(gca, 'ytick', 1000:200:2500);
set(gca,'yTickLabels',1000:200:2500);


box off;

x_lim = [0,100];
x_values = 5:100/8:100;

subplot(1, 3, 2)
    
brickplot(e',...
    orange.*ones(8, 3),...
    [1000, 2500],...
    fontsize,...
    '',...
    '',...
    '',...
    symp.*100,1,[0,100], x_values, .18,0);

% set(gca,'XTick', 5:100/4:100);
% set(gca,'xticklabels',10:20:90);
set(gca, 'ytick', 1000:200:2500);
set(gca,'yTickLabels',1000:200:2500);
set(gca, 'tickdir', 'out');
box off;

subplot(1, 3, 3)

x_lim = [0,100];
x_values = 5:100/8:100;

    
brickplot(ee',...
    green.*ones(8, 3),...
    [1000, 2500],...
    fontsize,...
    '',...
    '',...
    '',...
    symp.*100,1,[0,100], x_values, .18,0);
% %set(gca,'XTick',10:20:90);
% set(gca,'xticklabels',10:20:90);
set(gca, 'ytick', 1000:200:2500);
set(gca,'yTickLabels',1000:200:2500);

set(gca, 'tickdir', 'out');
box off;



saveas(gcf, figname);

writetable(stats_data, stats_filename);

% ------------------------------------------------------------------------%
