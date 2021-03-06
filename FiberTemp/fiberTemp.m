function tempPxls = fiberTemp(fiberImg, fiberStart, burnerLoc, pxlScl)
% store whether we generate masks here or we assume the mask is already
% generated. if this is false, the image is assumed to be 0 at all points
% except the fiber (no corrections are done at all)
generateMask = 'stats';

% define channel smoothing
% CHANGE THESE VALUES FOR DIFFERENT MASK GENERATION
smoothX = 1;
smoothY = 2;
smoothYLum = 1;

% extract r and g channels as doubles because later division
r = fiberImg(:, :, 1);
g = fiberImg(:, :, 2);

% generate the mask
if (strcmp(generateMask, 'oma')) % this replicates the OMA mask generation
    
    % make horizontal mask
    
    % clip at 50% of max brightness in red
    maskHoriz = clipfbOMA(r, .5);
    
    % normalize to [0, 1]
    maskHoriz = maskHoriz - min(maskHoriz(:));
    
    maskHoriz = intfillOMA(maskHoriz, 0);
    
    maskHoriz = maskHoriz/max(maskHoriz(:));
    
    % binarize the mask
    maskHoriz = maskOMA(maskHoriz, .2);
    
    % smooth it in y to include more of the fiber's light
    maskHoriz = smoothOMA(maskHoriz, 0, smoothY);
    
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
    maskVert = maskVert/max(maskVert(:));
    
    % binarize
    maskVert = maskOMA(maskVert, .1);
    
    % smooth the channels
    r = smoothOMA(r, smoothX, 0);
    g = smoothOMA(g, smoothX, 0);
    
    % multiply by the masks
    r = r .* maskHoriz;
    g = g .* maskHoriz;
    
elseif (strcmp(generateMask, 'stats'))
    
    % clip at 70% of max brightness in red
    maskVert = clipfbOMA(r, .7);
    
    % normalize to [0, 1]
    maskVert = maskVert - min(maskVert(:));
    maskVert = maskVert/max(maskVert(:));
    
    % smooth the mask
    maskVert = smoothOMA(maskVert, smoothX, smoothY);
    
    % integrate it vertically
    maskVert = intfillOMA(maskVert, 1);
    
    % binarize
    maskVert = maskOMA(maskVert, .2);
    
    % make it the same procedure as the horizontal because reasons
    maskHoriz = clipfbOMA(r, .7);
    maskHoriz = maskHoriz - min(maskHoriz(:));
    maskHoriz = maskHoriz/max(maskHoriz(:));
    maskHoriz = smoothOMA(maskHoriz, smoothX, smoothY);
    maskHoriz = intfillOMA(maskHoriz, 0);
    maskHoriz = maskOMA(maskHoriz, .2);
    
    % smooth the channels
    r = smoothOMA(r, smoothX, 0);
    g = smoothOMA(g, smoothX, 0);
    
end

% vertical integration
r = intfillOMA(r, 1);
g = intfillOMA(g, 1);

% divide channels
gDivr = g ./ r;
% apply masks
gDivr = gDivr .* maskHoriz .* maskVert;
% remove the Infs and NaNs (set to 0)
gDivr(~isfinite(gDivr)) = 0;

% convert divided channels to lookup values
load('grRatioOut.mat');

fullTemp = interp1(grRatio, temp, gDivr);
% make this a 1D array
fiberTemp = mean(fullTemp, 1, 'omitnan');

% get a spline of the fiber's coordinates based on red intensity
r = fiberImg(:, :, 1);
% multiply it by the mask
r = r .* maskHoriz .* maskVert;

% blur r in the y only to remove noise
% r = smoothOMA(r, 0, smoothYLum);

% store Y coordinate of center of fiber
[~, Y] = max(r, [], 1);
Y(Y<=1) = NaN;
% make array of X coordinates for this local image
X = 1:length(Y);

% remove NaN values
X = X(isfinite(Y));
fiberTemp = fiberTemp(isfinite(Y));
Y = Y(isfinite(Y));

% correct X and Y for the crop
Y = Y + fiberStart(1) - 1;
X = X + fiberStart(2) - 1;

% calculate the radius
radius = sqrt((Y - burnerLoc(1)).^2 + (X - burnerLoc(2)).^2);

% store the pixel coords and temperature as a matrix with columns
% [radius, temperature]
tempPxls = [transpose(radius) * pxlScl, transpose(fiberTemp)];

% sort the array
[~, I] = sort(tempPxls(:, 1));
tempPxls = [tempPxls(I, 1), tempPxls(I, 2)];