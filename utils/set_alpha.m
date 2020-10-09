function c = set_alpha(rgb, a)
    c = (1-a).* [1, 1, 1] + rgb .* a;
end
    
