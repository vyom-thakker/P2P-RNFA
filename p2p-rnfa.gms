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
econ_int(k) interventions /1*21/
vc_int(k) vc interventions/22*24/;

parameters
vcV(j,i)
vcU(i,j)
vcB(k,j)
econV(j,j)
econU(i,j)
A(i,j)
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

dcUvc(vc_r,econ_c)=0;
dcUrnfa(rnfa_r,econ_c)=0;
ucUvc(econ_r,vc_c)=0;
ucUrnfa(econ_r,rnfa_c)=0;



$offlisting
$include ./incFiles/vcV.inc
$include ./incFiles/vcU.inc
$include ./incFiles/vcB.inc
$include ./incFiles/econV.inc
$include ./incFiles/econU.inc
$include ./incFiles/econB.inc
$include ./incFiles/rnfaV.inc
$include ./incFiles/rnfaU.inc
$include ./incFiles/dcUvc.inc
$include ./incFiles/dcUrnfa.inc
$include ./incFiles/dcVCrnfa.inc
$include ./incFiles/ucUvc.inc
$include ./incFiles/ucUrnfa.inc
$include ./incFiles/ucVCrnfa.inc
$include ./incFiles/p.inc
$include ./incFiles/Pf.inc
$include ./incFiles/PfU.inc
$include ./incFiles/Pp.inc
$include ./incFiles/Pb.inc
$include ./incFiles/A.inc
$onlisting


*ucUrnfa('93','422')=-50;
*ucUrnfa('92','411')=-0.0


*ucUrnfa('92','411')=-0.03;
ucUrnfa('92','417')=-0.021;
ucUrnfa('92','421')=-0.021;

parameters
vcVstar(j,i)
vcUstar(i,j)
econVstar(j,j)
econUstar(i,j)
econBstar(k,j)
econR(k,j);

parameters
PfT(i,j)
PpT(j,j);

PfT(vc_r,econ_rJ)=Pf(econ_rJ,vc_r);
PpT(econ_c,vc_c)=Pp(vc_c,econ_c);
phat(vc_c,vc_c)=p(vc_c);
*rnfaV(rnfa_c,'417')=0;

alias(i,id1,id2);
alias(k,kd1,kd2);
alias(j,jd1,jd2,jd3);
econVstar(econ_c,econ_rJ)=econV(econ_c,econ_rJ)-sum(jd1$vc_c(jd1),PpT(econ_c,jd1)*sum(jd2$vc_c(jd2),phat(jd1,jd2)*sum(id1$vc_r(id1),vcV(jd2,id1)*PfT(id1,econ_rJ))));

econR(econ_int,econ_c)=econB(econ_int,econ_c)*sum(econ_rJ,econV(econ_c,econ_rJ)); 



econUstar(econ_r,econ_c)=econU(econ_r,econ_c)-(sum(id1$vc_r(id1),PfU(econ_r,id1)*sum(jd1$vc_c(jd1),vcU(id1,jd1)*sum(jd2$vc_c(jd2),phat(jd1,jd2)*Pp(jd2,econ_c))))+sum(id2$vc_r(id2),PfU(econ_r,id2)*dcUvc(id2,econ_c))+sum(jd3$vc_c(jd3),ucUvc(econ_r,jd3)*Pp(jd3,econ_c)));


parameter econVTstar(econ_rJ,econ_c);
econVTstar(econ_rJ,econ_c)=econVstar(econ_c,econ_rJ);

parameter econVTstarOne(econ_c);
econVTstarOne(econ_c)=sum(econ_rJ,econVTstar(econ_rJ,econ_c));


econBstar(econ_int,econ_c)=(econR(econ_int,econ_c)-sum(kd1$vc_int(kd1),Pb(econ_int,kd1)*sum(jd1$vc_c(jd1),vcB(kd1,jd1)*Pp(jd1,econ_c))))/econVTstarOne(econ_c);

parameter econVTstarInv(econ_c,econ_rJ);




