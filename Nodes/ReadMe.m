%% README 
% 5-axis robotic arm project
% ME557 - Portland State University - Winter 2025
% Amos Hunter, Zach Carlson, Matt Crisp, Beau Garland, Nedzad Ljaljic
%
% Contents:
% Robot Presentation (John Hancock).pdf centerboard.m, controller.m, DrawAndStore.m, 
% gobot.m, neutralstart.m, ReadMe.m, RobotConfig.m, Tbuilder.m, ThetaSolver_multi.m
%
% To Run:
% 1) Update ttyspot serial location in RobotConfig.m based on active port
%  showing in Arduino IDE
% 
% 2) Run neutralstart.m to put robot into neutral position > 10in from whiteboard
%
% 3) Install pen in end effector tool
%
% 4) Run centerboard.m to move pen tip to center of board
%
% 5) Run DrawAndStore.m, trace curves on figure window using mouse (ideal
%   curves are drawn top to bottom. Typical effective space on the board is
%   in the center in a 10cm wide by 8cm tall area
%
% 6) Run gobot.m - launches Tbuilder.m, ThetaSolver_multi.m, and
%  controller.m
% 
% 7) monitor drawing behavior and modify adjustment coefficients in
%   DrawAndStore.m to calibrate pen pressures and overall offsets.
%
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
