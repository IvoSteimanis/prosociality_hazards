*-------------------------------------------------------------------------------------------------------
* OVERVIEW
*-------------------------------------------------------------------------------------------------------
*   This script generates tables and figures reported in the manuscript and SOM of the paper:
*   "Prosociality as response to slow- and fast-onset climate hazards"
*	Author: Ivo Steimanis, Philipps University Marburg
*   All experimental data are stored in /data
*   All figures reported in the main manuscript and SOM are outputted to /results/figures
*   All tables areported in the main manuscript and SOM are outputted to /results/tables
* TO PERFORM A CLEAN RUN, DELETE THE FOLLOWING TWO FOLDERS:
*   /processed
*   /results
*-------------------------------------------------------------------------------------------------------


*--------------------------------------------------
* Set global Working Directory
*--------------------------------------------------
* Define this global macro to point where the replication folder is saved locally that includes this run.do script
global working_ANALYSIS "YourPath"


*--------------------------------------------------
* Program Setup
*--------------------------------------------------
* Initialize log and record system parameters
clear
set more off
cap mkdir "$working_ANALYSIS/scripts/logs"
cap log close
local datetime : di %tcCCYY.NN.DD!-HH.MM.SS `=clock("$S_DATE $S_TIME", "DMYhms")'
local logfile "$working_ANALYSIS/scripts/logs/`datetime'.log.txt"
log using "`logfile'", text

di "Begin date and time: $S_DATE $S_TIME"
di "Stata version: `c(stata_version)'"
di "Updated as of: `c(born_date)'"
di "Variant:       `=cond( c(MP),"MP",cond(c(SE),"SE",c(flavor)) )'"
di "Processors:    `c(processors)'"
di "OS:            `c(os)' `c(osdtl)'"
di "Machine type:  `c(machine_type)'"

*   Analyses were run on Windows using Stata version 16
version 16              // Set Version number for backward compatibility

* All required Stata packages are available in the /libraries/stata folder
tokenize `"$S_ADO"', parse(";")
while `"`1'"' != "" {
  if `"`1'"'!="BASE" cap adopath - `"`1'"'
  macro shift
}
adopath ++ "$working_ANALYSIS/scripts/libraries/stata"
mata: mata mlib index

* Create directories for output files
cap mkdir "$working_ANALYSIS/processed"
cap mkdir "$working_ANALYSIS/results"
cap mkdir "$working_ANALYSIS/results/intermediate"
cap mkdir "$working_ANALYSIS/results/tables"
cap mkdir "$working_ANALYSIS/results/figures"
* -------------------------------------------------


*--------------------------------------------------
* Run processing and analysis scripts
*--------------------------------------------------
do "$working_ANALYSIS\scripts\01_clean_data.do"
do "$working_ANALYSIS\scripts\02_analysis.do"

 
* End log
di "End date and time: $S_DATE $S_TIME"
log close
 
 
 
** EOF