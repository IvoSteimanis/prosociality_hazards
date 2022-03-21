*--------------------------------------------------------------------
* SCRIPT: 02_analysis.do
* PURPOSE: replicates all tables and figures and saves the results
*--------------------------------------------------------------------
/*
 Study 1: Fast-onset hazards: Typhoon Haiyan (Philippines)
	- Figure 2. Manipulation check – Worse togetherness
	- Figure 3.	Main treatment effects
	- Supplementary Information: Summary statistics, robustness checks and extented results, additional analysis

Study 2:  Slow-onset hazards: Sea-level rise (Solomon Islands, Bangladesh & Vietnam)
	- Figure 4.	Manipulation check – Negative emotions
	- Table 1.	 Main treatment effects and interactions with relocation beliefs
	- Supplementary Information: Summary statistics, robustness checks and extented results, additional analysis
*/
*--------------------------------------------------





*--------------------------------------------------------------
*  Study 1: Fast-onset hazards: Typhoon Haiyan (Philippines)
*--------------------------------------------------------------
* Load dataset for study 1
use "$working_ANALYSIS\processed\study1_ready.dta", replace


*-------------------------
* Study site description
*-------------------------
* Self-reported Affectedness by Haiyan
sum h6need house_dmg damages_house_ppp damages_haiyan_ppp house_dmg, detail
* 93% of participants were in need of aid because of Haiyan and 83% of houses were damaged
* The estimated costs of the damages to their houses was $865+-1125(SD) PPP adjusted
pwcorr h4finan damages_house_ppp damages_haiyan_ppp h6need , sig
* Perceived financial pressure after haiyan is correlated with damages (both house and overall) and being in need of aid

* TIME TO PREPARE
sum h1hours 
* Median 2 hours, 90% of participants had no more than 10 hours to prepare themselves
tab h1where 
* 76% of participants were at their homes when they were hit by Haiyan and only 11% found shelter in evacuation centers
sum h1prep h1rein h1prop h1food h1medi, detail
* 90% stated to have taken some kind of preperation measures, such as storing additional food (70%), reinforcing their houses (61%) or stacked up on medical supplies (29%)
sum income_hh_ppp, detail
*



*----------------------------------------------------------------
* Figure 2.	Manipulation check: Worse togetherness due to Haiyan?
*----------------------------------------------------------------
* What did the priming evoke?
ttest togetherness if priming < 3, by(priming)
ttest togetherness if priming !=2, by(priming)
ttest togetherness if priming !=1, by(priming)


ranksum togetherness if priming < 3, by(priming)
ranksum togetherness if priming !=2, by(priming)
ranksum togetherness if priming !=1, by(priming)

cibar togetherness, over1(priming)  bargap(10) barlabel(on) blfmt(%5.1f) blpos(11) blsize(8pt) blgap(0.03) graphopts(ysize(3.165) xsize(2.5)  legend(ring (1) pos(6) rows(1) size(8pt)) yla(1(1)6, nogrid) xla(, nogrid) ytitle("Mean", )) ciopts(lcolor(black) lpattern(dash)) 
gr save "$working_ANALYSIS\results\intermediate\figure2_study1_manipulation.gph", replace
gr export "$working_ANALYSIS\results\figures\figure2_study1_manipulation.tif", replace width(3465)


* Do participants who recalled conflicts perceive that Haiyan resulted in worse togetherness?
ttest togetherness if priming==3, by(primed_conflict)
ttest togetherness, by(primed_conflict2)

ranksum togetherness if priming==3, by(primed_conflict)
ranksum togetherness, by(primed_conflict2)




*-----------------------------------
* Figure 3.	Main treatment effects
*-----------------------------------
*set globals for groups of explanatory variables
global socio female married age only_elementary people_hh income_hh_ppp100 h1hours
global preferences survey_riskaversion survey_time a1trust


*Panel a: Prosocial behavior - Transfers
reg transfer_primed_anonymous t2 t3 transfer_baseline_anonymous $socio $preferences, vce(cluster group_session)
iegraph t2 t3, title("{bf: Panel A} Prosociality: Transfers", size(medium)) varlabels yla(0(10)40, nogrid) xla(, nogrid) barlabel  barlabelformat(%5.1f) mlabpos(11) mlabsize(medsmall) legend(ring(1) size(medsmall) pos(6) rows(1)) ysize(2) xsize(3.465) ytitle("Mean transfer in PHP", size(medsmall))
gr save "$working_ANALYSIS\results\intermediate\fig3_transfers.gph", replace


