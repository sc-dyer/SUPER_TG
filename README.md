**Welcome to SUPER_TG!**

This program was created by Sabastien Dyer on 2019/07/17
If you have any questions or comments please email me at sabastien.dyer@carleton.ca
The latest version of this program and other programs I develop will be available at www.scdyer.com/software
This has only been designed to work on UNIX based systems.


**About SUPER_TG:**

SUPER_TG is a small program developed to use THERIA_G (Gaidies et al, 2008) more effectively in conjunction with high performance computing(HPC). This program randomly generates points on a PTt path within given ranges of pressure and temperature. It then runs THERIA_G along this randomized path. The program is set up in such a way that it can be given two command line arguments and run without any further interaction. The two arguments are ARRAY_INDEX and DATABASE in that order. This allows it to be set up as a job array in whichever job management system the HPC cluster is using (NOTE: This has been designed only with the SLURM workload manager in mind but there is no reason this shouldnt work with other systems).


**The files required in your working directory to run SUPER_TG are:**

"THERIN" - compositional data of the rock (Same as THERIAK-DOMINO)

"theriag_dif.txt" - Diffusion matrix for garnet (Same as THERIA_G)

"theriag_CSD.txt" - Crystal size distribution of garnet (Same as THERIA_G)

database file - thermodymamic data, name is user input (Same as THERIAK_DOMINO)

theriak.ini - initialization file, copy from the SUPER_TG folder

"theriag_PTt_range.txt" - file used to generate random paths, see below


**Format of "theriag_PTt_range":**

The file is quite flexible in its formatting, just follow four rules.
1. the header line is not read by the program so make sure there is something there
2. Each line is a different PTt point
3. Every number must be seperated by at least one space ' '
4. Write each line in this order: T_low T_hi P_low P_hi HeatRate (Units are degC,bar,degC/Ma)


**Compiling:**

In the command line go to the directory where the source code is and type the following commands:

$ make super_tg

$ make clean


