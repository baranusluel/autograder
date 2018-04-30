# Autograder

This GUI is responsible for allowing the user to set options, run, and cancel
the autograder.

## Operation

This GUI is to be called directly; it is, after all, the main entry point.
However, the app will most likely be launched from the app toolbar of MATLAB.

## Exceptions

This GUI is guaranteed to never throw any exception. Any errors are reported
to the user, and optionally sent via email.