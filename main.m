clear all
%------------------------------------------------------------------------
data = load('data/first_88');
data = data.learningdatarandc88(:, :);

%----------------------------------
%sem = @(x) std(x)./sqrt(size(data,2));



% get parameters
%------------------------------------------------------------------------
ncond = max(data(:, 13));
nsession = max(data(:, 20));
sub_ids = unique(data(:, 1));
%sub_ids = sub_ids(2);
sim = 1;
choice = 2;

%------------------------------------------------------------------------
% Define idx columns
%------------------------------------------------------------------------
idx.rtime = 6;
idx.cond = 13;
idx.sess = 20;
idx.trial_idx = 12;
idx.cho = 9;
idx.out = 7;
idx.corr = 10;
idx.rew = 19;
idx.catch = 25;
idx.elic = 3;
idx.sub = 1;
idx.p1 = 4;
idx.p2 = 5;
idx.ev1 = 23;
idx.ev2 = 24;
idx.dist = 28;
idx.plot = 29;
idx.cont1 = 14;
idx.cont2 = 15;
%idx.prolific = 2;
%------------------------------------------------------------------------

corr_catch = extract_catch_trials(data, sub_ids, idx);
[cho1, out1, corr1, con1, rew] = extract_learning_data(...
    data, ncond, nsession, sub_ids, idx);
[corr, cho, out2, p1, p2, ev1, ev2, ctch, cont1, cont2] = extract_elicitation_data(...
    data, sub_ids, idx, 0);

% Split depending on optimism tendency
% -----------------------------------------------------------------------
data = load('data/fit/online_exp');
parameters = data.data('parameters');
delta_alpha = parameters(:, 2, 2) - parameters(:, 3, 2);
[sorted, idx_order] = sort(delta_alpha);
cho = cho(idx_order, :);
p2 = p2(idx_order, :);
cont1 = cont1(idx_order, :);

psym = zeros(4, 2);
for con = 1:4
    for c = 1:2
        temp = out1(logical((con1 == con) .* (cho1 == c))) == 1;
        psym(con , c) = mean(temp);
    end
end

figure
bar(psym);
ylabel('P(outcome=1)')
xlabel('Conditions')
legend('Option 1', 'Option 2')
ylim([0, 1.0]);
    
%------------------------------------------------------------------------
% Compute corr choice rate
%------------------------------------------------------------------------
corr_rate = zeros(size(corr1, 1), 30, 4);

for sub = 1:size(corr1, 1)
    for t = 1:30
        for j = 1:4
            d = corr1(sub, con1(sub, :) == j);
            corr_rate(sub, t, j) = mean(d(1:t));
        end
    end
end

%------------------------------------------------------------------------
% PLOT
%------------------------------------------------------------------------
%i = 1;
titles = {'-0.8 vs 0.8', '-0.6 vs 0.6', '-0.4 vs 0.4', '-0.2 vs 0.2'};
figure;
for cond = 1:4
    subplot(1, 4, cond)

    reversalplot(...
        corr_rate(:, :, cond)',...
        [],...
        [],...
        ones(3) * 0.5,...
        [0.4660    0.6740    0.1880],...
        1,...
        0.38,...
        -0.01,...
        1.01,...
        15,...
        titles{cond},...
        'trials',...
        'correct choice rate' ...
    );

    i = i + 1;
end


% ----------------------------------------------------------------------
% Compute for each symbol p of chosing depending on described cue value
% ------------------------------------------------------------------------
pcue = [0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1];
cont = unique(cont1);
plearn = zeros(length(pcue), length(cont));
for i = 1:size(corr, 1)
    for j = 1:length(pcue)
        for k = 1:length(cont)
            temp = cho(i, logical((p2(i, :) == pcue(j)) .* (cont1(i, :) == cont(k))));
            disp(temp);
            plearn(i, j, k) = temp == 1;
        end
    end
end


