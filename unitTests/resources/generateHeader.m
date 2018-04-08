%% generateHeader: Generate header information for HTML
%
% generateHeader returns a constant header cell array.
%
% H = generateHeader() gives a cell array of character vectors in H. H will
% be the standard template for the html header, and includes everything up
% to and including the opening body tag.
%
%%% Remarks
%
% Use this function so that html headers are standardized.
%
% The header does not include the closing body tag, or html tag.
%
%%% Exceptions
%
% This function never throws any exception

function header = generateHeader()
    header = {'<!DOCTYPE html>', '<html lang="en">', '<head>', ...
        '<meta charset="utf-8">', ...
        '<meta name="viewport" content="width=device-width, initial-scale=1">', ...
        '<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/css/bootstrap.min.css">', ...
        '<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>', ...
        '<script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.12.9/umd/popper.min.js"></script>', ...
        '<script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/js/bootstrap.min.js"></script>', ...
        '<script defer src="https://use.fontawesome.com/releases/v5.0.9/js/all.js"></script>', ...
        '<style>', ...
        '.fas.fa-check {', ...
        '    color: forestgreen;', ...
        '}', ...
        '.fas.fa-times {', ...
        '    color: darkred;', ...
        '}', ...
        '</style>', ...
        '</head>', ...
        '<body>'}; 
end