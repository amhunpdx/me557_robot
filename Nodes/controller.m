%% controller
% Takes input "posmap" (5xN matrix of absolute motor step positions) and
% loops, sending each goal position set as a packet via serial to
% controller.ino. Variables: Individual motor speed, send delay.
% 
% Load and run controller.ino on microcontroller before running. 
% Run DrawAndStore.m to generate posmap
% Check RobotConfig(ttyspot) for current USB port location.


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


% clear serial connection
if ~isempty(instrfind)
    disp("Closing serial connections...");
    fclose(instrfind);
    delete(instrfind);
end

% configure serial connection
[ttyspot, M, Slist, hp] = RobotConfig;
portName = ttyspot;
baudRate = 115200;
dynamixel = serialport(portName, baudRate);


pause(0.2); 

% flush serial
disp("Flushing buffer...");
while dynamixel.NumBytesAvailable > 0
    read(dynamixel, dynamixel.NumBytesAvailable, "uint8");
end

% Define motor IDs
motorIDs = [1,2,3,4,5];

% motor ID order must match .ino order
GoalSpeeds = [20, 20, 25, 40, 50];

% give up after no handshake N times
MAX_RETRIES = 5;

disp("Begin send"); 

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

    % Wait for "handshake" from microcontroller before sending next
    attempts = 0;
    while attempts < MAX_RETRIES
        write(dynamixel, dataPacket, "uint8"); % Send packet
        pause(0.05); % processing delay to prevent backup

        % wait for acknowledge
        ackReceived = false;
        tic; % start timer
        while toc < 1  % 1 second wait
            if dynamixel.NumBytesAvailable > 0
                response = readline(dynamixel);
                if contains(response, "ACK")
                    ackReceived = true;
                    break;
                end
            end
        end

        if ackReceived
            disp("Motor command recieved");
            break; %  exit loop and continue
        else
            disp("No ACK received, retrying... (" + (attempts+1) + "/" + MAX_RETRIES + ")");
            attempts = attempts + 1;
        end
    end

    if ~ackReceived
        error("Handshake failed: No ACK received after " + MAX_RETRIES + " attempts.");
    end
end


disp("Shutting down...");
clear dynamixel;
delete(instrfind);
disp("Done.");
