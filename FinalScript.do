/* Paper: Imperfect Recall: The Politics of Subnational Office Removals
Authors: Alisha Holland (achollan@princeton.edu)  and José Incio (j.incio@pitt.edu) 
June 2018, code*/

egen sdcompetition = std(competition) 
egen sdenp = std(enp)
egen sdvoters = std(voters) 
egen sdbudget = std(budget)
egen sdcanon = std(canon)
egen sdinvest = std(investment)
encode region, generate (code)

label variable competition "Competition"
label variable sdcompetition "Competition"
label variable sdenp "Fragmentation"
label variable sdvoters "Voters"
label variable sdcanon "Canon"
label variable firstexecution "Execution"
label variable sdbudget "Budget"
label variable female "Female"
label variable previous "Previous"
label variable rural "Rural"
label variable conflict "Conflict"
label variable indigenous "Indigenous"
label variable incumbent "Incumbent"
label variable poverty2 "Poverty"
label variable request "Request"
label variable removal "Removal"
label variable enp "Fragmentation"
label variable voters "Voters"
label variable budget "Budget" 
label variable canon "Canon"
label variable share "Share"
label variable investment "Investment"
label variable sdinvest "Investment"

***********************************
*****  Models and Figures
**********************************

** Table 2 ** 

*Pre reform*
*Petition*
eststo: reg request sdcompetition sdenp female incumbent previous sdvoters rural poverty2 i.period if period!=4
estimates store m1, title(Model 1)
eststo: reg request sdcompetition sdenp female incumbent previous sdvoters rural poverty2 i.period firstexecution sdbudget sdcanon conflict indigenous if period!=4
estimates store m2, title(Model 2)
*Aproval*
eststo: reg vote sdcompetition sdenp female incumbent previous sdvoters rural poverty2 i.period if period!=4 & request ==1
estimates store m11, title(Model 3)
eststo: reg vote sdcompetition sdenp female incumbent previous sdvoters rural poverty2 i.period firstexecution sdbudget sdcanon conflict indigenous if period!=4 & request==1
estimates store m12, title(Model 4)
* Post reform* 
* Petition
eststo: reg request sdcompetition sdenp female incumbent previous sdvoters rural poverty2 i.period if period ==4
estimates store m3, title(Model 5)
eststo: reg request sdcompetition sdenp female incumbent previous sdvoters rural poverty2 i.period firstexecution sdbudget sdcanon conflict indigenous if period==4
estimates store m4, title(Model 6)
*Aproval
eststo: reg vote sdcompetition sdenp female incumbent previous sdvoters rural poverty2 i.period if period ==4 & request ==1
estimates store m13, title(Model 7)
eststo: reg vote sdcompetition sdenp female incumbent previous sdvoters rural poverty2 i.period firstexecution sdbudget sdcanon conflict indigenous if period==4 & request ==1
estimates store m14, title(Model 8)

local titles "& Petition & Petition & Approval & Approval  & Petition & Petition & Approval  & Approval \\"
local numbers "& (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8)  \\ \hline"

esttab m1 m2 m11 m12 m3 m4 m13 m14 using table2.tex, replace ///
b (3) se (3) ar2 star(* 0.05 ) compress label drop (1.period 2.period 3.period 4.period) ///
mgroups("Pre reform" "Post Reform", pattern(1 0 0 0 1 0 0 0) ///
prefix(\multicolumn{@span}{c}{) suffix(}) ///
span erepeat(\cmidrule(lr){@span}))       ///
mlabels(none) nonumbers posthead("`titles'" "`numbers'")


** Table 3 **
*Conditional*
eststo: reg removal sdcompetition sdenp female incumbent previous sdvoters rural poverty2 i.period if vote==1
estimates store m15, title(Model 1)

eststo: reg removal sdcompetition sdenp female incumbent previous sdvoters rural poverty2 i.period firstexecution sdbudget sdcanon conflict indigenous if vote==1
estimates store m16, title(Model 2)

*Unconditional* 
eststo: reg removal sdcompetition sdenp female incumbent previous sdvoters rural poverty2 i.period
estimates store m17, title(Model 3)

eststo: reg removal sdcompetition sdenp female incumbent previous sdvoters rural poverty2 i.period firstexecution sdbudget sdcanon conflict indigenous
estimates store m18, title(Model 4)

local titles "& Removal & Removal & Removal & Removal  \\"
local numbers "& (1) & (2) & (3) & (4)   \\ \hline"

