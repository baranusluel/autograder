MINOS VERSION 2

Files:
- copy_files.m
- delete_files.m
- Grader.m
- MINOS.m
- Parser.m
- RubricParser.m
- writeGradeSheet.m

Description:
MINOS is an automatic grading system used to grade the CS 1371 homeworks. 

Setup:
- Download the T-Square assignment and unzip it.
- Copy the various MINOS files into the T-Square directory. It should be in the same directory that contains each of the student directories.
- Copy the rubric file into the T-Square directory.
- Copy a folder named "Solutions" that contains the solutions files into the T-Square directory.
- Run MINOS in matlab by calling: MINOS(rubric_filename), where rubric_filename is a string that is the path to the rubric file. If the rubric file is the same directory as the MINOS.m file, the rubric_filename can just be the filename of the rubric.

Running MINOS Advanced:
- MINOS has three optional arguments after the filename that dictates its behavior. These parameters are parse, copy, false:
	- 1. parse (boolean) - default: false - Determines whether the Parser is run on the student files. The purpose of the parser is to add some code into student files that will deal stop any infinite while loops. 
		- Call: MINOS(rubric_filename, parse);
	- 2. copy (boolean) - default: false - Copys all the files from a directory named "Copy Files" into the solutions and student directories. The "Copy Files" directory should be on the same level as the MINOS.m file and the "Solutions" directory.
		- Call: MINOS(rubric_filename, parse, copy);
	- 3. delete (boolean) - default: false - Will delete any files from the submissions directory so that the Homework can be easily uploaded to T-Square.
		- Call: MINOS(rubric_filename, parse, copy, delete);

Writing a Rubric
A template of the rubric has been included in rubric_template.txt. The basic idea of a rubric is to include the various test cases each problem will be run with using, and the various weights for problem and rubric.

Preconditions
- File Exists
	- Checks to see that the file exists (Always Used)
- Recursive
	- Checks to see if the File is Recursive (Needs to be added)

Grading Output Files
To grade output files, after the test case, add the "Output Files:" tag under the test case (with a line between the test case and header), and list out the files that should be graded. (Note: Avoid dlm files that use delimiters other than '!').
Example:

Output Files:
- file1
- file2

Adding variables
The grader will automatically derive variables to grade based on the last line of a test case. If you would like to manually add variables, then a line under the test case, add the "Variables:" tag. Then, just place the variable name, and the type in the format "name: type". The Variables tag is useful for when you run scripts. With scripts, since the variables is not specified in the Test Case, you can use the Variables tag to add the variables.

Example:

Variables:
- var1: default
- var2: cell

Currently, the only available type is cell. Use it to test cell arrays that may have numerical values susceptible to floating point error.

Grading Plots
To grade a plot, add the "Special Tests:" header and then give the tag "- Grade Plot".

Example:

Special Tests:
- Grade Plot

Grade Plot is the only special test that currently exists.