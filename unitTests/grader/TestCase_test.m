%% TestCase_test: Test the TestCase class module
%
% TestCase_test will run all the tests contained for this class
%
% [R, H] = TestCase_test(O, ...) will run all the test for this class,
% and will return the results as a structure array. See the documentation
% for more information about the options and outputs for this function.
%
%%% Remarks
%
% This tests all tests for the |TestCase| class.
%
%%% Exceptions
%
% This function is guaranteed to never throw an exception.
%
% See Also: Main

function [results, html] = TestCase_test(varargin)
    outs = parseTestInputs(varargin{:});
    %%% Unit Tests
    %
    % Assume INFO struct that looks like the example given above.
    % 
    %   J = '...' % Valid INFO;
    %   P = '...' % Valid path;
    %   T = TestCase(J, P);
    %
    %   T isa |TestCase|
    %   T.call -> "[out1, out2] = myFun(in1, in2);"
    %   T.initializer -> [];
    %   T.points -> 3;
    %   T.supportingFiles -> ["myFile.txt", "myInputImage.png"];
    %   T.loadFiles -> ["myTestCases.mat"];
    %   T.banned -> ["fopen", "fclose", "fseek", "frewind"];
    %   T.path -> '...' % Valid path
    % 
    % Note that the following would be filled _after_ running the solution. 
    % This is still done in the constructor. For this example, assume the 
    % function created one image file and one text file. For the purposes 
    % of documenting |TestCase|, we will not explore the contents of 
    % those files - that will be covered in |File|.
    %
    %   T.outputs -> struct('out1', 2, 'out2', 'Hello, World!'); 
    %
    % Now suppose the structure in |J| is similiar to the following JSON:
    %
    %   {
    %       "call": "[out1, out2] = myFun(in1, in2);",
    %       "initializer": "in2 = supportFunction__",
    %       "points": 3,
    %       "supportingFiles": [
    %           "myFile.txt",
    %           "myInputImage.png",
    %           "supportFunction__.m"
    %           "myTestCases.mat"
    %       ],
    %       "banned": [
    %           "fopen",
    %           "fclose",
    %           "fseek",
    %           "frewind"
    %       ]
    %   }
    %
    % Note the |initializer| is set. Suppose the following is 
    % found in "supportFunction__.m":
    %
    %   function out = supportFunction__()
    %       out = fopen('myFile.txt', 'r');
    %   end
    %
    % Now we call the function:
    %
    %   T = TestCase(J, P);
    %
    %   T isa |TestCase|
    %   T.call -> "[out1, out2] = myFun(in1, in2);"
    %   T.initializer -> "[in1] = supportFunction__();";
    %   T.points -> 3;
    %   T.supportingFiles -> ["myFile.txt", "myInputImage.png", "supportFunction__.m"];
    %   T.loadFiles -> ["myTestCases.mat"];
    %   T.banned -> ["fopen", "fclose", "fseek", "frewind"];
    %   T.path -> '...' % Valid path
    %
    % The following are filled in after everything is run. 
    % Note that for this case, the in2 is calculated _immediately_
    % before the function is run.
    %
    %   T.outputs -> struct('out1', 1, 'out2', false);
    %   T.files -> File[2];
    %   T.plots -> Plot[1];
    %
    % Assume J structure is empty or has missing fields:
    %   T = TestCase(J, P);
    %
    %   The constructor threw exception 
    %   AUTOGRADER:TESTCASE:CTOR:BADINFO
    %
    % Assume J is valid structure, but the solution code errors.
    %
    % Running the constructor:
    %   T = TestCase(J, P);
    % 
    %   The constructor threw exception
    %   AUTOGRADER:TESTCASE:CTOR:BADSOLUTION        
    setup();
    PASSED = '<span class="fas fa-check"></span>&nbsp;';
    FAILED = '<span class="fas fa-times"></span>&nbsp;';
    
    html = {'<div class="container test-results">', '<h2><code>TestCase</code> Unit Tests</h2>'};
    results = struct();
    info.call = '[out1, out2] = myFun(in1, in2);';
    info.initializer = '';
    info.points = 3;
    info.supportingFiles = {'myFile.txt', 'myInputImage.png', 'myTestCases.mat'};
    info.banned = {'fopen', 'fclose', 'fseek', 'frewind'};
    funPath = './resources/test01/';
    
    html = [html {'<div class="row test-result">', '<div class="col-12">', '<h3>Valid Test Case &amp; Path</h3>'}];
    
    ind = numel(html);
    try
        orig = cd(funPath);
        T = TestCase(info, funPath);
        cd(orig);
        % test T
        html = [html {'<div class="row result">'}];
        results = res;
        results(end).testName = 'ValidTestCase_FunctionCall';
        if strcmp(T.call, info.call)
            % passed
            results(end).status = true;
            html = [html PASSED {'<p>Function Call Passed</p>', '</div>'}];
        else
            html = [html FAILED, ...
                {sprintf('<p>Function Call Failed; expected %s; got %s</p>', ...
                info.call, T.call), '</div>'}];
            results(end).status = false;
        end
        
        html = [html {'<div class="row result">'}];
        results(end+1) = res;
        results(end).testName = 'ValidTestCase_Initializer';
        if isempty(T.initializer)
            % passed
            html = [html PASSED {'<p>Initializer Passed</p>', '</div>'}];
            results(end).status = true;
        else
            % failed
            html = [html FAILED, ...
                {sprintf('<p>Initializer Failed; expected %s; got %s</p>', ...
                info.initializer, T.initializer), '</div>'}];
            results(end).status = false;
        end
        html = [html {'<div class="row result">'}];
        results(end+1) = res;
        results(end).testName = 'ValidTestCase_Points';
        if T.points == 3
            % passed
            html = [html PASSED {'<p>Points Passed</p>', '</div>'}];
            results(end).status = true;
        else
            % failed
            html = [html FAILED, ...
                {sprintf('<p>Points Failed; expected %d; got %d</p>', ...
                3, T.points), '</div>'}];
            results(end).status = false;
        end
        html = [html {'<div class="row result">'}];
        results(end+1) = res;
        results(end).testName = 'ValidTestCase_SupportingFiles';
        if all(cellfun(@strcmp, T.supportingFiles, {'myFile.txt', 'myInputImage.png'}))
            % passed
            html = [html PASSED {'<p>Supporting Files Passed</p>', '</div>'}];
            results(end).status = true;
        else
            % failed
            html = [html FAILED, ...
                {'<p>Supporting Files failed</p>', '</div>'}];
            results(end).status = false;
        end
        html = [html {'<div class="row result">'}];
        results(end+1) = res;
        results(end).testName = 'ValidTestCase_LoadFiles';
        if strcmp(T.loadFiles, 'myTestCases.mat')
            % passed
            html = [html PASSED {'<p>Load Files Passed</p>', '</div>'}];
            results(end).status = true;
        else
            % failed
            html = [html FAILED, ...
                {'<p>Load Files failed</p>', '</div>'}];
            results(end).status = false;
        end
        html = [html {'<div class="row result">'}];
        results(end+1) = res;
        results(end).testName = 'ValidTestCase_Banned';
        if all(cellfun(@strcmp, T.supportingFiles, {'myFile.txt', 'myInputImage.png'}))
            % passed
            html = [html PASSED {'<p>Banned Functions Passed</p>', '</div>'}];
            results(end).status = true;
        else
            % failed
            html = [html FAILED, ...
                {'<p>Banned Files failed</p>', '</div>'}];
            results(end).status = false;
        end
        html = [html {'<div class="row result">'}];
        results(end+1) = res;
        results(end).testName = 'ValidTestCase_Path';
        if strcmp(T.path, funPath)
            % passed
            html = [html PASSED {'<p>Path Passed</p>', '</div>'}];
            results(end).status = true;
        else
            % failed
            html = [html FAILED, ...
                {sprintf('<p>Path Failed; expected "%s"; got "%s"</p>', ...
                funPath, T.path), '</div>'}];
            results(end).status = false;
        end
        % check outputs
        html = [html {'<div class="row result">'}];
        results(end+1) = res;
        results(end).testName = 'ValidTestCase_Outputs';
        if isequal(struct('out1', 2, 'out2', 'Hello, World!'), T.outputs)
            % passed
            html = [html PASSED {'<p>Outputs Passed</p>', '</div>'}];
            results(end).status = true;
        else
            % failed
            html = [html FAILED, ...
                {'<p>Outputs Failed</p>', '</div>'}];
            results(end).status = false;
        end
        % TODO: Add Files
    catch e
        % not supposed to error; bad
    end
    % close test-result
    html = [html {'</div>'}];
    
    
    % close test-results
    html = strjoin([html {'</div>'}], newline);
    cleanup();
    
    % write html feedback, if necessary
    completeHtml = strjoin([generateHeader() {'<div class="container-fluid">', ...
        '<div class="row">', '<div class="col-12">'}, html, ...
        {'</div>', '</div>', '</div>', '</body>', '</html>'}], newline);
    if ~isempty(outs.feedbackPath)
        % write html
        fid = fopen([outs.feedbackPath filesep 'TestCase_results.html'], 'wt');
        fwrite(fid, completeHtml);
        fclose(fid);
    end
    % if out.showFeedback, write temp feedback file and show
    if outs.showFeedback
        fName = [tempname '.html'];
        fid = fopen(fName, 'wt');
        fwrite(fid, completeHtml);
        fclose(fid);
        web(['file:///', fName]);
    end
end

function setup()
    copyfile(['..' filesep 'resources' filesep 'TestCase'], 'resources');
end

function cleanup()
    fclose all;
    try
        rmdir('resources', 's');
    catch
        %ok to catch
    end
end

function r = res()
    r.subject = 'TestCase';
    r.status = false;
    r.testName = '';
end