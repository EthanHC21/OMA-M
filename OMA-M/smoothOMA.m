function out = smoothOMA(img, x, y)
% We apply a convolution to the image. I'm totally guessing as to what the
% kernel is.

% We assume that the kernel is just a simple, normalized average with
% neighbors, the length of which in each direction is specified by x and y.
% We will also assume that it is symmetric about the center pixel.

[h, w, c] = size(img);

% x convolution
if (x > 0)
    
    % preallocate kernel
    kernelX = zeros(2*x + 1);
    % find center
    centerX = x + 1;
    % make kernel as normalized blur
    kernelX(centerX, :) = 1/(2*x+1);
    
    % perform convolution
    if (c == 1)
        
        convX = conv2(img, kernelX, 'same');
        
    elseif (c == 3)
        
        convX_R = conv2(img(:, :, 1), kernelX, 'same');
        convX_G = conv2(img(:, :, 2), kernelX, 'same');
        convX_B = conv2(img(:, :, 3), kernelX, 'same');
        convX = zeros(h, w, 3);
        convX(:, :, 1) = convX_R;
        convX(:, :, 2) = convX_G;
        convX(:, :, 3) = convX_B;
        
    else
        disp('Error: Not an image')
    end
    
end

% y convolution
if (y > 0)
    
    % preallocate kernel
    kernelY = zeros(2*y + 1);
    % find center
    centerY = y + 1;
    % make kernel as normalized blur
    kernelY(:, centerY) = 1/(2*y+1);
    
    % perform convolution
    if (c == 1)
        
        convY = conv2(img, kernelY, 'same');
        
    elseif (c == 3)
        
        convY_R = conv2(img(:, :, 1), kernelY, 'same');
        convY_G = conv2(img(:, :, 2), kernelY, 'same');
        convY_B = conv2(img(:, :, 3), kernelY, 'same');
        convY = zeros(h, w, 3);
        convY(:, :, 1) = convY_R;
        convY(:, :, 2) = convY_G;
        convY(:, :, 3) = convY_B;
        
    else
        disp('Error: Not an image')
    end
    
end

if (x > 0 && y > 0)
    
    % if we convoluted both, take the average
    out = (convX + convY)/2;
    
else
    
    % if we only did one, just do that one
    if (x > 0) out = convX; end
    if (y > 0) out = convY; end
    
end