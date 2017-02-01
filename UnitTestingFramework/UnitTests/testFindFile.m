%{
    This main function definition must be the same for all unit tests.
    The name of the main function must be of the form "test<Unit>" where <unit>
    is replaced witht the name of the unit (this should be the same as the name
    of the directory where this unit resides).
%}
function tests = testFindFile

%{
functiontests creates a TestSuite object of all of the unit tests in this file
localfunctions is a shortcut function that creates a cell array of function
handles to all of the local functions in this file

TL;DR smoosh all of the unit tests in this file into a runnable suite of tests
%}
tests = functiontests(localfunctions);
end

%{
All unit test functions must begin with the word "test". After that, the name of
the function should describe what the test is testing. The single input to all
test case functions should be "testCase".

A test case is composed of 3 main parts, defining the expected behavior,
calculating the actual behavior and making an assertion comparing the two
values. There are many different assertions you can make, but this one simply
asserts that the actual value must be equal to the expected value.

** NOTE ** The first input to the assert functions must be the same as the input
to the function. This TestCase object gets passed around between the assertions
by the TestSuite to run the entire test.
%}
function testFileExistsInTopLevelNoExt(testCase)
actual = findFile('walnut');
expected = 'walnut';
assertEqual(testCase, actual, expected);
end

function testFileExistsInTopLevelSingleLettExt(testCase)
actual = findFile('walnu.t');
expected = 'walnu.t';
assertEqual(testCase, actual, expected);
end

function testFileExistsInTopLevelMultiLettExt(testCase)
actual = findFile('pecans.txt');
expected = 'pecans.txt';
assertEqual(testCase, actual, expected);
end

function testFileExistsInSubfolder(testCase)
actual = findFile('peanuts.txt');
expected = fullfile('nutHouse', 'peanuts.txt');
%{
Note that for the expected value here, we cannot simply say
'nutHouse\peanuts.txt' because that would not be OS independent. One thing to
keep in mind when writing unit tests is they should be fully
compartmentalized; the test itself should not rely on any external
assumptions.
%}
assertEqual(testCase, actual, expected);
end

function testFileMatchMostRecentEdit(testCase)
actual = findFile('cashew');
expected = fullfile('nuts', 'moNuts', 'yoNuts', 'cashew');
assertEqual(testCase, actual, expected);
end

function testFileDoesNotExist(testCase)
%{
For this test case, we expect the function to throw an error saying that the
file was not found. To test that we can use the assertError function. The
expected value is any exception which we identify with ?MException. To assert a
particular type of error you will have to look up that error's ID.
Also, note that the actual result here is a function handle, not a value. This
is because if we tried to specify a value beforehand, it would error out before
we ever got to the assertion. However, if the error occurs in the assertion, it
will handle recovering from the error and checking the assertion.
%}
assertError(testCase, @() findFile('doesNotExist'), ?MException);
end

%{
In addition to testing function, you can also specify functions that run before
and after tests to set up and tear down a testing environment. These functions
could do things like change the current directory, open a figure, delete a file,
etc. These functions must adhere to the following naming convention exactly:
setup: Runs before EACH test case
setupOnce: Runs before ALL test cases
teardown: Runs after EACH test case
teardownOnce: Runs after ALL test cases have been completed

In the case of this unit test, we do not need to have a setup or teardown
function, but we do need a setupOnce and teardownOnce function to navigate to
the testing folder and make sure the function is on the path. Here's how that
should look:
%}
function setupOnce(testCase)
%{
Note that all paths are relitave to the location of this test file. You
should never use absolute paths because that breaks the machine-independent
paradigm of unit tests
%}

% get all folders on the MATLAB path
funcPath = fullfile(filesep, '..', 'FindFile');
warning off; %#ok<WNOFF>
pathCA = regexp(path, pathsep, 'split');
warning on; %#ok<WNON>

% determine if the one we want is there
if ispc
    onPath = any(strcmpi(funcPath, pathCA));
else
    onPath = any(strcmp(funcPath, pathCA));
end

% add the folder if it's not there
if ~onPath
    addpath(fullfile(pwd, funcPath));
end

% add the data to the TestData property
testCase.TestData.funcPath = funcPath;
testCase.TestData.onPath = onPath;

% go to the test folder
testCase.TestData.origPath = cd('TestFindFile');

%{
The TestData property of the testCase object is pretty cool. It allows any data
you choose to be passed from setup to test cases to teardown. In this case, we
are creating the origPath field to save the original current directory. We then
use this value to restore MATLAB to its original state after the test cases are
run. Unit tests should never leave "traces" of themselves. We also check if the
folder containing the function we are testing is on the path. If it is not, we
add it. In the teardown function, we only remove the folder from the path if it
wasn't there to bein with (thus returning MATLAB to it's pre-unit-test state).
%}
end

function teardownOnce(testCase)
% remove the test folder
cd(testCase.TestData.origPath);

% remove the folder containing the function only if it wasn't there to begin
% with
if (~testCase.TestData.onPath)
    rmpath(fullfile(pwd, testCase.TestData.funcPath));
end
end
