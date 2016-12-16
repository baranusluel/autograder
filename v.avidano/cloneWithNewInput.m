function cloneWithNewInput(fn)
fid = fopen([fn '.m'], 'r');
fidnew = fopen([fn '_clone.m'],'w');

functionFlag = false;
lin = fgetl(fid);
while ischar(lin)
    if ~functionFlag && ~isempty(lin) && ...
            strcmp(strtok(lin),'function')
        functionFlag = true;
        if any(lin==')') && isempty(strfind(lin,'varargin'))
            loc = find(lin==')');
            linSeg1 = lin(1:loc-1);
            linSeg2 = lin(loc:end);
            lin = [linSeg1 ',varargin' linSeg2];
        end
        fprintf(fidnew,'%s\n',lin);
        newlin = 'varargin = varargin(1:end-1)';
        lin = fgetl(fid);
        if ~strcmp(strtok(lin,';'),newlin);
            fprintf(fidnew,'%s;',newlin);
        end
    end
    
    fprintf(fidnew,'%s\n',lin);
    lin = fgetl(fid);
end

fclose(fid);
fclose(fidnew);
movefile([fn '_clone.m'], [fn '.m']);
end