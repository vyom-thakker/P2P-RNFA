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

parameter econVstarInv(econ_r,econ_c);
*execute_unload 'econVstar.gdx', i,j,econVstar;
*execute '=invert.exe econVstar.gdx i j econVstar econVstarInv.gdx econVstarInv';
*execute_load 'econVstarInv.gdx', econVstarInv;

$offlisting
$include inverseMat.gms
$onlisting

econVstarInv(econ_r,econ_c)=round(econVstarInv(econ_r,econ_c),4);

Display econVstarInv;

