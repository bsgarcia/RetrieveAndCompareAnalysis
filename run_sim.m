%-------------------------------------------------------------------------
init;
%-------------------------------------------------------------------------
exp_num = 1;

% load data
name = char(filenames{round(exp_num)});

data = d.(name).data;
sub_ids = d.(name).sub_ids;

[cho, cfcho, out, cfout, corr, con,...
    p1, p2, rew, rtime, ev1, ev2,...
    error_exclude] = extract_learning_data(data, sub_ids, exp, 0);

% set parameters
fit_params.cho = cho;
fit_params.cfcho = cfcho;
fit_params.out = out==1;
fit_params.cfout = cfout==1;
fit_params.con = con;
fit_params.fit_cf = (exp_num > 2);
fit_params.ntrials = size(cho, 2);
fit_params.models = learning_model;
fit_params.nsub = d.(exp_name).nsub;
fit_params.sess = sess;
fit_params.exp_num = num2str(exp_num);
fit_params.decision_rule = 1;
fit_params.q = 0.5;
fit_params.noptions = 2;
fit_params.ncond = length(unique(con));