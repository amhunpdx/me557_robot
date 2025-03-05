addpath('./mr')

T = Tbuilder(word); % Generate transformation matrices set
[M, Slist,hp] = RobotConfig;

thetalist0 = [-.42; .79; .52; -.26; .17; 0]; % Initial guess
eomg = 10^-3;
ev = 10^-3;

rad2step_sm = 195.3785;
rad2step_lg = 651.739;

% Number of transformation matrices
num_T = length(T); % Since T is a cell array, use length()

% Initialize posmap to store all motor positions
posmap = zeros(num_T, 6); % Preallocate for efficiency

for i = 1:num_T
    Ti = T{i}; % Extract the i-th transformation matrix from the cell

    % Ensure Ti is a 4x4 numeric matrix
    if ~ismatrix(Ti) || size(Ti, 1) ~= 4 || size(Ti, 2) ~= 4
        error('Error: Transformation matrix Ti at index %d is not 4x4.', i);
    end

    [thetalist, success] = IKinSpace(Slist, M, Ti, thetalist0, eomg, ev);

    if success
        % Convert radians to motor steps and store result
        posmap(i, :) = round([thetalist(1) * rad2step_lg, ...
                              thetalist(2) * rad2step_lg, ...
                              thetalist(3) * rad2step_sm, ...
                              thetalist(4) * rad2step_sm, ...
                              thetalist(5) * rad2step_sm, ...
                              thetalist(6)] + hp);
        thetalist0 = thetalist; % Update initial guess for next iteration
    else
        warning('No solution found for transformation matrix %d', i);
        posmap(i, :) = NaN; % Mark failed solutions with NaN
    end
end

% Replace NaN rows with last known valid position
posmap = fillmissing(posmap, 'previous', 1);

disp('Motor positions (steps):');
disp(posmap);
