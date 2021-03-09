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
$include ./incFiles/incToy.inc
$onlisting





positive variable m(j);
variable f(i);
variable g(k);



variables
vcVstar(j,i)
vcUstar(i,j)
econVstar(j,j)
econUstar(i,j)
econBstar(k,j);

parameters
PfT(i,j)
PpT(j,j);

PfT(vc_r,econ_rJ)=Pf(econ_rJ,vc_r);
PpT(econ_c,vc_c)=Pp(vc_c,econ_c);
phat(vc_c,vc_c)=p(vc_c);
*rnfaV(rnfa_c,'417')=0;

alias(i,id1,id2);
alias(j,jd1,jd2,jd3);
alias(k,kd1,kd2);

*binary variable y(j);

*equation activeProcess(vc_c);
*activeProcess(vc_c).. (1-y(vc_c))*m(vc_c)=e=0;
*activeProcess(vc_c).. y(vc_c)$(m(vc_c)>0)=e=1;


equations disagg1(econ_c,econ_rJ),disagg2(econ_r,econ_c),disagg3(econ_rJ,econ_c),disagg4(econ_int,econ_c);


disagg1(econ_c,econ_rJ).. econVstar(econ_c,econ_rJ)=e=econV(econ_c,econ_rJ)-sum(jd1$vc_c(jd1),PpT(econ_c,jd1)*m(jd1)*sum(jd2$vc_c(jd2),phat(jd1,jd2)*sum(id1$vc_r(id1),vcV(jd2,id1)*PfT(id1,econ_rJ))));

set notRJ(j);
notRJ(j)=vc_c(j)+rnfa_c(j);


disagg2(econ_r,econ_c).. econUstar(econ_r,econ_c)=e=econU(econ_r,econ_c)-(sum(id1$vc_r(id1),PfU(econ_r,id1)*sum(jd1$vc_c(jd1),vcU(id1,jd1)*sum(jd2$vc_c(jd2),phat(jd1,jd2)*Pp(jd2,econ_c)*m(jd2)))))+sum(id2$vc_r(id2),PfU(econ_r,id2)*dcUvc(id2,econ_c)*m(econ_c))+sum(jd3$vc_c(jd3),ucUvc(econ_r,jd3)*Pp(jd3,econ_c)*m(jd3));

econUstar.fx(econ_r,notRJ)=0;
econUstar.fx(vc_r,j)=0;
econUstar.fx(rnfa_r,j)=0;

variable econVTstar(econ_rJ,econ_c);
disagg3(econ_rJ,econ_c).. econVTstar(econ_rJ,econ_c)=e=econVstar(econ_c,econ_rJ);

equation vtone(econ_c);
variable econVTstarOne(econ_c);
vtone(econ_c).. econVTstarOne(econ_c)=e=sum(econ_rJ,econVTstar(econ_rJ,econ_c));

disagg4(econ_int,econ_c).. econBstar(econ_int,econ_c)*econVTstarOne(econ_c)=e=(econR(econ_int,econ_c)-sum(kd1$vc_int(kd1),Pb(econ_int,kd1)*sum(jd1$vc_c(jd1),vcB(kd1,jd1)*m(jd1)*Pp(jd1,econ_c))));


*disagg4(econ_int,econ_c).. econBstar(econ_int,econ_c)=e=econB(econ_int,econ_c);

*variable econVTstarInv(econ_c,econ_rJ);
*execute_unload 'econVstar.gdx', i,j,econVstar;
*execute '=invert.exe econVstar.gdx i j econVstar econVstarInv.gdx econVstarInv';
*execute_load 'econVstarInv.gdx', econVstarInv;

*$offlisting
*$include inverseMat.gms
*$onlisting

*Alias (econ_rJ,ip), (econ_c,jp);


