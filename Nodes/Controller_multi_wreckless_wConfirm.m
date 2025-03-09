%% Wreckless Controller with Handshake (Ensured Packet Delivery)

% Close any existing serial connections
if ~isempty(instrfind)
    disp("Closing serial connections...");
    fclose(instrfind);
    delete(instrfind);
end

% Serial Port Configuration
disp("Initializing serial...");
portName = '/dev/tty.usbmodem1101'; % Adjust to match your setup
baudRate = 115200;
dynamixel = serialport(portName, baudRate);

% Give time for initialization
pause(0.2); % Minimal startup delay

% Flush any existing bytes in buffer
disp("Flushing buffer...");
while dynamixel.NumBytesAvailable > 0
    read(dynamixel, dynamixel.NumBytesAvailable, "uint8");
end

% Define motor IDs
motorIDs = [1,2,3,4,5];

% Speed array (same for all sequences, modify if needed)
GoalSpeeds = [20, 20, 25, 40, 50];

% Max retries for handshake
MAX_RETRIES = 5;

disp("Starting Wreckless Mode");
% Iterate through each row in posmap 
for row = 1:size(posmap, 1)
    GoalPositions = posmap(row, :);
    disp("Row " + row);

    % Construct a single packet containing all motor positions & speeds
    dataPacket = zeros(1, numel(motorIDs) * 4, 'uint8');
    index = 1;
    for i = 1:numel(motorIDs)
        pos = GoalPositions(i);
        speed = GoalSpeeds(i);
        dataPacket(index:index+3) = [bitand(pos, 255), bitshift(pos, -8), bitand(speed, 255), bitshift(speed, -8)];
        index = index + 4;
    end

    % Handshake: Ensure microcontroller receives the command before proceeding
    attempts = 0;
    while attempts < MAX_RETRIES
        write(dynamixel, dataPacket, "uint8"); % Send packet
        pause(0.05); % Small delay for processing

        % Wait for acknowledgment from microcontroller
        ackReceived = false;
        tic; % Start timeout timer
        while toc < 1  % 1-second timeout
            if dynamixel.NumBytesAvailable > 0
                response = readline(dynamixel);
                if contains(response, "ACK")
                    ackReceived = true;
                    break;
                end
            end
        end

        if ackReceived
            disp("ACK received. Moving to next row.");
            break; % Exit retry loop and continue
        else
            disp("No ACK received, retrying... (" + (attempts+1) + "/" + MAX_RETRIES + ")");
            attempts = attempts + 1;
        end
    end

    if ~ackReceived
        error("Handshake failed: No ACK received after " + MAX_RETRIES + " attempts.");
    end
end

% Cleanup
disp("Shutting down...");
clear dynamixel;
delete(instrfind);
disp("Done.");
