 ==============================================================================
 Card & Krueger (1994) AER 复现 Stata 代码
 数据文件要求: public.csv
 ==============================================================================
clear all
set more off
*1. import data 
import delimited "public.csv", clear
*1.Variable Definition and Construction
 *Define the dummy variable for fast-food chain brands (1=Burger King, 2=KFC, 3=Roy Rogers, 4=Wendy's)
tab chain, gen(ch_)
 *variable declaration: ch_1: Burger King, ch_2: KFC, ch_3: Roy Rogers, ch_4: Wendy's
 
 *Calculate the number of full-time equivalent employees for the first period (FTE = full-time employee + 0.5 * part-time employee + manager)
gen fte1 = empft + 0.5 * emppt + nmgrs

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

*1. Descriptive statistics and mean comparison (corresponding to the paper, Table 2 & Table 3)
display "=== 1.Comparison of the average values of the basic variables in the two states (Wave 1) ==="
ttest fte1, by(state)
estimates store m1
ttest wage_st, by(state)
estimates store m2
ttest meal1, by(state)
estimates store m3
display "=== 2. Difference in employment changes between the two states (Difference-in-Differences, Table 3) ==="
esttab m1 m2 m3 using "regression_result.rtf", replace
reg dfte state if !missing(dfte)

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
esttab m1 m2 m3 m4 m5 m6 m7 m8 m9 m10 using "regression_result.rtf", replace
 
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
restore
