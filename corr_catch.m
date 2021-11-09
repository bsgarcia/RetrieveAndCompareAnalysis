init

exp = [1, 2, 3];
sub_count = 0;
num = 0;
for exp_num = exp
    num = num + 1;
    ES = de.extract_ED(exp_num);
    PM = de.extract_PM(exp_num);
    %

    %     for sub = 1:ES.nsub
    %         PM.ctch_corr(sub, :) = abs(PM.ctch_cho(sub, :)./100 - PM.ctch_p1(sub,:)) < .2;
    %
    %     end
    p = unique(PM.ctch_p1);
    disp(p)
%     for sub = 1:ES.nsub
%         for i = 1:length(p)
%             dd(sub, i) = PM.ctch_cho(sub, PM.ctch_p1(sub, :)==p(i))./100;
% 
%         end
%     end
%     colors = (magenta.*ones(size(dd,1), 3));
%     subplot(2, 2, num)
%     brickplot(dd', ...
%         colors,...
%         [0,1],...
%         fontsize*2.1,...
%         sprintf('Exp %s', num2str(exp_num)),...
%         '',...
%         '',...
%         p, 0, [-.01, .9], [.2, .4, 6, .8], .05, 0);
% 
%     clear dd

end
