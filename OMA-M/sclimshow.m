function null = sclimshow(imgArr)
dubImgArr = double(imgArr);
dubImgArr = dubImgArr - min(dubImgArr(:));
imshow(uint16(dubImgArr * (2^16-1)/max(dubImgArr(:))))