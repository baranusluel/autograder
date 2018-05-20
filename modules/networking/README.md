# Networking

This module is responsible for uploading files to their correct destinations.

## Functions

The `networking` Module has the following functions:

- `[void] = uploadToCanvas(*optional* string url);`

Uploads appropriate data directly to Canvas. This will implicitly call `autograder2Canvas`

- `[void] = uploadToWebsite(*optional* string url);`

Uploads appropriate data directly to the CS 1371 Website. This will implicitly call `autograder2Website`
