function [] = extractFiber(colorImg, mask, burnerLoc, saveDir, imgName, sclSubfolder, maskMode, plotPath, pxlScl, plotAxes, manualFibers)

% store whether to output the plots
outputPlot = true;

% store whether to output the boxed fibers
outputBox = false;
if (outputBox)
    boxImg = colorImg;
end
% subfolder to store the boxes (must have trailing \)
boxPathSubfolder = 'boxed\';

% number of the fiber being output
fiberNum = 1;

% make a figure to plot
figure()
xlabel('Radius from Burner [mm]')
ylabel('Temperature [K]')
title(imgName, 'Interpreter', 'none')
axis(plotAxes)
hold on

[height, width] = size(mask);

% search for location of top/bottom of fibers
fiberRowStart = 0;
fiberRowEnd = 0;

detecting = false;

for y = 1:height
    
    currRow = mask(y, :);
    consPix = 0;

    endDetection = true;
    
    % loop through pixels in row
    for x = 1:width
        
        if (currRow(x) ~= 0)
            
            consPix = consPix + 1;
            
        else
            
            consPix = 0;
            
        end
        
        % check if we're detecting
        if (~detecting)
            
            % if not, look for 5 consecutive white pixels
            if (currRow(x) ~= 0)
                
                if (consPix >= 5)
                    
                    % if we find them, engage detection
                    detecting = true;
                    fiberRowStart = y;
                    endDetection = false;
                    
                    break;
                    
                end
                
            end

        else
            
            % if we are, check if the current row has 5 consecutive white 
            % pixels
            if (consPix >= 5)
                
                % if it does, it's still part of the fiber
                endDetection = false;
                
            end
        end
    end
        
    % check if we are detecting and detected the end of fiber
    if (detecting && endDetection)
        
        fiberRowEnd = y-1;
        detecting = false;
        
    end
    
    % check if we found a start and end
    if (fiberRowStart ~= 0 && fiberRowEnd ~= 0)
        
        % check thickness of fiber (must be greater than some arbitrary
        % number of pixels
        if (fiberRowEnd - fiberRowStart > 2)
            
            % if we're using 'lum' mask mode, we need to generate a
            % vertical mask to extract the columns
            if (strcmp(maskMode, 'lum'))
                
                % extract just the fiber
                croppedFiberRGB = colorImg(fiberRowStart:fiberRowEnd, :, :);
                
                % convert it to BW (red - blue)
                croppedFiberBW = croppedFiberRGB(:, :, 1) - croppedFiberRGB(:, :, 3);
                
                % intfill in y
                croppedFiberInt = intfillOMA(croppedFiberBW, 1);
                
                % normalize to [0, 1]
                croppedFiberIntNorm = croppedFiberInt - min(croppedFiberInt(:));
                croppedFiberIntNorm = (croppedFiberIntNorm/max(croppedFiberIntNorm(:)));
                
                % create binarized mask
                % CHANGE THIS VALUE FOR MASK SENSITIVITY
                maskVert = maskOMA(croppedFiberIntNorm, .2);
                
                % smooth in x
                maskSmooth = smoothOMA(maskVert, 3, 0);
                
                % normalize to [0, 1]
                maskSmooth = maskSmooth - min(maskSmooth(:));
                maskSmooth = maskSmooth/max(maskSmooth(:));
                
                % get height of this smaller image
                [heightC, ~] = size(maskSmooth);
                
                % search for location of left/right of fiber given row number
                [fiberColStart, fiberColEnd] = extractCols(maskSmooth, 1, heightC);
                
            else
                
                % search for location of left/right of fiber given row number
                [fiberColStart, fiberColEnd] = extractCols(mask, fiberRowStart, fiberRowEnd);
                
            end
            
            if (fiberColStart ~= 0 && fiberColEnd ~= 0 && fiberColEnd < width)
                % extract the fiber
                fiber = colorImg(fiberRowStart:fiberRowEnd, fiberColStart:fiberColEnd, :);
                
                % save fiber image to disk
                imwrite(uint16(fiber), strcat(saveDir, imgName, '_f', int2str(fiberNum), '.tiff'));
                
                % save scaled fiber image to disk
                imwrite(uint16((fiber - min(fiber(:))) * (2^16-1)/max(fiber(:))), strcat(saveDir, sclSubfolder, imgName, '_f', int2str(fiberNum), '.tiff'))
                
                % write boxed image to disk if applicable (constant
                % scaling)
                if (outputBox)
                    
                    % make a white box on the image of the extracted fiber
                    boxImg(fiberRowStart - 1, (fiberColStart - 1):(fiberColEnd + 1), :) = (2^12 - 1);
                    boxImg(fiberRowEnd + 1, (fiberColStart - 1):(fiberColEnd + 1), :) = (2^12 - 1);
                    boxImg((fiberRowStart - 1):(fiberRowEnd + 1), fiberColStart -  1, :) = (2^12 - 1);
                    boxImg((fiberRowStart - 1):(fiberRowEnd + 1), fiberColEnd +  1, :) = (2^12 - 1);
                    
                end
                
                % run the temperature analysis
                tempPxls = fiberTemp(fiber, [fiberRowStart, fiberColStart], burnerLoc, pxlScl);
                % plot it
                scatter(tempPxls(:, 1), tempPxls(:, 2), 'DisplayName', strcat("Fiber ", num2str(fiberNum)));
                T = array2table(tempPxls);
                T.Properties.VariableNames = {'Radius [mm]', 'Temperature'};
                writetable(T, strcat(plotPath, strcat(imgName, "_f", num2str(fiberNum)), '.xlsx'))
                
                % increment fiber number
                fiberNum = fiberNum + 1;
            end
            
        end
        
        % reset for next fiber
        fiberRowStart = 0;
        fiberRowEnd = 0;
        
    end
    
end

if (outputBox)
    % factor of max of 4095
    imwrite(uint16(boxImg * (2^16-1)/(2^12 - 1)), strcat(saveDir, boxPathSubfolder, imgName, '.tiff'))
end

manualFiberNum = 1;
% process manually specified fibers
[numManual, ~] = size(manualFibers);
for i = 1:numManual
    
    % extract the manual fiber
    fiber = colorImg(manualFibers(1):manualFibers(3), manualFibers(2):manualFibers(4), :);
    
    % run the temperature analysis
    tempPxls = fiberTemp(fiber, [manualFibers(1), manualFibers(2)], burnerLoc, pxlScl);
    % plot it
    scatter(tempPxls(:, 1), tempPxls(:, 2), 'DisplayName', strcat("Manual Fiber ", num2str(manualFiberNum)));
    T = array2table(tempPxls);
    T.Properties.VariableNames = {'Radius [mm]', 'Temperature'};
    writetable(T, strcat(plotPath, strcat(imgName, "_mf", num2str(manualFiberNum)), '.xlsx'))
    
    % increment fiber number
    manualFiberNum = manualFiberNum + 1;
    
end


legend('show')

if (outputPlot)
    
    saveas(gcf, strcat(plotPath, imgName, '.png'));
    
end