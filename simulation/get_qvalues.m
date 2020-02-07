function Q = get_qvalues(params, cho, cfcho, con, out, cfout, ntrials, model)
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

    Q = simulation(sim_params);
    % ----------------------------------------------------------%
end
