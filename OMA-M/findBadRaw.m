function [bad_R, bad_G, bad_B] = findBadRaw(img, thresh)
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

% we now need to remove the 8 (or 4) neighbors as bad pixels which were
% added as a result of the extreme value of the central bad pixel
% preallocate neighbors
neighborsR = zeros(heightRB+2, widthRB+2, 8);
neighborsB = zeros(heightRB+2, widthRB+2, 8);
neighborsG = zeros(heightG+2, widthG+2, 4);

% reassign the loop arrays to be the bad arrays
loop_R = zeros(heightRB + 2, widthRB + 2);
loop_R(2:heightRB+1, 2:widthRB+1) = bad_R;

loop_G = zeros(heightG + 2, widthG + 2);
loop_G(2:heightG+1, 2:widthG+1) = bad_G;

loop_B = zeros(heightRB + 2, widthRB + 2);
loop_B(2:heightRB+1, 2:widthRB+1) = bad_B;

% neighbor assignment, but this time keep the surrounding zeros
% up
loop_R_U = circshift(loop_R, [1, 0]);
loop_B_U = circshift(loop_B, [1, 0]);
neighborsR(:, :, 1) = loop_R_U;
neighborsB(:, :, 1) = loop_B_U;
% down
loop_R_D = circshift(loop_R, [-1, 0]);
loop_B_D = circshift(loop_B, [-1, 0]);
neighborsR(:, :, 2) = loop_R_D;
neighborsB(:, :, 2) = loop_B_D;
% left
loop_R_L = circshift(loop_R, [0, 1]);
loop_B_L = circshift(loop_B, [0, 1]);
neighborsR(:, :, 3) = loop_R_L;
neighborsB(:, :, 3) = loop_B_L;
% right
loop_R_R = circshift(loop_R, [0, -1]);
loop_B_R = circshift(loop_B, [0, -1]);
neighborsR(:, :, 4) = loop_R_R;
neighborsB(:, :, 4) = loop_B_R;

