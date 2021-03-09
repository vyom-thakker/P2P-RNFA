$onText
Preparing the RNFA-P2P for 3-MTHF Example
Author: Vyom
Date: 02/02/2020
$OffText

*
*Sets
*i rows                    /1*417/          
*j columns                 /1*425/
*k rowsOfB                 /1*24/
*econ_r(i) commodities I     /1*385/
*econ_rJ(j) commodities I     /1*385/
*vc_r(i) elements K          /386*394/  
*rnfa_r(i) chemicals M       /395*417/
*econ_c(j) sectors J         /1*385/
*vc_c(j) processes L        /386*397/  
*rnfa_c(j) reactions N        /398*425/
*econ_int(k) interventions  /1*21/
*vc_int(k) vc interventions /22*24/;

Sets
i rows                    /1*5/          
j columns                 /1*6/
k rowsOfB                 /1*2/
econ_r(i) commodities I     /1*2/
econ_rJ(j) commodities I     /1*2/
vc_r(i) elements K          /3*4/ 
rnfa_r(i) chemicals M       /5/
econ_c(j) sectors J         /1*2/
vc_c(j) processes L        /3*4/  
rnfa_c(j) reactions N        /5*6/
econ_int(k) interventions  /1/
vc_int(k) vc interventions /2/;

parameters
X1(i,j)
X2(i,j)
B1(k,j)
B2(k,j)
vcV(j,i)
vcU(i,j)
vcB(k,j)
econV(j,j)
econU(i,j)
econR(k,j)
econB(k,j)
rnfaV(j,i)
rnfaU(i,j)
dcUvc(i,j)
dcUrnfa(i,j)
dcVCrnfa(i,j)
ucUvc(i,j)
ucUrnfa(i,j)
ucVCrnfa(i,j)
p(j)
phat(j,j)
Pf(j,i)
PfU(i,i)
Pp(j,j)
Pb(k,k);

vcV(j,i)=0;
vcU(i,j)=0;
vcB(k,j)=0;
econV(j,j)=0;
econU(i,j)=0;
econR(k,j)=0;
econB(k,j)=0;
rnfaV(j,i)=0;
rnfaU(i,j)=0;
dcUvc(i,j)=0;
dcUrnfa(i,j)=0;
dcVCrnfa(i,j)=0;
ucUvc(i,j)=0;
ucUrnfa(i,j)=0;
ucVCrnfa(i,j)=0;
p(j)=0;
phat(j,j)=0;
Pf(j,i)=0;
PfU(i,i)=0;
Pp(j,j)=0;
Pb(k,k)=0;
*vcV(vc_c,vc_r)
*vcU(vc_r,vc_c)
*vcB(k,vc_c)
*econV(econ_c,econ_r)
*econU(econ_r,econ_c)
*econB(k,econ_rJ)
*rnfaV(rnfa_c,rnfa_r)
*rnfaU(rnfa_r,rnfa_c)
*dcUvc(vc_r,econ_c)
*dcUrnfa(rnfa_r,econ_c)
*dcVCrnfa(rnfa_r,vc_c)
*ucUvc(econ_r,vc_c)
*ucUrnfa(econ_r,rnfa_c)
*ucVCrnfa(vc_r,rnfa_c)
*p(vc_c)
*phat(vc_c,vc_c)
*Pf(econ_rJ,vc_r)
*PfU(econ_r,vc_r)
*Pp(vc_c,econ_c);

$offlisting
*$include ./incFiles/vcV.inc
*$include ./incFiles/vcU.inc
*$include ./incFiles/vcB.inc
*$include ./incFiles/econV.inc
*$include ./incFiles/econU.inc
*$include ./incFiles/econB.inc
*$include ./incFiles/rnfaV.inc
*$include ./incFiles/rnfaU.inc
*$include ./incFiles/dcUvc.inc
*$include ./incFiles/dcUrnfa.inc
*$include ./incFiles/dcVCrnfa.inc
*$include ./incFiles/ucUvc.inc
*$include ./incFiles/ucUrnfa.inc
*$include ./incFiles/ucVCrnfa.inc
*$include ./incFiles/p.inc
*$include ./incFiles/Pf.inc
*$include ./incFiles/PfU.inc
*$include ./incFiles/incToy.inc
$include ./incFiles/X1.inc
$include ./incFiles/X2.inc
$include ./incFiles/B1.inc
$include ./incFiles/B2.inc
$onlisting





