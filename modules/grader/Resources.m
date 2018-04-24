%% Resources: Shared Resources for the Student class

classdef Resources < matlab.mixin.SetGet
    properties (Access=public,SetObservable)
        Problems;
    end
    properties (Access=public)
        resources struct;
    end
    methods
        function this = Resources
            this.addlistener('Problems', 'PostSet', @this.tester);
        end
        function tester(this, ~, ~)
            this.resources = struct('name', {this.Problems.name}, ...
                'resources', []);
            problems = this.Problems;
            encoder = org.apache.commons.codec.binary.Base64;
            for p = 1:numel(problems)
                rec = this.resources(p);
                % for each problem, get the supporting files. rec.resources
                % = struct(1xn), with fields 'name' and 'dataURI'
                % just use the first TestCase
                sups = [problems(p).testCases(1).supportingFiles, ...
                    problems(p).testCases(1).loadFiles];
                rec.resources = struct('name', sups, ...
                    'dataURI', '');
                for s = 1:numel(sups)
                    % switch on the type
                    file = sups{s};
                    [~, name, ext] = fileparts(file);
                    rec.resources(s).name = [name ext];
                    % fread file bytes, encode in base64, set as binary
                    fid = fopen(file, 'r');
                    bytes = fread(fid, inf, 'uint8');
                    fclose(fid);
                    str = char(encoder.encode(bytes)');
                    rec.resources(s).dataURI = ...
                        ['data:application/octet-stream;base64,', str];                            
                end
                
                this.resources(p) = rec;
            end
        end
    end
end