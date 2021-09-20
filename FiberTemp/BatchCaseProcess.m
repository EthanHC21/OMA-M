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

close all
clear

% specify directory containing case folders
dataDir = 'D:\Documents\School Documents\2020-2021 Senior Year College\Research\Data\Example File System\Data';
dataDir = checkPath(dataDir);

% specify output directory
outDir = 'D:\Documents\School Documents\2020-2021 Senior Year College\Research\Data\Example File System\Upload';
outDir = checkPath(outDir);

% get the folders
dayFolders = dir(dataDir);
% loop through each possible day folder
for i = 1:length(dayFolders)
    
    % get name of day
    dayName = dayFolders(i).name;
    % check if its a real day folder
    if (~(dayName == "." || dayName == ".."))
        
        % create day path
        dayPath = strcat(dataDir, dayName);
        dayPath = checkPath(dayPath);
        
        % make corresponding output directory
        if (~exist(strcat(outDir, dayName), 'dir'))
            mkdir(strcat(outDir, dayName));
        end
        
        % try to get the control file
        CaseControl = readtable(strcat(dayPath, 'Case Data.xlsx'));
        % this will explode if it's not there, which is good
        
        % get the folders
        caseFolders = dir(dayPath);
        
        % now loop through each possible case folder
        for j = 1:length(caseFolders)
            
            % get name of case
            caseName = caseFolders(j).name;
            % check if it's a real case folder and if the control file has
            % it
            if (~(caseName == "." || caseName == "..") && ~isempty(find(strcmp(CaseControl.CaseID, caseName))))
                
                % create case path
                casePath = strcat(dayPath, caseName);
                casePath = checkPath(casePath);
                
                % create case output path
                caseOutPath = strcat(outDir, dayName, '\', caseName);
                caseOutPath = checkPath(caseOutPath);
                if (~exist(caseOutPath, 'dir'))
                    mkdir(caseOutPath);
                end
                
                % get the index of interest
                caseInd = find(strcmp(CaseControl.CaseID, caseName));
                
                % extract analysis parameters
                ignitionStart = CaseControl.Ignition(caseInd);
                darksStart = CaseControl.Darks(caseInd);
                burnerLoc = double(strsplit(string(CaseControl.BurnerLoc(caseInd))));
                twostepDir = CaseControl.TwoStepDir(caseInd);
                cropLoc = double(strsplit(string(CaseControl.CropLoc(caseInd))));
                burnerSize = CaseControl.BurnerSize(caseInd);
                
                % path to images
                imgPath = strcat(casePath, 'Tiff');
                imgPath = checkPath(imgPath);
                % get files
                imgFiles = dir(imgPath);
                
                % split exposures
                % store classification of current exposure
                darkInd = 0;
                lightInd = 0;
                % create folder for actual fiber images
                actualFiberPath = strcat(casePath, 'Actual Fiber');
                actualFiberPath = checkPath(actualFiberPath);
                if (~exist(actualFiberPath, 'dir'))
                    mkdir(actualFiberPath);
                end
                if (~exist(strcat(actualFiberPath, 'short'), 'dir'))
                    mkdir(strcat(actualFiberPath, 'short'));
                end
                if (~exist(strcat(actualFiberPath, 'med'), 'dir'))
                    mkdir(strcat(actualFiberPath, 'med'));
                end
                if (~exist(strcat(actualFiberPath, 'long'), 'dir'))
                    mkdir(strcat(actualFiberPath, 'long'));
                end
                
                % create folder for dark images
                darkPath = strcat(casePath, 'Darks');
                darkPath = checkPath(darkPath);
                if (~exist(darkPath, 'dir'))
                    mkdir(darkPath);
                end
                if (~exist(strcat(darkPath, 'short'), 'dir'))
                    mkdir(strcat(darkPath, 'short'));
                end
                if (~exist(strcat(darkPath, 'med'), 'dir'))
                    mkdir(strcat(darkPath, 'med'));
                end
                if (~exist(strcat(darkPath, 'long'), 'dir'))
                    mkdir(strcat(darkPath, 'long'));
                end
                
                for k = 1:length(imgFiles)
                    
                    % store name and directory status
                    imgName = imgFiles(k).name;
                    imgDirStat = imgFiles(k).isdir;
                    
                    if (~imgDirStat) % check it's actually an image
                        
                        % get digits
                        imgID = imgName((length(imgName) - 9):(length(imgName) - 5));
                        
                        % check whether this is a dark or a light
                        if (str2double(imgID) >= ignitionStart && str2double(imgID) < darksStart)
                            
                            % it's a light with fibers
                            switch lightInd
                                
                                case 0 % short
                                    tempImg = uint16(read(Tiff(strcat(imgPath, imgName))));
                                    imwrite(tempImg, strcat(actualFiberPath, 'short\', imgName))
                                    lightInd = 1;
                                case 1 % med
                                    tempImg = uint16(read(Tiff(strcat(imgPath, imgName))));
                                    imwrite(tempImg, strcat(actualFiberPath, 'med\', imgName))
                                    lightInd = 2;
                                case 2 % long
                                    tempImg = uint16(read(Tiff(strcat(imgPath, imgName))));
                                    imwrite(tempImg, strcat(actualFiberPath, 'long\', imgName))
                                    lightInd = 0;
                            end
                            
                        elseif (str2double(imgID) >= darksStart)
                        
                            % it's a dark
                            switch darkInd
                                
                                case 0 % short
                                    tempImg = uint16(read(Tiff(strcat(imgPath, imgName))));
                                    imwrite(tempImg, strcat(darkPath, 'short\', imgName))
                                    darkInd = 1;
                                case 1 % med
                                    tempImg = uint16(read(Tiff(strcat(imgPath, imgName))));
                                    imwrite(tempImg, strcat(darkPath, 'med\', imgName))
                                    darkInd = 2;
                                case 2 % long
                                    tempImg = uint16(read(Tiff(strcat(imgPath, imgName))));
                                    imwrite(tempImg, strcat(darkPath, 'long\', imgName))
                                    darkInd = 0;
                            end
                        
                        end
                        
                    end
                    
                end
                
                
                % create the directories used for the case analysis
                
                % extracted fibers path
                workingPath = strcat(casePath, 'Extracted');
                workingPath = checkPath(workingPath);
                % make directory if it doesnt exist
                if (~exist(workingPath, 'dir'))
                    mkdir(workingPath);
                end
                % make scl subdirectory if it doesn't exist
                if (~exist(strcat(workingPath, '\scl'), 'dir'))
                    mkdir(strcat(workingPath, '\scl'));
                end
                % make boxed subdirectory if it doesn't exist
                if (~exist(strcat(workingPath, '\boxed'), 'dir'))
                    mkdir(strcat(workingPath, '\boxed'));
                end
                
                % specify other configurations
                
                % plot axis limits ([xmin, xmax, ymin, ymax])
                plotAxes = [8 23 1100 2000];
                
                % show the masks?
                showMask = false;
                
                
                % Preprocess each exposure
                PreprocessFiber(workingPath, strcat(actualFiberPath, 'short\'), caseOutPath, strcat(darkPath, 'short\'), cropLoc, burnerSize, burnerLoc, plotAxes, showMask, twostepDir)
                PreprocessFiber(workingPath, strcat(actualFiberPath, 'med\'), caseOutPath, strcat(darkPath, 'med\'), cropLoc, burnerSize, burnerLoc, plotAxes, showMask, twostepDir)
                PreprocessFiber(workingPath, strcat(actualFiberPath, 'long\'), caseOutPath, strcat(darkPath, 'long\'), cropLoc, burnerSize, burnerLoc, plotAxes, showMask, twostepDir)
            end
            
        end
        
        
    end
    
end

close all

% make it ding like a toaster
[y, Fs] = audioread('ding.wav');
sound(y/4, Fs);