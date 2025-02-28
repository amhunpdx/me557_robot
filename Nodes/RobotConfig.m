function [M, Slist] = RobotConfig()


    % Home Configuration Matrix (M) in meters
 M = [1, 0, 0, 0;
     0, 1, 0, 0.1397;
     0, 0, 1, 0.3048;
     0, 0, 0, 1];

    % % Screw Axes (angular velocity components w)
    % w1 = [0; 1; 0];
    % w2 = [0; 0; 1];
    % w3 = [0; 0; 1];
    % w4 = [0; 0; 1];
    % w5 = [0; 1; 0];

    % % Joint locations (position vectors r) in meters
    % r1 = [0; 0; 0];
    % r2 = [0; (4.8146 * in_to_m); 0];
    % r3 = [(9.8425 * in_to_m); (4.8146 * in_to_m); 0];
    % r4 = [(19.685 * in_to_m); (4.8146 * in_to_m); 0];
    % r5 = [(20.2598 * in_to_m); 0; (1.2378 * in_to_m)];
    % 
    % % Correctly compute linear velocity components (v = r × w)
    % v1 = cross(w1, r1);
    % v2 = cross(w2, r2);
    % v3 = cross(w3, r3);
    % v4 = cross(w4, r4);
    % v5 = cross(w5, r5);

    % Construct screw axes

S1 = [0; 1; 0; 0; 0; 0];                      % Base rotation about y-axis
S2 = [0; 0; 1; 0.12229; 0; 0];                % Vertical axis
S3 = [0; 0; 1; 0.12229; -0.250; 0];           % Second vertical rotation
S4 = [0; 0; 1; 0.12229; -0.500; 0];           % Third vertical rotation
S5 = [0; 1; 0; -0.03144; 0; 0.5145];          % End-effector rotation about y-axis


    % Ensure `Slist` is `6×5`
    Slist = [S1, S2, S3, S4, S5];
end
