function [R, G, B] = extractColoredPixels(rawImg)
% NOTE: THIS ASSUMES AN RGGB BAYER PATTERN!!!

% extract the pixels from the bayer pattern
[height, width] = size(rawImg);

% red and blue are easy
R = rawImg(1:2:height, 1:2:width);
B = rawImg(2:2:height, 2:2:width);

% preallocate green
G = zeros(height, width);
% green needs a loop
for m = 1:height
    % check if we're on an even or odd row
    
    if (mod(m, 2) == 1) % if row is odd
        % green pixels have even column indices
        G(m, 2:2:width) = rawImg(m, 2:2:width);
        
    else % if row is even
        
        % green pixels have odd column indices
        G(m, 1:2:width) = rawImg(m, 1:2:width);
        
    end
end