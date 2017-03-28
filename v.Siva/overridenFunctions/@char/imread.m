%% imread Overload function for imread
% 
%   img = imread(filename_img)
%
%   Input:
%       filename_img (char)
%           - name of image file (*.png, *.jpg, etc.)
%
%   Output:
%       img (uint8)
%           - 3D image array
%
%   Description:
%       The imread optimization reads the 3D image array from a pre-saved 
%       .mat file of the data.
function [varargout] = imread(filename_img)

    [filename_mat,extension] = strtok(filename_img,'.');
    filename_mat = [filename_mat '_' extension(2:end) '.mat'];
    
    load(filename_mat);

    varargout{1} = img;

end