*--------------------------------------------------------------------------
* SCRIPT: 1_process_raw_data.do
* PURPOSE: cleans the  experimental data and generates additional variables for 
* both study 1 and study 2
*--------------------------------------------------------------------------





*--------------------------------------------------
* PREPERATION DATASET STUDY 1: Philippines
*--------------------------------------------------
use "$working_ANALYSIS\data\study1_raw.dta", replace
drop if intens==0
sort session player_ID
gen id=_n

rename time survey_time

*Exchange rate 2016 1USD = 47.492 PHP
* Convert earnings using the world bank PPP conversion factor from 2016 (LCU=18.947)
gen payout_USD = payout_final / 47.492
gen payout_PPP =  payout_final / 18.947
gen h2housec_ppp = h2housec / 18.947
gen income_hh_ppp = ymonth / 18.947
gen income_hh_ppp100 = income_hh_ppp/100


*------------------------
* Solidarity Game
*------------------------
* Stranger identifier (player 3 in solidarity game)
lab def stranger1 0 "Friends" 1 "Stranger", replace
lab val stranger stranger1
lab def treat1 1 "Control" 2 "T1: Support" 3 "T2: Conflict"
lab val priming treat1


*Generate average amount transferred for strangers in solidarity game
egen transfer_stranger = rowmean(transfer_person1 transfer_person2) if stranger==1
egen transfer_primed_stranger = rowmean(transfer_primed_person1 transfer_primed_person2) if stranger==1

gen transfer_baseline_anonymous = transfer_person2 if stranger==0
replace transfer_baseline_anonymous = transfer_stranger if stranger==1
gen transfer_primed_anonymous = transfer_primed_person2 if stranger==0
replace transfer_primed_anonymous = transfer_primed_stranger if stranger==1

gen transfer_baseline_friend = transfer_person1 if stranger==0
gen transfer_primed_friend = transfer_primed_person1 if stranger==0

*Difference in transfers between friends and strangers
gen difference_baseline = transfer_baseline_friend-transfer_baseline_anonymous
gen difference_primed = transfer_primed_friend-transfer_primed_anonymous

* Consistency check:
pwcorr transfer_primed_friend transfer_primed_person1 if stranger==0
*looks good
pwcorr transfer_primed_anonymous transfer_primed_person2 if stranger==0
*looks good
pwcorr transfer_primed_anonymous transfer_primed_person2 transfer_primed_person1 if stranger==1
*looks good (less than 1 because we took the mean)


// priming check
* Could the respondent remember any positive or negative events associated with Yolanda?
tab pos_soli
*Only 2 (1.6%) respondents in the positive treatment could not remember any acts of solidarity in reponse to Yolanda
tab neg_confl
* 38 (30%) of participants in the negative priming treatment could not remember any conflicts that happened because of Yolanda -> some even mentioned acts of solidarity so rather positive primed
*identify people that mentioned acts of solidarity / helping in the negative treatment
sort neg_confl
replace neg_confl=1 if id==82
gen neg_soli=.
replace neg_soli = 1 if id==750
replace neg_soli = 1 if id==73
replace neg_soli = 1 if id==370
replace neg_soli = 1 if id==695
replace neg_soli = 1 if id==354
replace neg_soli = 1 if id==430
replace neg_soli = 1 if id==102
replace neg_soli = 1 if id==602
replace neg_soli = 1 if id==467
replace neg_soli = 1 if id==784
replace neg_soli = 1 if id==786
replace neg_soli = 1 if id==100
replace neg_soli = 1 if id==480
replace neg_soli = 1 if id==56
replace neg_soli = 1 if id==74
replace neg_soli = 1 if id==209
*replace pos_soli=1 if neg_soli==1

gen primed = 0
replace primed = 1 if priming==1 | pos_soli==1 | neg_confl==1


*identify participants in the conflict treatment that really mentioned conflicts / corruption
gen primed_conflict = .
replace primed_conflict = 1 if id==17
replace primed_conflict = 1 if id==30
replace primed_conflict = 1 if id==38
replace primed_conflict = 1 if id==48
replace primed_conflict = 1 if id==61
replace primed_conflict = 1 if id==63
replace primed_conflict = 1 if id==83
replace primed_conflict = 1 if id==100
replace primed_conflict = 1 if id==102
replace primed_conflict = 1 if id==127
replace primed_conflict = 1 if id==139
replace primed_conflict = 1 if id==141
replace primed_conflict = 1 if id==172
replace primed_conflict = 1 if id==182
replace primed_conflict = 1 if id==189
replace primed_conflict = 1 if id==213
replace primed_conflict = 1 if id==225
replace primed_conflict = 1 if id==226
replace primed_conflict = 1 if id==252
replace primed_conflict = 1 if id==268
replace primed_conflict = 1 if id==277
replace primed_conflict = 1 if id==278
replace primed_conflict = 1 if id==305
replace primed_conflict = 1 if id==306
replace primed_conflict = 1 if id==316
replace primed_conflict = 1 if id==320
replace primed_conflict = 1 if id==328
replace primed_conflict = 1 if id==329
replace primed_conflict = 1 if id==334
replace primed_conflict = 1 if id==343
replace primed_conflict = 1 if id==344
replace primed_conflict = 1 if id==345
replace primed_conflict = 1 if id==362
replace primed_conflict = 1 if id==363
replace primed_conflict = 1 if id==372

gen priming2 = 1 if priming==1
replace priming2 = 2 if priming==2
replace priming2 = 3 if primed_conflict==1
lab val priming2 treat1

* Comments related to Backfiring: "People here during typhoons are more cooperative", "Each of us help one another",  "There is nothing I remember only helpfulness of each people here" "No incident happened here" "No no no ! Sorry!" "No because people here are all victims too." "No bad incidents happen here!"

*to be moved to generating file
replace primed_conflict = 0 if priming==3 & primed_conflict==.
gen primed_conflict2= 0
replace primed_conflict2= 1 if primed_conflict==1
replace primed_conflict2=. if priming==2
replace primed_conflict2=. if primed_conflict==0


* Priming: Effect on perceived erosion of social relations (cohesion)
gen togetherness = worsetog
lab var togetherness "How likely (1 very unlikely, 10 very likely) do you think is it that a Haiyan results in a worse togetherness of people? "

* Joy of destruction game
* spite decisions
gen spite = 0 if spite_0==1
replace spite = 1 if spite_10==1
replace spite = 2 if spite_40==1
lab def spite_lab1 0 "0" 1 "Reduced by 20%" 2 "Reduced by 80%", replace
lab val spite spite_lab1
gen d_spite = 0
replace d_spite = 1 if spite>0
lab def spite_lab2 0 "No Spite" 1 "Spite" , replace
lab val spite spite_lab2

* spite expecatations
gen exp_spite = 0 if exp_spite_0==1
replace exp_spite = 1 if exp_spite_10==1
replace exp_spite = 2 if exp_spite_40==1
lab def spite_lab3 0 "0" 1 "Expect -20%" 2 "Expect -80%", replace
lab val exp_spite spite_lab3
gen d_exp_spite = 0
replace d_exp_spite = 1 if exp_spite>0
lab def spite_lab4 0 "No Spite" 1 "Spite" , replace
lab val spite spite_lab4

* Damages caused by Haiyan (self-reported)
egen damages_haiyan = rowtotal(h2housec h2bikec h2boatc h2workc h2cropc)
replace damages_haiyan = 0 if damages_haiyan == .
gen damages_house_ppp = h2housec / 18.947
gen damages_haiyan_ppp = damages_haiyan/18.947

