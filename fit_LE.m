% -------------------------------------------------------------------%
% This script finds the best fitting Values for each exp             %
% then plots the option value                                        %
% -------------------------------------------------------------------%
init;
% -------------------------------------------------------------------%

selected_exp = [1, 2, 3, 4, 5, 6.1, 6.2, 7.1, 7.2, 8.1, 8.2, 9.1, 9.2];
%selected_exp = selected_exp(1);
sessions = [0, 1];

fit_folder = 'data/fit/';


nfpm = [2, 4];

force = 1;

for exp_num = selected_exp
    
    fprintf('Fitting exp. %s \n', num2str(exp_num));
    
    % -------------------------------------------------------------------%
    % LEARNING
    % -------------------------------------------------------------------%
    data = de.extract_LE(exp_num);
    % set parameters
    fit_params.cho = data.cho;
    fit_params.cfcho = data.cfcho;
    fit_params.out = data.out==1;
    fit_params.cfout = data.cfout==1;
    fit_params.con = data.con;
    fit_params.fit_cf = (exp_num>2);
    fit_params.ntrials = size(data.cho, 2);
    fit_params.model = 1;
    fit_params.nsub = data.nsub;
    fit_params.sess = data.sess;
    fit_params.exp_num = num2str(exp_num);
    fit_params.decision_rule = 1;
    fit_params.q = 0.5;
    fit_params.noptions = 2;
    fit_params.ncond = length(unique(data.con));
    
    save_params.fit_file = sprintf(...
        '%s%s%s%s%d', fit_folder, 'learning_LE',  data.name,  '_session_', data.sess);
    
    % fmincon params
    fmincon_params.init_value = {[1, .5], [0, .5, .5],[0, .5]};
    fmincon_params.lb = {[0.001, 0.001], [0, 0, 0], [0, 0]};
    fmincon_params.ub = {[100, 1], [100, 1, 1], [100, 1]};
    
    try
        data = load(save_params.fit_file);
        
        fit_params.params = data.data('parameters');  %% Optimization parameters
        ll = data.data('ll');
        
        if force
            error('Force = True');
        end
    catch
        [fit_params.params, ll] = runfit_learning(...
            fit_params, save_params, fmincon_params);
        
    end
    
end

    
function [parameters,ll] = ...
    runfit_learning(fit_params, save_params, fmincon_params)

   
    options = optimset(...
        'Algorithm',...
        'interior-point',...
        'Display', 'off',...
        'MaxIter', 10000,...
        'MaxFunEval', 10000);

    w = waitbar(0, 'Fitting subject');
    
    tStart = tic;
    for sub = 1:fit_params.nsub
        
        waitbar(...
            sub/fit_params.nsub,...  % Compute progression
            w,...
            sprintf('%s%d%s%s', 'Fitting subject ', sub, ' in Exp. ', fit_params.exp_num)...
            );
        
        for model = fit_params.model
         
            
            [
                p1,...
                l1,...
                rep1,...
                grad1,...
                hess1,...
            ] = fmincon(...
                @(x) getlpp_learning(...
                    x,...
                    fit_params.con(sub, :),...
                    fit_params.cho(sub, :),...
                    fit_params.cfcho(sub, :),...
                    fit_params.out(sub, :),...
                    fit_params.cfout(sub, :),...
                    fit_params.q,...
                    fit_params.ntrials, model, fit_params.decision_rule,...
                    fit_params.fit_cf),...
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
