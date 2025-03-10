
addpath('./mr')

T = [ 1  0  0 .031  ;
      0  1  0   .3;
      0  0  1   .406;
      0  0  0   1   ];

 thetalist0 = [.1;.1;.1;.1;.1;.1];

eomg = 10^-3;
ev = 10^-3;

[thetalist, success] = IKinSpace(Slist, M, T, thetalist0, eomg, ev);

if success
    fprintf('Estimated joint angles (radians):\n');
    posmap=rem(thetalist,(2*pi))';
else
    disp('No Solution Found');
end
