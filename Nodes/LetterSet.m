files = {'LetterA.csv', 'LetterB.csv', 'LetterC.csv', 'LetterD.csv', 'LetterE.csv', ...
         'LetterF.csv', 'LetterG.csv', 'LetterH.csv', 'LetterI.csv', 'LetterJ.csv'};

directory = fullfile(pwd, 'Letters'); % Define the directory where files are stored

for i = 1:length(files)
    filename = fullfile(directory, files{i});
    if exist(filename, 'file') % Check if the file exists
        data = readmatrix(filename); % Read CSV file into a matrix
        
        if size(data, 2) >= 2 % Ensure there are at least 2 columns
            new_data = [data(1, 1:2), 15.5]; % Prepend first row with z = 15.5
            for j = 1:size(data, 1) - 1
                new_data = [new_data; data(j, :) 16]; % Assign 16 to z-value
                distance = sqrt((data(j+1, 1) - data(j, 1))^2 + (data(j+1, 2) - data(j, 2))^2);
                if distance > 0.5
                    new_data = [new_data; data(j, 1:2) 15.5]; % Insert intermediate point
                end
            end
            new_data = [new_data; data(end, :) 16]; % Append last row with z = 16
            new_data = [new_data; data(end, 1:2) 15.5]; % Append final row with z = 15.5
            
            % Apply transformation: Multiply first column by -1 and add 1.5
            new_data(:,1) = (-1 * new_data(:,1)) + 1.5;
        else
            warning('File %s does not have at least 2 columns.', filename);
            new_data = [];
        end
        
        varName = erase(files{i}, {'Letter', '.csv'}); % Remove 'Letter' prefix and '.csv' extension
        assignin('base', varName, new_data); % Assign matrix to a variable in the workspace
    else
        warning('File %s not found.', filename);
    end
end
