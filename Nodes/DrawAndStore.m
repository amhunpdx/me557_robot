
pointdiv = 1;         % subdivides between waypoints
lift_base = 5;        % Base number of points per lift-off 
lift_off_distance = -0.080000;  % Negative => moves pen away from the board along Z
pure_z_steps = 10;     % number of steps with no X,Y movement
stroke_gap_threshold = 0.5 * 0.025400;  % distance between points that triggers lift-off

board_width  = 0.220000;   
board_height = 0.160000;   

% Load robot config (for nominal Z)
[M, Slist, hp] = RobotConfig();
whiteboard_z = M(3,4);  

% Z skew adjustments at corners (meters) using a rigid planar (bilinear) model:
TopLeftZAdjust     = 0.0025;  
TopRightZAdjust    = -0.0025;  
BottomLeftZAdjust  = .0025;  
BottomRightZAdjust = -0.0035;  

CenterZAdjust = 0.12;   % Maximum additional offset at the center (Z adjustment)
CenterWeightPower = 4;  % Exponent controlling decay; higher values produce a sharper drop-off

% Global offset applied uniformly to all waypoints (Z):
BulkZAdjust   = 0.029;  

% Uniform X,Y offsets
x_offset = 0.010000;  
y_offset = 0.06;    


figure;
hold on; axis equal;
xlim([-board_width/2, board_width/2]);
ylim([-board_height/2, board_height/2]);
xlabel('X (m)');
ylabel('Y (m)');
title('Draw on the Whiteboard (2D)');
lettertest01 = [];
stroke_indices = [];  
keepDrawing = true;

while keepDrawing
    h = drawfreehand('Closed', false);
    if isempty(h.Position)
        break;
    end
    
    % Convert 2D points to 3D 
    adjusted_points = [h.Position, repmat(whiteboard_z, size(h.Position, 1), 1)];
    % Optional: add a vertical offset (Y axis) if desired.
    adjusted_points(:,2) = adjusted_points(:,2) + 0.100000;  % REDUNDANT - TEST WITHOUT
    
    if isempty(lettertest01)
        stroke_indices = 1;
        lettertest01 = adjusted_points;
    else
        stroke_indices = [stroke_indices; size(lettertest01, 1) + 1];
        lettertest01 = [lettertest01; adjusted_points]; %#ok<AGROW>
    end
    
    answer = questdlg('Draw more?', 'Continue?', 'Yes', 'No', 'Yes');
    if strcmp(answer, 'No')
        keepDrawing = false;
    end
end

if isempty(lettertest01)
    error('No valid strokes were drawn.');
end

word = [];

% lift off
first_point = lettertest01(1, :);
start_lift = generateLiftSequence(first_point, first_point, lift_off_distance, pointdiv, lift_base, pure_z_steps);
word = [word; start_lift];

% process segments
for i = 1 : (size(lettertest01, 1) - 1)
    p1 = lettertest01(i, :);
    p2 = lettertest01(i+1, :);
    
    % Add p1
    word = [word; p1];
    
    % Interpolate between p1 and p2 
    for j = 1 : (pointdiv - 1)
        alpha = j / pointdiv;
        xy_interp = (1 - alpha) * p1(1:2) + alpha * p2(1:2);
        interp_pt = [xy_interp(1), xy_interp(2), p1(3)];
        word = [word; interp_pt];
    end
    
    % detect liftoff spacing, lift-off where needed
    if ismember(i+1, stroke_indices) || norm(p2(1:2) - p1(1:2)) >= stroke_gap_threshold
        lift_seq = generateLiftSequence(p1, p2, lift_off_distance, pointdiv, lift_base, pure_z_steps);
        word = [word; lift_seq];
    end
end

% add final point
word = [word; lettertest01(end, :)];


last_point = word(end, :);
end_lift = generateFinalLiftSequence(last_point, lift_off_distance, pointdiv, lift_base, pure_z_steps);
word = [word; end_lift];

% apply offsets
max_distance = sqrt((board_width/2)^2 + (board_height/2)^2);
adjusted_word = zeros(size(word));

