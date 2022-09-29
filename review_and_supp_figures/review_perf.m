%-------------------------------------------------------------------------
init;
show_current_script_name(mfilename('fullpath'));
%-------------------------------------------------------------------------

%-------------------------------------------------------------------------%
% parameters of the script                                                %
%-------------------------------------------------------------------------%
selected_exp = [6, 7];
displayfig = 'on';
colors = [blue;orange;green;magenta];

num = 0;
%-------------------------------------------------------------------------%
% prepare data                                                            %

for exp_num = selected_exp
    num = num + 1;
 
    
    ES = de.extract_ES(exp_num);
    LE = de.extract_LE(exp_num);
    %SP = de.extract_SP(exp_num);
    EE = de.extract_EE(exp_num);

    m(num) = mean([EE.corr], 'all')

end