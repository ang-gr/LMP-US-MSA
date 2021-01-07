*** Append Datasets ***

clear all
set more off

global workdir ".."
global gphdir "$workdir/fig"
global data "$workdir/dta"

use "$data/shempl/shempl_1980", clear
append using "$data/shempl/shempl_1990"
append using "$data/shempl/shempl_2000"
append using "$data/shempl/shempl_2015"

merge m:1 cbsa using "$data/pop2015", keep(match) nogenerate
replace pop2015=log(pop2015)
rename year yr
sort cbsa yr

save "$data/workfile9015_all"
