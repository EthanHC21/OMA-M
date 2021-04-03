function img = clipfbOMA(img, frac)

% get max value
maxVal = max(img(:));

% get critical pixel value
crit = maxVal * frac;

img(img<crit) = crit;