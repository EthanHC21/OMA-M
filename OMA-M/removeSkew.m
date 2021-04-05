function nonSkewed = removeSkew(bgImg, thresh, lim) % thresh is an abs

% sort array
sorted = sort(bgImg(:));

% get original size
% origSize = length(sorted);

s = skewness(sorted);

while (abs(thresh) < s)
    
    if (s > thresh)
        
        % if skewness is greater than thresh, we remove one of the end
        % elements
        
        sorted = sorted(1:(length(sorted) - 1));
        
    else
        
        % if skewness is greater than thresh, we remove one of the end
        % elements
        sorted = sorted(2:length(sorted));
        
    end
    
    s = skewness(sorted);
    
end

if (length(sorted) < lim)
    
    disp('Error: Resulting array too small.')
    
else
    
    nonSkewed = sorted;
    
end

% pxlsRem = origSize - length(nonSkewed);
% disp(strcat('Removed ', num2str(pxlsRem), 'outliers.'))