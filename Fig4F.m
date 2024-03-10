%-------------------------------------------------------------------------
init;
%-------------------------------------------------------------------------
selected_exp = [7.1];
displayfig = 'on';
% filenames
filename = 'Fig4F';
figfolder = 'fig';

figname = sprintf('%s/%s.svg', figfolder, filename);
stats_filename = sprintf('data/stats/%s.csv', filename);

figure('Renderer', 'painters','Units', 'centimeters',...
    'Position', [0,0,5.3*length(selected_exp), 5.3/1.25],...
    'visible', displayfig)
num = 0;
fitname_ES = 'data/fit/midpoints_ES_%s_session_%d';
fitname_EE = 'data/fit/midpoints_EE_%s_session_%d';

for exp_num = selected_exp
 
    num = num + 1;
    
    data = de.extract_EE(exp_num);
    name = data.name;
    sess = data.sess;
       
    param = load(...
        sprintf(fitname_ES,...
        name, sess));
    midpoints1 = param.midpoints;
    
    param = load(...
        sprintf(fitname_EE,...
       name, sess));
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
    
    xlabel('E-option p(win) (%)');
    box off
    hold on

    set(gca, 'fontsize', fontsize);
    set(gca,'tickdir','out')
    
   % set(gca,'XTick',0.2:0.2:1);
    set(gca,'YTick',0:20:100);
    xtickangle(65)
   
    
end
saveas(gcf, figname);
