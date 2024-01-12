*--------------------------------------------------
*Title
*filename.do
*date
*Your name (and email adress)
*--------------------------------------------------

*--------------------------------------------------
*Program Setup
*--------------------------------------------------
version 14              // Set Version number for backward compatibility
set more off            // Disable partitioned output
clear all               // Start with a clean slate
set linesize 80         // Line size limit to make output more readable
macro drop _all         // clear all macros
capture log close       // Close existing log files
log using filename, replace      // Open log file
*--------------------------------------------------

*set working directory 
global path = "C:\Users\..."
cd $path

*open a .dta (Stata) file, ...
* ... assuming datafile.dta is in data folder in the working directory 
*we use clear to reaplce the new dataset with the former one
use "$path\data\datafile", clear 

*--------------------------------------------------
* Question 1
*--------------------------------------------------


*--------------------------------------------------
* Question N
*--------------------------------------------------



*--------------------------------------------------
log close // Close the log, end the file

translate "$path\filename.smcl" ///
          "$path\filename.pdf", translator(smcl2pdf)

exit