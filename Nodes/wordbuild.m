function wordMatrix = wordbuild(word)
    if length(word) ~= 4
        error('Input must be a 4-letter string');
    end

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
        transformedMatrix(:,1) = transformedMatrix(:,1) + shifts(i);
        wordMatrix = [wordMatrix; transformedMatrix];
    end
end
