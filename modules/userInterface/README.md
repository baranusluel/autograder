# User Interface

This module will be responsible for interacting with the user. Things like printing data to the screen and getting user input will be handled here, but the _logic_ will not.

## Functions

This module will have the following functions:

- `[void] = refresh();`

Refresh the user interface with any new data.

- `[void] = incrementProgress(double precentage);`

Increment the progress bar by the given percentage (1 = 100%).

- `[void] = updateStep(string stepName);`

Change the name of the step we are on (parsing, grading, converting, etc.)

- `[void] = updateStudent(Student student);`

Change the information for the student we are grading (Name, ID, etc.)

- `[string studentPath, string solut ionPath] = getInputs(*optional* bool failed=false);`

Get the paths for the student submissions and the solutions. If `failed` is given and true, `getInputs` will notify the user that it did receive inputs, _but_, those inputs were invalid. 
