$onText
Preparing the RNFA-P2P for 3-MTHF Example
Author: Vyom
Date: 02/02/2020
$OffText


Sets
i rows                    /1*417/          
j columns                 /1*425/
k rowsOfB                 /1*24/
econ_r(i) commodities I     /1*385/
econ_rJ(j) commodities I     /1*385/
vc_r(i) elements K          /386*394/  
rnfa_r(i) chemicals M       /395*417/
econ_c(j) sectors J         /1*385/
vc_c(j) processes L        /386*397/  
rnfa_c(j) reactions N        /398*425/
econ_int(k) interventions  /1*21/
vc_int(k) vc interventions /22*24/;

parameters
vcV(j,i)
vcU(i,j)
vcB(k,j)
econV(j,j)
econU(i,j)
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
Pp(j,j);

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
$include ./incfile1.inc
$onlisting

positive variable m(j);
variable f(i);
variable g(k);



variables
vcVstar(j,i)
vcUstar(i,j)
econVstar(j,j)
econUstar(i,j);

parameters
PfT(i,j)
PpT(j,j);

PfT(vc_r,econ_rJ)=Pf(econ_rJ,vc_r);
PpT(econ_c,vc_c)=Pp(vc_c,econ_c);
phat(vc_c,vc_c)=p(vc_c);
*rnfaV(rnfa_c,'417')=0;

alias(i,id1,id2);
alias(j,jd1,jd2,jd3);

binary variable y(j);

equation activeProcess(vc_c);
activeProcess(vc_c).. (1-y(vc_c))*m(vc_c)=e=0;
*activeProcess(vc_c).. y(vc_c)$(m(vc_c)>0)=e=1;


equations disagg1(econ_c,econ_rJ),disagg2(econ_r,econ_c),disagg3(econ_rJ,econ_c);


disagg1(econ_c,econ_rJ).. econVstar(econ_c,econ_rJ)=e=econV(econ_c,econ_rJ)-sum(jd1$vc_c(jd1),PpT(econ_c,jd1)*y(jd1)*sum(jd2$vc_c(jd2),phat(jd1,jd2)*sum(id1$vc_r(id1),vcV(jd2,id1)*PfT(id1,econ_rJ))));

*parameter diffCalc(econ_c,econ_rJ);
*diffCalc(econ_c,econ_rJ)=econVstar(econ_c,econ_rJ)-econV(econ_c,econ_rj);


disagg2(econ_r,econ_c).. econUstar(econ_r,econ_c)=e=econU(econ_r,econ_c)-(sum(id1$vc_r(id1),PfU(econ_r,id1)*sum(jd1$vc_c(jd1),vcU(id1,jd1)*sum(jd2$vc_c(jd2),phat(jd1,jd2)*y(jd2)*Pp(jd2,econ_c))))+sum(id2$vc_r(id2),PfU(econ_r,id2)*dcUvc(id2,econ_c))+sum(jd3$vc_c(jd3),ucUvc(econ_r,jd3)*y(jd3)*Pp(jd3,econ_c)));

variable econVTstar(econ_rJ,econ_c);
disagg3(econ_rJ,econ_c).. econVTstar(econ_rJ,econ_c)=e=econVstar(econ_c,econ_rJ);

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



parameter vcVT(i,j);
vcVT(i,j)=vcV(j,i);
variable VCstar(i,j);
equation vcEq1(vc_r,vc_c);
vcEq1(vc_r,vc_c).. VCstar(vc_r,vc_c)=e=vcVT(vc_r,vc_c)-vcU(vc_r,vc_c);

parameter rnfaVT(i,j);
rnfaVT(i,j)=rnfaV(j,i);
variable RNFA(i,j);
equation rnfaEq1(rnfa_r,rnfa_c);
rnfaEq1(rnfa_r,rnfa_c).. RNFA(rnfa_r,rnfa_c)=e=rnfaVT(rnfa_r,rnfa_c)-rnfaU(rnfa_r,rnfa_c);

equation xEq1(i,j);
variable X(i,j);
xEq1(i,j).. X(i,j)=e=L(i,j)+dcUvc(i,j)+dcUrnfa(i,j)+ucUvc(i,j)+ucUrnfa(i,j)+dcVCrnfa(i,j)+ucVCrnfa(i,j)+VCstar(i,j)+RNFA(i,j);
parameter B(k,j);
B(k,j)=round(econB(k,j),3)+vcB(k,j);

