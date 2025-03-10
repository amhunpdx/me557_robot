function plotWord(word)
    if length(word) ~= 4
        error('Input must be a 4-letter string');
    end
    
    % Retrieve corresponding matrices from the workspace
    matrices = cell(1,4);
    for i = 1:4
        varName = word(i);  % Use the letter directly
        if evalin('base', ['exist(''' varName ''', ''var'')'])
            matrices{i} = evalin('base', varName);
        else
            error('Matrix for letter %s does not exist in the workspace.', word(i));
        end
    end
    
    % Define transformation shifts
    shifts = [.04, 0, -.04, -.08];
    
    % Apply transformations and build word matrix
    wordMatrix = [];
    for i = 1:4
        transformedMatrix = matrices{i};
        transformedMatrix(:,1) = transformedMatrix(:,1) + shifts(i);
        wordMatrix = [wordMatrix; transformedMatrix];
    end
    
    % Plot the word
    figure;
    hold on;
    grid on;
   axis([-0.1 0.1 -0.0127 0.0762]);; % Adjusted for 3D space
    xlabel('X'); ylabel('Y'); zlabel('Z');
    title(['Animated 3D Plot of Word: ' word]);
    view(3);
    
    % Initialize plot handles
    hPoints = plot3(NaN, NaN, NaN, 'ro', 'MarkerFaceColor', 'r');
    hLines = plot3(NaN, NaN, NaN, 'b-', 'LineWidth', 2);
    
    % Animate the drawing process
    for i = 1:length(wordMatrix)-1
        set(hPoints, 'XData', wordMatrix(1:i,1), 'YData', wordMatrix(1:i,2), 'ZData', wordMatrix(1:i,3));
        if wordMatrix(i,3) == 0 && wordMatrix(i+1,3) == 0
            set(hLines, 'XData', wordMatrix(1:i,1), 'YData', wordMatrix(1:i,2), 'ZData', wordMatrix(1:i,3));
        end
        pause(0.01); % Small delay for animation effect
        drawnow;
    end
    
    hold off;
end
