clear all
set more off

global workdir ".."
global figdir "$workdir/fig"
global gphdir "$workdir/gph"
global data "$workdir/dta"


/* 1. Calculate changes */
* use "$data/workfile9015_all"
use "$data/workfile9015_USborn_all"

merge m:1 cbsa using "$data/cityname", keep(matched) nogenerate

*drop if yr == 1990 | yr == 2000
drop if yr == 1980 | yr == 2000

** Compute Changes between 1990/1980 and 2015 **
tsset cbsa yr
bysort cbsa: gen change_low = shempl_low[_n] -  shempl_low[_n-1]
bysort cbsa: gen change_mid = shempl_mid[_n] -  shempl_mid[_n-1]
bysort cbsa: gen change_high = shempl_high[_n] -  shempl_high[_n-1]

drop if change_low ==.

rename pop2015 lnpop2015
gen pop2015 = exp(lnpop2015)

drop if change_mid>0
drop if change_high<0

*save "$data/change/change_9015_all", replace
save "$data/change/change_9015_US_all", replace


/* 2. Plot */
*use "$data/change/change_9015_all", clear
use "$data/change/change_9015_US_all", clear

*Plot Changes 1990-2015*
twoway (scatter change_high change_mid if pop2015>100000&pop2015<500000, mcolor(midgreen) msymbol(X) msize(vsmall)) ///
(scatter change_high change_mid if pop2015>500000&pop2015<2000000, msymbol(Oh) mcolor(green) msize(medium)) ///
(scatter change_high change_mid if pop2015>2000000&pop2015<7000000, mcolor(midblue) msymbol(Oh) msize(vlarge)) ///
(scatter change_high change_mid if cbsa==14460|cbsa==47900|cbsa==16740|cbsa==42660|cbsa==12580|cbsa==38060, mcolor(midblue) msymbol(Oh) mlabsize(vsmall) mlabel(name) mlabcolor(black) msize(vlarge)) ///
(scatter change_high change_mid if cbsa==41860, mcolor(midblue) msymbol(Oh)  mlabel(name) mlabposition(2) mlabcolor(black) mlabsize(vsmall) msize(vlarge)) ///
(scatter change_high change_mid if cbsa==38900|cbsa==41700, mcolor(midblue) msymbol(Oh)  mlabel(name) mlabposition(5) mlabcolor(black) mlabsize(vsmall) msize(vlarge)) ///
(scatter change_high change_mid if pop2015>7000000&pop2015<10000000, mcolor(midblue) msymbol(Oh) mlabel(name) mlabcolor(black) mlabsize(vsmall) msize(vlarge)) /// 
(scatter change_high change_mid if pop2015>10000000, mcolor(red) msymbol(Oh) mlabel(name) mlabcolor(black) mlabposition(9) mlabsize(vsmall) msize(huge)) ///
(function y=-(x), range(-0.15 0.001) lcolor(black)) (function y=-(x/2), range(-0.15 0.001) lcolor(grey) lp(dash)) ///
(function y=0, range(-0.15 0) lcolor(black) ),  xscale(range(-0.15 0) noextend) yscale(range(-0.001 0.15) noextend) ///
xtitle("Percentage point change of middle-paid") ytitle("Percentage point change of high-paid") ///
legend(rows(1) size(small) position(0) bplacement(neast) order(1 "0.1m-0.5m" 2 "0.5m-2m" 3 "2m-10m" 8 ">10m")) ///
xlabel(-0.15(0.05)0) ylabel(0(0.05)0.15) title("Percentage point change of high and middle-paid in MSAs, 1990-2015", size(medsmall) color(black)) ///
saving("$workdir/gph/Figure7_changes_9015_all.gph",replace)
graph export "$workdir/fig/Figure7_changes_9015_all.pdf",replace



