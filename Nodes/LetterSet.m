clc; clear; close all;

% Define the "A" structure
x1 = linspace(0, 0.75, 10); 
y1 = (1.5/0.75) * x1; % Left leg

x2 = linspace(0.75, 1.5, 10);
y2 = -(1.5/0.75) * (x2 - 1.5); % Right leg

x3 = linspace(0.4, 1.1, 10);
y3 = ones(size(x3)) * 0.75; % Crossbar

% Plot the "A"
figure;
hold on;
plot(x1, y1, 'k', 'LineWidth', 2); % Left leg
plot(x2, y2, 'k', 'LineWidth', 2); % Right leg
plot(x3, y3, 'k', 'LineWidth', 2); % Crossbar

% Formatting
axis equal;
xlim([-0.1, 1.6]);
ylim([-0.1, 1.6]);
grid on;
xlabel('X');
ylabel('Y');
title('Letter "A"');

hold off;
