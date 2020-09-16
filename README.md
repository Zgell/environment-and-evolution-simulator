# Environment and Evolution Simulator

## Introduction

As stated in the repository's description, this is a program I wrote with my contest partner over the course of 2 months for the University of Alberta's ENCMP 100 first-year engineering programming competition in the 2019-2020 school year. It took first place in the "Applications" category for the contest.

I am fully aware that this is likely not the most efficient implementation of this concept, and that MATLAB is far from the best language for a simulation such as this one. However, these were the rules of the competition. We had to use MATLAB, and like all of the other contestants, we were also learning the language as we created the project for the competition.

I don't intend to update or to continue work on this repository going forward, and instead I am publishing it here so that anyone interested can access the code for the simulation, or even use it for themselves if they want. However, I may recreate the project in a more suitable programming language with a more suitable framework in the future someday.

## How to Run the Program

Firstly, download the file from the repository, and extract them to a folder of your choosing. Make sure that all five files are in the same folder. Then, open the "main.m" file in MATLAB. We created the program in version R2019b, and so we recommend that for best results you use that version as well. And that's it.

In theory, the program could also be run using GNU Octave if you don't have access to MATLAB. However, there are two issues with this implementation:
1. I can't guarantee that the performance of this code will be great using Octave as only MATLAB has access to the Intel Math Kernel Library.
2. I also can't guarantee absolute compatibility as I know that Octave currently lacks some of MATLAB's advanced features, and I do not know enough about Octave to know if this includes the interface features.