*Additional variables
gen house_dmg = 1 if h2housec >= 0
replace house_dmg = 0 if h2housec==.
replace h2housed = . if h2housed>1100

replace eyedis = 1 if eyedis>1 
gen only_elementary = 0
replace only_elementary = 1 if educ==1

gen group_session = group_ID*session

* PCA to identify more and less affected participants
global affectedness eyedis h6need house_dmg damages_haiyan_ppp
alpha $affectedness
pwcorr $affectedness, sig
pca $affectedness, comp(1)
estat loadings
predict pc1, score
estat kmo // kmo=0.60 -> okay
sum pc1
gen pca_affected=pc1

egen med_affected = median(pca_affected)
gen affected = 0 if pca_affected < med_affected
replace affected = 1 if pca_affected >= med_affected
lab def affectedness1 0 "Less affected" 1 "More affected"
lab val affected  affectedness1

*both treatments combined
gen treated=0
replace treated=1 if priming > 1
lab def treat_lab 0 "Control" 1 "Primed", replace
lab val treated treat_lab

*interaction treatment and affectedness
gen treated_affected = treated*affected

* Interaction: Priming*affected
*both treatments individually
tab priming, gen(t)

lab var t1 "Control"
lab var t2 "T1: Support"
lab var t3 "T2: Conflict"


*standardize variables
gen survey_riskaversion = 11-risk
egen z_income = std(ymonth)
gen log_income = log(ymonth)
egen z_prosocial_primed_anonymous = std (transfer_primed_anonymous)
egen z_prosocial_primed_friend = std(transfer_primed_friend)
egen z_prosocial_baseline_anonymous = std (transfer_baseline_anonymous)
egen z_prosocial_baseline_friend = std(transfer_baseline_friend)
egen z_risk = std(risk_aversion)
egen z_survey_time = std(survey_time)

save "$working_ANALYSIS\processed\study1_ready.dta", replace







*--------------------------------------------------
* PREPERATION DATASET STUDY 2
*--------------------------------------------------
* Preperation of datasets from each study site and merging


*--------------------------------------------------
* SOLOMON ISLANDS (2017)
*--------------------------------------------------
use "$working_ANALYSIS\data\study2_SI_raw.dta", replace

*SOME MORE LABELS
label var a3_age "Age(years)"
label var income_hh "Monthly household income"
label var income_ppp "Purchasity power adjusted income"
label var income_hh_ppp "Purchasity power adjusted household income"
label var a7_hhsize "Household size"
label var female "Female"
label var married "Married"
label var melanesian "Ethnicity: Melanesian"
label var a4_edu "Level of Education"
label var college "College degree"
label var a9 "Born here"
label var a10 "Live here(years)"
label var f4a "Close friends same tribe"
label var f4b "Close friends not-same tribe"
label var f5 "Visitors from home (per year)"
label var f6 "Visits home (per year)"
label var mean_premium_norm "Risk premium(normalized)"
label var patience "Patience"
label var spite "Spiteful"
lab define treated 0 "Control" 1 "Treatment", replace
lab val video treated

*generate variables
tab a4_edu, gen(edu)
gen secondary=0
replace secondary=1 if a4_edu >2

drop survey_trust
rename video treated
gen survey_trust = c6a
tab rel_wealth, gen(rel_wealth)
gen hh_worse_off= rel_wealth1
gen daily_prayer=0
replace daily_prayer=1 if a14a_prayer==1

rename a3_age age
rename a7_hhsize people_hh
rename patience survey_time
rename a9 village_same
rename c7 community_activities
gen edu=0 if a4_edu==1
replace edu=6 if a4_edu==2
replace edu=9 if a4_edu==3
replace edu=11 if a4_edu==4
replace edu=12 if a4_edu==5
replace edu=13 if a4_edu==6

egen z_prosocial=std(svo_in_r2)
egen z_prosocial2=std(send_in_r2)
egen z_prosocial_out = std(svo_out_r2)
egen z_risk=std(mean_premium_simple)
lab var z_prosocial "Higher values imply more pro-social"
lab var z_risk "Higher values imply more risk aversion"
egen z_place=std(place_attachment)
egen z_fp=std(cc_fp)
egen z_pp=std(cc_pp)
egen z_svo_in_r2=std(svo_in_r2)
egen z_svo_in_r1=std(svo_in_r1)
egen z_patience=std(c3)
egen z_psp_out2=std(svo_out_r2)

*normalized values
qui summ svo_in_r2
gen prosocial_norm = (svo_in_r2 - r(min)) / (r(max) - r(min))

qui summ mean_premium_simple
gen risk_aversion_norm = (mean_premium_simple - r(min)) / (r(max) - r(min))
qui summ survey_time
gen patience_norm = (survey_time - r(min)) / (r(max) - r(min))
qui summ survey_trust
gen trust_norm = (survey_trust - r(min)) / (r(max) - r(min))

*Rely on
rename cca5_rely_on_climatechange1 h1
rename cca5_rely_on_climatechange2 h2
rename cca5_rely_on_climatechange3 h4
rename cca5_rely_on_climatechange4 h5
rename cca5_rely_on_climatechange5 h6
rename cca5_rely_on_climatechange6 h7

label var h1 "Government"
label var h2 "NGO"
*label var h3 "Rich countries (polluters)"
label var h4 "Religious organization"
label var h5 "Other villagers"
label var h6 "Family members"
label var h7 "No one"


*PAST PERCEPTION OF CC IMPACTS
drop cc_pp
egen pp_drought=rowmean(d4a d4b_reverse)
lab var pp_drought "Droughts more frequent and intense"
egen pp_cyclones=rowmean(d4c d4d d4e_reverse)
lab var pp_cyclones "Cyclones more frequent,more frequent heavy rains and more sever floods"
egen pp_slr=rowmean(d4f d4g d4h  )
lab var pp_slr "Sea level is higher, more intense saltwater intrusion and coastal erosion"
egen cc_pp=rowmean(d4a d4b_reverse d4c d4d d4e_reverse d4f d4g d4h  )
labe var cc_pp "Higher values imply stronger approval that CC impacts did happen."

*FUTURE PERCEPTION OF CC IMPACTS
drop cc_fp
egen fp_drought=rowmean(d5a d5b_reverse)
lab var fp_drought "Droughts more frequent and intense"
egen fp_cyclones=rowmean(d5c d5d d5e_reverse)
lab var fp_cyclones "Cyclones more frequent,more frequent heavy rains and more sever floods"
egen fp_slr=rowmean(d5f d5g d5h)
lab var fp_slr "Sea level is higher, more intense saltwater intrusion and coastal erosion"
egen cc_fp=rowmean(d5a d5b_reverse d5c d5d d5e_reverse d5f d5g d5h  )
labe var cc_fp "Higher values imply stronger approval that CC impacts will happen."


*--------------------------------------------------
* SVO TASK SPECIFIC
*--------------------------------------------------
gen individualistic_r2=0
replace individualistic_r2=1 if svo_in_r2_type<3
lab def indi 0 "pro-social/altruistic" 1 "individualistic/competitive", replace
lab val individualistic_r2 indi

*--------------------------------------------------
* TRUST GAME SPECIFIC 
*--------------------------------------------------

lab def delta 0 "One-shot" 1 "Repeated"
gen repeated=0 if one_shot==1
replace repeated=1 if one_shot==0
lab val repeated delta
lab var repeated "1= Repeatead Treatment"

lab def trust_l 1 "A: Trustor" 2 "B: Trustee", replace
lab val position trust_l

