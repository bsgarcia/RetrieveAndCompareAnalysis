init;

selected_exp = [6.1, 7.1];

count = 0;
conv = [0.62, 1.2];


for num = 1:length(conv)
    pounds = conv(num);
    b = ones(2, 2) .* pounds;
    % bonus_LE = [];
    % bonus_ES_EE = [];
    bonus = [];
    for i = 1:10
        count = 0;
        b1 = [];
        for exp_num = selected_exp
            count = count + 1;

            LE = de.extract_LE(exp_num);
            ES = de.extract_ES(exp_num);
            EE = de.extract_EE(exp_num);

            for sub = 1:LE.nsub
                EE_ES = [ES.out(sub,:)'; EE.out(sub,:)'];

                o1 = randsample(...
                    LE.out(sub, :), 1, true,...
                    repmat([1/length(LE.out(sub,:))], 1, length(LE.out(sub,:))));

                o2 = randsample(...
                    EE_ES, 1, true,...
                    repmat([1/length(EE_ES)], 1, length(EE_ES)));


                %             bonus_LE = [bonus_LE; o1*b(count, 1)];
                %             bonus_ES_EE = [bonus_ES_EE; o2*b(count, 2)];
                b1(count, sub) = o1*b(count, 1)+o2*b(count, 2);

            end

        end

        bonus = [bonus; 2.5+sum(b1)'];

    end

    % bonus = sum([bonus_LE ; bonus_ES_EE], 'all');
    %
    subplot(1, 2, num)
    skylineplot(bonus', 22, blue.*ones(size(bonus)), -3, 9, 20, sprintf('1pt=%.2f£, avg bonus=%.2f£', pounds, mean(bonus)), '', 'pounds (£) ', {''}, 0);
end
