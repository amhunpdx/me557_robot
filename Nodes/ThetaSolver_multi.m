addpath('./mr')

T = Tbuilder(word); % Generate transformation matrices set
[M, Slist, hp] = RobotConfig;

thetalist0 = [0.8009    3.8482    4.6299    2.0106    2.6142         0]; % Initial guess
eomg = 10^-3;
ev = 10^-3;

rad2step_sm = 195.3785;
rad2step_lg = 651.739;

% Number of transformation matrices
num_T = length(T); % Since T is a cell array, use length()

% Initialize posmap storage dynamically
posmap = []; % Start with an empty matrix

for i = 1:num_T
    Ti = T{i}; % Extract the i-th transformation matrix from the cell

    % Ensure Ti is a 4x4 numeric matrix
    if ~ismatrix(Ti) || size(Ti, 1) ~= 4 || size(Ti, 2) ~= 4
        error('Error: Transformation matrix Ti at index %d is not 4x4.', i);
    end

    [thetalist, success] = IKinSpace(Slist, M, Ti, thetalist0, eomg, ev);

    if success
        % Truncate the 6th position from thetalist
        thetalist_truncated = thetalist(1:5);

        % Convert radians to motor steps and add first 5 elements of hp
        new_row = round([thetalist_truncated(1) * rad2step_lg, ...
                         thetalist_truncated(2) * rad2step_lg, ...
                         thetalist_truncated(3) * rad2step_sm, ...
                         thetalist_truncated(4) * rad2step_sm, ...
                         thetalist_truncated(5) * rad2step_sm] + hp(1:5));

        % Only add the row if it's different from the previous one
        if isempty(posmap) || any(posmap(end, :) ~= new_row)
            posmap = [posmap; new_row]; %#ok<AGROW> % Append only if different
        end

        thetalist0 = thetalist; % Update initial guess for next iteration
    else
        warning('No solution found for transformation matrix %d', i);
    end
end

disp('Motor positions (steps):');
disp(posmap);
