
clear all
set more off

global workdir ".."
global gphdir "$workdir/fig"
global data "$workdir/dta"

use "$data/change/change_9015_US_nopublic", clear


*** Rank & Group MSAs 
sort pop2015
gen sumpop2015 = sum(pop2015)
egen total_pop2015 = total(pop2015)
di 0.129*total_pop2015
* old:29,525,326
* 25,974,883
* us: 27609957
gen small_city = 0
replace small_city = 1 if sumpop2015<=27700000


gsort -pop2015
gen sumpop2015_h2l = sum(pop2015)
di 0.582*total_pop2015
* old:1.332e+08
* 1.172e+08
* us: 1.246e+08
gen big_city = 0
replace big_city = 1 if sumpop2015_h2l<=1.25e+08

di 27700000/total_pop2015 //12.9%
di 1.25e+08/total_pop2015 //58.5%
*di 2.96e+07/total_pop2015 //12.9%
*di 1.34e+08/total_pop2015 //58.5%

keep if  big_city == 1 | small_city == 1
rename big_city city_thresh

*** T-test
*mean change_high [w = pop2015] if city_thresh==1
*est store llcc1

*mean change_mid [w = pop2015] if city_thresh==1
*est store llcc2

*mean change_low [w = pop2015] if city_thresh==1
*est store llcc3

*estout llcc1 llcc2 llcc3 using "F:\STATA\MSA_test\changes_popw15_large_pcs.rtf", append cells(b transpose) style(tab) legend label collabels(, none) varlabels(_cons CONSTANT) posthead("") prefoot("") postfoot("")  

*mean change_high [w = pop2015] if city_thresh==0
*est store sscc1

*mean change_mid [w = pop2015] if city_thresh==0
*est store sscc2

*mean change_low [w = pop2015] if city_thresh==0
*est store sscc3

*estout sscc1 sscc2 sscc3 using "F:\STATA\MSA_test\changes_popw15_small_pcs.rtf", append cells(b transpose) style(tab) legend label collabels(, none) varlabels(_cons CONSTANT) posthead("") prefoot("") postfoot("")  


*drop if cbsa == 35620 | cbsa == 31080

eststo: reg change_high city_thresh [w = pop2015], robust
//est store rr1

eststo: reg change_mid city_thresh [w = pop2015], robust
//est store rr2

eststo: reg change_low city_thresh [w = pop2015], robust
//est store rr3

esttab using ttest9015_USborn_nopublic.rtf, se r2 star(* 0.10 ** 0.05 *** 0.01) replace   //Word
*esttab using ttest9015_nopublic.rtf, se r2 star(* 0.10 ** 0.05 *** 0.01) replace   //Word

//estout rr1 rr2 rr3  using ".rtf", append cells(b(star fmt(%9.4f)) t(par fmt(%9.2f) abs) se(par fmt(%9.4f) abs)) stats(N N_clust F r2, fmt(%9.0f %9.0f %9.4f %9.4f)) starlevels(* 0.10 ** 0.05 *** 0.01) style(tab) legend label collabels(, none) varlabels(_cons CONSTANT) posthead("") prefoot("") postfoot("")  

//est clear









