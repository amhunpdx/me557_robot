function ThetaMatrix = ThetaSolver(T_matrices)
    % Get robot configuration
    [M, Slist, thetalist0_a, eomg, ev] = RobotConfig();

    % Ensure correct dimensions
    num_joints = size(Slist, 2); % Should be 5 for a 5R robot
    num_positions = length(T_matrices);

    % Initialize matrix to store theta values
    ThetaMatrix = NaN(num_positions, num_joints); % Preallocate as NaN

    % Debugging: Display process
    fprintf('Solving IK for %d positions...\n', num_positions);

    % Loop through each transformation matrix in T_matrices
    for i = 1:num_positions
        T = T_matrices{i}; % Get current transformation matrix
        
        % Debugging: Display transformation matrix
        fprintf('Processing position %d:\n', i);
        disp(T);
        
        % Solve inverse kinematics
        [thetalist, success] = IKinSpace(Slist, M, T, thetalist0_a(1:num_joints), eomg, ev);

        % Debugging: Display IK results
        fprintf('Position %d: Success = %d\n', i, success);
        
        if success && ~isempty(thetalist) && all(isfinite(thetalist)) && isvector(thetalist)
            ThetaMatrix(i, :) = mod(real(thetalist(:))', 2 * pi); % Use `mod` instead of `rem`
        else
            fprintf('Warning: IK failed for position %d. Assigning NaN.\n', i);
        end
    end

    % Debugging: Display final ThetaMatrix
    disp('Final Theta Matrix:');
    disp(ThetaMatrix);
end