*rename expectations about partner will do
forval i = 1(1)10 {
	rename tg_`i'_expec tg_exp`i', replace
}



*keep only necessary variables
keep id player_id session_ID  date location village location2 place treatment treated female age married edu edu1 edu2 edu3 edu4 edu5 edu6 max_primary secondary daily_prayer people_hh village_same a10 melanesian polynesian income income_hh income_ppp income_hh_ppp pca_wealth fix_assets movable_assets hh_worse_off rel_wealth1 rel_wealth2 rel_wealth3  ///SETUP & SOCIO
	one_shot repeated rounds q1_tg q2_tg q3_tg q4_tg q5_tg q_score_tg position tg_partner tg_1 tg_exp1 tg_2 tg_exp2 tg_3 tg_exp3 tg_4 tg_exp4 tg_5 tg_exp5 tg_6 tg_exp6 tg_7 tg_exp7 tg_8 tg_exp8 tg_9 tg_exp9 ///TG
	z_prosocial2 svo_in_r1 svo_in_r2 svo_in_r1_type svo_in_r2_type send_in_r1 send_in_r2 svo_out_r1 svo_out_r2 send_out_r1 send_out_r2 individualistic_r2 z_psp_out2 q_score_svo svo_order c_in_r1 c_in_r2 c_in ///SVO
	q_score_risk mean_premium_simple mean_premium_norm exp_risk survey_risk mixed_risk premium_simple1 premium_simple2 premium_simple3 premium_norm1 premium_norm2 premium_norm3 /// RISK
	spite spite_expec number_thrown p_honesty cfc_score lot_score place_identity place_dependence place_attachment high_pa mean_premium_norm exp_risk survey_risk survey_trust survey_time patience_norm risk_aversion_norm trust_norm community_activities /// OTHER MEASURES
	z_prosocial prosocial_norm z_risk z_place z_fp z_pp   z_svo_in_r2 z_svo_in_r1 z_patience ///standardized outcomes
	sealevel1 sealevel2 sealevel3 sealevel4 sealevel5 ///ADAPTATION STRATEGIES
	f1a_friends f1b_relatives f1c_conflict /// friends and relatives in session
	cc_pp cc_fp pp_drought pp_cyclones pp_slr fp_slr fp_drought fp_cyclones d3 relocation info_washedaway rank_top3 rank4_7 rank_bottom3 ///CC RELATED
	h1 h2 h4 h5 h6 h7 ///Who do you believe sould help you deal with the impacts of CC?
	session_ID payout not_primed sum_video attention t_attention assistant p1_future p2_present p3_present p4_future p5_present p6_present t2_sum_video1 t2_sum_video3 t2_sum_video2 t2_sum_video5 t2_sum_video4 t2_sum_video7 t2_sum_video6 t2_sum_video8/*PRIMING RELATED*/
	

order id player_id session_ID  date location location2 place treatment treated female age married edu edu1 edu2 edu3 edu4 edu5 edu6 max_primary secondary daily_prayer people_hh village_same melanesian polynesian income income_hh pca_wealth fix_assets movable_assets hh_worse_off rel_wealth1 rel_wealth2 rel_wealth3  ///SETUP & SOCIO
	one_shot repeated rounds q1_tg q2_tg q3_tg q4_tg q5_tg q_score_tg position tg_partner tg_1 tg_exp1 tg_2 tg_exp2 tg_3 tg_exp3 tg_4 tg_exp4 tg_5 tg_exp5 tg_6 tg_exp6 tg_7 tg_exp7 tg_8 tg_exp8 tg_9 tg_exp9 ///TG
	z_prosocial2 svo_in_r1 svo_in_r2 svo_in_r1_type svo_in_r2_type send_in_r1 send_in_r2 send_out_r1 send_out_r2 individualistic_r2 q_score_svo svo_order c_in_r1 c_in_r2 c_in ///SVO
	q_score_risk mean_premium_simple mean_premium_norm exp_risk survey_risk mixed_risk premium_simple1 premium_simple2 premium_simple3 premium_norm1 premium_norm2 premium_norm3 /// RISK
	spite spite_expec number_thrown p_honesty cfc_score lot_score place_identity place_dependence place_attachment high_pa mean_premium_norm exp_risk survey_risk survey_trust survey_time community_activities /// OTHER MEASURES
	z_prosocial z_risk z_place z_fp z_pp   z_svo_in_r2 z_svo_in_r1 z_psp_out2 z_patience ///standardized outcomes
	sealevel1 sealevel2 sealevel3 sealevel4 sealevel5 ///ADAPTATION STRATEGIES
	f1a_friends f1b_relatives f1c_conflict /// friends and relatives in session
	cc_pp cc_fp pp_drought pp_cyclones pp_slr fp_slr fp_drought fp_cyclones d3 relocation info_washedaway rank_top3 rank4_7 rank_bottom3 ///CC RELATED
	h1 h2 h4 h5 h6 h7 ///Who do you believe sould help you deal with the impacts of CC?
	session_ID payout not_primed sum_video attention t_attention assistant p1_future p2_present p3_present p4_future p5_present p6_present t2_sum_video1 t2_sum_video3 t2_sum_video2 t2_sum_video5 t2_sum_video4 t2_sum_video7 t2_sum_video6 t2_sum_video8/*PRIMING RELATED*/
sort id


save "$working_ANALYSIS\processed\study2_SI_clean.dta", replace





*--------------------------------------------------
* BANGLADESH (2018)
*--------------------------------------------------
use "$working_ANALYSIS\data\study2_BD_raw.dta", replace


*unique identifier variable
gen id = _n
lab var id "Unique identifier"

gen treated=0
replace treated=1 if treatment > 0

gen daily_prayer=0
replace daily_prayer=1 if prayer==1

gen muslim=0
replace muslim=1 if religion==1

gen survey_trust=trust/2

drop location
rename treatment treatment_BD
rename new_union location

*location
replace location = "24" if date == "2018-08-27" | date == "2018-08-28" //Padrishibpur
replace location = "26" if date == "2018-08-29" //Shikarpur
replace location = "21" if location=="Amragachhia"
replace location = "22" if location=="Bhandaria" //too big
replace location = "23" if location=="Dapdapia"
replace location = "24" if location=="Padri Shibpur"
replace location = "25" if location=="Roy Pasha Karapur"
replace location = "26" if location=="Shikarpur"
replace location = "27" if location=="Sholak"
destring location, replace
label define location_bangladesh 21 "Amragachhia" 22 "Bhandaria" 23 "Dapdapia" 24 "Padri Shibpur " 25 "Roy Pasha Karapur" 26 "Shikarpur" 27 "Sholak"
label values location location_bangladesh

* Attention to priming videos
egen attention_score=rowmean (t0_sum_video1 t0_sum_video2 t0_sum_video3 t0_sum_video4 t0_sum_video5 t0_sum_video6 ///
	t1_sum_video1 t1_sum_video2 t1_sum_video3 t1_sum_video4 t1_sum_video5 t1_sum_video6 t1_sum_video7)
	lab var attention_score "1 implies that the respondent could perfectly sum. the contents of the video"

sum attention_score,detail	
xtile pct_as= attention_score, nq(3)
	lab def q_as 1 "low" 2 "medium" 3 "high"
	lab val pct_as q_as

// Emotions
pwcorr p11_hopeless p12_sad p13_helpless, sig
gen e_depressed= (p11_hopeless + p12_sad + p13_helpless)
lab var e_depressed "Higher scores indicate that participant feels more sad, hope- & helpless"

