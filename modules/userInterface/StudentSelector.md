# Student Selector

This GUI is responsible for showing the user a list of the possible
student submissions to grade, for a specific assignment.

## Operation

This GUI is _not_ to be called directly. Instead, it is to be called via the
`Autograder`, which does so automatically. This GUI automatically assigns the
`selectedStudents` in the `Autograder` on exit.

## Exceptions

This GUI will throw a `connectionError` exception if the connection is
terminated.