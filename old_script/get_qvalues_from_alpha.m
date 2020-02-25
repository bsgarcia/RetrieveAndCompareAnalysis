function qvalues = get_qvalues_from_alpha(alphas, a, out, s, cfa, cfout)

    nsub = size(alphas, 1);
    tmax = size(a, 2);

    for sub = 1:nsub       
        alpha1 = alphas(sub, 1);
        alpha2 = alphas(sub, 2);

        Q = zeros(4, 2);       
        for t = 1:tmax         
            deltaI = out(sub, t) - Q(s(sub, t), a(sub, t));
            Q(s(sub, t), a(sub, t)) = Q(s(sub, t), a(sub, t)) + alpha1 * deltaI;
            
            if ~all(cfout(:, :) == 0)
                deltaCF = cfout(sub, t) - Q(s(sub, t), cfa(sub, t));
                Q(s(sub, t), cfa(sub, t)) = Q(s(sub, t), cfa(sub, t)) + alpha2 * deltaCF;
            end

        end
        qvalues(sub, :, :) = Q(:, :);
    end

end
