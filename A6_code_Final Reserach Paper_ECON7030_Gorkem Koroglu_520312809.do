

*-----------------------------------------------------------------------------
"File Name: A6_code_Final Reserach Paper_ECON7030_Gorkem Koroglu_520312809"
"Creator: Gorkem Koroglu"
"Date: 6 November 2024"
"Data Access Link: 'https://unisydneyedu-my.sharepoint.com/:u:/g/personal/gkor2280_uni_sydney_edu_au/Ece6k7HEnzFGocSPpOVL2GcBBgJiUU145b9RDkcrhaki_w?e=7Nowkd' "
*-----------------------------------------------------------------------------

*-----------------------------------------------------------------------------
					* DATA PREPARATION & PROCESSING * 
*-----------------------------------------------------------------------------
		
*-----------------------------------------------------------------------------
* Define working directory
*-----------------------------------------------------------------------------
local readdatadir "/Users/gorkis/Desktop/HILDA_econ7030/data"
local writedatadir "/Users/gorkis/Desktop/HILDA_econ7030/data"

set maxvar 20000	
use "`readdatadir'/Users/gorkis/Desktop/HILDA_econ7030/data/hilda_econ7030_cleaned", clear

// Data Check
** Total survey vawes -- vawes = years
xtset xwaveid wave
destring xwaveid, replace
xtset xwaveid wave

*-----------------------------------------------------------------------------
* Generate categorical variables of interest
*-----------------------------------------------------------------------------
tab wave

** 1) hhstate refers to the states and territories => create 8 dummy variables
tab hhstate 

gen nsw = 0
replace nsw = 1 if hhstate==1
label var nsw "NSW"

gen vic = 0
replace vic = 1 if hhstate==2
label var vic "VIC"

gen qld = 0
replace qld = 1 if hhstate==3
label var qld "QLD"

gen sa = 0
replace sa = 1 if hhstate==4
label var sa "SA"

gen wa = 0
replace wa = 1 if hhstate==5
label var wa "WA"

gen tas = 0
replace tas = 1 if hhstate==6
label var tas "TAS"

gen nt = 0
replace nt = 1 if hhstate==7
label var nt "NT"

gen act = 0
replace act = 1 if hhstate==8
label var act "ACT"

** 2) Section of the State (remoteness)
tab hhsos

* Remove 54 missing data and the 2 migratıry data the dataset
drop if hhsos==-7
drop if hhsos==4

gen majorurban = 0
replace majorurban = 1 if hhsos==0
label var majorurban "Major Urban"

gen otherurban = 0
replace otherurban = 1 if hhsos==1
label var otherurban "Other Urban"

gen boundedlocality = 0
replace boundedlocality = 1 if hhsos==2
label var boundedlocality "Bounded Locality"

gen ruralbalance = 0 
replace ruralbalance = 1 if hhsos==3
label var ruralbalance "Rural Balance"


** 3) Country of birth 
tab ancob

* Remove the Non-responding person
drop if ancob==-10
drop if ancob==-4

gen ausborn = 0 
replace ausborn = 1 if ancob==1101
label var ausborn "Born in Australia"

gen esb = 0
replace esb = 1 if ancob==1101 | ancob==1201 | ancob==2100 | ancob==2202 | ancob==8104 // Australia, New Zealand, UK, Ireland, US
label var esb "Born in ESB"

gen nesb = 0
replace nesb = 1 if ausborn==0 & esb==0
label var nesb "Born in NESB"

** 4) COVID-19 vaccination requirement at your current job or any previous job -- Available after 2022 (NOT WORK)
gen vaccreq = 0 
replace vaccreq = 1 if cvempj==1
replace vaccreq = 2 if cvempj==2
label var vaccreq "Vaccination Required"

// 5) Collectiveness of the Job -- Only in 2020 (NOT WORK)
drop if cvemp==-1

gen colbus = 0
replace colbus = 1 if cvemp==1 // worked for an employer for wages or salary
replace colbus = 2 if cvemp==2 // self-employed for wages or salary
replace colbus = 3 if cvemp==3 // both for wages or salary
label var colbus "Collectiveness of Business" // 

