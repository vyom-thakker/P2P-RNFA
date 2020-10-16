$OnText
GAMS for Global Optimization Biorefinery Supply Chain

$OffText

Sets
i suppliers               /s1*s2/
j Potential facilities    /b1*b3/
k customer                /c1*c2/
p product type            /ethanol/
r raw material type       /m/
w technology type         /Conv/
o objective function      /tc,te,tj/ ;

$set min -1
$set max +1

Parameter dir(o) 'direction of the objective functions'
                 / tc %min%, te %min%, tj %max% /;

* Parameter Definition
Parameters

$OnText
.............................................
cost parameters
..............................................
$OffText
Table PCO(p,w,j)      Cost of Opening a facility
                       conv.b1    conv.b2    conv.b3
      ethanol          5e6        7e6        6e6

Table PCP(p,w,j)      Cost of Production
                      conv.b1    conv.b2    conv.b3
      ethanol          120       150        135

Table PCR(i,r,p)      Cost of Raw Material
                      m.ethanol
      s1              7.68
      s2              11.88

Table PCT(i,r,j)      Cost of Transporting Raw material
                       m.b1       m.b2       m.b3
      s1               0.064      0.035      0.088
      s2               0.072      0.076      0.080

Table PCD(j,p,k)      Cost of Transporting Product
                       ethanol.c1 ethanol.c2
      b1               0.104       0.056
      b2               0.045       0.096
      b3               0.048       0.176
$OnText
.............................................
GHG parameters
..............................................
$OffText

Table PGP(p,w,j)      Energy Consumption in Biorefinery
                       conv.b1    conv.b2    conv.b3
      ethanol          0.4        0.2        0.33

Table PGT(i,r,j)      GHG in  Transporting Raw material
                       m.b1       m.b2       m.b3
      s1               0.12       0.0525     0.165
      s2               0.135      0.1425     0.150

Table PGD(j,p,k)      GHG Transporting Product
                       ethanol.c1 ethanol.c2
      b1               0.1950       0.105
      b2               0.0675       0.180
      b3               0.0900       0.350

Table PGW(p,w,j)      Waste Generated
                       conv.b1    conv.b2    conv.b3
      ethanol          0.0002     0.0001     0.00015

$OnText
.............................................
Social parameters
..............................................
$OffText

Table PSC(p,w,j)       Social  coefficient
                       conv.b1    conv.b2    conv.b3
      ethanol          250        300        270

$OnText
.............................................
Constrainst  parameters
..............................................
$OffText
Table PCC(p,w,j)      Capacity of Biorefinery
                      conv.b1    conv.b2    conv.b3
      ethanol         2.5e5      3.0e5      2.7e5
Table DEM(p,k)        Demand of product by customer
                       c1        c2
      ethanol          1e5       1.5e5 ;

Variables
b(o)            multiobjective functions

Binary Variables
  F(p,w,j)      facility location
  si(i,j)       raw material supply

Positive Variables

  X(p,w,j)     Amount of Products produced
  Y(r,i,j)     Amount of Raw Material Transported
  Z(j,p,k)     Amount of Product Transported ;

Equations
$OnText
.............................................
Objevtive Function
..............................................
$OffText
eCostFunction      FunctionCost
eEnvFunction       FunctionEnvironment
eSocFunction       FunctionSocial

$OnText
.............................................
Constraints
..............................................
$OffText
Cons1          Demand Satisfaction
Cons2          Capacity Production Limit
cons3          material balance of flow of materials
cons4          Conservation of flow
cons5          Supplt to facility ;

eCostFunction.. b('tc') =e= sum[(p,w,j),   PCO(p,w,j)*F(p,w,j)]
                          + sum[(i,r,p,j), PCR(i,r,p)*Y(r,i,j)]
                          + sum[(i,r,j),   PCT(i,r,j)*Y(r,i,j)]
                          + sum[(j,p,k),   PCD(j,p,k)*Z(j,p,k)];

eEnvFunction..  b('te') =e= sum[(p,w,j),   PGP(p,w,j)*X(p,w,j)]
                          + sum[(p,w,j),   PGW(p,w,j)*X(p,w,j)]
                          + sum[(r,i,j),   PGT(i,r,j)*Y(r,i,j)]
                          + sum[(j,p,k),   PGD(j,p,k)*Z(j,p,k)];

eSocFunction..  b('tj') =e= sum[(p,w,j),   PSC(p,w,j)*F(p,w,j)];



Cons1(p,k)..         sum(j, Z(j,p,k)) =g= DEM(p,k);
cons2(w,j)..         sum(p, X(p,w,j)* F(p,w,j)) =l= sum(p, PCC(p,w,j));
cons3(p,w,k)..       sum(j, X(p,w,j)* F(p,w,j))- sum(j, Z(j,p,k)) =e= 0;
cons4(r)..           sum((i,j), si(i,j)* Y(r,i,j))- sum((p,w,j),X(p,w,j)*F(p,w,j)) =e=0;
cons5(j)..           sum(i, si(i,j)) =e= 1;

Model example / all /;

$STitle eps-Constraint Method
Set
   o1(o)  'the first element of k'
   om1(o) 'all but the first elements of k';

o1(o)$(ord(o) = 1) = yes;
om1(o)  = yes;
om1(o1) =  no;

Set oo(o) 'active objective function in constraint allobj';

Parameter
   rhs(o)     'right hand side of the constrained obj functions in eps-constraint'
   maxobj(o)  'maximum value from the payoff table'
   minobj(o)  'minimum value from the payoff table';

