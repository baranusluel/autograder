# Data Conversion

This module is responsible for converting data into necessary forms. This does _not_ actually change the data itself; only the format it is in.

## Functions

This module shall have the following functions:

- `[string unzipPath] = unzipArchive(string path, *optional* bool isTemp=true, *optional* bool deleteOriginal=false);`

Unzips the ZIP archive defined in `path`. If `isTemp` is `true`, then `unzipArchive` will unzip the archive into a temporary folder; otherwise, it will unzip into the same folder the ZIP archive was found. If `deleteOriginal` is `true`, then `unzipArchive` will delete the original ZIP archive after unzipping. Regardless, the path of the unzipped archive (including the zipped folder name) will be returned. 

- `[string convertedPath] = canvas2Autograder(string path, *optional* string outPath=void);`

Takes in a path to the ZIP archive downloaded from Canvas of all the student's submissions. This will reformat this data to be fed into the main autograder. If `outPath` is given, then `canvas2Autograder` will unzip the given archive into that path. Regardless, `convertedPath` will be a path to the resulting folder (including that folder name) will be returned.

- `[string convertedPath] = autograder2Canvas(string path, *optional* string outPath=void);`

Takes in a path to the autograder's working folder, and converts the data to be compatible with Canvas. If `outPath` is given, then it will store these results into the path given by `outPath`; otherwise, it will use a temporary folder. Regardless, this function returns the path to the resulting Canvas compatible archive.

- `[string convertedPath] = autograder2Website(string path, *optional* string outPath=void);`

Takes in a path to the autograder's working folder, and converts the data to be compatible with the CS 1371 Website. If `outPath` is given, then it will store the results into the path given by `outPath`; otherwise, it will use a temporary folder. Regardless, this function returns the path to the resulting Website-compliant data.

- `[Problem[] problems] = generateSolutions(string path);`

This will generate the solution values, given a path to the solution ZIP archive. These solutions are held in a `Problem` array, which is detailed below.

- `[void] = unpackStudentSubmission(string startPath);`

Unpacks a student's submissions into their same folder. If a student submitted a ZIP archive as their attachment, this will unzip that archive _and_ move the files so that they are directly beneath the student's folder. If the student submitted each file separately, this function does nothing.
