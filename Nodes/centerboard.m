%% centerboard
% moves pen tip to x,y center of whiteboard. Load and run controller.ino on microcontroller
% before running. Check RobotConfig(ttyspot) for current USB port location

% 5-axis robotic arm project
% ME557 - Portland State University - Winter 2025
% Amos Hunter, Zach Carlson, Matt Crisp, Beau Garland, Nedzad Ljaljic
%
% Credits
% Modern Robotics (Lynch 2019)
% Group collaboration with : Elvis Barry, Sam Bechtel, Ben Bolen, Jose Brambila
% Pelayo, August Bueche, Jonathan Cervantes, Wilson Cumbi, Trisha Edmisten,
% Lauryn Gormaly, Tyson Ly, Stu McNeal,Priyanka Prakash, Chanraiksmeiy San,
% and Laura Skinner. Some portions of this code were written with assistance 
% from ChatGPT (https://openai.com 2025) and MATLAB Answers forums
% (https://www.mathworks.com/matlabcentral 2025).
%


% configure serial connection
[ttyspot, M, Slist, hp] = RobotConfig;
portName = ttyspot;
baudRate = 115200;
dynamixel = serialport(portName, baudRate);

pause(0.5);

% motor ID order must match .ino order
motorIDs = [1,2,3,4,5];  

% flush buffer
while dynamixel.NumBytesAvailable > 0
    read(dynamixel, dynamixel.NumBytesAvailable, "uint8");
end

homepositions=[546, 2443, 901, 390, 503]; 
GoalPositions=homepositions
GoalSpeeds = [20, 25, 20, 25, 30];  

% build packet
dataPacket = zeros(1, numel(motorIDs) * 4, 'uint8');
index = 1;
for i = 1:numel(motorIDs)
    pos = GoalPositions(i);
    speed = GoalSpeeds(i);
    dataPacket(index:index+3) = [bitand(pos, 255), bitshift(pos, -8), bitand(speed, 255), bitshift(speed, -8)];
    index = index + 4;
end

% send packet
write(dynamixel, dataPacket, "uint8");
pause(0.1);

% check response
disp("Motor Responses:");
while dynamixel.NumBytesAvailable > 0
    disp(readline(dynamixel));
end

clear dynamixel
