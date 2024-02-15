*----------------------------------------------------------------------------*-
*ARE 256b W24 -- Week 4
*week4.do
*Feb/09/2024
*Mahdi Shams (mashams@ucdavis.edu)
*Based on Bulat Gafarov's Slides, and previous work by Armando Rangel Colina &
* Zhiran Qin.
*This code is prepared for the fourth week of ARE 256B TA Sections. 
*Here you find codes related to the discussion macros and loops in Stata.
* This is mostly aimed at preparing studnets for homework 2 where they need 
* these concepts in Stata to replicate the RD and D-in-D results from 
* "Mastering Metrics".
*----------------------------------------------------------------------------*

*set working directory 
global path = "C:\Users\mahdi\are256b-w24"
cd $path

*----------------------------------------------------------------------------*
*Program Setup
*----------------------------------------------------------------------------*
version 14              // Set Version number for backward compatibility
set more off            // Disable partitioned output
clear all               // Start with a clean slate
set linesize 80         // Line size limit to make output more readable
macro drop _all         // clear all macros
capture log close       // Close existing log files
log using week4, replace // Open log file
*----------------------------------------------------------------------------*

*----------------------------------------------------------------------------*
* Section 1: Local Macros
*----------------------------------------------------------------------------*

use data\auto

/* Local macros are somewhat like variables in programming languages.
They are "boxes" where you can store things and pull them our later. 
This allows you to write code that will do different things depending
on the value of the macros at the time it is run.
While macros can be used like variables, they are not really variables.
What really happens is that macros are replaced by the text they contain
before Stata interprets the command.
All macros are stored as strings, even numbers. In fact we don't even
need the equals sign in the macro definition unless we want Stata to 
do some math first.*/

local x 1
//is the same as:
local x=1

display x
summ make

local y 2+2
display `y'
display "`y'"


local x -2
di `x'^2

/*If you guessed 4, you forgot either the precedence of algebraic
operators or how Stata uses macros. `x' is replaced by -2 before Stata
does anything with it, so it sees -2^2. But the power takes precedence
over the minus sign, so this is the same as -(2^2), not (-2)^2. If `x'
were a variable like in other programming languages, the minus sign
would not be separate from the 2.*/

// create local macro variable X and set it equal to the text lalala.
local X = "lalala"  

display "My variable name is: `X'"
display "My variable name is:   X"


/*Enclosing a letter or variable name in left and right quotes
tells Stata to evaluate it as a local macro variable.*/

local i 1
di `i'

/* A local macro variable can be used many times throughout a program and
thus can save a lot of typing.  It can also help keep a foeach command
from looking very messy, like if you wanted to pass through a foreach 
command 10 or more variables that could not be represented in shorthand.*/

/*if you had a big list of control variables that you used constantly,
you could define the list as a a macro called controls. Then instead of:*/

// these three regression are going to yield same result: 

regress mpg trunk weight length

local apple trunk weight length
regress mpg `apple'

local varlist "trunk weight length"
regress mpg `varlist'

// local has a short memory
local a = 2

di `a'

*----------------------------------------------------------------------------*
* Section 2: Loops in Stata
*----------------------------------------------------------------------------*

**** foreach 

help foreach

foreach i in red blue green {
di "`i'"
}

//is same as:

local colors red blue green
foreach i in `colors' {
di "`i'"
}
//is same as:

local colors red blue green
foreach i of local colors {
di "`i'"
} 

/* Note that in changed to of because local is officially a list type,
if a rather odd one. Also note that colors is not in quotes in the
foreach command. If it were in quotes, the standard macro processor
would expand it out to red blue green. Instead, we let the local list
type look up what the macro means, which it does very quickly.
Normally list types tell Stata tell what types of things are in
your list. The available types are varlist, newlist, and numlist.*/

foreach x in "hi" "bye" "aloha" {
	display "`x'"
}
**
foreach x in "Dr. Nick" "Dr. Hibbert" {
	display in yellow "`x' contains "  length("`x'") " characters"
}
**
foreach x in mpg weight {
	summarize `x', detail
}

foreach x of varlist mpg weight {
	summarize `x', detail
}

local controls price mpg weight
foreach j of local controls {
	summarize `j', detail
	egen z_`j' = std(`j')
	label var z_`j' "Z-scored `j'"
	summarize z_`j'
} 


**** forvalues
forvalues i = 10(10)50 {
	display `i'
	}
**
regress price mpg rep78 displacement if foreign == 0
regress price mpg rep78 displacement if foreign == 1

