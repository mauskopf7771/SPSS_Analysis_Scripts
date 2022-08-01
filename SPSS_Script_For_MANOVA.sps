* Encoding: UTF-8.
*
    
***** Assumptions tests

* Normality

DATASET NAME DataSet1 WINDOW=FRONT. 
EXAMINE VARIABLES=SBI Pre_PA Pre_SL Pre_SR Post_SL Post_SR Post_PA 
  /PLOT BOXPLOT HISTOGRAM NPPLOT 
  /COMPARE GROUPS 
  /STATISTICS DESCRIPTIVES EXTREME 
  /CINTERVAL 95 
  /MISSING LISTWISE 
  /NOTOTAL.

* Multivariate normaity with Mahalanobis distance
    * Any variables that aren't normally distributed, we're going to remove from the analysis.

REGRESSION 
  /MISSING LISTWISE 
  /STATISTICS COEFF OUTS R ANOVA 
  /CRITERIA=PIN(.05) POUT(.10) 
  /NOORIGIN 
  /DEPENDENT Participant 
  /METHOD=ENTER Gender SBI Pre_PA Pre_SL Pre_SR Post_SL Post_SR Post_PA 
  /SAVE MAHAL.

* Compute p values for Mahalanobis distance
    
COMPUTE MAH_P=1-CDF.CHISQ(MAH_1, 7). 
EXECUTE.

* Once you've figured out which are p<.001 and put a 1 in the filter column, set everything else in the column to 0
    then run the following code to remove participants
    
COMPUTE filter_$=(Exclude<1). 
VARIABLE LABELS filter_$ 'Exclude<1 (FILTER)'. 
VALUE LABELS filter_$ 0 'Not Selected' 1 'Selected'. 
FORMATS filter_$ (f1.0). 
FILTER BY filter_$. 
EXECUTE.

* Test linearity of variables - we just need pairs to be linear 
    
GRAPH 
  /SCATTERPLOT(MATRIX)=Pre_PA Pre_SL Post_SL Post_PA 
  /MISSING=LISTWISE.


* Correlation matrix to test for multicollinearity - different textbooks use different values: some say .7-.9 depending on the
    book/paper so you can argue .9 is multicollinear (it suits your data)
    
CORRELATIONS 
  /VARIABLES=Pre_PA Pre_SL Post_SL Post_PA 
  /PRINT=TWOTAIL NOSIG FULL 
  /MISSING=PAIRWISE.

* Run the actual MANOVA
    
GLM Pre_PA Post_PA Pre_SL Post_SL BY exercise 
  /WSFACTOR=TimePoint 2 Polynomial 
  /MEASURE=PA SL 
  /METHOD=SSTYPE(3) 
  /POSTHOC=exercise(BONFERRONI) 
  /PLOT=PROFILE(TimePoint*exercise) TYPE=LINE ERRORBAR=CI MEANREFERENCE=NO YAXIS=AUTO 
  /PRINT=ETASQ OPOWER HOMOGENEITY 
  /CRITERIA=ALPHA(.05) 
  /WSDESIGN=TimePoint 
  /DESIGN=exercise.

* Then all you need to do is interpret the results! 



