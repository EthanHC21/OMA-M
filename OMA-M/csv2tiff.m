% set the current folder to be the directory with the images before running
% this script

csvPath = "D:\Documents\School Documents\2020-2021 Senior Year College\Research\fiberTemperature\cldFlame\debug\";

files = dir(csvPath);

for k = 1:length(files)
    
    name = files(k).name;
    dirStat = files(k).isdir;
    
    % remove the . and .. names
    if (~dirStat && strcmp(name(end-2:end), 'csv'))
        % get the data
        temp = readmatrix(strcat(csvPath, name));
        
        % convert massive array to RGB array
        
        % get dimensions
        [height3, width] = size(temp);
        height = height3/3;
        
        % extract channels
        r = temp(1:height, 1:width);
        g = temp((height + 1):(2 * height), 1:width);
        b = temp((2 * height + 1):(3 * height), 1:width);
        
        % assemble channels into 3D array
        tempImg = zeros(height, width, 3);
        tempImg(:, :, 1) = r;
        tempImg(:, :, 2) = g;
        tempImg(:, :, 3) = b;
        
        % write a tiff
        imwrite(uint16(tempImg), strcat(files(k).name(1:end-3), 'tiff'));
    end
end