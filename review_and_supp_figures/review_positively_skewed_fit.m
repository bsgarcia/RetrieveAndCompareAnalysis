% %-------------------------------------------------------------------------%

init
%-------------------------------------------------------------------------%
factor = 1;
%-------------------------------------------------------------------------%
% parameters of the script                                                %
%-------------------------------------------------------------------------%
selected_exp = [5];
displayfig = 'on';
% filenames
filename = 'review_positively_skewed_fit';
figfolder = 'fig';

fit_folder = 'data/fit/';

figname = sprintf('%s/%s.svg', figfolder, filename);
stats_filename = sprintf('data/stats/%s.csv', filename);
force = 0;
num = 0;


for exp_num = selected_exp

    ES = de.extract_ES(exp_num);
    
    % set parameters
    fit_params.cho = ES.cho;
    fit_params.ntrials = size(ES.cho, 2);
    fit_params.models = [1, 2];
    fit_params.nsub = ES.nsub;
    fit_params.sess = ES.sess;
    fit_params.p1 = ES.p1;
    fit_params.p2 = ES.p2;
    fit_params.exp_num = num2str(exp_num);
    
    save_params.fit_file = sprintf(...
        '%s%s%s%d', fit_folder, ES.name,  '_prelec_', ES.sess);
    
    % fmincon params
    fmincon_params.init_value = {[1, 1, 1], [1, 1,1, 1, 1]};
    fmincon_params.lb = {[0.001, 0.001, 0.001], [0.001, 0.001,0.001, 0.001,0.001]};
    fmincon_params.ub = {[10, 10, 30], [10,10, 10, 10, 30]};
    
    try
        data = load(save_params.fit_file);
        
        %lpp = data.data('lpp');
        fit_params.params = data.data('parameters');  %% Optimization parameters
        ll = data.data('ll');
        %hessian = data.data('hessian');
        
        if force
            error('Force = True');
        end
    catch
        [fit_params.params, ll] = runfit(...
            fit_params, save_params, fmincon_params);
        
    end
    
end

figure('Renderer', 'painters','Units', 'centimeters',...
    'Position', [0,0,5.3*2, 5.3/1.25].*factor, 'visible', displayfig)

subplot(1, 2, 1)
params = fit_params.params{1};
%params = mean(params);
x = 0:.01:1;

p = prelec2(x, params(1), params(2));

plot(x.*100, x.*100, 'LineStyle','--', 'color', 'k')
hold on
plot(x.*100,p.*100,'linewidth', 1.5, 'color', 'k')
hold on

ylabel('w(p(win)) (%)')
xlabel('p(win) (%)')

set(gca, 'FontSize', fontsize.*factor);
box off
set(gca, 'tickdir', 'out')
xticks([0:20:100])
yticks([0:20:100])
ylim([-0.08*100, 1.08*100]);
xlim([-0.08*100, 1.08*100]);

subplot(1, 2, 2)
params = fit_params.params{2};
%params = mean(params);

x = 0:.01:1;

p = prelec2(x, params(1), params(2));

plot(x.*100, x.*100, 'LineStyle','--', 'color', 'k')
hold on
plot(x.*100,p.*100,'linewidth', 1.5, 'color', blue)
hold on
% 
p = prelec2(x, params(3), params(4));
plot(x.*100,p.*100,'linewidth', 1.5, 'color', orange)

ylabel('w(p(win)) (%)')
xlabel('p(win) (%)')

set(gca, 'FontSize', fontsize.*factor);
box off
set(gca, 'tickdir', 'out')
xticks([0:20:100])
yticks([0:20:100])
    ylim([-0.08*100, 1.08*100]);
    xlim([-0.08*100, 1.08*100]);

    saveas(gcf, figname);
% ------------------------------------------------------------------------%
%  side func
% -----------------------------------------------------------------------%
function p = prelec2(x, alpha1, beta1)
% prelec PWF
p = exp(...
    -beta1 .* (-log(x)).^alpha1...
);
% if (x <= .5)
%     p = x;
% end

end

function [parameters,ll] = ...
    runfit(fit_params, save_params, fmincon_params)

   
    options = optimset(...
        'Algorithm',...
        'interior-point',...
        'Display', 'off',...
        'MaxIter', 10000,...
        'MaxFunEval', 10000);

    w = waitbar(0, 'Fitting subject');
    
    tStart = tic;
    for sub = 1:1%fit_params.nsub
        
        waitbar(...
            sub/fit_params.nsub,...  % Compute progression
            w,...
            sprintf('%s%d%s%s', 'Fitting subject ', sub, ' in Exp. ', fit_params.exp_num)...
            );
        
        for model = fit_params.models
         
            
            [
                p1,...
                l1,...
                rep1,...
                grad1,...
                hess1,...
            ] = fmincon(...
                @(x) prelec(...
                    x,...
                    reshape(fit_params.cho(:, :),[],1),...
                    reshape(fit_params.p1(:, :),[],1),...
                    reshape(fit_params.p2(:, :),[],1),...
                    model,...
                    fit_params.ntrials*fit_params.nsub),...
                fmincon_params.init_value{model},...
                [], [], [], [],...
                fmincon_params.lb{model},...
                fmincon_params.ub{model},...
                [],...
                options...
                );
            
            parameters{model}(sub, :) = p1;
            ll(model, sub) = l1;

        end
    end
   toc(tStart);
    % Save the data
   %data = load(save_params.fit_file);
      
   %hessian = data.data('hessian');
   data = containers.Map({'parameters', 'll'},...
            {parameters, ll});
   save(save_params.fit_file, 'data');
     close(w);
%     
end

