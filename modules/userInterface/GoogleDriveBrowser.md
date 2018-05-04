# Google Drive Browser

This GUI is responsible for showing the user a detailed list of their Drive
documents. This aids in downloading the `grader` folder.

## Operation

This GUI is _not_ to be called directly. Instead, it is to be called via the
`Autograder`, which does so automatically. This GUI automatically assigns the
`driveFolderId` in the `Autograder` on exit.

## Exceptions

This GUI will throw a `connectionError` exception if the connection is
terminated.