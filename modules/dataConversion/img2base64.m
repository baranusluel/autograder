%% img2base64: Convert an image to a Base 64 string
%
% img2base64 will convert an image to a base64 string with uri tags as
% well.
%
% B = img2base64(I) will convert I to base64 string B using BMP
% compression formats. The string B will include the |data| and |base64|
% attributes, which means it can be injected directly inside of HTML.
%
%%% Remarks
%
% This is used extensively wherever we need to show an image, since
% including an image as an attachment is usually frowned upon.
%
%%% Exceptions
%
% This will never throw an exception
%
%%% Unit Tests
%
%   I = imread(...); % valid image
%   B = img2base64(I);
%
%   B -> 'data:image/bmp;base64,STRING...';
function base64 = img2base64(img)
    persistent encoder;
    if isempty(encoder)
        encoder = org.apache.commons.codec.binary.Base64;
    end
    % Base header for bmp
    HEADER = uint8([66;77;118;5;0;0;0;0;0;0;54;0;0;0;40;0;0;0;21;0;0;0;21;0;0;
        0;1;0;24;0;0;0;0;0;64;5;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0]);

    img = permute(img, [2 1 3]);
    img = img(:, :, end:-1:1);
    img = img(:, end:-1:1, :);

    [w, h, ~] = size(img);
    % Since it's transposed, width is actually rows!
    base64 = HEADER;
    % The width
    base64(19:22) = typecast(uint32(w), 'uint8');
    % The height
    base64(23:26) = typecast(uint32(h), 'uint8');

    img = reshape(permute(img, [3 1 2]), [w * 3, h]);

    % Pad image
    % amount of padding needed: rem(width / 32) = # bits
    img = img(:);
    padding = rem(3 * w * 24, 32) / 8;
    % if 0, then no padding necessary
    % if 1, 2, or 3, then pad with 1, 2, or 3 bytes.
    tmp = zeros((w*h*3) + h*padding, 1, 'uint8');
    % new row size = orig#bytes + padding#bytes
    newWidth = (w * 3) + padding;
    % for each column, fill in all the rows
    for c = 1:(w*3)
        tmp(c:newWidth:end) = img(c:(w*3):end);
    end
    img = tmp;
    base64(35:38) = typecast(uint32(numel(img)), 'uint8'); % size of actual pixel data
    base64 = [base64; img];
    base64(3:6) = typecast(uint32(length(base64) + 4), 'uint8'); % file size

    base64 = ['data:image/bmp;base64,', char(encoder.encode(base64)')];
end