for i = 1:size(word, 1)
    % 1) Apply uniform X,Y offset.
    x = word(i,1) + x_offset;
    y = word(i,2) + y_offset;
    
    % 2A) Rigid planar (bilinear) offset from the 4 corners.
    u = (x + board_width/2) / board_width;
    v = (y + board_height/2) / board_height;
    planarOffset = (1-u)*(1-v)*BottomLeftZAdjust + ...
                   (1-u)*v*TopLeftZAdjust + ...
                    u*(1-v)*BottomRightZAdjust + ...
                    u*v*TopRightZAdjust;
                
    % 2B) Gravitational center (bowl) offset:
    dist_from_center = sqrt(x^2 + y^2);
    centerMeshOffset = CenterZAdjust * (1 - (dist_from_center / max_distance))^CenterWeightPower;
    
    % 3) Total Z adjustment: sum of the planar, center, and bulk offsets.
    z_adjust = planarOffset + centerMeshOffset + BulkZAdjust;
    
    % 4) Final adjusted point.
    adjusted_word(i,:) = [ x, y, word(i,3) + z_adjust ];
end

% Overwrite word with the final adjusted matrix.
word = adjusted_word;

% Display final result.
disp('Final processed XYZ points (stored in "word"):');
disp(word);

%% functions

function seq = generateLiftSequence(p_start, p_end, lift_off_distance, pointdiv, lift_base, pure_z_steps)


    % Compute the safe lift-off height.
    p_lift_z = p_start(3) + lift_off_distance;
    
    % Segment 1: Pure vertical ascent from p_start to [p_start(1:2), p_lift_z].
    ascent = zeros(pure_z_steps, 3);
    for i = 1:pure_z_steps
        alpha = i / pure_z_steps;
        z_val = p_start(3) + alpha * (p_lift_z - p_start(3));
        ascent(i,:) = [p_start(1), p_start(2), z_val];
    end
    
    % Segment 2: Horizontal interpolation at safe height.
    % Interpolate X,Y from p_start to p_end at constant Z = p_lift_z.
    n_total = lift_base * pointdiv;
    n_horiz = max(n_total - 2 * pure_z_steps, 1);
    horiz = zeros(n_horiz, 3);
    for i = 1:n_horiz
        alpha = i / n_horiz;
        xy_val = (1 - alpha) * [p_start(1), p_start(2)] + alpha * [p_end(1), p_end(2)];
        horiz(i,:) = [xy_val, p_lift_z];
    end
    % Ensure the final horizontal position exactly matches p_end's X,Y.
    horiz(end,1:2) = p_end(1:2);
    
    % Segment 3: Pure vertical descent from safe height to p_end.
    % With X,Y fixed at p_end.
    descent = zeros(pure_z_steps, 3);
    for i = 1:pure_z_steps
        alpha = i / pure_z_steps;
        z_val = p_lift_z + alpha * (p_end(3) - p_lift_z);
        descent(i,:) = [p_end(1), p_end(2), z_val];
    end
    
    % Combine segments.
    seq = [ascent; horiz; descent];
end

function seq = generateFinalLiftSequence(p_start, lift_off_distance, pointdiv, lift_base, pure_z_steps)

    % Compute safe height.
    p_lift = [p_start(1), p_start(2), p_start(3) + lift_off_distance];
    
    % Segment 1: Pure vertical ascent (Z-only) from p_start to p_lift.
    ascent = zeros(pure_z_steps, 3);
    for i = 1:pure_z_steps
        alpha = i / pure_z_steps;
        z_val = p_start(3) + alpha * (p_lift(3) - p_start(3));
        ascent(i,:) = [p_start(1), p_start(2), z_val];
    end
    
    % Segment 2: Stay at p_lift for a fixed number of steps.
    n_stay = max(lift_base * pointdiv - pure_z_steps, 1);
    stay = repmat(p_lift, n_stay, 1);
    
    % Combine segments.
    seq = [ascent; stay];
end
