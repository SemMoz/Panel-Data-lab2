clear
clear mata
set mem 200m

cd ""

use hrs_dynamic

xtset hhidpn wave
sort hhidpn wave



*** Question 1: Produce summary statistics and tabulate the values of dsmokenow
sum age female yearseducation smokenow dsmokenow healthfair healthgood  hverygood hexcellent 
tab dsmokenow


*** Question 2: Regress smokenow on smokenow in the previous period, the health dummies, and age using the ordinary least squares estimator.
gen smokenowlag = smokenow[_n-1]
reg smokenow smokenowlag healthfair healthgood hverygood hexcellent age,cluster(hhidpn)


*** Question 3: Now include female and yearseducation as additional regressors.
reg smokenow smokenowlag healthfair healthgood hverygood hexcellent age female yearseducation, cluster(hhidpn)

xtsum female yearseducation
* xtsum illustrates that there is no within variation in the variables age and female


*** Question 4: Perform fixed effects estimation.
xtreg smokenow l.smokenow healthfair healthgood hverygood hexcellent age female yearseducation, fe cluster(hhidpn)	


*** Question 5: calculate the dynamic panel bias if the true estimator of smokenowlag is equal to 0.2, 0.4, 0.6, 0.8, and T = 3.3 (average number of time periods)

#delimit ;	
local  Tbar = 3.3 ;         
forvalues gamma = 0.2(0.2)0.8 { ;
local j : display %2.1f `gamma' ; 
di "the bias for a true gamma = `j' is"
-(((1+`gamma')/(`Tbar'-1))*(1-(1/`Tbar')*((1-`gamma'^`Tbar')/
(1-`gamma'))))	
/[1-((2*`gamma')/((1-`gamma')*(`Tbar'-1)))*(1-(1-`gamma'^`Tbar')/(`Tbar'*(1-
`gamma')))]; 	
};
#delimit cr
* we see that the dynamic panel bias becomes worse as if the true estimator of smokenowlag increases 


*** Question 6: Now perform a regression using first differences of the dependent and the explanatory variables.
reg dsmokenow ld.smokenow d.healthfair d.healthgood d.hverygood d.hexcellent d.age, cluster(hhidpn)


*** Question 7: Continue using first-differenced data but use an instrumental variables approach. Run one IV regression with yit−2 as instrument and one with yit−2 − yit−3 as instrument.

ivreg dsmokenow (l.dsmokenow=l2.dsmokenow) d.healthfair d.healthgood d.hverygood d.hexcellent d.age, cluster(hhidpn) 
	
ivreg dsmokenow (l.dsmokenow=l2.smokenow) d.healthfair d.healthgood d.hverygood d.hexcellent d.age, cluster(hhidpn) 


*** Question 8: Now use the Arellano-Bond estimator (command: xtabond2. Implement the one-step and the two-step estimator and compare the results. 

xtabond2 smokenow l.smokenow healthfair healthgood hverygood hexcellent age, gmm(l.smokenow) ivstyle(age healthfair healthgood hverygood hexcellent) nolevel robust nodiff 

xtabond2 smokenow l.smokenow healthfair healthgood hverygood hexcellent age, gmm(l.smokenow) ivstyle(age healthfair healthgood hverygood hexcellent) nolevel robust nodiff twostep


* if we assume that all variables are endogenous
xtabond2 smokenow l.smokenow healthfair healthgood hverygood hexcellent age, gmm(l.smokenow healthfair healthgood hverygood hexcellent age) nolevel robust nodiff 

xtabond2 smokenow l.smokenow healthfair healthgood hverygood hexcellent age, gmm(l.smokenow healthfair healthgood hverygood hexcellent age) nolevel robust nodiff twostep



*** Question 9: Estimate the model using as many lags as possible by ordinary least squares and Arellano-Bond, respectively
reg smokenow l.smokenow l2.smokenow l3.smokenow healthfair healthgood  hverygood hexcellent age, cluster(hhidpn)	
	
xtabond2 smokenow l.smokenow l2.smokenow l3.smokenow healthfair healthgood hverygood hexcellent age, gmm(l.smokenow healthfair healthgood hverygood hexcellent age) nolevel robust nodiff twostep
	




