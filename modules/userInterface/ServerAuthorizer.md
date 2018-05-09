# Server Authorizer

This is a simple GUI that requests the user's Username and Password for
the server. While a tokenized system would be preferable, this will work.

## Operation

This GUI is _not_ to be called directly. Instead, it is to be called via the
`Autograder`, which does so automatically. This GUI automatically closes

## Remarks

For security reasons, the password is not stored - specifically, we can't
encrypt the password, so we can't be tasked with securely storing it.