// Place attachment
egen med_pa=median(place_attachment)
gen high_pa=0
replace high_pa=1 if place_attachment > med_pa
label var high_pa "Takes the value of 1, if more attached"
lab def lab_pa 0 "Low PA" 1 "High PA"
lab val high_pa lab_pa

// General Opinions
*Faith in gov
gen faith_gov3_r = 6-faith_gov3
gen faith_gov6_r = 6-faith_gov6
gen faith_gov = 1-((faith_gov1+faith_gov2+faith_gov3_r+faith_gov4+faith_gov5+faith_gov6_r -6) /6 /4)
label var faith_gov "Faith in Government (1=high, 0=low)"

*Faith in NGOs
gen faith_ngos3_r = 6-faith_ngos3
gen faith_ngos5_r = 6-faith_ngos5
gen faith_ngo = 1-((faith_ngos1+faith_ngos2+faith_ngos3_r+faith_ngos4+faith_ngos5_r -5) /5 /4)
label var faith_ngo "Faith in NGOs (1=high, 0=low)"

*Past migration experience
gen cc_relocate = 0 if cc_resettle_within_union==0 & cc_resettle_different_union == 0
replace cc_relocate = 1 if cc_resettle_within_union> 0 | cc_resettle_different_union > 0 
replace cc_relocate = . if cc_resettle_within_union == .

// Climate Change Perception
*CC past perception

*PAST PERCEPTION OF CC IMPACTS
gen cc_perception_past2_r = 6 - cc_perception_past2
gen cc_perception_past5_r = 6 - cc_perception_past5

egen pp_drought=rowmean(cc_perception_past1 cc_perception_past2_r)
lab var pp_drought "Droughts more frequent and intense"
egen pp_cyclones=rowmean(cc_perception_past3 cc_perception_past4 cc_perception_past5_r)
lab var pp_cyclones "Cyclones more frequent,more frequent heavy rains and more sever floods"
egen pp_slr=rowmean(cc_perception_past6 cc_perception_past7 cc_perception_past8)
lab var pp_slr "Sea level is higher, more intense saltwater intrusion and coastal erosion"
egen cc_pp=rowmean(cc_perception_past1 cc_perception_past3 cc_perception_past4 cc_perception_past5_r cc_perception_past6 cc_perception_past7 cc_perception_past8 cc_perception_past2_r)
labe var cc_pp "Higher values imply stronger approval that CC impacts did happen."

*FUTURE PERCEPTION OF CC IMPACTS
gen cc_expectation2_r = 6 - cc_expectation2
gen cc_expectation5_r = 6 - cc_expectation5

egen fp_drought=rowmean(cc_expectation1 cc_expectation2_r)
lab var fp_drought "Droughts more frequent and intense"
egen fp_cyclones=rowmean(cc_expectation3 cc_expectation4 cc_expectation5_r)
lab var fp_cyclones "Cyclones more frequent,more frequent heavy rains and more sever floods"
egen fp_slr=rowmean(cc_expectation6 cc_expectation7 cc_expectation8)
lab var fp_slr "Sea level is higher, more intense saltwater intrusion and coastal erosion"
egen cc_fp=rowmean(cc_expectation1 cc_expectation2_r cc_expectation3 cc_expectation4 cc_expectation5_r cc_expectation6 cc_expectation7 cc_expectation8)
labe var cc_fp "Higher values imply stronger approval that CC impacts will happen."


*CC denier
gen cc_denier = (cc_c1+cc_c2+cc_c3+cc_c4 -4) /4 /4
label var cc_denier "1 if CC is beliefed to be invented."

*Self-stated exposure
lab def exp_lab 0 "Less exposed" 1 "More exposed", replace
lab val land_lost exp_lab
lab var land_lost "More exposed"

gen exp_extreme=0
replace exp_extreme=1 if number_extremes>0

gen rebuild_house = 0 if rebuild_frequency==0
replace rebuild_house = 1 if rebuild_frequency > 0
replace rebuild_house = . if rebuild_frequency < 0 | rebuild_frequency ==.

*Rely on
rename assistance_cc1 h1
rename assistance_cc2 h2
rename assistance_cc3 h3
rename assistance_cc4 h4
rename assistance_cc5 h5
rename assistance_cc6 h6
rename assistance_cc7 h7
label var h1 "Government"
label var h2 "NGO"
label var h3 "Rich countries (polluters)"
label var h4 "Religious organization"
label var h5 "Other villagers"
label var h6 "Family members"
label var h7 "No one"

*Uncertainty
gen cc_uncertain = (cc_contribution1+cc_contribution2+cc_contribution3 -3) /3 /4
label var cc_uncertain "1=high uncertainty on how to deal with CC"

*Adaptation
rename cc_adaptation1 sealevel1
rename cc_adaptation2 sealevel2
rename cc_adaptation3 sealevel3
rename cc_adaptation4 sealevel4
rename cc_adaptation5 sealevel5
rename cc_adaptation6 sealevel6
rename cc_adaptation7 sealevel7
label var sealevel1 "Sea walls" 
label var sealevel2 "Plant mangroves" 
label var sealevel3 "Restore beach" 
label var sealevel4 "Migrate" 
label var sealevel5 "Move within village" 

* standardize variables
replace payout=payout/84 /*to USD, 1 USD = 84 Taka*/
gen dg_percent=dg/120
egen z_prosocial=std(dg)
egen z_prosocial2=std(dg)
replace survey_risk=33-survey_risk
lab var z_prosocial "Higher values imply more pro-social"
egen z_place=std(place_attachment)
egen z_risk=std(survey_risk)
egen z_fp=std(cc_fp)
egen z_pp=std(cc_pp)
egen z_NA=std(NA)
egen z_PA=std(PA)
egen m_place=median(place_attachment)
gen d_place=0
replace d_place=1 if place_attachment > m_place

*normalize
qui summ dg
gen prosocial_norm = (dg - r(min)) / (r(max) - r(min))
qui summ survey_risk
gen risk_aversion_norm = (survey_risk - r(min)) / (r(max) - r(min))
qui summ survey_time
gen patience_norm = (survey_time - r(min)) / (r(max) - r(min))
qui summ trust
gen trust_norm = (trust - r(min)) / (r(max) - r(min))




*labels
label var age "Age(years)"
label var edu "Education (years)"
label var income_hh "Monthly household income(converted to USD)"
label var income "Monthly income(converted to USD)"
label var people_hh "Household size"
label var income_meals_month "HH had to reduce meals?"
label var female "Female"
label var married "Married"
label var muslim "Muslim"
label var village_same "Born in this village"
label var daily_prayer "Goes to prayer daily"




/// PCA: AFFECTEDNESS INDEX
global affectedness pc_livelihood pc_relocate number_extremes land_lost rebuild_house
pwcorr $affectedness, sig
alpha $affectedness
pca $affectedness, comp(1)
estat loadings
predict pc1, score
estat kmo //  kmo=0.66 -> okay
sum pc1
gen pca_affected=pc1

egen med_affected = median(pca_affected)
gen affected = 0 if pca_affected < med_affected
replace affected = 1 if pca_affected >= med_affected

*identify assistants where respondents on average sent 66% of their DG endowment
bysort assistant treatment: sum dg_percent
tab dg if assistant==5
*there is no variation for assistant 5, independent of treatment respondents gave 2/3 of their endowment (> 70% gave evrything)


rename assets_sum asset_sum

