# Data Conversion

This module is responsible for converting data into necessary forms. This does _not_ actually change the data itself; only the format it is in.

## Classes

This module has one class:

- `Resources`

Functions as a static resource to be used in grading and constructing feedback

## Functions

This module has the following functions:

- `[string unzipPath] = unzipArchive(string path, *optional* bool isTemp=true, *optional* bool deleteOriginal=false);`

Unzips the ZIP archive defined in `path`. If `isTemp` is `true`, then `unzipArchive` will unzip the archive into a temporary folder; otherwise, it will unzip into the same folder the ZIP archive was found. If `deleteOriginal` is `true`, then `unzipArchive` will delete the original ZIP archive after unzipping. Regardless, the path of the unzipped archive (including the zipped folder name) will be returned.

- `[string convertedPath] = canvas2autograder(string zipPath, string csvPath);`

Takes in a path to the ZIP archive downloaded from Canvas of all the student's submissions, and a CSV path from Canvas. This will reformat this data to be fed into the main autograder. `convertedPath` will be a path to the resulting folder (including that folder name) will be returned. It operates within the current directory (`pwd`).

- `autograder2canvas(Student[] students, string gradebook, string hwName);`

Takes in an array of `Student`s, a path to the `gradebook` csv, and a `Homework Name`. It then will generate a new gradebook that is fit to upload to Canvas.

- `[string convertedPath] = autograder2website(string studentPath, *optional* string outpath=pwd);`

This will generate a folder structure ready to be uploaded to the CS 1371 Website. It takes in a path to all the Student folders. Optionally, you can specify a place for this folder - otherwise, it just uses the current directory. This looks for a folder called.

- `[Problem[] problems] = generateSolutions(bool isResub, UIProgressDlg progress);`

This will generate the solution values. These solutions are held in a `Problem` array, which is detailed below.

- `[Student[] students] = generateStudents(string path, UIProgressDlg progress);`

This will generate the student array from their folders.

- `[void] = exportCheaters(Student[] students, cell[] cheaters, cell[] scores, cell[] problems, string path, UIProgressDlg progress);`

This will use the student, cheater, score, and problem names to construct meaningful cheater archives.

- `[string base64] = img2base64(uint8[3][][] img);`

This uses in-memory processes to create a base64 version of the given image

- `[double[] rank1, double[] rank2] = jaccardIndex(string txt1, string txt2, double perm);`

This uses the texts given to find the relative similarity between them