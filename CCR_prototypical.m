%-------------------------------------------------------------------------
init;
%-------------------------------------------------------------------------

figure('Renderer', 'painters', 'position', [0, 0, 828, 600],...
    'visible', 'on')

bar(80, 'FaceColor', orange_color, 'FaceAlpha', .8, 'edgecolor', 'w');
box off 
ylim([0, 100]);
set(gca, 'tickdir', 'out');
set(gca, 'fontsize', fontsize);