*Display X;



sets
    li(j,i) limitingsets /399.395, 400.395, 401.395, 402.396, 403.396, 404.396, 405.401, 406.402, 407.397, 408.400, 409.398, 410.400, 411.395, 412.395, 413.395, 414.403, 415.406, 416.406, 417.410, 418.404, 419.404, 420.407, 421.411, 422.405, 423.408, 424.412, 425.409/
    posb(i) positive products /395*411,416/;

parameter yei(j) Yield /399 0.97, 400 0.97, 401 0.97, 402 0.97, 403 0.97, 404 0.97, 405 0.97, 406 0.97, 407 0.97, 408 0.97, 409 0.97, 410 0.97, 411 0.97, 412 0.97, 413 0.97, 414 0.97, 415 0.97, 416 0.97, 417 0.97, 418 0.97, 419 0.97, 420 0.97, 421 0.97, 422 0.97, 423 0.97, 424 0.97, 425 0.97/;

f.lo(i)$(posb(i)) =0;
f.fx(i)$(vc_r(i)) =0;
f.lo(i)$(econ_r(i)) =0;
f.fx('417')=0;
m.fx('397')=0;
m.fx('386')=0;


*Enter Bases in mol/sec
$if not set basis $set basis 1

equation LCModel(i);

LCModel(i).. sum(j,X(i,j)*m(j))=e=f(i);

equation LCIntModel(k);

LCIntModel(k)..sum(j,B(k,j)*m(j))=e=g(k);

equation yeildConstr(j,i);
yeildConstr(j,i)$li(j,i).. m(j)=l= yei(j)*sum(jd1,X(i,jd1)*m(jd1))/(abs(X(i,j))*(1-yei(j)));



equation MTHFProd;
MTHFProd.. f('399')=e=%basis%;


equation CO2EqConstr;
variable CO2Eq;
CO2EqConstr.. CO2Eq=e=g('4')+g('22');
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

set U2RNFA(i,j) /#econ_r.#rnfa_c/;
set U2VC(i,j) /#econ_r.#vc_c/;
set IASource(j) /391*396/;
parameter costIASource(j) /391 1.6, 392 6.88, 393 9.98, 394 0.321, 395 0.061, 396 0.101/;
equation costInEq;
variable costIn;
CostInEq.. costIn=e=sum((i,j)$U2RNFA(i,j),abs(X(i,j))*m(j))+sum((i,j)$U2VC(i,j),abs(X(i,j))*m(j))+sum(j$IAsource(j),costIASource(j)*m(j));

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

equation LCCConstr;
variable LCC;
LCCConstr.. LCC=e=costIn;


*equation TARPost;
*TarPost.. TAR=g=0;

*(IC*intrate/(1-(1+intrate)**(-5)))

parameters LCCDummy,NPVDummy,CO2Dummy,co2;

$if not set co2 $set co2 -1;
co2=%co2%;
equation eCons;
eCons$(co2>0).. CO2Eq=l=co2;


    Model P2PRNFA /ALL/;
    Option MINLP=BARON;
*    Solve P2PRNFA using LP maximizing NPV; 
*     NPVDummy=NPV.l;
*    NPV.lo=NPVDummy;
*   Solve P2PRNFA using LP minimizing CO2Eq; 

*    Solve P2PRNFA using LP minimizing LCC;
*     LCCDummy=LCC.l;
*    LCC.up=LCCDummy;
*   Solve P2PRNFA using LP minimizing CO2Eq; 
*  Solve P2PRNFA using LP minimizing CO2Eq; 
*  Solve P2PRNFA using LP minimizing kgP; 
*   Solve P2PRNFA using LP minimizing landArea; 
  Solve P2PRNFA using MINLP minimizing CO2Eq; 
*   CO2Dummy=CO2Eq.l;
*   CO2Eq.up=CO2Dummy;
*   Solve P2PRNFA using LP minimizing LCC; 

*Display econVTstarInv;
*Display Astar,rank;
Display m.l;
Display f.l;

*$if not set file $set file 0
*
*File pareto /pareto%file%.txt/;
*pareto.ap=1;
*pareto.nd=4;
*put pareto"";
*put %basis%",";
*put LCC.l",";
*put CO2Eq.l",";
*put kgP.l",";
*put landArea.l"";
*put /;
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

