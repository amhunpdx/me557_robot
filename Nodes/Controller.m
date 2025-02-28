%% Controller

% Serial Port Configuration
portName = '/dev/tty.usbmodem2101'; % Change to match your setup
baudRate = 115200;
dynamixel = serialport(portName, baudRate);

% Give time for initialization
pause(0.5);

% Flush any existing bytes in buffer
while dynamixel.NumBytesAvailable > 0
    read(dynamixel, dynamixel.NumBytesAvailable, "uint8");
end

% Define Motor Commands
motorIDs = [1,2,3,4,5];    
homepositions=[2460,1970,360,304,515];
%GoalPositions = [2000,2600,387,900,400];   
GoalPositions=homepositions;
GoalSpeeds = [50,50,50,50,50,50]; 

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
