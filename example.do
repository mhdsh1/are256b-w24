*----------------------------------------------------------------------------*
*Title
*filename.do
*date
*Your name (and email adress)
*----------------------------------------------------------------------------*

*set working directory 
global path = "C:\Users\..."
cd $path

*----------------------------------------------------------------------------*
*Program Setup
*----------------------------------------------------------------------------*
version 14              // Set Version number for backward compatibility
set more off            // Disable partitioned output
clear all               // Start with a clean slate
set linesize 80         // Line size limit to make output more readable
macro drop _all         // Clear all macros
capture log close       // Close existing log files
log using filename, replace    // Open log file
*----------------------------------------------------------------------------*

*open a .dta (Stata) file, ...
* ... assuming datafile.dta is in data folder in the working directory 
*we use clear to reaplce the new dataset with the former one
use "$path\data\datafile", clear 

*----------------------------------------------------------------------------*
* Question 1
*----------------------------------------------------------------------------*


*----------------------------------------------------------------------------*
* Question N
*----------------------------------------------------------------------------*



*----------------------------------------------------------------------------*
log close // Close the log, end the file, the log file will be created

* convert the log file to a pdf file
translate "filename.smcl" ///
          "filename.pdf", translator(smcl2pdf)

exit