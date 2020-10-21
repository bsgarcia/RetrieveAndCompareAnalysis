% --------------------------------------------------------------------
% This script is ran by other scripts at init 
% --------------------------------------------------------------------
close all
clear all

addpath './fit'
addpath './plot'
addpath './data'
addpath './'
addpath './utils'
addpath './simulation'


format shortg

%------------------------------------------------------------------------
% Set parameters
%------------------------------------------------------------------------
% filenames and folders
filenames = {
    'interleaved_incomplete', 'block_incomplete', 'block_complete', 'block_complete_simple',...
    'block_complete_mixed',  'block_complete_mixed_2s',...
    'block_complete_mixed_2s_amb_final',...
    'block_complete_mixed_2s_amb_heuristic'};

folder = 'data';

% exclusion criteria
rtime_threshold = 100000;
catch_threshold = 1;
% if different from 0 then select the number of best sub
n_best_sub = 0;

allowed_nb_of_rows = [...
    258, 288,... %exp 1, 2, 8
    255, 285,... %exp 3
    376, 470,... %exp 4 
    648, 658,... %exp 5
    742, 752 ... %exp 6, 7
    216,... %exp 8
    ];

% display figures
displayfig = 'off';


%-----------------------------------------------------------------------
% colors
%-----------------------------------------------------------------------

colors = [0.3963    0.2461    0.3405;...
    1 0 0;...
    0.7875    0.1482    0.8380;...
    0.4417    0.4798    0.7708;...
    0.5992    0.6598    0.1701;...
    0.7089    0.3476    0.0876;...
    0.2952    0.3013    0.3569;...
    0.1533    0.4964    0.2730];

%blue_color = [0.0274 0.427 0.494];
blue_color = [0    0.4470    0.7410];
%blue_color = [14/255, 151/255, 165/255];
%blue_color = colors(1, :);
blue_color_min = [0 0.686 0.8];

light_blue = [141/255 160/255 203/255];
light_orange = [252/255 141/255 98/255];
light_magenta = [231/255,138/255,195/255];
light_green = [173/255,205/255,131/255];

magenta_color = [166/255 77/255 121/255];

% create a default color map ranging from blue to dark blue
len = 8;
blue_color_gradient = zeros(len, 3);
blue_color_gradient(:, 1) = ...
    linspace(blue_color_min(1),blue_color(1),len)';
blue_color_gradient(:, 2) = ...
    linspace(blue_color_min(2),blue_color(2),len)';
blue_color_gradient(:, 3) = ...
    linspace(blue_color_min(3),blue_color(3),len)';

orange_color = [0.8500, 0.3250, 0.0980];
green_color = [0.4660    0.6740    0.1880];
green_color = [61/255, 176/255, 125/255];
red_color = [0.6350    0.0780    0.1840];

red_to_blue(:, 1) = ...
    linspace(red_color(1),blue_color(1),len)';
red_to_blue(:, 2) = ...
    linspace(red_color(2),blue_color(2),len)';
red_to_blue(:, 3) = ...
    linspace(red_color(3),blue_color(3),len)';

%-------------------------------------------------------------------------
% Plot parameters
%------------------------------------------------------------------------
fontsize = 6;


%-------------------------------------------------------------------------
% Load Data (do cleaning stuff)
%-------------------------------------------------------------------------
[d, idx] = load_data(filenames, folder, rtime_threshold, catch_threshold, ...
    n_best_sub, allowed_nb_of_rows);
show_loaded_data(d);
show_parameter_values(rtime_threshold, catch_threshold, allowed_nb_of_rows);


%-------------------------------------------------------------------------
% Define functions
%-------------------------------------------------------------------------
function [d, idx] = load_data(filenames, folder,  rtime_threshold,...
    catch_threshold, n_best_sub, allowed_nb_of_rows)

    d = struct();
    i = 1;
    for f = filenames
        [dd{i}, sub_ids{i}, idx] = DataExtraction.get_data(...
            sprintf('%s/%s', folder, char(f)));
        i = i + 1;
    end
    
    i = 1;
    for f = filenames
        d = setfield(d, char(f), struct());
        new_d = getfield(d, char(f));
        
        before_sub_ids = DataExtraction.exclude_subjects(...
            dd{i}, sub_ids{i}, idx, catch_threshold, rtime_threshold,...
            n_best_sub, allowed_nb_of_rows);
        
        [cho, cfcho, out, cfout, corr2, con, p1, p2, rew, rt, ev1, ev2, error_exclude] = ...
            DataExtraction.extract_learning_data(...
                dd{i}, before_sub_ids, idx, [0, 1]);
            
        to_select = 1:length(before_sub_ids);
        to_select(error_exclude) = [];
        
        new_d.sub_ids = before_sub_ids(to_select);
        new_d.data = dd{i};
        
        new_d.nsub = length(new_d.sub_ids);
        d = setfield(d, char(f), new_d);

        i = i + 1;
    end
    
end


function show_loaded_data(d)
    disp(repmat('=', [1, 30]));
    disp('RUNNING init.m SCRIPT');
    disp(repmat('=', [1, 30]));
    
    disp('Loaded struct with fields: ');
    filenames = fieldnames(d);
    disp(filenames);
    disp('N sub:');
    for f = filenames'
        f = f{:};
        if ~strcmp(f, 'idx')
            fprintf('%s: N=%d \n', f, d.(f).nsub);
        end
    end
end


function show_parameter_values(rtime_threshold, catch_threshold,...
    allowed_number_of_rows)

    fprintf('\nParameter values:\n');
    fprintf('Response time threshold=%d seconds\n', rtime_threshold/1000);
    fprintf('Correct catch trials threshold=%d  \n', catch_threshold.*100);
    fprintf(['Number of trials allowed and retrieved per subject=' ...
        repmat('%d ', 1, length(allowed_number_of_rows))], allowed_number_of_rows);
    fprintf('\n');
    disp(repmat('=', [1, 30]));
    fprintf('RUNNING SELECTED SCRIPT \n');
    disp(repmat('=', [1, 30]));
    
end