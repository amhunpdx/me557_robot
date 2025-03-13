%% Tbuilder
% Takes input (word) and converts into matrix cell, T
%

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

function T_matrices = Tbuilder(word)
    % Initialize cell array to store T matrices
    T_matrices = cell(size(word,1),1);

    for i = 1:size(word,1);
        x = word(i,1);
        y = word(i,2);
        z = word(i,3);
        
        % Construct T matrix for this point
        T = eye(4); % Start with identity matrix
        T(1:3,4) = [x; y; z]; % Assign position vector
        
        % Store in cell array
        T_matrices{i} = T;
        
    end
end
