% Serial Port Configuration
portName = '/dev/tty.usbmodem2101'; 
baudRate = 115200;
dynamixel = serialport(portName, baudRate);

% Give time for initialization
pause(0.5);

% Motor IDs
motorIDs = [1,2,3,4,5];  

% Flush existing buffer
while dynamixel.NumBytesAvailable > 0
    read(dynamixel, dynamixel.NumBytesAvailable, "uint8");
end
homepositions=[546, 2443, 901, 365, 503]; 
% Set goal positions and speeds
GoalPositions=homepositions
%GoalPositions = [700, 2000, 901, 300, 300];  % Example goal positions
GoalSpeeds = [10, 10, 10, 10, 10];  % Same speed for all

% Construct command packet
dataPacket = zeros(1, numel(motorIDs) * 4, 'uint8');
index = 1;
for i = 1:numel(motorIDs)
    pos = GoalPositions(i);
    speed = GoalSpeeds(i);
    dataPacket(index:index+3) = [bitand(pos, 255), bitshift(pos, -8), bitand(speed, 255), bitshift(speed, -8)];
    index = index + 4;
end

% Send all motor data in one batch
write(dynamixel, dataPacket, "uint8");
pause(0.1);

% Read and print responses
disp("Motor Responses:");
while dynamixel.NumBytesAvailable > 0
    disp(readline(dynamixel));
end

% Cleanup
clear dynamixel