% green has these neighbors (yes the numbering doesn't make sense with the
% red and blue just it's G+4)
% up left
loop_R_UL = circshift(loop_R, [1, 1]);
loop_G_UL = circshift(loop_G, [1, 1]);
loop_B_UL = circshift(loop_B, [1, 1]);
neighborsR(:, :, 5) = loop_R_UL;
neighborsB(:, :, 5) = loop_B_UL;
neighborsG(:, :, 1) = loop_G_UL;
% up right
loop_R_UR = circshift(loop_R, [1, -1]);
loop_G_UR = circshift(loop_G, [1, -1]);
loop_B_UR = circshift(loop_B, [1, -1]);
neighborsR(:, :, 6) = loop_R_UR;
neighborsB(:, :, 6) = loop_B_UR;
neighborsG(:, :, 2) = loop_G_UR;
% down left
loop_R_DL = circshift(loop_R, [-1, 1]);
loop_G_DL = circshift(loop_G, [-1, 1]);
loop_B_DL = circshift(loop_B, [-1, 1]);
neighborsR(:, :, 7) = loop_R_DL;
neighborsB(:, :, 7) = loop_B_DL;
neighborsG(:, :, 3) = loop_G_DL;
% down right
loop_R_DR = circshift(loop_R, [-1, -1]);
loop_G_DR = circshift(loop_G, [-1, -1]);
loop_B_DR = circshift(loop_B, [-1, -1]);
neighborsR(:, :, 8) = loop_R_DR;
neighborsB(:, :, 8) = loop_B_DR;
neighborsG(:, :, 4) = loop_G_DR;

% collapse the neighbors to one value
neighborsR_tot = sum(neighborsR, 3);
neighborsB_tot = sum(neighborsB, 3);
neighborsG_tot = sum(neighborsG, 3);

% save these indices as hot pixels
hot_R = neighborsR_tot >= 8;
hot_G = neighborsG_tot >= 4;
hot_B = neighborsB_tot >= 8;

% intfill these
for i = 1:8 % red/blue
    
    neighborsR(:, :, i) = neighborsR_tot;
    neighborsB(:, :, i) = neighborsB_tot;
    
end

for i = 1:4 % green
    
    neighborsG(:, :, i) = neighborsG_tot;
    
end

% we set the neighbor values that correspond to all neighbors being
% selected to -1 in order to eventually remove them from the bad pixels.
% This is the rejection step, and it can be edited to reject a threshold.
neighborsR(~neighborsR>=8) = 0;
neighborsR(neighborsR>=8) = -1;
neighborsB(~neighborsB>=8) = 0;
neighborsB(neighborsB>=8) = -1;
neighborsG(~neighborsG>=4) = 0;
neighborsG(neighborsG>=4) = -1;
% NEEDS TO BE ADJUSTED FOR EDGES - can be done with a comparison of the
% mean with NaN and non NaN

% undo all of the circular shifts
% up
loop_R_U = circshift(neighborsR(:, :, 1), [-1, 0]);
loop_B_U = circshift(neighborsB(:, :, 1), [-1, 0]);
% down
loop_R_D = circshift(neighborsR(:, :, 2), [1, 0]);
loop_B_D = circshift(neighborsB(:, :, 2), [1, 0]);
% left
loop_R_L = circshift(neighborsR(:, :, 3), [0, -1]);
loop_B_L = circshift(neighborsB(:, :, 3), [0, -1]);
% right
loop_R_R = circshift(neighborsR(:, :, 4), [0, 1]);
loop_B_R = circshift(neighborsB(:, :, 4), [0, 1]);

% green has these neighbors (yes the numbering doesn't make sense with the
% red and blue just it's G+4)
% up left
loop_R_UL = circshift(neighborsR(:, :, 5), [-1, -1]);
loop_G_UL = circshift(neighborsG(:, :, 1), [-1, -1]);
loop_B_UL = circshift(neighborsB(:, :, 5), [-1, -1]);
% up right
loop_R_UR = circshift(neighborsR(:, :, 6), [-1, 1]);
loop_G_UR = circshift(neighborsG(:, :, 2), [-1, 1]);
loop_B_UR = circshift(neighborsB(:, :, 6), [-1, 1]);
% down left
loop_R_DL = circshift(neighborsR(:, :, 7), [1, -1]);
loop_G_DL = circshift(neighborsG(:, :, 3), [1, -1]);
loop_B_DL = circshift(neighborsB(:, :, 7), [1, -1]);
% down right
loop_R_DR = circshift(neighborsR(:, :, 8), [1, 1]);
loop_G_DR = circshift(neighborsG(:, :, 4), [1, 1]);
loop_B_DR = circshift(neighborsB(:, :, 8), [1, 1]);

% add all of these together and resize them to the correct size
loop_R_neighbors = loop_R_U + loop_R_D + loop_R_L + loop_R_R + loop_R_UL + loop_R_UR + loop_R_DL + loop_R_DR;
loop_R_neighbors = loop_R_neighbors(2:heightRB+1, 2:widthRB+1);

loop_B_neighbors = loop_B_U + loop_B_D + loop_B_L + loop_B_R + loop_B_UL + loop_B_UR + loop_B_DL + loop_B_DR;
loop_B_neighbors = loop_B_neighbors(2:heightRB+1, 2:widthRB+1);

loop_G_neighbors = loop_G_UL + loop_G_UR + loop_G_DL + loop_G_DR;
loop_G_neighbors = loop_G_neighbors(2:heightG+1, 2:widthG+1);

% remove neighbors from bad arrays
bad_R = bad_R - loop_R_neighbors;
bad_B = bad_B - loop_B_neighbors;
bad_G = bad_G - loop_G_neighbors;

% normalize to [0, 1]
bad_R(bad_R<0) = 0;
bad_R(bad_R>1) = 1;

bad_G(bad_G<0) = 0;
bad_G(bad_G>1) = 1;

bad_B(bad_B<0) = 0;
bad_B(bad_B>1) = 1;

% add in the hot pixels
bad_R = bad_R + hot_R(2:heightRB+1, 2:widthRB+1);
bad_B = bad_B + hot_B(2:heightRB+1, 2:widthRB+1);
bad_G = bad_G + hot_G(2:heightG+1, 2:widthG+1);