init;
exp = [1, 2, 3, 4, 5, 6, 6.1, 6.2, 7, 7.1, 7.2, 8, 8.1, 8.2];

for e = exp
    LE = de.extract_LE(e);
    save(sprintf('data/struct/LE_exp_%s.mat', num2str(e)), 'data');

    ES = de.extract_ES(e);
    save(sprintf('data/struct/ES_exp_%s.mat', num2str(e)), 'data');
    

    SP = de.extract_PM(e);
    save(sprintf('data/struct/SP_exp_%s.mat', num2str(e)), 'data');
    
    try
        EE = de.extract_EE(e);
        save(sprintf('data/struct/EE_exp_%s.mat', num2str(e)), 'data');
    catch
    end

    try
        EE = de.extract_EE(e);
        save(sprintf('data/struct/EE_exp_%s.mat', num2str(e)), 'data');
    catch
    end
end

function randomize(d)

end
