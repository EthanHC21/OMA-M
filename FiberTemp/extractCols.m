function [leftmost, rightmost] = extractCols(mask, rowStart, rowEnd)

% looking for beginning and end of fiber in cropped row
leftmost = 0;
rightmost = 0;

[~, width] = size(mask);

% row iterate
for y = rowStart:rowEnd
    
    consWhitePix = 0;
    
    % look for 5 consecutive white pixels coming from the left
    for x = 1:width
        
        % white pixel found
        if (mask(y, x) ~= 0)
            consWhitePix = consWhitePix + 1;
        end
        
        % if 5 white pixels are found
        if (consWhitePix >= 5)
            if (leftmost == 0)
                leftmost = x-5;         % location of left boundary
            elseif (x - 5 < leftmost)   % override old location if this location is farther left
                leftmost = x - 5;       
            end
            break;
        end
    end
    
    % if black pixel is found, restart count -- 
    consWhitePix = 0;
    
    % look for 5 consecutive white pixels coming from the right
    for x = width:-1:1
        
        % white pixel found
        if (mask(y, x) ~= 0)
            consWhitePix = consWhitePix + 1;
        end
        
        % if 5 white pixels are found
        if (consWhitePix >= 5)
            if (rightmost == 0)
                rightmost = x+5;        % location of right boundary
            elseif (x + 5 > rightmost)  % override old location if this is location is farther right
                rightmost = x + 5;
            end
            break;
        end
    end
end
