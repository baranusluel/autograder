# Cheat Detection

The goal is to flag students whose code looks similar to others' code. Then, the user should be able to view the detection results, and see what students likely cheated (copied) code from one another.

## Tools

To detect code similarity, we'll use the **l**ocale **s**ensitive **h**ash, or **LSH**. It is a type of hashing algorithm that aims to encourage collisions for similar data.

## Interaction with user

The user should be able to select before grading whether or not they want to test for cheating. If they do, at the end of grading, they should be presented with a report that details how similar two students' code was.

## Implementation Notes

- [ ] Regardless of whether or not cheating detection was asked for, we should still collect the raw data - so that in the future, a person who had the right .mat file could theoretically rerun the report.
- [ ] There should be a way for the user to run cheating detection on a student array, even if not currently grading

## Possible UI Idea

The user could be presented with a screen that used the `uitree` and friends. Each student would be in a list (we could provide a search functionality), and it would have their name, ID, and likelihood of cheating. Selecting a student would populate a `uitree` with nodes for each submitted HW. Expanding each HW would show who they were most similar to (within a certain margin). Additionally, when selected, a text area at the top would populate and say "this student's homework was similar to x's, y's, ..., and z's homework. See below for details".

Additionally, the user should be able to push a button and compare two students fully, seeing if it is likely they cheated.
