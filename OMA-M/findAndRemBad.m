function cleanImg = findAndRemBad(img, thresh, iterations)
% this is based on the functionality of OMA2

% get size of image
[height, width, chnls] = size(img);
% preallocate a clean array
cleanImg = zeros(height, width, chnls);

% make an image that has a boarder of 0's around it so we can loop the
% edges.
loopImg = zeros(height + 2, width + 2, chnls);
% store the image in the center of this one
loopImg(2:height+1, 2:width+1, :) = double(img);

% loop to control the iteration
for l = 1:iterations
    % loop over the entire image
    for o = 1:chnls
        
        % make images for the neighbors so I don't have to wait for for loops to go
        % for hours. The name indicates which neighbor is at the pixel's position.
        % preallocate arrays to hold the neighbors
        neighbors = zeros(height, width, 8);
        
        % up
        loopImg_U = circshift(loopImg, [1, 0]);
        neighbors(:, :, 1) = loopImg_U(2:height+1, 2:width+1);
        % down
        loopImg_D = circshift(loopImg, [-1, 0]);
        neighbors(:, :, 2) = loopImg_D(2:height+1, 2:width+1);
        % left
        loopImg_L = circshift(loopImg, [0, 1]);
        neighbors(:, :, 3) = loopImg_L(2:height+1, 2:width+1);
        % right
        loopImg_R = circshift(loopImg, [0, -1]);
        neighbors(:, :, 4) = loopImg_R(2:height+1, 2:width+1);
        % up left
        loopImg_UL = circshift(loopImg, [1, 1]);
        neighbors(:, :, 5) = loopImg_UL(2:height+1, 2:width+1);
        % up right
        loopImg_UR = circshift(loopImg, [1, -1]);
        neighbors(:, :, 6) = loopImg_UR(2:height+1, 2:width+1);
        % down left
        loopImg_DL = circshift(loopImg, [-1, 1]);
        neighbors(:, :, 7) = loopImg_DL(2:height+1, 2:width+1);
        % down right
        loopImg_DR = circshift(loopImg, [-1, -1]);
        neighbors(:, :, 8) = loopImg_DR(2:height+1, 2:width+1);
        
        % preallocate boolean array stating bad pixels
        badPxls = zeros(height, width);
        
        % set values in the neighbors array to NaN so they are ignored in the mean
        % calculation
        neighbors(neighbors == 0) = NaN;
        
        % calculate which pixels are bad
        badPxls(thresh < abs(img(:, :, o) - mean(neighbors, 3, 'omitnan'))) = 1;
        
        % fill these with the fixed pixels
        % calculate replacement pixels for each color (must be done to index
        % properly, much faster than waiting for a for loop).
        replacements = mean(neighbors, 3, 'omitnan');
        
        cleanImg(logical(badPxls)) = replacements(logical(badPxls));
        
    end
    
    loopImg(2:height+1, 2:width+1, :) = cleanImg;
    
end