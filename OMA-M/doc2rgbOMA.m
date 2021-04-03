function img = doc2rgbOMA(rawImg)

% only works with RGGB

% get height
[height, width] = size(rawImg);

% red and blue are easy
R = double(rawImg(1:2:height, 1:2:width));
B = double(rawImg(2:2:height, 2:2:width));

% green is not
G_UR = zeros(height, width);
G_DL = zeros(height, width);

% get upper right green
G_UR(1:2:height, 2:2:width) = rawImg(1:2:height, 2:2:width);
% get down left green
G_DL(2:2:height, 1:2:width) = rawImg(2:2:height, 1:2:width);

% get selected indices
G_sel = zeros(height, width);
G_sel(1:2:height, 2:2:width) = 1;
G_sel = logical(G_sel);

% add the two pixel values
G_temp = G_UR + circshift(G_DL, [-1, 1]);

% extract
G = double(G_temp(G_sel))/2;
G = reshape(G, [height/2, width/2]);

% assemble image
img = zeros(height/2, width/2, 3);
img(:, :, 1) = R;
img(:, :, 2) = G;
img(:, :, 3) = B;
img = uint16(img);