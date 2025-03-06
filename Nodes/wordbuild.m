function word = wordbuild(wordStr)
    if length(wordStr) ~= 4
        error('Input must be a 4-letter string');
    end

    % Default corner distances in meters (16 inches = 0.406400 m)
    persistent z_tl z_tr z_bl z_br;
    if isempty(z_tl) || isempty(z_tr) || isempty(z_bl) || isempty(z_br)
        z_tl = 0.406400; 
        z_tr = 0.406400;
        z_bl = 0.406400;
        z_br = 0.406400;
    end

    % Whiteboard dimensions in meters
    board_width = 0.330200;  % 13 inches
    board_height = 0.317500; % 12.5 inches
    board_x_center = 0;      % Centered at x = 0
    board_y_center = board_height / 2; % Centered vertically

    % Retrieve corresponding matrices from the workspace
    matrices = cell(1,4);
    for i = 1:4
        varName = wordStr(i);  % Use the letter directly
        if evalin('base', ['exist(''' varName ''', ''var'')'])
            matrices{i} = evalin('base', varName);
        else
            error('Matrix for letter %s does not exist in the workspace.', wordStr(i));
        end
    end

    % Define transformation shifts
    shifts = [.04, 0, -.04, -.08];

    % Compute the average Z-distance (reference Z-level)
    avg_z = (z_tl + z_tr + z_bl + z_br) / 4;

    % Distance threshold for pen lift (0.5 inches in meters)
    lift_threshold = 0.012700;

    % Pen lift height (2 inches in meters)
    pen_lift_height = 0.050800;

    % Lift position (14 inches in meters)
    lift_position = 0.355600;

    % Apply transformations and build word matrix
    word = [];
    for i = 1:4
        transformedMatrix = matrices{i};
        transformedMatrix(:,1) = transformedMatrix(:,1) + shifts(i);

        % Compute the Z offset based on proximity to board corners
        for j = 1:size(transformedMatrix, 1)
            x = transformedMatrix(j, 1);
            y = transformedMatrix(j, 2);

            % Normalize (0 to 1) based on board width and height
            x_ratio = (x - (board_x_center - board_width / 2)) / board_width;
            y_ratio = (y - (board_y_center - board_height / 2)) / board_height;

            % Bilinear interpolation for Z value
            z = (1 - x_ratio) * (1 - y_ratio) * z_tl + ...
                x_ratio * (1 - y_ratio) * z_tr + ...
                (1 - x_ratio) * y_ratio * z_bl + ...
                x_ratio * y_ratio * z_br;

            % Compute the offset from the average
            z_offset = z - avg_z;

            % Assign calculated Z value (with 6 decimal places)
            transformedMatrix(j,3) = round(avg_z + z_offset, 6);
        end

        % Insert pen lift if needed
        adjustedMatrix = [];
        for j = 1:size(transformedMatrix, 1) - 1
            adjustedMatrix = [adjustedMatrix; transformedMatrix(j, :)];

            % Compute distance between current and next point
            dist = sqrt(sum((transformedMatrix(j+1, 1:2) - transformedMatrix(j, 1:2)).^2));

            if dist > lift_threshold
                % Insert lift point at same X,Y but lifted in Z
                lift_row = [transformedMatrix(j, 1:2), round(transformedMatrix(j, 3) + pen_lift_height, 6)];
                adjustedMatrix = [adjustedMatrix; lift_row];
            end
        end

        % Append the last row
        adjustedMatrix = [adjustedMatrix; transformedMatrix(end, :)];

        % Append to final word matrix
        word = [word; adjustedMatrix];
    end

    % Add lift rows at the start and end
    lift_row = [0, 0, lift_position];
    word = [lift_row; word; lift_row];

    % Store the final word matrix in the base workspace
    assignin('base', 'word', word);
end
