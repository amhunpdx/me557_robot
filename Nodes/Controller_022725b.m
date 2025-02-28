%% Controller

% Serial Port Configuration
portName = '/dev/tty.usbmodem101'; % Change to match your setup
baudRate = 115200;
dynamixel = serialport(portName, baudRate);

% Give time for initialization
pause(0.5);

% Flush any existing bytes in buffer
while dynamixel.NumBytesAvailable > 0
    read(dynamixel, dynamixel.NumBytesAvailable, "uint8");
end

% Define Motor Commands
motorIDs = [2];              % Motor IDs
GoalPositions = [2000];   % Target positions (max 1023 for small motors, 4095 for large)
GoalSpeeds = [50];        % Speed valuesc

% Read and print initial motor positions
disp("Initial Motor Positions:");
pause(0.1);
while dynamixel.NumBytesAvailable > 0
    disp(readline(dynamixel));
end

% Send Command to Each Motor
for i = 1:numel(motorIDs)
    ID = motorIDs(i);
    pos = GoalPositions(i);
    speed = GoalSpeeds(i);
    
    % Send (ID, pos low byte, pos high byte, speed low byte, speed high byte)
    write(dynamixel, [ID, bitand(pos, 255), bitshift(pos, -8), bitand(speed, 255), bitshift(speed, -8)], "uint8");
    pause(0.1);
    
    % Read and print debug messages from Arduino
    while dynamixel.NumBytesAvailable > 0
        disp(readline(dynamixel));
    end
end

% Wait for movements to finish
pause(1);

% Read and print final motor positions
disp("Final Motor Positions:");
pause(0.1);
while dynamixel.NumBytesAvailable > 0
    disp(readline(dynamixel));
end

% Cleanup
clear dynamixel
clearvars()
