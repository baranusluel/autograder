# Unit Tests

This section serves as a "mirror" of the _modules_ section - it has the same folder structure. However, this folder houses all the automated _Unit Tests_ for the code in the _modules_ section.

## Setup

Each folder has a set of functions, each of which completely tests it's corresponding function. For convenience, each function is named as the following:

```matlab

functionNameToTest_Test

```

Optionally, each function can generate HTML feedback that visualizes what fails

Additionally, each module will have a function that tests all functions within its module. Optionally, it can generate HTML feedback that visualizes what fails

Finally, this folder has one function which tests all modules.

## Specification

Each function will test all aspects of the given class/function. Its signature will look like this:

```matlab
function [results, html] functionNameToTest_Test(opts, ...);
```

### `results`

`results` will be a structure array with the following fields:

- `testName`: The name of the test run, as a character vector
- `status`: Whether or not it passed, as a logical
- `message`: A help message, if any

### `html`

`html` will be the feedback. If this argument is requested, no output is written. This output html doesn't include the "boilerplate" - it's a single `<div>` instead.

### `opts`

`opts` is a structure array or set of name-value pairs that specify options. Options can be as follows:

- `feedbackPath`: The directory to write the HTML feedback to - the html will always be called `functionNameToTest_results.html`. If this is empty, no feedback is written
- `showFeedback`: True if you'd like to see the feedback in a MATLAB web browser. If this is false, and `feedbackPath` is empty, no feedback is generated