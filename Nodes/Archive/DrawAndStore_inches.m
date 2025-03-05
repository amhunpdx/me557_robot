clc; clear; close all;

% Create a figure for drawing
fig = figure;
axis([-0.5 3 -0.5 3]); % Adjusted axis limits
hold on;
grid on;
title('Draw your curves (Press Enter when done)');

all_points = []; % Initialize an empty array for storing points

while true
    % Let the user draw a freehand curve
    h = drawfreehand;
    
    % Get the position (x, y) data
    if isempty(h.Position)
        break;
    end
    
    % Append to the list, adding a NaN row as a separator
    all_points = [all_points; h.Position; NaN NaN];
    
    % Ask if they want to draw another
    choice = questdlg('Draw another curve?', 'Continue?', 'Yes', 'No', 'Yes');
    if strcmp(choice, 'No')
        break;
    end
end

% Prompt user for a filename
name = inputdlg('Enter filename (without extension):', 'Save As', [1 50]);
if isempty(name)
    disp('No filename entered. Exiting.');
    return;
end

% Define the path inside "Nodes/Letters"
folder_path = fullfile('Nodes', 'Letters');
if ~exist(folder_path, 'dir')
    mkdir(folder_path);
end

filepath = fullfile(folder_path, [name{1}, '.csv']);

% Save to CSV
csvwrite(filepath, all_points);

disp(['Data saved to ', filepath]);
