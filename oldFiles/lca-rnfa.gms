sets
   li(j,i) limitingsets /399.395, 400.395, 401.395, 402.396, 403.396, 404.396, 405.401, 406.402, 407.397, 408.400, 409.398, 410.400, 411.395, 412.395, 413.395, 414.403, 415.406, 416.406, 417.410, 418.404, 419.404, 420.407, 421.411, 422.405, 423.408, 424.412, 425.409/
   posb(i) positive products /395*401,416*418,424*425/
   p /Vk, Cost, CO2/

parameter A(i,j);

*$call GDXXRW indata.xlsx trace=3 par=A rng=StoichMatrix!B1 rdim=1 cdim=1
*$GDXIN indata.gdx
*$LOAD A
*$GDXIN

$offlisting
$include ./incFiles/indata.inc
$onlisting
display A;

positive variables
     f reaction flow;

parameter
     yei(j) Yield /399 0.97, 400 0.97, 401 0.97, 402 0.97, 403 0.97, 404 0.97, 405 0.97, 406 0.97, 407 0.97, 408 0.97, 409 0.97, 410 0.97, 411 0.97, 412 0.97, 413 0.97, 414 0.97, 415 0.97, 416 0.97, 417 0.97, 418 0.97, 419 0.97, 420 0.97, 421 0.97, 422 0.97, 423 0.97, 424 0.97, 425 0.97/
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



Execute_Unload 'outdata.gdx';
*Execute 'GDXXRW outdata.gdx par=z rng=Sheet1!A1';