positive variable m(j);
variable f(i);
variable g(k);


*f.lo(i)$(posb(i)) =0;
f.fx(i)$(vc_r(i)) =0;
f.lo(i)$(econ_r(i)) =0;
m.lo(j)=0;

*positive variables y1,y2;
*equations definingY1, definingY2;
*definingY1.. y1=e=m('5')/1000;
*definingY2.. y2=e=m('6')/500;
*y1.up=1;
*y2.up=1;

binary variables y1,y2;
equations definingY1, definingY2;
definingY1.. y1=g=m('5')/1000;
definingY2.. y2=g=m('6')/500;



*Enter Bases in mol/sec
$if not set basis $set basis 1


$ontext

variable X(i,j);
equation X_apprx(i,j);
X_apprx(i,j).. X(i,j)=e=y1*X1(i,j)+y2*X2(i,j);

variable B(k,j);
equation B_apprx(k,j);
B_apprx(k,j).. B(k,j)=e=y1*B1(k,j)+y2*B2(k,j);

$offtext


equation LCModel(i);

LCModel(i).. sum(j,(y1*X1(i,j)+y2*X2(i,j))*m(j))=e=f(i);

equation LCIntModel(k);

LCIntModel(k).. sum(j,(y1*B1(k,j)+y2*B2(k,j))*m(j))=e=g(k);

*equation yeildConstr(j,i);
*yeildConstr(j,i)$li(j,i).. m(j)=l= yei(j)*sum(jd1,X(i,jd1)*m(jd1))/(abs(X(i,j))*(1-yei(j)));

f.fx('1')=0;
f.fx('2')=0;
f.fx('3')=0;
f.fx('4')=0;


equation MTHFProd;
MTHFProd.. f('5')=e=%basis%;


equation CO2EqConstr;
variable CO2Eq;
CO2EqConstr.. CO2Eq=e=g('1')+g('2');


$onText
equation kgPConstr;
variable kgP;
kgPConstr.. kgP=e=g('23');

set A1f1(j,i) /399.395, 400.395, 401.395, 417.413, 421.413, 411.414, #rnfa_c.415/;
set A3f3(j,i) /409.399,410.399/;

parameter Hcom(i) /395 0.731, 413 0.216, 414 0.236, 415 0.285, 399 0.218/;
*parameter costVals(i) /395 , 399 , 413 , 414 , 415/;  





scalar intrate /0.05/;
equation TARConstr;
variable TAR;
TARConstr.. TAR=e=(f('399')*5000*86*10**(-6))-costIn;

variable NPV;
equation NPVConstr;
NPVConstr.. NPV=e= TAR*7.27 -IC;

variable landArea;
equation landAreaEq;
landAreaEq.. landArea=e=g('14')+g('24');



*equation fruitConstr1,fruitConstr2;
*fruitConstr1.. m('395')=l=0.3*(m('394')+m('395')+m('396'));
*fruitConstr2.. m('396')=l=0.3*(m('394')+m('395')+m('396'));
$offText
set U2RNFA(i,j) /#econ_r.#rnfa_c/;
set U2VC(i,j) /#econ_r.#vc_c/;
set IASource(j) /3*4/;
parameter costIASource(j) /3 0.1, 4 0.1/;
equation costInEq;
variable costIn;
CostInEq.. costIn=e=sum((i,j)$U2RNFA(i,j),-1*(y1*X1(i,j)+y2*X2(i,j))*m(j))+sum((i,j)$U2VC(i,j),-1*(y1*X1(i,j)+y2*X2(i,j))*m(j))+sum(j$IAsource(j),costIASource(j)*m(j));
equation LCCConstr;
variable LCC;
LCCConstr.. LCC=e=costIn;


*equation TARPost;
*TarPost.. TAR=g=0;

