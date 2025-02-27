function word = wordbuild(wordInput)
    if length(wordInput) ~= 4
        error('Input must be a 4-letter string');
    end
    
    % Retrieve corresponding matrices from the workspace
    matrices = cell(1,4);
    for i = 1:4
        varName = wordInput(i);  % Use the letter directly
        if evalin('base', ['exist(''' varName ''', ''var'')'])
            matrices{i} = evalin('base', varName);
        else
            error('Matrix for letter %s does not exist in the workspace.', wordInput(i));
        end
    end
    
    % Define transformation shifts
    shifts = [1.75, 0, -1.75, -3.5]; % Shifts each letter along X-axis
    
    % Apply transformations and build word matrix
    word = [];
    for i = 1:4
        transformedMatrix = matrices{i};
        transformedMatrix(:,1) = transformedMatrix(:,1) + shifts(i);
        word = [word; transformedMatrix];
    end
    
    % Replace NaN values with previous row's value in the same column
    for col = 1:size(word, 2) % Iterate through columns
        for row = 2:size(word, 1) % Start from second row to avoid out-of-bounds
            if isnan(word(row, col))
                word(row, col) = word(row - 1, col); % Replace with previous value
            end
        end
    end
end
