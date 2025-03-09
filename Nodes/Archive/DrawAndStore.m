clc; clear; close all;
fig = figure;
axis([-0.0127 0.0762 -0.0127 0.0762]);
hold on;
grid on;
title('Draw your curves (Press Enter when done)');
rectangle('Position',[0, 0, 0.04, 0.07],'EdgeColor','r','LineStyle','--');
all_points = [];
while true
    h = drawfreehand;
    if isempty(h.Position)
        break;
    end
    all_points = [all_points; h.Position; NaN NaN];
    choice = questdlg('Draw another curve?', 'Continue?', 'Yes', 'No', 'Yes');
    if strcmp(choice, 'No')
        break;
    end
end
name = inputdlg('Enter filename (without extension):', 'Save As', [1 50]);
if isempty(name)
    disp('No filename entered. Exiting.');
    return;
end
folder_path = fullfile('Nodes', 'Letters');
if ~exist(folder_path, 'dir')
    mkdir(folder_path);
end
filepath = fullfile(folder_path, [name{1}, '.csv']);
csvwrite(filepath, all_points);
disp(['Data saved to ', filepath]);
