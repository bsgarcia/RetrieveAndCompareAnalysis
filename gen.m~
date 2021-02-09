%-------------------------------------------------------------------------
init;
%-------------------------------------------------------------------------
selected_exp = [5, 6.1, 6.2];
displayfig = 'on';
size_factor = 5;

figure('Renderer', 'painters','Units', 'centimeters',...
    'Position', [0,0,5.3*size_factor, 5.3/1.25*size_factor], 'visible', displayfig)
num = 0;

for exp_num = selected_exp
 
    num = num + 1;
    
    sess = de.get_sess_from_exp_num(exp_num);
    nsub = de.get_nsub_from_exp_num(exp_num);
    
    
    data = de.extract_EE(exp_num);
    p1 = data.p1;
    p2 = data.p2;
    corr1 = data.corr;
    
    
    i = 0; j = 0;

    %new_corr = []; corr2 = []; 
    for sub = 1:nsub
        for p = 1:size(p1,2)
            if (all(ismember([p1(sub,p), p2(sub,p)], [.9, .1])))...
                    ||(all(ismember([p1(sub,p), p2(sub,p)], [.8, .2])))...
                    ||(all(ismember([p1(sub,p), p2(sub,p)], [.7, .3])))...
                    ||(all(ismember([p1(sub,p), p2(sub,p)], [.6, .4])))
                i = i + 1;
                new_corr{num}(sub, i) = corr1(sub, p);
              
            else
                j = j + 1;               
                corr2{num}(sub, j) = corr1(sub, p);
            end
        end
    end
end
for 
new_corr = horzcat(new_corr{:});
corr2 = horzcat(corr2{:});


    %subplot(1, length(selected_exp), num)
    t = {new_corr; corr2};
    skylineplot(t, 4.5*size_factor,...
        [green_color; green_color],...
        -0.08,...
        1.08,...
        fontsize*size_factor,...
        '',...
        '',...
        '',...
        {'pair seen', 'pair not seen'},...
        0);
    
    ylabel('CCR');
    
    %title(sprintf('Exp. %s', num2str(exp_num)));
    set(gca, 'tickdir', 'out');
    box off
    box off
    hold on

    set(gca,'tickdir','out')
    