// 6) Highest Education Achieved -- edhigh1
drop if edhigh1==10

gen postgrad = 0
replace postgrad = 1 if edhigh1==1
label var postgrad "Masters or Doctorate"

gen graddip = 0
replace graddip = 1 if edhigh1==2
label var graddip "Grad Diploma or Grad Certificate"

gen bach = 0
replace bach = 1 if edhigh1==3
label var bach "Bachelor or Honours"

gen advdip = 0 
replace advdip = 1 if edhigh1==4
label var advdip "Advance Diploma or Diploma"

gen cert = 0 
replace cert = 1 if edhigh1==5
label var cert "Cert III or IV"

gen year12 = 0 
replace year12 = 1 if edhigh1==8
label var year12 "Cert III or IV"

gen year11b = 0 
replace year11b = 1 if edhigh1==9
label var year11b "Year 11 and below"

// 7) Age -- icagef2
drop if icagef2==-1

gen less18 = 0 
replace less18 = 1 if icagef2==1
label var less18 "Less than 18"

gen btwn = 0 
replace btwn = 1 if icagef2==2
label var btwn "Between 18-49"

gen more50 = 0 
replace more50 = 1 if icagef2==3
label var more50 "More than 50"

// 8) Sex -- hgsex1
gen sex=. 
replace sex = 1 if hgsex1==1	//male
replace sex = 0 if hgsex1==2	//female

// 9) Family Type -- hhfty
gen lone_cb15 = 0
replace lone_cb15 = 1 if hhfty==13
label var lone_cb15 "Lone parent with children < 15 wo others"

gen lone_dpst = 0
replace lone_dpst = 1 if hhfty==16
label var lone_dpst "Lone parent with dependents wo others"

gen lone_ndepc = 0
replace lone_ndepc = 1 if hhfty==19
label var lone_ndepc "Lone parent with non-dependent child wo others"

gen couple_nc = 0
replace couple_nc = 1 if hhfty==1
label var couple_nc "Couple parent without child wo others"

gen couple_cb15 = 0
replace couple_cb15 = 1 if hhfty==4
label var couple_cb15 "Couple parent with children < 15 wo others"

gen couple_dpst = 0
replace couple_dpst = 1 if hhfty==7
label var couple_dpst "Couple parent with dependents wo others"

*-----------------------------------------------------------------------------
* Generate continuous variables of interest
*-----------------------------------------------------------------------------
// 1) Income
rename wscme wagesmainnet	// this one used for income in the final analysis
label var wagesmainnet " Net Wages - main job"

// 2) Wealth -- The PC report (page 30): "Household net wealth (sometimes called net worth) is measured as the excess of total household assets (including superannuation) over total household liabilities."
sum hwassei hwsupei hwdebti
// hwassei == Household Total Assets [imputed] ($) [weighted topcode]
// hwsupei == Household wealth: Total superannuation [imputed] ($) [weighted topcode]
// hwdebti == Household Debt [imputed] ($) [weighted topcode]

gen hhwealth = hwassei + hwsupei - hwdebti
label var hhwealth "Household Wealth"
sum hhwealth

*-----------------------------------------------------------------------------
* Cleaning
*-----------------------------------------------------------------------------
** 1 ) Exclude top 1% and bottom 1% of the distribution
ssc install winsor2

// wagesmainnet
sum wagesmainnet,d
winsor2 wagesmainnet, cuts(1 99) trim by(wave) // new variable generated with suffix _tr
label var wagesmainnet_tr "Main Wages excl outliers (trimmed)"
sum wagesmainnet_tr, d


*-----------------------------------------------------------------------------
						* DATA ANALYSIS *
*-----------------------------------------------------------------------------
// Data Check
sum xwaveid // ID variable for each household
sum wave 
sum wagesmainnet_tr

*-----------------------------------------------------------------------------
* Track by ID 
*-----------------------------------------------------------------------------
** Only leave years 2019,20,21
drop if wave < 19
drop if wave==20
tab wave
sort xwaveid wave wagesmainnet_tr 

