% CALLED BY:
%       convertSupportingFiles.m
function filename_mat = xls2mat(filename_xls)

    [num, txt, raw] = xlsread(filename_xls); %#ok
    [~, filename_mat, extension] = fileparts(filename_xls);
    filename_mat = [filename_mat '_' extension(2:end) '.mat'];
    save(filename_mat,'num','txt','raw');

end