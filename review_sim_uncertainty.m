figure
%
%
% %%%%%%%%  Main program %%%%%%%%%%%%%%%%%%
%
% data_LE = de.extract_LE(1);
% data_ED = de.extract_ED(1);
% %Values for the symbolic object
%
% plot = unique(data_ED.p2);
% psym = unique(data_ED.p1);
% %Values for the experiential object
% %prx = [0.2:0.1:0.8]; Nx = length(prx);
%
%
% %Discretization of the prob axis (for vizualization).
% %pri = [0.01:0.01:0.99];
%
% %figure
%
%
% for Nsample = 1:2:9
%
% %
% %     pchoicesym = zeros(Nsubj,Nx,Ns);
% %
% %     for subj=1: Nsubj
% %         for k=1:Nx
% %             preal = prx(k);
% %             px = postp(preal,Nsample);
% %             Npx = length(px);
% %             for l = 1:Ns
% %                 psym = prs(l);
% %                 pchoicesym(subj,k,l) = sum(px(1:round(psym*Npx))); % probability that the symbolic object value is larger than the experential object value.
% %             end
% %         end
% %     end
% %
% %     subplot(2,5,5+5-round(Nsample-1)/2)
% %     plot(prs,squeeze(mean(1-pchoicesym,1))')
% %     xlabel('value for symbolic cue')
% %     ylabel('p choose non-symbolic cue')
% %     title(['N=',num2str(Nsample)])


%This is last part is just to plot the mean posteriors over experiential values:
%
%
%     postall = zeros(Nx,length(px));
%
%     for subj=1:Nsubj
%        for k = 1:Nx
%             preal = prx(k);
%             px = postp(preal,Nsample);
%             postall(k,:) = postall(k,:)+1/Nsubj * px;
%        end
%     end
%
%     subplot(2,5,5-round(Nsample-1)/2)
%     plot(pri,postall')
%     xlabel('value')
%     ylabel('prob(value)')
%     title(['N=',num2str(Nsample)])
%     if Nsample == 9
%         legend('realvalue = 0.8','realvalue = 0.7','realvalue = 0.6','realvalue = 0.5','realvalue = 0.4','realvalue = 0.3','realvalue = 0.2')
%
%     end

% end
init;

figure('Units', 'centimeters',...
    'Position', [0,0,5.3*5, 5.3/1.25*2.3], 'visible', 'on')


selected_exp = [4];
nsample = 1:2:20;
num = 0;

for ns = nsample
    num = num + 1;

for exp_num = selected_exp

    LE = de.extract_LE(exp_num);
    ES = de.extract_ES(exp_num);

    fit_params.nsub = LE.nsub;
    fit_params.exp_num = exp_num;

    fit_params.cho_LE = LE.cho;
        fit_params.cho_ED = ES.cho;
        fit_params.out = LE.out;
        fit_params.cfout = LE.cfout;
        fit_params.p1_LE = LE.p1;
        fit_params.p1_ED = ES.p1;
        fit_params.p2_LE = LE.p2;
    fit_params.p2_ED = ES.p2;

    save_params = [];

    %[x,ll] = runfit(fit_params);

end
x(:,1) =ones(LE.nsub, 1) .* ns;
p_sym = unique(ES.p1);
p_lot = unique(ES.p2);
trials = 1:length(LE.cho(1,:));

for i=1:LE.nsub
    for k=1:length(p_sym)
        sample = getsample(LE.out(i, :), LE.cfout(i,:), p_sym(k), LE.cho(i, :), LE.p1(i,:), LE.p2(i,:), trials, x(i,1));
        
        px = postp(sample);
        
        npx = length(px);
        for l = 1:length(p_lot)
            p2 = sum(px(1:round(p_lot(l)*npx))); % probability that the symbolic object value is larger than the experential object value.
            p1 = 1 - p2;
            %p = exp([p1, p2].*x(i,2))./sum(exp([p1, p2].*x(i,2)));
        
            pchoicesym(i,k,l) = p1;
            pchoicelot(i,k,l) = p2;


        end
    end
end
% 
% figure
% plot(p_lot,squeeze(mean(pchoicesym,1))')
% xlabel('value for symbolic cue')
% ylabel('p choose non-symbolic cue')
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

    sc2 = scatter(xout, yout, 40, 'MarkerFaceColor', lin3.Color,...
        'MarkerEdgeColor', 'w');
    sc2.MarkerFaceAlpha = alpha(i);

    if ismember(num, [1, 6])
        ylabel('P(choose E-option) (%)');
    end

    xlabel('S-option p(win) (%)');

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
%    title(['N=',num2str(Nsample)])
end

function [parameters,ll] = runfit(fit_params)

options = optimset(...
    'Algorithm',...
    'interior-point',...
    'Display', 'off',...
    'MaxIter',100000,...
    'MaxFunEval', 100000);

% function [c,ceq] = cons(x)
%     c(1) = double(~(mod(x, 1)));
%     ceq = [];
% end
% nonlin = @cons;
w = waitbar(0, 'Fitting subject');

tStart = tic;
for sub = 1:fit_params.nsub

    waitbar(...
        sub/fit_params.nsub,...  % Compute progression
        w,...
        sprintf('%s%d%s%s', 'Fitting subject ', sub, ' in Exp. ', fit_params.exp_num)...
        );



    [
        p1,...
        l1,...
        rep1,...
        grad1,...
        hess1,...
        ] = fmincon(...
        @(x) getparams(...
        x,...
        fit_params.cho_LE(sub, :),...
        fit_params.cho_ED(sub, :),...
        fit_params.out(sub, :),...
        fit_params.cfout(sub, :),...
        fit_params.p1_LE(sub, :),...
        fit_params.p1_ED(sub,:),...
        fit_params.p2_LE(sub,:),...
        fit_params.p2_ED(sub,:)),...
        [1],...
        [], [], [], [],...
        [.2], ...
        [11.9],...
        [],...
        options...
        );

    parameters(sub,:) = p1;
    ll(sub) = l1;

end
toc(tStart);
% Save the data
%data = load(save_params.fit_file);

%hessian = data.data('hessian');
% param.par
% save(save_params.fit_file, 'data');
% close(w);


%
end


function nll = getparams(x, cho_LE, cho_ED, out, cfout, p1_LE, p1_ED, p2_LE, p2_ED)
x(1) = round(x(1), 1)*10;
p_sym = unique(p1_ED);
p_lot = unique(p2_ED);
pchoicelot = nan(length(p_sym), length(p_lot));
pchoicesym = nan(length(p_sym), length(p_lot));
trials = 1:length(cho_LE);
ll = 0;

for i = 1:length(p_sym)
    mask_out = logical((((p1_LE == p_sym(i)) .* (cho_LE==1)) + ((p2_LE == p_sym(i)) .* (cho_LE==2))) .* (trials>(length(trials)-x(1))));
    mask_cfout = logical((((p1_LE == p_sym(i)) .* (cho_LE==2)) + ((p2_LE == p_sym(i)) .* (cho_LE==1))).*(trials>(length(trials)-x(1))));
    sample = [out(mask_out) cfout(mask_cfout)];
    px = postp(sample);
    npx = length(px);
    for j = 1:length(p_lot)
        p2 = sum(px(1:round(p_lot(j)*npx))); % probability that the symbolic object value is larger than the experential object value.
        p1 = 1 - p2;

        %p = exp([p1, p2].*x(2))./sum(exp([p1, p2].*x(2)));
        
        pchoicesym(i,j) = p1;
        pchoicelot(i,j) = p2;
    end
end

idx1 = 1:length(p_sym);
idx2 = 1:length(p_lot);

pchoice = {pchoicesym, pchoicelot};

for t = 1:length(cho_ED)

    idt1 = idx1(p1_ED(t)==p_sym);
    idt2 = idx2(p2_ED(t)==p_lot);

    p = pchoice{cho_ED(t)}(idt1, idt2);

    if (p==0) 
        p = 0.0001;
    end

    if (p==1)
        p = .999;
    end


    ll = ll + log(p); 
    %disp(log(p))
end

nll = real(-ll);
end



%%%%%%%% Function "postp" %%%%%%%%%%%%%%%%%%%%%%%%%%%%

% The function computes a discretized probability distribution over values from Nsample
% binary samples (0 = no reward, 1 = reward), generated with probability preal.

function px = postp(out)

%Generate N random samples with p(X_n = 1) = preal

X = out'==1;
%Compute the discretized posterior probability distribution (discretization
%step = 0.01). Here we assume that the prior over value is flat:

prop = 0.1:0.01:.99;

logpx = sum(X*log(prop) + (1-X) * log(1-prop),1);

px = exp(logpx)./(sum(exp(logpx)));
end


function out = getsample(out, cfout, p_sym, cho_LE, p1_LE, p2_LE, trials, x)
mask_out = logical((((p1_LE == p_sym) .* (cho_LE==1)) + ((p2_LE == p_sym) .* (cho_LE==2))) .* (trials>(length(trials)-x(1))));
mask_cfout = logical((((p1_LE == p_sym) .* (cho_LE==2)) + ((p2_LE == p_sym) .* (cho_LE==1))) .* (trials>(length(trials)-x(1))));
out = shuffle([out(mask_out) cfout(mask_cfout)]);
end
