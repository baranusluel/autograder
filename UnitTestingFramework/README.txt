Autograder Unit Testing Framework (prototype)

1. Directory Structure
    Every directory within the main autograder repo will contain the functions
    for a single unit of code. A unit of code is a part of the autograder that
    can also function as a standalone component. For example, the plot checker
    is a unit, or the extraction of student code from the T-Square bulk download
    is a unit. If a directory contains more than 5 functions, it is probably
    time to refactor into multiple units.

2. Unit Tests
    This is the heart of Test Driven Development and is the reason for
    structuring code into units. Each unit (directory) should have a unit test
    that fully checks that unit's "contract". The unit contract is a well
    defined description of how to go from inputs to outputs (sort of like a
    function description). If you are familiar with OOP, this is sort of like
    testing the interface that a class must adhere to. Unit tests should not
    test specific implementation details (regular debugging is used to figure
    that stuff out) but rather unit testing makes sure that given any possible
    input, the unit of code produces the expected result.

3. Writing Unit Tests
    A good set of unit tests will cover every possible input and output
    scenario. One way to construct tests is to look at every conditional and
    loop in your code. What different scenarios are you trying to account for
    with this logic? For each different case your code considers, you should
    write a test case. Additionally, it is sometimes a good idea to write unit
    tests before you even write your code to solidify in your mind exactly the
    problem you are trying to solve and also to think through the possible input
    scenarios. Make sure all of your unit test functions are well named (you do
    not earn brownie points for having short function names!).
    
    ** NOTE **
    A test case does not have to be lengthy to be a good test case.
    For example, to test the code that parses the T-Square bulk download, you do
    not need a directory of 1000 student's files. Instead, you should carefully
    construct a folder of 5-10 mock-student's code that tests all possible
    scenarios.

4. Function-Based Unit Tests
    MATLAB provides script-based, function-based and class-based unit testing
    frameworks. For the autograder, we will use the function-based framework. You
    may want to look over the following documentation before looking at the
    example: https://www.mathworks.com/help/matlab/function-based-unit-tests.html
    Once you have read and have a general understanding of the funcionality that
    MATLAB function-based unit testing provides, you can take a look at the code
    in ExampleUnitTest.m. This will give you a general idea of how to structure
    your unit tests so that they are uniform across all units and recognizable
    by the UnitTestDriver (the code that runs all of the unit tests).

5.  Reasoning for Unit Testing
    At this point, you may be wondering why this way of doing things is any
    better than regular debugging. The reason is because unit testing gives a
    very concrete metric by which to measure code correctness. Also, by shifting
    the focus of development away from just hacking away at a keyboard and
    toward defining functionalty by test cases, correctness usually comes as a
    biproduct. And lastly, by testing every unit for expected behavior as it is
    written mitigates the dreaded crash when the call stack is 15 functions deep
    and you have no idea what caused the problem. This framework is used by
    software dev teams around the world because it works!