*--------------------------------------------------
*ARE 256b W24 -- Week 6
*week6.do
*Feb/16/2024
*Mahdi Shams (mashams@ucdavis.edu)
*Based on Bulat's Slides, and previous work by Armando Rangel Colina & Zhiran Qin
*This code is prepared for the week 6 of ARE 256B TA Sections. 
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
log using week6, replace // Open log file
*--------------------------------------------------

*set working directory 
global path = "C:\Users\mahdi\are256b-W24"
cd $path

*--------------------------------------------------
* Section 1: White noise, MA(1), AR(1)  
*--------------------------------------------------

*Generate White noise, MA(1), AR(1) processes using the codes from the slides. 
*Make *autocorrelation plots  for T=100 and 1000 to illustrate consistency.

browse 

clear all
set more off

set obs 1050

gen t=[_n]

tsset t // we use this to declare time periods to stata, try help tsset.

* Let's create the White Noise First. 
* white noise is the buidling block of time series.

gen e=rnormal() 

// here we create the WN,by creating using random normal distribution ... 
// ... this is white noise beacuase (slide 9): 
// (1) the mean is zero and constant 
// (2) the variance is not changing over time
// (3) and ac is 0 for any lag larger than 0

tsline e if t<100 //Plot the constructed time series

*Create an autocorrelogram (95% confidence interval by default)
ac e
// autocorrelogram gives the function of autocorrelation function (slide 8) ...
// ... as function of lags (\tau in lecture)
// We observe that the ac for the white noise is always 0 for all the lags



* Let's create the MA1 process
// we are going to make the same process as we have on slide 10

* first thing to do is to create the lag of e:
gen elag=e[_n-1]

* and now we have MA(1)
gen yma=0.25+e+elag*.5

tsline yma if t<100 // plot the MA(1)

ac yma // plot the autocorrelation



* Let's create the AR1 process

gen yar=0.25+e in 1 // we create the y_1 first, assuming y_0 is 0: 

replace yar=0.25+0.9*yar[_n-1]+e in 2/1050
// and then create the following values

tsline yar
ac yar
ac yar,lags(500)

*AR1 with diff parameters  
*Plot AR(1) process with rho = 0, 0.4, 0.9 for T=100.

*rho=0
gen yar_00=e in 1
replace yar_00=0.25+0*yar_00[_n-1]+e in 2/1050

*rho=0.4
gen yar_04=e in 1
replace yar_04=0.25+0.4*yar_04[_n-1]+e in 2/1050

*rho=0.6
gen yar_06=e in 1
replace yar_06=0.25+0.25*yar_06[_n-1]+e in 2/1050


*rho=0.9
gen yar_09=e in 1
replace yar_09=0.25+0.9*yar_09[_n-1]+e in 2/1050

tsline yar_00 yar_025 yar_04 yar_09

* compate the autocorrelograms:
ac yar_00 
ac yar_04 
ac yar_06
ac yar_09


*--------------------------------------------------
* Bonus 1:  S&P 500  
*--------------------------------------------------


*Download S&P 500 daily stock returns for recent 5 years
*https://fred.stlouisfed.org/series/SP500*
*Make a plot of the time series  and autocorrelation. 
*It should be like white noise, i.e. no autocorrelation.

import excel "data\SP500.xls", firstrow clear 

destring SP500, replace

*time format
*Date and time functions :   https://www.stata.com/manuals13/u24.pdf
format DATE %td

tsset DATE
tsline SP500
ac SP500, lag(100)

*daily stock returns rate
gen returns = (SP500 - SP500[_n-1])/  SP500[_n-1]
tsline returns 


*like white noise
ac returns,lags(100)


*first differences
gen dSP500 = SP500 - SP500[_n-1]
tsline dSP500
ac dSP500, lag(100)

*--------------------------------------------------
* Bonus 2: CPI monthly
*--------------------------------------------------

*Download CPI monthly  inflation (both index, Y,  and percentage changes, d log Y)  
*1970-2022 https://fred.stlouisfed.org/series/CPIAUCSL . 
*Note that Index is trending upwards, but after doing percentage changes ... 
* ... it wiggles around the mean.

import delimited "data\CPIAUCSL.csv",clear

*time format
generate date1 = date(DATE, "YMD")
gen date2 = date1
format date2 %td
tsset date2

rename cpilfesl y
ac y, lags(200)

*two ways to calculate percentage change
gen logy = log(y)
gen dlogy = logy - logy[_n-1]
gen pcy = (y-y[_n-1])/y[_n-1]
tsline dlogy pcy

tsline y

ac logy, lags(200)

*For CPI percentage changes compute mean  and AC function. How many AC lags are *statistically significant?

sum dlogy
ac dlogy, lag(70)

*Compute differences in CPI percentage changes, dd log Y, make TS plot. How many AC lags are statistically for dd log Y ?

gen ddlogy = dlogy - dlogy[_n-1]
tsline ddlogy
ac ddlogy, lag(500)

*Computing first differences to try to get a stationary process
gen dy = y - y[_n-1]	
tsline dy
ac dy
	
gen ddy = dy - dy[_n-1]	
tsline ddy
ac ddy

// For an insight of why we would want a stationary process, please check
// your textbook and
// https://www.tylervigen.com/spurious-correlations

*===========================================================
log close 

/*
Loose ends:
- Why we need confidence intervals for autocorrelogram?
*/