esttab m15 m16 m17 m18  using table3.tex, replace ///
b (3) se (3) ar2 star(* 0.05 ) compress label ///
mgroups("Conditional" "Unconditional", pattern(1 0 1 0) ///
prefix(\multicolumn{@span}{c}{) suffix(}) ///
span erepeat(\cmidrule(lr){@span}))       ///
mlabels(none) nonumbers posthead("`titles'" "`numbers'")

 esttab m15 m16 m17 m18  using table3.tex, replace b (3) se (3) ar2 star(* 0.05 ) compress label mgroups("Conditional" "Unconditional", pattern(1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))     mlabels(none) nonumbers posthead("`titles'" "`numbers'")

eststo clear
estimate clear


** Fig 2: The Timing of Recall Petitions, 2006-2014 ** 

generate days2= days-365 /* The number is since the election day (around October each day) to the filling request, */
hist days2 if days2>0 & period!=4, xtitle("Days After Filing Opens") ytitle("Fraction of Requests") ylabel(, nogrid) color(gray) fintensity(2) graphregion(color(white)) bgcolor(white) 


** Fig 3: The Role of Electoral Competition Pre-and Post-Institutional Reforms ** 

quietly xi: logit request competition enp female incumbent previous voters rural poverty2 if period!=4

margins, at(competition=(0(.025).3))
marginsplot, plotopts(scheme(sj)) yscale(r(0 .4)) xlab(0(.1).3) xtitle("Margin of Victory") ytitle("Pr(Petition)") title("Petitions Pre-Reform") graphregion(color(white)) bgcolor(white) name(a, replace) 

quietly xi: logit request competition enp female incumbent previous voters rural poverty2 if period==4
margins, at(competition=(0(.025).3))
marginsplot, plotopts(scheme(sj)) yscale(r(0 .4)) xlab(0(.1).3) xtitle("Margin of Victory") ytitle("Pr(Petition)") title("Petitions Post-Reform") graphregion(color(white)) bgcolor(white) name(b, replace)

quietly xi: logit vote competition enp female incumbent previous voters rural poverty2 i.period if period!=4 & request==1, iterate(90)

margins, at(competition=(0(.025).3))
marginsplot, plotopts(scheme(sj)) yscale(r(0 .4)) xlab(0(.1).3) xtitle("Margin of Victory") ytitle("Pr(Approval)") title("Approvals Pre-Reform") graphregion(color(white)) bgcolor(white) name(c, replace) 

quietly xi: logit vote competition enp female incumbent previous voters rural poverty2 i.period if period==4 & request==1, iterate(90)
margins, at(competition=(0(.025).3))
marginsplot, plotopts(scheme(sj)) yscale(r(0 .4)) xlab(0(.1).3) xtitle("Margin of Victory") ytitle("Pr(Approval)") title("Approvals Post-Reform") graphregion(color(white)) bgcolor(white) name(d, replace)

graph combine a b c d, ycommon


** Fig 4: The Role of Budget Execution in Recall Petitions and Removals ** 


quietly xi: logit request sdcompetition sdenp sdvoters rural poverty2 indigenous female previous firstexecution budget canon conflict 
margins, at(firstexecution=(.3(.1)1))
marginsplot, plotopts(scheme(sj)) yscale(r(.2 .4)) xlab(.3(.1)1) xtitle("Fraction Budget Execution") ytitle("Pr(Requests)") title("Requests") graphregion(color(white)) bgcolor(white) name(c, replace) 

quietly xi: logit removal sdcompetition sdenp female incumbent previous sdvoters rural poverty2 i.period firstexecution sdbudget sdcanon conflict indigenous if vote==1
margins, at(firstexecution=(.3(.1)1))
marginsplot, plotopts(scheme(sj)) yscale(r(.2 .4)) xlab(.3(.1)1) xtitle("Fraction Budget Execution") ytitle("Pr(Removal)") title("Removals") graphregion(color(white)) bgcolor(white) name(d, replace) 

graph combine c d, ycommon


************************
******** APENDIX *******
************************

** Table 3: Summary Statistics

sutex budget canon competition enp firstexecution indigenous voters rural, lab nobs key(table3) replace ///
file(table3a.tex) title("Summary Statistics") minmax

** Table 4:  Frequency Tables, Categorical Variables  
label define poverty 0 "Not poor"  1 "Extremely poor" /* */ 
label values poverty poverty

latab poverty,  tf(table4a) replace 

** Incumbent 

latab female,  tf(table5a) replace 

** Female

latab female,  tf(table6a) replace 

** Conflcit 
label define conflict 0 "0"  1 "1" /* */ 
label values conflict conflict

latab conflict,  tf(table7a) replace 

** Previous 
label define previous 0 "no prior" 1 "prior recall"
latab previous,  tf(table8a) replace 

