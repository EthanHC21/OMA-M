function [avg, stdev] = getDarkStatsFromFiles(path, bad_R, bad_G, bad_B)
% path must have trailing \ and contain raw (non-debayered) data

% get the files
files = dir(path);

% store whether we know the dimensions of the array
dimensionsKnown = false;
filesProcessed = 0;

% store dimensions of the frames
height = 0;
width = 0;

for k = 1:length(files)
    
    name = files(k).name;
    
    if (~(convertCharsToStrings(name) == convertCharsToStrings('.') || convertCharsToStrings(name) == convertCharsToStrings('..')))
        
        if(~dimensionsKnown)
            
            [height, width] = size(read(Tiff(strcat(path, name))));
            dimensionsKnown = true;
            
        end
        
        filesProcessed = filesProcessed + 1;
        
    end
    
end

% preallocate the arrays for each channel
dark_R = zeros(height, width, filesProcessed);
dark_G = zeros(height, width, filesProcessed);
dark_B = zeros(height, width, filesProcessed);

% store the current file number
fileNum = 1;

for k = 1:length(files)
    
    name = files(k).name;
    
    if (~(convertCharsToStrings(name) == convertCharsToStrings('.') || convertCharsToStrings(name) == convertCharsToStrings('..')))
        
        % read the image
        tempImg = double(read(Tiff(strcat(path, name))));
        
        % clear the bad pixels
        tempImgClean = clearBad(tempImg, bad_R, bad_G, bad_B);
        
        % debayer the image (store as double for future calculations)
        rgbImg = double(demosaic(uint16(tempImgClean), 'rggb'));
        
        % extract the channels
        dark_R(:, :, fileNum) = rgbImg(:, :, 1);
        dark_G(:, :, fileNum) = rgbImg(:, :, 2);
        dark_B(:, :, fileNum) = rgbImg(:, :, 3);
        
        fileNum = fileNum + 1;
        
    end
    
end

% do stats - we want an array of the mean and standard deviation of each
% pixel
avg_R = mean(dark_R, 3);
avg_G = mean(dark_G, 3);
avg_B = mean(dark_B, 3);

sdev_R = std(dark_R, 0, 3);
sdev_G = std(dark_G, 0, 3);
sdev_B = std(dark_B, 0, 3);

% return these arrays
avg = zeros(height, width, 3);
avg(:, :, 1) = avg_R;
avg(:, :, 2) = avg_G;
avg(:, :, 3) = avg_B;

stdev = zeros(height, width, 3);
stdev(:, :, 1) = sdev_R;
stdev(:, :, 2) = sdev_G;
stdev(:, :, 3) = sdev_B;
