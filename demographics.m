%------------------------------------------------------------------------
filenames = {
    'interleaved_incomplete', 'block_incomplete', 'block_complete', 'block_complete_simple',...
    'block_complete_mixed',  'block_complete_mixed_2s',...
    'block_complete_mixed_2s_heur'};%------------------------------------------------------------------------
dd = [];

for name = filenames
    name = name{:};
    
    data = readtable(sprintf('data/demographics/%s.csv', name));
    
    d = data.bonus;
    dd = [dd; d];
    i = 1;

end
dd = dd(~isnan(dd));