**Parameter
*   bp(econ_rJ,econ_c)   'permuted and transposed inverse of a'
*   pair(econ_rJ,econ_c) 'pivoting sequence and permutation'
*   rank      'rank of matrix a'
*   piv
*   big
*   tol;
*
*Set
*   r(econ_rJ)   'pivot row candidates'
*   npr(econ_rJ) 'non pivot rows'
*   s(econ_c)   'pivot column candidates'
*   nps(econ_c) 'non pivot columns';
*
*r(econ_rJ)    = yes;
*s(econ_c)    = yes;
*bp(econ_rJ,econ_c) = econVTstar(econ_rJ,econ_c);
*rank    = 0;
*tol     = 1e-5;
*
*loop(econ_c,
*   big = smax((r,s), abs(bp(r,s)));
*   big$(big < tol) = 0;
*   npr(econ_rJ)   = yes;
*   nps(jp)  = yes;
*   loop((r,s)$(big and big = abs(bp(r,s))),
*      rank = rank + 1;
*      pair(r,s) = rank;
*      piv    = 1/bp(r,s);
*      big    = 0;
*      npr(r) = no;
*      nps(s) = no;
*
*      bp(  r,nps)  =  bp(r,nps)*piv;
*      bp(npr,nps)  =  bp(npr,nps) - bp(r,nps)*bp(npr,s);
*      bp(npr,  s)  = -bp(npr,s)*piv;
*      bp(  r,  s)  =  piv;
*   );
*   r(r) = npr(r);
*   s(s) = nps(s);
*);

*econVTstarInv(econ_c,econ_rJ) = sum((ip,jp)$(pair(econ_rJ,jp) and pair(ip,econ_c)), bp(ip,jp));

*econVTstarInv(econ_c,econ_r)=round(econVTstarInv(econ_c,econ_r),4);


equations econEq1(econ_r,econ_c),econEq2(econ_r,econ_rJ);

Alias(econ_c,econ_c_d1);
Alias(econ_rJ,econ_rJ_d1);
variable Astar(econ_r,econ_rJ);
econEq1(econ_r,econ_c).. sum(econ_rJ_d1,Astar(econ_r,econ_rJ_d1)*econVTstar(econ_rJ_d1,econ_c))=e=econUstar(econ_r,econ_c);

Alias(econ_r,econ_r_d1);
Alias(econ_rJ,econ_rJ_d1);
parameter ident(econ_r,econ_rJ);
ident(econ_r,econ_rj)$(ord(econ_r)=ord(econ_rJ))=1;

variable L(i,j);
econEq2(econ_r,econ_rJ).. L(econ_r,econ_rJ)=e=ident(econ_r,econ_rJ)-Astar(econ_r,econ_rJ);

L.fx(econ_r,notRJ)=0;
L.fx(vc_r,j)=0;
L.fx(rnfa_r,j)=0;


parameter vcVT(i,j);
vcVT(i,j)=vcV(j,i);
variable VCstar(i,j);
set notVC(j),notRNFA(j);
notVC(j)=econ_c(j)+rnfa_c(j);
notRNFA(j)=econ_c(j)+vc_c(j);
equation vcEq1(vc_r,vc_c);
vcEq1(vc_r,vc_c).. VCstar(vc_r,vc_c)=e=vcVT(vc_r,vc_c)-vcU(vc_r,vc_c);
VCstar.fx(vc_r,notVC)=0;
VCstar.fx(econ_r,j)=0;
VCstar.fx(rnfa_r,j)=0;

parameter rnfaVT(i,j);
rnfaVT(i,j)=rnfaV(j,i);
variable RNFA(i,j);
equation rnfaEq1(rnfa_r,rnfa_c);
rnfaEq1(rnfa_r,rnfa_c).. RNFA(rnfa_r,rnfa_c)=e=rnfaVT(rnfa_r,rnfa_c)-rnfaU(rnfa_r,rnfa_c);
RNFA.fx(rnfa_r,notRNFA)=0;
RNFA.fx(econ_r,j)=0;
RNFA.fx(vc_r,j)=0;

