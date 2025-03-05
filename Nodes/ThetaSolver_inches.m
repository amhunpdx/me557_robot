
addpath('./mr')

% inches
T = [[1, 0, 0, 16]; 
        [0, 1, 0, 6.75]; 
        [0, 0, 1, 0]; 
        [0, 0, 0, 1]];

[M,Slist]=RobotConfig

thetalist0 = [-.42;.79;.52;-.26;.17]

eomg = 10^-3;
ev = 10^-3;

[thetalist, success] = IKinSpace(Slist, M, T, thetalist0, eomg, ev);

if success
    fprintf('Estimated joint angles (radians):\n');
    disp(thetalist);
else
    disp('No Solution Found');
end