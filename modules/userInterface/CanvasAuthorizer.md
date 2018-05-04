# Canvas Authorizer

This GUI is responsible for authorizing the user with Canvas. It is little 
more than requesting a token (the user must manually generate this token)
and checking if it works.

## Operation

This GUI is _not_ to be called directly. Instead, it is to be called via the
`Autograder`, which does so automatically. This GUI automatically assigns the
`canvasToken` in the `Autograder` on exit, and this token is automatically saved.

## Exceptions

This GUI will throw a `connectionError` exception if the connection is
terminated.