**Table 8: The determinants of Recall Request and Vote: Logit Models** 
* Pre reform 
xi: logit request sdcompetition sdenp female incumbent previous sdvoters rural poverty2 i.period if period!=4
eststo margin: margins, dydx(*) post
estimates store m8, title(Model 8)

xi: logit request sdcompetition sdenp female incumbent previous sdvoters rural poverty2 i.period firstexecution sdbudget sdcanon conflict indigenous if period!=4
eststo margin: margins, dydx(*) post
estimates store m9, title(Model 9)

xi: logit vote sdcompetition sdenp female incumbent previous sdvoters rural poverty2 i.period if period!=4 & request ==1, iterate(90)
eststo margin: margins, dydx(*) post
estimates store m12, title(Model 12)

xi: logit vote sdcompetition sdenp female incumbent previous sdvoters rural poverty2 i.period firstexecution sdbudget sdcanon conflict indigenous if period!=4 & request==1,iterate(90)
eststo margin: margins, dydx(*) post
estimates store m13, title(Model 13)


* Post reform * 


xi: logit request sdcompetition sdenp female incumbent previous sdvoters rural poverty2 i.period if period ==4
eststo margin: margins, dydx(*) post
estimates store m10, title(Model 10)

xi: logit request sdcompetition sdenp female incumbent previous sdvoters rural poverty2 i.period firstexecution sdbudget sdcanon conflict indigenous if period==4
eststo margin: margins, dydx(*) post
estimates store m11, title(Model 11)

xi: logit vote sdcompetition sdenp female incumbent previous sdvoters rural poverty2 i.period if period ==4 & request ==1, iterate(90)
eststo margin: margins, dydx(*) post
estimates store m14, title(Model 14)

xi: logit vote sdcompetition sdenp female incumbent previous sdvoters rural poverty2 i.period firstexecution sdbudget sdcanon conflict indigenous if period==4 & request ==1, iterate(90)
eststo margin: margins, dydx(*) post
estimates store m14_1, title(Model 14_1)


esttab m8 m9 m12 m13 m10 m11 m14 m14_1 using table8a.tex, replace ///
b (3) se (3) ar2 star(* 0.05 ) compress label drop (_Iperiod_2 _Iperiod_3 _Iperiod_4) ///
mgroups("Pre-Reform" "Post-Reform", pattern(1 0 0 0 1 0 0 0) ///
prefix(\multicolumn{@span}{c}{) suffix(}) ///
span erepeat(\cmidrule(lr){@span}))       ///
mlabels(none) nonumbers posthead("`titles'" "`numbers'")

eststo clear
estimate clear

**Table 9: The determinants of Recall Removal: Logit Models** 

** Conditional on Vote
xi: logit removal sdcompetition sdenp female incumbent previous sdvoters rural poverty2 i.period if vote==1
eststo margin: margins, dydx(*) post
estimates store m15, title(Model 15)

xi: logit removal sdcompetition sdenp female incumbent previous sdvoters rural poverty2 i.period firstexecution sdbudget sdcanon conflict indigenous if vote==1
eststo margin: margins, dydx(*) post
estimates store m16, title(Model 16)

** Unconditional on Vote
xi: logit removal sdcompetition sdenp female incumbent previous sdvoters rural poverty2 i.period
eststo margin: margins, dydx(*) post
estimates store m17, title(Model 17)

xi: logit removal sdcompetition sdenp female incumbent previous sdvoters rural poverty2 i.period firstexecution sdbudget sdcanon conflict indigenous
eststo margin: margins, dydx(*) post
estimates store m18, title(Model 18)

esttab m15 m16 m17 m18  using table9a.tex, replace ///
b (3) se (3) ar2 star(* 0.05 ) compress label ///
mgroups("Conditional" "Unconditional", pattern(1 0 1 0) ///
prefix(\multicolumn{@span}{c}{) suffix(}) ///
span erepeat(\cmidrule(lr){@span}))       ///
mlabels(none) nonumbers posthead("`titles'" "`numbers'")

eststo clear
estimate clear

** Table 10: Budget Execution and Investment Per Capita 

** IV: Execution
eststo: reg request sdcompetition sdenp female incumbent previous sdvoters rural poverty2 i.period firstexecution sdbudget sdcanon conflict indigenous
estimates store m19, title (Model 19)
eststo: reg vote sdcompetition sdenp female incumbent previous sdvoters rural poverty2 i.period firstexecution sdbudget sdcanon conflict indigenous if request==1
estimates store m21, title (Model 21)
eststo: reg removal sdcompetition sdenp female incumbent previous sdvoters rural poverty2 i.period firstexecution sdbudget sdcanon conflict indigenous if vote==1
estimates store m20, title (Model 20)
** IV Investment per capita

