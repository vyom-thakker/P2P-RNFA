$onText
Preparing the RNFA-P2P for 3-MTHF Example
Author: Vyom
Date: 02/02/2020
$OffText


Sets
i rows                    /1*417/          
j columns                 /1*425/
k rowsOfB                 /1*24/
econ_r(i) commodities     /1*385/
vc_r(i) elements          /386*394/  
rnfa_r(i) chemicals       /395*417/
econ_c(j) sectors         /1*385/
vc_c(j) processes         /386*397/  
rnfa_c(j) reactions       /398*425/
econ_int(k) interventions /1*21/
vc_int(k) vc interventions/22*24/;

parameters
econV(vc_c,vc_r)
econU(vc_r,vc_c)
vcV(econ_c,econ_r)
vcU(econ_r,econ_c)
rnfaV(rnfa_c,rnfa_u)
rnfaU(rnfa_r,rnfa_c)
dcUvc(vc_r,econ_c)
dcUrnfa(rnfa_r,econ_c)
dcVCrnfa(rnfa_r,vc_c)
ucUvc(econ_r,vc_c)
ucUrnfa(econ_r,rnfa_c)
ucVCrnfa(vc_r,rnfa_c)
p(vc_c)
Pf(econ_r,vc_r)
Pp(vc_c,econ_c);


$offlisting
$include econU.inc
$include econV.inc
$onlisting


