init;

figure('Units', 'centimeters',...
    'Position', [0,0,5.3*5, 5.3/1.25*2.3], 'visible', 'on')


nsample = 1:1:10;
num = 0;
nsub = 100;

for ns = nsample
    num = num + 1;

    ES = de.extract_ES(5);

    p_sym = unique(ES.p1);
    p_lot = unique(ES.p2);
  
    for i = 1:nsub
    for j = 1:length(p_sym)
        %sample = getsample(LE.out(i, :), LE.cfout(i,:), p_sym(k), LE.cho(i, :), LE.p1(i,:), LE.p2(i,:), x(i,1));
        sample = rand(ns,1) < p_sym(j);
        px = postp(sample);
            
        npx = length(px);
        for k = 1:length(p_lot)
            p2 = sum(px(1:round(p_lot(k)*npx))); % probability that the symbolic object value is larger than the experential object value.
    
            pchoicesym(i,j,k) = 1-p2;


        end
    end
    end

    subn = 1:length(nsample);
    
    subplot(2, 5, subn(num))
    colors = orange;
    prop = squeeze(mean(pchoicesym, 1));

    pwin = p_sym;
    alpha = linspace(.15, .95, length(p_sym));
    lin1 = plot(...
        linspace(p_sym(1)*100, p_sym(end)*100, 12), ones(12,1)*50,...
        'LineStyle', ':', 'Color', [0, 0, 0], 'HandleVisibility', 'off');

    for i = 1:length(pwin)

        hold on

        lin3 = plot(...
            p_lot.*100,  prop(i, :).*100,...
            'Color', colors(1,:), 'LineWidth', 1.5 ...% 'LineStyle', '--' ...
            );

        lin3.Color(4) = alpha(i);

        hold on

        [xout, yout] = intersections(lin3.XData, lin3.YData, lin1.XData, lin1.YData);

        sc2 = scatter(xout, yout, 20, 'MarkerFaceColor', lin3.Color,...
            'MarkerEdgeColor', 'w');
        sc2.MarkerFaceAlpha = alpha(i);

        if ismember(num, [1, 6])
            ylabel('P(choose E-option) (%)');
        end

        if ismember(num, 6:10)
            xlabel('S-option p(win) (%)');
        end

        ylim([-0.08*100, 1.08*100]);
        xlim([-0.08*100, 1.08*100]);

        box off
    end

    set(gca,'TickDir','out')
    %set(gca, 'FontSize', 20);
    xticks([0:20:100])
    yticks([0:20:100])

    xtickangle(0)
    title(sprintf('N=%d', ns))

    clear pchoicesym;
    %    title(['N=',num2str(Nsample)])
end

saveas(gcf, 'sim_uncertainty_ES.svg')


%%%%%%%% Function "postp" %%%%%%%%%%%%%%%%%%%%%%%%%%%%

% The function computes a discretized probability distribution over values from Nsample
% binary samples (0 = no reward, 1 = reward), generated with probability preal.

function px = postp(out)

%Generate N random samples with p(X_n = 1) = preal
X = out;
%Compute the discretized posterior probability distribution (discretization
%step = 0.01). Here we assume that the prior over value is flat:

prop = 0.01:.01:0.99;

logpx = sum(X.*log(prop) + (1-X) .* log(1-prop),1);

px = exp(logpx)./(sum(exp(logpx)));%betapdf(prop, sum(X), sum(X==0))./100
end


function out = getsample(out, cfout, p_sym, cho_LE, p1_LE, p2_LE, x)
mask_out = logical((((p1_LE == p_sym) .* (cho_LE==1)) + ((p2_LE == p_sym) .* (cho_LE==2))));
mask_cfout = logical((((p1_LE == p_sym) .* (cho_LE==2)) + ((p2_LE == p_sym) .* (cho_LE==1))));
outs = shuffle([out(mask_out) cfout(mask_cfout)]);
out = outs(1:x);
end