*execute_unload 'econVstar.gdx', i,j,econVstar;
*execute '=invert.exe econVstar.gdx i j econVstar econVstarInv.gdx econVstarInv';
*execute_load 'econVstarInv.gdx', econVstarInv;

*$offlisting
*$include inverseMat.gms
*$onlisting

Alias (econ_rJ,ip), (econ_c,jp);


Parameter
   bp(econ_rJ,econ_c)   'permuted and transposed inverse of a'
   pair(econ_rJ,econ_c) 'pivoting sequence and permutation'
   rank      'rank of matrix a'
   piv
   big
   tol;

Set
   r(econ_rJ)   'pivot row candidates'
   npr(econ_rJ) 'non pivot rows'
   s(econ_c)   'pivot column candidates'
   nps(econ_c) 'non pivot columns';

r(econ_rJ)    = yes;
s(econ_c)    = yes;
bp(econ_rJ,econ_c) = econVTstar(econ_rJ,econ_c);
rank    = 0;
tol     = 1e-5;

loop(econ_c,
   big = smax((r,s), abs(bp(r,s)));
   big$(big < tol) = 0;
   npr(econ_rJ)   = yes;
   nps(jp)  = yes;
   loop((r,s)$(big and big = abs(bp(r,s))),
      rank = rank + 1;
      pair(r,s) = rank;
      piv    = 1/bp(r,s);
      big    = 0;
      npr(r) = no;
      nps(s) = no;

      bp(  r,nps)  =  bp(r,nps)*piv;
      bp(npr,nps)  =  bp(npr,nps) - bp(r,nps)*bp(npr,s);
      bp(npr,  s)  = -bp(npr,s)*piv;
      bp(  r,  s)  =  piv;
   );
   r(r) = npr(r);
   s(s) = nps(s);
);

econVTstarInv(econ_c,econ_rJ) = sum((ip,jp)$(pair(econ_rJ,jp) and pair(ip,econ_c)), bp(ip,jp));

*econVTstarInv(econ_c,econ_r)=round(econVTstarInv(econ_c,econ_r),4);

Alias(econ_c,econ_c_d1);
parameter Astar(econ_r,econ_rJ);
Astar(econ_r,econ_rJ)=sum(econ_c_d1,econUstar(econ_r,econ_c_d1)*econVTstarInv(econ_c_d1,econ_rJ));



parameter econVTInv(econ_c,econ_rJ);

parameter econVT(econ_rJ,econ_c);
econVT(econ_rJ,econ_c)=econV(econ_c,econ_rJ);

r(econ_rJ)    = yes;
s(econ_c)    = yes;
bp(econ_rJ,econ_c) = econVT(econ_rJ,econ_c);
rank    = 0;
tol     = 1e-5;

loop(econ_c,
   big = smax((r,s), abs(bp(r,s)));
   big$(big < tol) = 0;
   npr(econ_rJ)   = yes;
   nps(jp)  = yes;
   loop((r,s)$(big and big = abs(bp(r,s))),
      rank = rank + 1;
      pair(r,s) = rank;
      piv    = 1/bp(r,s);
      big    = 0;
      npr(r) = no;
      nps(s) = no;

      bp(  r,nps)  =  bp(r,nps)*piv;
      bp(npr,nps)  =  bp(npr,nps) - bp(r,nps)*bp(npr,s);
      bp(npr,  s)  = -bp(npr,s)*piv;
      bp(  r,  s)  =  piv;
   );
   r(r) = npr(r);
   s(s) = nps(s);
);

econVTInv(econ_c,econ_rJ) = sum((ip,jp)$(pair(econ_rJ,jp) and pair(ip,econ_c)), bp(ip,jp));

parameter A1(econ_r,econ_rJ);
A1(econ_r,econ_rJ)=sum(econ_c_d1,econU(econ_r,econ_c_d1)*econVTInv(econ_c_d1,econ_rJ));


