clc; clear; close all;

% Load the data
points = csvread('LetterA.csv');

% Remove NaN rows (separators)
valid_rows = ~isnan(points(:,1));
points = points(valid_rows, :);

% Initialize new matrix with z dimension
LetterAwLift = [];

% Add initial transition point
LetterAwLift = [LetterAwLift; points(1,1), points(1,2), -0.5];

% Process points and insert transition markers where needed
for i = 1:length(points)-1
    LetterAwLift = [LetterAwLift; points(i,1), points(i,2), 0];
    dist = norm(points(i+1,:) - points(i,:));
    if dist > 0.25
        LetterAwLift = [LetterAwLift; points(i,1), points(i,2), -0.5];
    end
end

% Add last point and final transition marker
LetterAwLift = [LetterAwLift; points(end,1), points(end,2), 0];
LetterAwLift = [LetterAwLift; points(end,1), points(end,2), -0.5];

% Create a figure
figure;
hold on;
grid on;
axis([-0.5 2 -0.5 2 -1 1]); % Adjusted for 3D space
xlabel('X'); ylabel('Y'); zlabel('Z');
title('Animated 3D Plot of LetterAwLift');
view(3);

% Initialize plot handles
hPoints = plot3(NaN, NaN, NaN, 'ro', 'MarkerFaceColor', 'r');
hLines = plot3(NaN, NaN, NaN, 'b-', 'LineWidth', 2);

% Animate the drawing process
for i = 1:length(LetterAwLift)-1
    set(hPoints, 'XData', LetterAwLift(1:i,1), 'YData', LetterAwLift(1:i,2), 'ZData', LetterAwLift(1:i,3));
    if LetterAwLift(i,3) == 0 && LetterAwLift(i+1,3) == 0
        set(hLines, 'XData', LetterAwLift(1:i,1), 'YData', LetterAwLift(1:i,2), 'ZData', LetterAwLift(1:i,3));
    end
    pause(0.1); % Small delay for animation effect
    drawnow;
end

hold off;
