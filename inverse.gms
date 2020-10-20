
nText
This example demonstrates the use of Loops and Dynamic definition
of sets in elementary transformations using Gaussian Elimination with
full pivot selection.


GAMS Development Corporation, Formulation and Language Example.

Keywords: matrix inversion, Gaussian elimination, full pivoting
$offText

Set
   i 'row labels'    / row-1 * row-3 /
      j 'column labels' / col-1 * col-3 /;

      Alias (i,ip), (j,jp);

      Table a(i,j) 'original matrix'
                    col-1  col-2  col-3
                       row-1          1      2      3
                          row-2          1      3      4
                             row-3          1      4      3;

                             Parameter
                                b(j,i)    'inverse of a'
                                   bp(i,j)   'permuted and transposed inverse of a'
                                      pair(i,j) 'pivoting sequence and permutation'
                                         rank      'rank of matrix a'
                                            adet      'absolute value of determinant of matrix a'
                                               piv
                                                  big
                                                     tol;

                                                     Set
                                                        r(i)   'pivot row candidates'
                                                           npr(i) 'non pivot rows'
                                                              s(j)   'pivot column candidates'
                                                                 nps(j) 'non pivot columns';

                                                                 r(i)    = yes;
                                                                 s(j)    = yes;
                                                                 bp(i,j) = a(i,j);
                                                                 rank    = 0;
                                                                 adet    = 1;
                                                                 tol     = 1e-5;

                                                                 loop(j,
                                                                    big = smax((r,s), abs(bp(r,s)));
                                                                       big$(big < tol) = 0;
                                                                          npr(i)   = yes;
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

                                                                 b(j,i) = sum((ip,jp)$(pair(i,jp) and pair(ip,j)), bp(ip,jp));
                                                                 adet   = abs(adet);

                                                                 display a, rank, adet, pair, bp, b;

                                                                 Parameter
                                                                    ir(i,ip) 'a times b'
                                                                       ic(j,jp) 'b times a';

                                                                       ir(i,ip) = sum(j, a(i,j)*b(j,ip));
                                                                       ic(j,jp) = sum(i, b(j,i)*a(i,jp));

                                                                       display ir, ic;
