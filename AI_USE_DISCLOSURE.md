AI-Use Disclosure
In the replication and extension of the classic empirical study by David Card and Alan B.
Krueger (1994), "Minimum Wages and Employment: A Case Study of the Fast-Food Industry in
New Jersey and Pennsylvania" [cite: 2], artificial intelligence (AI) tools were utilized as an
auxiliary aid for programming, methodological interpretation, and academic drafting. This
disclosure outlines where and how AI was used, how the outputs were verified, and important
corrections made during the process.
1. Where and How AI Was Used
● Stata Scripting and Programming: AI assisted in structuring and drafting the Stata
.do file for data cleaning, variable construction, and econometric regressions.
Specifically, this included:
○ Formulating the Full-Time Equivalent (FTE) employment metrics and handling
permanently closed stores (status2 == 3) [cite: 5].
○ Constructing the continuous initial wage gap (gap) variable across treatment and
control groups [cite: 10].
○ Implementing the regression specifications for baseline DiD models (Tables 4
and 7) and the ownership heterogeneity subsample analyses using esttab.
● Methodological and Theoretical Framework: AI was consulted to organize the
background literature regarding difference-in-differences (DiD) models, competitive
versus monopsonistic labor market theories, and potential empirical extensions.
2. How AI-Generated Code, Analysis, and Writing Were Checked
All AI-generated code, text, and analytical suggestions underwent rigorous human review and
local execution:
● Empirical Validation: The generated Stata scripts were executed locally using the
project dataset (public.csv). Output coefficients, standard errors, sample sizes ($N$),
and $R$-squared values were cross-verified against the original paper's reported
statistics.
● Theoretical and Statistical Review: The economic rationale behind suggested model
specifications (such as interaction terms and control variable selections) was manually
checked to ensure alignment with standard econometric practices.
3. Important AI Errors or Suggestions That Were Corrected or Rejected
● Sample Consistency Correction: Initial AI-suggested regression commands omitted
explicit missing-value exclusions for key variables (e.g., if !missing(wage_st)).
This was corrected manually to ensure that models using the continuous gap variable
shared an identical sample size with baseline specifications, preventing sample selection
bias.
● Data Structure Adjustment: Initial code templates did not account for potential case
sensitivity in dataset column names. This was rectified by adding rename *, lower at
the initialization stage and incorporating precise conditional replacements for
establishment closure statuses [