* Panel b: Prosocial behavior - Expected Transfers
reg exp_transfer_primed_person2 t2 t3 exp_person2 $socio $preferences, vce(cluster group_session)
iegraph t2 t3, title("{bf: Panel B} Prosociality: Expected Transfers", size(medium)) varlabels yla(0(10)40, nogrid) xla(, nogrid) barlabel barlabelformat(%5.1f) mlabpos(11) mlabsize(medsmall) legend(ring(1) size(medsmall)  pos(6) rows(1)) ysize(2) xsize(3.465) ytitle("Mean expected transfer in PHP", size(medsmall))
gr save "$working_ANALYSIS\results\intermediate\fig3_expectation.gph", replace


* Panel c: antisocial behavior (spite)
reg d_spite t2 t3 d_exp_spite $socio $preferences, vce(cluster group_session)
iegraph t2 t3, title("{bf:Panel C} Antisocial behavior", size(medium)) varlabels yla(0(0.05)0.2, nogrid) xla(, nogrid) barlabel barlabelformat(%5.2f)  mlabpos(11) mlabsize(medsmall) legend(ring(1) size(medsmall)  pos(6) rows(1)) ysize(2) xsize(3.465) ytitle("Spite rate", size(medsmall))
gr save "$working_ANALYSIS\results\intermediate\fig3_spite.gph", replace

* Panel d: In-group favoritism
*significance tests
ttest difference_baseline==0


reg difference_primed t2 t3 difference_baseline $socio $preferences, vce(cluster group_session)
iegraph t2 t3, title("{bf:Panel D} In-group favoritism", size(medium)) varlabels yla(0(5)15, nogrid) xla(, nogrid) barlabel barlabelformat(%5.1f)  mlabpos(11) mlabsize(medsmall) legend(ring(1) size(medsmall)  pos(6) rows(1)) ysize(2) xsize(3.465) ytitle("Mean difference in PHP", size(medsmall))
gr save "$working_ANALYSIS\results\intermediate\fig3_favoritism.gph", replace
*no significant difference between treatments, however respondents discriminate between friends and strangers from their community

grc1leg  "$working_ANALYSIS\results\intermediate\fig3_transfers.gph" "$working_ANALYSIS\results\intermediate\fig3_expectation.gph" "$working_ANALYSIS\results\intermediate\fig3_spite.gph" "$working_ANALYSIS\results\intermediate\fig3_favoritism.gph", rows(2) saving("$working_ANALYSIS\results\intermediate\figure3_fast_onset.gph", replace)
gr display, xsize(4) ysize(3)
gr export "$working_ANALYSIS\results\figures\figure3_fast_onset.tif", replace width(4000)


*R2: Furthermore, while in-group favouritism is measured based on average size of the transfer between friends (vs strangers) the authors may want to consider analysing the mediating effects of in-group favouritism – rather than ‘do participants give a significantly higher amount to friends compared to strangers’ - which is not the case here, perhaps a more interesting analysis would be to run a mediation to ascertain whether being part of the in-group explains some of the variation in transfers.

pwcorr transfer_primed_friend transfer_primed_anonymous
*correlation transfers friend and anonymous is 0.77 
*medeff (regress transfer_primed_friend treated transfer_baseline_friend $socio $preferences) (regress transfer_primed_anonymous treated transfer_primed_friend transfer_baseline_anonymous $socio $preferences), seed(12345) vce(robust) treat(treated) mediate(transfer_primed_friend) sims(1000)




*-----------------------------------
* SUPPLEMENTARY ONLINE MATERIALS 
*-----------------------------------
*Table S1.	 Summary statistics 
global overview transfer_baseline_anonymous transfer_baseline_friend difference_baseline transfer_primed_anonymous  transfer_primed_friend  difference_primed spite_0 spite_10 spite_40 togetherness female married age only_elementary people_hh income_hh_ppp  h1hours h6need house_dmg damages_haiyan_ppp survey_riskaversion patient a1trust

