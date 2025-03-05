% Read current motor positions and store in 'livehome'

livehome = zeros(1,6); % Preallocate with 6 elements (last one is 0)

% Flush any existing bytes in buffer
while dynamixel.NumBytesAvailable > 0
    read(dynamixel, dynamixel.NumBytesAvailable, "uint8");
end

% Read motor positions
for i = 1:5
    fprintf(dynamixel, "READ %d", i); % Send request to microcontroller
    pause(0.05); % Short delay for response
    
    if dynamixel.NumBytesAvailable > 0
        line = readline(dynamixel);
        data = sscanf(line, "Motor %d Position: %d");
        
        if numel(data) == 2
            motorID = data(1);
            posValue = data(2);
            
            if motorID >= 1 && motorID <= 5
                livehome(motorID) = posValue;
            end
        end
    end
end

% Last position is fixed at 0
livehome(6) = 0;

% Display result
disp('Motor positions stored in livehome:');
disp(livehome);
