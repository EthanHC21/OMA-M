%                                                                  ,********                                                                  
%                                                                (&&&&&@@@@@@@.                                                               
%                                                              *&&&&&&&&&@@@@@@%                                                              
%                                                            .#&&&&&@@&&&&&@@@@@@#                                                            
%                                                           /&&&&&@%. #@&&&&@@@@@@@/                                                          
%                                                         .&&&&&@%,    .%@&&&&@@@@@@@,                                                        
%                                                        %&&&&&&*        *&&&&&&@@@@@@@                                                       
%                                                      (&&&&&&(            (&&&&&@@@@@@@#                                                     
%                                                    *&&&&&@%.        ..... .%@&&&&@@@@@@@*                                                   
%                                                  .&&&&&&&* ./(. .#/ (/..(#* .&@&&&&@@@@@@%.                                                 
%                                                 &&&&&&@/ ./##(((##/*#(//**##. *@&&&&&@@@@@@/                                                
%                                               (&&&&&@#.  .                 *#/ .(@&&&&&@@@@@@.                                              
%                                             *%&&&&&%*                ./(((((((*  ,%&&&&&@@@@@@@                                             
%                                           .#&&&&&&/   .                            *&&&&&&@@@@@@&                                           
%                                          *&&&&&@%  ./#(.      ,.               .     (@&&&&&@@@@@@#                                         
%                                        .&&&&&@&. *####/    ./##*     ,#(.     ,##(,    #@&&&&@@@@@@@*                                       
%                                       &&&&&&&**(######*  ,(####/    ,####/    *#####(/. ,%@&&&&@@@@@@%.                                     
%                                     %&&&&&&%#########(,/#######(.  ,#######,  (#########(,/&&&&&&@@@@@@/                                    
%                                   (&&&&&&&%#####################* ,#########(,(#############&&&&&&@@@@@@@.                                  
%                                 *&&&&&&&%#######################/*############################&&&&&&@@@@@@&                                 
%                               .#&&&&&&&########################################################%&&&&&&@@@@@@#                               
%                              /&&&&&&&############################################################%&&&&&&@@@@@@#.                            
%                            .&&&&&&&%###############################################################&&&&&&@@@@@@@*                           
%                           #&&&&&&%###################################################################&&&&&&@@@@@@@                          
%                         *%&&&&&&######################################################################%&&&&&&@@@@@@#                        
%                       .#&&&&&&%#(/,,(############/,,/#################(*,*(######(*,/###############(###%&&&&&@@@@@@&*                      
%                     .&&&&&&&%##/    .(#########(.    /###############*    .####(,    /###########(.   /###&&&&&&@@@@@@#.                    
%                    &&&&&&&&##(       /########,      ,(############(       /##/      .##########,    /######&&&&&&@@@@@@*                   
%                  (&&&&&&&###.   .,.  .######*    ,.   /##########(.   .,   ,(    ..   /#######*    *#########%&&&&&&@@@@@@.                 
%                ,%&&&&&&%##*    *#(,   /###(.   .(#*   ,#########,    /#(.      ./#*   .#####/.   ,(###(//######&&&&&&@@@@@@@(               
%              .(&&&&&&&##/.   ,####/   ,#(,    /###(.  .(######*    ,####*     *###(.   /##(,    (#(*.     (######&&&&&&@@@@@@&,             
%             ,&&&&&&&##(.   .(##########/    *###############(.   .#######*  ,######/. .(#*    ..      .*#########(#&&&&&&@@@@@@#            
%            %&&&&&&%##*    /##########(    ,(###############,    /######################/          *(################%&&&&&@@@@@@@*          
%          (&&&&&&%##(    ,(#########(.                 ./#/    *#######################.                          .*###&&&&&&@@@@@@%.        
%        ,%&&&&&&####(,.,(###########(,                 ./#(..*(########################,.                        ../#####&&&&&&@@@@@@/       
%       #&&&&&&%###########################################################################################################%&&&&&@@@@@@@.     
%     *&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&@@@@@@%    
%   .&&&&&&&&#&@&%&@@@@@@@@@&@@&@%&&##&@@@@@&%&@@&@@@&%&&@&@@&&@&%&@&&%%%%%&@&@@@@@@@@@@@@@&%%&&@@%(#&@@@@&@@@&%&@@@&@@@@&%@@&&&&&&&&@@@@@@(  
%  &&&&&&&&@/**////*(*,//*/(/*/*//%(##/(**/*/*/**(***/////*//#%*///**@*,,//*((*(//*/**#*,/*///(*/@/*#(*//***//(/*//***//////,#@&&&&&&&@@@@@@@*
%  &&&&&&&&&@&@@@@@@&@@@@@@@&@@&@@&&@@&@@@@@@@@@@@@@@@@@@@&@@&&@@@@@@&@@@@@@@@@&@@%#%@&@@&@&@@%#&&@@@@@%&@&@@@&@@@@@&@@@@@@@@&&&&&&&&&&&@@@@@@
%  @&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&@@@@@@@@
%  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
%  (@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
%   .&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&,
%                                                                                                                                             
%                                                                                                                                             
clear
close all

% specify debayer mode, either 'matlab', 'oma', 'twostep' or 'none'
debayerMode = 'twostep';
% direction for twostep debayering - 0 is horizontal and 1 is vertical
twostepDir = 0;

% specify mask mode, either 'sampledstats' for statistics-based or 'lum'
% for luminance based (OMA technique)
maskMode = 'sampledstats';

% show the masks?
showMask = false;

% path for output (must have trailing \)
outPath = 'D:\Documents\School Documents\2020-2021 Senior Year College\Research\Data\20176C1\Test Images\Extracted\';
% subfolder for scaled output (for easy review, needs trailing \)
sclSubfolder = 'scl\';

% path to lights (must have trailing \)
lightPath = 'D:\Documents\School Documents\2020-2021 Senior Year College\Research\Data\20176C1\Test Images\';

% path to plots (must have trailing \)
plotPath = 'D:\Documents\School Documents\2020-2021 Senior Year College\Research\Data\20176C1\Test Images\plots\';

% we read the defined parameters for the mask region

% specify background mask - the square enclosed by this
    bgRows = 668:861;
    bgCols = 61:260;

% test image
% bgRows = 404:1004;
% bgCols = 32:1332;

% if we're using OMA debayering, we divide the begnining and end by 2
if (strcmp(debayerMode, 'oma'))
    bgRows = (ceil(bgRows(1)/2)):(floor(bgRows(end)/2));
    bgCols = (ceil(bgCols(1)/2)):(floor(bgCols(end)/2));
end

% load info about light files
files = dir(lightPath);

for i = 1:length(files)
    
    name = files(i).name;
    dirStat = files(i).isdir;
    
    % only loop through the .tiff (or tif) files
    if (~dirStat && (strcmp(name(end-3:end), 'tiff') || strcmp(name(end-2:end), 'tif')))
        
        if (strcmp(debayerMode, 'matlab') || strcmp(debayerMode, 'oma') || strcmp(debayerMode, 'twostep'))
            
            % get the light frame as a double
            lightRaw = double(read(Tiff(strcat(lightPath, name))));
            
            % find the bad pixels on the light frame
            % this can be very aggressive at low threshold values - be warned
            [bad_R_L, bad_G_L, bad_B_L] = findBadRaw(lightRaw, 400);
            
            % remove its bad pixels (from dark frame and from itself)
            lightRawClean = clearBad(lightRaw, bad_R_L, bad_G_L, bad_B_L);
            
            % debayer it and store it as a double
            if (strcmp(debayerMode, 'oma'))
                
                lightRGB = double(doc2rgbOMA(lightRawClean));
                
            elseif (strcmp(debayerMode, 'matlab'))
                
                lightRGB = double(demosaic(uint16(lightRawClean), 'rggb'));
                
            else
                
                lightRGB = double(twoStepLinear(lightRawClean, twostepDir));
                
            end
            
        elseif (strcmp(debayerMode, 'none'))
            
            % get the debayered light frame as a double
            lightRGB = double(read(Tiff(strcat(lightPath, name))));
            
        else
            
            disp('Invalid debayer mode')
            return
            
        end
        
        % get image size
        [height, width, ~] = size(lightRGB);
        
        % store location of the crop (for later use)
        % specified as upper left y, upper left x, lower right y, lower right x
        cropLoc = [floor(height*2/3), 1, height, width];
%         cropLoc = cropLoc * 2; % correct because these are image relative coordinates

        % test image
%         cropLoc = [128, 746, 210, 1042];
        
        % modify if we used OMA debayering
        if (strcmp(debayerMode, 'oma'))
            
%             cropLoc = [ceil(cropLoc(1)/2), ceil(cropLoc(2)/2), floor(cropLoc(3)/2), floor(cropLoc(4)/2)];
            
        end
        
        % store location of the burner in the original image [y, x]
        % use Photoshop or something to get this
        burnerLoc = [495, 715];
        
        % modify if we used OMA debayering
        if (strcmp(debayerMode, 'oma'))
            
            burnerLoc = burnerLoc/2;
            
        end
        
        % background subtraction
        
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
            extractFiber(lightRGBSub, maskSmooth, burnerLoc, outPath, name(1:end-5), sclSubfolder, maskMode, plotPath);
            
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
            extractFiber(lightRGB, maskSmooth, burnerLoc, outPath, name(1:end-5), sclSubfolder, maskMode, plotPath);
            
        else
            
            disp('Invalid mask mode')
            return
            
        end
        
    end

end