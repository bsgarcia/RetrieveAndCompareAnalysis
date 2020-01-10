function out = question(str, answer1, answer2)
    answer = questdlg(str, ...
        'Info',...
        answer1,...
        answer2,...
        answer1);
    % Handle response
    switch answer
        case answer1
            fprintf('Choice = %s \n', answer1);
        case answer2
            fprintf('Choice = %s \n', answer2);
        otherwise
            error('Window was closed, exiting...');
    end
    out = answer;
end

