*** Aggregate ***
*** Treat 1970 Census with Loop ***
clear all
set more off

global workdir ".."
global gphdir "$workdir/fig"
global data "$workdir/dta"

use "$data/usa_1970"

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

/*2. Merge Autor's occ1990dd to the dataset then match to the PCS codes*/
merge m:1 occ using "$data/occ/occ1970_occ1990dd", keep(match) nogenerate
merge m:1 occ1990dd using "$data/occ/occ1990dd_pcs", keep(match) nogenerate

* Categories Dummies
gen occ_high=0
replace occ_high=1 if pcs==23 | pcs==37 | pcs==38 | pcs==35 | pcs==31
gen occ_mid=0
replace occ_mid=1 if pcs == pcs==48 | pcs==46 | pcs==47 | pcs==43 | pcs==62 ///
| pcs==54 | pcs==65 | pcs==63 | pcs==64 | pcs==67
gen occ_low=0
replace occ_low=1 if pcs == 53 | pcs==55 | pcs==56 | pcs==68

drop if pcs==.

/*3 employment share*/

replace wkswork2 = 13 if wkswork2==1
replace wkswork2 = 26 if wkswork2==2
replace wkswork2 = 39 if wkswork2==3
replace wkswork2 = 47 if wkswork2==4
replace wkswork2 = 49 if wkswork2==5
replace wkswork2 = 52 if wkswork2==6

replace hrswork2 = 14 if hrswork2==1
replace hrswork2 = 29 if hrswork2==2
replace hrswork2 = 34 if hrswork2==3
replace hrswork2 = 39 if hrswork2==4
replace hrswork2 = 40 if hrswork2==5
replace hrswork2 = 48 if hrswork2==6
replace hrswork2 = 59 if hrswork2==7
replace hrswork2 = 60 if hrswork2==8


gen totwrkhr_indi = wkswork2*hrswork2*perwt
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

save "$data\shempl\shempl_1970", replace