Variable
   a_objval   'auxiliary variable for the objective function'
   obj        'auxiliary variable during the construction of the payoff table';

Positive Variable
   sl(o)      'slack or surplus variables for the eps-constraints';

Equation
   con_obj(o) 'constrained objective functions'
   augm_obj   'augmented objective function to avoid weakly efficient solutions'
   allobj     'all the objective functions in one expression';

con_obj(om1).. b(om1) - dir(om1)*sl(om1) =e= rhs(om1);


* We optimize the first objective function and put the others as constraints
* the second term is for avoiding weakly efficient points
augm_obj.. sum(o1,dir(o1)*b(o1)) + 1e-3*sum(om1,sl(om1)/(maxobj(om1) - minobj(om1))) =e= a_objval;

allobj..   sum(oo, dir(oo)*b(oo)) =e= obj;

Model
   mod_payoff    / example, allobj /
   mod_epsmethod / example, con_obj, augm_obj /;

option limRow = 0, limCol = 0, solPrint = off, solveLink = %solveLink.CallModule%;

Parameter payoff(o,o) 'payoff tables entries';

Alias (o,op);

* Generate payoff table applying lexicographic optimization
loop(op,
   oo(op) = yes;
   repeat
      solve mod_payoff using MINLP maximizing obj;
      payoff(op,oo) = b.l(oo);
      b.fx(oo)      = b.l(oo);
      oo(o++1)      = oo(o);
   until oo(op);
   oo(op) = no;
*  release the fixed values of the objective functions for the new iteration
   b.up(o) =  inf;
   b.lo(o) = -inf;
);

*if(mod_payoff.modelStat <> %modelStat.optimal% and
*   mod_payoff.modelStat <> %modelStat.feasibleSolution%,
*   abort 'no feasible solution for mod_payoff');

*display payoff;

minobj(o) = smin(op,payoff(op,o));
maxobj(o) = smax(op,payoff(op,o));

$set fname p.%gams.scrext%

File fx 'solution points from eps-method' / "%gams.scrdir%%fname%" /;

$if not set gridpoints $set gridpoints 10

Set
   g         'grid points' / g0*g%gridpoints% /
   grid(o,g) 'grid';

Parameter
   gridrhs(o,g) 'rhs of eps-constraint at grid point'
   maxg(o)      'maximum point in grid for objective'
   posg(o)      'grid position of objective'
   firstOffMax  'counter'
   lastZero     'counter'
   numo(o)      'ordinal value of k starting with 1'
   numg(g)      'ordinal value of g starting with 0';

lastZero = 1;
loop(om1,
   numo(om1) = lastZero;
   lastZero  = lastZero + 1;
);
numg(g) = ord(g) - 1;

grid(om1,g) = yes;
maxg(om1)   = smax(grid(om1,g), numg(g));
gridrhs(grid(om1,g))$(%min% = dir(om1)) = maxobj(om1) - numg(g)/maxg(om1)*(maxobj(om1) - minobj(om1));
gridrhs(grid(om1,g))$(%max% = dir(om1)) = minobj(om1) + numg(g)/maxg(om1)*(maxobj(om1) - minobj(om1));
display gridrhs;

* Walk the grid points and take shortcuts if the model becomes infeasible
posg(om1) = 0;
repeat
   rhs(om1) = sum(grid(om1,g)$(numg(g) = posg(om1)), gridrhs(om1,g));
   solve mod_epsmethod maximizing a_objval using MINLP;

   if(mod_epsmethod.modelStat <> %modelStat.optimal%,
      lastZero = 0;
      loop(om1$(posg(om1)  > 0 and lastZero = 0), lastZero = numo(om1));
      posg(om1)$(numo(om1) <= lastZero) = maxg(om1);
   else
      loop(o, put fx b.l(o):12:2); put /;
   );

*  Proceed forward in the grid
   firstOffMax = 0;
   loop(om1$(posg(om1) < maxg(om1) and firstOffMax = 0),
      posg(om1)   = posg(om1) + 1;
      firstOffMax = numo(om1);
   );
   posg(om1)$(numo(om1) < firstOffMax) = 0;
until sum(om1$(posg(om1) = maxg(om1)),1) = card(om1) and firstOffMax = 0;
putClose fx;

* Get unique solutions from the point file using some Posix Tools (awk, (g)sort, uniq) that come with GAMS
$set awkscript awk.%gams.scrext%
File fa / "%gams.scrdir%%awkscript%" /;
put  fa 'BEGIN { printf("Table solutions(*,*)\n$ondelim\nsol';
loop(o, put ',' o.tl:0);
putClose '\n"); }' / '{ print NR,$0 }' / 'END { print ";" }';
$if     %system.filesys% == UNIX execute 'cd "%gams.scrdir%" && sort %fname% | uniq | awk -f %awkscript% > g.%gams.scrext% && gams g.%gams.scrext% o=gx.%gams.scrext% lo=0 gdx=soleps';
$if not %system.filesys% == UNIX execute 'cd "%gams.scrdir%" && gsort %fname% | uniq | awk -f %awkscript% > g.%gams.scrext% && gams g.%gams.scrext% o=gx.%gams.scrext% lo=0 gdx=soleps';
execute 'mv -f "%gams.scrdir%soleps.gdx" .';

Set s 'solutions' / 1*50 /;

Parameter solutions(s,o) 'unique solutions';

execute_load 'soleps', solutions;
display solutions;

$exit

$onText










