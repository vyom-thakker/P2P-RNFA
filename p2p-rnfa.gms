$onText
Preparing the RNFA-P2P for 3-MTHF Example
Author: Vyom
Date: 02/02/2020
$OffText


Sets
i rows                    /1*485/          
j columns                 /1*490/
econ_r(i) commodities     /1*405/
vc_r(i) elements          /406*450/  
rnfa_r(i) chemicals       /450*485/
econ_c(j) sectors         /1*405/
vc_c(j) processes         /406*450/  
rnfa_c(j) reactions       /450*490/;

Variables
underbarV(vc_c,vc_r)
underbarU(vc_r,vc_c)
overbarV(econ_c,econ_r)
overbarU(econ_r,econ_c)
rnfaV(rnfa_c,rnfa_u)
rnfaU(rnfa_r,rnfa_c);

parameter rnfa(rnfa_r,rnfa_c);

$offlisting
$include indata.inc
$onlisting
display rnfa;

parameter econmake(econ_r,econ_c);

$offlisting
$include econmake.inc
$onlisting
display econmake;

parameter econuse(econ_r,econ_c);

$offlisting
$include econuse.inc
$onlisting
display econuse;

*parameter vcmake(vc_r,vc_c);
*$offlisting
*$include vcmake.inc
*$onlisting
*display vcmake;

*parameter vcuse(vc_r,vc_c);
*$offlisting
*$include vcuse.inc
*$onlisting
*display vcuse;

*parameter P_ve_pdt();


*variable ecomakestar;
*equation disagg_econ;
*disagg_econ.. econmakestar=e=econmake-













































variables
vcmakeusd(i,k)
vcuseusd(i,k) ;

alias(i,k);

*THIS IS THE MATRIX MULTIPLICATION OF VCmake USD WITH VCSCALE TO CREATE NEW VCMAKEUSD MATRIXXXXX ::::
eq30(i,jj).. vcmakeusd(i,jj) =e= sum[k, vcscale(i,k)*vcmakeusd2(k,jj)];


*THIS IS THE MATRIX MULTIPLICATION OF VCUSE USD WITH VCSCALE TO CREATE NEW VCUSEUSD MATRIXXXXX ::::

eq31(i,jj).. vcuseusd(i,jj) =e= sum[k, vcuseusd2(i,k)*vcscale(k,jj)];


*TRANSPOSING VCpP PERMUTATION MATRIX
vcpP.fx(m,i)=vcpP1(i,m);

*TRANSPOSING VCPF PERMUTATION MATRIX
vcpF.fx(i,m)=vcpF1(m,i);

equations
econ0,econ1,econ2,econ3,econ4,econ5,econ6,econ7,econ8,econ9,econ10,econ11,econ12,econ13;
variables
vcupstcutdisagg2(m,i);
*MATRIX MULTIPLICLIATION OFFFF     vcupstcut and vcscale
econ1(m,i)..  vcupstcutdisagg2(m,i) =E= sum[k, vcupstcut(m,k)*vcscale(k,i)];
econ0(m,i)..  vcupstcutdisagg(m,i) =E= vcupstcutdisagg2(m,i)/1000000.0;


variables
b1(m),b(m,m),a1(m,i),a(m,n),econmakestar(m,n),c1(m,i),c(m,n),d(m,n),e1(m),e(m,n);

variables
econusestar(m,n),teconmakestar(m,n),astar(m,n);

econ2(m).. b1(m)=E=eqeconpP(m)*eqmakeusd*eqsf;

econ3(m,n).. b(m,n) =E= b1(m)*eqeconpF(n);

econ4(m,i).. a1(m,i) =E= sum[k,vcpP(m,k)*vcmakeusd(k,i)];

econ5(m,n).. a(m,n) =E= sum[k,a1(m,k)*vcpF(k,n)];

econ6(m,n).. econmakestar(m,n)=E= econmake(m,n)-a(m,n)-b(m,n);

econ7(m,i)..  c1(m,i) =E= sum[k,vcpF1(m,k)*vcuseusd(k,i)];

econ8(m,n)..   c(m,n) =E= sum[k,c1(m,k)*vcpP1(k,n)];

econ9(m,n)..  d(m,n) =E=  sum[k,vcupstcutdisagg(m,k)*vcpP1(k,n)];

