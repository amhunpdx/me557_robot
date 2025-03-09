

% ------------------ USER PARAMETERS ------------------
pointdiv = 3;         % Subdivision for stroke drawing
lift_base = 5;        % Base number of points per phase for lift-offs
lift_off_distance = -0.060000;  % Negative => away from board in z
stroke_gap_threshold = 0.5 * 0.025400;  % 0.5 inch in meters

% Whiteboard dimensions (meters):
board_width  = 0.220000;  
board_height = 0.160000;  

% Load robot config (for nominal z)
[M, Slist, hp] = RobotConfig();
whiteboard_z = M(3,4);  
% Alternatively: whiteboard_z = 16 * 0.025400;

% Z skew adjustments at corners (meters):
TopLeftZAdjust     = 0.015;  
TopRightZAdjust    = 0.0;  
BottomLeftZAdjust  = 0.015;  
BottomRightZAdjust = 0.0;  

% Gravitational center offset (meters):
% This value sets the maximum extra offset at the center.
% It decays linearly to 0 at the board edges.
CenterZAdjust = 0.00;   % Adjust for stronger/weaker center influence

% Global offset applied uniformly to all waypoints:
BulkZAdjust   = 0.02;  

% Uniform x,y offsets (meters):
x_offset = 0.000000;
y_offset = 0.090000;  % Note: these may push points outside the defined board region

% ------------------ SETUP 2D DRAWING FIGURE ------------------
figure;
hold on; axis equal;
xlim([-board_width/2, board_width/2]);
ylim([-board_height/2, board_height/2]);
xlabel('X (m)');
ylabel('Y (m)');
title('Draw on the Whiteboard (2D)');

% ------------------ USER FREEHAND STROKES ------------------
lettertest01 = [];
stroke_indices = [];  % track start of each new stroke
keepDrawing = true;
while keepDrawing
    % drawfreehand returns 2D points [x y]
    h = drawfreehand('Closed', false);
    if isempty(h.Position)
        break;
    end
    
    % Convert 2D points to 3D by assigning whiteboard_z
    adjusted_points = [h.Position, repmat(whiteboard_z, size(h.Position, 1), 1)];
    % Optional: vertical offset if desired
    adjusted_points(:,2) = adjusted_points(:,2) + 0.100000;  
    
    if isempty(lettertest01)
        stroke_indices = 1;
        lettertest01 = adjusted_points;
    else
        stroke_indices = [stroke_indices; size(lettertest01, 1) + 1];
        lettertest01 = [lettertest01; adjusted_points]; %#ok<AGROW>
    end
    
    % Ask user if another stroke is needed
    answer = questdlg('Draw another stroke?', 'Continue?', 'Yes', 'No', 'Yes');
    if strcmp(answer, 'No')
        keepDrawing = false;
    end
end

if isempty(lettertest01)
    error('No valid strokes were drawn.');
end

% ------------------ BUILD FINAL "WORD" WITH INTERPOLATIONS ------------------
% Intermediate "word" holds the unadjusted 3D waypoints.
word = [];

% 1) Generate an initial lift-off from the first point to itself
first_point = lettertest01(1, :);
start_lift = generateLiftSequence(first_point, first_point, lift_off_distance, pointdiv, lift_base);
word = [word; start_lift];

% 2) Process each segment
for i = 1 : (size(lettertest01, 1) - 1)
    p1 = lettertest01(i, :);
    p2 = lettertest01(i+1, :);
    
    % Add p1 to the word
    word = [word; p1];
    
    % Interpolate between p1 and p2 for normal drawing
    for j = 1 : (pointdiv - 1)
        alpha = j / pointdiv;
        xy_interp = (1 - alpha)*p1(1:2) + alpha*p2(1:2);
        interp_pt = [xy_interp(1), xy_interp(2), p1(3)];
        word = [word; interp_pt];
    end
    
    % If stroke break or large gap, insert a normal lift-off (3-phase)
    if ismember(i+1, stroke_indices) || norm(p2(1:2) - p1(1:2)) >= stroke_gap_threshold
        lift_seq = generateLiftSequence(p1, p2, lift_off_distance, pointdiv, lift_base);
        word = [word; lift_seq];
    end
end

% 3) Add the last point
word = [word; lettertest01(end, :)];

% 4) For the final lift, do NOT descend back to the board:
%    Just do Phase 1 (up) + Phase 2 (stay) and skip Phase 3.
last_point = word(end, :);
end_lift = generateFinalLiftSequence(last_point, lift_off_distance, pointdiv, lift_base);
word = [word; end_lift];

