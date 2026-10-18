
clear all
set more off
*1. import data 
import delimited "public.csv", clear
rename *, lower
*1.Variable Definition and Construction
 *Define the dummy variable for fast-food chain brands (1=Burger King, 2=KFC, 3=Roy Rogers, 4=Wendy's)
tab chain, gen(ch_)
 *variable declaration: ch_1: Burger King, ch_2: KFC, ch_3: Roy Rogers, ch_4: Wendy's
 
 *Calculate the number of full-time equivalent employees for the first period (FTE = full-time employee + 0.5 * part-time employee + manager)
gen fte1 = empft + 0.5 * emppt + nmgrs

gen full1= empft/(empft+nmgrs)
gen full2= empft2/(empft2+nmgrs2)
 *Calculate the number of full-time equivalent employees for the second period
 *stores that have permanently closed down (status2 == 3)，Set the fte for the second period to 0; the rest will be calculated based on normal values.
gen fte2 = empft2 + 0.5 * emppt2 + nmgrs2
replace fte2 = 0 if status2 == 3

 *Change in employment volume (Wave 2 - Wave 1)
gen dfte = fte2 - fte1

 *Construct the initial wage gap variable (GAP)
*Formula Explanation：The value for the PA region is 0; for the NJ region, if the starting salary is greater than or equal to 5.05, the value is 0; otherwise, it is (5.05 - wage_st) / wage_st.
gen gap = 0
replace gap = (5.05 - wage_st) / wage_st if state == 1 & wage_st < 5.05 & !missing(wage_st)
replace gap = 0 if state == 1 & wage_st >= 5.05 & !missing(wage_st)

*Calculate the total price of the meal (Full meal price = Soda + French fries + Staple food)
gen meal1 = psoda + pfry + pentree
gen meal2 = psoda2 + pfry2 + pentree2

*Calculate the logarithmic price change of the entire meal (for Table 7)
gen dlnmeal = ln(meal2) - ln(meal1)


preserve

keep if !missing(wage_st) & !missing(wage_st2)

* ------------------------------------------------------------------------------
* Figure 1: New Jersey - February 1992 (Wave 1)
* ------------------------------------------------------------------------------
twoway histogram wage_st if state==1, discrete width(0.05) color(black) ///
       title("Figure 1A: New Jersey Starting Wages (Feb 1992)") ///
       xtitle("Starting Wage ($)") ytitle("Percent of Stores") ///
       xlabel(4.25(0.1)5.6)
graph export "D:/6067/Figure1_NJ_Feb1992.png", replace


* ------------------------------------------------------------------------------
* Figure 2: Pennsylvania - February 1992 (Wave 1)
* ------------------------------------------------------------------------------
twoway histogram wage_st if state==0, discrete width(0.05) fcolor(blue%60) lcolor(blue) ///
       title("Figure 1B: Pennsylvania Starting Wages (Feb 1992)") ///
       xtitle("Starting Wage ($)") ytitle("Percent of Stores") ///
       xlabel(4.25(0.1)5.6)
graph export "D:/6067/Figure1_PA_Feb1992.png", replace


* ------------------------------------------------------------------------------
* Figure 3: New Jersey - November 1992 (Wave 2)
* ------------------------------------------------------------------------------
twoway histogram wage_st2 if state==1, discrete width(0.05) color(black) ///
       title("Figure 1C: New Jersey Starting Wages (Nov 1992)") ///
       subtitle("Post Minimum Wage Increase to $5.05") ///
       xtitle("Starting Wage ($)") ytitle("Percent of Stores") ///
       xlabel(4.25(0.1)5.6)
graph export "D:/6067/Figure1_NJ_Nov1992.png", replace


* ------------------------------------------------------------------------------
* Figure 4: Pennsylvania - November 1992 (Wave 2)
* ------------------------------------------------------------------------------
twoway histogram wage_st2 if state==0, discrete width(0.05) fcolor(blue%60) lcolor(blue) ///
       title("Figure 1D: Pennsylvania Starting Wages (Nov 1992)") ///
       subtitle("Constant Minimum Wage at $4.25") ///
       xtitle("Starting Wage ($)") ytitle("Percent of Stores") ///
       xlabel(4.25(0.1)5.6)
graph export "D:/6067/Figure1_PA_Nov1992.png", replace

restore	
	
	
*table 2

tabulate chain if state == 1, matcell(freq_nj) matrow(cats)


tabulate chain if state == 0, matcell(freq_pa)


matrix pct_nj = freq_nj / 331 * 100
matrix pct_pa = freq_pa / 79 * 100


matrix table2 = freq_nj, pct_nj, freq_pa, pct_pa
matrix colnames table2 = NJ_Freq NJ_Pct PA_Freq PA_Pct
matrix rownames table2 = BurgerKing KFC RoyRogers Wendyes


matrix list table2

putexcel set "D:/6067/Table2_Matrix_Replication.xlsx", replace
putexcel A1 = ("Chain") B1 = ("NJ (N)") C1 = ("NJ (%)") D1 = ("PA (N)") E1 = ("PA (%)")
putexcel A2 = matrix(table2), names




eststo t2_nj: estpost summarize fte1 fte2 wage_st wage_st2 meal1 meal2 hrsopen hrsopen2 full1 if state == 1, listwise
eststo t2_pa: estpost summarize fte1 fte2 wage_st wage_st2 meal1 meal2 hrsopen hrsopen2 full2 if state == 0, listwise


esttab t2_nj t2_pa using "D:/6067/Table2_Rep.csv", replace ///
    cells("mean(fmt(2)) sd(fmt(2))") ///
    collabels("New Jersey (Mean/SD)" "Pennsylvania (Mean/SD)") ///
    plain


	


*Define balanced sample identifier (non-missing in both waves)
gen balanced = (!missing(fte1) & !missing(fte2))

/* STREAMING_CHUNK:Defining New Jersey initial wage groups... */

*Define New Jersey Initial Wage Groups (for Table 3 breakdown)
gen nj_wage_grp = .
replace nj_wage_grp = 1 if state == 1 & wage_st == 4.25
replace nj_wage_grp = 2 if state == 1 & wage_st > 4.25 & wage_st < 5.00
replace nj_wage_grp = 3 if state == 1 & wage_st >= 5.00 & !missing(wage_st)

/* STREAMING_CHUNK:Running summary statistics and Difference-in-Differences tests... */

*==============================================================================

*Replicating Table 3 (Means, Changes, and Difference-in-Differences)

*==============================================================================

display ""
display "TABLE 3 REPLICATION: OVERALL STATE MEANS & CHANGES"
display ""

*Summary for New Jersey (Balanced Sample)
display "-- New Jersey (State == 1) --"
summarize fte1 fte2 dfte if state == 1 & balanced == 1

*Summary for Pennsylvania (Balanced Sample)
display "-- Pennsylvania (State == 0) --"
summarize fte1 fte2 dfte if state == 0 & balanced == 1

*Cross-State Difference-in-Differences (Two-sample t-test on dfte by state)
display "-- Difference-in-Differences Test (NJ vs PA) --"
ttest dfte if balanced == 1, by(state)

/* STREAMING_CHUNK:Analyzing New Jersey intra-state wage tiers... */
display ""
display "TABLE 3 REPLICATION: NJ INTRA-STATE WAGE TIERS"
display ""

*Low wage tier ($4.25)
display "-- NJ Low-Wage Tier (Wage = $4.25) --"
summarize dfte if nj_wage_grp == 1 & balanced == 1

Midrange wage tier ($4.26 - $4.99)
display "-- NJ Mid-Wage Tier ($4.26 - $4.99) --"
summarize dfte if nj_wage_grp == 2 & balanced == 1

High wage tier (>= $5.00)
display "-- NJ High-Wage Tier (>= $5.00) --"
summarize dfte if nj_wage_grp == 3 & balanced == 1

/* STREAMING_CHUNK:Exporting Table 3 results to CSV... */

*Clean Export using estpost / esttab (if estout package is installed)
capture ssc install estout, replace
eststo clear

eststo t3_nj:   estpost summarize fte1 fte2 dfte if state == 1 & balanced == 1
eststo t3_pa:   estpost summarize fte1 fte2 dfte if state == 0 & balanced == 1
eststo nj_low:  estpost summarize dfte if nj_wage_grp == 1 & balanced == 1
eststo nj_mid:  estpost summarize dfte if nj_wage_grp == 2 & balanced == 1
eststo nj_high: estpost summarize dfte if nj_wage_grp == 3 & balanced == 1

esttab t3_nj t3_pa nj_low nj_mid nj_high using "Table3_Replication_Output.csv", replace ///
cells("mean(fmt(2)) sd(fmt(2)) count(fmt(0))") ///
collabels("NJ_Stats" "PA_Stats" "Wage_4.25" "Wage_Mid" "Wage_High") ///
title("Table 3 Replication: Employment Changes and DID Estimates")

display "Table 3 replication complete! Results saved to Table3_Replication_Output.csv."


	

*1. A simple regression model for employment changes (corresponding to Table 4 in the paper)
display "=== Table 4 Model (i): Contains only NJ dummy variables ==="
reg dfte state if !missing(dfte) & !missing(wage_st), robust
estimates store m1
display "=== Table 4 Model (ii): Incorporating the chain and the company's own store control variables ==="
reg dfte state ch_1 ch_3 ch_4 co_owned if !missing(dfte) & !missing(wage_st), robust
display "=== Table 4 Model (iii): Using GAP variables instead of NJ dummy variables ==="
estimates store m2
reg dfte gap if !missing(dfte) & !missing(wage_st), robust
estimates store m3
display "=== Table 4 Model (iv): Incorporating the chain and company-owned store control variables ==="
reg dfte gap ch_1 ch_3 ch_4 co_owned if !missing(dfte) & !missing(wage_st), robust
estimates store m4
display "=== Table 4 Model (v): Incorporating the control variables for chains and the company's own stores, as well as regions ==="
reg dfte gap ch_1 ch_3 ch_4 co_owned southj northj pa1 if !missing(dfte) & !missing(wage_st), robust
estimates store m5
esttab m1 m2 m3 m4 m5 using "regression_result.rtf", replace




*1. A simple regression model for the variation in the total meal price (corresponding to the paper's Table 7)
display "=== Table 7 Model (i): NJ dummy variable regression for price changes ==="
reg dlnmeal state if !missing(dlnmeal), robust
estimates store m6
display "=== Table 7 Model (ii): Incorporating Chain Stores and Company-Owned Store Control Variables ==="
reg dlnmeal state ch_1 ch_3 ch_4 co_owned if !missing(dlnmeal), robust
estimates store m7
display "=== Table 7 Model (iii): Price Regression Using GAP Variables ==="
reg dlnmeal gap if !missing(dlnmeal), robust
estimates store m8
display "=== Table 7 Model (iv): Incorporating the chain and company-owned store control variables ==="
reg dlnmeal gap ch_1 ch_3 ch_4 co_owned if !missing(dlnmeal), robust
estimates store m9
display "=== Table 7 Model (iv): Incorporating the control variables for chains and company-owned stores, as well as regions ==="
reg dlnmeal gap ch_1 ch_3 ch_4 co_owned southj northj pa1 if !missing(dfte) & !missing(wage_st), robust
estimates store m10
esttab m6 m7 m8 m9 m10 using "regression_result(dlnmeal).rtf", replace
 
*extension
preserve
keep if co_owned==0
reg dfte state ch_1 ch_3 ch_4 southj northj pa1 if !missing(dfte) & !missing(wage_st), robust
estimates store m11
reg dfte gap ch_1 ch_3 ch_4 southj northj pa1 if !missing(dfte) & !missing(wage_st), robust
estimates store m12
restore
esttab m11 m12 using "regression_result(heterogeneity co_owned==0).rtf", replace
preserve
keep if co_owned==1
reg dfte state ch_1 ch_3 ch_4 southj northj pa1 if !missing(dfte) & !missing(wage_st), robust
estimates store m13
reg dfte gap ch_1 ch_3 ch_4 southj northj pa1 if !missing(dfte) & !missing(wage_st), robust
estimates store m14
esttab m13 m14 using "regression_result(heterogeneity co_owned==1).rtf", replace
esttab m11 m12 m13 m14 using "regression_result(extension).rtf", replace
restore