*Plot Changes US-born 1990-2015*
twoway (scatter change_high change_mid if pop2015>100000&pop2015<500000, mcolor(midgreen) msymbol(X) msize(vsmall)) ///
(scatter change_high change_mid if pop2015>500000&pop2015<2000000, msymbol(Oh) mcolor(green) msize(medium)) ///
(scatter change_high change_mid if pop2015>2000000&pop2015<7000000, mcolor(midblue) msymbol(Oh) msize(vlarge)) ///
(scatter change_high change_mid if cbsa==38900|cbsa==41860|cbsa==16740|cbsa==42660|cbsa==12580|cbsa==38060|cbsa==41700|cbsa==12060, mcolor(midblue) mlabsize(vsmall) msymbol(Oh)  mlabel(name) mlabcolor(black)  msize(vlarge)) ///
(scatter change_high change_mid if cbsa==14460|cbsa==47900, mcolor(midblue) msymbol(Oh)  mlabel(name) mlabposition(4) mlabcolor(black) mlabsize(vsmall) msize(vlarge)) ///
(scatter change_high change_mid if pop2015>7000000&pop2015<10000000, mcolor(midblue) msymbol(Oh) mlabel(name) mlabposition(4) mlabcolor(black) mlabsize(vsmall) msize(vlarge)) /// 
(scatter change_high change_mid if pop2015>10000000, mcolor(red) msymbol(Oh) mlabel(name) mlabcolor(black) mlabposition(9) mlabsize(vsmall) msize(huge) ) ///
(function y=-(x), range(-0.18 0.001) lcolor(black)) (function y=-(x/2), range(-0.18 0.001) lcolor(grey) lp(dash)) ///
(function y=0, range(-0.18 0) lcolor(black) ),  xscale(range(-0.18 0) noextend) yscale(range(-0.001 0.18) noextend) ///
xtitle("Percentage point change of middle-paid") ytitle("Percentage point change of high-paid") ///
legend(rows(1) size(small) position(0) bplacement(neast) order(1 "0.1m-0.5m" 2 "0.5m-2m" 3 "2m-10m" 7 ">10m")) ///
xlabel(-0.18(0.06)0) ylabel(0(0.06)0.18) title("Percentage point change of high and middle-paid in MSAs (US-born), 1990-2015", size(medsmall) color(black)) ///
saving("$workdir/gph/Figure7_changes_9015_all_US.gph",replace)
graph export "$workdir/fig/Figure7_changes_9015_all_US.pdf",replace


*Plot Changes for only NY and LA, 1990-2015*
twoway 	(scatter change_high change_mid if pop2015>20000000, mcolor(midblue) msymbol(Oh) msize(vhuge))  (scatter change_high change_mid if pop2015<15000000, mcolor(midgreen) msymbol(Oh) msize(vhuge)) (function y=-(x), range(-0.12 0.001) lcolor(black)) (function y=-(x/2), range(-0.12 0.001) lcolor(grey) lp(dash)) (function y=0, range(-0.12 0) lcolor(black) ),  xscale(range(-0.12 0) noextend) yscale(range(-0.001 0.12) noextend) xtitle("Percentage point change of middle-paid") ytitle("Percentage point change of high-paid") legend(rows(1) size(small) position(0) bplacement(neast) order(1 "New York City" 2 "Los Angeless City")) xlabel(-0.12(0.03)0) ylabel(0(0.03)0.12) 
title("Percentage point change of high-paid and middle-paid in NYC and LA City, 1990-2015", size(small) color(black)) 
graph export "$workdir/gph/Figure7_changes_9015_NYLA.png",replace
graph export "$workdir/gph/Figure7_changes_9015_NYLA.pdf",replace		
		
/* References:		
twoway 	(scatter change_high change_mid if TDUU2015_size>50&TDUU2015_size<71, mcolor(midblue) msize(vsmall)) 
		(scatter change_high change_mid if TDUU2015_size==50, mcolor(midgreen) msymbol(X) msize(small)) 
		(scatter change_high change_mid if UU2010_c15==38701, mcolor(red) msymbol(S) mlabel(cityname) mlabp(12) mlabcolor(black) msize(small)) 
		(scatter change_high change_midS if UU2010_c15==33701, mcolor(red) msymbol(S) mlabel(cityname) mlabp(1) mlabcolor(black) msize(small)) 
		(scatter change_high change_mid if UU2010_c15==759, mcolor(red) msymbol(S) mlabel(cityname) mlabp(4) mlabcolor(black) msize(small)) 
		(scatter change_high change_mid if UU2010_c15==757|UU2010_c15==758|UU2010_c15==6701, mcolor(red) msymbol(S) mlabel(cityname) mlabp(6) mlabcolor(black) msize(small)) 
		(scatter change_high change_mid if TDUU2015_size>70&UU2010_c15!=757&UU2010_c15!=38701&UU2010_c15!=758&UU2010_c15!=33701&UU2010_c15!=759&UU2010_c15!=6701, mcolor(red) msymbol(S) mlabel(cityname) mlabcolor(black) msize(small)) 
		
		(function y=-(x), range(-20 0) lcolor(black)) 
		(function y=-(x/2), range(-22 0) lcolor(grey) lp(dash)) 
		(function y=0, range(-22 0) lcolor(black)), xsc(r(-22 0)) ysc(r(-3 19)) xtitle("Percentage point change of middle-paid") ytitle("Percentage point change of high-paid") legend(rows(1) size(small) position(0) bplacement(neast) order(3 ">=0.5m" 1 "0.1-0.5m" 2 "<0.1m"))
*/ 
