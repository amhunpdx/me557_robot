%% Wreckless Controller (Instant Jump Between Points - Simultaneous Movement)

% Close any existing serial connections
if ~isempty(instrfind)
    disp("Closing serial connections...");
    fclose(instrfind);
    delete(instrfind);
end

% Serial Port Configuration
disp("Initializing serial...");
portName = '/dev/tty.usbmodem2101'; % Adjust to match your setup
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
GoalSpeeds = [20, 20, 20, 20, 20];

disp("Starting ultra-fast movement...");
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

    % Send all motor commands in a single batch
    write(dynamixel, dataPacket, "uint8");

    % **Tiny delay to prevent MATLAB from overloading the serial buffer**
    pause(0.1); 

    % Flush the serial buffer after each move command
    while dynamixel.NumBytesAvailable > 0
        disp(readline(dynamixel));
    end
end

% Cleanup
disp("Shutting down...");
clear dynamixel;
delete(instrfind);
disp("Done.");