*keep variables that are needed for analysis
sort id
keep id assistant date district village location treatment treated affected pca_affected female age married edu daily_prayer muslim people_hh village_same income income_hh income_ppp income_hh_ppp asset_sum hh_worse_off rel_wealth1 rel_wealth2 rel_wealth3 income_meals_month income_meals_frequency ///SETUP & SOCIO
	dg dg_percent prosocial_norm reciprocity revenge trust lot_score place_identity place_dependence place_attachment survey_risk survey_trust survey_time life_satisfaction comunity_activities patience_norm risk_aversion_norm trust_norm ///MEASURED OUTCOMES
	z_prosocial z_prosocial2 z_place z_risk z_fp z_pp z_NA z_PA ///standardized outcomes
	sealevel1 sealevel2 sealevel3 sealevel4 sealevel5 sealevel6 sealevel7 ///ADAPTATION STRATEGIES
	cc_pp cc_fp pp_drought pp_cyclones pp_slr fp_slr fp_drought fp_cyclones land_lost land_lost_size land_lost_value pc_livelihood pc_relocate number_extremes exp_extreme rebuild_house rebuild_frequency rebuild_days rebuild_costs prev_home_affected cc_relocate cc_perception_past1 cc_perception_past2 cc_perception_past3 cc_perception_past4 cc_perception_past5 cc_perception_past6 cc_perception_past7 cc_perception_past8 cc_expectation1 cc_expectation2 cc_expectation3 cc_expectation4 cc_expectation5 cc_expectation6 cc_expectation7 cc_expectation8 	///CC RELATED
	PA NA emo_neg e_depressed p1_upset p2_hostile p3_alert p4_ashamed p5_inspired p6_nervous p7_determined p8_attentive p9_afraid p10_active p11_hopeless p12_sad p13_helpless ///EMOTIONS
	h1 h2 h3 h4 h5 h6 h7 cc_contribution1 cc_contribution2 cc_contribution3 ///Who do you believe sould help you deal with the impacts of CC?
	not_primed payout assi_1 assi_2 assi_3 assi_4 assi_5 assi_6 assi_7 assi_8 ///interviewer dummies
	attention_score pct_as /*PRIMING RELATED*/

order id assistant date district village treatment treated affected female age married edu daily_prayer muslim people_hh village_same income income_hh income_ppp income_hh_ppp hh_worse_off rel_wealth1 rel_wealth2 rel_wealth3 income_meals_month income_meals_frequency ///SETUP & SOCIO
	dg dg_percent reciprocity revenge trust lot_score place_identity place_dependence place_attachment survey_risk survey_trust survey_time life_satisfaction comunity_activities ///MEASURED OUTCOMES
	z_prosocial z_prosocial2 prosocial_norm z_place z_risk z_fp z_pp z_NA z_PA ///standardized outcomes
	sealevel1 sealevel2 sealevel3 sealevel4 sealevel5 sealevel6 sealevel7 ///ADAPTATION STRATEGIES
	cc_pp cc_fp pp_drought pp_cyclones pp_slr fp_slr fp_drought fp_cyclones land_lost land_lost_size land_lost_value pc_livelihood pc_relocate number_extremes exp_extreme rebuild_frequency rebuild_days rebuild_costs prev_home_affected ///CC RELATED
	PA NA emo_neg e_depressed p1_upset p2_hostile p3_alert p4_ashamed p5_inspired p6_nervous p7_determined p8_attentive p9_afraid p10_active p11_hopeless p12_sad p13_helpless ///EMOTIONS
	h1 h2 h3 h4 h5 h6 h7 cc_contribution1 cc_contribution2 cc_contribution3 ///Who do you believe sould help you deal with the impacts of CC?
	not_primed payout assi_1 assi_2 assi_3 assi_4 assi_5 assi_6 assi_7 assi_8 ///interviewer dummies
	attention_score pct_as /*PRIMING RELATED*/

drop if assistant==5
save "$working_ANALYSIS\processed\study2_BD_clean.dta", replace



*--------------------------------------------------
* VIETNAM (2019)
*--------------------------------------------------
use "$working_ANALYSIS\data\study2_VN_raw.dta"


//SYNCHRONIZING VARIABLE NAMES
rename district_current area_current
rename district_previous area_previous
rename district_home area_home
rename migration_temp_divison migration_temp_area
rename migration_perm_divison migration_perm_area
rename mc_internal mc_city
rename cc_resettle_within_union cc_resettle_within_area
rename cc_resettle_different_union cc_resettle_different_area
rename assistance_cc cc_assistance
rename assistance_cc1 cc_assistance1
rename assistance_cc2 cc_assistance2
rename assistance_cc3 cc_assistance3
rename assistance_cc4 cc_assistance4
rename assistance_cc5 cc_assistance5
rename assistance_cc6 cc_assistance6
rename assistance_cc7 cc_assistance7
rename cc_adaptation1 sealevel1
rename cc_adaptation2 sealevel2
rename cc_adaptation3 sealevel3
rename cc_adaptation4 sealevel4
rename cc_adaptation5 sealevel5

*location
drop location

gen location =.
replace location = 31 if village == "Dat Mui"
replace location = 32 if village == "Tan An Tay"
replace location = 33 if village == "Nam Can"
replace location = 34 if village == "Cai Nuoc"
replace location = 35 if village == "Dam Doi"
replace location = 36 if village == "Ganh Hao"
replace location = 37 if village == "Nha Mat"
replace location = 38 if village == "Vinh Trach"
replace location = 39 if village == "Hiep Thanh"

lab var location "Where the survey took place"
lab def location_vn 31 "Dat Mui" 32 "Tan An Tay" 33 "Nam Can" 34 "Cai Nuoc" 35 "Dam Doi" 36 "Ganh Hao" 37 "Nha Mat" 38 "Vinh Trach" 39 "Hiep Thanh"
lab value location location_vn

*treatments
tab treatment, gen(t)
label var t2 "Community"
label var t3 "Individual"
label var t1 "control"
gen exp_nohelp=0
replace exp_nohelp=1 if rel_assistance==1
gen exp_extreme=0
replace exp_extreme=1 if number_extremes>0
replace not_primed = 0 if treatment== 0


*standardize variables
egen z_prosocial=std(dg)
egen z_prosocial2=std(dg)
replace risk=20000-risk
egen z_risk=std(risk)
lab var z_prosocial "Higher values imply more pro-social"
lab var z_risk "Higher values imply more risk aversion"
egen z_place=std(place_attachment)
egen z_fp=std(cc_fp)
egen z_pp=std(cc_pp)
egen z_NA=std(NA)
egen z_PA=std(PA)
egen m_place=median(place_attachment)
gen d_place=0
replace d_place=1 if place_attachment > m_place
replace payout = payout/ 23209 /*1 USD = 23209 Dong*/
gen survey_trust=trust/2

*normalize outcomes
qui summ dg
gen prosocial_norm = (dg - r(min)) / (r(max) - r(min))

qui summ risk
gen risk_aversion_norm = (risk - r(min)) / (r(max) - r(min))
qui summ survey_time
gen patience_norm = (survey_time - r(min)) / (r(max) - r(min))
qui summ trust
gen trust_norm = (trust - r(min)) / (r(max) - r(min))


// Climate Change Perception

