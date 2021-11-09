function new_data = get_heuristic_sub(dd, de)
    
    to_keep = [];
    exp_num = dd.exp_num;
    %---------------------------------------------------------------------%
    % get data parameters                                                 %
    % --------------------------------------------------------------------%
    sess = de.get_sess_from_exp_num(exp_num);
    name = de.get_name_from_exp_num(exp_num);
    nsub = de.get_nsub_from_exp_num(exp_num);
    data = de.extract_ED(exp_num);
    
 
    heur = heuristic(data);
    le = [];
        
    % get le q values estimates
    for i = 1:length(sess)
        sim_params.de = de;
        sim_params.sess = sess(i);
        sim_params.exp_name = name;
        sim_params.exp_num = exp_num;
        sim_params.nsub = nsub;
        sim_params.model = 1;
        
        if length(sess) == 2
            d = de.extract_ED(...
                str2num(sprintf('%d.%d', exp_num, sess(i)+1)));
        else
            d = data;
        end
        
        [Q, tt] = get_qvalues(sim_params);
        
        symp = unique(d.p1);
        le = [le argmax_estimate(d, symp, Q)];
        
    end
    
    o_heur = nan(nsub, 1);
    o_le = nan(nsub, 1);

    for sub = 1:nsub
        o_heur(sub,1) = mean(...
            logical((data.cho(sub,:)==heur(sub,:)) .* (data.cho(sub,:)~=le(sub,:))));
        o_le(sub,1) = mean(...
            logical((data.cho(sub,:)~=heur(sub,:)) .* (data.cho(sub,:)==le(sub,:))));
        if o_heur(sub,1) > o_le(sub,1)
            to_keep(length(to_keep)+1) = sub;
        end
        
    end
    new_data = struct();
    fn = fieldnames(dd);
    for k=1:numel(fn)
        if (ismatrix(dd.(fn{k}))) && (numel(dd.(fn{k})) > 2) && ~ischar(dd.(fn{k}))
            try
            new_data.(fn{k}) = dd.(fn{k})(to_keep, :);
            catch
                disp()
            end
        else
            new_data.(fn{k}) = dd.(fn{k});
        end
    end
    new_data.nsub = length(to_keep);
end



function score = heuristic(data)

    for sub = 1:size(data.cho,1)

        for t = 1:size(data.cho,2)

            if data.p2(sub,t) >= .5
                prediction = 2;
            else
                prediction = 1;
            end

            score(sub, t) = prediction;

        end
    end
end


function score = argmax_estimate(data, symp, values)
    for sub = 1:size(data.cho,1)    
        for t = 1:size(data.cho,2)

            if data.p2(sub,t) >= values(sub, symp==data.p1(sub,t))
                prediction = 2;
            else
                prediction = 1;
            end

            score(sub, t) = prediction;

        end
    end
end



