%% Starting point - copy of multi_motor_goal_pos_01.m

% Controls multiple Dynamixel actuators over Serial.

% Amos Hunter, Zach Carlson
% 25 January 2025

% Serial
portName = '/dev/tty.usbmodem2101'; % Change to match your setup
baudRate = 115200;
dynamixel = serialport(portName, baudRate);

pause(0.5); % Allow time for initialization
flush(dynamixel);

% Set Goal Positions
motorIDs = [6,5,8,2,4];
home=zeros(numel(motorIDs));
GoalPositions = home;
%GoalPositions = [1000,1000,1000,1000,1000];

% Send Packet to Dynamixel
for i = 1:numel(motorIDs)
    ID = motorIDs(i);
    val = GoalPositions(i);
    
    % Send Command, then again just in case it doesn't work the first time.
    % (yeah, I know)
    write(dynamixel, [ID, bitand(val, 255), bitshift(val, -8)], "uint8");
    pause(0.1);
    write(dynamixel, [ID, bitand(val, 255), bitshift(val, -8)], "uint8");
        write(dynamixel, [ID, bitand(val, 255), bitshift(val, -8)], "uint8");
    pause(0.1);
    write(dynamixel, [ID, bitand(val, 255), bitshift(val, -8)], "uint8");
        write(dynamixel, [ID, bitand(val, 255), bitshift(val, -8)], "uint8");
    pause(0.1);
    write(dynamixel, [ID, bitand(val, 255), bitshift(val, -8)], "uint8");
end

% Wait 
pause(2); 

% Cleanup
clear dynamixel
clearvars()
