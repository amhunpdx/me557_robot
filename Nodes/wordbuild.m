function wordMatrix = wordbuild(word)
    if length(word) ~= 4
        error('Input must be a 4-letter string');
    end

    min_spacing = 0.00635; % Minimum spacing between points (1/4 inch in meters)
    whiteboard_offset = 0.4064; % Distance from base to whiteboard (meters)

    matrices = cell(1,4);
    for i = 1:4
        varName = word(i);  
        if evalin('base', ['exist(''' varName ''', ''var'')'])
            matrices{i} = evalin('base', varName);
        else
            error('Matrix for letter %s does not exist in the workspace.', word(i));
        end
    end

    shifts = [.04, 0, -.04, -.08];
    wordMatrix = [];

    for i = 1:4
        transformedMatrix = matrices{i};
        transformedMatrix(:,1) = transformedMatrix(:,1) + shifts(i); % Apply letter spacing
        transformedMatrix(:,2) = transformedMatrix(:,2) + whiteboard_offset; % Move to whiteboard

        % Downsample by removing close points
        reducedMatrix = transformedMatrix(1, :); % Keep first point

        for j = 2:size(transformedMatrix, 1)
            if norm(transformedMatrix(j, 1:3) - reducedMatrix(end, 1:3)) >= min_spacing
                reducedMatrix = [reducedMatrix; transformedMatrix(j, :)];
            end
        end

        wordMatrix = [wordMatrix; reducedMatrix];
    end
end
