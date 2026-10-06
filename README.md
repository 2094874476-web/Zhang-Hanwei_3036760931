# Zhang-Hanwei_3036760931
This report documents my complete empirical replication of Card and Krueger’s core findings using the original dataset (⁠public.csv⁠). The replication process is structured into three systematic stages: data preparation and variable construction, descriptive analysis, and econometric modeling.
The Process of My Replication

1. Data Cleaning and Variable Harmonization (⁠.do⁠ Script Development):
To replicate the exact specifications of the original paper, I developed a structured Stata ⁠.do⁠ script. First, I cleaned the dataset and generated key structural dummies, including chain identifiers (Burger King, KFC, Roy Rogers, Wendy's) and ownership status (⁠co_owned⁠).
Difference in fte Employment Construction between two waves: Total employment for both Wave 1 (pre-policy) and Wave 2 (post-policy) was standardized into Full-Equivalent Employment (fte) units. Following standard convention, FTE was computed as the sum of full-time employees, managers, and 0.5 times part-time employees (⁠fte = empft + 0.5 * emppt + nmgrs⁠). For permanently closed stores in Wave 2 (⁠status2 == 3⁠), FTE was adjusted to zero.
Difference:dfte=fte of wave2(fte2)-fte of wave1(fte1)

Initial Wage Gap Construction: To capture treatment intensity more precisely than a simple binary state dummy, I constructed a continuous policy variable, ⁠gap⁠. For Pennsylvania stores and New Jersey stores with an initial starting wage already at or above the new statutory minimum ($5.05), the gap was set to zero. For New Jersey stores with initial wages below $5.05, the gap measured the proportional wage increase required to reach the new minimum: tgap = (5.05 - textwage_st) / twage_st.

2. Descriptive and Difference-in-Differences Analysis (Tables 2 & 3):
Following the variable setup, I performed mean comparisons across New Jersey and Pennsylvania for pre- and post-intervention employment and prices. Using standard two-sample t-tests and simple difference-in-differences regressions (⁠reg dfte state⁠), I examined whether employment growth in New Jersey experienced a relative decline compared to the control group in Pennsylvania following the policy implementation.

3. Econometric Specification and Reduced-Form Modeling (Tables 4 & 7):
To rigorously test the policy impact, I estimated a series of reduced-form OLS regressions with robust standard errors:
Employment Models (Table 4): I progressively augmented the baseline DiD specification. Model (i) tests the basic state dummy; Model (ii) controls for chain-specific fixed effects and ownership structures and regions; Model (iii) replaces the binary New Jersey dummy with the continuous ⁠gap⁠ variable; and Model 
(i)dfte=α+βstate+ε
(ii)dfte=α+βstate+γX+ε
(iii)dfte=α+βGAP+γX+ε
Price Models (Table 7): To investigate the pass-through effects of the minimum wage hike on consumer prices, I calculated the total price of a full meal (⁠meal = psoda + pfry + pentree⁠) and estimated log-price changes (dlnmeal = ln(meal2) - ln(meal1)) against the treatment indicators and chain controls.



Through this methodical replication workflow, the script successfully recovers the core empirical results of Card & Krueger (1994), providing hands-on validation of quasi-experimental methods in applied econometrics.
