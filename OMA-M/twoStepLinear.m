function img = twoStepLinear(rawImg, dir)

% convert to double
rawImg = double(rawImg);

% get height
[height, width] = size(rawImg);

% make selection arrays
% red (easy)
R_sel = zeros(height, width);
R_sel(1:2:height, 1:2:width) = 1;
R_sel = logical(R_sel);

% green (not easy)
G_sel = zeros(height, width);
G_sel(1:2:height, 2:2:width) = 1;
G_sel(2:2:height, 1:2:width) = 1;
G_sel = logical(G_sel);

% blue (easy)
B_sel = zeros(height, width);
B_sel(2:2:height, 2:2:width) = 1;
B_sel = logical(B_sel);

% extract pixels
R = zeros(height, width);
R(R_sel) = rawImg(R_sel);

G = zeros(height, width);
G(G_sel) = rawImg(G_sel);

B = zeros(height, width);
B(B_sel) = rawImg(B_sel);

if (dir == 0)
    
    % red and blue are easy
    % interpolate in the first direction
    R_interp1 = (circshift(R, [0, 1]) + circshift(R, [0, -1]))/2;
    B_interp1 = (circshift(B, [0, 1]) + circshift(B, [0, -1]))/2;
    
    % get meaningful pixels
    R_sel1 = zeros(height, width);
    R_sel1(1:2:height, 2:2:width) = R_interp1(1:2:height, 2:2:width);
    R_sel1 = logical(R_sel1);
    
    B_sel1 = zeros(height, width);
    B_sel1(2:2:height, 1:2:width) = B_interp1(2:2:height, 1:2:width);
    B_sel1 = logical(B_sel1);
    
    % add these to the regular array
    R(R_sel1) = R_interp1(R_sel1);
    B(B_sel1) = B_interp1(B_sel1);
    
    % interpolate in the second direction
    R_interp2 = (circshift(R, [1, 0]) + circshift(R, [-1, 0]))/2;
    B_interp2 = (circshift(B, [1, 0]) + circshift(B, [-1, 0]))/2;
    
    % get meaningful pixels
    R_sel2 = zeros(height, width);
    R_sel2(2:2:height, :) = R_interp2(2:2:height, :);
    R_sel2 = logical(R_sel2);
    
    B_sel2 = zeros(height, width);
    B_sel2(1:2:height, :) = B_interp2(1:2:height, :);
    B_sel2 = logical(B_sel2);
    
    % add these to full array
    R(R_sel2) = R_interp2(R_sel2);
    B(B_sel2) = B_interp2(B_sel2);
    
    % green is actually not that hard either but it's different
    % get meaningful pixels
    G_sel_interp = ~G_sel;
    % interpolate in the specified direction
    G_interp = (circshift(G, [0, 1]) + circshift(G, [0, -1]))/2;
    
    % merge
    G(G_sel_interp) = G_interp(G_sel_interp);
    
elseif (dir == 1)
    
    % red and blue are easy
    % interpolate in the first direction
    R_interp1 = (circshift(R, [1, 0]) + circshift(R, [-1, 0]))/2;
    B_interp1 = (circshift(B, [1, 0]) + circshift(B, [-1, 0]))/2;
    
    % get meaningful pixels
    R_sel1 = zeros(height, width);
    R_sel1(2:2:height, 1:2:width) = R_interp1(2:2:height, 1:2:width);
    R_sel1 = logical(R_sel1);
    
    B_sel1 = zeros(height, width);
    B_sel1(1:2:height, 2:2:width) = B_interp1(1:2:height, 2:2:width);
    B_sel1 = logical(B_sel1);
    
    % add these to the regular array
    R(R_sel1) = R_interp1(R_sel1);
    B(B_sel1) = B_interp1(B_sel1);
    
    % interpolate in the second direction
    R_interp2 = (circshift(R, [0, 1]) + circshift(R, [0, -1]))/2;
    B_interp2 = (circshift(B, [0, 1]) + circshift(B, [0, -1]))/2;
    
    % get meaningful pixels
    R_sel2 = zeros(height, width);
    R_sel2(:, 2:2:width) = R_interp2(:, 2:2:width);
    R_sel2 = logical(R_sel2);
    
    B_sel2 = zeros(height, width);
    B_sel2(:, 1:2:width) = B_interp2(:, 1:2:width);
    B_sel2 = logical(B_sel2);
    
    % add these to full array
    R(R_sel2) = R_interp2(R_sel2);
    B(B_sel2) = B_interp2(B_sel2);
    
    % green is actually not that hard either but it's different
    % get meaningful pixels
    G_sel_interp = ~G_sel;
    % interpolate in the specified direction
    G_interp = (circshift(G, [1, 0]) + circshift(G, [-1, 0]))/2;
    
    % merge
    G(G_sel_interp) = G_interp(G_sel_interp);
    
end

img = zeros(height, width, 3);
img(:, :, 1) = R;
img(:, :, 2) = G;
img(:, :, 3) = B;