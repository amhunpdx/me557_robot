%% Controller (Using Delta Step Values)

% Serial Port Configuration
portName = '/dev/tty.usbmodem2101'; 
baudRate = 115200;
dynamixel = serialport(portName, baudRate);

% Give time for initialization
pause(0.5);

motorIDs = [1,2,3,4,5];  

% Flush any existing bytes in buffer
while dynamixel.NumBytesAvailable > 0
    read(dynamixel, dynamixel.NumBytesAvailable, "uint8");
end

% Read current motor positions BEFORE movement
disp("Reading Current Motor Positions...");
currentPositions = zeros(1,5);

for i = 1:5
    ID = motorIDs(i);
    
    % Request current position from motor
    write(dynamixel, [ID, 2], "uint8"); 
    pause(0.1);
    
    % Read response
    if dynamixel.NumBytesAvailable > 0
        data = readline(dynamixel);
        pos = str2double(data);
        
        % Ensure valid integer values, otherwise default to zero
        if ~isnan(pos) && pos >= 0
            currentPositions(i) = round(pos);
        else
            disp("Warning: Invalid response from motor " + num2str(ID));
        end
    else
        disp("Warning: No response from motor " + num2str(ID));
    end
end

% Display current positions
disp("Current Motor Positions:");
disp(currentPositions);

% Define delta steps to move (Example: [2,2,4,0,0] change from current)
deltaSteps = [.1, .1, .1, 0, 0];  % Modify this array as needed

% Compute new goal positions (relative movement)
GoalPositions = currentPositions + deltaSteps;

% Define movement speeds
GoalSpeeds = uint16([50, 50, 50, 50, 50]); 

% Flush buffer before sending commands
while dynamixel.NumBytesAvailable > 0
    read(dynamixel, dynamixel.NumBytesAvailable, "uint8");
end

% Send Delta Step Commands to Each Motor
disp("Sending Delta Step Commands...");
for i = 1:numel(motorIDs)
    ID = motorIDs(i);
    pos = uint16(GoalPositions(i)); % Ensure integer type
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
clearvars -except currentPositions GoalPositions deltaSteps