Alias(econ_r,econ_r_d1);
Alias(econ_rJ,econ_rJ_d1);
parameter ident(econ_r,econ_rJ);
ident(econ_r,econ_rj)$(ord(econ_r)=ord(econ_rJ))=1;

parameter L(i,j);
parameter L1(i,j);
L(econ_r,econ_rJ)=ident(econ_r,econ_rJ)-Astar(econ_r,econ_rJ);
L1(econ_r,econ_rJ)=ident(econ_r,econ_rJ)-A1(econ_r,econ_rJ);

parameter vcVT(i,j);
vcVT(i,j)=vcV(j,i);
parameter VCstar(i,j);
VCstar(i,j)=vcVT(i,j)-vcU(i,j);

parameter rnfaVT(i,j);
rnfaVT(i,j)=rnfaV(j,i);
parameter RNFA(i,j);
RNFA(i,j)=rnfaVT(i,j)-rnfaU(i,j);


parameter XSTAR(i,j);
parameter X(i,j);
XSTAR(i,j)=round(L(i,j),3)+dcUvc(i,j)+dcUrnfa(i,j)+ucUvc(i,j)+ucUrnfa(i,j)+dcVCrnfa(i,j)+ucVCrnfa(i,j)+VCstar(i,j)+RNFA(i,j);
X(i,j)=round(L1(i,j),3)+dcUvc(i,j)+dcUrnfa(i,j)+ucUvc(i,j)+ucUrnfa(i,j)+dcVCrnfa(i,j)+ucVCrnfa(i,j)+VCstar(i,j)+RNFA(i,j);
parameter BSTAR(k,j);
parameter B(k,j);
BSTAR(k,j)=round(econBSTAR(k,j),3)+vcB(k,j);
B(k,j)=round(econB(k,j),3)+vcB(k,j);

*Display X;



sets
    li(j,i) limitingsets /399.395, 400.395, 401.395, 402.396, 403.396, 404.396, 405.401, 406.402, 407.397, 408.400, 409.398, 410.400, 411.395, 412.395, 413.395, 414.403, 415.406, 416.406, 417.410, 418.404, 419.404, 420.407, 421.411, 422.405, 423.408, 424.412, 425.409/
    posb(i) positive products /395*411,416/;

parameter yei(j) Yield /399 0.97, 400 0.97, 401 0.97, 402 0.97, 403 0.97, 404 0.97, 405 0.97, 406 0.97, 407 0.97, 408 0.97, 409 0.97, 410 0.97, 411 0.97, 412 0.97, 413 0.97, 414 0.97, 415 0.97, 416 0.97, 417 0.97, 418 0.97, 419 0.97, 420 0.97, 421 0.97, 422 0.97, 423 0.97, 424 0.97, 425 0.97/;


positive variable m(j);
variable f(i);
variable g(k);

f.lo(i)$(posb(i)) =0;
f.fx(i)$(vc_r(i)) =0;
f.lo(i)$(econ_r(i)) =0;
f.up(i)$(econ_r(i)) =100;
f.fx('417')=0;
m.fx('397')=0;
m.fx('386')=0;
m.fx('410')=0;
*m.fx('411')=0;
*m.fx('413')=0;
*m.fx('408')=0;


*positive variable y;
*equation lineqn;
binary variable y;
equation bineqn1,bineqn2;
bineqn1.. m('394')-1000=l=860000*(y);
bineqn2.. m('394')=g=1000*y;
*lineqn.. m('394')=e=542878*y;




*binary variables z1,z2,z3;
*equation bineqn2,bineqn3,bineqn4;
*bineqn2.. (-0.05)*z1+0.05*z3=l=m('394');
*bineqn3.. (-0.05)*z1+860000*z3=g=m('394');
*bineqn4.. z1+z2+z3=e=1;
*bineqn1.. y=e=1-z2;



*Enter Bases in mol/sec
$if not set basis $set basis 1

