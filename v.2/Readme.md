# Autograder v.2

## Workflow
1. Grade student submissions
2. Generate html feedback for each student
3. Zip graded homework folder
4. Upload graded feedback files to T-Square

### Potential steps
* Upload graded feedback files to website
* Generate tsquare feedback files with link to website with student's specific feedback
	* On feedback webpage, students can see feedback and can download relevant files (problems they did not get a 100 on)

## Layout
### Input(s):
1. rubric zip file path
2. bulk_download zip file path
3. destination folder path

###Output(s):
1. upload zip file
	* HTML feedback file for each student

### Steps
#### [1] Get Rubric
1. unzip rubric zip file to destination folder path
2. convert supporting files
3. load rubric.json
4. run solutions

#### [2] Get Gradebook
1. unzip bulk_download file to destination folder path
2. get gradebook template from grades.csv

#### [3] Grade Student Submissions
1. run student submissions
2. grade student submissions
3. generate feedback files

#### [4] Write grades.csv

#### [5] Zip graded homework folder
