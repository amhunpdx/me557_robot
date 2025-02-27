function T = FKinSpace_SM_header(M, Slist, thetalist)
% *** CHAPTER 4: FORWARD KINEMATICS ***
% Parameters: 
%           M: the home configuration (position and orientation) of the 
%              end-effector,
%       Slist: The joint screw axes in the space frame when the manipulator
%              is at the home position. Screw axes should be stacked in 
%              ascending order ([S1, S2, S3, etc.], where Sn is a 6x1 vector),
%   thetalist: A list of joint coordinates, stacked as [Th1; Th2; Th3; etc.].
% 
% Returns:
% ========
%         Tse: in SE(3), representing the end-effector frame, when the joints 
%              are at the specified coordinates (w.r.t. {s}, Space Frame).
%
% Example Inputs:
% ===============
% clear; clc;
% M = [[-1, 0, 0, 0]; [0, 1, 0, 6]; [0, 0, -1, 2]; [0, 0, 0, 1]];
% 
% S1 = [0, 0, 1, 4, 0, 0]';
% S2 = [0, 0, 0, 0, 1, 0]';
% S3 = [0; 0; -1; -6; 0; -0.1];
% Slist = [S1, S2, S3];
% 
% thetalist =[pi / 2; 3; pi];
%
% T = FKinSpace_SM_header(M, Slist, thetalist)
% 
% Output:
% T =
%   -0.0000    1.0000         0   -5.0000
%    1.0000    0.0000         0    4.0000
%         0         0   -1.0000    1.6858
%         0         0         0    1.0000

T = M;
for i = size(thetalist): -1: 1
    T = MatrixExp6(VecTose3(Slist(:, i) * thetalist(i))) * T;
end
end