forvalues i = 0/1 {
	regress price mpg rep78 displacement if foreign == `i'
	}
	
*----------------------------------------------------------------------------*
* Bonus: Replication of Table 4.1 of Mastering Metrics
*----------------------------------------------------------------------------*

clear all

use "$path\data\AEJfigs_MM_RD", clear

* columns 1 and 3 is the model 4.2 AP2014 -- you only use control for age
* columns 2 and 4 is the model 4.4 AP2014 -- you control for age, age_sq, and 
* ... their interaction with the dummy variable

* generate an over-21 dummy
gen D = (agecell>21)
* generate control variables
gen age = agecell - 21 // a - a_0
gen age_sq = age^2
gen age_D = age*D
gen age_sq_D = age_sq*D

matrix A = J(8,8,0)
matrix rownames A = all mva suicide homicide externalother internal alcohol Sample_Size
matrix colnames A = 1 se 2 se 3 se 4 se

* define a variable list and loop over all dependent variables in var_list 
* we have 4 different regressions for each dep. variable in varlist
* note that when using local, you should run the code all together,

local var_list all mva suicide homicide externalother internal alcohol
loc count = 1
foreach i of local var_list {

	* regressions for column (1)
	qui reg `i' D age, robust
	mat A[`count',1] = _b[D]
	mat A[`count',2] = _se[D]
	mat A[8, 1] = e(N) // e(N) gives the sample size
	mat A[8, 2] = .
	if `i' == all predict all_hat

	* regressions for column (2)
	//exercise

	* regressions for column (3)
	qui reg `i' D age if inrange(agecell, 20 , 22), robust
	mat A[`count',5] = _b[D]
	mat A[`count',6] = _se[D]
	mat A[8, 5] = e(N)
	mat A[8, 6] = .

	* regressions for column (4)
	// exercise

	loc ++count
	dis `count'
}

* let's look at the output: 
matlist A

* and let's make a letex table output form the matrix:
esttab matrix(A, fmt(2)) using graphs/Tab41.tex, replace nomtitles sfmt(%5.2f) ///
width(\hsize) ///
addnote("Samples in columns 1 and 2 regressions have between 19 and 22 years." ///
"samples in coulmns 3 and 4 have between 20 and 21 years old." ///
"Columns 1 and 3 report the results of regressing dependent variable on age." ///
"columns 2 and 4 report results of regressing dependent variable on age, age-squared" ///
"with their interactions with the over-21 dummy.") ///
label title(Sharp RD estimates of MLDA effects on mortality ///
(Replication of Table 4.1 of AP2014) \label{tab::41})


*---------------------------------------------------------*
* an alternative way to replicate using outreg2 in stata  *
*---------------------------------------------------------*

* this is the package that we need in order to send regression results we get in
* ... each loop to excel and append them together:
ssc install outreg2

* define a variable list, dependent variables: "all deaths", 
* ... "motor vehicle accidents releted deaths", ...
local var_list all mva suicide homicide externalother internal alcohol

* Only replace the Excel file the first time is run
loc first_step = "replace"

*counting each loop (we expect to run 7 loops as we have 7 different dep. variable)
loc count = 0

*Loop over var_list (4 different regressions for each dep. variable in varlist) 

foreach i of local var_list {

if `count' != 0 loc first_step = "append"

* regressions for column (1)
qui reg `i' D age, robust
outreg2  using "$path\outputs\rd.xls", keep(D) dec(3) bdec(3)tdec(3) rdec(3) alpha(.01, .05, .1) `first_step'

* regressions for column (2)
// home exercise

* regressions for column (3)
qui reg `i' D age if inrange(agecell, 20 , 22 ) , robust
outreg2  using "$path\outputs\rd.xls", keep(D) dec(3) bdec(3)tdec(3) rdec(3) alpha(.01, .05, .1) append
//inrange(z,a,b): 1 if it is known that a < z < b; otherwise, 0

* regressions for column (4)
// home exercise

loc ++count
dis `count'
}


*----------------------------------------------------------------------------*
* Bonus: Replication of Table 5.2 of Mastering Metrics
*----------------------------------------------------------------------------*

use "$path\data\deaths",clear

* replicating model 5.5 (col 1 & 3)and 5.6 (col 2 & 4) in AP2014

* generating state trends
levelsof state , loc(states)
foreach s of loc states {
gen t_`s' = year*(state == `s')
}

set more off
//tells Stata to run the commands continuously without worrying about 
// the capacity of the Results window to display the results

* Col 1
reg mrate legal i.year i.state ///
if dtype == 1 & inrange(year,1970,1983) & agegr ==2, vce(cluster state)

* Col 2
//exercise 

* Col 3
reg mrate legal i.year i.state [w = pop] ///
if dtype == 1 & inrange(year,1970,1983) & agegr ==2, vce(cluster state)

* Col 4 for dtype == 1 (i.e., all death)
// exercise

*==============================================================================

log close 

translate "week4.smcl" ///
          "week4.pdf", translator(smcl2pdf)