estpost tabstat $overview, statistics(count mean sd min max) columns(statistics)
esttab . using "$working_ANALYSIS\results\tables\tableS1_summary_statistics.rtf", cells("count(fmt(0)) mean(fmt(%9.2fc)) sd(fmt(%9.2fc)) min(fmt(0)) max(fmt(0))")  not nostar unstack nomtitle nonumber nonote label replace
 

*Table S2.	Treatment balance
global balance female married age only_elementary people_hh income_hh_ppp h1hours h6need house_dmg damages_haiyan_ppp survey_riskaversion patient a1trust

iebaltab $balance, grpvar(priming) rowvarlabels format(%9.2f) ///
	  stdev ftest fmissok tblnonote save("$working_ANALYSIS\results\tables\tableS2_treatment_balancing.xlsx") replace
	  
	  
*Table S3.	Priming effects on main outcomes
*prosocial behavior: transfers
reg transfer_primed_anonymous t2 t3, vce(cluster group_session)
outreg2 using "$working_ANALYSIS\results\tables\tableS3_main_effects_Haiyan" ,  drop() addstat("Adjusted R2", e(r2_a))  adec(2) dec(2) word  noaster replace
reg transfer_primed_anonymous t2 t3 transfer_baseline_anonymous $socio $preferences, vce(cluster group_session)
est store fig2_transfer
outreg2 using "$working_ANALYSIS\results\tables\tableS3_main_effects_Haiyan",  drop() addstat("Adjusted R2", e(r2_a)) adec(2) dec(2) word noaster append
*Prosocial behavior: expectations
reg exp_transfer_primed_person2 t2 t3, vce(cluster group_session)
outreg2 using "$working_ANALYSIS\results\tables\tableS3_main_effects_Haiyan",  drop() addstat("Adjusted R2", e(r2_a)) adec(2) dec(2) word noaster append
reg exp_transfer_primed_person2 t2 t3 exp_person2 $socio $preferences, vce(cluster group_session)
est store fig2_expectation
outreg2 using "$working_ANALYSIS\results\tables\tableS3_main_effects_Haiyan",  drop() addstat("Adjusted R2", e(r2_a)) adec(2) dec(2) word noaster append
*anitsocial behavior
reg d_spite t2 t3, vce(cluster group_session)
outreg2 using "$working_ANALYSIS\results\tables\tableS3_main_effects_Haiyan",  drop() addstat("Adjusted R2", e(r2_a)) adec(2) dec(2) word noaster append
reg d_spite t2 t3 d_exp_spite $socio $preferences, vce(cluster group_session)
est store fig2_spite
outreg2 using "$working_ANALYSIS\results\tables\tableS3_main_effects_Haiyan",  drop() addstat("Adjusted R2", e(r2_a)) adec(2) dec(2) word noaster append
*in-group favoritism
reg difference_primed t2 t3, vce(cluster group_session)
outreg2 using "$working_ANALYSIS\results\tables\tableS3_main_effects_Haiyan",  drop() addstat("Adjusted R2", e(r2_a)) adec(2) dec(2) word noaster append
reg difference_primed t2 t3 difference_baseline $socio $preferences , vce(cluster group_session)
est store fig2_favoritism
outreg2 using "$working_ANALYSIS\results\tables\tableS3_main_effects_Haiyan",  drop() addstat("Adjusted R2", e(r2_a)) adec(2) dec(2) word noaster append


*Table S4.	Backfiring of conflict treatment?
* check whether participants who were actually recalling conflicts behave differently
reg transfer_primed_anonymous primed_conflict transfer_baseline_anonymous $socio $preferences if priming==3, vce(cluster group_session)
outreg2 using "$working_ANALYSIS\results\tables\tableS4_conflict_priming" ,  drop() addstat("Adjusted R2", e(r2_a))  adec(2) dec(2) word  noaster replace
reg exp_transfer_primed_person2 primed_conflict exp_person2 $socio $preferences if priming==3, vce(cluster group_session)
outreg2 using "$working_ANALYSIS\results\tables\tableS4_conflict_priming" ,  drop() addstat("Adjusted R2", e(r2_a))  adec(2) dec(2) word  noaster append
reg d_spite primed_conflict d_exp_spite $socio $preferences if priming==3, vce(cluster group_session)
outreg2 using "$working_ANALYSIS\results\tables\tableS4_conflict_priming" ,  drop() addstat("Adjusted R2", e(r2_a))  adec(2) dec(2) word  noaster append
reg difference_primed primed_conflict difference_baseline $socio $preferences , vce(cluster group_session)
outreg2 using "$working_ANALYSIS\results\tables\tableS4_conflict_priming" ,  drop() addstat("Adjusted R2", e(r2_a))  adec(2) dec(2) word  noaster append