*PAST PERCEPTION OF CC IMPACTS
drop cc_pp pp_drought pp_cyclones pp_slr cc_pp
egen pp_drought=rowmean(cc_perception_past1 cc_perception_past2_r)
lab var pp_drought "Droughts more frequent and intense"
egen pp_cyclones=rowmean(cc_perception_past3 cc_perception_past4 )
lab var pp_cyclones "Cyclones more frequent,more frequent heavy rains and more sever floods"
egen pp_slr=rowmean(cc_perception_past6 cc_perception_past7 cc_perception_past8)
lab var pp_slr "Sea level is higher, more intense saltwater intrusion and coastal erosion"
egen cc_pp=rowmean(cc_perception_past1 cc_perception_past2_r cc_perception_past3 cc_perception_past4 cc_perception_past6 cc_perception_past7 cc_perception_past8)
labe var cc_pp "Higher values imply stronger approval that CC impacts did happen."

*FUTURE PERCEPTION OF CC IMPACTS
drop cc_fp fp_drought fp_cyclones fp_slr
egen fp_drought=rowmean(cc_expectation1 cc_expectation2_r)
lab var fp_drought "Droughts more frequent and intense"
egen fp_cyclones=rowmean(cc_expectation3 cc_expectation4)
lab var fp_cyclones "Cyclones more frequent,more frequent heavy rains and more sever floods"
egen fp_slr=rowmean(cc_expectation6 cc_expectation7 cc_expectation8)
lab var fp_slr "Sea level is higher, more intense saltwater intrusion and coastal erosion"
egen cc_fp=rowmean(cc_expectation1 cc_expectation2_r cc_expectation3 cc_expectation4 cc_expectation6 cc_expectation7 cc_expectation8)
labe var cc_fp "Higher values imply stronger approval that CC impacts will happen."



*Adaptation
rename cc_adaptation6 sealevel6
rename cc_adaptation7 sealevel7
label var sealevel1 "Sea walls" 
label var sealevel2 "Plant mangroves" 
label var sealevel3 "Restore beach" 
label var sealevel4 "Migrate" 
label var sealevel5 "Move within village" 

*Labelling
lab var age "Age(years)"
lab var edu "Education (years)"
lab var income_hh "Monthly household income(converted to USD)"
lab var income "Monthly income(converted to USD)"
lab var people_hh "Household size"
lab var income_meals_month "HH had to reduce meals?"
lab var female "Female"
lab var married "Married"
lab var village_same "Born in this village"
lab var rebuild "Did you have to rebuild your house at the place you currently live?"
lab var land_lost "Did you lose any land because of erosion?"
lab var land_lost_size "How much land did you lose? (in XX)"
lab var land_lost_value "Value in USD of lost land?"


// PCA: AFFECTEDNESS INDEX
gen rebuild_house = 0 if rebuild_frequency==0
replace rebuild_house = 1 if rebuild_frequency > 0
replace rebuild_house = . if rebuild_frequency < 0 | rebuild_frequency ==.

global affectedness pc_livelihood pc_relocate number_extremes land_lost rebuild_house
pwcorr $affectedness, sig
alpha $affectedness
pca $affectedness, comp(1)
estat loadings
predict pc1, score
estat kmo // probably does not make sense to combine these variables into one factor, kmo=0.61 -> okay
sum pc1
gen pca_affected=pc1

egen med_affected = median(pca_affected)
gen affected = 0 if pca_affected < med_affected
replace affected = 1 if pca_affected >= med_affected

*Past migration experience
gen cc_relocate = 0 if cc_resettle_within_area==0 & cc_resettle_different_area == 0
replace cc_relocate = 1 if cc_resettle_within_area> 0 | cc_resettle_different_area > 0 
replace cc_relocate = . if cc_resettle_within_area == .



*keep variables that are needed for analysis
keep id assistant date district village location treatment treated affected pca_affected t1 t2 t3 female age married edu prayer religion people_hh village_same home income income_hh income_ppp income_hh_ppp asset_sum hh_worse_off rel_wealth1 rel_wealth2 rel_wealth3 income_meals_month income_meals_frequency ///SETUP & SOCIO
	dg dg_percent risk csc cfe PA NA com1 com2 com3 use_hypo2 use_hypo1 env_health env_water env_soil env_forest reciprocity revenge survey_trust place_identity place_dependence place_attachment survey_time life_satisfaction comunity_activities ///MEASURED OUTCOMES
	z_prosocial z_prosocial2 prosocial_norm z_place z_risk z_fp z_pp z_NA z_PA patience_norm risk_aversion_norm trust_norm  ///standardized outcomes
	sealevel1 sealevel2 sealevel3 sealevel4 sealevel5 sealevel6 sealevel7 ///ADAPTATION STRATEGIES
	cc_pp cc_fp fp_slr pp_slr pp_drought pp_cyclones fp_drought fp_cyclones cc_loc land_lost land_lost_size land_lost_value pc_livelihood pc_relocate number_extremes exp_extreme rebuild_house rebuild_frequency rebuild_days rebuild_costs pca_affected cc_relocate cc_perception_past1 cc_perception_past2 cc_perception_past3 cc_perception_past4 cc_perception_past6 cc_perception_past7 cc_perception_past8 cc_perception_past9 cc_expectation1 cc_expectation2 cc_expectation3 cc_expectation4 cc_expectation6 cc_expectation7 cc_expectation8 cc_expectation9 	 ///CC RELATED
	p1_upset p2_hostile p3_alert p4_ashamed p5_inspired p6_nervous p7_determined p8_attentive p9_afraid p10_active ///EMOTIONS
	cc_assistance1 cc_assistance2 cc_assistance3 cc_assistance4 cc_assistance5 cc_assistance6 cc_assistance7 cc_contribution1 cc_contribution2 cc_contribution3 ///Who do you believe sould help you deal with the impacts of CC?
	payout assi1 assi2 assi3 assi4 assi5 assi6 assi7 assi8 assi9 assi10 ///interviewer dummies
	rdy_tomove not_primed  rel_assistance exp_nohelp rel_scenario rel_way rel_job rel_so rel_belief /// priming worked?
	kw p_difficult p_direction t1_not t2_not t1_keywords t1_keywords1 t1_keywords2 t1_keywords3 t1_keywords4 t1_keywords5 t1_keywords6 t1_keywords7 t1_keywords8 t1_keywords9 t1_keywords10 t1_keywords11 t1_keywords12 t1_keywords13 t1_difficult t1_direction t2_video t2_keywords t2_keywords1 t2_keywords2 t2_keywords3 t2_keywords4 t2_keywords5 t2_keywords6 t2_keywords7 t2_keywords8 t2_keywords9 t2_keywords10 t2_keywords11 t2_keywords12 t2_keywords13 t2_keywords14 t2_difficult t2_direction/*PRIMING RELATED*/

