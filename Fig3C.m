%-------------------------------------------------------------------------
init;
%-------------------------------------------------------------------------
selected_exp = [5];
displayfig = 'on';
% filenames
filename = 'Fig3C';
figfolder = 'fig';

figname = sprintf('%s/%s.svg', figfolder, filename);
stats_filename = sprintf('data/stats/%s.csv', filename);

figure('Renderer', 'painters','Units', 'centimeters',...
    'Position', [0,0,5.3*length(selected_exp), 5.3/1.25],...
    'visible', displayfig)
num = 0;

for exp_num = selected_exp
 
    num = num + 1;
    
    data = de.extract_EE(exp_num);
    sess = de.get_sess_from_exp_num(exp_num);
       
    param = load(...
        sprintf('data/midpoints_ED_exp_%d_%d_mle',...
        round(exp_num), sess));
    midpoints1 = param.midpoints;
    
    param = load(...
        sprintf('data/midpoints_EE_exp_%d_%d_mle',...
        round(exp_num), sess));
    midpoints2 = param.midpoints;
    beta2 = param.beta1;
    
    ev = unique(data.p1)'.*100; 
    varargin = ev;
    x_values = ev;
    x_lim = [0, 100];
    
    subplot(1, length(selected_exp), num)

    slope1 = add_linear_reg(midpoints1.*100, ev, orange);   
    hold on
    slope2 = add_linear_reg(midpoints2.*100, ev, green);
    hold on
    
    brick_comparison_plot(...
        midpoints1'.*100,midpoints2'.*100,...
        orange, green, ...
        x_lim, [-8, 108], 11,...
        '',...
        '',...
        '', varargin, x_values, 0);
    
    if num == 1
        ylabel('Estimated p(win) (%)')
    end
    
    xlabel('Symbol p(win) (%)');
    box off
    hold on

    set(gca, 'fontsize', fontsize);
    set(gca,'tickdir','out')
    
   % set(gca,'XTick',0.2:0.2:1);
    set(gca,'YTick',0:20:100);
   
    
end
saveas(gcf, figname);