// Table S5.	Robustness checks
// Solidarity transfers
reg transfer_primed_anonymous t2 t3  transfer_baseline_anonymous $socio $preferences i.session, vce(cluster group_session)
testparm $socio
local F1 = r(p)
testparm $preferences
local F2 = r(p)
outreg2 using "$working_ANALYSIS\results\tables\tableS5_robustness_checks_fast",  drop(i.session) addstat("Adjusted R2", e(r2_a), "F-test: Socio-economic", `F1', "F-test: cognitive measures", `F2') adec(2) dec(2) noaster word replace

*Tobit model accounting for censoring of outcome variable 
tobit transfer_primed_anonymous transfer_baseline_anonymous t2 t3 $socio $preferences i.session, vce(cluster group_session) ul(70) 
testparm $socio
local F1 = r(p)
testparm $preferences
local F2 = r(p)
outreg2 using "$working_ANALYSIS\results\tables\tableS5_robustness_checks_fast",  drop(i.session) addstat("Adjusted R2", e(r2_a), "F-test: Socio-economic", `F1', "F-test: cognitive measures", `F2') adec(2) dec(2) noaster word append


// Expected transfers
*including village fe
reg exp_transfer_primed_person2 t2 t3  exp_person2 $socio $preferences i.session, vce(cluster group_session)
testparm $socio
local F1 = r(p)
testparm $preferences
local F2 = r(p)
outreg2 using "$working_ANALYSIS\results\tables\tableS5_robustness_checks_fast",  drop(i.session) addstat("Adjusted R2", e(r2_a), "F-test: Socio-economic", `F1', "F-test: cognitive measures", `F2') adec(2) dec(2) noaster word append

*Tobit model accounting for upward censoring of outcome variable 
tobit exp_transfer_primed_person2 exp_person2 t2 t3 $socio $preferences i.session, vce(cluster group_session) ul(70)
testparm $socio
local F1 = r(p)
testparm $preferences
local F2 = r(p)
outreg2 using "$working_ANALYSIS\results\tables\tableS5_robustness_checks_fast",  drop(i.session) addstat("Adjusted R2", e(r2_a), "F-test: Socio-economic", `F1', "F-test: cognitive measures", `F2') adec(2) dec(2) noaster word append

// Spiteful behavior - Probit
probit d_spite t2 t3 d_exp_spite female age only_elementary people_hh income_hh_ppp100 h1hours $preferences, vce(cluster group_session)
local R2 = e(r2_p)
testparm female age only_elementary people_hh income_hh_ppp100
local F1 = r(p)
testparm $preferences
local F2 = r(p)
margins, dydx(*) post
outreg2 using "$working_ANALYSIS\results\tables\tableS5_robustness_checks_fast",  drop(i.session) addstat("Adjusted R2", `R2', "F-test: Socio-economic", `F1', "F-test: cognitive measures", `F2') adec(2) dec(2) noaster word append

//in-group favoritism
reg difference_primed t2 t3 difference_baseline $socio $preferences i.session, vce(cluster group_session)
testparm $socio
local F1 = r(p)
testparm $preferences
local F2 = r(p)
outreg2 using "$working_ANALYSIS\results\tables\tableS5_robustness_checks_fast",  drop(i.session) addstat("Adjusted R2", e(r2_a), "F-test: Socio-economic", `F1', "F-test: cognitive measures", `F2') adec(2) dec(2) noaster word append

tobit difference_primed t2 t3 difference_baseline $socio $preferences i.session, vce(cluster group_session) ul(70) ll(-70)
testparm $socio
local F1 = r(p)
testparm $preferences
local F2 = r(p)
outreg2 using "$working_ANALYSIS\results\tables\tableS5_robustness_checks_fast",  drop(i.session) addstat("Adjusted R2", e(r2_a), "F-test: Socio-economic", `F1', "F-test: cognitive measures", `F2') adec(2) dec(2) noaster word append








*-------------------------------------------------------------------------------------
* Study 2:  Slow-onset hazards: Sea-level rise (Solomon Islands, Bangladesh & Vietnam)
*-------------------------------------------------------------------------------------
* Load dataset for study 2
use "$working_ANALYSIS\processed\study2_ready.dta", replace


*-------------------------
* Study site description
*-------------------------
ttest relocation, by(affected)
tab rel_certainty country_id
ttest pc_livelihood, by(country_id)
ttest pc_relocate, by(country_id)


*--------------------------------------------------
* Figure 4.	Manipulation check: Negative emotions
*--------------------------------------------------
tab treatment_vn, gen(vn_t)

* Manipulation check
ranksum NA, by(treated)
ttest NA, by(treated)

preserve
rename NA emo1
rename p1_upset emo2
rename p2_hostile emo3
rename p4_ashamed emo4
rename p6_nervous emo5
rename p9_afraid emo6

reshape long emo, i(id) j(emotions_lab)
lab def emo_lab1 1 "Average" 2 "Upset" 3 "Hostile" 4 "Ashamed" 5 "Nervous" 6 "Afraid" , replace 
lab val emotions_lab emo_lab1
cibar emo, over1(treated) over2(emotions_lab) gap(30) bargap(10) barlabel(on) blfmt(%5.1f) blpos(12) blsize(8pt) blgap(0.12) graphopts(xsize(3.165) ysize(2)  legend(ring (1) pos(6) rows(1))  yla(1(1)5, nogrid) xla(, nogrid) ytitle("Mean", )) ciopts(lcolor(black) lpattern(dash)) 
gr save "$working_ANALYSIS\results\intermediate\figure4_study2_manipulation.gph", replace
gr export "$working_ANALYSIS\results\figures\figure4_study2_manipulation.tif", replace width(3465)
restore




*---------------------------------------------------------------------------
* Table 1.	 Main treatment effects and interactions with relocation beliefs
*---------------------------------------------------------------------------
// set globals for control variables
global socio female married age edu people_hh income_hh_ppp100
global other z_survey_time z_survey_trust z_risk z_place 
gen treated_relocate = treated*relocation

* OLS regression
reg z_prosocial treated, vce(hc3)
outreg2 using "$working_ANALYSIS\results\tables\table1_main_slow_onset",  drop(i.session) addstat("Adjusted R2", e(r2_a)) adec(2) dec(2) word replace
reg z_prosocial treated  $socio $other i.country_id, vce(hc3)
outreg2 using "$working_ANALYSIS\results\tables\table1_main_slow_onset",  drop(i.session) addstat("Adjusted R2", e(r2_a)) adec(2) dec(2) word append
reg z_prosocial treated relocation treated_relocate, vce(hc3)
est store sotf_pooled
outreg2 using "$working_ANALYSIS\results\tables\table1_main_slow_onset",  drop(i.session) addstat("Adjusted R2", e(r2_a)) adec(2) dec(2) word append
reg z_prosocial treated relocation treated_relocate   $socio $other i.country_id, vce(hc3)
outreg2 using "$working_ANALYSIS\results\tables\table1_main_slow_onset",  drop(i.session) addstat("Adjusted R2", e(r2_a)) adec(2) dec(2) word append


* Survey evidence: Adaptation actions
sum sealevel1 sealevel2 sealevel3 sealevel4 sealevel5 sealevel6 sealevel7
tab adapt1





*--------------------------------
* SUPPLEMENTARY ONLINE MATERIALS 
*--------------------------------

***(1) FIGURES

*Figure S4.	Climate change impact appraisal across study sites
ttest cc_fp==cc_pp
signrank cc_pp=cc_fp

preserve
rename cc_pp appraisal1 
rename cc_fp appraisal2
rename pp_slr appraisal3 
rename fp_slr appraisal4 

reshape long appraisal, i(id) j(appraisal_lab)
lab def appraisal_lab1 1 "Past: CC" 2 "Future: CC" 3 "Past: SLR" 4 "Future: SLR", replace 
lab val appraisal_lab appraisal_lab1
cibar appraisal , over1(appraisal_lab) over2(country_id)  gap(30) bargap(5)  barlabel(on) blfmt(%5.1f) blpos(12) blsize(8pt) blgap(0.1) graphopts(xsize(3.465) ysize(2) legend(ring (1) pos(6) rows(1))  yla(1(1)5, nogrid) xla(, nogrid) ytitle("Mean", )) ciopts(lcolor(black) lpattern(dash))
gr save "$working_ANALYSIS\results\intermediate\figureS4_impact_appraisal.gph", replace
gr export "$working_ANALYSIS\results\figures\figureS4_impact_appraisal.tif", replace width(3465)
restore


*Figure S5.	Recommended adaptation strategies
mylabels 0(20)100, myscale(@) local(pctlabel) suffix("%") 
catplot adapt1, over(country_id, label(labsize(6pt))) asyvar stack percent(country_id)  yla(`pctlabel', nogrid)   blabel(bar, format(%9.0f) size(7pt) pos(center)) title("{bf:A:} Across SLR samples", size(10pt)) ytitle("") l1title("")  b1title("") legend(rows(2) size(7pt)) xsize(3.465) ysize(2)
gr save  "$working_ANALYSIS\results\intermediate\figureS5_adaptation_a.gph", replace

mylabels 0(20)100, myscale(@) local(pctlabel)suffix("%") 
catplot adapt1,  over(relocation, label(labsize(6pt)))  asyvar stack percent(relocation)  yla(`pctlabel', nogrid) blabel(bar, format(%9.0f) size(7pt) pos(center)) title("{bf:B:} By relocation belief", size(10pt))  ytitle("") l1title("")  b1title("") legend(rows(2) size(7pt)) xsize(3.465) ysize(2)
gr save  "$working_ANALYSIS\results\intermediate\figureS5_adaptation_b.gph", replace

grc1leg "$working_ANALYSIS\results\intermediate\figureS5_adaptation_a" "$working_ANALYSIS\results\intermediate\figureS5_adaptation_b",  pos(6) rows(1) ring(1) saving("$working_ANALYSIS\results\intermediate\figureS5_adaptation_strategies.gph", replace)
gr display, xsize(3.465) ysize(2)
gr export "$working_ANALYSIS\results\figures\figureS5_adaptation_strategies.tif", replace width(3465)


*Figure S6.	Vietnam: Relocation beliefs and prosociality
* Relocation asistance beliefs by treatment
lab def vn_t 0 "Control (n=123)" 1 "Community (n=92)" 2 "Individual (n=102)", replace
lab val treatment_vn vn_t

* Panel a: Belief in group relocation
cibar rel_assistance, over1(treatment_vn) bargap(20) barlabel(on) blfmt(%5.1f) blpos(9) blsize(7pt) blgap(0.08) graphopts(xsize(3.465) ysize(2) legend(rows(1) ring(1) pos(6) size(8pt))  yla(1(1)5, labsize(6pt) nogrid) xla(, nogrid) title("{bf:A:} Belief in group relocation", size(10pt))  ytitle("mean", size(8pt))) ciopts(lcolor(black) lpattern(dash))
gr save "$working_ANALYSIS\results\intermediate\figureS6_a.gph", replace

ranksum rel_scenario , by(treatment_vn)

ranksum rel_assistance if treatment_vn!=2, by(treatment_vn)
*not significantly different from control group
ranksum rel_assistance if treatment_vn!=1, by(treatment_vn)
* significantly lower than control group, p=0.044
ranksum rel_assistance if treatment_vn!=0, by(treatment_vn)
* significantly lower than community treatment, p=0.0033

* Panel b: Average share transferred in the DG across treatments
cibar dg_percent, over1(treatment_vn) bargap(20) barlabel(on) blfmt(%5.2f) blpos(9) blsize(7pt) blgap(0.03) graphopts(xsize(3.465) ysize(2) legend(rows(1) ring(1) pos(6) size(8pt))  yla(0(0.2)1, labsize(6pt) nogrid) xla(, nogrid) title("{bf:B:} Dictator transfers", size(10pt))  ytitle("mean transfer in percent", size(8pt))) ciopts(lcolor(black) lpattern(dash))
gr save "$working_ANALYSIS\results\intermediate\figureS6_b.gph", replace

grc1leg "$working_ANALYSIS\results\intermediate\figureS6_a" "$working_ANALYSIS\results\intermediate\figureS6_b",  pos(6) rows(1) ring(1) saving("$working_ANALYSIS\results\intermediate\figureS6_treatment_effects_vietnam.gph", replace)
graph display, xsize(3.465) ysize(2.5)
gr export "$working_ANALYSIS\results\figures\figureS6_treatment_effects_vietnam.tif", replace width(3465)

ttest dg_percent if treatment_vn !=2, by(treatment_vn)
ttest dg if treatment_vn !=1, by(treatment_vn)
ttest dg if treatment_vn !=0, by(treatment_vn)
ranksum dg if treatment_vn !=2, by(treatment_vn)
ranksum dg if treatment_vn !=1, by(treatment_vn)
ranksum dg if treatment_vn !=0, by(treatment_vn)
reg dg_percent i.treatment_vn, vce(robust)





***(2) TABLES
*Table S8.	Overview of outcome and control variables
global overview svo_in_r2 dg_percent strat1 strat2 strat3 strat4 collective_action rel_assistance /// experimental
		female married age edu people_hh income_ppp income_hh_ppp /// socio
		risk_aversion_norm survey_time survey_trust place_attachment NA /// survey outcomes
		fp_slr pp_slr pc_livelihood pc_relocate relocation number_extremes land_lost ///perceived risk exposure

estpost tabstat $overview, statistics(count mean sd min max) columns(statistics)
esttab . using "$working_ANALYSIS\results\tables\TableS8_overview.rtf", cells("count(fmt(0)) mean(fmt(%9.2fc)) sd(fmt(%9.2fc)) min(fmt(0)) max(fmt(0))")  not nostar unstack nomtitle nonumber nonote label replace


*Table S9.	Pooled sample: Treatment balance
global balance female married age edu people_hh income_ppp income_hh_ppp risk_aversion_norm survey_time survey_trust place_attachment

iebaltab $balance, grpvar(treated) rowvarlabels format(%9.2f) stdev ftest fmissok tblnonote save( "$working_ANALYSIS\results\tables\tableS9_balancing.xlsx") replace
reg treated $balance 


*Table S10.	Vietnam: Treatment balance
iebaltab $balance, grpvar(treatment_vn) rowvarlabels format(%9.2f) stdev ftest fmissok tblnonote save("$working_ANALYSIS\results\tables\tableS10_balancing_VN.xlsx") replace




*Table S11.	Selection of atoll migrants
* Atoll islanders have the option to move to the main island, which some already did. We find no evidence that these atoll migrants are less pro-social, risk loving or patient than atoll islanders. There seems to be no selection of especially selfish people migrating first. Moving allows atoll islanders to earn significantly more money and be less exposed to SLR hazards (perceive that their current location will be less affected by SLR in the next five years than atoll islanders)
gen atoll_migrant = 0 if si_study_sites == 3 
replace atoll_migrant = 1 if si_study_sites == 2 & village_same == 1
lab def atoll_mig 0 "Atoll Islander" 1 "Atoll Migrant", replace
lab val atoll_migrant atoll_mig
lab def si_sites 1 "Main Islanders" 2 "Atoll Migrants" 3 "Atoll Islanders", replace
lab val si_study_sites si_sites

probit atoll_migrant $socio $other svo_in_r1, vce(robust)
local R2 = e(r2_p)
testparm $socio
local F1 = r(p)
testparm $other svo_in_r1
local F2 = r(p)
margins, dydx(*) post 
outreg2 using "$working_ANALYSIS\results\tables\tableS11_selection_atoll_migrants",  drop() addstat("Pseudo R2", `R2', "F-test: Socio-economic", `F1', "F-test: Preferences", `F2') adec(2) dec(2) word replace


*Table S12.	Main pooled results (full)
reg z_prosocial treated i.country_id, vce(robust)
outreg2 using "$working_ANALYSIS\results\tables\tableS12_main_study2",  drop(i.session) addstat("Adjusted R2", e(r2_a)) adec(2) dec(2) noaster word replace
reg z_prosocial treated  $socio $other i.country_id, vce(robust)
outreg2 using "$working_ANALYSIS\results\tables\tableS12_main_study2",  drop(i.session) addstat("Adjusted R2", e(r2_a)) adec(2) dec(2) noaster word append
reg z_prosocial treated relocation treated_relocate i.country_id, vce(robust)
est store sotf_pooled
outreg2 using "$working_ANALYSIS\results\tables\tableS12_main_study2",  drop(i.session) addstat("Adjusted R2", e(r2_a)) adec(2) dec(2) noaster word append
reg z_prosocial treated relocation treated_relocate   $socio $other i.country_id, vce(robust)
outreg2 using "$working_ANALYSIS\results\tables\tableS12_main_study2",  drop(i.session) addstat("Adjusted R2", e(r2_a)) adec(2) dec(2) noaster word append


*Table S13.	Robustness checks pooled results
*Only treatment
reg z_prosocial treated, vce(hc3)
outreg2 using "$working_ANALYSIS\results\tables\tableS13_robustness_study2",  drop() addstat("Adjusted R2", e(r2_a)) adec(2) dec(2) word replace

* country FE
reg z_prosocial treated, vce(hc3)
outreg2 using "$working_ANALYSIS\results\tables\tableS13_robustness_study2",  drop() addstat("Adjusted R2", e(r2_a)) adec(2) dec(2) word append 

*treatment + socio
reg z_prosocial treated $socio i.country_id, vce(hc3)
testparm $socio
local F1 = r(p)
outreg2 using "$working_ANALYSIS\results\tables\tableS13_robustness_study2",  drop() addstat("Adjusted R2", e(r2_a)) adec(2) dec(2) word append 

*treatment + socio + preferences / perceptions
reg z_prosocial treated $socio $other i.country_id, vce(hc3)
testparm $socio
local F1 = r(p)
testparm $other
local F2 = r(p)
outreg2 using "$working_ANALYSIS\results\tables\tableS13_robustness_study2",  drop() addstat("Adjusted R2", e(r2_a)) adec(2) dec(2) word append 

*TOBIT: treatment + socio + preferences / perceptions + Interaction + Country FE
tobit prosocial_norm treated $socio $other i.country_id, vce(robust) ul(1)
testparm $socio
local F1 = r(p)
testparm $other
local F2 = r(p)
outreg2 using "$working_ANALYSIS\results\tables\tableS13_robustness_study2",  drop() addstat("Adjusted R2", e(r2_a)) adec(2) dec(2) word append 


*Table S14.	Main treatment effects by study site
* Solomon Islands
reg svo_in_r2 treated i.location $socio $other  if country_id==1, vce(cluster session_ID)
outreg2 using "$working_ANALYSIS\results\tables\tableS14_study_site_effects",  drop(i.location) addstat("Adjusted R2", e(r2_a)) adec(2) dec(2) word replace
tobit svo_in_r2 treated i.location $socio $other if country_id==1, vce(cluster session_ID) ll(-16) ul(61)
outreg2 using "$working_ANALYSIS\results\tables\tableS14_study_site_effects",  drop(i.location) addstat("Adjusted R2", e(r2_a)) adec(2) dec(2) word append

*Bangladesh
reg dg treated $socio $other i.location i.assistant if country_id==2, vce(robust)
outreg2 using "$working_ANALYSIS\results\tables\tableS14_study_site_effects",  drop(i.location) addstat("Adjusted R2", e(r2_a)) adec(2) dec(2) word append
tobit dg treated $socio $other i.location i.assistant if country_id==2, vce(robust) ul(120)
outreg2 using "$working_ANALYSIS\results\tables\tableS14_study_site_effects",  drop(i.location) addstat("Adjusted R2", e(r2_a)) adec(2) dec(2) word append

*Vietnam
reg dg i.treatment_vn $socio $other i.location i.assistant if country_id==3, vce(robust)
outreg2 using "$working_ANALYSIS\results\tables\tableS14_study_site_effects",  drop(i.location) addstat("Adjusted R2", e(r2_a)) adec(2) dec(2) word append
tobit dg i.treatment_vn $socio $other i.location i.assistant if country_id==3, vce(robust) ul(25000)
outreg2 using "$working_ANALYSIS\results\tables\tableS14_study_site_effects",  drop(i.location) addstat("Adjusted R2", e(r2_a)) adec(2) dec(2) word append



** EOF