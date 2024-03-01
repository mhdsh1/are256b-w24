*==============================================================================
*ARE 256B SECTION 8
*Date: Feb 25th, 2022

*Edited by Zhiran
*Nonstationary data
*==============================================================================


clear all
cd "/Users/c/Documents/Stata/256B2022/Discussion8/"

*********************************************
*****part1: Time Trend      ***********
*********************************************

*use S&P 500 index data
import delimited "SP500.csv",clear


*time format
generate date1 = date(date, "YMD")
gen date2 = date1
format date2 %td
tsset date2


tsline sp500

gen log_sp500 = log(sp500)
tsline log_sp500

*Only check data before the pandemic
*till Feb 14th, 2020
keep if date1<21960

tsline log_sp500

ac log_sp500, lags(200)

*time trend
reg log_sp500 date2
predict yhat
tsline yhat log_sp500


*detrend
reg log_sp500 date2
predict uhat, residuals
tsline uhat
ac uhat, lags(200)


*Breusch-Godfrey test
reg log_sp500 date2
estat bgodfrey, lags(1)



*Correction for AR(1) in u
reg L(0/1).log_sp500 L(0/1).date2
predict uhat2, residuals
ac uhat2
estat bgodfrey, lags(1)






*===============================================================


***************************************************************
*****part2: Random Walk     ******************************
***************************************************************

tsline log_sp500



*test rho=1
reg log_sp500 L1.log_sp500

dis 589*(.9999676 -1)
*  -.0190836




*unit root
*calculate daily returns/ first difference

gen dlog_sp500 = log_sp500 - log_sp500[_n-1]

tsline dlog_sp500

ac dlog_sp500, lags(200)






*===============================================================


****************************************************************
*****part3: Spurious regression     ***********
****************************************************************


*we have find one trend
tsline yhat log_sp500

*generate another time series data containing trend
gen e = rnormal(0,1)
gen C = 1 + 0.0025 * date2 + e

*spurious regression
reg log_sp500 C


*another example
gen ex = rnormal(0,1)
gen ey = rnormal(0,1)
*alpha_y = 1.6
*alpha_x = 0.8 
gen X = 1 + 0.8 * date2 + ex
gen Y = 0.2 + 1.6 * date2 + ey

reg Y X
*alpha_y / alpha_x =2