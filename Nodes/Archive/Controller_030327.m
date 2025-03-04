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

A1=[ 649,2613 ,891 ,415 ,478];
%A2=[ , , , , ,];
%A3=[ , , , , ,];
%A4=[ , , , , ,];
%A5=[ , , , , ,];

theta=[546,2428,894,367,503]./1023.*(5*pi)/3

% Define Motor Commands
motorIDs = [1,2,3,4,5];    
homepositions=[546,2428,894,367,503];
%GoalPositions = [2000,1700,100,1000,400];   
%GoalPositions=A1;
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
