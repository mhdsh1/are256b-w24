*--------------------------------------------------
*ARE 256B W24 -- SECTION 3
*week3.do
*1/26/2024
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
log using week3,replace         // Open log file
*--------------------------------------------------

*----------------------------------------------------------------------------*
* Section 1: Censoring 
*----------------------------------------------------------------------------*

*** Censored Data Generation (Monte Carlo Method):
clear all
set obs 50
* generating a new var X ranging from 11 to 60
gen X=_n+10
browse
* now we generate the error term assuming normal distribution
* it's good to set seed before generating any random var
set seed 2023
gen U=rnormal(0,10)

browse

gen Ystar=-40+1.2*X+U
browse

gen Y= Ystar*(Ystar>0)
// Stata trick: the term in the parantheses works as a conditional
// any conditional term in Stata is either 0 when false or 1 when true. 
// gen Y= Ystar
// replace Y = 0 if Ystar <= 0



scatter Y X if Y>0 || lfit Y X if Y>0|| lfit Ystar X, ///
legend(
    label(1 "Y")  ///
    label(2 "Truncated Regression") /// 
    label(3 "True Regression Relationship") )

graph export graphs/censored.png, replace

// help export graph 

regress Y X if Y>0

tobit Y X, ll(0)  robust

// check help tobit

*vce represents variance-covariance matrix of the estimators
tobit Y X, ll(0)  vce(robust)

*----------------------------------------------------------------------------*
* Section 2: Sample Selection
*----------------------------------------------------------------------------*

use "http://fmwww.bc.edu/ec-p/data/wooldridge/mroz.dta", clear
* more info on data http://fmwww.bc.edu/ec-p/data/wooldridge/mroz.des
gen exper2=exper^2

browse

*We want to understand the effect of education and experience on wage
* but we only observe earning for EMPLOYED individuals.
*We don't know who is employed
* but we may be able to model employment statuts (B) based on what we observe
*We suppose B is explained by the total income of hh, age, and number of kids.  
*... and probably they have negative effect on someoene being employed

*method 1: Heckman two stage model

*stage 1: finding the probit model 
gen B=1
replace B=0 if lwage==.
* modeling employment status
probit B nwifeinc age kidslt6 kidsge6


gen z=_b[nwifeinc]*nwifeinc+_b[age]*age+_b[kidslt6]*kidslt6 +_b[kidsge6]*kidsge6 + _b[_cons]
gen lambda_hat=normalden(z)/normal(z)

*stage 2: 
reg lwage educ exper exper2 lambda_hat


*method 2: using heckman command (ML Estimation)
heckman lwage educ exper exper2, select(nwifeinc age kidslt6 kidsge6)

*----------------------------------------------------------------------------*
* Section 3: exporting tables
*----------------------------------------------------------------------------*

*use estout to generate nice tables
ssc install estout, replace

*To create nice LATEX/Doc tables we can use this command
*If you do not want/need Latex output, just erase the commands.
eststo clear
eststo model_l: quietly regress EDUCBA  ASVABC, robust 
eststo model_p: quietly probit EDUCBA  ASVABC, robust 

esttab model_l


esttab model_l using graphs/model_l.rtf, replace ///
se onecell width(\hsize) ///
addnote() ///
label title(Estimation Result of Linear Model)

*----------------------------------------------------------------------------*
* Bonus: Drawing CDFs and PDFs
*----------------------------------------------------------------------------*

*How can we draw CDFs and PDFs in Stata?
gen Z=rnormal(0) 
/* this generates a normal random variable, you could also
generate a uniform using ‘gen Z=runiform(-3,3)’*/

*CDF
* the distribution used for logit is called LOGISTIC
gen Z_cdf_logit=1/(1+exp(-Z)) 
gen Z_cdf_probit=normal(Z) 
sort Z 
line Z_cdf_logit Z||line Z_cdf_probit Z 

*PDF
gen Z_pdf_logit=exp(-Z)/(1+exp(-Z))^2
gen Z_pdf_probit=normalden(Z)
sort Z
line Z_pdf_logit Z||line Z_pdf_probit Z



*----------------------------------------------------------------------------*
*----------------------------------------------------------------------------*

log close

translate "$path\week3.smcl" ///
          "$path\week3.pdf", translator(smcl2pdf)

exit