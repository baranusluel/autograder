# User Interface

This module will be responsible for interacting with the user and starting the autograder with the given settings. It is the user's primary method of starting the autograder.

## Classess

The `userInterface` Module has the following classes; all of them represent a `UIFigure`:

- `Autograder`: The main entry point for the autograder. Responsible for calling the main method and adding necessary paths. Additionally, it gets most of the settings
- `CanvasAuthorizer`: Instructs the user to get a token from `Canvas` and stores it in the settings file.
- `CanvasHomeworkSelector`: Allows the user to pick which homework to select
- `GoogleDriveBrowser`: Allows the user to browse his/her folders on Google Drive for the solution archive
- `ServerAuthorizer`: Fetches the credentials from the user for logging into the server