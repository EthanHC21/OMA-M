close all
clear

% path to files (must have trailing \)
imgPath = 'D:\Documents\School Documents\2020-2021 Senior Year College\Research\Data\20029G1\Actual Fiber\';
imgOut = imgPath;

% subfolders for exposures (must have trailing \)
shortSubFolder = 'short\';
medSubFolder = 'med\';
longSubFolder = 'long\';

% get files
files = dir(imgPath);

% tracker for number of files
% it is assumed that the order is short, med, long, but change this file
% number to specify the first exposure
fileNum = 0;

for i = 1:length(files)
    
    name = files(i).name;
    dirStat = files(i).isdir;
    
    % only loop through the .tiff (or tif) files
    if (~dirStat && (strcmp(name(end-3:end), 'tiff') || strcmp(name(end-2:end), 'tif')))
        
        % increment file number
        fileNum = fileNum + 1;
        
        % read the image
        img = read(Tiff(strcat(imgPath, name)));
        
        % write the image according to the exposure
        if (mod(fileNum, 3) == 1)
            
            imwrite(img, strcat(imgOut, shortSubFolder, name));
            
        elseif (mod(fileNum, 3) == 2)
            
            imwrite(img, strcat(imgOut, medSubFolder, name));
            
        else
            
            imwrite(img, strcat(imgOut, longSubFolder, name));
            
        end
        
    end
    
end