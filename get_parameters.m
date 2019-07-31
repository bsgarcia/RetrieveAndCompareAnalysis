function [data, ncond, nsession, sub_ids, idx] = get_parameters()
    data = load('data/first_88');
    data = data.learningdatarandc88(:, :);

    % get parameters
    %------------------------------------------------------------------------
    ncond = max(data(:, 13));
    nsession = max(data(:, 20));
    sub_ids = unique(data(:, 1));
    %sub_ids = sub_ids(2);

    %------------------------------------------------------------------------
    % Define idx columns
    %------------------------------------------------------------------------
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
    idx.ev1 = 23;
    idx.ev2 = 24;
    idx.cont1 = 14;
    idx.cont2 = 15;
    %------------------------------------------------------------------------

end