// drop if xwaveid does not repeat 2 times in the dataset (so that only 19 and 21 left)
egen count_xwaveid = count(xwaveid), by(xwaveid)

* Step 2: Drop individuals whose xwaveid does not repeat exactly 2 times
drop if count_xwaveid != 2
drop count_xwaveid

// Create an 'income decile' var
gen income_decile = .
replace income_decile = 1 if wagesmainnet_tr <= 442.31
replace income_decile = 2 if wagesmainnet_tr > 442.31 & wagesmainnet_tr <= 538.46
replace income_decile = 3 if wagesmainnet_tr > 538.46 & wagesmainnet_tr <= 653.85
replace income_decile = 4 if wagesmainnet_tr > 653.85 & wagesmainnet_tr <= 750
replace income_decile = 5 if wagesmainnet_tr > 750 & wagesmainnet_tr <= 884.62
replace income_decile = 6 if wagesmainnet_tr > 884.62 & wagesmainnet_tr <= 1000
replace income_decile = 7 if wagesmainnet_tr > 1000 & wagesmainnet_tr <= 1192.31
replace income_decile = 8 if wagesmainnet_tr > 1192.31 & wagesmainnet_tr <= 1403.85
replace income_decile = 9 if wagesmainnet_tr > 1403.85 & wagesmainnet_tr <= 1730.77
replace income_decile = 10 if wagesmainnet_tr > 1730.77


// Create 'difference' var 
bysort xwaveid (wave): gen difference = income_decile - income_decile[_n-1]
drop if difference == . 
tab difference // Output variable


*-----------------------------------------------------------------------------
				// Results -- UP UNTIL A5 (Presentation) //
sort xwaveid wave difference
tab difference // Output


// Histogram of the variable 'difference' by percentage frequency
histogram difference, percent ///
    title("Absolute Change in Income Decile in 2019-2020 and 2021-2022")  ///
    xtitle("Difference") /// Output
	xlabel(-9(1)9)
	
*-----------------------------------------------------------------------------
** Export the results
*-----------------------------------------------------------------------------
ssc install asdoc 
asdoc tab difference, save(Table_4_difference) // run Line 64	  

// Run Line 67 first, then run this:
graph export "Absolute Change in Income Decile in 2019-2020 and 2021-2022.png"	
	
	
*-----------------------------------------------------------------------------
* 2) Wealth Mobility 2019-2020 -- // Recent avalable data was in wave 18 (2018) in Release 21
*-----------------------------------------------------------------------------	

*-----------------------------------------------------------------------------
				// A6 -- Regression Analysis //
*-----------------------------------------------------------------------------
// Create a dummy var:
* =1 for those who moved up across deciles between 2019 & 2021​
* =0 for those who moved down across deciles between 2019 & 2021 

gen up_mobility = difference >= 1
	
// Run the regression to observe the link:
* Income - Education​: wagesmainnet_tr ~ postgrad, up_mobility
* Income - State​
* Income – Born in English speaking country​
* Income – Remoteness of the household​
* age -- rtage1 - employed age check 45
* age -- icagef2 - G28 Confirm age for female
* sex -- hgsex1 - sex

// Random Effects Probit Model 
** xtprobit is to apply probit regress on a panel data
xtprobit up_mobility postgrad bach nsw vic qld sa wa nt act majorurban ruralbalance esb less18 more50 sex lone_cb15 lone_dpst lone_ndepc couple_nc couple_cb15 couple_dpst, vce(robust)

// The independent vars could be correlated with the error term.
// So, adding "robust" corrects heteroskedasticity in error terms to be homoskedastic.

* export the table
ssc install estout
esttab using "regression_results.doc", replace  

// Correlation check
correlate postgrad bach nsw majorurban esb	// all checks


*-----------------------------------------------------------------------------
* Save
*-----------------------------------------------------------------------------	
save "/Users/gorkis/Desktop/HILDA_econ7030/data/hilda_econ7030_cleaned.dta", replace


