econ10(m)..   e1(m) =E=   eqeconupstcut(m)*eqsf/1000000.0;

econ11(m,n)..  e(m,n) =E= e1(m)*eqeconpP(n);

econ12(m,n)..   econusestar(m,n) =E= econuse(m,n)-c(m,n)-d(m,n)-e(m,n);

econ13(m,n)..  teconmakestar(n,m) =E=  econmakestar(m,n);

equations econ14,econ15;
alias(m,n1);
econ14(m,n)..  econusestar(m,n)=E= sum[n1,astar(m,n1)*teconmakestar(n1,n)];

parameter
idmat(m,n)
/1.1    1
2.2    1
3.3    1
4.4    1
5.5    1
6.6    1
7.7    1
8.8    1
9.9    1
10.10    1
11.11    1
12.12    1
13.13    1
14.14    1
15.15    1
16.16    1
17.17    1
18.18    1
19.19    1
20.20    1
21.21    1
22.22    1
23.23    1
24.24    1
25.25    1
26.26    1
27.27    1
28.28    1
29.29    1
30.30    1
31.31    1
32.32    1
33.33    1
34.34    1
35.35    1
36.36    1
37.37    1
38.38    1
39.39    1
40.40    1
41.41    1
42.42    1
43.43    1
44.44    1
45.45    1
46.46    1
47.47    1
48.48    1
49.49    1
50.50    1
51.51    1
52.52    1
53.53    1
54.54    1
55.55    1
56.56    1
57.57    1
58.58    1
59.59    1
60.60    1
61.61    1
62.62    1
63.63    1
64.64    1
65.65    1
66.66    1
67.67    1
68.68    1
69.69    1
70.70    1
71.71    1
72.72    1
73.73    1
74.74    1
/;

variable
lstar(m,n)
;

econ15(m,n).. lstar(m,n)=E=idmat(m,n)-astar(m,n);



parameter
tvcmake(i,jj)
/1.1 0/;

*TRANSPOSING VCMAKE
tvcmake(jj,i)=vcmake(i,jj);


*CREATING VCY
parameters
vcy(i,jj)
/1.1 0/
;

vcy(i,jj) = tvcmake(i,jj)-vcuse(i,jj);

variable eqy;
equation eq32;


eq32.. eqy =E= eqmake-equse;

variable g1(i),vcenvintdisagg(m),eqenvintdisagg(m),toteconenvintstar(m) ;


equations env1,env2,env3,env4;

env1(i).. g1(i)=E=vcscalevec(i)*vcenvint(i);
env2(m).. vcenvintdisagg(m)=E=sum[k,g1(k)*vcpP1(k,m)];
env3(m).. eqenvintdisagg(m)=E=eqsf*eqenvint*eqeconpP(m);

env4(m).. toteconenvintstar(m)=E=econenvint(m)-vcenvintdisagg(m)-eqenvintdisagg(m);


parameter
one(m)
/1 1
2 1
3 1
4 1
5 1
6 1
7 1
8 1
9 1
10 1
11 1
12 1
13 1
14 1
15 1
16 1
17 1
18 1
19 1
20 1
21 1
22 1
23 1
24 1
25 1
26 1
27 1
28 1
29 1
30 1
31 1
32 1
33 1
34 1
35 1
36 1
37 1
38 1
39 1
40 1
41 1
42 1
43 1
44 1
45 1
46 1
47 1
48 1
49 1
50 1
51 1
52 1
53 1
54 1
55 1
56 1
57 1
58 1
59 1
60 1
61 1
62 1
63 1
64 1
65 1
66 1
67 1
68 1
69 1
70 1
71 1
72 1
73 1
74 1
/;




variables sectorout(m),econenvintstar(m);
alias(m,n1);

equations env5,env6,eq33;

env5(m).. sectorout(m)=E= sum[n1,teconmakestar(m,n1)*one(n1)];
env6(m).. econenvintstar(m)*1000000.0*sectorout(m)=E= toteconenvintstar(m);

set
p2p /1*91/;
variable
p2pf(p2p);

variables
s(p2p);

*s.L(p2p) = 0.1;



eq33.. p2pf('90') =E= ethanol;


p2pf.fx(p2p)$(Ord(p2p) ne 90) =0;



