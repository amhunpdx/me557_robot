%% Read and Display Motor Positions

% Define serial port settings
portName = '/dev/tty.usbmodem101'; % Adjust to match your setup
baudRate = 115200;
numMotors = 5;

% Close any existing serial connections
if ~isempty(instrfind)
    disp("Closing existing serial connections...");
    fclose(instrfind);
    delete(instrfind);
end

% Initialize serial connection
disp("Initializing serial...");
dynamixel = serialport(portName, baudRate);

% Give time for initialization
pause(0.2);

% Flush any existing bytes in buffer
disp("Flushing buffer...");
while dynamixel.NumBytesAvailable > 0
    read(dynamixel, dynamixel.NumBytesAvailable, "uint8");
end

% Read motor positions
disp("Reading motor positions...");
positions = zeros(1, numMotors);

while dynamixel.NumBytesAvailable > 0
    line = readline(dynamixel);
    data = sscanf(line, "Motor %d Position: %d");
    if numel(data) == 2
        motorID = data(1);
        posValue = data(2);
        if motorID >= 1 && motorID <= numMotors
            positions(motorID) = posValue;
        end
    end
end

% Display motor positions
disp("Motor Positions:");
for i = 1:numMotors
    fprintf("Motor %d: %d\n", i, positions(i));
end

% Cleanup
disp("Shutting down...");
clear dynamixel;
delete(instrfind);
disp("Done.");
