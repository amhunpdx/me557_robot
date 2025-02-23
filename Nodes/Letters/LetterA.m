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

% % Create a figure
% figure;
% hold on;
% grid on;
% axis([-0.5 2 -0.5 2]);
% title('Modified Plot of LetterAwLift');
% 
% % Plot the points with condition on distance
% for i = 1:length(LetterAwLift)-1
%     if LetterAwLift(i,3) == 0 && LetterAwLift(i+1,3) == 0
%         plot(LetterAwLift(i:i+1,1), LetterAwLift(i:i+1,2), 'b-', 'LineWidth', 2);
%     end
% end
% 
% % Display the points
% plot(LetterAwLift(:,1), LetterAwLift(:,2), 'ro', 'MarkerFaceColor', 'r');
% hold off;

