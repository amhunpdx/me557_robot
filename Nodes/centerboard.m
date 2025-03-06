% centerboard.m
% Reads and records the current motor positions (1-5) without sending any commands.

clear;
addpath('./mr')

% Serial Port Configuration
portName = '/dev/tty.usbmodem2101'; % Change to match your setup
baudRate = 115200;
% dynamixel = serialport(portName, baudRate);

% Initialize serial communication if not already open
if ~exist('dynamixel', 'var') || ~isvalid(dynamixel)
    dynamixel = serialport(portName, baudRate);
    configureTerminator(dynamixel, "CR/LF");
    pause(1); % Allow connection to stabilize
end

% Define motor IDs (1-5)
motorIDs = [1, 2, 3, 4, 5];

% Clear buffer
while dynamixel.NumBytesAvailable > 0
    readline(dynamixel);
end

% Read current motor positions
disp("Reading Current Motor Positions...");
centerboard_pos = zeros(1, 5); % Preallocate array for efficiency

for i = 1:5
    ID = motorIDs(i);
    
    % Request position from motor
    write(dynamixel, [ID, 2], "uint8"); 
    pause(0.1);
    
    % Read response
    if dynamixel.NumBytesAvailable > 0
        data = readline(dynamixel);
        centerboard_pos(i) = str2double(data);
    else
        disp("Warning: No response from motor " + num2str(ID));
    end
end

% Display and store centerboard positions
disp("Centerboard Motor Positions:");
disp(centerboard_pos);
assignin('base', 'centerboard_pos', centerboard_pos);

% Cleanup
clearvars -except dynamixel motorIDs centerboard_pos
