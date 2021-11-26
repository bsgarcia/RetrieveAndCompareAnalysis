%-------------------------------------------------------------------------
init;
%-------------------------------------------------------------------------
selected_exp = [8.1, 8.2];
displayfig = 'on';
% filenames
filename = 'Fig4brickplot';
figfolder = 'fig';

figname = sprintf('%s/%s.svg', figfolder, filename);
stats_filename = sprintf('data/stats/%s.csv', filename);

figure('Renderer', 'painters','Units', 'centimeters',...
    'Position', [0,0,5.3, 5.3/1.25],...
    'visible', displayfig)
num = 0;

for exp_num = selected_exp
 
    num = num + 1;
    
    data = de.extract_EE(exp_num);
    sess = de.get_sess_from_exp_num(exp_num);
       
    param = load(...
        sprintf('data/midpoints_ED_exp_%d_%d_mle',...
        round(exp_num), sess));
    midpoints1{num} = param.midpoints;
    
    param = load(...
        sprintf('data/midpoints_EE_exp_%d_%d_mle',...
        round(exp_num), sess));
    midpoints2{num} = param.midpoints;

end

midpoints1 = vertcat(midpoints1{:});
midpoints2 = vertcat(midpoints2{:});
beta2 = param.beta1;

ev = unique(data.p1)'.*100;
varargin = ev;
x_values = ev;
x_lim = [0, 100];

subplot(1, 1, 1)

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

 ylabel('Estimated p(win) (%)')


xlabel('E-option p(win) (%)');
box off
hold on

set(gca, 'fontsize', fontsize-.9);
set(gca,'tickdir','out')

% set(gca,'XTick',0.2:0.2:1);
set(gca,'YTick',0:20:100);
xtickangle(45)



saveas(gcf, figname);
