% DO NOT CHANGE THIS LINE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [A B C D E F G H I J] = ABCs_sorting()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Directions: Write the code to satisify the following directions. For each
% part, store your answer in the variable that is specified within the
% parentheses.
%   Ex. Add 1 + 1. (GT)
% That means store the value of 1 + 1 in the variable GT, like so:
%   Ex. GT = 1 + 1;

%% Part I: Big O
% Big O is a method of measuring the efficiency of an algorithm, based
% on how many operations must be completed.

% Directions: The following code blocks are executed in the MATLAB command
% window. Select the big O that best describes each algorithm.

% Options:
%
% 1 - O(N)
% 2 - O(3*N^2)
% 3 - O(N^2)
% 4 - O(N^3 + N^2)
% 5 - O(N^3)

% 1. What is the Big O of the following code? (A)
% for i = 1:N
%     for j = 1:3*N
%         <code>
%     end
% end
A = 3;

% 2. What is the Big O of the following code? (B)
% for i = 1:N
%     for j = 1:N
%         for k = 1:N
%             <code>
%         end
%     end
% end 
% for m = 1:N
%     for n = 1:N
%         <code>
%     end
% end
B = 5;

% 3. What is the Big O of the following code? (C)
% for i = 1:N
%     for j = 1:10
%         <code>
%     end
% end
C = 1;

% 4. What is the Big O of the following code? (D)
% for i = N:N^2
%     for j = N:-1:1
%         <code>
%     end
% end
D = 5;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Part 2: Sorting

% Directions: The following code blocks are executed in the MATLAB command
% window. Select the value of the option that best describes each
% algorithm or statement.

% Options:
%
% 1 - Bubble Sort
% 2 - Insertion Sort
% 3 - Merge Sort
% 4 - Quick Sort
% 5 - iterative
% 6 - recursive
% 7 - O(N*log(N))
% 8 - O(N^2)

% 1. For the following sorting algorithm, choose the name of the sort (E),
% whether the sort is iterative or recursive (F), and the Big O of the
% sort (G).

% function out = mystery(in)
%     if length(in)==1 | length(in)==0
%         out = in;
%     else
%         num = in(1);
%         out=[mystery(in(in<num)),in(in==num),mystery(in(in>num))];
%     end
% end
E = 4; % Name of the sort?
F = 6; % Iterative or Recursive?
G = 7; % Big O?

% 2. For the following sorting algorithm, choose the name of the sort (H),
% whether the sort is iterative or recursive (I), and the Big O of the
% sort (J).

% function vec = mystery2(vec)
%     for i = 2:length(vec)
%         value = vec(i);
%         j = i - 1;
%         while (j >= 1) & (vec(j) > value)
%             vec(j+1) = vec(j);
%             j = j-1;
%         end
%         vec(j+1) = value;
%     end
% end
H = 2; % Name of the sort?
I = 5; % Iterative or Recursive?
J = 8; % Big O?

end