[p, h] = ttest(t{:})
disp(p)
disp(h)
% 
% 
% 
% 
% 
%        
%     param = load(...
%         sprintf('data/post_test_fitparam_ED_exp_%d_%d',...
%         round(exp_num), sess));
%     shift1 = param.shift;
%     beta1 = param.beta1;
%       
%     param = load(...
%         sprintf('data/post_test_fitparam_EE_exp_%d_%d',...
%         round(exp_num), sess));
%     shift2 = param.shift;
%     beta2 = param.beta1;
%     
%     [corr, cho, out2, p1, p2, ev1, ev2, ctch, cont1, cont2, dist] = ...
%         DataExtraction.extract_sym_vs_lot_post_test(...
%         data, sub_ids, idx, sess);
%     
%     ev = unique(p1).*100;
%     varargin = ev;
%     x_values = ev;
%     x_lim = [0, 100];
%     
%     subplot(1, length(selected_exp), num)
% 
% %        
%     slope1 = add_linear_reg(shift1.*100, ev, orange_color);
%     slope2 = add_linear_reg(shift2.*100, ev, green_color);     
%     
%     
%     brick_comparison_plot2(...
%         shift1'.*100,shift2'.*100,...
%         orange_color, green_color, ...
%         [0, 100], 11,...
%         '',...
%         '',...
%         '', varargin, 1, x_lim, x_values);
%     
%     if num == 1
%         ylabel('Indifference point (%)')
%     end
%     
%     xlabel('Symbol p(win) (%)');
%     box off
%     hold on
%     
%     set(gca, 'fontsize', fontsize);
% %     
% %     %set(gca, 'ytick', [0:10]./10);
%     set(gca,'TickDir','out')
%     
%     %title(sprintf('Exp. %s', num2str(exp_num)));
%     
% %     
% %     figure('Renderer', 'painters',...
% %     'Position', [145,157,700,650], 'visible', 'on')
% %     
%     dd(1, :) = slope1(:, 2)';
%     dd(2, :) = slope2(:, 2)';
%     bigdd{1, num} = dd(1, :)';
%     bigdd{2, num} = dd(2, :)';
%     
% % %     m1 = min(log(dd), [], 'all');
% %     m2 = max(log(dd), [], 'all');
% %     if m1 < y1
% %         y1 = m1;
% %     end
% %     if m2 > y2
% %         y2 = m2;
% %     end
% %     
% %      bigdd{1, num} = log(dd(1,:));
% %     bigdd{2, num} = log(dd(2, :));
% 
% %     skylineplot(dd,...
% %         [orange_color; blue_color],...
% %         -1.3,...
% %         1.5,...
% %         20,...
% %         '',...
% %         '',...
% %         '',...
% %         {'ED', 'EE'},...
% %     0);
% %     if exp_num == 5
% %         ylabel('Slope');
% %     end
% %     set(gca, 'tickdir', 'out');
% %     box off
% %     
% %     title('Exp. 6.2');
% %     
% %      figure('Renderer', 'painters',...
% %     'Position', [145,157,700,650], 'visible', 'on')
% %     dd(1, :) = beta1';
% %     dd(2, :) = beta2';
% %     skylineplot(log(dd),...
% %         [orange_color; blue_color],...
% %         min(log(dd),[],'all')-.08,...
% %         max(log(dd),[],'all')+.08,...
% %         20,...
% %         '',...
% %         '',...
% %         '',...
% %         {'ED','EE'},...
% %         0);
% %     
% %     ylabel('Stochasticity');
% %     set(gca, 'tickdir', 'out');
% %     box off
% %     
% %     title(sprintf('Exp. %s', num2str(exp_num)));
%     
%     
% end
% 
% mkdir('fig/exp', 'brickplot');
%         saveas(gcf, ...
%             sprintf('fig/exp/brickplot/EE_2.svg',...
%             num2str(exp_num)));
% 
% slope_ee = {bigdd{1,:}}';
% slope_ed = {bigdd{2,:}}';
% 
% T = table();
% for c = [1, 2, 3]
%     for sub = 1:length(slope_ed{c})
%         T1 = table(sub, c, slope_ed{c}(sub), 2, 'variablenames',...
%             {'subject', 'exp_num', 'slope', 'modality'});
%         T = [T; T1];
%     end
% end
% % end
% for c = [1, 2, 3]
%     for sub = 1:length(slope_ee{c})
%         T1 = table(sub, c, slope_ee{c}(sub), 1, 'variablenames',...
%             {'subject', 'exp_num', 'slope', 'modality'});
%         T = [T; T1];
%     end
% end
% writetable(T, 'data/ED_EE.csv');
% 
% % 
% % figure('Renderer', 'painters',...
% %     'Position', [145,157,700,650], 'visible', 'on')
% % 
% % skyline_comparison_plot({bigdd{1,:}}',{bigdd{2,:}}',...
% %     [orange_color; blue_color],...
% %     y1,...
% %     y2,...
% %     20,...
% %     '',...
% %     '',...
% %     '',...
% %     1:4,...
% %     0);
% % ylabel('log\beta');
% % set(gca, 'tickdir', 'out');
% % box off
% % 
% % return
% % 
% % 
% % slope_ed = {bigdd{1,:}}';
% % slope_ee = {bigdd{2,:}}';
% % 
% % T = table();
% % i = 0;
% % for c = 1:length(selected_exp)
% %     for row = 1:length(slope_ed{c})
% %         i = i +1;
% %         T1 = table(i, c, slope_ed{c}(row), 0, 'variablenames',...
% %             {'subject', 'exp_num', 'slope', 'modality'});
% %         T = [T; T1];
% %     end
% % end
% % i = 0;
% % for c = 1:length(selected_exp)
% %     for row = 1:length(slope_ee{c})
% %         i = i + 1;
% %         T1 = table(i, c, slope_ee{c}(row), 1, 'variablenames',...
% %             {'subject', 'exp_num', 'slope', 'modality'});
% %         T = [T; T1];
% %     end
% % end
% % 
% writetable(T, 'data/ED_EE_anova.csv');