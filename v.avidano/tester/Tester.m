%% Testing speed
profile off
profile on

makeBannedFunctionFile()
%% Avidano
function makeBannedFunctionFile(banned)
% Get path to actual banned function
filePath = which(banned);
if strcmp(strtok(filePath,' ('),'built-in')
    filePath = filePath(find(filePath=='(')+1:find(filePath==')')-1);
end
filePath = fileparts(filePath);%remove function name
curPath = pwd;


%Print file
fid = fopen([banned '.m'],'w');
fprintf(fid,'function varargout=%s(varargin)',banned);
fprintf(fid,'\ns=dbstack;');
fprintf(fid,'\nif ~strcmp(strtok(s(1).file,''.''),''%s'')',banned);
fprintf(fid,'\ncurPath = pwd;');
fprintf(fid,'\ncd(''%s'');',filePath);
fprintf(fid,'\nfh=str2func(''%s'');',banned);
fprintf(fid,'\ncd(curPath);');
fprintf(fid,'\nvarargout=fh(varargin);');
fprintf(fid,'\nelse');
fprintf(fid,'\nthrowAsCaller(MException(''%s:bannedFunction'',''Banned function %s used.''));',...
    banned,banned);
fprintf(fid,'\nend');


fclose(fid);

end