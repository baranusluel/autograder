%% Autograder: Automatically grade student homework submissions
%
% The autograder is your primary method for grading student submissions.
% The autograder has a wide variety of options for fine-tuning how we grade
% the homework - ideally, you only ever need to touch the autograder to
% grade student submissions.
%
%% Introduction
%
% The autograder was born out of a central need: With 875 students, two
% homeworks due per week, each homework consisting of 7-8 problems, each of
% which contains 3-4 test cases. Doing the math, that means 36,750 tests.
%
% If each test case takes one second to grade (which is unlikely), then
% that means _10.2 hours_ to grade everything, each week. In reality, we
% guarantee each student at most _30 seconds_, so this becomes ~30 times as
% long: _12.7 days_. Longer than a week! This is unacceptable, and it
% doesn't even account for the fact that we also have to create feedback
% files, upload grades, etc.
%
% Clearly, if we are smart about crafting the homework, we could make a way
% to automatically grade them. Let computers do the hard work! That idea is
% what this application is all about.
%
% This manual is separated into two parts:
%
% # Quick Start: Get started quickly with this step-by-step example.
% # Option Documentaton: Get documentation for each part of the autograder.
%
%% Quick Start Guide
%
% To get started, let's walk through an example!
%
%%% Installation
%
% First, let's make sure you meet the minimum requirements. You have to
% have:
%
% * MATLAB r2018a or later
% * Parallel Computing Toolbox
% * Instrument Control Toolbox
%
% If you meet the requirements, great! Let's get it installed. Just
% download the latest release from the GitHub site under Releases. To
% install, just double click the file: MATLAB will automatically install
% the autograder. Incidentally, this is also how you upgrade.
%
%%% First Run
%
% When you first run the autograder, you'll need to download the initial
% settings file. This will allow the autograder to interface with Google
% Drive, Canvas, notifications, and the course website. Thankfully,
% installing these settings is quite simple: Just _make sure you are on
% Georgia Tech's network_, and enter in the username and password for the
% server. If you don't know these credentials, you'll need to ask the Head
% TA or STAs for them
%
% Once the credentials are downloaded, we just have to get a few
% permissions from you.
%
% First up is Canvas. To authorize, you can either use the Authorizations
% menu or just select the "Select from Canvas" option in the first box,
% student submissions
%
% After you follow the instructions on-screen, you will be presented with
% the chance to pick a homework assignment to grade. Only assignments with
% the name "Homework" are shown.
%
% Once you've picked the assignment to grade, we can then look at getting
% the solution files. To do this, pick "Select from Google Drive" in the
% second settings box. You'll be asked to authorize with Google Drive -
% that's so the Autograder can download data from your drive to create and
% run solutions. *The Autograder will _never_ upload or delete information
% from your Drive*.
%
% After you authorize, you'll be able to pick a folder: Pick the "grader"
% folder; in other words, pick the containing folder for all the grader
% files. If you have any questions about this, ask the homework STA.
%
% Theoretically, that's all you need to do. If you click "Go!", it will
% grade the students. However, if you don't check any options (detailed in
% the next section), your grading won't be communicated anywhere. For now,
% just click "Upload Grades to Canvas", which will upload the students'
% grades to Canvas.
%
% Click "Go!", and you'll notice the grader will start. At this point, feel
% free to do other things on your computer, but for obvious reasons, you'll
% be unable to use MATLAB during grading. Once grading commences, you'll
% see a histogram pop up, which will track grades during the grading
% process. This histogram is updated after every 10 graded students, so
% don't worry if it doesn't update at first.
%
%% Option Documentation
%
% This section details what all of the options are for, and what they can
% do.
%
%%% Grading a Subset of Students
%
% The autograder can grade a subset of students, if you want to. To do
% this, just select a source for the student submissions, then select
% "Select" instead of "All". You'll be presented with a list of students,
% and you'll be able to select which students you want to grade
%
%%% Upload Grades to Canvas
%
% This will upload all grades to the Canvas site. As of now, comment grades
% are included in the feedback file, but _not_ in the grade itself. _Note:
% This does *not* upload feedback files_.
%
%%% Email Feedback
%
% This will use the CS 1371 Notifier to email each student's feedback to
% their Georiga Tech inbox. You can provide a message, but that message
% must be in plaintext.
%
%%% Upload Files to Server
%
% This will upload feedback files to the CS 1371 Website, for use with the
% regrade and gradebook website(s). You'll need to re-enter the Server
% Password
%
%%% Store Output Locally
%
% This will make the autograder export the student files (and feedback) to
% a folder of your choice.
%
%%% Debugger Mode
%
% This will augment the autograder to enter "Debug" mode when it encounters
% an error. If you're having troubles with the autograder, this tool is
% indispensable.
%
%%% Post Announcement
%
% This will allow you to post a styled announcement to the Canvas course
% site. It defaults to Markdown, but you can use whatever formatting you're
% most comfortable with. The title is _not_ styled.
%
%%% Analyze For Cheating
%
% This will use the CheatAnalyzer(TM) to analyze all students for cheating,
% and will open a viewer to parse the results. Optionally, you can export
% this to a set of folders and HTML files, to be viewed as a website.
%