parameter diffCalcV(econ_c,econ_rJ);
parameter diffCalcU(econ_r,econ_c);
parameter diffCalcB(econ_int,econ_c);
diffCalcU(econ_r,econ_c)=econUstar(econ_r,econ_c)-econU(econ_r,econ_c);
diffCalcV(econ_c,econ_rJ)=econVstar(econ_c,econ_rJ)-econV(econ_c,econ_rj);
diffCalcB(econ_int,econ_c)=round(econBstar(econ_int,econ_c)-econB(econ_int,econ_c),5);
parameter diffCalcX(i,j);
diffCalcX(i,j)=round(Xstar(i,j)-X(i,j),3);


equation LCModel(i);

LCModel(i).. sum(j,(y*Xstar(i,j)+(1-y)*X(i,j))*m(j))=e=f(i);
*LCModel(i).. sum(j,(Xstar(i,j))*m(j))=e=f(i);

equation LCIntModel(k);

LCIntModel(k)..sum(j,(y*Bstar(k,j)+(1-y)*B(k,j))*m(j))=e=g(k);
*LCIntModel(k)..sum(j,Bstar(k,j)*m(j))=e=g(k);

equation yeildConstr(j,i);
yeildConstr(j,i)$li(j,i).. m(j)=l= yei(j)*sum(jd1,X(i,jd1)*m(jd1))/(abs(X(i,j))*(1-yei(j)));



equation MTHFProd;
MTHFProd.. f('399')=e=%basis%;


equation CO2EqConstr;
variable CO2Eq;
CO2EqConstr.. CO2Eq=e=g('4')+g('22');
equation kgPConstr;
variable kgP;
kgPConstr.. kgP=e=g('2')+g('23');

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
*equation posLand;
*posLand.. landArea=g=100;


*equation fruitConstr1,fruitConstr2;
*fruitConstr1.. m('395')=l=0.3*(m('394')+m('395')+m('396'));
*fruitConstr2.. m('396')=l=0.3*(m('394')+m('395')+m('396'));

equation LCCConstr;
variable LCC;
*LCCConstr.. LCC=e=costIn;

equation fval;
variable totalEconf;
fval.. totalEconF=e=sum(i$econ_r(i),f(i));
LCCConstr.. LCC=e=costIn+0.01*totalEconf;
*equation TARPost;
*TarPost.. TAR=g=0;

*(IC*intrate/(1-(1+intrate)**(-5)))

parameters LCCDummy,NPVDummy,CO2Dummy,co2;

$if not set eco2 $set eco2 -1;
co2=%eco2%;
equation eCons;
eCons$(co2>0).. CO2Eq=l=co2;


    Model P2PRNFA /ALL/;
    Option MINLP=BARON;
    Option LP=BARON;
    Option NLP=BARON;
*    Solve P2PRNFA using MINLP maximizing NPV; 
*     NPVDummy=NPV.l;
*    NPV.lo=NPVDummy;
*  Solve P2PRNFA using LP minimizing CO2Eq; 

  Solve P2PRNFA using MINLP minimizing LCC;
*     LCCDummy=LCC.l;
*    LCC.up=LCCDummy;
*  Solve P2PRNFA using MINLP minimizing CO2Eq; 
* Solve P2PRNFA using LP minimizing CO2Eq; 
*  Solve P2PRNFA using MINLP minimizing kgP; 
*   Solve P2PRNFA using MINLP minimizing landArea; 
*  Solve P2PRNFA using MINLP minimizing CO2Eq; 
*   CO2Dummy=CO2Eq.l;
*   CO2Eq.up=CO2Dummy;
*   Solve P2PRNFA using MINLP minimizing LCC; 

*Display econVTstarInv;
*Display Astar,rank;
Display m.l;
Display f.l;
Display y.l;

$if not set file $set file 0


