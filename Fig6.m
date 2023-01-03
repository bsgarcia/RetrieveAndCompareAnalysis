p1 = [.1, .2, .3, .4, .6, .7, .8, .9];
p2 = 0:.1:1;

coordinates = [0, 0, 1, 2];
EE = repmat({'EE'}, 7, 1);
ES = repmat({'ES'}, 11, 1);
figure
for i = 1:length(p1)
    t = shuffle([EE; ES]);
    trials = [t; {'catch'}];
    trials = [trials; {'blank'}];

    n = length(trials);
    count = 0;
    for t = trials'
        count = count + 1;
        
        if count == 1
            curvature = 0;
        elseif count == n
            curvature = 0;
        else
            curvature = 0;
        end
        edgecolor = 'black';

        if strcmp(t, 'EE')
           color = green; 
           
        end
        if strcmp(t, 'ES')

            color = orange;
        end
        if strcmp(t, 'catch')
            continue

        end
        if strcmp(t, 'blank')
            color = 'white';
            edgecolor='white';
        end

        color(4) = .55;
        rectangle('Position', coordinates, 'curvature', curvature, 'facecolor', color, 'EdgeColor', edgecolor);
        hold on 
        coordinates(1) = coordinates(1) + 1;
        coordinates(3) = coordinates(2) + 1;
   
     end
    
end


ylim([0, 5]);
set(gca, 'tickdir', 'out')
h = gca; h.YAxis.Visible = 'off';