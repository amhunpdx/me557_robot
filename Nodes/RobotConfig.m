function [M, Slist, hp] = RobotConfig()

% Hand-calibrated homing values

% step2rad_lg=0.00153435653;
% step2rad_sm=0.00511593255;
% hp=[546,2428,894,367,503];
% thetalist0 = rem([hp(1)*step2rad_lg,hp(2)*step2rad_lg,hp(3)*step2rad_sm,hp(4)*step2rad_sm,hp(5)*step2rad_sm],2*pi);

hp=[546        2342         938         385         503           0];

 M = [ 1  0  0 .03  ;
      0  1  0   .19;
      0  0  1   .41;
      0  0  0   1   ];

w1 = [0; 1; 0];
w2 = [1; 0; 0];
w3 = [1; 0; 0];
w4 = [-1; 0; 0];
w5 = [0; 1; 0];
w6 = [0;0;0];

r1 = [0; 0; 0];
r2 = [0; .122; 0];
r3 = [0; -.36; 0.1];
r4 = [0; 0.165; 0.265];
r5 = [0.045; 0.2; 0.28];
r6 = [.03;.19;.41];

v1=cross(w1,r1);
v2=cross(w2,r2);
v3=cross(w3,r3);
v4=cross(w4,r4);
v5=cross(w5,r5);
v6=cross(w6,r6);

S1 = [w1; v1];
S2 = [w2; v2];
S3 = [w3; v3];
S4 = [w4; v4];
S5 = [w5; v5];
S6 = [w6; v6];

Slist = [S1, S2, S3, S4, S5,S6];

end

