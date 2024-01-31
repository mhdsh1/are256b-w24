*--------------------------------------------------
*ARE 256B W24 -- SECTION 2
*week2.do
*1/19/2024
*Mahdi Shams (mashams@ucdavis.edu)
*Based on Bulat's Slides, and previous work by Armando Rangel Colina & Zhiran 
* Qin. This code is prepared for the second week of ARE 256B. Here codes 
* related to linear models, nonliniear models (probit), the way to compare 
* models based on rmse is reviewed. Also, there is a discussion of how to make
* logfiles, exporting graphs, and outputting regression tables with estout 
* package. 
*--------------------------------------------------

*set working directory 
global path "C:\Users\mahdi\are256b-w24"
cd $path

*--------------------------------------------------
*Program Setup
*--------------------------------------------------
version 14              // Set Version number for backward compatibility
set more off            // Disable partitioned output
clear all               // Start with a clean slate
set linesize 80         // Line size limit to make output more readable
macro drop _all         // clear all macros
capture log close       // Close existing log files
log using week2,replace         // Open log file
*--------------------------------------------------

*open a .dta (Stata) file
*we use clear to reaplce the new dataset with the former one
use "data\EAWE01.dta", clear 

*----------------------------------------------------------------------------*
* section 1: linear model
*----------------------------------------------------------------------------*

*let us work with some linear probability models
*P(Y_i=1|X_i) = \beta X_i + \epsilon_i 
*Prob of finishing a bachelor's degree vs composite cognitive ability test

reg EDUCBA  ASVABC, robust

* calcualting the \hat{Y}_i = \hat{\beta}X_i for some values of X_i

sum ASVABC, detail

display 0.2566+0.1746*0.3341
display 0.2566+0.1746*1.9718
display 0.2566+0.1746*(-2.2188)

* alternative way to calculate the predicted probability
display _b[_cons]+_b[ASVABC]*0.3341
display _b[_cons]+_b[ASVABC]*1.9718
display _b[_cons]+_b[ASVABC]*(-2.2188)

*Does the last predicted probability make sense? 
* No, it yields a negative probability

*let's find the fitted values for all the observations
*\hat{Y}_i = \hat{\beta}X_i
*command predict yields the fitted values for all the observations 
* based on the "latest" model ran 
help predict // like ? predict in R
predict EDUCBA_hat, xb	

browse EDUCBA EDUCBA_hat

count if EDUCBA_hat>1
count if EDUCBA_hat<0
count if missing(EDUCBA_hat)

*Show the predicted probability graphically
twoway scatter EDUCBA_hat ASVABC
graph export graphs/linear.png, replace

*----------------------------------------------------------------------------*
* sction 2: nonlinear model
*----------------------------------------------------------------------------*

*let us move to non-linear probability models
*Non-linear probability models map the dependent variables using a function
*whose range lies between zero and one.

*PROBIT: The function used for mapping is the cumulative distribution
*of a normal.
*P(Y_i=1|X_i) = \Phi(\beta X_i + \epsilon_i) 

probit EDUCBA  ASVABC, robust 
*Compare results with Linear Probability Model

*----------------------------------------------------------------------------*
* section 3: computing marginal effects 
*----------------------------------------------------------------------------*

*Computing marginal effects
*Look at Slides 68-69 for definitions
*Average Margnal Effect
margins, dydx(ASVABC)

*Marginal effects evaluated at the mean 
margins, dydx(ASVABC) atmeans
// alternative: mfx compute, dydx

*Marginal effects evaluated at a different point
margins, dydx(ASVABC) at(ASVABC=0.1)
margins, dydx(ASVABC) at(ASVABC=0.6)


// what does margins alone do?

*Predict Probability
*\hat{Y}_i = \Phi{\hat{\beta}X_i}

*calculating the predicted probability
h nlcom
h norm
*At 75 percentile
nlcom norm(_b[ASVABC]*0.8584 + _b[ _cons])
*At 1 percentile
nlcom norm(_b[ASVABC]*-2.2188 + _b[ _cons])

*Generate variable that predicts for every observation
predict EDUCBA_probit_hat
browse EDUCBA EDUCBA_hat EDUCBA_probit_hat
twoway (scatter EDUCBA_probit_hat ASVABC)

*----------------------------------------------------------------------------*
* section 4: model comparison based on rmse 
*----------------------------------------------------------------------------*

*How do the models compare? (linear vs probit)
twoway (scatter EDUCBA_probit_hat ASVABC) ///
       (scatter EDUCBA_hat ASVABC) ///
       (scatter EDUCBA ASVABC)

*We use root mean squared error (rmse) concept to compare 
*rmse = sqrt{((1/n)*(\Sigma{(Y_i - \hat{Y_i})^2})}
* look at slide 65

gen sqerror        = (EDUCBA - EDUCBA_hat)^2
gen sqerror_probit = (EDUCBA - EDUCBA_probit_hat)^2


qui summarize sqerror 
di r(mean)^0.5

qui summarize sqerror_probit
di r(mean)^0.5

* taking a random subsample *


*Check https://www.stata.com/support/faqs/statistics/random-samples/ for the procedure

* In HA 1 you need to calculate RMSE for five random observations:

*We are going to take a random sub-sample. To make results replicable, I want 
*to always make the exact same random draw. To achieve that, I will set a seed
* so that the "random" number generator always begins with the same draw.

set seed 2024

*We make random draws from a uniform distribution (0,1) to assign to each 
*observation
generate rand_draw = runiform()

*We will sort our observations from smallest to largest and take the first "n"
*. This is how I randomize our sample of size "n", in this case n=5. That is, 
*I randomly assign the number one to some observations. 

sort rand_draw

// the first five observations are chosen to be in our subsample
generate chosen = _n <= 5

browse rand_draw 

*Now we can call caluclate the rmse for the subsample of five observations

qui summarize sqerror if chosen==1
di r(mean)^0.5

qui summarize sqerror_probit if chosen==1
di r(mean)^0.5


*----------------------------------------------------------------------------*
*----------------------------------------------------------------------------*

log close // Close the log, end the file

global path "C:\Users\mahdi\are256b-w24"
cd $path

translate "$path\week2.smcl" ///
          "$path\week2.pdf", translator(smcl2pdf)

exit

/*Loose Ends:
- drawing CDFs and PDFs in Stata? (Slide 41)
*/
