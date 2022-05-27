% --------------------------------------------------------------------
% This script is ran by other scripts at init 
% --------------------------------------------------------------------
tic
%close all

if exist('de')
    clearvars -except de
else
    clear all
end

addpath './fit'
addpath './plot'
addpath './data'
addpath './'
addpath './utils'
addpath './simulation'


format long g

%------------------------------------------------------------------------
% Set parameters
%------------------------------------------------------------------------
% filenames and folders
filenames = {
   'interleaved_incomplete', 'block_incomplete', 'block_complete',...
   'block_complete_simple',...
   'block_complete_mixed',  'block_complete_mixed_2s','block_complete_mixed_2s_amb_heuristic',...
   'block_complete_mixed_2s_amb_final',...
   };
filenames = {'incentivize'};

folder = 'data/raw/';

% exclusion criteria
%rtime_threshold = 1500000000000000;
rtime_threshold = 90000;

ES_catch_threshold = 0; PM_catch_threshold = 0; PM_corr_threshold = .25;
% if different from 0 then select the number of best sub
n_best_sub = 0;

allowed_nb_of_rows = [...
    258, 288,... %exp 2, 3
    255, 285,... %exp 1
    376, 470,... %exp 5
    572,... %exp9
    648, 658,... %exp 6, 7, 8
    742, 752,746 ... %exp 6, 7, 8
    216,... %exp 4
    583,...
    ];


%-----------------------------------------------------------------------
% colors
%-----------------------------------------------------------------------

% created using coloors website
orange = [0.8500, 0.3250, 0.0980];
blue = [0    0.4470    0.7410];
%green_color = [0.4660    0.6740    0.1880];
green = [61/255, 176/255, 125/255];
red = [0.6350    0.0780    0.1840];
dark_green = [37/255 89/255 87/255];
magenta = [166/255 77/255 121/255];
black = [73/255 72/255 80/255];
pink = [146 119 135]./255;
yellow = [255 200 87]./255;
dark_blue = [42 30 92]./255;


% from fig 5 explained choices
light_blue = [166 177 225]./255;
purple = [220 214 247]./255;
grey = [202 207 214]./255;

% red_to_blue(:, 1) = ...
%     linspace(red_color(1),blue_color(1),len)';
% red_to_blue(:, 2) = ...
%     linspace(red_color(2),blue_color(2),len)';
% red_to_blue(:, 3) = ...
%     linspace(red_color(3),blue_color(3),len)';


% From set2 seaborn
% green = [102 194 165]./255;
% blue = [141 160 203]./255;
% orange = [252 141 98]./255;
% magenta = [231 138 195]./255;
% colors = [[0.4       , 0.76078431, 0.64705882];...
%        [0.98823529, 0.55294118, 0.38431373];...
%        [0.55294118, 0.62745098, 0.79607843];...
%        [0.90588235, 0.54117647, 0.76470588];...
%        [0.65098039, 0.84705882, 0.32941176];...
%        [1.        , 0.85098039, 0.18431373];...
%        [0.89803922, 0.76862745, 0.58039216];...
%        [0.70196078, 0.70196078, 0.70196078]];
% green = colors(1,:);
% orange = colors(2,:);
% blue = colors(3,:);
% magenta = colors(4,:);
% lime = colors(5,:);
% yellow = colors(6,:);
% taupe = colors(7,:);
% gray = colors(8,:);

%-------------------------------------------------------------------------
% Plot parameters
%------------------------------------------------------------------------
fontsize = 6;
% display figures
displayfig = 'off';



if ~exist('de')
%-------------------------------------------------------------------------
% Load Data (do cleaning stuff)
%-------------------------------------------------------------------------
de = load_data(filenames, folder, rtime_threshold,  ES_catch_threshold, PM_catch_threshold, PM_corr_threshold, ...
    n_best_sub, allowed_nb_of_rows);
end
%end
show_loaded_data(de.d);
show_parameter_values(rtime_threshold, ES_catch_threshold, PM_catch_threshold, PM_corr_threshold, allowed_nb_of_rows);
toc
%-------------------------------------------------------------------------
% Define functions
%-------------------------------------------------------------------------
function de = load_data(filenames, folder,  rtime_threshold,...
     ES_catch_threshold, PM_catch_threshold, PM_corr_threshold, n_best_sub, allowed_nb_of_rows)

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
        disp(sprintf('Treating %s', char(f)));
        % exclude subject based on exclusion criteria
        before_sub_ids = DataExtraction.exclude_subjects(...
            dd{i}, sub_ids{i}, idx, ES_catch_threshold, PM_catch_threshold, PM_corr_threshold, rtime_threshold,...
            n_best_sub, allowed_nb_of_rows);
        
        % try to retrieve data and see if there is any error (missing
        % trials etc..)
        
        [cho, cfcho, out, cfout, corr2, con, p1, p2, rew, rt, ev1, ev2, error_exclude] = ...
            DataExtraction.extract_learning_data(...
                dd{i}, before_sub_ids, idx, [0, 1]);
       
        % if there is one exclude them
        to_select = 1:length(before_sub_ids);
        to_select(error_exclude) = [];
        
        new_d.sub_ids = before_sub_ids(to_select);
        new_d.data = dd{i};
        
        new_d.nsub = length(new_d.sub_ids);
        d = setfield(d, char(f), new_d);

        i = i + 1;
    end
    de = DataExtraction(d, filenames, idx);
    
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


function show_parameter_values(rtime_threshold, ES_catch_threshold, PM_catch_threshold, PM_corr_threshold,...
    allowed_number_of_rows)

    fprintf('\nParameter values:\n');
    fprintf('Response time threshold=%d seconds\n', rtime_threshold/1000);
    fprintf('Correct catch trials (ES, PM, PM_corr) threshold=%d,%d,%d  \n', [ES_catch_threshold, PM_catch_threshold, PM_corr_threshold].*100);
    fprintf(['Number of trials allowed and retrieved per subject=' ...
        repmat('%d ', 1, length(allowed_number_of_rows))], allowed_number_of_rows);
    fprintf('\n');   
    
end