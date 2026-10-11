Guide to Reusable Stata Workflow Skills for Generating Empirical Tables and Figures
This guide breaks down the core, reusable Stata programming skills and code structures used in code.do to replicate Card & Krueger (1994). These workflow techniques can be applied across empirical economics projects to build data pipelines, compute variables, execute Difference-in-Differences (DiD) regressions, and export publication-ready tables.


Skill 1: Data Standardization and Preprocessing Pipeline
Purpose
To initialize a clean workspace, standardize variable naming conventions across different operating systems, and handle survey non-responses or structural missing values consistently.
Stata Template
* Initialize environment

clear all

set more off

* Import raw CSV dataset

import delimited "public.csv", clear

* Standardize all variable names to lower case

rename *, lower
Key Practices
Case Normalization (rename *, lower): Prevents syntax errors caused by inconsistent uppercase/lowercase column names in raw data (e.g., WAGE_ST vs. wage_st).
Deterministic Cleanup (clear all): Ensures that cached macros, scalars, or matrices from previous runs do not pollute current estimations.


Skill 2: Aggregation Metrics and Sample-Adjustment Rules
Purpose
To construct composite economic variables—such as Full-Time Equivalent (FTE) employment and treatment intensity metrics—while accounting for establishment closures and missing survey items.
Stata Template
* 1. Aggregate Full-Time Equivalent (FTE) Employment

* FTE = Full-time staff + Managers + 0.5 * Part-time staff

gen fte1 = empft + 0.5 * emppt + nmgrs

gen fte2 = empft2 + 0.5 * emppt2 + nmgrs2

* Adjust for permanently closed establishments in Wave 2

replace fte2 = 0 if status2 == 3

* Compute period-to-period change

gen dfte = fte2 - fte1

* 2. Construct Policy Treatment Intensity (GAP Variable)

gen gap = 0

replace gap = (5.05 - wage_st) / wage_st if state == 1 & wage_st < 5.05 & !missing(wage_st)

replace gap = 0 if state == 1 & wage_st >= 5.05 & !missing(wage_st)

* 3. Construct Logarithmic Price Metrics

gen meal1 = psoda + pfry + pentree

gen meal2 = psoda2 + pfry2 + pentree2

gen dlnmeal = ln(meal2) - ln(meal1)
Key Practices
Explicit Non-Missing Constraints (!missing(wage_st)): Crucial when constructing conditional metrics or ratios. It prevents missing numeric values (.) from being improperly processed as large positive numbers in logical comparisons.
Structural Closure Corrections (replace fte2 = 0 if status2 == 3): Ensures that permanently closed stores are accurately recorded as zero employment rather than omitted as missing observations, preserving full-sample population dynamics.


Skill 3: Difference-in-Differences (DiD) and Heterogeneity Modeling
Purpose
To execute baseline OLS DiD regressions, incorporate categorical fixed effects (e.g., chain brands, regions), and estimate continuous treatment intensity models with robust standard errors.
Stata Template
* Generate dummy indicator variables for categorical brands

tab chain, gen(ch_)

* Baseline DiD Model (State Dummy)

reg dfte state if !missing(dfte) & !missing(wage_st), robust

estimates store m1

* DiD Model with Chain and Ownership Fixed Effects

reg dfte state ch_1 ch_3 ch_4 co_owned if !missing(dfte) & !missing(wage_st), robust

estimates store m2

* Continuous Treatment Intensity Model (GAP Variable)

reg dfte gap ch_1 ch_3 ch_4 co_owned if !missing(dfte) & !missing(wage_st), robust

estimates store m3

* Full Specification with Regional Fixed Effects

reg dfte gap ch_1 ch_3 ch_4 co_owned southj northj pa1 if !missing(dfte) & !missing(wage_st), robust

estimates store m4
Key Practices
Sample Consistency Enforcement: Including if !missing(dfte) & !missing(wage_st) across all specifications guarantees that comparisons across models (e.g., State dummy vs. GAP continuous variable) are conducted on an identical, un-shifted estimation sample.
Heteroskedasticity-Robust Inference (robust): Produces Huber-White Sandwich standard errors to shield statistical inference against non-constant error variances.


Skill 4: Subsample Heterogeneity Analysis via Memory Preservation
Purpose
To perform subgroup regressions (e.g., company-owned stores vs. franchises) without destroying the core dataset in memory or requiring external file re-imports.
Stata Template
* Subsample 1: Independent Franchises (co_owned == 0)

preserve

    keep if co_owned == 0

    reg dfte state ch_1 ch_3 ch_4 southj northj pa1 if !missing(dfte) & !missing(wage_st), robust

    estimates store m11

    reg dfte gap ch_1 ch_3 ch_4 southj northj pa1 if !missing(dfte) & !missing(wage_st), robust

    estimates store m12

    esttab m11 m12 using "regression_result(heterogeneity co_owned==0).rtf", replace

restore

* Subsample 2: Company-Owned Outlets (co_owned == 1)

preserve

    keep if co_owned == 1

    reg dfte state ch_1 ch_3 ch_4 southj northj pa1 if !missing(dfte) & !missing(wage_st), robust

    estimates store m13

    reg dfte gap ch_1 ch_3 ch_4 southj northj pa1 if !missing(dfte) & !missing(wage_st), robust

    estimates store m14

    esttab m13 m14 using "regression_result(heterogeneity co_owned==1).rtf", replace

restore
Key Practices
preserve / restore Block Control: Temporarily modifies the dataset in memory to perform subgroup analysis and immediately restores the full sample, maintaining code modularity and runtime execution speed.


Skill 5: Automated Export of Publication-Ready Tables
Purpose
To store multiple regression estimation results in Stata's memory (estimates store) and export formatted, publication-ready multi-column tables directly into RTF or Word formats.
Stata Template
* Store sequential models

reg dlnmeal state if !missing(dlnmeal), robust

estimates store m6

reg dlnmeal state ch_1 ch_3 ch_4 co_owned if !missing(dlnmeal), robust

estimates store m7

reg dlnmeal gap if !missing(dlnmeal), robust

estimates store m8

* Export consolidated multi-model comparison table

esttab m1 m2 m3 m4 m5 m6 m7 m8 m9 m10 using "regression_result.rtf", replace
Key Practices
Batch Table Compiling (esttab ... using ...): Eliminates human copy-paste errors by directly writing coefficients, t-statistics, sample sizes, and goodness-of-fit indicators into external word processing documents (.rtf).