order id assistant date district village treatment treated affected t1 t2 t3 female age married edu prayer religion people_hh village_same home income income_hh income_ppp income_hh_ppp hh_worse_off rel_wealth1 rel_wealth2 rel_wealth3 income_meals_month income_meals_frequency ///SETUP & SOCIO
	dg dg_percent risk csc cfe PA NA com1 com2 com3 use_hypo2 use_hypo1 env_health env_water env_soil env_forest reciprocity revenge survey_trust place_identity place_dependence place_attachment survey_time life_satisfaction comunity_activities ///MEASURED OUTCOMES
	z_prosocial z_prosocial2 z_place z_risk z_fp z_pp z_NA z_PA ///standardized outcomes
	sealevel1 sealevel2 sealevel3 sealevel4 sealevel5 sealevel6 sealevel7 ///ADAPTATION STRATEGIES
	cc_pp cc_fp cc_loc land_lost land_lost_size land_lost_value pc_livelihood pc_relocate number_extremes exp_extreme rebuild_frequency rebuild_days rebuild_costs ///CC RELATED
	p1_upset p2_hostile p3_alert p4_ashamed p5_inspired p6_nervous p7_determined p8_attentive p9_afraid p10_active ///EMOTIONS
	cc_assistance1 cc_assistance2 cc_assistance3 cc_assistance4 cc_assistance5 cc_assistance6 cc_assistance7 cc_contribution1 cc_contribution2 cc_contribution3 ///Who do you believe sould help you deal with the impacts of CC?
	payout assi1 assi2 assi3 assi4 assi5 assi6 assi7 assi8 assi9 assi10 ///interviewer dummies
	rdy_tomove not_primed  rel_assistance exp_nohelp rel_scenario rel_way rel_job rel_so rel_belief /// priming worked?
	kw p_difficult p_direction t1_not t2_not t1_keywords t1_keywords1 t1_keywords2 t1_keywords3 t1_keywords4 t1_keywords5 t1_keywords6 t1_keywords7 t1_keywords8 t1_keywords9 t1_keywords10 t1_keywords11 t1_keywords12 t1_keywords13 t1_difficult t1_direction t2_video t2_keywords t2_keywords1 t2_keywords2 t2_keywords3 t2_keywords4 t2_keywords5 t2_keywords6 t2_keywords7 t2_keywords8 t2_keywords9 t2_keywords10 t2_keywords11 t2_keywords12 t2_keywords13 t2_keywords14 t2_difficult t2_direction/*PRIMING RELATED*/

drop if treatment==.
drop if dg==.
save "$working_ANALYSIS\processed\study2_VN_clean.dta", replace






*--------------------------------------------------
* CREATE POOLED DATASET FOR ANALYSIS OF STUDY 2
*--------------------------------------------------

* Cleanup: Solomon Islands
use "$working_ANALYSIS\processed\study2_SI_clean.dta"
replace location = 2 if village == 1| village == 12
gen country_id=1
drop z_prosocial
egen z_prosocial=std(svo_in_r2)
gen difference_baseline = svo_in_r1-svo_out_r1
gen difference_primed = svo_in_r2-svo_out_r2
gen affected=0 if location==1
replace affected=1 if location==3
rename location si_study_sites
drop  location2
rename village location 
save "$working_ANALYSIS\processed\study2_SI_clean.dta", replace

* Cleanup: Bangladesh
use "$working_ANALYSIS\processed\study2_BD_clean.dta",clear
gen country_id=2
rename treatment treatment_bd
gen PA_bd = PA/5
drop z_prosocial
egen z_prosocial=std(dg)
save "$working_ANALYSIS\processed\study2_BD_clean.dta", replace

* Cleanup: Vietnam
use "$working_ANALYSIS\processed\study2_VN_clean.dta",clear
gen country_id=3
rename treatment treatment_vn
drop z_prosocial
egen z_prosocial=std(dg)
save "$working_ANALYSIS\processed\study2_VN_clean.dta", replace

* Merge all three datasets
clear all
use "$working_ANALYSIS\processed\study2_VN_clean.dta"
append using "$working_ANALYSIS\processed\study2_BD_clean.dta", force
append using "$working_ANALYSIS\processed\study2_SI_clean.dta", force

*--------------------------------------------------
* GENERATE ADDITIONAL VARIABLES FOR STUDY 2
*--------------------------------------------------

* LOCATION IDENTIFIER AND UNIQUE ID
label var country_id "Source of data"
label define country_l 1 "Solomon Islands" 2 "Bangladesh" 3 "Vietnam"
label values country_id country_l
lab def treated1 0 "Control" 1 "Treatment: SLR information", replace
lab val treated treated1

* district identifier
label define location 2 "Malapu" 3 "Malubu" 4 "Mataniko" 5 "Matema" 6 "Nganamola" 7 "Ngandeli" 8 "Ngawa" 9 "Nifiloli" 10 "Nola" 11 "Pileni" 13 "Tanga" 14 "Tuwo" 15 "Vura" 21 "Amragachhia" 22 "Bhandaria" 23 "Dapdapia" 24 "Padri Shibpur " 25 "Roy Pasha Karapur" 26 "Shikarpur" 27 "Sholak" 31 "Dat Mui" 32 "Tan An Tay" 33 "Nam Can" 34 "Cai Nuoc" 35 "Dam Doi" 36 "Ganh Hao" 37 "Nha Mat" 38 "Vinh Trach" 39 "Hiep Thanh"
label values location location

* sample identifier
gen sample = 1 if location==1 & country_id==1
replace sample = 2 if location==3 & country_id==1
replace sample=3 if country_id==2 & affected==0
replace sample=4 if country_id==2 & affected==1
replace sample=5 if country_id==3 & affected==0
replace sample=6 if country_id==3 & affected==1
lab def l1 1 "SI: Main Islander" 2  "SI: Atoll Islanders" 3 "BD: affected" ///
	4 "BD: more affected" 5 "VN: affected" 6 "VN: more affected", replace
lab val sample l1
label var sample "Source of data"

lab def affected_l 0 "less affected" 1 "more affected", replace
lab val affected affected_l

* Relocation certainty due to SLR
replace relocation = 0 if pc_relocate < 10
replace relocation = 1 if pc_relocate == 10
gen treated_relocate = treated*relocation

gen rel_certainty=0
replace rel_certainty=1 if d3==1
replace rel_certainty=2 if relocation==1
replace rel_certainty=1 if  (pc_relocate>2 & pc_relocate <8) & country_id > 1
replace rel_certainty=2 if  pc_relocate>7  & country_id > 1
lab def rel_lab 0 "very unlikely" 1 "uncertain when" 2 "absolutely certain", replace
lab val rel_certainty rel_lab
lab var rel_certainty "Do people think they will have to relocate because of climate change?"

* Considered adaptation strategies
egen n_adapt=rowtotal(sealevel1 sealevel2 sealevel3 sealevel4 sealevel5)
gen only_local=0
replace only_local=1 if n_adapt>0 & sealevel4==0

gen adapt1=0 if n_adapt==0
replace adapt1=1 if only_local==1
replace adapt1=2 if sealevel4==1 & n_adapt==1
replace adapt1=3 if n_adapt>1 & sealevel4==1

lab def l_adapt1 0 "Do nothing" 1 "Only local" 2 "Only Migration" 3 "Local & Migration", replace
lab val adapt1 l_adapt1

tab adapt1, gen(strat)

replace number_extremes=. if number_extremes==-1
*categorize as l,long-term maladaptation based on considered adaptation actions
gen maladaptation=1 if adapt1==0 | adapt1==1
replace maladaptation=0 if adapt1==2 | adapt1==3
lab def mal1 0 "leave" 1 "stay", replace
lab val maladaptation mal1

*Considering the future effects of climate change (sea level rise, heavy rainfall, floods, droughts), who do you believe should help you to deal with the consequences?
egen n_help=rowtotal(h1 h2 h3 h4 h5 h6 h7)
gen only_gov=0
replace only_gov=1 if h1==1 & n_adapt==1
gen only_ngo=0
replace only_ngo=1 if h2==1 & n_adapt==1

gen help_local = 0
replace help_local = 1 if  h4==1 | h5==1 | h6==1
replace help_local = 0 if h1==1 | h2==1 | h3==1

gen help_outside = 0
replace help_outside = 1 if h1==1 | h2==1 | h3==1
replace help_outside = 0 if h4==1 | h5==1 | h6==1


