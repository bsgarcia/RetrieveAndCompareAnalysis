function new_Q = sort_Q(Q)
    map = [2 4 6 8 7 5 3 1];
    for i = 1:size(Q, 1)
        t_Q(1:4, 1:2) = Q(i, :, :);
        new_Q(i, :) = reshape(t_Q', [], 1);
        new_Q(i, :) = new_Q(i, map);
    end
end

