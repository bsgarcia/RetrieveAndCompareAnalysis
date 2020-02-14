function [Q, params] = get_qvalues(exp_name, sess, cho, cfcho, con, out, cfout, ntrials, fit_cf, model)

    
    data = load(sprintf('data/fit/%s_learning_%d', exp_name, sess));
    parameters = data.data('parameters');
    
    switch model
        case {1, 3}
            alpha1 = parameters{model}(:, 2);
            beta1 = parameters{model}(:, 1);
            params = {beta1, alpha1};
        case 2
            beta1 = parameters{model}(:, 1);
            alpha1 = parameters{model}(:, 2);
            alpha2 = parameters{model}(:, 3);
            params = {beta1, alpha1, alpha2};
    end
    
 
    % ----------------------------------------------------------%
    % Parameters                                                %
    % ----------------------------------------------------------%
    sim_params.noptions = 2;
    sim_params.ntrials = ntrials;
    sim_params.nsub = size(cho, 1);
    sim_params.ncond = length(unique(con));
    sim_params.con = con;
    sim_params.show_window = true;
    %sim_params.beta1 = beta1;
    sim_params.params = params;
    sim_params.out = out;
    sim_params.cfout = cfout;
    sim_params.cho = cho;
    sim_params.cfcho = cfcho;
    sim_params.model = model;
    sim_params.fit_cf = fit_cf;
    Q = simulation(sim_params);
    % ---------------------------------------------------------%
end
