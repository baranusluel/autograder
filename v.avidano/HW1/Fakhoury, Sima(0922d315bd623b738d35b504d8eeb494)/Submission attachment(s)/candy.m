function [eaten, wasted] = candy (pieces, kids)
eaten1 = pieces./kids
eaten = floor(eaten1)
wasted = pieces - (eaten.*kids)
end