titles = {'Low \Delta\alpha', 'High \Delta\alpha'};
tt = 0;
for k = {1:45, 46:90}
    tt = tt + 1;
    k = k{:};
    prop = zeros(length(cont), length(pcue));
    for j = 1:length(pcue)
        for l = 1:length(cont)
           temp1 = cho(k, :);
           temp = temp1(logical((p2(k, :) == pcue(j)) .* (cont1(k, :) == cont(l))));
           prop(l, j) = mean(temp == 1);
       end
    end
   
    X = repmat(pcue, 45, 1);
    pp = zeros(length(cont), length(pcue));
    for i = 1:length(cont)
        Y = plearn(k, :, i);
        disp(i);
        %     [B,dev,stats] = mnrfit(X, Y);
        %     pp(i, :) = mnrval(B, plearn(:, :, i));
        [logitCoef,dev] = glmfit(...
            reshape(X, [], 1), reshape(plearn(k, :, i), [], 1), 'binomial','logit');
        pp(i, :) = glmval(logitCoef,pcue','logit');
    end


    figure
    pwin = [0.1, 0.2, 0.3, 0.4, 0.6, 0.7, 0.8, 0.9];
    suptitle(titles{tt});

    for i = 1:length(cont)
        subplot(4, 2, i)
        lin = plot(...
            pcue,  pp(i, :),... %'bs', pcue, pp(i, :),  'b-', 'MarkerEdgeColor',...
            'Color', [0.4660    0.6740    0.1880] ...
            );
        ind_point = interp1(lin.YData, lin.XData, 0.5);
        if mod(i, 2) ~= 0
            ylabel('P(choose learnt value)');
        end
        if ismember(i, [7, 8])
            xlabel('Described cue win probability');
        end
        hold on
        scatter(pcue, prop(i, :), 'MarkerEdgeColor', [0.4660    0.6740    0.1880]);
        scatter(ind_point, 0.5, 'MarkerFaceColor', 'r');

        plot(ones(10)*pwin(i), linspace(0.1, 0.9, 10), 'LineStyle', '--', 'Color', [0, 0, 0], 'LineWidth', 0.6);
        %[xi,yi] = polyxpoly(ones(10)*pwin(i),linspace(0.1, 0.9, 10),pcue,  pp(i, :));
        %scatter(xi, yi, 'Color', 'r');
        if i < 6
        text(pwin(i)+0.03, 0.8, sprintf('P(win) = %0.1f', pwin(i)), 'FontSize', 7);
        else

            text(pwin(i)-0.30, 0.8, sprintf('P(win) = %0.1f', pwin(i)), 'FontSize', 7);
        end

        plot(linspace(0, 1, 12), ones(12)*0.5, 'LineStyle', ':', 'Color', [0, 0, 0]);
        ylim([-0.08, 1.08]);
        xlim([-0.08, 1.08]);   
    end
end

[corr, cho, out2, p1, p2, ev1, ev2, ctch, cont1, cont2] = extract_elicitation_data(...
    data, sub_ids, idx, 2);
i = 1;
for p = pwin
    mn(i, :) = cho(p1(:, :) == p);
    i = i + 1;
end


figure
pirateplot(...
    mn, rand(8, 3),...
    -0.8, 100.8, 20, 'Slider choices' , 'P(win of learnt value)',...
    'Choice (% of odds reward is +1)', pwin)

%set(ha(1:4),'XTickLabel',''); set(ha,'YTickLabel','')

function [cho, out, corr, con, rew] = extract_learning_data(data, ncond, nsession, sub_ids, idx)
i = 1;
for id = 1:length(sub_ids)
    sub = sub_ids(id);
    mask_sub = data(:,1) == sub;
    if ismember(sum(data(:, 1) == sub), [255, 285])
            %mask_cond = data(:, idx.cond) == cond;
            mask_sess = ismember(data(:, idx.sess), [0]);
            mask_eli = data(:, idx.elic) == -1;
            mask = logical(mask_sub .* mask_sess .* mask_eli);
            [noneed, trialorder] = sort(data(mask, idx.trial_idx));
            tempcho = data(mask, idx.cho);
            cho(i, :) = tempcho(trialorder);
            tempout = data(mask, idx.out);
            out(i, :) = tempout(trialorder);
            tempcorr = data(mask, idx.corr);
            corr(i, :) = tempcorr(trialorder);
            temprew = data(mask, idx.rew);
            rew(i, :) = temprew(trialorder);
            tempcon = data(mask, idx.cond);
            con(i, :) = tempcon(trialorder) + 1;
%             temp_prolid = str2num(data(mask, idx.prolific));
%             prolid(i, :) = temp_prolid(trialorder);
%         if sum(corr(i, :)) > 90
             i = i+1;
%         end
    end
end
end

function [corr_catch] = extract_catch_trials(data, sub_ids, idx)
i = 1;
for id = 1:length(sub_ids)
    sub = sub_ids(id);
    if ismember(sum(data(:, 1) == sub), [255, 285])
        for eli = [0, 2]
            
            mask_eli = data(:, idx.elic) == eli;
            if eli == 0
                eli = 1;
            end
            mask_sub = data(:, idx.sub) == sub;
            mask_catch = data(:, idx.catch) == 1;
            mask_sess = ismember(data(:, idx.sess), [0]);
            mask = logical(mask_sub .* mask_sess .* mask_catch .* mask_eli);
            [noneed, trialorder] = sort(data(mask, idx.trial_idx));
            temp_corr = data(mask, idx.corr);
            corr_catch{i, eli} = temp_corr(trialorder);
        end
        i = i + 1;
    end
end
end

function [corr, cho, out, p1, p2, ev1, ev2, ctch, cont1, cont2] = ...
    extract_elicitation_data(data, sub_ids, idx, eli)
i = 1;
for id = 1:length(sub_ids)
    sub = sub_ids(id);
    if ismember(sum(data(:, 1) == sub), [255, 285])
        
        mask_eli = data(:, idx.elic) == eli;
        mask_sub = data(:, idx.sub) == sub;
        mask_catch = data(:, idx.catch) == 0;
        mask_sess = ismember(data(:, idx.sess), [0]);
        mask = logical(mask_sub .* mask_sess .* mask_eli .* mask_catch);
        
        [noneed, trialorder] = sort(data(mask, idx.trial_idx));
        
        temp_corr = data(mask, idx.corr);
        corr(i, :) = temp_corr(trialorder);
        
        temp_cho = data(mask, idx.cho);
        cho(i, :) = temp_cho(trialorder);
        
        temp_out = data(mask, idx.out);
        out(i, :) = temp_out(trialorder);
        
        temp_ev1 = data(mask, idx.ev1);
        ev1(i, :) = temp_ev1(trialorder);
        
        temp_catch = data(mask, idx.catch);
        ctch(i, :) = temp_catch(trialorder);
        
        temp_cont1 = data(mask, idx.cont1);
        cont1(i, :) = temp_cont1(trialorder);
        
        temp_ev2 = data(mask, idx.ev2);
        ev2(i, :) = temp_ev2(trialorder);
        
        temp_cont2 = data(mask, idx.cont2);
        cont2(i, :) = temp_cont2(trialorder);
        
        temp_p1 = data(mask, idx.p1);
        p1(i, :) = temp_p1(trialorder);
        
        temp_p2 = data(mask, idx.p2);
        p2(i, :) = temp_p2(trialorder);
        
%         temp_prolid = str2num(data(mask, idx.prolific));
%         prolid(i, :) = temp_prolid(trialorder);
%         if sum(corr(i, :)) > 40
         i = i + 1;
%         end
        
    end
end
end
