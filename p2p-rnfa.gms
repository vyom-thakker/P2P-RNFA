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
econV(j,j)
econU(i,j)
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
*econV(econ_c,econ_r)
*econU(econ_r,econ_c)
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
$include ./incFiles/vcV.inc
$include ./incFiles/vcU.inc
$include ./incFiles/econV.inc
$include ./incFiles/econU.inc
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
$onlisting

parameters
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
alias(i,id1,id2);
alias(j,jd1,jd2,jd3);
econVstar(econ_c,econ_rJ)=econV(econ_c,econ_rJ)-sum(jd1$vc_c(jd1),PpT(econ_c,jd1)*sum(jd2$vc_c(jd2),phat(jd1,jd2)*sum(id1$vc_r(id1),vcV(jd2,id1)*PfT(id1,econ_rJ))));


econUstar(econ_r,econ_c)=econU(econ_r,econ_c)-(sum(id1$vc_r(id1),PfU(econ_r,id1)*sum(jd1$vc_c(jd1),vcU(id1,jd1)*sum(jd2$vc_c(jd2),phat(jd1,jd2)*Pp(jd2,econ_c))))+sum(id2$vc_r(id2),PfU(econ_r,id2)*dcUvc(id2,econ_c))+sum(jd3$vc_c(jd3),ucUvc(econ_r,jd3)*Pp(jd3,econ_c)));

parameter econVTstar(econ_rJ,econ_c);
econVTstar(econ_rJ,econ_c)=econVstar(econ_c,econ_rJ);

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

Alias(econ_r,econ_r_d1);
Alias(econ_rJ,econ_rJ_d1);
parameter L(i,j);
L(econ_r_d1,econ_rJ_d1)=Astar(econ_r_d1,econ_rJ_d1) $(ord(econ_r_d1)<>ord(econ_rJ_d1))+(1-Astar(econ_r_d1,econ_rJ_d1)) $(ord(econ_r_d1)=ord(econ_rJ_d1));

parameter vcVT(i,j);
vcVT(i,j)=vcV(j,i);
parameter VCstar(i,j);
VCstar(i,j)=vcU(i,j)-vcVT(i,j);

parameter rnfaVT(i,j);
rnfaVT(i,j)=rnfaV(j,i);
parameter RNFA(i,j);
RNFA(i,j)=rnfaU(i,j)-rnfaVT(i,j);

parameter X(i,j);
X(i,j)=round(L(i,j),3)+dcUvc(i,j)+dcUrnfa(i,j)+ucUvc(i,j)+ucUrnfa(i,j)+dcVCrnfa(i,j)+ucVCrnfa(i,j)+VCstar(i,j)+RNFA(i,j);

Display X;

positive variable m(j);
variable f(i);


equation LCModel(i);

LCModel(i).. sum(j,X(i,j)*m(j))=e=f(i);


equation dumm;
variable dum;
dumm.. dum=e=10;
	Model P2PRNFA /ALL/;
*Option LP=Gurobi;
	Solve P2PRNFA using LP maximizing dum; 



execute_unload 'X.gdx', X; 
execute 'gdxdump X.gdx output=X.csv symb=X format=csv'
execute 'rm X.gdx'

*Display Astar;
*display rank, piv;

