
Alias (econ_c,ip), (econ_r,jp);


Parameter
   bp(econ_c,econ_r)   'permuted and transposed inverse of a'
   pair(econ_c,econ_r) 'pivoting sequence and permutation'
   rank      'rank of matrix a'
   adet      'absolute value of determinant of matrix a'
   piv
   big
   tol;

Set
   r(econ_c)   'pivot row candidates'
   npr(econ_c) 'non pivot rows'
   s(econ_r)   'pivot column candidates'
   nps(econ_r) 'non pivot columns';

r(econ_c)    = yes;
s(econ_r)    = yes;
bp(econ_c,econ_r) = econVstar(econ_c,econ_r);
rank    = 0;
adet    = 1;
tol     = 1e-5;

loop(j,
   big = smax((r,s), abs(bp(r,s)));
   big$(big < tol) = 0;
   npr(econ_c)   = yes;
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

econVstarInv(econ_r,econ_c) = sum((ip,jp)$(pair(econ_c,jp) and pair(ip,econ_r)), bp(ip,jp));
adet   = abs(adet);

*display econVstar, rank, adet, pair, bp, econVstarInv;
