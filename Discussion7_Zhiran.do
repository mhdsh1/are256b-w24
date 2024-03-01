*==============================================================================
*ARE 256B SECTION 7
*Date: Feb 18th, 2022

*Edited by Zhiran
*refer to Bulat's and Armando's codes
*==============================================================================


clear all
cd "/Users/c/Documents/Stata/256B2022/Discussion7/"

*********************************************
*****part1: CPI monthly      ***********
*********************************************


 

*Download CPI monthly  inflation (both index, Y,  and percentage changes, d log Y)  *1970-2022 https://fred.stlouisfed.org/series/CPILFESL . Discuss that Index is *trending upwards, but after doing percentage changes, it wiggles around the mean.

import delimited "CPIAUCSL.csv",clear


*time format
generate date1 = date(date, "YMD")
gen date2 = date1
format date2 %td
tsset date2

*extract month and year
gen mth = month(date2) 
gen yr = year(date2)

*generate a new monthly time index
gen month = ym(yr,mth)
format month %tm
tsset month

*or
gen mdate = mofd(date2)
format mdate %tm




rename cpiaucsl y
tsline y

ac y, lags(200)

*two ways to calculate percentage change, which is actually inflation
gen logy = log(y)
gen dlogy = logy - logy[_n-1]
gen pcy = (y-y[_n-1])/y[_n-1]
tsline dlogy pcy


ac logy, lags(200)

*For CPI percentage changes compute mean  and AC function. How many AC lags are *statistically significant?

sum dlogy
ac dlogy, lag(400)


*Compute differences in CPI percentage changes, dd log Y, make TS plot. How many AC lags are statistically for dd log Y ?
*Computing first differences to try to get a stationary process

gen ddlogy = dlogy - dlogy[_n-1]
tsline ddlogy
ac ddlogy, lag(500)



*For an insight of why we would want a stationary process, please check
*your textbook and
* https://www.tylervigen.com/spurious-correlations



*==============================================================================


*******************************************************************
*****part2: Seasonal patterns: Electronic prices     ***********
*******************************************************************


import delimited "APU000072610.csv",clear

*rename variables
rename apu000072610 p

*time format
generate date1 = date(date, "YMD")
gen date2 = date1
format date2 %td

*extract month and year
gen mth = month(date2) 
gen yr = year(date2)

*generate a new monthly time index
gen month = ym(yr,mth)
format month %tm
tsset month

*or
gen mdate = mofd(date2)
format mdate %tm


*seasonal?
tsline p
tsline p if  inrange(yr, 2000, 2003)

*(a)Seasonal dummies
*Generate a new variable seasonal that is equal to 1 for t 
*corresponding to January and 0 otherwise. 

gen seasonal = 1 if mth == 1
replace seasonal = 0 if seasonal == .

*Compute regression of gcem on L(0=10)seasonal.
*Which months has the largest and the smallest average values for gcem? 

*use December as a base case
reg p L(0/10).seasonal,robust

*use January as a base case
reg p i.mth, robust
dis .1008837+.0001877

*Directly calculate the means
reg p L(0/11).seasonal, nocons robust


*(b)Breusch-Godfrey Test
*for simplicity set x as white noise
gen x = rnormal() 

*i) Perform the OLS regression.
reg p x
*ii) Obtain residuals from that regression.
predict resid, residuals
ac resid
*iii) Generate the lagged residual.
gen resid_lag1 = resid[_n-1]
*iv)Perform the auxiliary regression of the residual on its own lag and the regressor grres.
reg resid x  resid_lag
reg resid x L(1/1).resid
reg L(0/1).resid x


reg resid x L(1/3).resid
reg resid x L(1/5).resid

esttab, se r2

*v) Compute the Breusch-Godfrey statistic using nR2 from the above regression.	
dis 484 * 0.997 


reg resid x
estat bgodfrey, lags(5)

estat bgodfrey, lags(20)

*(c)Correcting for Serial Correlation.
*compute the T you need
reg p x, robust
newey p x, lag(6) force


reg L(0/26).p 
estat bgodfrey, lags(26)




























