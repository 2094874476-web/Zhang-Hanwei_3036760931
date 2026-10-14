# Zhang-Hanwei_3036760931
This report documents my complete empirical replication of Card and Krueger’s core findings using the original dataset (⁠public.csv⁠). The replication process is structured into three systematic stages: data preparation and variable construction, descriptive analysis, and econometric modeling.
The Process of My Replication

1. Data Cleaning and Variable Harmonization (⁠.do⁠ Script Development):
To replicate the exact specifications of the original paper, I developed a structured Stata ⁠.do⁠ script. First, I cleaned the dataset and generated key structural dummies, including chain identifiers (Burger King, KFC, Roy Rogers, Wendy's) and ownership status (⁠co_owned⁠).

Difference in fte Employment Construction between two waves: Total employment for both Wave 1 (pre-policy) and Wave 2 (post-policy) was standardized into Full-Equivalent Employment (fte) units. Following standard convention, FTE was computed as the sum of full-time employees, managers, and 0.5 times part-time employees (⁠fte = empft + 0.5 * emppt + nmgrs⁠). For permanently closed stores in Wave 2 (⁠status2 == 3⁠), FTE was adjusted to zero.
Difference:dfte=fte of wave2(fte2)-fte of wave1(fte1)

Initial Wage Gap Construction: To capture treatment intensity more precisely than a simple binary state dummy, I constructed a continuous policy variable, ⁠gap⁠. For Pennsylvania stores and New Jersey stores with an initial starting wage already at or above the new statutory minimum ($5.05), the gap was set to zero. For New Jersey stores with initial wages below $5.05, the gap measured the proportional wage increase required to reach the new minimum: tgap = (5.05 - textwage_st) / twage_st.

2. Replication of Figure 1: Distribution of Starting Wage Rates。
Methodology & Execution
Figure 1 illustrates the frequency distribution of starting wages across fast-food restaurants in New Jersey and Pennsylvania during Wave 1 and Wave 2. In Stata, histograms with a discrete bin width of $0.05$ were estimated across state and wave subsets:

Wave 1 (Feb 1992): Both New Jersey and Pennsylvania exhibited highly synchronized starting wage distributions, tightly clustered around the old $4.25 minimum wage.

Wave 2 (Nov 1992): Following the policy implementation, over $85\%$ of New Jersey stores shifted their starting wages exactly to the new $\$5.05$ statutory minimum, whereas Pennsylvania's distribution remained virtually unchanged. Crucially, little to no wage spillover was observed among New Jersey stores that initially paid more than $5.00.   

3. Replication of Table 2: Means of Key Variables
Table 2 provides summary statistics (means and standard deviations) for store characteristics, pre-policy employment, starting wages, and meal prices.
Store Type Distribution: Using matrix operations (matcell and putexcel), the categorical distribution of fast-food chains (chain: Burger King, KFC, Roy Rogers, Wendy's) and ownership status (co_owned) was extracted. For instance, Burger King outlets comprise roughly 41.1% of the New Jersey sample and 44.3%of the Pennsylvania sample.

Baseline Alignment: Wave 1 pre-policy FTE employment was tightly aligned between New Jersey ($20.44$) and Pennsylvania ($23.33$), and initial starting wages were nearly identical ($\$4.61$ vs. $\$4.63$), verifying the validity of the control group. 

4. Replication of Table 3: Employment Levels, Changes, and DID Estimates
Table 3 evaluates the core Difference-in-Differences (DID) framework by comparing employment changes across states and within New Jersey across initial wage tiers:

a.Cross-State Comparison: While Pennsylvania control stores experienced an average employment contraction of -2.28 FTEs (reflecting regional macroeconomic recessionary pressures), New Jersey treatment stores saw an average employment expansion (+0.47 FTEs).

b.Difference-in-Differences Estimator: The cross-state net employment change (DELTAFTE_NJ- DELTAFTE_PA) yields a positive difference of approximately +2.75 to +2.76 FTEs (approx 2.03), directly rejecting the traditional competitive prediction of job losses.

C.Intra-State Wage Tiers: Within New Jersey, low-wage stores (wage = 4.25, most exposed) experienced employment gains, whereas high-wage stores (wage >$5.00, unaffected) contracted by -2.16 FTEs—a decline virtually identical to Pennsylvania stores, confirming the robustness of the control group.

5. Replication of Table 4: Reduced-Form Models for Change in Employment
able 4 estimates OLS reduced-form models controlling for chain types, company ownership, and regional fixed effects:

a.Model (i) & (ii) [NJ Dummy]: Regressing dfteon the New Jersey treatment dummy yields a coefficient of 2.30 (t = 1.92), confirming a relative employment increase in NJ even after controlling for brand heterogeneity. 

b.Model (iii) & (iv) [Wage Gap]: Replacing the state dummy with the continuous GAP variable yields a highly significant coefficient of 14.92 to 15.65 (p < 0.01). This demonstrates a positive "dose-response" effect: stores facing a larger required wage adjustment experienced greater relative employment growth. 

c.Model (v) [Regional Controls]: Including regional fixed effects (North, Central, South NJ and PA sub-regions) attenuates the coefficient to 11.91 due to well-documented measurement error attenuation bias in self-reported initial wages, yet the coefficient remains positive.  

6. Extension: Price Pass-Through (Table 7) & Ownership Heterogeneity
Price Effects (Table 7): Regressing log meal price changes (dlnmeal) on the state dummy yields a coefficient of 0.032$ to 0.037(p < 0.05), indicating that post-tax full meal prices rose about 3%-4% faster in New Jersey than in Pennsylvania. This confirms that a substantial portion of the minimum wage cost burden was successfully passed on to consumers via higher prices.

Ownership Heterogeneity Extension: Subsample regressions partitioned by store ownership (co_owned) reveal that the positive employment driving effect of the wage gap is concentrated primarily among franchise-owned stores (co_owned == 0, coefficient $18.68, t = 1.92), highlighting institutional differences in operational flexibility between corporate and franchised units.

Summary Conclusion
The replicated Stata workflow successfully validates all core qualitative and quantitative findings of Card and Krueger (1994). The evidence confirms that New Jersey's minimum wage hike did not reduce fast-food employment, while driving moderate product price increases—an empirical puzzle that catalyzed modern labor economics literature on imperfect labor markets, search friction, and monopsony models.

Directly running the code in stata can easily obtain all the output of replication.
