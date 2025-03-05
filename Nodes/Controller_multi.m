%% Controller

% Serial Port Configuration
portName = '/dev/tty.usbmodem101'; % Adjust to match your setup
baudRate = 115200;
dynamixel = serialport(portName, baudRate);

% Give time for initialization
pause(0.5);

% Flush any existing bytes in buffer
while dynamixel.NumBytesAvailable > 0
    read(dynamixel, dynamixel.NumBytesAvailable, "uint8");
end

% Define motor IDs
motorIDs = [1,2,3,4,5,6]; 

% Speed array (same for all sequences, modify if needed)
GoalSpeeds = [50,50,50,50,50,50]; 

% Position tolerance for stopping condition
posTolerance = 2;

% Function to get current motor positions
getCurrentPositions = @() readMotorPositions(dynamixel, numel(motorIDs));

% Iterate through each row in posmap
for row = 1:size(posmap, 1)
    GoalPositions = posmap(row, :);

    attempt = 0;
    while attempt < 3
        % Send commands to each motor
        for i = 1:numel(motorIDs)
            ID = motorIDs(i);
            pos = GoalPositions(i);
            speed = GoalSpeeds(i);

            % Send (ID, pos low byte, pos high byte, speed low byte, speed high byte)
            write(dynamixel, [ID, bitand(pos, 255), bitshift(pos, -8), bitand(speed, 255), bitshift(speed, -8)], "uint8");
            pause(0.05); % Short delay for command processing
        end

        % Wait for motors to reach the goal positions
        timeout = 3; % Maximum time to wait before resending
        elapsed = 0;
        while elapsed < timeout
            pause(0.1); % Short delay before checking position
            currentPositions = getCurrentPositions();

            % Check if all motors are within tolerance
            if all(abs(currentPositions - GoalPositions) <= posTolerance)
                break;
            end

            elapsed = elapsed + 0.1;
        end

        % If positions are stable but not within tolerance, retry
        currentPositions = getCurrentPositions();
        if all(abs(currentPositions - GoalPositions) <= posTolerance)
            break;
        elseif elapsed >= timeout
            attempt = attempt + 1;
        end
    end
end

% Cleanup
clear dynamixel


