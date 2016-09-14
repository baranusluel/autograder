function delete_files(varargin)

s = warning('off', 'MATLAB:dispatcher:nameConflict');

deleteAll = false;

if isempty(varargin)
    R = input('Delete all submission files (Y/[N])? ', 's');
    
    if strcmpi(R, 'Y')
        deleteAll = true;
    else
        return;
    end
end

students = dir('*(*)');
disp('Start Delete Sequence')
for i = 1:length(students)
    cd([students(i).name filesep 'Submission attachment(s)']);
    
    if deleteAll
        delete('*.*');
    else
        for ndx = 1:nargin
            delete(varargin{ndx});
        end
    end
    
    cd('..');
    cd('..');
end
disp('Deleting Complete');

warning(s)

end
