% Function to Read Motor Positions
function positions = readMotorPositions(dynamixel, numMotors)
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
end