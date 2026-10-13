 ==============================================================================
 Card & Krueger (1994) AER 复现 Stata 代码
 数据文件要求: public.csv
 ==============================================================================
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
* 仅保留有效起薪数据
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
	
	


* ==============================================================================
* 2. 复现并导出 Table 2 到 Excel (D:/Table2_Replication.csv)
* ==============================================================================
eststo t2_nj: estpost summarize fte1 fte2 wage_st wage_st2 meal1 meal2 if state == 1, listwise
eststo t2_pa: estpost summarize fte1 fte2 wage_st wage_st2 meal1 meal2 if state == 0, listwise

* 利用 esttab 导出为 csv 格式，Excel 可以直接完美双击打开
esttab t2_nj t2_pa using "D:/Table2_Replication.csv", replace ///
    cells("mean(fmt(2)) sd(fmt(2))") ///
    collabels("New Jersey (Mean/SD)" "Pennsylvania (Mean/SD)") ///
    plain


	

gen balanced = (!missing(fte1) & !missing(fte2))  

* 定义 NJ 内部起薪组别 (Table 3 的第 iv, v, vi 列)
gen nj_wage_grp = .
replace nj_wage_grp = 1 if state == 1 & wage_st == 4.25
replace nj_wage_grp = 2 if state == 1 & wage_st > 4.25 & wage_st < 5.00
replace nj_wage_grp = 3 if state == 1 & wage_st >= 5.00 & !missing(wage_st)

* 3. 利用 estpost 和 esttab 将 Table 3 所需的核心均值及 DID 结果打包导出
capture ssc install estout, replace
eststo clear

* (1) 全样本及各州均值与变化量
eststo t3_nj: estpost summarize fte1 fte2 dfte if state == 1
eststo t3_pa: estpost summarize fte1 fte2 dfte if state == 0

* (2) 跨州双差检验 (DID)
eststo t3_did: estpost ttest dfte, by(state)

* (3) NJ 内部不同起薪组的就业变化量
eststo nj_low:  estpost summarize dfte if nj_wage_grp == 1
eststo nj_mid:  estpost summarize dfte if nj_wage_grp == 2
eststo nj_high: estpost summarize dfte if nj_wage_grp == 3

* 4. 导出为 CSV 文件（可用 Excel 直接双击打开）
esttab t3_nj t3_pa t3_did nj_low nj_mid nj_high using "D:/6067/Table3_Replication_Detailed.csv", replace ///
    cells("mean(fmt(2)) sd(fmt(2)) count(fmt(0))") ///
    collabels("NJ_Stats" "PA_Stats" "DID_Test" "NJ_Wage_4.25" "NJ_Wage_Mid" "NJ_Wage_High") ///
    plain ///
    title("Table 3 Replication: Employment Levels, Changes and DID Estimates")


	

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
