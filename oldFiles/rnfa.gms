sets
   i substances /S1*S35/
   j reactions  /R1*R40/
   li(j,i) limitingsets /R1.S1, R2.S1, R3.S1, R4.S2, R5.S2, R6.S2, R7.S7, R8.S8, R9.S3, R10.S6, R11.S4, R12.S6, R13.S1, R14.S1,
           R15.S1, R16.S9, R17.S12, R18.S12, R19.S16, R20.S10, R21.S10, R22.S13, R23.S17, R24.S11, R25.S14, R26.S18, R27.S15/
   posb(i) positive products /S1,S2,S3,S4,S5,S6,S7,S8,S9,S10,S11,S12,S13,S14,S15,S16,S17,S18,S22,S23,S24,S30,S31,S32,S33,S35/
   p /Vk, Cost, CO2/

parameter A(i,j);

*$call GDXXRW indata.xlsx trace=3 par=A rng=StoichMatrix!B1 rdim=1 cdim=1
*$GDXIN indata.gdx
*$LOAD A
*$GDXIN

$offlisting
$include indata.inc
$onlisting
display A;

positive variables
     f reaction flow;

parameter
     yei(j) Yield /R1 0.97, R2 0.97, R3 0.97, R4 0.97, R5 0.97, R6 0.97, R7 0.97, R8 0.97, R9 0.97, R10 0.97, R11 0.97, R12 0.97, R13 0.97, R14 0.97,
           R15 0.97, R16 0.97, R17 0.97, R18 0.97, R19 0.97, R20 0.97, R21 0.97, R22 0.97, R23 0.97, R24 0.97, R25 0.97, R26 0.97, R27 0.97/
     v(p) sustainability metrix;

     v('CO2')=4
variable
     z    objective variable
     b(i) pruduct flow
     f(j) reaction flow



equations

     mobal mole balance
     FI feedstock input
     objproduct  objective pruduct(3-MTFH)
     carboncapture carbon capture
     carbon  carbon emission objective
     cost  cost objective

     constraintY yield constraint

     constraintS  nonnegative constraint;

     mobal(i) .. b(i) =e=sum(j,A(i,j)*f(j));
     FI .. f('R38') =e= 1;
     objproduct .. b('S5') =e= 1;
     carboncapture .. f('R40') =e= 0;
     carbon .. b('S29') =l= v('CO2');

     cost .. z =e= b('S24') ;


     alias(j,k);
     constraintY(i,j)$li(j,i).. f(j) =l= yei(j)*sum(k,A(i,k)*f(k))/(1+(A(i,j)*yei(j)));
     constraintS(i)$posb(i).. b(i) =g= 0;



Model transport /all/ ;
Solve transport using lp maximizing z;

v('Vk') = -b.l('S29')/(-A('S29','R39')*f.l('R39')-A('S29','R40')*f.l('R40')+b.l('S29'));
v('Cost')=100-z.l;

Display b.l;
Display f.l;
Display z.l;



*Execute_Unload 'outdata.gdx';
*Execute 'GDXXRW outdata.gdx par=z rng=Sheet1!A1';
