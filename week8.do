*--------------------------------------------------
*ARE 256b W24 -- Week 8
*week8.do
*Mar/1/2024
*Mahdi Shams (mashams@ucdavis.edu)
*Based on Bulat's Slides, and previous work by Armando Rangel Colina & Zhiran Qin
*This code is prepared for the week 8 of ARE 256B TA Sections. 
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
log using week7, replace // Open log file
*--------------------------------------------------

*set working directory 
global path = "C:\Users\mahdi\are256b-W24"
cd $path


*--------------------------------------------------
* Section Random Walk
*--------------------------------------------------

*use S&P 500 index data
import excel "data/SP500.xls", firstrow clear 


rename DATE date
rename SP500 sp500
destring sp500, replace

*we use "format" to make date readable
format date %td
tsset date


tsline sp500

gen log_sp500 = log(sp500)
tsline log_sp500


reg log_sp500 L1.log_sp500


*testing against rho=1 -- The Naive approach
* we should avoid doing this and do DF test instead
* find the tstat
*dis (1/se)*(rhoh -1) 
dis (1/.0022345)*abs(.9972702  -1) 

// t-stat is smaller than 1.96 ... should we conclude that it is non-stationary?
// no, because if the process is non-stationary the t-stat is not normally-
// distributed anymore

dfuller log_sp500, regress
// we can not reject the null of non-stationarity with df-test

*unit root
* Dealing Nonstationary Time Series: Taming the Tiger
*calculate daily returns/ first difference

gen dlog_sp500 = log_sp500 - log_sp500[_n-1]
tsline dlog_sp500

ac dlog_sp500, lags(200)

dfuller dlog_sp500, regress

****************
*** DF TEST ****
****************

clear
	import excel "data/section_timeseries.xlsx", firstrow clear 

	*For some reason there STATA is reading some missing data at the end, we'll just get rid of it
	drop if date_ == "" 

*Create a running variable.
	generate time_ =[_n]
*Tell STATA that the time structure is based on the variable called time_
	tsset time_		
	
	*China's exchange rate vs USD
		twoway (line apple_stock time_)	
		
		dfuller apple_stock, regress
		
		*Testing for an AR(2) process with drift
		dfuller apple_stock, lags(2) drift
		
		
		*Data transformation to try and eliminate  non-stationarity
		gen log_apple =  log(apple_stock)
		gen d1_log_apple =  log_apple-log_apple[_n-1]
		twoway (line d1_log_apple time_)	
		dfuller d1_log_apple
	
* how to read the tests?
* Instead of rejecting H0 at the significance level α if T > c, 
* we can reject H0 if p < α.


*--------------------------------------------------
* Section  Spurious Regression 
*--------------------------------------------------

*time trend
reg log_sp500 date
predict yhat
tsline yhat log_sp500


*we have find one trend
tsline yhat log_sp500

*generate another time series data containing trend
gen e = rnormal(0,1)
gen C = 1 + 0.0025 * date + e

*spurious regression
reg log_sp500 C


*another example
gen ex = rnormal(0,1)
gen ey = rnormal(0,1)
*alpha_y = 1.6
*alpha_x = 0.8 
gen X = 1 + 0.8 * date + ex
gen Y = 0.2 + 1.6 * date + ey

reg Y X
*comapare with alpha_y / alpha_x =2



*--------------------------------------------------
* Section  CPI monthly
*--------------------------------------------------

 

*Download CPI monthly  inflation (both index, Y,  and percentage changes, d 
* log Y)  
*1970-2022 https://fred.stlouisfed.org/series/CPILFESL . 
* Discuss that Index is *trending upwards, but after doing percentage changes,
* it wiggles around the mean.


import excel "data/CPIAUCSL.xls", firstrow clear 

rename DATE date
rename CPIAUCSL y

format date %td
tsset date


*extract month and year
gen mth = month(date) 
gen yr = year(date)

*generate a new monthly time index
gen month = ym(yr,mth)
format month %tm
tsset month

*or
*gen mdate = mofd(date2)
*format mdate %tm

tsline y

ac y, lags(200)

*two ways to calculate percentage change, which is actually inflation
gen logy = log(y)
gen dlogy = logy - logy[_n-1]
gen pcy = (y-y[_n-1])/y[_n-1]
tsline dlogy pcy


ac logy, lags(200)

*For CPI percentage changes compute mean  and AC function. 
* How many AC lags are *statistically significant?

sum dlogy
ac dlogy, lag(400)


* Compute differences in CPI percentage changes, dd log Y, make TS plot. 
* How many AC lags are statistically for dd log Y ?
* Computing first differences to try to get a stationary process

gen ddlogy = dlogy - dlogy[_n-1]
tsline ddlogy
ac ddlogy, lag(500)


*For an insight of why we would want a stationary process, please check
*your textbook and
* https://www.tylervigen.com/spurious-correlations






log close 
