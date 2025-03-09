% Load robot configuration
[M, Slist, hp] = RobotConfig();

% Define fixed whiteboard dimensions
board_width = 0.20;   % 20 cm in meters
board_height = 0.15;  % 15 cm in meters

% Get the end-effector z-position from home position
whiteboard_z = M(3,4); % Extract the z-value from M

% Setup figure
figure;
hold on;
axis equal;
xlim([-board_width/2, board_width/2]);
ylim([-0.1, 0.1]); % Adjusted Y range
zlim([whiteboard_z - 0.01, whiteboard_z + 0.01]); % Slight padding
xlabel('X (m)');
ylabel('Y (m)');
zlabel('Z (m)');
title('Draw on the Whiteboard');

% Draw whiteboard outline
rectangle('Position', [-board_width/2, -board_height/2, board_width, board_height], 'EdgeColor', 'k');

% Initialize storage
lettertest01 = [];

% User draws multiple strokes
keepDrawing = true;
while keepDrawing
    h = drawfreehand('Closed', false);
    if isempty(h.Position) % If no points were drawn, break loop
        break;
    end
    
    % Flip Y-coordinates, shift DOWN by 8cm to correct positioning
    adjusted_points = [h.Position(:,1), ...
                       -h.Position(:,2) + 0.08, ...  % Corrected: Moves drawing down
                       repmat(whiteboard_z, size(h.Position,1), 1)];
    
    % Append new stroke data to lettertest01
    if isempty(lettertest01)
        lettertest01 = adjusted_points;
    else
        lettertest01 = [lettertest01; adjusted_points]; %#ok<AGROW>
    end

    % Ask if another stroke is needed BEFORE moving to processing
    answer = questdlg('Draw another stroke?', 'Continue?', 'Yes', 'No', 'Yes');
    if strcmp(answer, 'No')
        keepDrawing = false;
    end
end

% Now process lettertest01 to insert transition points
updated_lettertest = lettertest01(1, :); % Start with the first point
gap_threshold = 0.02; % 2 cm in meters
num_transition_points = 5; % Number of interpolated points

for i = 2:size(lettertest01, 1) - 1 % Ignore first and last points
    prev_point = lettertest01(i - 1, :);
    curr_point = lettertest01(i, :);
    
    % Compute Euclidean distance in XY plane
    gap = norm(curr_point(1:2) - prev_point(1:2));
    
    % If gap is greater than threshold, insert transition points
    if gap > gap_threshold
        for j = 1:num_transition_points
            % Interpolate X and Y positions
            interp_xy = prev_point(1:2) + (curr_point(1:2) - prev_point(1:2)) * (j / num_transition_points);
            % Keep Z at 0.3 for transition points
            transition_point = [interp_xy(1), interp_xy(2), 0.3];
            updated_lettertest = [updated_lettertest; transition_point]; %#ok<AGROW>
        end
    end
    
    % Append current point after transition points
    updated_lettertest = [updated_lettertest; curr_point]; %#ok<AGROW>
end

% Add 5 extra rows at the start with Z = 0.3
first_point = updated_lettertest(1, :);
start_lift = repmat([first_point(1), first_point(2), 0.3], 5, 1);
updated_lettertest = [start_lift; updated_lettertest]; %#ok<AGROW>

% Add 5 extra rows at the end with Z = 0.3
last_point = updated_lettertest(end, :);
end_lift = repmat([last_point(1), last_point(2), 0.3], 5, 1);
updated_lettertest = [updated_lettertest; end_lift]; %#ok<AGROW>

% Display final processed points
disp('Processed XYZ points with transitions:');
disp(updated_lettertest);
