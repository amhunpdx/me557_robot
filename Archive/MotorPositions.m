%% Serial Port Configuration
portName = '/dev/tty.usbmodem101'; % Change to match your setup
baudRate = 115200;
dynamixel = serialport(portName, baudRate);

% Give time for initialization
pause(0.5);

% Flush any existing bytes in buffer
while dynamixel.NumBytesAvailable > 0
    read(dynamixel, dynamixel.NumBytesAvailable, "uint8");
end

disp("Reading motor positions...");

while true
    % Check if there's data available
    if dynamixel.NumBytesAvailable > 0
        % Read and display data from Arduino
        disp(readline(dynamixel));
    end
    pause(0.1); % Small delay to avoid flooding the serial buffer
end
