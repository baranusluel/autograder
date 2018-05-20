function edgy(filename)
    img = imread(filename);
    avg = uint8((double(img(:,:,1)) + double(img(:,:,2)) + double(img(:,:,3))) / 3);
    gray = cat(3, avg, avg, avg);
    xdiff = diff(gray, 1, 1);
    xdiff = abs(xdiff(:, 1:end-1, :));
    ydiff = diff(gray, 1, 2);
    ydiff = abs(ydiff(1:end-1, :, :));
    xlayer = xdiff(:,:,1);
    ylayer = ydiff(:,:,1);
    xthresh = mean(mean(xlayer)) + std(double(xlayer(:)));
    ythresh = mean(mean(ylayer)) + std(double(ylayer(:)));
    mask = xdiff(:,:,1) >= xthresh | ydiff(:,:,1) >= ythresh;

    % crop out for diff 
    img = img(1:end-1, 1:end-1, :);
%     img(:,:,:) = 0;
    rlayer = img(:,:,1);
    rlayer(mask) = 255;
    glayer = img(:,:,2);
    glayer(mask) = 0;
    blayer = img(:,:,3);
    blayer(mask) = 0;

    newImg = cat(3, rlayer, glayer, blayer);
    imwrite(newImg, ['edgy_', strtok(filename,'.') '_soln.png']);
end