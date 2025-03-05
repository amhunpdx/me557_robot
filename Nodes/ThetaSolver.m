
addpath('./mr')


 % T = [ 1  0  0 .03  ;
 %      0  1  0   .17;
 %      0  0  1   .41;
 %      0  0  0   1   ];
 % 

 T = [ 1  0  0  -.05  ;
      0  1  0   .19;
      0  0  1   .44;
      0  0  0   1   ];

[M,Slist]=RobotConfig

thetalist0 = [-.42;.79;.52;-.26;.17;0]

eomg = 10^-3;
ev = 10^-3;

[thetalist, success] = IKinSpace(Slist, M, T, thetalist0, eomg, ev);

if success
    fprintf('Estimated joint angles (radians):\n');
    disp(thetalist);
else
    disp('No Solution Found');
end

%Solutions found are in radians. The following converts radians to motor
%steps (based on motor size)
rad2step_sm=195.3785;
rad2step_lg=651.739;

hp=RobotConfig;
posmap = round([thetalist(1)*rad2step_lg,thetalist(2)*rad2step_lg,thetalist(3)*rad2step_sm,thetalist(4)*rad2step_sm,thetalist(5)*rad2step_sm,thetalist(6)]+hp)
