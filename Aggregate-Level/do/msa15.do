*** Aggregate ***
*** Treat 2014-2016 Census ***
clear all
set more off

global workdir ".."
global gphdir "$workdir/fig"
global data "$workdir/dta"

use "$data/usa_2015"

/*1. Filter dataset for persons aged 16 to 64 who worked at least 
one week in the earnings years, excluding those in the military*/
drop if age < 16
drop if age > 64
drop if wkswork2<1

** Choice: only US-born
keep if bpl<100

** Choice: exclude government workers
*drop if classwkrd == 24 | classwkrd == 25 | classwkrd ==26 | classwkrd ==27 | classwkrd ==28
*keep if classwkrd == 22 //only private employees

replace year = 2015 if year == 2014 | year == 2016

/*2. Merge Autor's occ1990dd to the dataset*/
replace occ = occ/10
merge m:1 occ using "$data/occ/occ2005_occ1990dd", keep(match) nogenerate
merge m:1 occ1990dd using "$data/occ/occ1990dd_pcs", keep(match) nogenerate

* Categories Dummies
gen occ_high=0
replace occ_high=1 if (pcs==23 | pcs==37 | pcs==38 | pcs==35 | pcs==31)
gen occ_mid=0
replace occ_mid=1 if (pcs == pcs==48 | pcs==46 | pcs==47 | pcs==43 | pcs==62 ///
| pcs==54 | pcs==65 | pcs==63 | pcs==64 | pcs==67)
gen occ_low=0
replace occ_low=1 if (pcs == 53 | pcs==55 | pcs==56 | pcs==68)

drop if pcs==.

/*3. employment share*/
replace wkswork2 = 7 if wkswork2==1
replace wkswork2 = 20 if wkswork2==2
replace wkswork2 = 33 if wkswork2==3
replace wkswork2 = 43.5 if wkswork2==4
replace wkswork2 = 48.5 if wkswork2==5
replace wkswork2 = 51 if wkswork2==6

gen totwrkhr_indi = wkswork2*uhrswork*perwt
gen totwrkhr_high = totwrkhr_indi*occ_high
gen totwrkhr_mid = totwrkhr_indi*occ_mid
gen totwrkhr_low = totwrkhr_indi*occ_low

collapse (sum) totwrkhr=totwrkhr_indi totwrkhr_high=totwrkhr_high ///
totwrkhr_mid=totwrkhr_mid totwrkhr_low=totwrkhr_low, by (year)

gen shempl_high = totwrkhr_high/totwrkhr
gen shempl_mid = totwrkhr_mid/totwrkhr
gen shempl_low = totwrkhr_low/totwrkhr
gen shempl = shempl_high+shempl_mid+shempl_low

drop totwrkhr totwrkhr_high totwrkhr_mid totwrkhr_low

save "$data\shempl\shempl_2015", replace

/*4. Append together*/
append using "$data\shempl\shempl_1970"
append using "$data\shempl\shempl_1980"
append using "$data\shempl\shempl_1990"
append using "$data\shempl\shempl_2000"

sort year
* save "$data\workfile7015_all", replace
* save "$data\workfile7015_nopub", replace
save "$data\workfile7015_US", replace

/*5. Calculate changes */
* use "$data/workfile7015_all", clear
* use "$data\workfile7015_nopub", clear

tsset year
gen change_low=(shempl_low[_n]-shempl_low[_n-1])*100
gen change_mid=(shempl_mid[_n]-shempl_mid[_n-1])*100
gen change_high=(shempl_high[_n]-shempl_high[_n-1])*100

replace change_low=change_low*10/16 if year==2015
replace change_mid=change_mid*10/16 if year==2015
replace change_high=change_high*10/16 if year==2015
drop if year==1970
drop shempl*

save "$data\change\change7015_all", replace
save "$data\change\change7015_US", replace
save "$data\change\change7015_nopub", replace
save "$data\change\change7015_nopub_US", replace

