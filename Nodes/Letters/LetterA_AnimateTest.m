

% Assume LetterA is already loaded in the workspace

% Create a figure
figure;
hold on;
grid on;
axis([-6 6 -0.5 10 0 16.5]); % Adjusted for 3D space
xlabel('X'); ylabel('Y'); zlabel('Z');
title('Animated 3D Plot of LetterA');
view(3);

% Initialize plot handles
hPoints = plot3(NaN, NaN, NaN, 'ro', 'MarkerFaceColor', 'r');
hLines = plot3(NaN, NaN, NaN, 'b-', 'LineWidth', 2);

% Animate the drawing process
for i = 1:length(LetterA)-1
    set(hPoints, 'XData', LetterA(1:i,1), 'YData', LetterA(1:i,2), 'ZData', LetterA(1:i,3));
    if LetterA(i,3) == 0 && LetterA(i+1,3) == 0
        set(hLines, 'XData', LetterA(1:i,1), 'YData', LetterA(1:i,2), 'ZData', LetterA(1:i,3));
    end
    pause(0.02); % Small delay for animation effect
    drawnow;
end

hold off;
