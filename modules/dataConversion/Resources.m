%% Resources: Shared Resources for the Student class
%
% Resources represents the problems and their resources; it acts as a shared
% repository for the Problems and the supporting files.
%
%%% Fields
%
% * Problems: The Problem array for this grading session
%
% * supportingFiles: A structure array that represents all the supporting files.
%
%%% Remarks
%
% This class is used exclusively by the Student class to keep track of Problems.
% It also frees up the Student from having to have an instance property for the
% Problems array.

classdef Resources < matlab.mixin.SetGet
    properties (Access=public,SetObservable)
        Problems;
    end
    properties (Access=public)
        supportingFiles struct;
    end
    methods
        function this = Resources
            this.addlistener('Problems', 'PostSet', @this.tester);
        end
        function tester(this, ~, ~)
            this.supportingFiles = struct('name', {this.Problems.name}, ...
                'files', []);
            problems = this.Problems;
            encoder = org.apache.commons.codec.binary.Base64;
            for p = 1:numel(problems)
                rec = this.supportingFiles(p);
                % for each problem, get the supporting files. rec.resources
                % = struct(1xn), with fields 'name' and 'dataURI'
                % just use the first TestCase
                sups = [problems(p).testCases(1).supportingFiles(:)', ...
                    problems(p).testCases(1).loadFiles(:)'];
                rec.files = struct('name', sups, ...
                    'dataURI', '');
                [~, inds] = sort(upper(sups));
                sups = sups(inds);
                for s = 1:numel(sups)
                    % switch on the type
                    file = sups{s};
                    [~, name, ext] = fileparts(file);
                    rec.files(s).name = [name ext];
                    % fread file bytes, encode in base64, set as binary
                    fid = fopen(file, 'r');
                    bytes = fread(fid, inf, 'uint8');
                    fclose(fid);
                    str = char(encoder.encode(bytes)');
                    rec.files(s).dataURI = ...
                        ['data:application/octet-stream;base64,', str];
                end

                this.supportingFiles(p) = rec;
            end
        end
    end
end