// Review of what people have done in sections

// Armando:
// 	W4 0207 -- time-series intro 
// 	W5 0214 -- contemporaneous regression, adding different lags, bgf test
// 	W6 0221 -- dfuller test

// Zhiran:
// 	D3 -- tobit & heckit, bootsrap, 
// 	D4 -- rd & dd, using foreach, 
// 	D6
// 	D7
// 	D8
// 	D9

// My Plan:
// W2 0120 --
//	linear and nonlinear models
//	i will do tobit next week

// W3 0127 --
//	tobit
//	heckit
//	bootstrap -- didn;t cover

// W4 0203 -- 
// 	loops (foreeach)
// 	macros?
// 	rd
// 	dd
//	using outreg to append results to a table

// W5 0210 --
*	done
// W6 0217 --
* 	done

*------------------------------
*------------------------------
*------------------------------

// W7 0224 --

// zhiran discussion 6 is the base
// 	see what you can add from
// 		armando code feb 07, feb 14, feb 21
// 		zhiran d7 or d8


*Edited by Zhiran
*Refer to Armando's code
*Fixed Effect Example Code and Homework Hints
* intro to time series
*   white noise, AR(1), MA(1)
* sp 500 application
* cpi monthly application
* sesoanl patterns
* bgf test


* armando 0207 and 0214



// W8  0303
*

// W9  0310
* 

// W10 0317
	*exam?




*--------------------------------------------------
* Probability Models Armando
*--------------------------------------------------

*let us work with some linear probability models
	*Prob of finishing a bachelor's degree vs composite cognitive ability test
	reg EDUCBA  ASVABC, robust
	sum ASVABC, detail
	display 0.2566+0.1746*0.3341
	display 0.2566+0.1746*1.9718
	display 0.2566+0.1746*(-2.2188)
	
	*Does the last predicted probability make sense? No, it yields a negative probability
		predict prob_linear, xb	
		ount if prob_linear>1
		count if prob_linear<0
		count if missing(prob_linear)
	*Show the predicted probability graphically
		twoway (scatter prob_linear ASVABC)
	
*let us move to non-linear probability models				
	*Non-linear probability models map the dependent variables using a function
	* whose range lies between zero and one.
		
	*PROBIT: The function used for mapping is the cumulative distribution
	*		of a normal.
	probit EDUCBA  ASVABC, robust 
		*Compare results with Linear Probability Model
	
	*Computing marginal effects
		*Marginal effects are evaluated at the mean, by default
		mfx compute, dydx
		*Marginal effects evaluated at a different point
			*At 75 percentile
			mfx compute, dydx at (0.8584 1)
			*At 25 percentile
			mfx compute, dydx at (-0.2895 1)
			
		*Alternative way
			
		*Predict Probability
		h nlcom
		h norm
			*At 75 percentile
			nlcom norm(_b[ASVABC]*0.8584 + _b[ _cons])
			*At 1 percentile
			nlcom norm(_b[ASVABC]*-2.2188 + _b[ _cons])
			*Generate variable that predicts for every observation
			predict prob_probit
			twoway (scatter prob_probit ASVABC)
			


		*How do the models compare?
		twoway (scatter prob_probit ASVABC) (scatter pffrob_linear ASVABC) (scatter EDUCBA ASVABC)
		
		probit EDUCBA  ASVABC, robust
		ereturn list
		display  e(rmse)
		*0.42946007
		
		reg EDUCBA  ASVABC, robust
		display  e(rmse)
		
		
*********************************************
*****part3: Tobit  ************************
*********************************************

*Censored Data Generation (Monte Carlo Method):
clear all
set obs 50
gen X=_n+10
gen U=rnormal(0,10)
gen Ystar=-40+1.2*X+U
gen Y= Ystar*(Ystar>0)

scatter Y X if Y>0 || lfit Y X if Y>0|| lfit Ystar X, ///
legend(label(1 "Y")  label(2 "Truncated Regression")  label(3 "True Regression Relationship") )
regress Y X if Y>0

*Tobit model
tobit Y X, ll(0)  vce(robust)
tobit Y X, ll(0)  robust
*vce is just variance-covariance matrix of the estimators







//est


*Perform a linear regression of grad (Yi ) on ASVABC (Xi )
reg grad ASVABC
reg grad ASVABC,robust

*use estout to generate nice tables
*ssc install estout, replace

*To create nice LATEX/Doc tables we can use this command
*If you do not want/need Latex output, just erase the commands.
eststo clear
eststo: quietly regress grad ASVABC, robust
eststo: quietly logit grad ASVABC
*Displays the .tex table in Stata
esttab, se ar2
*Exports the table in .tex format
esttab using "`my_path'q_1_1_reglinresults.tex", se ar2 replace
esttab using "`my_path'q_1_1_reglinresults.rtf", se ar2 replace

browse


*==============================================================================


*********************************************
*****part3: Logit & Probit ************
*********************************************


*How can we draw CDFs and PDFs in Stata?
gen Z=rnormal(0) 
/* this generates a normal random variable, you could also
generate a uniform using ‘gen Z=runiform(-3,3)’*/

*CDF
gen Z_cdf_logit=1/(1+exp(-Z)) 
gen Z_cdf_probit=normal(Z) 
sort Z 
line Z_cdf_logit Z||line Z_cdf_probit Z 

*PDF
gen Z_pdf_logit=exp(-Z)/(1+exp(-Z))^2
gen Z_pdf_probit=normalden(Z)
sort Z
line Z_pdf_logit Z||line Z_pdf_probit Z

*models
logit grad ASVABC
probit grad ASVABC

