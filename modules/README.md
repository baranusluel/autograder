# Modules

Each folder is a single `module`, which is itself a collection of related functions, classes, and documents. Code in any module is free to call code located in any other module - however, all code must exist in a module.

## Data Conversion

`dataConversion` is responsible for converting data from one type to another - it is _not_ responsible for collecting this data.

For more information, see the README in the `dataConversion` folder.

## Grader

`grader` is responsible for actually managing the grading of individual assignments. It grades assignments, assigns scores, and produces HTML feedback. It _isn't_ responsible for communicating this data.

For more information, refer to the README in the `grader` folder.

## Networking

`networking` is responsible for downloading and uploading data. It is _not_ responsible for converting this to a certain form, though it may elect to do so. In general, however, this module takes pre-processed data, or produces raw data.

For more information, refer to the README in the `networking` folder.

## Runner

`runner` is the "brain" (or `Controller`) of the autograder. It has only one function - `Main` - which is responsible for starting up any `GUI`s and generally is the manager of the operations.

For more information, refer to the README in the `runner` folder.

## User Interface

`userInterface` is responsible for communicating directly with the user. It does _not_ provide any data by itself - that is left to the other modules. Instead, it serves purely as a data communicator.

For more information, refer to the README in the `userInterface` folder.