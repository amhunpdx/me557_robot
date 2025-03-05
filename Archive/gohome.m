%% Serial Port Configuration
portName = '/dev/tty.usbmodem101'; % Change to match your setup
baudRate = 115200;
dynamixel = serialport(portName, baudRate);

% Give time for initialization
pause(0.5);

% Flush any existing bytes in buffer
while dynamixel.NumBytesAvailable > 0
    read(dynamixel, dynamixel.NumBytesAvailable, "uint8");
end

disp("Returning robot to home configuration...");

%% Define Home Positions for Motors
% Motor 1 & 2 (Max 4095), Motors 4,5,6 (Max 1023)
homePositions = [2048, 2048, 512, 512, 512]; % Approx. middle of range
homeSpeeds = [10, 10, 10, 10, 10]; % Moderate speed

motorIDs = [1, 2, 4, 5, 6];

%% Send Commands to Motors
for i = 1:numel(motorIDs)
    ID = motorIDs(i);
    pos = homePositions(i);
    speed = homeSpeeds(i);
    
    % Send (ID, pos low byte, pos high byte, speed low byte, speed high byte)
    write(dynamixel, [ID, bitand(pos, 255), bitshift(pos, -8), bitand(speed, 255), bitshift(speed, -8)], "uint8");
    pause(0.1);
    
    % Read and print debug messages from Arduino
    while dynamixel.NumBytesAvailable > 0
        disp(readline(dynamixel));
    end
end

% Wait for movements to complete
pause(1);

%% Read Final Positions
disp("Final Motor Positions:");
pause(0.1);
while dynamixel.NumBytesAvailable > 0
    disp(readline(dynamixel));
end

% Cleanup
clear dynamixel
clearvars()