* Standardized explanatory variables
gen no_ca=0
replace no_ca=1 if community_activities==5
replace no_ca=1 if comunity_activities==0
gen collective_action = 1-no_ca
lab var collective_action "Did participate at least once in collective community activities in the past year."
gen std_edu=0 if edu==0
replace std_edu=1 if (edu > 0 & edu <7)
replace std_edu=2 if (edu > 6 & edu <=18)
lab def edu1 0 "No education" 1 "Primary" 2 "Secondary or more"
lab val std_edu edu1
tab location, gen(loc_)
tab std_edu, gen(edu_)


sort country_id
foreach x of varlist income lot_score survey_trust survey_time reciprocity revenge {
	egen m_`x' = mean(`x'), by(country_id)
	egen sd_`x' = sd(`x'), by(country_id)
	by country_id: gen z_`x' = (`x'-m_`x')/sd_`x'
	}


* Interviewer dummies
replace assistant=. if country_id==1
replace assistant=8+assistant if country_id==3
replace assistant=. if assistant==18

* PPP adjusted income
replace income_ppp = 0 if income_ppp<0
replace income_hh_ppp = 0 if income_hh_ppp<0
replace income_ppp=. if income_ppp > 10000
replace income_hh_ppp=. if income_hh_ppp > 10000
gen income_hh_ppp100 = income_hh_ppp/100

*get rid of extreme outliers in migration costs, income and value of owned assets
gen asset_sum_adjusted_hh= asset_sum/people_hh
replace asset_sum_adjusted_hh=. if asset_sum==. & people_hh==.

*Negative emotions
replace NA = NA/5
lab var NA "Additive negative affect index [1, 5]"

egen NA_bd = rowmean(p9_afraid p6_nervous p4_ashamed p3_alert p2_hostile p1_upset p13_helpless p12_sad p11_hopeless) if country_id==2

*interaction treatment and affected / place attachment
gen treated_affected = treated*affected
gen treated_place = treated*z_place


// ORGANIZE DATASET
sort country_id female married age edu people_hh income income_hh 
drop id
gen id=_n
lab var id "Unique identifier"


keep id country_id sample location si_study_sites village village_same a10 treated affected treated_affected pca_affected treated_place treatment_vn female married age std_edu edu people_hh z_income income income_hh_ppp100 income_hh income_ppp income_hh_ppp asset_sum asset_sum_adjusted_hh  hh_worse_off ///SETUP & SOCIO
	svo_in_r1 svo_in_r2 svo_in_r1_type svo_in_r2_type svo_out_r1 svo_out_r2 dg dg_percent NA NA_bd PA PA_bd  place_identity place_dependence place_attachment  collective_action lot_score life_satisfaction survey_time patience survey_risk risk survey_trust z_reciprocity reciprocity z_revenge revenge csc ///measured outcomes
	z_prosocial z_prosocial2 difference_baseline difference_primed z_place z_risk z_lot z_survey_trust z_survey_time z_patience z_fp z_pp z_NA z_PA z_psp_out2 send_in_r1 send_in_r2 send_out_r1 send_out_r2 prosocial_norm patience_norm risk_aversion_norm trust_norm  ///standardized outcomes
	rel_certainty n_adapt maladaptation adapt1 strat1 strat2 strat3 strat4 sealevel1 sealevel2 sealevel3 sealevel4 sealevel5 sealevel6 sealevel7 ///ADAPTATION STRATEGIES
	cc_pp cc_fp pp_slr pp_drought pp_cyclones fp_slr fp_drought fp_cyclones cc_loc land_lost land_lost_size land_lost_value pc_livelihood pc_relocate rel_assistance relocation number_extremes rebuild_house exp_extreme rebuild_frequency rebuild_days rebuild_costs  cc_relocate cc_perception_past1 cc_perception_past2 cc_perception_past3 cc_perception_past4 cc_perception_past6 cc_perception_past7 cc_perception_past8 cc_perception_past9 cc_expectation1 cc_expectation2 cc_expectation3 cc_expectation4 cc_expectation6 cc_expectation7 cc_expectation8 cc_expectation9 ///CC RELATED
	h1 h2 h3 h4 h5 h6 h7 cc_contribution1 cc_contribution2 cc_contribution3 n_help only_gov only_ngo help_local help_outside ///Who do you believe sould help you deal with the impacts of CC?
	p1_upset p2_hostile p3_alert p4_ashamed p5_inspired p6_nervous p7_determined p8_attentive p9_afraid p10_active p11_hopeless p12_sad p13_helpless /// emotions
	rel_scenario not_primed session_ID payout assistant assi1 assi2 assi3 assi4 assi5 assi6 assi7 assi8 assi9 assi10 assi_1 assi_2 assi_3 assi_4 assi_5 assi_6 assi_7 assi_8 ///interviewer dummies
	f1a_friends f1b_relatives f1c_conflict /// payment, friends and relatives in session
		one_shot repeated rounds q1_tg q2_tg q3_tg q4_tg q5_tg q_score_tg position tg_partner tg_1 tg_exp1 tg_2 tg_exp2 tg_3 tg_exp3 tg_4 tg_exp4 tg_5 tg_exp5 tg_6 tg_exp6 tg_7 tg_exp7 tg_8 tg_exp8 tg_9 tg_exp9 ///TG


order id country_id sample  treated affected treated_affected treatment_vn female married age std_edu edu people_hh z_income income income_hh income_ppp income_hh_ppp hh_worse_off ///SETUP & SOCIO
	svo_in_r1 svo_in_r2 difference_baseline difference_primed svo_in_r1_type svo_in_r2_type dg dg_percent NA NA_bd PA  place_identity place_dependence place_attachment  collective_action lot_score life_satisfaction survey_time survey_risk survey_trust z_reciprocity reciprocity z_revenge revenge csc ///measured outcomes
	z_prosocial z_prosocial2 z_place z_risk z_lot z_survey_trust z_survey_time z_fp z_pp z_NA z_PA z_psp_out2 send_in_r1 send_in_r2 send_out_r1 send_out_r2 ///standardized outcomes
	rel_certainty n_adapt maladaptation adapt1 strat1 strat2 strat3 strat4 sealevel1 sealevel2 sealevel3 sealevel4 sealevel5 sealevel6 sealevel7 ///ADAPTATION STRATEGIES
	cc_pp cc_fp pp_slr pp_drought pp_cyclones fp_slr fp_drought fp_cyclones cc_loc land_lost land_lost_size land_lost_value pc_livelihood pc_relocate rel_assistance relocation number_extremes exp_extreme rebuild_frequency rebuild_days rebuild_costs ///CC RELATED
	h1 h2 h3 h4 h5 h6 h7 cc_contribution1 cc_contribution2 cc_contribution3 n_help only_gov only_ngo help_local help_outside ///Who do you believe sould help you deal with the impacts of CC?
	p1_upset p2_hostile p3_alert p4_ashamed p5_inspired p6_nervous p7_determined p8_attentive p9_afraid p10_active p11_hopeless p12_sad p13_helpless /// emotions
	rel_scenario not_primed session_ID payout assistant assi1 assi2 assi3 assi4 assi5 assi6 assi7 assi8 assi9 assi10 assi_1 assi_2 assi_3 assi_4 assi_5 assi_6 assi_7 assi_8 ///interviewer dummies
		one_shot repeated rounds q1_tg q2_tg q3_tg q4_tg q5_tg q_score_tg position tg_partner tg_1 tg_exp1 tg_2 tg_exp2 tg_3 tg_exp3 tg_4 tg_exp4 tg_5 tg_exp5 tg_6 tg_exp6 tg_7 tg_exp7 tg_8 tg_exp8 tg_9 tg_exp9 ///TG

	
save "$working_ANALYSIS\processed\study2_ready.dta", replace





** EOF
