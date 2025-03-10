%% Serial Port Configuration
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

%% Define Conversion Function
% Converts radians to steps based on motor type
radiansToSteps = @(rads, motorType) ...
    round(rads * (1024 / (2 * pi))) * strcmp(motorType, 'MX-64') + ...
    round(rads * (4096 / (2 * pi))) * strcmp(motorType, 'AX-12');

%% Define Goal Positions in Radians
GoalPositionsRad = posmap(1:5);  % Example in radians

% Define corresponding motor types
motorTypes = ["MX-64", "MX-64", "AX-12", "AX-12", "AX-12"];

% Convert radians to steps
GoalPositions = arrayfun(@(r, m) radiansToSteps(r, m), GoalPositionsRad, motorTypes);

% Define speeds (same for all motors)
GoalSpeeds = [40, 40, 40, 40, 40];

%% Construct command packet
dataPacket = zeros(1, numel(motorIDs) * 4, 'uint8');
index = 1;
for i = 1:numel(motorIDs)
    pos = GoalPositions(i);
    speed = GoalSpeeds(i);
    dataPacket(index:index+3) = [bitand(pos, 255), bitshift(pos, -8), bitand(speed, 255), bitshift(speed, -8)];
    index = index + 4;
end

%% Send all motor data in one batch
write(dynamixel, dataPacket, "uint8");
pause(0.1);

%% Read and print responses
disp("Motor Responses:");
while dynamixel.NumBytesAvailable > 0
    disp(readline(dynamixel));
end

%% Cleanup
clear dynamixel
