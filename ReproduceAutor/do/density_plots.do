clear all
set more off

global workdir ".."
global figdir "$workdir/fig"
global gphdir "$workdir/gph"
global data "$workdir/dta"


* Open data source
use "$data/workfile7015", clear

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


****************************************************************************************************************************
* Programs for figures 7, 8, 11, A1
****************************************************************************************************************************

* This program plots the employment shares in 1970, 1980, 1990, 2000, and 2015
* vs population density in three panels: high, mid, and low skill occupation shares.
*
* Notes: This program is called by another program, occplots_HML, to create the figures.

capture program drop occdens_HML_7015
program define occdens_HML_7015, nclass
	args fignum suffix occ1 occ2 occ3 desc

    * If we're doing everyone (suffix blank) add a nice extension for graph name
    if "`suffix'" == "" {
        local suffix = "all"
    }


	forvalues y = 1(1)3 {
        if `y'==1 {
            local tit1 = "High Skill: Professional"
            local tit2 = "Technical & Managerial"
        }
        else if `y'==2 {
            local tit1 = "Mid Skill: Production"
            local tit2 = "Clerical, Admin & Sales"
        }
        else if `y'==3 {
            local tit1 = "Low Skill: Services, Transport"
            local tit2 = "Construction, & Laborers"
        }

			binscatter `occ`y'' lndens_70 [aw=popwkage] if (yr==1970 |yr==1980| yr==1990 |yr==2000 |yr==2015 ), by(yr) ////
            linetype(qfit) nquantiles(20) msymbol(oh th sh dh x ) ///
            title("`tit1'", size(medsmall) color(black)) subtitle("`tit2'", size(medsmall)) xtitle("") ytitle("") yscale(range(-0.2 0.3)) ///
            xscale(range(2 9)) xlab(`=log(10)' "10" `=log(100)' "100" `=log(1000)' "1,000" `=log(7500)' "7,500", angle(90)) ///
            legend(label(1 "1970") label(2 "1980") label(3 "1990") label(4 "2000") label(5 "2015"))  ///
            xtitle("Population Density (1970)") ///
            legend(style(zyx2)) legend(cols(5) rows(1)) legend(region(lstyle(none))) legend(region(lcolor(none))) ///
            nodraw scheme(s2color) graphregion(color(white)) plotregion(color(white)) name("occ`y'", replace)
	}

    grc1leg2  occ3 occ2 occ1, ///
		scheme(s2color)  graphregion(color(white)) plotregion(color(white)) rows(1) cols(5) ///
        ycommon title("Occupation Shares among `desc'", size(medium)) subtitle("(Level Relative to 1970 Mean)") ///
        xtob1title  xtitlefrom(occ3) l2title("Employment share")  ///
		ring(1) pos(6) legendfrom(occ1) saving("$gphdir/Fig_`fignum'_occdens_HML_708090015_`suffix'.gph", replace)
	graph export "$workdir/fig/Fig_`fignum'_occdens_HML_708090015_`suffix'.pdf", replace

end


* This program normalizes the employment shares in 1970, 1980, 1990, 2000, and 2015
* to be 0 in a certain base year then plots theses shares using occdens_HML_7015.
*
* Notes: This program call occdens_HML_7015 to create the figures.
capture program drop occplots_HML
program define occplots_HML, nclass
	args fignum suffix desc

    if "`suffix'"!="" {
        local suff = "_" + "`suffix'"
    }

    * Six categories
    gen base = shempl`suff' /* - shempl_farm`suff' */
    gen o6_exma = shempl_exma`suff'/base
    gen o6_ptec = (shempl_prof`suff'+shempl_tech`suff')/base
    gen o6_sadm = (shempl_adms`suff'+shempl_rsal`suff')/base
    gen o6_prod = shempl_prod`suff'/base
    gen o6_labr = (shempl_come`suff'+shempl_tran`suff' +shempl_farm`suff')/base
    gen o6_svcs = (shempl_sclp`suff'+shempl_sper`suff'+shempl_shel`suff')/base
    egen checksum=rsum(o6_exma o6_ptec o6_sadm o6_prod o6_labr o6_svcs)
    assert checksum>0.99 & checksum<1.01 if base!=0 & base!=.
    drop checksum

    * High medium low
    gen o6_high = o6_exma + o6_ptec
    gen o6_mid = o6_sadm + o6_prod
    gen o6_low = o6_lab + o6_svcs
    assert (o6_high + o6_mid + o6_low)>0.99 & (o6_high + o6_mid + o6_low)<1.01 if base!=0 & base!=.  & yr>=1980

    * Top three and bottom three
    gen o6_top3 = o6_exma + o6_ptec + o6_sadm
    gen o6_bot3 = o6_prod + o6_labr + o6_svcs

    * Separate clerical and admin support
    gen o6_adms = shempl_adms`suff'/ base
    gen o6_rsal = shempl_rsal`suff'/ base

    * Everything but prod, sadm svcs
    gen o6_alot = o6_exma + o6_ptec + o6_labr
    assert (o6_alot + o6_prod + o6_sadm +  o6_svcs)>0.99 ///
        & (o6_alot + o6_prod + o6_sadm + o6_svcs)<1.01 if base!=0 & base!=.

    gen checksum = 0
    foreach v in exma prof tech adms rsal prod come tran farm sclp sper shel {
        gen o12_`v' = shempl_`v'`suff'/base
        replace checksum = checksum + o12_`v'
    }
    assert checksum > 0.99 & checksum <1.01 if base!=. & base!=0
    drop checksum

    * Renormalize by removing 1980 or 1970 or 1950 base of each occupation from all values and plot
    egen tempwt = sum(popwkage), by(yr)
    foreach v in high mid low {
        egen n80_`v' = sum(o6_`v'*popwkage/tempwt), by(yr)
        gen n70_`v' = n80_`v'
        //gen n50_`v' = n80_`v'
        egen nbase80 = max(n80_`v'*(yr==1980))
        egen nbase70 = max(n70_`v'*(yr==1970))
        //egen nbase50 = max(n70_`v'*(yr==1950))
        replace n80_`v' = o6_`v' - nbase80
        replace n70_`v' = o6_`v' - nbase70
        //replace n50_`v' = o6_`v' - nbase50
        drop nbase80 nbase70 
    }

    summ n80_* o6_high o6_mid o6_low [aw=popwkage] if yr==1980
    summ n70_* o6_high o6_mid o6_low [aw=popwkage] if yr==1970
    //summ n50_* o6_high o6_mid o6_low [aw=popwkage] if yr==1950
    bysort yr: summ n80_high n80_mid n80_low [aw=popwkage]
    bysort yr: summ n70_high n70_mid n70_low [aw=popwkage]
    //bysort yr: summ n50_high n50_mid n50_low [aw=popwkage]

    * Plot
    occdens_HML_7015 "`fignum'" "`suffix'" n70_high n70_mid n70_low "`desc'"

    drop o6_* o12_* n80_* n70_* base tempwt

end


* Figure 7
occplots_HML "7" "" "Working-Age Adults by CZ Population"
