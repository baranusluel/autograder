function st = json2struct(fname)
%JSON2STRUCT Converts a .json file into a structure array
    fh = fopen(fname);
    jsonDat = fscanf(fh,'%s\n');
    fclose(fh);
    st = jsondecode(jsonDat);
end