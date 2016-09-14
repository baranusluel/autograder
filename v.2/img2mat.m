%% img2mat Converts an image file to a .mat file
%
%   filename_mat = img2mat(filename_img)
%
%   Input:
%       filename_img (char)
%           - the name of the image file
%
%   Output:
%       filename_mat (char)
%           - the name of the .mat file
%
%   Description:
%       Converts an image file to a .mat file
function filename_mat = img2mat(filename_img)

    img = imread(filename_img); %#ok
    [~, filename_mat, extension] = fileparts(filename_img);
    filename_mat = [filename_mat '_' extension(2:end) '.mat'];
    save(filename_mat, 'img');

end