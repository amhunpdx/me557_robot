
addpath('./mr')

% T = [ 1  0  0  0.4064;
%       0  1  0  0.1715;
%       0  0  1     0;
%       0  0  0     1 ];

pen=0.144;

 T = [ 1  0  0 .03144  ;
      0  1  0   .15754;
      0  0  1   -0.5-pen;
      0  0  0   1   ];


hp=[522        2508         905         393         511           0];
step2rad_lg=0.00153435653;
step2rad_sm=0.00511593255;

% hp=[546,2428,894,367,503];
% thetalist0 = rem([hp(1)*step2rad_lg,hp(2)*step2rad_lg,hp(3)*step2rad_sm,hp(4)*step2rad_sm,hp(5)*step2rad_sm],2*pi);

 t1=hp(1)*step2rad_lg,t2=hp(2)*step2rad_lg,t3=hp(3)*step2rad_sm,t4=hp(4)*step2rad_sm,t5=hp(5)*step2rad_sm, t6=0;

 thetalist0 = [t1;t2;t3;t4;t5;t6];

eomg = 10^-3;
ev = 10^-3;

[thetalist, success] = IKinSpace(Slist, M, T, thetalist0, eomg, ev);

if success
    fprintf('Estimated joint angles (radians):\n');
    rem(thetalist,(2*pi))
else
    disp('No Solution Found');
end

% rad2step_sm=195.659;
% rad2step_lg=651.89;
% posmap = round([thetalist(1)*rad2step_lg,thetalist(2)*rad2step_lg,thetalist(3)*rad2step_sm,thetalist(4)*rad2step_sm,thetalist(5)*rad2step_sm]+hp);
