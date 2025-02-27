function [M, Slist, thetalist0_a, eomg, ev] = RobotConfig()
    % Home configuration matrix M
    M = [ 1  0  0  10;
          0  1  0  10;
          0  0  1  10;
          0  0  0   1];

    % Screw axes (angular velocity components)
    w1 = [0; 0; 1];
    w2 = [0; 1; 0];
    w3 = [0; 1; 0];
    w4 = [0; 0; 1];
    w5 = [0; 1; 0];

    % Joint locations
    r1 = [0; 0; 0];
    r2 = [2; 0; 0];
    r3 = [4; 0; 0];
    r4 = [6; 2; 0];
    r5 = [8; 2; 0];

    % Linear velocity components (v = r × w)
    v1 = cross(r1, w1);
    v2 = cross(r2, w2);
    v3 = cross(r3, w3);
    v4 = cross(r4, w4);
    v5 = cross(r5, w5);

    % Construct screw axes
    S1 = [w1; v1];
    S2 = [w2; v2];
    S3 = [w3; v3];
    S4 = [w4; v4];
    S5 = [w5; v5];

    % Combine into screw axis list
    Slist = [S1, S2, S3, S4, S5];

    % Initial joint angles (thetalist0_a)
thetalist0_a = [0.5; -0.3; 0.2; 0.5; -0.2]; % Initial joint angles in radians


    % Error tolerances
    eomg = 0.001;  % Angular error tolerance
    ev = 0.0001;   % Linear velocity error tolerance
end
