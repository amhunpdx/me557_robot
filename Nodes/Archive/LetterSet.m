files = {'LetterA.csv', 'LetterB.csv', 'LetterC.csv', 'LetterD.csv', 'LetterE.csv', ...
         'LetterF.csv', 'LetterG.csv', 'LetterH.csv', 'LetterI.csv', 'LetterJ.csv'};

directory = fullfile(pwd, 'nodes/Letters'); % Define the directory where files are stored

for i = 1:length(files)
    filename = fullfile(directory, files{i});
    if exist(filename, 'file') % Check if the file exists
        data = readmatrix(filename); % Read CSV file into a matrix

        % Ensure consistent decimal places and initialize first row
        new_data = round([data(1, 1:2), 0], 6);
        lastValid = new_data(end, :); % Store last valid row for NaN handling

        for j = 1:size(data, 1)
            new_row = round([data(j, 1:2), 0], 6); % Assign Z = 0 and round to 6 decimals

            % Handle potential NaNs by replacing with last known valid value
            nanIdx = isnan(new_row);
            new_row(nanIdx) = lastValid(nanIdx);
            new_data = [new_data; new_row];

            lastValid = new_data(end, :); % Update last valid row
        end

        % Apply transformation: Multiply first column by -1 and add 0.0381
        new_data(:,1) = round((-1 * new_data(:,1)) + 0.0381, 6);

        varName = erase(files{i}, {'Letter', '.csv'}); % Remove 'Letter' prefix and '.csv' extension
        assignin('base', varName, new_data); % Assign matrix to a variable in the workspace
    else
        warning('File %s not found.', filename);
    end
end
