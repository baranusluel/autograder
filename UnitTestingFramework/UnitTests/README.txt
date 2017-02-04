To run a single unit test, use the command:
runtests('testExample.m');

To run multiple unit tests, use the command:
runtests({'test1.m', 'test2.m', ...});

To run all of the unit tests, use the command:
runtests

All of these commands output a structure array that contains the
test results if you wish to further analyze the results.