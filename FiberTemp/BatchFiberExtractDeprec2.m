clear
close all

% specify mask mode, either 'stats', 'lum', 'globalstats', or 'sampledstats'
maskMode = 'sampledstats';

% specify debayer mode, either 'matlab', 'oma', or 'none'
debayerMode = 'oma';

% show the masks?
showMask = true;

% path for output (must have trailing \)
outPath = 'D:\Documents\School Documents\2020-2021 Senior Year College\Research\Data\Test\Extracted Fibers\';
% subfolder for scaled output (for easy review, needs trailing \)
sclSubfolder = 'scl\';

% path to lights (must have trailing \)
lightPath = 'D:\Documents\School Documents\2020-2021 Senior Year College\Research\Data\Test\Tiff\';

% if the mask mode is 'sampledstats', we read the defined parameters for
% the mask region
if (strcmp(maskMode, 'sampledstats'))
    
    % specify background mask - the square enclosed by this
%     bgRows = 668:861;
%     bgCols = 61:260;
    
    % test image
    bgRows = 404:1004;
    bgCols = 32:1332;
    
    % if we're using OMA debayering, we divide the begnining and end by 2
    if (strcmp(debayerMode, 'oma'))
        bgRows = (ceil(bgRows(1)/2)):(floor(bgRows(end)/2));
        bgCols = (ceil(bgCols(1)/2)):(floor(bgCols(end)/2));
    end
    
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
        % this can be very aggressive at low threshold values - be warned
        [bad_R_L, bad_G_L, bad_B_L] = findBadRaw(lightRaw, 400);
        
        % remove its bad pixels (from dark frame and from itself)
        if (strcmp(maskMode, 'sampledstats'))
            lightRawClean = clearBad(lightRaw, bad_R_L, bad_G_L, bad_B_L);
        else
            lightRawClean = clearBad(lightRaw, logical(bad_R + bad_R_L), logical(bad_G + bad_G_L), logical(bad_B + bad_B_L));
        end
        
        % debayer it and store it as a double
        if (strcmp(debayerMode, 'oma'))
            
            lightRGB = double(doc2rgbOMA(lightRawClean));
            
        elseif (strcmp(debayerMode, 'matlab'))
            
            lightRGB = double(demosaic(lightRawClean, 'rggb'));
        
        else
            
            disp('Invalid debayer mode')
            
        end
        
        % get image size
        [height, width, ~] = size(lightRGB);
        
        % store location of the crop (for later use)
        % specified as upper left y, upper left x, lower right y, lower right x
%         cropLoc = [floor(height*2/3), 1, height, width];

        % test
        cropLoc = [128, 746, 210, 1042];
        
        % modify if we used OMA debayering
        if (strcmp(debayerMode, 'oma'))
            
            cropLoc = cropLoc/2;
            
        end
        
        % store location of the burner in the original image [y, x]
        % use Photoshop or something to get this
        burnerLoc = [495, 715];
        
        % modify if we used OMA debayering
        if (strcmp(debayerMode, 'oma'))
            
            burnerLoc = burnerLoc/2;
            
        end
        
        % get the stats on the sampled background
        if (strcmp(maskMode, 'sampledstats'))
            
            % extract channels
            lightR = lightRGB(:, :, 1);
            lightG = lightRGB(:, :, 2);
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
            lightGSub = lightG - bg_G_avg;
            lightBSub = lightB - bg_B_avg;
            
            % construct subtracted image
            lightRGBSub = zeros(height, width, 3);
            lightRGBSub(:, :, 1) = lightRSub;
            lightRGBSub(:, :, 2) = lightGSub;
            lightRGBSub(:, :, 3) = lightBSub;
            
            % subtract b from r
            lightBW = lightRSub - lightBSub;
            
            % truncate to 0
            lightBW(lightBW<0) = 0;
            
            % get BW standard deviation
            bg_BW_std = sqrt(bg_R_std^2 + bg_B_std^2);
            
        else % DOESN'T WORK - NO SUPPORT FOR RESIZED IMAGE
            
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
            lightRGB(lightRGB<0) = 0;
            lightBW(lightBW<0) = 0;
            
        end
        
        % generate mask
        if (strcmp(maskMode, 'lum'))
            
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
            
            if (showMask)
                figure
                sclimshow(uint16(maskSmooth) * 65335)
            end
            
            % output the fibers
            extractFiber(lightRGBSub, maskSmooth, burnerLoc, outPath, name(1:end-5), sclSubfolder, maskMode);
            
        elseif (strcmp(maskMode, 'sampledstats'))
            
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
            extractFiber(lightRGBSub, maskSmooth, burnerLoc, outPath, name(1:end-5), sclSubfolder, maskMode);
            
        else
            
            disp('Invalid mask mode')
            
        end
        
    end

end