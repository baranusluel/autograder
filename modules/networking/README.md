# Networking

This module is responsible for uploading files to their correct destinations.

## Functions

The `networking` Module has the following functions:

- `[string token] = authorizeWithGoogle();`

Asks the user for permission to use Google Drive and returns the refresh token

- `[void] = downloadFromCanvas(string courseId, string assignmentId, string token, string path, UIProgressDlg progress);`

Downloads the assignment submissions for the given assignment in the given course, using the given
path and token. Progress is tracked via the progress dialogue

- `[void] = downloadFromDrive(string folderId, string token, string path, string key, UIProgressDlg progress);`

Downloads the given folder using the given token and key to the given path, updating progress along the way.

- `[void] = uploadToCanvas(Student[] students, string courseId, string assignmentId, string token, UIProgressDlg progress);`

Uploads the grades for the given students to Canvas.

- `[void] = uploadToServer(Student[] students, string user, string pass, string hwName, UIProgressDlg progress);`

Uploads the student's files to the CS 1371 server, using the credentials provided. This function makes use
of `JSch` for quick `SFTP` communication with the server.

- `[string access] = refresh2access(string refresh);`

Converts a given refresh token to an access token

- `[void] = postToCanvas(string courseId, string token, string message);`

Posts a given message to the given course on Canvas as an announcement

- `[string courseId] = getCanvasCourse(string token, string code);`

Uses the given code to find the "best match" course ID on Canvas.