# Runner

This is a module dedicated to simply running the autograder. It will utilize all other modules to accomplish this.

## Classes

The `Runner` Module has only one class:

- `Logger`: Responsible for logging all activities within the autograder

## Functions

The `Runner` Module has only one function:

- `[void] = Main(*optional* string studentPath, *optional* string solutionPath, *optional* bool isGui);`

Runs the autograder, and controls the "higher-level" logic, such as initiating conversions and starting grading.