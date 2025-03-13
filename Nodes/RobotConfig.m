%% RobotConfig
% Stores physical robot configuration and serial port information
% Update ttyspot value to match Arduino IDE port location

% 5-axis robotic arm project
% ME557 - Portland State University - Winter 2025
% Amos Hunter, Zach Carlson, Matt Crisp, Beau Garland, Nedzad Ljaljic
%
% Credits
% Modern Robotics (Lynch 2019)
% Group collaboration with : Elvis Barry, Sam Bechtel, Ben Bolen, Jose Brambila
% Pelayo, August Bueche, Jonathan Cervantes, Wilson Cumbi, Trisha Edmisten,
% Lauryn Gormaly, Tyson Ly, Stu McNeal,Priyanka Prakash, Chanraiksmeiy San,
% and Laura Skinner. Some portions of this code were written with assistance 
% from ChatGPT (https://openai.com 2025) and MATLAB Answers forums
% (https://www.mathworks.com/matlabcentral 2025).
%


function [ttyspot, M, Slist, hp] = RobotConfig()

ttyspot='/dev/tty.usbmodem101'; 

hp=[546,2443,901,390,503,0];

M = [ 1  0  0 .02  ;
      0  1  0   .155;
      0  0  1   .405;
      0  0  0   1   ];

w1 = [0; 1; 0];
w2 = [-1; 0; 0];
w3 = [-1; 0; 0];
w4 = [1; 0; 0];
w5 = [0; -1; 0];
w6 = [0;1;0]; 

r1 = [0; 0; 0];
r2 = [0; .14; 0];
r3 = [0; .3625; .09];
r4 = [0; 0.18; 0.262];
r5 = [0.03144; .21; .27];
r6 = [0.02;0.155; .405];

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

Slist = [S1, S2, S3, S4, S5, S6];

end

