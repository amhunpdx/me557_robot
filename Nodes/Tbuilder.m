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
