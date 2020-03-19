function ll = manual_fit(params, s, a, cfa, r, cfr, q, ntrials, model, decision_rule,fit_cf)

    addpath './'
    
    model_str = {'QLearning', 'AsymmetricQLearning'};
    
    model = models.(model_str{model})(params, q, 4, 2, ntrials, decision_rule);
    ll = -model.fit(s, a, cfa, r, cfr, fit_cf);
    
end
