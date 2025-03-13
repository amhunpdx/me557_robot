%% gobot
% Takes input (word), launches Tbuilder, ThetaSolver_multi, controller
% 
% Load and run controller.ino on microcontroller before running. 
% Run DrawAndStore.m to generate word matrix
% Check RobotConfig(ttyspot) for current USB port location.

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

function gobot(word)

    T = Tbuilder(word);
    
    ThetaSolver_multi;

    controller;
end
