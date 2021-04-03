clear
close all

% path to tiff images to process. This should be the output directory of
% BatchFiberExtract.m
path = 'D:\Documents\School Documents\2020-2021 Senior Year College\Research\Data\20176C1\Extracted Fibers\';
files = dir(path);
% store whether we generate masks here or we assume the mask is already
% generated. if this is false, the image is assumed to be 0 at all points
% except the fiber (no corrections are done at all)
generateMask = true;

for i = 1:length(files)
    
    name = files(i).name;
    dirStat = files(i).isdir;
    
    % only get tiffs
    if (~dirStat && (strcmp(name(end-3:end), 'tiff') || strcmp(name(end-2:end), 'tif')))
        
        img = double(read(Tiff(strcat(path, name))));
        
        % define channel smoothing
        % CHANGE THESE VALUES FOR DIFFERENT MASK GENERATION
        smoothX = 1;
        smoothY = 2;
        smoothYLum = 1;
        
        % extract r and g channels as doubles because later division
        r = img(:, :, 1);
        g = img(:, :, 2);
        
        % generate the mask
        if (generateMask) % this replicates the OMA mask generation
            
            % make horizontal mask
            
            % clip at 20% of mask brightness in red
            maskHoriz = clipfbOMA(r, .2);
            
            % normalize to [0, 1]
            maskHoriz = maskHoriz - min(maskHoriz(:));
            maskHoriz = maskHoriz/max(maskHoriz(:));
            
            % binarize the mask
            maskHoriz = maskOMA(maskHoriz, .2);
            
            % smooth it in y to include more of the fiber's light
            maskHoriz = smoothOMA(maskHoriz, 0, smoothY);
            
            % normalize to [0, 1]
            maskHoriz = maskHoriz - min(maskHoriz(:));
            maskHoriz = maskHoriz/max(maskHoriz(:));
            
            % binarize mask
            maskHoriz = maskOMA(maskHoriz, .2);
            
            % make vertical mask
            
            % smooth the red
            maskVert = smoothOMA(r, smoothX, 0);
            
            % multiply it by the horizontal mask
            maskVert = maskVert .* maskHoriz;
            
            % integrate it vertically
            maskVert = intfillOMA(maskVert, 1);
            
            % normalize to [0, 1]
            maskVert = maskVert - min(maskVert(:));
            maskVert = maskVert/max(maskVert(:));
            
            % binarize
            maskVert = maskOMA(maskVert, .1);
            
            % smooth the channels
            r = smoothOMA(r, smoothX, 0);
            g = smoothOMA(g, smoothX, 0);
            
            % multiply by the masks
            r = r .* maskHoriz .* maskVert;
            g = g .* maskHoriz .* maskVert;
            
        end
        
        % vertical integration
        r = intfillOMA(r, 1);
        g = intfillOMA(g, 1);
        
        % divide channels
        gDivr = g ./ r;
        % remove the Infs and NaNs (set to 0)
        gDivr(~isfinite(gDivr)) = 0;
        
        % convert divided channels to lookup values
        load('GRnoFilterFiberWin1.1.mat');
        
        fullTemp = interp1(grRatio, temp, gDivr);
        % remove NaNs again
        fullTemp(~isfinite(gDivr)) = 0;
        
        % this is the file you output.
        fiberTemp = fullTemp(1, :);
        
        % get a spline of the fiber's coordinates based on red intensity
        r = img(:, :, 1);
        % multiply it by the mask
        r = r .* maskHoriz .* maskVert;
        
        % blur r in the y only to remove noise
        r = smoothOMA(r, 0, smoothYLum);
        
        % store Y coordinate of center of fiber
        [~, Y] = max(r, [], 1);
        Y(Y<=1) = NaN;
        % make array of X coordinates for this local image
        X = zeros(1, length(Y));
        
    end
    
end