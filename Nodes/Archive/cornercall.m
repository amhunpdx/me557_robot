%% Manual Control Script for X, Y, Z Movement (0.5s Continuous Drive)

% Close any existing serial connections
if ~isempty(instrfind)
    disp("Closing serial connections...");
    fclose(instrfind);
    delete(instrfind);
end

% Serial Port Configuration
disp("Initializing serial...");
portName = '/dev/tty.usbmodem2101'; % Adjust for your system
baudRate = 115200;
dynamixel = serialport(portName, baudRate);

% Allow the connection to establish
pause(0.2);

% Flush buffer
disp("Flushing buffer...");
while dynamixel.NumBytesAvailable > 0
    read(dynamixel, dynamixel.NumBytesAvailable, "uint8");
end

% Define motor IDs
motorIDs = [1,2,3,4,5];

% Default speed settings (adjust as needed)
GoalSpeeds = [20, 20, 20, 20, 20];

% Initialize position storage
topRight = [];
bottomLeft = [];
bottomRight = [];

% Instructions
disp("Manual Control Initialized.");
disp("Use 'w', 's', 'a', 'd', 'r', 'f' to move. Enter 'save' to store a position.");
disp("Commands: w = +X, s = -X, d = +Y, a = -Y, r = +Z, f = -Z.");
disp("Enter 'exit' to quit.");

% Initial motor positions (modify as needed)
currentPosition = [512, 512, 512, 512, 512]; % Assuming centered positions

% Movement step size (tune for your system)
stepSize = 10; % Adjust for how much movement occurs per step
duration = 0.5; % Drive for 0.5 seconds
updateRate = 0.05; % Update motor positions every 50ms
numSteps = duration / updateRate; % Number of iterations for continuous drive

while true
    command = input("Enter command: ", 's');

    if strcmp(command, 'exit')
        break;
    elseif strcmp(command, 'save')
        positionName = input("Enter position name (topRight, bottomLeft, bottomRight): ", 's');
        switch positionName
            case 'topRight'
                topRight = currentPosition;
            case 'bottomLeft'
                bottomLeft = currentPosition;
            case 'bottomRight'
                bottomRight = currentPosition;
            otherwise
                disp("Invalid position name. Use 'topRight', 'bottomLeft', or 'bottomRight'.");
        end
        continue;
    end

    % Drive in the selected direction for 0.5 seconds
    for i = 1:numSteps
        switch command
            case 'w' % Move +X
                currentPosition(1) = currentPosition(1) + stepSize;
            case 's' % Move -X
                currentPosition(1) = currentPosition(1) - stepSize;
            case 'd' % Move +Y
                currentPosition(2) = currentPosition(2) + stepSize;
            case 'a' % Move -Y
                currentPosition(2) = currentPosition(2) - stepSize;
            case 'r' % Move +Z
                currentPosition(3) = currentPosition(3) + stepSize;
            case 'f' % Move -Z
                currentPosition(3) = currentPosition(3) - stepSize;
            otherwise
                disp("Invalid command. Use 'w', 's', 'a', 'd', 'r', 'f' or 'save'.");
                continue;
        end

        % Send updated motor positions
        dataPacket = zeros(1, numel(motorIDs) * 4, 'uint8');
        index = 1;
        for j = 1:numel(motorIDs)
            pos = currentPosition(j);
            speed = GoalSpeeds(j);
            dataPacket(index:index+3) = [bitand(pos, 255), bitshift(pos, -8), bitand(speed, 255), bitshift(speed, -8)];
            index = index + 4;
        end

        % Send movement command
        write(dynamixel, dataPacket, "uint8");

        % Wait for acknowledgment from Arduino
        while true
            if dynamixel.NumBytesAvailable > 0
                response = readline(dynamixel);
                if contains(response, "ACK")
                    break;
                end
            end
        end

        % Pause for next update
        pause(updateRate);
    end

    % Display current position
    disp("Current Position: " + mat2str(currentPosition));
end

% Store the saved positions in the workspace
assignin('base', 'topRight', topRight);
assignin('base', 'bottomLeft', bottomLeft);
assignin('base', 'bottomRight', bottomRight);

% Cleanup
disp("Shutting down...");
clear dynamixel;
delete(instrfind);
disp("Done.");
