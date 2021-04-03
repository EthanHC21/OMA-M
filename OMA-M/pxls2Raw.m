function img = pxls2Raw(R, G, B)

% get size of green
[height, width] = size(G);
% preallocate final image to a value that the channels can never take
img = zeros(height, width);

% just store the arrays in the image
% red and blue are easy because we know what their indices are
img(1:2:height, 1:2:width) = R;
img(2:2:height, 2:2:width) = B;
% for green, since it's the same size as the image, we just add it
img = img + G;