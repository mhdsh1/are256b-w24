*--------------------------------------------------
*ARE 256b W24 -- Week 9
*week9.do
*Mar/8/2024
*Mahdi Shams (mashams@ucdavis.edu)
*Based on Bulat's Slides, and previous work by Armando Rangel Colina & Zhiran Qin
*This code is prepared for the Week 9 of ARE 256B TA Sections. 
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
log using week9, replace // Open log file
*--------------------------------------------------

*set working directory 
global path = "C:\Users\mahdi\are256b-w24"
cd $path


*--------------------------------------------------
* Section 1: Slides 92 - 93: FE in Stata
*--------------------------------------------------

use data\Guns.dta,clear
		
		
*Declare the dataset as a panel
xtset stateid year, yearly


*Let us look at the data over time
*State 11 has very very large numbers so it looks weird in the same
*graph
//twoway (line vio year), by(stateid)
//twoway (line vio year if stateid!=11), by(stateid)
twoway (line vio year if stateid==11), by(stateid)


*plain-vanilla:
xtreg vio shall, fe


*plain-vanilla with robust standard errors:
*Robust standard errors cluster over cross-sectional units
*allowing for arbitrary heteroskedasticity and serial correlation within cross-sectional units
xtreg vio shall, fe vce(robust)


*Least Squares Dummy Variable Regression
reg vio shall i.stateid

* note that \beta1_FE = \beta1_LSDV (slide 89) 

*including time fixed effects:
*i.year creates a dummy variable for each unique value of year
qui reg vio shall i.stateid i.year
esttab, se 

eststo: qui xtreg vio shall i.year, fe
esttab, se 

eststo: xtreg vio shall i.year, fe vce(robust)
esttab, se 




*including time fixed effects and state-level time trends (slide 91) 
xtreg vio shall i.year c.year#i.stateid, fe 

*c.year deals with year as a continuous variable, 
*whereas i.stateid creates a dummy variable for each unique value of stateid. 
*# interacts each state dummy variable with the continuous year trend.
reg vio shall c.year 
reg vio shall year

reg vio shall c.year#i.stateid
#reg vio shall i.year#i.stateid

reg vio shall c.year#stateid
reg vio shall year#i.stateid



*including the time-invariant regressor z:
gen z = 10*sqrt(stateid)
xtreg vio shall i.year#c.z, fe vce(robust)

*The above create year-specific coefficients for z. 
*Of course you can also include the time fixed effects and state-level time trends.

*--------------------------------------------------
* Section 2: HW4 Gun Control 
*--------------------------------------------------

*1a
*Regular regressions
eststo clear
eststo: quietly reg vio shall year avginc pm1029 density pop, robust
esttab, se ar2


*1b
*Random Effect regressions
eststo: quietly xtreg vio shall year avginc pm1029 density pop, re vce(robust)
esttab, se r2


*1c
eststo: quietly xtreg vio shall year avginc pm1029 density pop, fe vce(robust)
esttab, se r2

*1e

*Fixed effects regressions
xtreg vio shall year avginc pm1029 density pop, fe
estimates store fe_vio

*Random effects regressions
xtreg vio shall year avginc pm1029 density pop, re
estimates store re_vio

hausman fe_vio re_vio, sigmamore
*RE assumption is rejected


*--------------------------------------------------
* Section 3: HW4 Seat Belt  
*--------------------------------------------------

use data\SeatBelts.dta,clear


*Declare the dataset as a panel
xtset fips year, yearly

*2a
generate dk_spd=drinkage21*speed70

eststo clear
*first case (without time fixed effects)
eststo:  xtreg fatalityrate sb_useage drinkage21 dk_spd, fe vce(robust)


***sidenote1***
/*another way for interaction term, using # ... almost the same:
reg fatalityrate sb_useage drinkage21 drinkage21#speed70
reg fatalityrate sb_useage drinkage21 dk_spd

*why?
br drinkage21 if speed70 ==1
reg  fatalityrate sb_useage  drinkage21#speed70
***end of sidenote1***/


*second case (include time fixed effects) (+ i.year)


*third case (include time fixed effects & state-level trends) (+ i.year and c.year#fips)


esttab, se r2



*2b

*Create a variable that indicates the driver had a higher 
*alcohol content in the blood 
* known as DUI (driving under the influence)
gen dui = 1- ba08


*repeat regressions for 3 cases
			
eststo clear

*first case (without time fixed effects)
eststo:  xtreg fatalityrate speed65#speed70 if dui==1 ,fe vce(robust)
*second case (include time fixed effects)

*third case (include time fixed effects & state-level trends)


esttab, se r2

*double check
br speed65 if speed70==1


*2c 

/*sidenote2
when first differentating we can not use drinkage21#speed70 or dk_spd
drinkage21 and speed70 are treated as categorical values. 
Although we see a 0 and a 1 STATA reads the zero as a "NO" and the 1 as a "YES". 
Then, when we ask STATA to do an operation *like YES-YES it doesn't know what 
to do. So we can do a quick workaround by creating four new variables and first 
differentiating them using D. :*/  
gen yy  = (drinkage21==1 & speed70==1)
gen yn  = (drinkage21==1 & speed70==0)
gen ny  = (drinkage21==0 & speed70==1)
gen nn  = (drinkage21==0 & speed70==0)


* case 1 
eststo: reg D.fatalityrate D.sb_useage D.drinkage21 D.yy D.yn D.ny D.nn, ///
nocons vce(robust)

* compare with FE regression 
eststo:  xtreg fatalityrate sb_useage drinkage21 yy yn ny nn, fe vce(robust)


* case 2


* case 3


*===========================================================
log close 