parameter flows(i,j);
set econset(i,j) /#econ_r.#econ_rJ/;
flows(i,j)$(ord(i)<>ord(j) and econset(i,j))=-1*(y.l*Xstar(i,j)+(1-y.l)*X(i,j))*m.l(j);
flows(i,j)$(ord(i)=ord(j) and econset(i,j))=m.l(j)-((y.l*Xstar(i,j)+(1-y.l)*X(i,j))*m.l(j));
flows(i,j)$(not econset(i,j))=(y.l*Xstar(i,j)+(1-y.l)*X(i,j))*m.l(j);
*flows(i,j) $( flows(i,j)<0)=0;


*set sankey(i,j) /#vc_r.#vc_c, #rnfa_r.#rnfa_c, 393.#rnfa_c, 394.#rnfa_c/;

*set from /'corn','apple','banana', S1*S23/;
*set to /S1*S23/;
*variable sankey(from,to);
*sankey('corn',S1)=flows('390','394');
*sankey('apple',S1)=flows('391','395');
*sankey('banana',S1)=flows('392','396');





File chorddiag /chorddiag%fileS%.txt/;
chorddiag.ap=1;
chorddiag.nd=4;
chorddiag.pw=32767;
put chorddiag"";
loop(i,loop(j,put flows(i,j)",") put/);
put "";
put /;


File throughputs /throughputs%fileS%.txt/;
throughputs.ap=1;
throughputs.nd=4;
throughputs.pw=32767;
put throughputs"";
loop(j,put m.l(j)"/");
put "";
put /;

parameter envtflows(k,j);
envtflows(k,j)=(y.l*Bstar(k,j)+(1-y.l)*B(k,j))*m.l(j);

File barchart /barchart%fileS%.txt/;
barchart.ap=1;
barchart.nd=4;
barchart.pw=32767;
put barchart"";
loop(k,loop(j,put envtflows(k,j)",") put/);
put "";
put /;

execute_unload '%fileS%.gdx', flows, m, y;

$onText

File pareto /pareto%file%.txt/;
pareto.ap=1;
pareto.nd=4;
pareto.pw=32767;
put pareto"";
put %basis%",";
put LCC.l",";
put CO2Eq.l",";
put kgP.l",";
put landArea.l"";
put /;



*execute 'mkdir ./case_study_results_nlp/%fileS%folder'
*execute 'mv ./*%fileS%.txt ./case_study_results_nlp/%fileS%folder/'
*execute 'mv ./%fileS%.gdx ./case_study_results_nlp/%fileS%folder/'


File paretoecon /paretoecon%file%.txt/;
paretoecon.ap=1;
paretoecon.nd=4;
paretoecon.pw=32767;
put paretoecon"";
put %basis%",";
put LCC.l",";
put CO2Eq.l",";
loop(j$econ_c(j),put m.l(j)",");
put "";
put /;


File paretovc /paretovc%file%.txt/;
paretovc.ap=1;
paretovc.nd=4;
paretovc.pw=32767;
put paretovc"";
put %basis%",";
put LCC.l",";
put CO2Eq.l",";
loop(j$vc_c(j),put m.l(j)",");
put "";
put /;

File paretornfa /paretornfa%file%.txt/;
paretornfa.ap=1;
paretornfa.nd=4;
paretornfa.pw=32767;
put paretornfa"";
put %basis%",";
put LCC.l",";
put CO2Eq.l",";
loop(j$rnfa_c(j),put m.l(j)",");
put "";
put /;


$ontext
*execute_unload 'XNEW.gdx', X,Astar,VCstar,RNFA,m;
*execute 'gdxdump X.gdx output=X.csv symb=X format=csv'
*execute 'gdxdump X.gdx output=Astar.csv symb=Astar format=csv'
*execute 'gdxdump X.gdx output=VCstar.csv symb=VCstar format=csv'
*execute 'gdxdump X.gdx output=RNFA.csv symb=RNFA format=csv'
*execute 'gdxdump XNEW.gdx output=m.csv symb=m format=csv'
*execute 'rm X.gdx'

*Display Astar;
*display rank, piv;

Display diffCalcU;
Display diffCalcV;
Display diffCalcB;
Display diffCalcX;
$offText
