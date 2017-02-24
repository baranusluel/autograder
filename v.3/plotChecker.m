function [getCredit] = plotChecker(img1, img2, tol)
    img1 = uint8(mean(imread(img1),3));
    img2 = unit8(mean(imread(img2)));
    hd = HausdorffDist(img1, img2, 0);
    getCredit = hd <= tol;
end