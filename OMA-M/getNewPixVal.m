function pixVal = getNewPixVal(pxls, thresh, mode)
% replaces the value of a pixel with the average of its neighbors if it is
% detected as a bad pixel

% NOTE: A pixel value of 0 means we're on the edge, so we omit these.

if (strcmp(mode, 'avg'))
    
    % in this case, we compare the threshold to the difference of the pixel
    % and the average of its neighbors
    if (thresh < abs(pxls(1) - mean(pxls(~(pxls == 0)))))
        pixVal = mean(pxls(~(pxls(2:9) == 0)));
    else
        pixVal = pxls(1);
    end
    
elseif (strcmp(mode, 'indiv'))
    
    if (thresh < abs(max(pxls(1) - pxls(2:9))))
        pixVal = mean(pxls(~(pxls(2:9) == 0)));
    else
        pixVal = pxls(1);
    end
    
else
    disp('Invalid mode')
end