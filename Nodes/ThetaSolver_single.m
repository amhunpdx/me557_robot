
addpath('./mr')

% T = [ 1  0  0  0.4064;
%       0  1  0  0.1715;
%       0  0  1     0;
%       0  0  0     1 ];

T = [ 1  0  0  -0.165;
      0  1  0  .315;
      0  0  1     .41;
      0  0  0     1 ];

[M,Slist]=RobotConfig

% thetalist0=[0;0;0;0;0];
 t1=hp(1)*step2rad_lg,t2=hp(2)*step2rad_lg,t3=hp(3)*step2rad_sm,t4=hp(4)*step2rad_sm,t5=hp(5)*step2rad_sm;
thetalist0 = [t1;t2;t3;t4;t5];

eomg = 10^-3;
ev = 10^-3;

[thetalist, success] = IKinSpace(Slist, M, T, thetalist0, eomg, ev);

if success
    fprintf('Estimated joint angles (radians):\n');
    disp(thetalist);
else
    disp('No Solution Found');
end