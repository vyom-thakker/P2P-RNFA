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
econV(j,i)
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
Pf(i,i)
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
*Pf(econ_r,vc_r)
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
$include ./incFiles/Pp.inc
$onlisting

parameters
vcVstar(j,i)
vcUstar(i,j)
econVstar(j,i)
econUstar(i,j);

parameters
PfT(i,i)
PpT(j,j);

PfT(vc_r,econ_r)=Pf(econ_r,vc_r);
PpT(econ_c,vc_c)=Pp(vc_c,econ_c);
phat(vc_c,vc_c)=p(vc_c);
alias(i,id1,id2);
alias(j,jd1,jd2,jd3);
econVstar(econ_c,econ_r)=econV(econ_c,econ_r)-sum(jd1$vc_c(jd1),PpT(econ_c,jd1)*sum(jd2$vc_c(jd2),phat(jd1,jd2)*sum(id1$vc_r(id1),vcV(jd2,id1)*PfT(id1,econ_r))));


econUstar(econ_r,econ_c)=econU(econ_r,econ_c)-(sum(id1$vc_r(id1),Pf(econ_r,id1)*sum(jd1$vc_c(jd1),vcU(id1,jd1)*sum(jd2$vc_c(jd2),phat(jd1,jd2)*Pp(jd2,econ_c))))+sum(id2$vc_r(id2),Pf(econ_r,id2)*dcUvc(id2,econ_c))+sum(jd3$vc_c(jd3),ucUvc(econ_r,jd3)*Pp(jd3,econ_c)));

parameter econVTstar(econ_r,econ_c);
econVTstar(econ_r,econ_c)=econVstar(econ_c,econ_r);

parameter econVTstarInv(econ_c,econ_r);
*execute_unload 'econVstar.gdx', i,j,econVstar;
*execute '=invert.exe econVstar.gdx i j econVstar econVstarInv.gdx econVstarInv';
*execute_load 'econVstarInv.gdx', econVstarInv;

*$offlisting
*$include inverseMat.gms
*$onlisting

Alias (econ_r,ip), (econ_c,jp);


Parameter
   bp(econ_r,econ_c)   'permuted and transposed inverse of a'
   pair(econ_r,econ_c) 'pivoting sequence and permutation'
   rank      'rank of matrix a'
   adet      'absolute value of determinant of matrix a'
   piv
   big
   tol;

Set
   r(econ_r)   'pivot row candidates'
   npr(econ_r) 'non pivot rows'
   s(econ_c)   'pivot column candidates'
   nps(econ_c) 'non pivot columns';

r(econ_r)    = yes;
s(econ_c)    = yes;
bp(econ_r,econ_c) = econVTstar(econ_r,econ_c);
rank    = 0;
adet    = 1;
tol     = 1e-5;

loop(econ_c,
   big = smax((r,s), abs(bp(r,s)));
   big$(big < tol) = 0;
   npr(econ_r)   = yes;
   nps(jp)  = yes;
   loop((r,s)$(big and big = abs(bp(r,s))),
      rank = rank + 1;
      pair(r,s) = rank;
      piv    = 1/bp(r,s);
      big    = 0;
      adet   = adet/piv;
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

econVTstarInv(econ_c,econ_r) = sum((ip,jp)$(pair(econ_r,jp) and pair(ip,econ_c)), bp(ip,jp));

*econVTstarInv(econ_c,econ_r)=round(econVTstarInv(econ_c,econ_r),4);

Alias(econ_c,econ_c_d1);
parameter Astar(econ_r,econ_r);
Astar(econ_r,econ_r)=sum(econ_c_d1,econUstar(econ_r,econ_c_d1)*econVTstarInv(econ_c_d1,econ_r));

Alias(econ_r,econ_r_d1,econ_r_d2);
parameter L(i,i);
L(econ_r_d1,econ_r_d2)=Astar(econ_r_d1,econ_r_d2) $(ord(econ_r_d1)<>ord(econ_r_d2))+(1-Astar(econ_r_d1,econ_r_d2)) $(ord(econ_r_d1)=ord(econ_r_d2));



parameter X(i,j);


*execute_unload 'Astar.gdx', econ_r,Astar; 
*execute 'gdxdump Astar.gdx output=Astar.csv symb=Astar format=csv'
*execute 'rm Astar.gdx'

*Display Astar;
*display rank, piv;

