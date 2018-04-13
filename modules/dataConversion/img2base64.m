%% img2base64: Convert an image to a Base 64 string
%
% img2base64 will convert an image to a base64 string with uri tags as
% well.
%
% B = img2base64(I) will convert I to base64 string B using PNG
% compression formats. The string B will include the |data| and |base64|
% attributes, which means it can be injected directly inside of HTML.
%
% B = img2base64(I, F) will use the format in F to encode I as a base 64
% string B.
%
%%% Remarks
%
% This is used extensively wherever we need to show an image, since
% including an image as an attachment is usually frowned upon.
%
%%% Exceptions
%
% Any exceptions will be thrown as an
% AUTOGRADER:img2base64:conversionException, with the reason listed as a
% cause.
%
%%% Unit Tests
%
%   I = imread(...); % valid image
%   B = img2base64(I);
%
%   B -> 'data:image/png;base64,STRING...';
%
%   I = imread(...); % valid iamge
%   B = img2base64(I, 'bmp');
%
%   B -> 'data:image/bmp;base64,STRING...';
