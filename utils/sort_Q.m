function new_Q = sort_Q(Q)
    if size(Q, 2) == 4
        map = [2 4 6 8 7 5 3 1];
    else
        map = [2 4 3 1];
    end
    for i = 1:size(Q, 1)
        
        t_Q(1:size(Q,2), 1:2) = Q(i, :, :);

        new_Q(i, :) = reshape(t_Q', [], 1);
        new_Q(i, :) = new_Q(i, map);
    end
end

