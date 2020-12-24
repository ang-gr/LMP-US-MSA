clear all
set more off

global workdir ".."
global figdir "$workdir/fig"
global gphdir "$workdir/gph"
global data "$workdir/dta"


* Open data source
use "$data/workfile9015_nopublic", clear

* Merge population of the working-age adults 
merge 1:1 yr cbsa using "$data/shempl/wkage_8015", keep(match) nogenerate

* Color scheme
set scheme s2color

** Set default graph dimenions
grstyle init
grstyle set graphsize 4.5 6


** ######################################## **
**********************************************
** Programs
**********************************************
** ######################################## **

capture program drop occdens_HML_9015
program define occdens_HML_9015, nclass
	args fignum suffix occ1 occ2 occ3 desc

    * If we're doing everyone (suffix blank) add a nice extension for graph name
    if "`suffix'" == "" {
        local suffix = "all"
    }


	forvalues y = 1(1)3 {
        if `y'==1 {
            local tit1 = "High Paid"
        }
        else if `y'==2 {
            local tit1 = "Mid Paid"
        }
        else if `y'==3 {
            local tit1 = "Low Paid"     
        }

	    graph twoway (lpoly `occ`y'' pop2015  [aw=popwkage] if yr==1990, degree(1)  kernel(epan2) bwidth(5)) ///
			(lpoly `occ`y'' pop2015 [aw=popwkage] if yr==2000, degree(1)  kernel(epan2) bwidth(5)) ///
			(lpoly `occ`y'' pop2015 [aw=popwkage] if yr==2015, degree(1) kernel(epan2) bwidth(5)), ///
            title("`tit1'", size(medsmall) color(black)) subtitle("`tit2'", size(medsmall)) xtitle("") ytitle("") yscale(range(-0.15 0.10)) ///
            xscale(range(11.5 17)) xlab(`=log(100000)' "100,000" `=log(2000000)' "2,000,000" `=log(8000000)' "8,000,000" `=log(20000000)' "20,000,000", angle(90)) ///
			ylabel(-0.15(0.05)0.10) ///
            legend(label(1 "1990") label(2 "2000") label(3 "2015"))  ///
            xtitle("Population (2015)") ///
            legend(style(zyx2)) legend(cols(5) rows(1)) legend(region(lstyle(none))) legend(region(lcolor(none))) ///
            nodraw scheme(s2color) name("occ`y'", replace) //graphregion(color(white)) plotregion(color(white))  
	}

    grc1leg2  occ3 occ2 occ1, ///
		scheme(s2color) rows(1) cols(5) ///  graphregion(color(white)) plotregion(color(white)) ///
        ycommon title("Occupation Shares among `desc'", size(small)) subtitle("(Level Relative to 1990 Mean)", size(small)) ///
        xtob1title  xtitlefrom(occ3) l2title("Employment share")  ///
		note("kernel = epan2, degree = 1, bandwidth = 5 ") ///
		ring(1) pos(6) legendfrom(occ1) saving("$gphdir/Fig_MSA_nobin_nopublic.gph", replace)
		graph export "$workdir/fig/Fig_MSA_nobin_nopublic.pdf", replace

end



capture program drop occplots_HML
program define occplots_HML, nclass
	args fignum suffix desc

    if "`suffix'"!="" {
        local suff = "_" + "`suffix'"
    }

     * Base
   gen base = shempl`suff' 

    * High medium low
    gen o6_high = shempl_high/base
    gen o6_mid = shempl_mid/base
    gen o6_low = shempl_low/base

    * Renormalize by removing 1990 base of each occupation from all values and plot
    egen tempwt = sum(popwkage), by(yr)
    foreach v in high mid low {
        egen n90_`v' = sum(o6_`v'*popwkage/tempwt), by(yr)
        gen n15_`v' = n90_`v'
        egen nbase90 = max(n90_`v'*(yr==1990))
        egen nbase15 = max(n15_`v'*(yr==2015))
        replace n90_`v' = o6_`v' - nbase90
        replace n15_`v' = o6_`v' - nbase15
        drop nbase90 nbase15 
    }

    summ n90_* o6_high o6_mid o6_low [aw=popwkage] if yr==1990
    summ n15_* o6_high o6_mid o6_low [aw=popwkage] if yr==2015

    * Plot
    occdens_HML_9015 "`fignum'" "`suffix'" n90_high n90_mid n90_low "`desc'"

    drop o6_*  n90_* n15_* base tempwt

end

* Figure 7
occplots_HML "1" "" "Working-Age Adults in non-public sectors by MSA Population"



 
 
 
 
