# Unit Tests

This section serves as a "mirror" of the _modules_ section - it has the same folder structure. However, this folder houses all the automated _Unit Tests_ for the code in the _modules_ section.

## Structure

The folder structure is important here. The top level directory is considered to be `unitTests`. Under that, you'll have your module name (i.e., `grader`). Each module is actually a folder of folders, where each folder represents a specific unit. Look at the visualization below:

- `unitTests` (folder)
  - `yourModule` (folder)
    - `yourUnit` (folder)
      - `YourTest` (folder - name is the name of your test)
        - `test.m` (main test file)
        - `yourSupportingFile.txt` (optional environment file)
        - `yourHelper.m` (optional helper function that's secific to this test case)
      - `helper.m` (optional helper function that is available in **all** test cases)

A couple of requirements:

- The main testing function **must** be called `test.m`. If no `test.m` files are found, no unit tests are run
- The `yourTest` folder name should be an _extremely_ brief description of what your test is testing.
- If your unit is actually a `class`, then the name of the test **must** look like this: `MethodName_TestName`. As an example, If I wanted to test an `InvalidPath` case for the `generateFeedback` method of the `Student`, my name for `yourTest` would be `GenerateFeedback_InvalidPath`. `Constructors` don't need this prefix.
- Note that unit names follow the capitalization of the unit. So classes should be Capitalized, while function should be lowercase.
- For the test name, however, you always use `PascalCase` - `MyTestName`

When we want to test `yourUnit`, there's a separate function (you don't need to worry about that function) that will run all your written test cases. Then, it generates some nice feedback on what passed and what didn't.

So, now that you know where to put your unit tests, let's talk about writing one

## Writing A Unit Test

Unit Tests are really just functions that test a specific case and reports the results. The function signature **always** looks like this:

`function [passed, message] = test()`

Additionally, above it should be a spec that tells the reader _what_ this is testing. More often than not, you can just copy the Unit Test specification from
the original unit.

The `passed` variable is a logical - true if your test passed, false if it failed. The `message` is a custom message you'd like to use - for example, it could be `message = 'Correct output'` or `message = 'Exception thrown'`.

Your Unit Test function is responsible for setting up and running the test case, as well as cleaning up (closing file streams, etc.). You are _not_ responsible for replacing any modified files with their originals - the Unit Testing Framework will handle that for you. In other words, there is no need to worry about your test's _environment_. This also includes figure windows.

For each unit test you have, you must write a function to test that.

## Unit Test Template

For your convenience, below is a Unit Test Template.

```matlab

%% NameOfTest
%
% Unit Test Description (setup, what constitutes correct)
% JUST LIKE the original specification for unit tests

function [passed, message] = test()
  % set up your arguments
  % test your function
  % fclose your files and close any open plot windows
end

```