% ------------------ APPLY X,Y OFFSETS AND Z ADJUSTMENTS ------------------
% We now combine two effects:
%  A) Rigid planar adjustment (using the 4 corners via bilinear interpolation)
%  B) Gravitational center offset (bowl effect) with maximum at the center.
%
% Also apply the uniform BulkZAdjust.
%
% Compute the maximum distance from the center (for normalization):
max_distance = sqrt( (board_width/2)^2 + (board_height/2)^2 );
adjusted_word = zeros(size(word));

for i = 1:size(word, 1)
    % 1) Apply uniform x,y offset
    x = word(i,1) + x_offset;
    y = word(i,2) + y_offset;
    
    % 2A) Rigid planar (bilinear) offset from the 4 corners:
    u = (x + board_width/2) / board_width;
    v = (y + board_height/2) / board_height;
    planarOffset = (1-u)*(1-v)*BottomLeftZAdjust + ...
                   (1-u)*v*TopLeftZAdjust + ...
                    u*(1-v)*BottomRightZAdjust + ...
                    u*v*TopRightZAdjust;
                
    % 2B) Gravitational center offset (bowl effect):
    % Maximum at the center and decays linearly to 0 at the edges.
    dist_from_center = sqrt(x^2 + y^2);
    centerMeshOffset = CenterZAdjust * (1 - (dist_from_center / max_distance));
    
    % 3) Total z adjustment is the sum of the two effects and the global bulk offset:
    z_adjust = planarOffset + centerMeshOffset + BulkZAdjust;
    
    % 4) Final adjusted point:
    adjusted_word(i,:) = [ x, y, word(i,3) + z_adjust ];
end

% Overwrite word with the final adjusted matrix
word = adjusted_word;

% Display final result
disp('Final processed XYZ points (stored in "word"):');
disp(word);

%% ------------------------------------------------------------------------
%% HELPER FUNCTIONS
%% ------------------------------------------------------------------------
function seq = generateLiftSequence(p_start, p_end, lift_off_distance, pointdiv, lift_base)
% Normal 3-phase lift-off used for mid-stroke or between strokes:
%   1) p_start -> p_lift (vertical)
%   2) Stay at p_lift
%   3) p_lift -> p_end
%
% Each phase has n_phase = pointdiv * lift_base points => total 3*n_phase

    n_phase = lift_base * pointdiv;
    
    % The lift point is directly above p_start in z
    p_lift = [ p_start(1), p_start(2), p_start(3) + lift_off_distance ];
    
    %% Phase 1: Vertical interpolation from p_start to p_lift
    z_phase1 = linspace(p_start(3), p_lift(3), n_phase+1);
    z_phase1 = z_phase1(2:end);  % Skip duplicating p_start
    phase1 = [ repmat(p_start(1:2), n_phase, 1), z_phase1' ];
    
    %% Phase 2: Stay at p_lift
    phase2 = repmat(p_lift, n_phase, 1);
    
    %% Phase 3: Descend from p_lift to p_end
    x_phase3 = linspace(p_lift(1), p_end(1), n_phase+1);
    y_phase3 = linspace(p_lift(2), p_end(2), n_phase+1);
    z_phase3 = linspace(p_lift(3), p_end(3), n_phase+1);
    x_phase3 = x_phase3(2:end);
    y_phase3 = y_phase3(2:end);
    z_phase3 = z_phase3(2:end);
    phase3 = [ x_phase3', y_phase3', z_phase3' ];
    
    seq = [phase1; phase2; phase3];
end

function seq = generateFinalLiftSequence(p_start, lift_off_distance, pointdiv, lift_base)
% Final 2-phase lift-off used at the very end:
%   1) p_start -> p_lift (vertical)
%   2) Stay at p_lift
% NO final descent.
%
% Each phase has n_phase = pointdiv * lift_base points => total 2*n_phase

    n_phase = lift_base * pointdiv;
    
    % The lift point is directly above p_start in z
    p_lift = [ p_start(1), p_start(2), p_start(3) + lift_off_distance ];
    
    %% Phase 1: Vertical interpolation from p_start to p_lift
    z_phase1 = linspace(p_start(3), p_lift(3), n_phase+1);
    z_phase1 = z_phase1(2:end);  % Skip duplicating p_start
    phase1 = [ repmat(p_start(1:2), n_phase, 1), z_phase1' ];
    
    %% Phase 2: Stay at p_lift
    phase2 = repmat(p_lift, n_phase, 1);
    
    seq = [phase1; phase2];
end