equations
equat1, equat2, equat3, equat4, equat5, equat6, equat7, equat8, equat9, equat10, equat11, equat12, equat13, equat14, equat15, equat16, equat17, equat18, equat19, equat20, equat21, equat22, equat23, equat24, equat25, equat26, equat27, equat28, equat29, equat30, equat31, equat32, equat33, equat34, equat35, equat36, equat37, equat38, equat39, equat40, equat41, equat42, equat43, equat44, equat45, equat46, equat47, equat48, equat49, equat50, equat51, equat52, equat53, equat54, equat55, equat56, equat57, equat58, equat59, equat60, equat61, equat62, equat63, equat64, equat65, equat66, equat67, equat68, equat69, equat70, equat71, equat72, equat73, equat74, equat75, equat76, equat77, equat78, equat79, equat80, equat81, equat82, equat83, equat84, equat85, equat86, equat87, equat88, equat89, equat90, equat91;

equat1 ..    p2pf('1') =E= lstar('1','1')*s('1')+lstar('1','2')*s('2')+lstar('1','3')*s('3')+lstar('1','4')*s('4')+lstar('1','5')*s('5')+lstar('1','6')*s('6')+lstar('1','7')*s('7')+lstar('1','8')*s('8')+lstar('1','9')*s('9')+lstar('1','10')*s('10')+lstar('1','11')*s('11')+lstar('1','12')*s('12')+lstar('1','13')*s('13')+lstar('1','14')*s('14')+lstar('1','15')*s('15')+lstar('1','16')*s('16')+lstar('1','17')*s('17')+lstar('1','18')*s('18')+lstar('1','19')*s('19')+lstar('1','20')*s('20')+lstar('1','21')*s('21')+lstar('1','22')*s('22')+lstar('1','23')*s('23')+lstar('1','24')*s('24')+lstar('1','25')*s('25')+lstar('1','26')*s('26')+lstar('1','27')*s('27')+lstar('1','28')*s('28')+lstar('1','29')*s('29')+lstar('1','30')*s('30')+lstar('1','31')*s('31')+lstar('1','32')*s('32')+lstar('1','33')*s('33')+lstar('1','34')*s('34')+lstar('1','35')*s('35')+lstar('1','36')*s('36')+lstar('1','37')*s('37')+lstar('1','38')*s('38')+lstar('1','39')*s('39')+lstar('1','40')*s('40')+lstar('1','41')*s('41')+lstar('1','42')*s('42')+lstar('1','43')*s('43')+lstar('1','44')*s('44')+lstar('1','45')*s('45')+lstar('1','46')*s('46')+lstar('1','47')*s('47')+lstar('1','48')*s('48')+lstar('1','49')*s('49')+lstar('1','50')*s('50')+lstar('1','51')*s('51')+lstar('1','52')*s('52')+lstar('1','53')*s('53')+lstar('1','54')*s('54')+lstar('1','55')*s('55')+lstar('1','56')*s('56')+lstar('1','57')*s('57')+lstar('1','58')*s('58')+lstar('1','59')*s('59')+lstar('1','60')*s('60')+lstar('1','61')*s('61')+lstar('1','62')*s('62')+lstar('1','63')*s('63')+lstar('1','64')*s('64')+lstar('1','65')*s('65')+lstar('1','66')*s('66')+lstar('1','67')*s('67')+lstar('1','68')*s('68')+lstar('1','69')*s('69')+lstar('1','70')*s('70')+lstar('1','71')*s('71')+lstar('1','72')*s('72')+lstar('1','73')*s('73')+lstar('1','74')*s('74')-vcupstcut('1','1')*s('75')-vcupstcut('1','2')*s('76')-vcupstcut('1','3')*s('77')-vcupstcut('1','4')*s('78')-vcupstcut('1','5')*s('79')-vcupstcut('1','6')*s('80')-vcupstcut('1','7')*s('81')-vcupstcut('1','8')*s('82')-vcupstcut('1','9')*s('83')-vcupstcut('1','10')*s('84')-vcupstcut('1','11')*s('85')-vcupstcut('1','12')*s('86')-vcupstcut('1','13')*s('87')-vcupstcut('1','14')*s('88')-vcupstcut('1','15')*s('89')-vcupstcut('1','16')*s('90')-eqeconupstcut('1')*s('91');









