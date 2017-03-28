%% imwrite Overload function for imwrite
%
%   imwrite(filename_img,varargin)
%
%	Input:
%       filename_img (char)
%           - name of image file (*.png, *.jpg, etc.)
%
%   Output:
%       filename_mat (char)
%           - name of mat file (.mat)
%
%   Output File:
%       mat file containing variable: img
%
%   Description:
%       The imwrite overload function simulates image writing using a .mat
%       file to store the 3D uint8 image array.
function filename_mat = imwrite(img, filename_img,varargin)

    if nargin == 2

        % get .mat filename
        [filename_img,extension] = strtok(filename_img,'.');
        extension(1) = [];

    elseif nargin == 3

        % get .mat filename
        [filename_img, ~] = strtok(filename_img,'.');
        
        % get file extension
        extension = lower(varargin{1});

        if false == isFileExtensionValid(extension)

            % Throw invalid format error
            error('Invalid file format input "%s"  to imwrite',extension);

        end

    elseif nargin > 3
        
        % call builtin imwrite
        currentDirectory = cd;
        img = imwrite_builtin(currentDirectory,img,filename_img,varargin);

    end

    % get output .mat file name
    filename_mat = [filename_img '_' extension '.mat'];

    save(filename_mat,'img');

end

%% imwrite_builtin Helper function for imwrite overload
%
%   img = imwrite_builtin(returnDirectory,img,filename_img,varargin)
%
%   Inputs:
%       returnDirectory (char)
%           - student submission directory to return to
%       img (uint8)
%           - 3D uint8 image array
%       filename_img (char)
%           - image file name
%       varargin (cell)
%           - inputs to student's function call of imwrite
%
%   Output:
%       img (uint8)
%           - 3D uint8 image array
%
%   Description:
%       The imwrite_builtin function is called when the student uses an
%       "unusual" format to call the builtin imwrite function. We go to the
%       system's default temporary directory and write the img file. Then
%       we read the file, delete it, and return the img data.
function img = imwrite_builtin(returnDirectory,img,filename_img,varargin)

    cd(tempdir)

    try

        if ischar(varargin{1}) && isFileExtensionValid(lower(varargin{1}))

            extension = lower(varargin{1});

        else

            [~,extension] = strtok(filename_img,'.');
            extension(1) = [];

        end

        filename = ['temp.' extension];

        builtin('imwrite', img, filename, varargin{:});
        img = imread(filename);
        delete(filename);

    catch ME
        % do nothing because we still need to go back to the 
        % student submission attachments directory
    end

    % go back to the student submission directory
    cd(returnDirectory)

    if ~isempty(ME)
        error(ME.message);
    end

end

%% isFileExtensionValid Check if input image file extension is valid
%
%   isValid = isFileExtensionValid(extension)
%
%   Input:
%       extension (char)
%           - image file extension
%
%   Output:
%       isValid (logical)
%           - logical describing if file extension is valid
%
%   Description:
%       The isFileExtensionValid function returns true or false depending
%       on whether or not the file extension given is an accepted format.
function isValid = isFileExtensionValid(extension)

    % get possible file extensions
    possible_extensions = imformats;
    possible_extensions = [possible_extensions.ext];

    % check if input file extension is valid
    isValid = any(strcmp(possible_extensions,extension));

end