% Load robot configuration
[M, Slist, hp] = RobotConfig();

% Define fixed whiteboard dimensions
board_width = 0.22;   % 20 cm in meters
board_height = 0.16;  % 15 cm board + 10 cm height correction

% Get the end-effector z-position from home position
whiteboard_z = M(3,4); % Z is distance from the robot base

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

% Initialize storage
lettertest01 = [];
stroke_indices = []; % Store indices where new strokes begin

% User draws multiple strokes
keepDrawing = true;
while keepDrawing
    h = drawfreehand('Closed', false);
    if isempty(h.Position) % If no points were drawn, break loop
        break;
    end

    % Ensure Z-values exist (assume strokes start at whiteboard_z)
    adjusted_points = [h.Position, repmat(whiteboard_z, size(h.Position, 1), 1)];
    adjusted_points(:,2) = adjusted_points(:,2) + 0.10; % Apply height correction

    if isempty(lettertest01)
        stroke_indices = [stroke_indices; 1];
        lettertest01 = adjusted_points;
    else
        stroke_indices = [stroke_indices; size(lettertest01, 1) + 1];
        lettertest01 = [lettertest01; adjusted_points]; %#ok<AGROW>
    end

    % Ask if another stroke is needed BEFORE moving to processing
    answer = questdlg('Draw another stroke?', 'Continue?', 'Yes', 'No', 'Yes');
    if strcmp(answer, 'No')
        keepDrawing = false;
    end
end

% Ensure lettertest01 is not empty before proceeding
if isempty(lettertest01)
    error('No valid strokes were drawn.');
end

% Define point division parameter
pointdiv = 1; % Change this value to adjust the number of subdivisions
lift_off_distance = -0.03; % Move away from the board (in Z direction)
stroke_gap_threshold = 0.5 * 0.0254; % 0.5 inches converted to meters

% Process lettertest01 to insert interpolated points and lift-off mechanism
word = [];

% Add initial lift-off points (Move away in Z)
first_point = lettertest01(1, :);
if size(first_point, 2) < 3
    error('lettertest01 does not have a Z column. Check input stroke data.');
end
start_lift = repmat([first_point(1), first_point(2), first_point(3) + lift_off_distance], 5, 1);
word = [word; start_lift]; %#ok<AGROW>

for i = 1:size(lettertest01, 1) - 1
    p1 = lettertest01(i, :);
    p2 = lettertest01(i+1, :);
    
    % Append the first point of the pair
    word = [word; p1]; %#ok<AGROW>
    
    % Generate interpolated points
    for j = 1:pointdiv - 1
        alpha = j / pointdiv;
        interp_xy = (1 - alpha) * p1(1:2) + alpha * p2(1:2);
        interp_point = [interp_xy(1), interp_xy(2), p1(3)]; % Keep same Z
        word = [word; interp_point]; %#ok<AGROW>
    end
    
    % Check if the next point is the start of a new stroke
    if ismember(i+1, stroke_indices) || norm(p2(1:2) - p1(1:2)) >= stroke_gap_threshold
        % Insert lift-off points before switching strokes (Move away in Z)
        lift_off = repmat([p2(1), p2(2), p2(3) + lift_off_distance], 5, 1);
        word = [word; lift_off]; %#ok<AGROW>
    end
end

% Append the last point
word = [word; lettertest01(end, :)];

% Add final lift-off points (Move away in Z)
last_point = word(end, :);
end_lift = repmat([last_point(1), last_point(2), last_point(3) + lift_off_distance], 5, 1);
word = [word; end_lift]; %#ok<AGROW>

% Display final processed points
disp('Processed XYZ points with interpolations and lift-off mechanism:');
disp(word);