eststo: reg request sdcompetition sdenp female incumbent previous sdvoters rural poverty2 i.period sdinvest sdbudget sdcanon conflict indigenous
estimates store m22, title (Model 22)
eststo: reg removal sdcompetition sdenp female incumbent previous sdvoters rural poverty2 i.period sdinvest sdbudget sdcanon conflict indigenous if vote==1
estimates store m23, title (Model 23)
eststo: reg vote sdcompetition sdenp female incumbent previous sdvoters rural poverty2 i.period sdinvest sdbudget sdcanon conflict indigenous if request==1
estimates store m24, title (Model 24)


esttab m19 m21 m20 m22 m24 m23 using table10a.tex, replace ///
b (3) se (3) ar2 star(* 0.05 ) compress label  ///
mgroups("IV: Execution" "IV: Investment per capita", pattern(1 0 0 1 0 0) ///
prefix(\multicolumn{@span}{c}{) suffix(}) ///
span erepeat(\cmidrule(lr){@span}))       ///
mlabels(none) nonumbers posthead("`titles'" "`numbers'")



** Table 11: The determinants of Recalls and Vote: State Fixed Effect Models 

xtset code

**Pre-Reform 
eststo: xtreg request sdcompetition sdenp female incumbent previous sdvoters rural poverty2 i.period if period!=4
estimates store m25, title(Model 25)

eststo: xtreg request sdcompetition sdenp female incumbent previous sdvoters rural poverty2 i.period firstexecution sdbudget sdcanon conflict indigenous if period!=4
estimates store m26, title(Model 26)

eststo: xtreg vote sdcompetition sdenp female incumbent previous sdvoters rural poverty2 i.period if period!=4 & request ==1
estimates store m29, title(Model 29)

eststo: xtreg vote sdcompetition sdenp female incumbent previous sdvoters rural poverty2 i.period firstexecution sdbudget sdcanon conflict indigenous if period!=4 & request==1
estimates store m30, title(Model 30)

** Post-Reform 

eststo: xtreg request sdcompetition sdenp female incumbent previous sdvoters rural poverty2 i.period if period ==4
estimates store m27, title(Model 27)

eststo: xtreg request sdcompetition sdenp female incumbent previous sdvoters rural poverty2 i.period firstexecution sdbudget sdcanon conflict indigenous if period==4
estimates store m28, title(Model 28)

eststo: xtreg vote sdcompetition sdenp female incumbent previous sdvoters rural poverty2 i.period if period ==4 & request ==1
estimates store m31, title(Model 31)

eststo: xtreg vote sdcompetition sdenp female incumbent previous sdvoters rural poverty2 i.period firstexecution sdbudget sdcanon conflict indigenous if period==4 & request ==1
estimates store m32, title(Model 32)


esttab m25 m26 m29 m30 m27 m28 m31 m32 using table11a.tex, replace ///
b (3) se (3) ar2 star(* 0.05 ) compress label drop (1.period 2.period 3.period 4.period) ///
mgroups("Pre-Reform" "Post-Reform", pattern(1 0 0 0 1 0 0 0) ///
prefix(\multicolumn{@span}{c}{) suffix(}) ///
span erepeat(\cmidrule(lr){@span}))       ///
mlabels(none) nonumbers posthead("`titles'" "`numbers'")


** Table 12: The Determinants of Removal: Fixed Effects Models

** Conditional on Vote 

eststo: xtreg removal sdcompetition sdenp female incumbent previous sdvoters rural poverty2 i.period if vote==1
estimates store m33

eststo: xtreg removal sdcompetition sdenp female incumbent previous sdvoters rural poverty2 i.period firstexecution sdbudget sdcanon conflict indigenous if vote==1
estimates store m34

** Unconditional on vote

eststo: xtreg removal sdcompetition sdenp female incumbent previous sdvoters rural poverty2 i.period
estimates store m35

eststo: xtreg removal sdcompetition sdenp female incumbent previous sdvoters rural poverty2 i.period firstexecution sdbudget sdcanon conflict indigenous
estimates store m36

esttab m33 m34 m35 m36 using table12a.tex, replace ///
b (3) se (3) ar2 star(* 0.05 ) compress label drop (2.period 3.period 4.period) ///
mgroups("Conditional" "Unconditional", pattern(1 0 1 0) ///
prefix(\multicolumn{@span}{c}{) suffix(}) ///
span erepeat(\cmidrule(lr){@span}))       ///
mlabels(none) nonumbers posthead("`titles'" "`numbers'")






