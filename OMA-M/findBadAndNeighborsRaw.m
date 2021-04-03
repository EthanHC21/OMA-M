function [bad_R, bad_G, bad_B] = findBadAndNeighborsRaw(img, thresh)
% must be run on a raw (non-debayered) image

% get the colored pixels
[img_R, img_G, img_B] = extractColoredPixels(img);

% get array sizes
[heightRB, widthRB] = size(img_R);
[heightG, widthG] = size(img_G);

% make images to loop over (image surrounded by zeros)
loop_R = zeros(heightRB + 2, widthRB + 2);
loop_R(2:heightRB+1, 2:widthRB+1) = img_R;

loop_G = zeros(heightG + 2, widthG + 2);
loop_G(2:heightG+1, 2:widthG+1) = img_G;

loop_B = zeros(heightRB + 2, widthRB + 2);
loop_B(2:heightRB+1, 2:widthRB+1) = img_B;

% make images for the neighbors so I don't have to wait for for loops to go
% for hours. The name indicates which neighbor is at the pixel's position.
% preallocate arrays to hold the neighbors
neighborsR = zeros(heightRB, widthRB, 8);
neighborsB = zeros(heightRB, widthRB, 8);
neighborsG = zeros(heightG, widthG, 4);

% up
loop_R_U = circshift(loop_R, [1, 0]);
loop_B_U = circshift(loop_B, [1, 0]);
neighborsR(:, :, 1) = loop_R_U(2:heightRB+1, 2:widthRB+1);
neighborsB(:, :, 1) = loop_B_U(2:heightRB+1, 2:widthRB+1);
% down
loop_R_D = circshift(loop_R, [-1, 0]);
loop_B_D = circshift(loop_B, [-1, 0]);
neighborsR(:, :, 2) = loop_R_D(2:heightRB+1, 2:widthRB+1);
neighborsB(:, :, 2) = loop_B_D(2:heightRB+1, 2:widthRB+1);
% left
loop_R_L = circshift(loop_R, [0, 1]);
loop_B_L = circshift(loop_B, [0, 1]);
neighborsR(:, :, 3) = loop_R_L(2:heightRB+1, 2:widthRB+1);
neighborsB(:, :, 3) = loop_B_L(2:heightRB+1, 2:widthRB+1);
% right
loop_R_R = circshift(loop_R, [0, -1]);
loop_B_R = circshift(loop_B, [0, -1]);
neighborsR(:, :, 4) = loop_R_R(2:heightRB+1, 2:widthRB+1);
neighborsB(:, :, 4) = loop_B_R(2:heightRB+1, 2:widthRB+1);

