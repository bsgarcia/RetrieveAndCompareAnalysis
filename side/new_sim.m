ev1 = [-.8, -.2, .2, .8];
%ev1 = [-.8, -.6, -.2, .2, .4, .6, .8];
ev2 = [-1, -.8, -.6, -.2, 0, .2, .4, .6, .8, 1];


count = 1;
for i = 1:length(ev1)
    for j = 1:length(ev2)
            trials(count, :) = [ev1(i), ev2(j), i, j];
            count = count + 1;
        
    end
end

% ------------------------------------------------------------------
% Run simulations
%-------------------------------------------------------------------
corr_heuristic = simulate_better_than_zero_heuristic(trials);
disp(mean(corr_heuristic));


% ------------------------------------------------------------------
% Simultion functions
% ------------------------------------------------------------------
function correct = simulate_better_than_zero_heuristic(trials)
for t = 1:length(trials)
    c = [1, 2];
    choice = randi(2);%c(1 + (trials(t, 2) >= .1));
    correct(t) = trials(t, choice) == max(trials(t, 1:2));
end
end