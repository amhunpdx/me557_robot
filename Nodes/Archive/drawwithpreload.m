function drawLettersAJ_RealOffsets
    % DRAWLETTERSAJ_REALOFFSETS
    %   Prompts user for a 4-letter word (A–J only), then draws each letter
    %   side by side on an 8cm x 4cm board with margins.
    %
    %   The board is offset in the real robot frame by:
    %       - X offset = 0
    %       - Y offset = +9 inches (~0.2286 m)
    %       - Z offset = +16 inches (~0.4064 m)
    %
    %   G and J are updated for better shapes. 
    %   Now removes any initial (0,0,z_pullback) point to avoid collisions.
    %
    %   The final path is stored in "word" (x,y,z) and plotted in 3D.
    %   Use 'word' for your inverse kinematics solver.
    %
    %   Author: ChatGPT Example

    clc; clear;

    %% ------------------ Real-World Offsets ------------------
    board_center_x = 0.0;       % No X offset
    board_center_y = 0.2286;    % 9 inches in meters
    board_center_z = 0.4064;    % 16 inches in meters

    %% ------------------ Board & Drawing Parameters ------------------
    board_width  = 0.08;   % 8 cm in meters
    board_height = 0.04;   % 4 cm in meters

    % We'll introduce small margins so letters don't fill the board edge-to-edge
    gap_h = 0.002; % 2 mm horizontal gap
    gap_v = 0.002; % 2 mm vertical gap

    % Effective space for letters after subtracting margins
    width_for_letters  = board_width  - 2*gap_h;
    height_for_letters = board_height - 2*gap_v;

    % Each letter is a quarter of the available width
    letter_width  = width_for_letters / 4;
    letter_height = height_for_letters;

    % Pen lift/board contact heights (relative to the robot base frame)
    z_board    = board_center_z;        % Where the pen touches the board
    z_pullback = board_center_z - 0.01; % Lift pen ~1 cm toward robot base

    %% ------------------ Prompt for a 4-letter word (A–J only) ------------------
    valid_letters = 'ABCDEFGHIJ';
    while true
        user_input = upper(input('Enter a 4-letter word (A-J only): ', 's'));
        if length(user_input) == 4 && all(ismember(user_input, valid_letters))
            break;
        else
            disp('Invalid input! Please enter exactly 4 letters from A-J.');
        end
    end

    %% ------------------ Helper Functions ------------------

    % Generate a line segment from (x1,y1) to (x2,y2) in local coords
    % with a small step for sampling
    function seg = lineSeg(x1,y1,x2,y2,step)
        dist = sqrt((x2 - x1)^2 + (y2 - y1)^2);
        N    = max(2, ceil(dist/step)); % at least 2 points
        t    = linspace(0, 1, N);
        seg  = [x1 + (x2 - x1)*t;  y1 + (y2 - y1)*t]';  % Nx2
    end

    % Merge multiple Nx2 segments into one continuous path
    function path2D = mergeSegments(varargin)
        path2D = [];
        for k = 1:nargin
            seg = varargin{k};
            path2D = [path2D; seg]; %#ok<AGROW>
        end
    end

    % Convert local letter coords [0..1]^2 into final board coords
    % for the i-th letter (iIndex in {1,2,3,4}).
    function scaled = scaleAndOffset(path2D, iIndex)
        % Margins from the board center
        left_margin   = -board_width/2  + gap_h;
        bottom_margin = -board_height/2 + gap_v;

        % Horizontal offset for letter i
        xOffset = left_margin + (iIndex-1)*letter_width;
        yOffset = bottom_margin;

        % Scale local coords [0..1] to [0..letter_width/height], then offset
        scaled = zeros(size(path2D));
        scaled(:,1) = xOffset + letter_width  * path2D(:,1);
        scaled(:,2) = yOffset + letter_height * path2D(:,2);

        % Finally shift entire board in real robot frame by board_center_(x,y)
        scaled(:,1) = scaled(:,1) + board_center_x;
        scaled(:,2) = scaled(:,2) + board_center_y;
    end

    % Convert Nx2 -> Nx3 with given Z
    function path3D = to3D(path2D, zval)
        N = size(path2D,1);
        path3D = [path2D, repmat(zval, N, 1)];
    end

    % Pen lift
    function path3D = liftPen(path3D, zLift)
        if isempty(path3D)
            % By default, we used to do: path3D = [0, 0, zLift];
            % But that places a point at (0,0,zLift). We'll skip that now.
            % => Do nothing if path is empty
        else
            path3D = [path3D; path3D(end,1), path3D(end,2), zLift];
        end
    end

    % Pen drop
    function path3D = dropPen(path3D, zBoard)
        % If path is still empty, dropping pen won't work. 
        % We'll only drop if path is non-empty.
        if ~isempty(path3D)
            path3D = [path3D; path3D(end,1), path3D(end,2), zBoard];
        end
    end

    %% ------------------ Define Letters A–J in Local [0..1]^2 ------------------
    % We'll approximate each letter with line segments. G & J are updated.

    step = 0.01; % resolution for line segments

    function path2D = getLetterShape(letter)
        switch letter
            case 'A'
                seg1 = lineSeg(0,0,   0.5,1, step);
                seg2 = lineSeg(0.5,1, 1,0,   step);
                seg3 = lineSeg(0.2,0.5, 0.8,0.5, step);
                path2D = mergeSegments(seg1, seg2, seg3);

            case 'B'
                seg1 = lineSeg(0,0,   0,1, step);
                seg2 = lineSeg(0,1,   0.5,1, step);
                seg3 = lineSeg(0.5,1, 0.7,0.75, step);
                seg4 = lineSeg(0.7,0.75, 0.5,0.5, step);
                seg5 = lineSeg(0.5,0.5,  0,0.5,   step);
                seg6 = lineSeg(0,0.5,   0.5,0.5,  step);
                seg7 = lineSeg(0.5,0.5, 0.7,0.25, step);
                seg8 = lineSeg(0.7,0.25,0.5,0, step);
                seg9 = lineSeg(0.5,0,   0,0, step);
                path2D = mergeSegments(seg1, seg2, seg3, seg4, seg5, ...
                                       seg6, seg7, seg8, seg9);

            case 'C'
                seg1 = lineSeg(1,1,   0,1, step);
                seg2 = lineSeg(0,1,   0,0, step);
                seg3 = lineSeg(0,0,   1,0, step);
                path2D = mergeSegments(seg1, seg2, seg3);

            case 'D'
                seg1 = lineSeg(0,0,   0,1, step);
                seg2 = lineSeg(0,1,   0.8,1, step);
                seg3 = lineSeg(0.8,1, 1,0.5, step);
                seg4 = lineSeg(1,0.5, 0.8,0, step);
                seg5 = lineSeg(0.8,0, 0,0,   step);
                path2D = mergeSegments(seg1, seg2, seg3, seg4, seg5);

            case 'E'
                seg1 = lineSeg(1,1,   0,1, step);
                seg2 = lineSeg(0,1,   0,0, step);
                seg3 = lineSeg(0,0,   1,0, step);
                seg4 = lineSeg(0,0.5, 0.5,0.5, step);
                path2D = mergeSegments(seg1, seg2, seg3, seg4);

            case 'F'
                seg1 = lineSeg(0,0,   0,1, step);
                seg2 = lineSeg(0,1,   1,1, step);
                seg3 = lineSeg(0,0.5, 0.5,0.5, step);
                path2D = mergeSegments(seg1, seg2, seg3);

            case 'G'
                seg1 = lineSeg(1,1,   0,1, step);
                seg2 = lineSeg(0,1,   0,0, step);
                seg3 = lineSeg(0,0,   1,0, step);
                seg4 = lineSeg(1,0,   1,0.5, step);
                seg5 = lineSeg(1,0.5, 0.6,0.5, step);
                path2D = mergeSegments(seg1, seg2, seg3, seg4, seg5);

            case 'H'
                seg1 = lineSeg(0,0, 0,1, step);
                seg2 = lineSeg(1,0, 1,1, step);
                seg3 = lineSeg(0,0.5, 1,0.5, step);
                path2D = mergeSegments(seg1, seg2, seg3);

            case 'I'
                seg1 = lineSeg(0,1, 1,1, step);
                seg2 = lineSeg(0,0, 1,0, step);
                seg3 = lineSeg(0.5,0, 0.5,1, step);
                path2D = mergeSegments(seg1, seg2, seg3);

            case 'J'
                seg1 = lineSeg(0,1, 1,1, step);
                seg2 = lineSeg(1,1, 1,0, step);
                seg3 = lineSeg(1,0, 0,0, step);
                seg4 = lineSeg(0,0, 0,0.2, step);
                path2D = mergeSegments(seg1, seg2, seg3, seg4);

            case 'A'
                seg1 = lineSeg(0,0,   0.5,1, step);
                seg2 = lineSeg(0.5,1, 1,0,   step);
                seg3 = lineSeg(0.2,0.5, 0.8,0.5, step);
                path2D = mergeSegments(seg1, seg2, seg3);

            otherwise
                % fallback (shouldn't happen if user_input is A-J)
                path2D = [0,0];
        end
    end

    %% ------------------ Build the Word Path ------------------
    word = [];

    for i = 1:4
        letter = user_input(i);

        % 1) Get letter shape in local [0..1] coords
        local2D = getLetterShape(letter);

        % 2) Scale and offset for letter i
        scaled2D = scaleAndOffset(local2D, i);

        % 3) Convert to 3D at z_board
        letter3D = to3D(scaled2D, z_board);

        % 4) Lift pen, drop pen, draw letter, lift pen
        word = liftPen(word, z_pullback);
        word = dropPen(word, z_board);
        word = [word; letter3D];
        word = liftPen(word, z_pullback);
    end

    % Move pen off the board
    word = [word; word(end,1), word(end,2), z_pullback];

    %% ------------------ Remove (0,0,z_pullback) If It Exists ------------------
    % If we never added any points before the first letter, there may be a
    % row at [0,0,z_pullback]. This ensures we skip that "floor crash" point.
    if ~isempty(word) && all(word(1,1:2) == 0) ...
            && abs(word(1,3) - z_pullback) < 1e-9
        word(1,:) = [];
    end

    %% ------------------ Display & Plot ------------------
    disp('Generated Word Path (with real offsets):');
    disp(size(word));

    figure;
    plot3(word(:,1), word(:,2), word(:,3), '-o', 'MarkerSize', 1);
    xlabel('X (m)');
    ylabel('Y (m)');
    zlabel('Z (m)');
    title(['Drawing Path for Word: ', user_input]);
    grid on;
    axis equal;

    % If you want "word" in your base workspace:
    assignin('base','word', word);
end
