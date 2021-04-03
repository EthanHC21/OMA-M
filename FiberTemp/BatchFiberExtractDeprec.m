clear
close all

% specify mask mode, either 'stats', 'lum', 'globalstats', or 'sampledstats'
maskMode = 'sampledstats';

% path for output (must have trailing \)
outPath = 'D:\Documents\School Documents\2020-2021 Senior Year College\Research\Data\20176C1\Extracted Fibers\';
% subfolder for scaled output (for easy review, needs trailing \)
sclSubfolder = 'scl\';

% path to lights (must have trailing \)
lightPath = 'D:\Documents\School Documents\2020-2021 Senior Year College\Research\Data\20176C1\Actual Fiber Images\';

% if the mask mode is 'sampledstats', we read the defined parameters for
% the mask region
if (strcmp(maskMode, 'sampledstats'))
    
    % mask is the square enclosed by this
    bgRows = 668:861;
    bgCols = 61:260;
    
else
    
    % path to darks (must have trailing \)
    darkPath = 'D:\Documents\School Documents\2020-2021 Senior Year College\Research\Data\20176C1\Darks\';
    % integrate the raw darks to a raw master dark
    darkRawInt = integrateDarkFrame(darkPath);
    
    % find the bad pixels from the dark frame
    [bad_R, bad_G, bad_B] = findBadRaw(darkRawInt, 100);
    
    % obtain the dark frame pixel statistics
    [pxlMean, pxlStd] = getDarkStatsFromFiles(darkPath, bad_R, bad_G, bad_B);
    
    % get image size
    [height, width, ~] = size(pxlMean);
    
    % extract red and blue channels
    pxlMeanR = pxlMean(:, :, 1);
    pxlStdR = pxlStd(:, :, 1);
    pxlMeanB = pxlMean(:, :, 3);
    pxlStdB = pxlStd(:, :, 3);
    
end

% load info about light files
files = dir(lightPath);

