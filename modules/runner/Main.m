%% Main: Run the autograder
%
% Main runs the autograder completely, cleaning up after itself and
% generally ensuring nothing is changed in the host environment

% Implementation notes:
% Start the parpool if isempty(gcp) parpool;
% Create and assign the SENTINEL file of File.m
% factory default path: origPath = path(); restoredefaultpath();
% path(origPath, '');
% After running, close the parallel pool (delete(gcp('nocreate'));
% After running, delete the sentinel file (fclose('all'),
% delete(File.SENTINEL);)