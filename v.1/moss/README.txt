Here are the instructions for Moss:
	
This script takes about 3 minutes to run. Maybe more if your machine is slow. Be patient.

Requirements: A working internet connection. If you do this without one, things will get messed up in this early version. I
               will fix this soon.

1. Place moss.m, mossinterface.jar, and moji-1.0.1.jar
 	in the same directory as all the student folders. They should
	be alongside the Lastname,Firstname(12423kajfakdsn234342) directories.

2. Create another directory in this same directory called "base". Exactly like that.
	Inside base, put all the .m files that contain text that will be common among submissions.
	This should be any provided text. In here, you should put hw##.m.
	Also copy and paste the contents of the drill problems pdf into a .m file and put it here.
	This is because students tend to put comments in their coded that contain text from these
	files.
	THESE FILES MUST HAVE .m AS THEIR EXTENSION!!!

3. Call moss.m from the command window. Its arguments are the strings of the files that you want
	moss to completely ignore. This will usually be hw##.m, and any ABCs files, as every student
	submits them, and they will be largely similar.
	
	your call should look something like this

	moss('hw03.m', 'ABCs_vectors.m');

4. Wait.

5. Profit! --- Instructions for reading the results are on the webpage that appears.

VERY IMPORTANT NOTE:
If you kill the script before it is completely finished (it's not finished when the webpage pops up), the names of your
student directories and files will be all fudged up. Wait for the >> to reappear in the command window before doing 
anything else.