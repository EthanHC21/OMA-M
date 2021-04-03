function out = intfillOMA(img, dir)
% does not implement selection or average

[m, n] = size(img);
out = zeros(m, n);

if (dir == 0) % sum in x direction
    
    for i = 1:m
        out(i, :) = sum(img(i, :));
    end
    
elseif (dir == 1) % sum in y direction
    
    for j = 1:n
        out(:, j) = sum(img(:, j));
    end
    
else
    disp('Invalid direction.')
end