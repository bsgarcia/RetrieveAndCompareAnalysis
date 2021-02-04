function colors = colorgradient(color1, color2, ncolor)
    for i = 1:3
        colors(:, i) = linspace(color1(i), color2(i), ncolor)';
    end
end