% green has these neighbors (yes the numbering doesn't make sense with the
% red and blue just it's G+4)
% up left
loop_R_UL = circshift(loop_R, [1, 1]);
loop_G_UL = circshift(loop_G, [1, 1]);
loop_B_UL = circshift(loop_B, [1, 1]);
neighborsR(:, :, 5) = loop_R_UL(2:heightRB+1, 2:widthRB+1);
neighborsB(:, :, 5) = loop_B_UL(2:heightRB+1, 2:widthRB+1);
neighborsG(:, :, 1) = loop_G_UL(2:heightG+1, 2:widthG+1);
% up right
loop_R_UR = circshift(loop_R, [1, -1]);
loop_G_UR = circshift(loop_G, [1, -1]);
loop_B_UR = circshift(loop_B, [1, -1]);
neighborsR(:, :, 6) = loop_R_UR(2:heightRB+1, 2:widthRB+1);
neighborsB(:, :, 6) = loop_B_UR(2:heightRB+1, 2:widthRB+1);
neighborsG(:, :, 2) = loop_G_UR(2:heightG+1, 2:widthG+1);
% down left
loop_R_DL = circshift(loop_R, [-1, 1]);
loop_G_DL = circshift(loop_G, [-1, 1]);
loop_B_DL = circshift(loop_B, [-1, 1]);
neighborsR(:, :, 7) = loop_R_DL(2:heightRB+1, 2:widthRB+1);
neighborsB(:, :, 7) = loop_B_DL(2:heightRB+1, 2:widthRB+1);
neighborsG(:, :, 3) = loop_G_DL(2:heightG+1, 2:widthG+1);
% down right
loop_R_DR = circshift(loop_R, [-1, -1]);
loop_G_DR = circshift(loop_G, [-1, -1]);
loop_B_DR = circshift(loop_B, [-1, -1]);
neighborsR(:, :, 8) = loop_R_DR(2:heightRB+1, 2:widthRB+1);
neighborsB(:, :, 8) = loop_B_DR(2:heightRB+1, 2:widthRB+1);
neighborsG(:, :, 4) = loop_G_DR(2:heightG+1, 2:widthG+1);

% preallocate boolean array stating bad pixels
bad_R = zeros(heightRB, widthRB);
bad_B = zeros(heightRB, widthRB);
bad_G = zeros(heightG, widthG);

% set values in the neighbors array to NaN so they are ignored in the mean
% calculation
neighborsR(neighborsR == 0) = NaN;
neighborsG(neighborsG == 0) = NaN;
neighborsB(neighborsB == 0) = NaN;

% calculate which pixels are bad
bad_R(thresh < abs(img_R - mean(neighborsR, 3, 'omitnan'))) = 1;
bad_B(thresh < abs(img_B - mean(neighborsB, 3, 'omitnan'))) = 1;
bad_G(thresh < abs(img_G - mean(neighborsG, 3, 'omitnan'))) = 1;

% also add the neighbors of each bad pixel
loop_bad_R = zeros(heightRB + 2, widthRB + 2);
loop_bad_B = zeros(heightRB + 2, widthRB + 2);
loop_bad_G = zeros(heightG + 2, widthG + 2);
loop_bad_R(2:heightRB+1, 2:widthRB+1) = bad_R;
loop_bad_B(2:heightRB+1, 2:widthRB+1) = bad_B;
loop_bad_G(2:heightG+1, 2:widthG+1) = bad_G;

% up left
loop_bad_R = loop_bad_R + circshift(loop_bad_R, [1, 1]);
loop_bad_G = loop_bad_G + circshift(loop_bad_G, [1, 1]);
loop_bad_B = loop_bad_B + circshift(loop_bad_B, [1, 1]);
% up right
loop_bad_R = loop_bad_R + circshift(loop_bad_R, [1, -1]);
loop_bad_G = loop_bad_G + circshift(loop_bad_G, [1, -1]);
loop_bad_B = loop_bad_B + circshift(loop_bad_B, [1, -1]);
% down left
loop_bad_R = loop_bad_R + circshift(loop_bad_R, [-1, 1]);
loop_bad_G = loop_bad_G + circshift(loop_bad_G, [-1, 1]);
loop_bad_B = loop_bad_B + circshift(loop_bad_B, [-1, 1]);
% down right
loop_bad_R = loop_bad_R + circshift(loop_bad_R, [-1, -1]);
loop_bad_G = loop_bad_G + circshift(loop_bad_G, [-1, -1]);
loop_bad_B = loop_bad_B + circshift(loop_bad_B, [-1, -1]);
% up
loop_bad_R = loop_bad_R + circshift(loop_bad_R, [1, 0]);
loop_bad_B = loop_bad_B + circshift(loop_bad_B, [1, 0]);
% down
loop_bad_R = loop_bad_R + circshift(loop_bad_R, [-1, 0]);
loop_bad_B = loop_bad_B + circshift(loop_bad_B, [-1, 0]);
% left
loop_bad_R = loop_bad_R + circshift(loop_bad_R, [0, 1]);
loop_bad_B = loop_bad_B + circshift(loop_bad_B, [0, 1]);
% right
loop_bad_R = loop_bad_R + circshift(loop_bad_R, [0, -1]);
loop_bad_B = loop_bad_B + circshift(loop_bad_B, [0, -1]);

% save these
bad_R = loop_bad_R(2:heightRB+1, 2:widthRB+1);
bad_B = loop_bad_B(2:heightRB+1, 2:widthRB+1);
bad_G = loop_bad_G(2:heightG+1, 2:widthG+1);

% normalize them back to [0, 1]
bad_R(bad_R > 1) = 1;
bad_B(bad_B > 1) = 1;
bad_G(bad_G > 1) = 1;