for i = 1:length(files)
    
    name = files(i).name;
    dirStat = files(i).isdir;
    
    % only loop through the .tiff (or tif) files
    if (~dirStat && (strcmp(name(end-3:end), 'tiff') || strcmp(name(end-2:end), 'tif')))
        
        % get the light frame as a double
        lightRaw = double(read(Tiff(strcat(lightPath, name))));
        
        % find the bad pixels on the light frame
        [bad_R_L, bad_G_L, bad_B_L] = findBadRaw(lightRaw, 20);
        
        % remove its bad pixels (from dark frame and from itself)
        if (strcmp(maskMode, 'sampledstats'))
            lightRawClean = clearBad(lightRaw, bad_R_L, bad_G_L, bad_B_L);
        else
            lightRawClean = clearBad(lightRaw, logical(bad_R + bad_R_L), logical(bad_G + bad_G_L), logical(bad_B + bad_B_L));
        end
        % debayer it and store it as a double
        lightRGB = double(demosaic(uint16(lightRawClean), 'rggb'));
        
        % get image size
        [height, width, ~] = size(lightRGB);
        
        % store location of the crop (for later use)
        % specified as upper left y, upper left x, lower right y, lower right x
        cropLoc = [floor(height*2/3), 1, height, width];
        
        % store location of the burner in the original image [y, x]
        burnerLoc = [495, 715];
        
        % get the stats on the sampled background
        if (strcmp(maskMode, 'sampledstats'))
            
            % extract red and blue channels
            lightR = lightRGB(:, :, 1);
            lightB = lightRGB(:, :, 3);
            
            % extract background channels
            bg_R = lightRGB(bgRows, bgCols, 1);
            bg_G = lightRGB(bgRows, bgCols, 2);
            bg_B = lightRGB(bgRows, bgCols, 3);
            
            % get the averages
            bg_R_avg = mean(bg_R(:));
            bg_G_avg = mean(bg_G(:));
            bg_B_avg = mean(bg_B(:));
            
            % get the standard deviations (for later)
            bg_R_std = std(bg_R(:));
            bg_G_std = std(bg_G(:));
            bg_B_std = std(bg_B(:));
            
            % dark subtraction
            lightRSub = lightR - bg_R_avg;
            lightBSub = lightB - bg_B_avg;
            
            % subtract b from r
            lightBW = lightRSub - lightBSub;
            
            % truncate to 0
            lightBW(lightBW<0) = 0;
            
            % get BW standard deviation
            bg_BW_std = sqrt(bg_R_std^2 + bg_B_std^2);
            
        else
            
            % extract red and blue channels
            lightR = lightRGB(:, :, 1);
            lightB = lightRGB(:, :, 3);
            
            % subtract the red channel's background
            lightRSub = lightR - pxlMeanR;
            
            % subtract the blue channel's background
            lightBSub = lightB - pxlMeanB;
            
            % subtract R and B to remove the flame
            lightBW = lightRSub - lightBSub;
            
            % truncate at 0
            lightBW(lightBW<0) = 0;
            
        end
        
        % generate mask
        if (strcmp(maskMode, 'stats')) % DOESN'T WORK BECAUSE OF GAIN ISSUE
            % define crtitical p value for pixels above which will be
            % considered a fiber detection
            p_crit = 10;
            
            % get array of pixel z-scores
            zArr = lightBW./(pxlStdR.^2 + pxlStdB.^2).^(1/2);
            
            % apply the critical p value to get the mask
            crits = double(zArr > p_crit);
            
            % apply the crop
            mask = zeros(width, height);
            mask(cropLoc(1):cropLoc(3), cropLoc(2):cropLoc(4)) = crits(cropLoc(1):cropLoc(3), cropLoc(2):cropLoc(4));
            
            % smooth the mask
            maskSmooth = maskOMA(smoothOMA(mask, 2, 1), .2);
            
            figure
            sclimshow(uint16(maskSmooth) * 65335)
            
            % output the fibers
            extractFiber(lightCrop, maskSmooth, burnerLoc, cropLoc, outPath, name(1:end-5), sclSubfolder, maskMode);
            
        elseif (strcmp(maskMode, 'lum'))
            
            % crop image
            lightBWCropped = zeros(height, width);
            lightBWCropped(cropLoc(1):cropLoc(3), cropLoc(2):cropLoc(4)) = lightBW(cropLoc(1):cropLoc(3), cropLoc(2):cropLoc(4));
            
            % smooth image along x to reduce noise
            lightBWSmooth = smoothOMA(lightBWCropped, 1, 0);
            
            % perform a horizontal integration
            lightBWInt = intfillOMA(lightBWCropped, 0);
            
            % normalize this to [0, 1]
            lightBWIntNorm = lightBWInt - min(lightBWInt(:));
            lightBWIntNorm = (lightBWIntNorm/max(lightBWIntNorm(:)));
            
            % create binarized mask
            % CHANGE THIS VALUE FOR MASK SENSITIVITY
            mask = maskOMA(lightBWIntNorm, .05);
            
            % smooth in y
            maskSmooth = smoothOMA(mask, 0, 3);
            
            % normalize to [0, 1]
            maskSmooth = maskSmooth - min(maskSmooth(:));
            maskSmooth = maskSmooth/max(maskSmooth(:));
            
            figure
            sclimshow(uint16(maskSmooth) * 65335)
            
            % output the fibers
            extractFiber(lightRGB, maskSmooth, cropLoc, burnerLoc, outPath, name(1:end-5), sclSubfolder, maskMode);
            
        elseif (strcmp(maskMode, 'globalstats')) % DOESN'T WORK
            
            % obtain global standard deviation
            globalBGStd = std2(pxlMeanCropped(:, :, 1) - pxlMeanCropped(:, :, 3));
            
            lightCropBWDenoise = findAndRemBad(lightBW, 20, 3);
            % lightCropBWDenoise = lightCropBW;
            
            % define crtitical p value for pixels above which will be
            % considered a fiber detection
            p_crit = 5;
            
            % get z values
            zArr = lightCropBWDenoise/globalBGStd;
            
            % apply the critical p value to get the initial mask
            mask = double(zArr > p_crit);
            
            % smooth the mask slightly
            maskSmooth = maskOMA(smoothOMA(mask, 2, 1), .2);
            
            % apply this mask to the color image
            lightCropBWDenoise(~(logical(maskSmooth))) = 0;
            
            % generate an intfill
            lightCropInt = intfillOMA(lightCropBWDenoise, 0);
            
            % normalize this to [0, 1]
            lightCropIntMask = lightCropInt - min(lightCropInt(:));
            lightCropIntMask = lightCropIntMask/max(lightCropIntMask(:));
            
            % binarize the mask
            lightCropIntMask = maskOMA(lightCropIntMask, .05);
            
            % smooth it in y
            lightCropIntMask = smoothOMA(lightCropIntMask, 0, 3);
            
            % normalize this to [0, 1]
            finalMask = lightCropIntMask - min(lightCropIntMask(:));
            finalMask = finalMask/max(finalMask(:));
            
            figure
            sclimshow(uint16(finalMask) * 65335)
            
            % output the fibers
            extractFiber(lightCrop, maskSmooth, cropLoc, burnerLoc, outPath, name(1:end-5), sclSubfolder, maskMode);
            
        elseif (strcmp(maskMode, 'sampledstats'))
            
            % define crtitical p value for pixels above which will be
            % considered a fiber detection
            p_crit = 10;
            
            % get array of pixel z-scores
            zArr = lightBW/bg_BW_std;
            
            % apply the critical p value to get the mask
            crits = double(zArr > p_crit);
            
            % apply the crop
            mask = zeros(width, height);
            mask(cropLoc(1):cropLoc(3), cropLoc(2):cropLoc(4)) = crits(cropLoc(1):cropLoc(3), cropLoc(2):cropLoc(4));
            
            % smooth the mask
            maskSmooth = maskOMA(smoothOMA(mask, 2, 1), .2);
            
            figure
            sclimshow(uint16(maskSmooth) * 65335)
            
            % output the fibers
            extractFiber(lightRGB, maskSmooth, cropLoc, burnerLoc, outPath, name(1:end-5), sclSubfolder, maskMode);
            
        else
            
            disp('Invalid mask mode')
            
        end
        
    end

end