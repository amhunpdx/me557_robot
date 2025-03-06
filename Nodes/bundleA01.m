% Draw Letter "A" with Robot Arm (No JacobianSpace)

%% Setup
clear; clc;

% Load robot configuration
[M, Slist, hp] = RobotConfig();

% Serial Port Configuration
portName = '/dev/tty.usbmodem2101'; 
baudRate = 115200;
dynamixel = serialport(portName, baudRate);
pause(0.5);

motorIDs = [1,2,3,4,5];  % Only 5 real joints
homepositions = [546, 2428, 894, 367, 503]; 

% Tolerances for inverse kinematics
eomg = 0.01;
ev = 0.001;

%% Define Waypoints in Cartesian Space for Letter "A"
waypoints = [
    0.02, 0.22, 0.4;  % Left bottom point
    0.04, 0.32, 0.5;  % Top point
    0.06, 0.22, 0.4;  % Right bottom point
    0.03, 0.27, 0.45; % Middle bar of "A"
    0.05, 0.27, 0.45; % Middle bar end
];

% Initial joint angles (home position)
thetalist0 = zeros(5,1);

% Speed settings
GoalSpeeds = [50,50,50,50,50];

%% Move Robot to Each Waypoint
for i = 1:size(waypoints,1)
    % Define desired transformation matrix (T) at waypoint
    T = [1 0 0 waypoints(i,1);
         0 1 0 waypoints(i,2);
         0 0 1 waypoints(i,3);
         0 0 0 1];

    % Solve inverse kinematics using Levenberg-Marquardt
    [thetalist, success] = IKinLM(Slist, M, T, thetalist0, eomg, ev);

    disp(['Waypoint ', num2str(i), ' - IK Success: ', num2str(success)]);

    if ~success
        disp(['IK Failed at waypoint ', num2str(i)]);
        continue;
    end
    
    % Convert joint angles to motor steps
    GoalPositions = ConvertAnglesToSteps(thetalist, hp);

    % Send motor commands
    for j = 1:numel(motorIDs)
        ID = motorIDs(j);
        pos = GoalPositions(j);
        speed = GoalSpeeds(j);
        write(dynamixel, [ID, bitand(pos, 255), bitshift(pos, -8), bitand(speed, 255), bitshift(speed, -8)], "uint8");
        pause(0.1);
    end
    
    % Wait for movement
    pause(1);
end

% Cleanup
clear dynamixel
disp("Finished drawing 'A'.");

%% Helper Function: Inverse Kinematics using Levenberg-Marquardt (No Jacobian)
function [thetalist, success] = IKinLM(Slist, M, T, thetalist0, eomg, ev)
    thetalist = thetalist0;
    max_iterations = 20;
    lambda = 0.01; % Damping factor
    success = false;

    for i = 1:max_iterations
        Tsb = FKinSpace(M, Slist, thetalist); % Compute current forward kinematics
        error = se3ToVec(MatrixLog6(TransInv(Tsb) * T)); % Compute error in SE(3)
        
        % Check if error is within tolerance
        if norm(error(1:3)) < eomg && norm(error(4:6)) < ev
            success = true;
            return;
        end
        
        % Compute small numerical perturbations
        dtheta = lambda * error(4:6);  % Adjust angles based on error
        thetalist = thetalist + dtheta;
    end
end

%% Helper Function: Convert Angles to Motor Steps
function steps = ConvertAnglesToSteps(thetalist, hp)
    step_ranges = [4095, 4095, 1024, 1024, 1024];
    angle_ranges = [360, 360, 300, 300, 300];

    % Convert angles to steps
    steps = round((thetalist ./ deg2rad(angle_ranges)) .* step_ranges + hp(1:5));
end
