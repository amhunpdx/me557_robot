addpath('./mr')
hp=[546,2443,901,365,503,0];

% Motor step-to-radian conversion factors
MX64_step_to_rad = (0.088 * pi) / 180; % Dynamixel MX-64
AX12_step_to_rad = (0.29 * pi) / 180;  % Dynamixel AX-12

% Motor steps at centerboard position
% gp_centerboard = [522, 2508, 905, 393, 511, 0];

% Convert steps to radians
 thetalist0 = zeros(1, 6);
% thetalist0(1:2) = gp_centerboard(1:2) * MX64_step_to_rad; % First 2 motors are MX-64
% thetalist0(3:6) = gp_centerboard(3:6) * AX12_step_to_rad; % Remaining motors are AX-12

% Homogeneous transformation matrix for centerboard position
T = [ 1  0  0 -.05  ;
      0  1  0   .26;
      0  0  1   .406;
      0  0  0   1   ];

% Load robot configuration
[M, Slist] = RobotConfig;


% Inverse kinematics solver parameters
eomg = 1e-3;
ev = 1e-3;

% Solve inverse kinematics
[thetalist, success] = IKinSpace(Slist, M, T, thetalist0, eomg, ev);
thetalist=thetalist(1:6);

% Display results
if success
    fprintf('Estimated joint angles (radians):\n');
    disp(thetalist);
else
    disp('No Solution Found');
end

rad2step_sm = 195.3785;
rad2step_lg = 651.739;

gp=[rem(thetalist(1)*rad2step_lg,4095),rem(thetalist(2)*rad2step_lg,4095),rem(thetalist(3)*rad2step_sm,1024),rem(thetalist(4)*rad2step_sm,1024),rem(thetalist(5)*rad2step_sm,1024),0]+hp