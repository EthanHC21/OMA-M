function maskCandidate = maskOMA(maskCandidate, frac)

% get the values that will be 1
whites = maskCandidate>frac;

% set them as 1
maskCandidate(whites) = 1;

% set the inverse to 0
maskCandidate(~whites) = 0;