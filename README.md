# Replication Package
This repository contains the information videos used in the treatments, as well as the data and code that replicates tables and figures for the following paper: <br>
__Title:__ Prosociality as response to slow- and fast-onset climate hazards <br>
__Authors:__ Ivo Steimanis1 & Björn Vollan1,* <br>
__Affiliations:__ 1 Department of Economics, Philipps University Marburg, 35032 Marburg, Germany <br>
__*Correspondence to:__ Björn Vollan bjoern.vollan@wiwi.uni-marburg.de <br>
__ORCID:__ Steimanis: 0000-0002-8550-4675; Vollan: 0000-0002-5592-4185 <br>
__Classification:__ Social Sciences, Economic Sciences <br>
__Keywords:__ climate hazards, prosociality, in-group favoritism, antisociality <br>

## Treatments: Information videos
In order to channel participant’s thoughts on potential consequences caused by SLR we used three-minute-long videos:
- ‘treatment_SI.mp4’ is the treatment video used in Solomon Islands 
- ‘treatment_BD.mp4’ is the treatment video used in Bangladesh
- ‘control_BD.mp4’ is the control video used in Bangladesh
- ‘treatment_individual_VN.mp4’ is the individual relocation treatment video used in Vietnam
- ‘treatment_community_VN.mp4’ is the community relocation treatment video used in Vietnam
- ‘control_VN.mp4’ is the control video used in Vietnam

## License
The data are licensed under a Creative Commons Attribution 4.0 International Public License. The code is licensed under a Modified BSD License. See __LICENSE.txt__ for details.

## Software requirements
All analysis were done in Stata version 16:
- Add-on packages are included in __scripts/libraries/stata__ and do not need to be installed by user. The names, installation sources, and installation dates of these packages are available in __scripts/libraries/stata/stata.trk__.

## Instructions
1.	Save the folder __‘replication_GSUS’__ to your local drive.
2.	Open the master script __‘run.do’__ and change the global pointing to the working direction (line 20) to the location where you save the folder on your local drive 
3.	Run the master script __‘run.do’__  to replicate the analysis and generate all tables and figures reported in the paper and supplementary online materials

## Datasets
- Study 1 – Fast-onset hazards (Philippines): The raw experimental dataset is named ‘study1_raw.dta’
- Study 2 – Slow-onset hazards (Solomon Islands, Bangladesh, Philippines): The raw experimental datasets are named ‘study2_SI_raw.dta’, ‘study2_BD_raw.dta’, and ‘study2_VN_raw.dta’

## Descriptions of scripts
__01_clean_data.do__ 
This script processes the raw experimental data from all study sites data and prepares it for analysis.
__02_analysis.do__
This script estimates regression models in Stata, creates figures and tables, saving them to __results/figures__ and __results/tables__
