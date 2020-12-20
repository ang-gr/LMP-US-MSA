clear all
set more off

global workdir ".."
global gphdir "$workdir/fig"
global data "$workdir/dta"

use "$data/workfile7015_all"

tsset year
gen change_low=(shempl_low[_n]-shempl_low[_n-1])*100
gen change_mid=(shempl_mid[_n]-shempl_mid[_n-1])*100
gen change_high=(shempl_high[_n]-shempl_high[_n-1])*100

replace change_low=change_low*10/16 if year==2016
replace change_mid=change_mid*10/16 if year==2016
replace change_high=change_high*10/16 if year==2016
drop if year==1970
drop shempl*

save "$data\change\change7015_all", replace