*(IC*intrate/(1-(1+intrate)**(-5)))

parameters LCCDummy,NPVDummy,CO2Dummy,elcc;

$if not set elccval $set elccval -1;
elcc=%elccval%;
equation eCons;
eCons$(elcc>0).. LCC=l=elcc;


variable dumm;
equation dumeq;
dumeq.. dumm=e=0;


    Model P2PRNFA /ALL/;
    Option NLP=BARON;
    Option MINLP=BARON;
*    Solve P2PRNFA using NLP minimizing dumm;
*    Solve P2PRNFA using LP maximizing NPV; 
*     NPVDummy=NPV.l;
*    NPV.lo=NPVDummy;
*   Solve P2PRNFA using LP minimizing CO2Eq; 

*   Solve P2PRNFA using NLP minimizing LCC;
*    LCCDummy=LCC.l;
*   LCC.up=LCCDummy;
*   Solve P2PRNFA using NLP minimizing CO2Eq; 
*  Solve P2PRNFA using MINLP minimizing CO2Eq; 
  Solve P2PRNFA using MINLP minimizing LCC; 
*  Solve P2PRNFA using LP minimizing kgP; 
*   Solve P2PRNFA using LP minimizing landArea; 
* Solve P2PRNFA using NLP minimizing CO2Eq; 
*  CO2Dummy=CO2Eq.l;
*  CO2Eq.up=CO2Dummy;
*  Solve P2PRNFA using NLP minimizing LCC; 

*Display econVTstarInv;
*Display Astar,rank;


parameter X(i,j), B(k,j);
X(i,j)=y1.l*X1(i,j)+y2.l*X2(i,j);
B(k,j)=y1.l*B1(k,j)+y2.l*B2(k,j);

Display X1,B1;
Display X2,B2;
Display X,B;
Display m.l;
Display f.l;
Display g.l;

$ontext
parameter diffCalc1(econ_c,econ_rJ),diffCalc2(econ_r,econ_c);
diffCalc1(econ_c,econ_rJ)=econVstar.l(econ_c,econ_rJ)-econV(econ_c,econ_rj);
diffCalc2(econ_r,econ_c)=econUstar.l(econ_r,econ_c)-econU(econ_r,econ_c);
Display diffCalc1,diffCalc2;

$offtext

*
$if not set file $set file 0
$if not set textval $set textval 0
*
File pareto /pareto%file%.txt/;
pareto.ap=1;
pareto.nd=4;
pareto.pw=32767;
put pareto"";
put %basis%",";
put LCC.l",";
put CO2Eq.l",";
loop(j,put m.l(j)",");
put "%textval%";
put "";
put /;


*File paretoAll3 /paretoAll3.txt/;
*paretoAll3.ap=1;
*paretoAll3.nd=4;
*put paretoAll3"";
*put %basis%",";
*put LCC.l",";
*put CO2Eq.l",";
*put kgP.l",";
*put landArea.l",";
*loop(j$vc_c(j),put m.l(j)",");
**loop(j$rnfa_c(j),put m.l(j)",");
*put "";
*put /;
*
*File paretoAll4 /paretoAll4.txt/;
*paretoAll4.ap=1;
*paretoAll4.nd=4;
*put paretoAll4"";
*put %basis%",";
*put LCC.l",";
*put CO2Eq.l",";
*put kgP.l",";
*put landArea.l",";
**loop(j$vc_c(j),put m.l(j)",");
*loop(j$rnfa_c(j),put m.l(j)",");
*put "";
*put /;
*
*execute_unload 'XNEW.gdx', X,Astar,VCstar,RNFA,m;
*execute 'gdxdump X.gdx output=X.csv symb=X format=csv'
*execute 'gdxdump X.gdx output=Astar.csv symb=Astar format=csv'
*execute 'gdxdump X.gdx output=VCstar.csv symb=VCstar format=csv'
*execute 'gdxdump X.gdx output=RNFA.csv symb=RNFA format=csv'
*execute 'gdxdump XNEW.gdx output=m.csv symb=m format=csv'
*execute 'rm X.gdx'

*Display Astar;
*display rank, piv;

