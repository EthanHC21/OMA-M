function [] = PreprocessFiber(workingPath, lightPath, plotPath, darkPath, cropLoc, burnerSize, burnerLoc, plotAxes, showMask, twostepDir)

close all

% manual fibers - n-by-2 cell array containing the image name (without file
% extension, so "eximg.tiff" is "eximg" and an m-by-4 array with the fiber
% bounding box coordinates as follows [up_y, up_x, low_y, low_x]
manualFibers = {};

% specify clipping threshold above which pixels are considered clipped
clipThresh = 3404;

% subfolder for scaled fibers output
sclSubfolder = 'scl\';

masterDark = integrateDarkFrame(darkPath);

% get image size
[height, width, ~] = size(masterDark);

% find bad pixels on the dark frame
[bad_R, bad_G, bad_B] = findBadRaw(masterDark, 20);
% remove bad pixels
masterDarkClean = clearBad(masterDark, bad_R, bad_G, bad_B);

darkRGB = double(twoStepLinear(masterDarkClean, twostepDir));

% get stats of the cropped background frame
bgStats = darkRGB(cropLoc(1):cropLoc(3), cropLoc(2):cropLoc(4), :);
bg_R = bgStats(:, :, 1);
% bg_G = bgStats(:, :, 2);
bg_B = bgStats(:, :, 3);

% remove skew
bg_R = removeSkew(bg_R, .5, floor(.5 * (cropLoc(3)-cropLoc(1)) * (cropLoc(4) - cropLoc(2))));
% bg_G = removeSkew(bg_G, .5, floor(.5 * (cropLoc(3)-cropLoc(1)) * (cropLoc(4) - cropLoc(2))));
bg_B = removeSkew(bg_B, .5, floor(.5 * (cropLoc(3)-cropLoc(1)) * (cropLoc(4) - cropLoc(2))));
bg_R = bg_R(:);
% bg_G = bg_G(:);
bg_B = bg_B(:);

% calculate standard deviation
bg_R_std = std(bg_R(:));
% bg_G_std = std(bg_G(:));
bg_B_std = std(bg_B(:));

% calculate pixel scale
pxlScl = 6.35/burnerSize; % in mm/pxl, burner is 6.35mm in diameter

% load info about light files
files = dir(lightPath);

for i = 1:length(files)
    
    name = files(i).name;
    dirStat = files(i).isdir;
    
    % only loop through the .tiff (or tif) files
    if (~dirStat)
            
        % get the light frame as a double
        lightRaw = double(read(Tiff(strcat(lightPath, name))));


        % remove its bad pixels (from dark frame and from itself)
        lightRawClean = clearBad(lightRaw, bad_R, bad_G, bad_B);

        % debayer
        lightRGB = double(twoStepLinear(lightRawClean, twostepDir));
        
        
        % get the manual fibers for this image
        imgManualFibers = [];
        [numManualImages, ~]= size(manualFibers);
        for j = 1:numManualImages
            
            if (strcmp(manualFibers{j, 1}, name(1:end-5)))
                imgManualFibers = manualFibers{j, 2};
                break;
            end
            
        end
        
        
        % background subtraction
        % extract channels
        lightR = lightRGB(:, :, 1);
        lightG = lightRGB(:, :, 2);
        lightB = lightRGB(:, :, 3);

        % check for clipped pixels in each channel
        clippedR = lightR >= clipThresh;
        clippedG = lightG >= clipThresh;
        clippedB = lightB >= clipThresh;
        % generate clipped rejection map
        clipped = logical(clippedR + clippedG + clippedB);
        % if any channel has a pixel clipped, we remove that location
        % from all channels
        lightR(clipped) = 0;
        lightG(clipped) = 0;
        lightB(clipped) = 0;

        % dark subtraction
        lightRSub = lightR - darkRGB(:, :, 1);
        lightGSub = lightG - darkRGB(:, :, 2);
        lightBSub = lightB - darkRGB(:, :, 3);

        % subtract b from r
        lightBW = lightRSub - lightBSub;

        % crop the image
        lightRGBCropped = zeros(height, width, 3);
        lightRGBCropped(cropLoc(1):cropLoc(3), cropLoc(2):cropLoc(4), 1) = lightRSub(cropLoc(1):cropLoc(3), cropLoc(2):cropLoc(4));
        lightRGBCropped(cropLoc(1):cropLoc(3), cropLoc(2):cropLoc(4), 2) = lightGSub(cropLoc(1):cropLoc(3), cropLoc(2):cropLoc(4));
        lightRGBCropped(cropLoc(1):cropLoc(3), cropLoc(2):cropLoc(4), 3) = lightBSub(cropLoc(1):cropLoc(3), cropLoc(2):cropLoc(4));
        % truncate at 0
        lightRGBCropped(lightRGBCropped < 0) = 0;
            
        
        % truncate to 0
        lightBW(lightBW<0) = 0;
        
        % get BW standard deviation
        bg_BW_std = sqrt(bg_R_std^2 + bg_B_std^2);
        
        
        % generate mask using statistics
        % define crtitical p value for pixels above which will be
        % considered a fiber detection
        p_crit = 10;

        % get array of pixel z-scores
        zArr = lightBW/bg_BW_std;

        % apply the critical p value to get the mask
        crits = double(zArr > p_crit);

        % apply the crop
        mask = zeros(height, width);
        mask(cropLoc(1):cropLoc(3), cropLoc(2):cropLoc(4)) = crits(cropLoc(1):cropLoc(3), cropLoc(2):cropLoc(4));

        % smooth the mask
        maskSmooth = maskOMA(smoothOMA(mask, 2, 1), .2);

        if (showMask)
            figure
            sclimshow(uint16(maskSmooth) * 65335)
        end

        % output the fibers
        extractFiber(lightRGBCropped, maskSmooth, burnerLoc, workingPath, name(1:end-5), sclSubfolder, plotPath, pxlScl, plotAxes, imgManualFibers);

    end

end
end