equation xEq1(i,j),bEq1(k,j);
variable X(i,j);
xEq1(i,j).. X(i,j)=e=L(i,j)+dcUvc(i,j)+dcUrnfa(i,j)+ucUvc(i,j)+ucUrnfa(i,j)+dcVCrnfa(i,j)+ucVCrnfa(i,j)+VCstar(i,j)+RNFA(i,j);
variable B(k,j);
bEq1(k,j).. B(k,j)=e=econBstar(k,j)+vcB(k,j);
B.fx(econ_int,vc_c)=0;
B.fx(econ_int,rnfa_c)=0;
B.fx(vc_int,econ_c)=0;
B.fx(vc_int,vc_c)=vcB(vc_int,vc_c);
B.fx(vc_int,rnfa_c)=0;

*Display X;



*sets
*    li(j,i) limitingsets //
*   posb(i) positive products //;

*parameter yei(j) Yield //;

*f.lo(i)$(posb(i)) =0;
f.fx(i)$(vc_r(i)) =0;
f.lo(i)$(econ_r(i)) =0;
m.lo(j)=0;

*Enter Bases in mol/sec
$if not set basis $set basis 1

equation LCModel(i);

LCModel(i).. sum(j,X(i,j)*m(j))=e=f(i);

equation LCIntModel(k);

LCIntModel(k)..sum(j,B(k,j)*m(j))=e=g(k);

*equation yeildConstr(j,i);
*yeildConstr(j,i)$li(j,i).. m(j)=l= yei(j)*sum(jd1,X(i,jd1)*m(jd1))/(abs(X(i,j))*(1-yei(j)));



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


equation DeltaEeq;
variable DeltaE;
DeltaEeq.. DeltaE=e=sum((j,i)$A1f1(j,i),abs(X(i,j))*m(j)*Hcom(i))-sum((j,i)$A3f3(j,i),abs(X(i,j))*m(j)*Hcom(i));

equation ICEq;
variable IC;
ICEq.. IC=e=3*DeltaE*0.35;


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
CostInEq.. costIn=e=sum((i,j)$U2RNFA(i,j),-1*(X(i,j))*m(j))+sum((i,j)$U2VC(i,j),-1*(X(i,j))*m(j))+sum(j$IAsource(j),costIASource(j)*m(j));
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
*    Solve P2PRNFA using NLP minimizing dumm;
*    Solve P2PRNFA using LP maximizing NPV; 
*     NPVDummy=NPV.l;
*    NPV.lo=NPVDummy;
*   Solve P2PRNFA using LP minimizing CO2Eq; 

  Solve P2PRNFA using NLP minimizing LCC;
*    LCCDummy=LCC.l;
*   LCC.up=LCCDummy;
*   Solve P2PRNFA using NLP minimizing CO2Eq; 
*Solve P2PRNFA using NLP minimizing CO2Eq; 
*  Solve P2PRNFA using LP minimizing kgP; 
*   Solve P2PRNFA using LP minimizing landArea; 
* Solve P2PRNFA using NLP minimizing CO2Eq; 
*  CO2Dummy=CO2Eq.l;
*  CO2Eq.up=CO2Dummy;
*  Solve P2PRNFA using NLP minimizing LCC; 

*Display econVTstarInv;
*Display Astar,rank;
Display m.l;
Display f.l;
Display g.l;

parameter diffCalc1(econ_c,econ_rJ),diffCalc2(econ_r,econ_c);
diffCalc1(econ_c,econ_rJ)=econVstar.l(econ_c,econ_rJ)-econV(econ_c,econ_rj);
diffCalc2(econ_r,econ_c)=econUstar.l(econ_r,econ_c)-econU(econ_r,econ_c);
Display diffCalc1,diffCalc2;

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


execute_unload 'X.gdx', X;
execute 'gdxdump X.gdx output=X.csv symb=X format=csv'

execute_unload 'B.gdx', B;
execute 'gdxdump B.gdx output=B.csv symb=B format=csv'
execute 'python convert_to_inc.py'
*
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

