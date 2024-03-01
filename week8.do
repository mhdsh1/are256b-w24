*--------------------------------------------------
*ARE 256b W24 -- Week Xm1
*weekXm1.do
*Feb/29/2024
*Mahdi Shams (mashams@ucdavis.edu)
*Based on Bulat's Slides, and previous work by Armando Rangel Colina & Zhiran Qin
*This code is prepared for the week 7 of ARE 256B TA Sections. 
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

*Only check data before the pandemic
*till Feb 14th, 2020
*keep if date<21960

tsline log_sp500


reg log_sp500 L1.log_sp500


*testing against rho=1
* find the tstat
*dis (1/se)*(rhoh -1) 


*unit root
* Dealing Nonstationary Time Series: Taming the Tiger
*calculate daily returns/ first difference

gen dlog_sp500 = log_sp500 - log_sp500[_n-1]
tsline dlog_sp500

ac dlog_sp500, lags(200)


*--------------------------------------------------
* Section Time Trend
*--------------------------------------------------

*use S&P 500 index data

tsline sp500

*Only check data before the pandemic
*till Feb 14th, 2020
*keep if date1<21960

*detrend
reg log_sp500 date
predict uhat, residuals
tsline uhat
ac uhat, lags(200)

reg L(0/1).log_sp500 L(0/1).date
predict yhat2
tsline yhat2 log_sp500



*Breusch-Godfrey test
reg log_sp500 date
estat bgodfrey, lags(1)


*Correction for AR(1) in u
reg L(0/1).log_sp500 L(0/1).date
predict uhat2, residuals
ac uhat2
estat bgodfrey, lags(1)


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
*alpha_y / alpha_x =2



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












*===========================================================
log close 
