*----------------------------------------------------------------------------*
*Cenosred data and the Tobit model
*----------------------------------------------------------------------------*

*Censored Data Generation (Monte Carlo Method):
clear all
set obs 50
gen X=_n+10
gen U=rnormal(0,10)
gen Ystar=-40+1.2*X+U
gen Y= Ystar*(Ystar>0)

scatter Y X if Y>0 || lfit Y X if Y>0|| lfit Ystar X, ///
legend(label(1 "Y")  ///
label(2 "Truncated Regression")  ///
label(3 "True Regression Relationship") )

regress Y X if Y>0

*the truncated regression slope is biased (slide 77)
*one soltion is Tobit model
*ll() argument isleft-censoring limit i.e. 
* We only observe Y_i > 0 in this regression. 
tobit Y X, ll(0)  robust


*----------------------------------------------------------------------------*
* presentation: exporting tables
*----------------------------------------------------------------------------*
/*
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
*/
