%% ThetaSolver_multi
% Takes input, T (cell of transformation matrices) and solves for motor
% angles, thetalist. Converts motor angles to absolute step postions.
%

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

addpath('./mr')

% Load robot configuration
[ttyspot, M, Slist, hp] = RobotConfig;

% Initial guess for thetalist
thetalist0 = [.1,.1,.1,.1,.1]; 

% Error tolerances
eomg = 10^-3;
ev = 10^-3;

% Correct radians-to-steps conversion factors
rad2step_sm = 195.3785;  % AX-12
rad2step_lg = 651.739;   % MX-64

% Number of transformation matrices
num_T = length(T); % Since T is a cell array, use length()

% Initialize posmap storage
posmap = []; 

for i = 1:num_T
    Ti = T{i}; % Extract the i-th transformation matrix

    % Ensure Ti is a 4x4 numeric matrix
    if ~ismatrix(Ti) || size(Ti, 1) ~= 4 || size(Ti, 2) ~= 4
        error('Error: Transformation matrix Ti at index %d is not 4x4.', i);
    end

    % Solve inverse kinematics
    [thetalist, success] = IKinSpace(Slist, M, Ti, thetalist0, eomg, ev);

    % Ensure angles are continuous within [-π, π]
    thetalist = mod(thetalist + pi, 2*pi) - pi;

    if success
        % Convert radians to motor steps
        thetalist_truncated = thetalist(1:5); % Keep only first 5 joints
        
        % Convert to steps and add offsets
        new_row = round([thetalist_truncated(1) * rad2step_lg, ...
                         thetalist_truncated(2) * rad2step_lg, ...
                         thetalist_truncated(3) * rad2step_sm, ...
                         thetalist_truncated(4) * rad2step_sm, ...
                         thetalist_truncated(5) * rad2step_sm] + hp(1:5));

        % Append all computed positions (removing uniqueness constraint)
        posmap = [posmap; new_row]; %#ok<AGROW>

        thetalist0 = thetalist; % Update initial guess for next iteration
    else
        warning('No solution found for transformation matrix %d', i);
    end
end

% offset for pen angle
posmap(:, 4) = posmap(:, 4) + 60;
posmap(:, 5) = posmap(:, 5) - 10;


% Display results
disp('Motor positions (steps):');
disp(posmap);
