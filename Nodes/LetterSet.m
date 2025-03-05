files = {'LetterA.csv', 'LetterB.csv', 'LetterC.csv', 'LetterD.csv', 'LetterE.csv', ...
         'LetterF.csv', 'LetterG.csv', 'LetterH.csv', 'LetterI.csv', 'LetterJ.csv'};

directory = fullfile(pwd, '/Letters'); % Define the directory where files are stored

for i = 1:length(files)
    filename = fullfile(directory, files{i});
    if exist(filename, 'file') % Check if the file exists
        data = readmatrix(filename); % Read CSV file into a matrix
        
        new_data = [data(1, 1:2), 0.35]; % Prepend first row with z = 0.0635m
        lastValid = new_data(end, :); % Store last valid row to handle NaNs

        for j = 1:size(data, 1) - 1
            new_row = [data(j, :) 0.4064]; % Assign 0.4064m to z-value

            % Handle potential NaNs by replacing with last known valid value
            nanIdx = isnan(new_row);
            new_row(nanIdx) = lastValid(nanIdx);
            new_data = [new_data; new_row];

            % Compute distance and insert intermediate point if needed
            distance = sqrt((data(j+1, 1) - data(j, 1))^2 + (data(j+1, 2) - data(j, 2))^2);
            if distance > 0.0127
                intermediate_row = [data(j, 1:2) 0.0635]; % **Z = 0.0635m (Corrected offset)**

                % Handle potential NaNs
                nanIdx = isnan(intermediate_row);
                intermediate_row(nanIdx) = lastValid(nanIdx);
                new_data = [new_data; intermediate_row];
            end

            lastValid = new_data(end, :); % Update last valid row
        end

        % Append last row with z = 0.4064m
        final_row = [data(end, :) 0.4064];
        nanIdx = isnan(final_row);
        final_row(nanIdx) = lastValid(nanIdx);
        new_data = [new_data; final_row];

        % Append final row with z = 0.33m
        final_backoff = [data(end, 1:2) 0.33];
        nanIdx = isnan(final_backoff);
        final_backoff(nanIdx) = lastValid(nanIdx);
        new_data = [new_data; final_backoff];

        % Apply transformation: Multiply first column by -1 and add 0.0381
        new_data(:,1) = (-1 * new_data(:,1)) + 0.0381;

        varName = erase(files{i}, {'Letter', '.csv'}); % Remove 'Letter' prefix and '.csv' extension
        assignin('base', varName, new_data); % Assign matrix to a variable in the workspace
    else
        warning('File %s not found.', filename);
    end
end
