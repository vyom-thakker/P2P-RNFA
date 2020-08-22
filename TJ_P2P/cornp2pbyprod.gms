$offlisting
$offsymxref
$offsymlist
option
    limrow = 0,
    limcol = 0,
    solprint = off,
    sysout = off;





Set
*        Define units: Src=source, Snk=sink, Mix=mixer, Spl=splitter
*                      Str=storage, MS1=in use, MS2=in recovery
         unit    units
        /Wash1, Grind1, Premix1, Jet1, Col1, Liq1, Sac1, Fer1, BC1,
         Rec1, Ads1, MS1*MS2, MecP1*MecP2, Flot1*Flot2, Dry1, WWT1,
         HX1*HX12, Cond1, Cond2, Src1*Src9, Snk1*Snk9, Str1*Str2,
         Mix2*Mix7, Spl1*Spl7/

*        Define subsets of units
         HX(unit) heat exchangers
        /HX1*HX12/

         Mix(unit) mixers
        /Mix2*Mix7/

                 Mix_v(Mix) mixers with vapor inlet
                 /Mix4*Mix7/
                 Mix_l(Mix) mixers with liquid inlet
                 /Mix2*Mix3/

         Spl(unit) splitter
         /Spl1*Spl7/

         Src(unit) sources
         /Src1*Src9/

         Snk(unit) sinks
         /Snk1*Snk9/

         Column(Unit) distillation columns
         /BC1,Rec1/

*        Define components
         J       components
         /Wa, Star, Gluc, Malt, Prot, Etho, Glyc, SucA, AceA, LacA, Urea,
         CellM, CO2, O2, Cellu, HCellu, Oil, Ash/

         liquids(J)
         /Wa, Etho, Glyc, AceA, LacA, Oil/

         solids(J)
         /Star, Prot, CellM, Cellu, HCellu, Ash/

         h(J)    water and ethanol
         /Wa, Etho/

*        Define reactions; Star_Malt is reaction starch to maltose etc.
*        Note: star_gluc in Sac1 is neglected
         react
         /Star_Malt, Malt_Gluc, Gluc_Etho, Gluc_Glyc, Gluc_SucA, Gluc_AceA,
         Gluc_LacA, Gluc_CellM/

*        running variable for vapor pressure correlation
         l /1*3/


Alias(unit, unit1)
Alias(h,h1)



*Data

Parameters

*        feedstock composition in mass fractions: corn, #2 yellow dent
         x_0(J)
         /Wa             0.15
          Star           0.6185
          Gluc           0.0162
          Malt           0
          Prot           0.076
          Etho           0
          Glyc           0
          SucA           0
          AceA           0
          LacA           0
          Urea           0
          CellM          0
          CO2            0
          O2             0
          Cellu          0.0274
          HCellu         0.0638
          Oil            0.0354
          Ash            0.0127/

*        composition of adsorbend - corn grits
         x_ads(J)
         /Wa             0
          Star           0.881
          Gluc           0
          Malt           0
          Prot           0.0847
          Etho           0
          Glyc           0
          SucA           0
          AceA           0
          LacA           0
          Urea           0
          CellM          0
          CO2            0
          O2             0
          Cellu          0.0069
          HCellu         0.0161
          Oil            0.0079
          Ash            0.0034/

*        individual liquid heat capacity of a component (average in a range 20 C - 100 C)
*        in kJ/(kg*C), assume: constant heat capacities and c_p_ind('CellM')=c_p_ind('Wa')
         c_p_ind(J)
         /Wa             4.19
          Star           1.64
          Gluc           1.64
          Malt           1.64
          Prot           2.07
          Etho           2.83
          Glyc           1.0477
          SucA           0.6079
          AceA           0.6687
          LacA           0.8706
          Urea           0
          CellM          4.19
          CO2            0
          O2             0
          Cellu          1.94
          HCellu         1.94
          Oil            2.23
          Ash            1.19/


*        standard heat of vaporization: kJ/kg
         dH_vap_0(h)
        /Wa      2254.62
         Etho    840.192/

*        critical temperature: C
         Tc(h)
        /Wa      374.15
         Etho    243.05/

*        boiling point temperature: C
         Tb(h)
        /Wa      100
         Etho    78.35/

*        Molecular weight: g/mol
         MW(h)
        /Wa             18.015
         Etho           46.069/

*        conversion of the individual reactions
         conv(react)
        /Star_Malt      0.99
         Malt_Gluc      0.99
         Gluc_Etho      0.470496
         Gluc_Glyc      0.034762
         Gluc_SucA      0.01319
         Gluc_AceA      0.0024
         Gluc_LacA      0.002
         Gluc_CellM     0.025919/

*        density in kg/l; assume: constant density
         dens(h)
        /Wa     1
         Etho    0.787/

*        individual vapor heat capacity (average in a range 80 C - 100 C)
*        assume: constant heat capacities
         c_p_v(h)
        /Wa      1.89
         Etho    1.67/

Scalar   n_watson        exponent in Watson correlation /0.38/;

Table
*        vapor pressure coefficients: mmHq, T= C
*        750 mmHq = 1bar, 760mmHq = 1atm
*        ln(p_k)= coef_p(h,1)-coef_p(h,2)/(T+coef_p(h,3))
*        Data from Biegler's database
         coef_p(h,l)
                 1        2        3
         Wa      18.3036  3816.44  227.02
         Etho    18.9119  3803.98  231.47
         ;



SET      Arc(unit,unit1) stream matrix;

*setting entries in stream matrix
***Arc is unknown symbol***
Arc(unit, unit1)=No;

*Define all existing streams Arc('1','2') is stream from unit 1 to unit 2

*Washing
Arc('Src1','Wash1')=Yes;
Arc('Src2','Wash1')=Yes;
Arc('Wash1','Grind1')=Yes;

*Grinding
Arc('Grind1','Mix2')=Yes;
Arc('Mix2','HX1')=Yes;
Arc('Src3','Mix2')=Yes;
Arc('Spl6','Mix2')=Yes;

*Cooking
Arc('HX1','Premix1')=Yes;
Arc('Premix1','Jet1')=Yes;
Arc('Src4','Jet1')=Yes;
Arc('Jet1','Col1')=Yes;
Arc('Col1','Liq1')=Yes;
Arc('Src5','Liq1')=Yes;
Arc('Liq1','HX2')=Yes;
Arc('HX2','Sac1')=Yes;
Arc('Src6','Sac1')=Yes;
Arc('Sac1','HX3')=Yes;

*Fermentation
Arc('HX3','Mix3')=Yes;
Arc('Src7','Mix3')=Yes;
Arc('Mix3','Str1')=Yes;
Arc('Fer1','Snk1')=Yes;
Arc('Str2','Spl1')=Yes;
*Note:stream Str1_Fer1, Fer1_Str2 are covered by the fermenter eq. and the don't have to be defined

*Liquid-Solid separation
Arc('Spl1','MecP1')=Yes;
Arc('Spl1','HX4')=Yes;
Arc('MecP1','Flot1')=Yes;
Arc('MecP1','Dry1')=Yes;
Arc('Flot1','HX4')=Yes;
Arc('Flot1','Dry1')=Yes;
Arc('HX4','BC1')=Yes;
Arc('BC1','Spl2')=Yes;
Arc('BC1','Spl3')=Yes;
Arc('Spl3','HX11')=Yes;
Arc('HX11','WWT1')=Yes;
Arc('Spl3','MecP2')=Yes;
Arc('MecP2','Dry1')=Yes;
Arc('MecP2','Flot2')=Yes;
Arc('Flot2','WWT1')=Yes;
Arc('Flot2','Dry1')=Yes;
Arc('WWT1','Snk7')=Yes;
Arc('WWT1','Snk6')=Yes;
Arc('Dry1','Spl7')=Yes;
Arc('Dry1','HX10')=Yes;
Arc('HX10','Snk8')=Yes;
Arc('Spl7','HX4')=Yes;
Arc('Spl7','Snk9')=Yes;

*Ethanol purification
Arc('Spl2','Mix4')=Yes;
Arc('Spl2','Mix5')=Yes;
Arc('Spl2','Mix6')=Yes;
Arc('Mix4','Rec1')=Yes;
Arc('Mix5','Ads1')=Yes;
Arc('Mix6','HX7')=Yes;
Arc('HX7','MS1')=Yes;
Arc('Rec1','Spl4')=Yes;
Arc('Rec1','Snk2')=Yes;
Arc('Ads1','Spl6')=Yes;
Arc('Spl6','Snk3')=Yes;
Arc('Ads1','Spl5')=Yes;
Arc('Src9','HX6')=Yes;
Arc('HX6','Ads1')=Yes;
Arc('MS1','Mix7')=Yes;
Arc('MS1','MS2')=Yes;
Arc('Src8','HX8')=Yes;
Arc('HX8','MS2')=Yes;
Arc('MS2','HX9')=Yes;
Arc('HX9','Snk4')=Yes;
Arc('Spl4','Mix5')=Yes;
Arc('Spl4','Mix6')=Yes;
Arc('Spl4','Mix7')=Yes;
Arc('Spl5','Mix4')=Yes;
Arc('Spl5','Mix6')=Yes;
Arc('Spl5','Mix7')=Yes;
Arc('Mix7','Cond1')=Yes;
Arc('Cond1','HX5')=Yes;
Arc('HX5','Snk5')=Yes;
Arc('Spl7','Cond2')=Yes;
Arc('Cond2','HX4')=Yes;


Positive Variables
*        streams and mass fractions: all in kg/s
         fc(J,unit,unit1)        individual components streams
         x(J,unit,unit1)         mass fraction of comp J in stream

*        heat of evaporation
         dH_v(h,unit,unit1)      individual heat of vap. (KJ per kg)

*        vapor pressure: water and etho
         p_v(h,unit,unit1)       vapor pressure in bar

*        temperatures in C
         T(unit,unit1)          temperature of stream in C

*        power
         W(Unit)                 power consumption of unit in kW (efficiency included)

         m_frac(h,unit,unit1)    mol fraction of water or ethanol
         ;

Variables
*        heat
         Q(Unit)         heat produced or consumed in unit (efficiency included)
         Q_cond(column)  heat load of condenser of column
         Q_reb(column)   heat load of reboiler of column

         Z               objective function value ;

Parameter
*        temperatures in C
         Tmp(unit,unit1)          temperature of stream in C
/Grind1.Mix2 0/;



Tmp('Grind1','Mix2') = 20;
Tmp('Src3','Mix2') = 20;
Tmp('HX1','Premix1') = 60;
Tmp('Premix1','Jet1') = 60;
Tmp('Jet1','Col1') = 120;
Tmp('Col1','Liq1') = 85;
Tmp('Src3','Mix2') = 20;
Tmp('HX1','Premix1') = 60;
Tmp('HX2','Sac1') = 75;
Tmp('Liq1','HX2') = 85;
Tmp('Sac1','HX3') = 75;
Tmp('Src7','Mix3') = 20;
Tmp('Mix3','Str1') = 32;
Tmp('Str2','Spl1') = 32;
Tmp('Spl1','MecP1') = 32;
Tmp('Spl1','HX4') = 32;
Tmp('MecP1','Dry1') = 32;
Tmp('MecP1','Flot1') = 32;
Tmp('Flot1','HX4') = 32;
Tmp('Flot1','Dry1') = 32;
Tmp('HX11','WWT1') = 25;
Tmp('Dry1','HX10') = 100;
Tmp('Dry1','Spl7') = 100;
Tmp('Spl7','Cond2')= 100;
Tmp('Spl7','Snk9') = 100;
Tmp('HX5','Snk5') = 25;
Tmp('HX9','Snk4') = 25;
Tmp('HX10','Snk8') = 25;
Tmp('Src8','HX8') = 20;
Tmp('HX8','MS2') = 95;
Tmp('MS2','HX9') = 95;
Tmp('HX7','MS1') = 95;
Tmp('MS1','MS2') = 95;
Tmp('MS1','Mix7') = 95;
Tmp('Src9','HX6') = 20;
Tmp('HX6','Ads1') = 91;
Tmp('Ads1','Spl6') = 91;
Tmp('Spl6','Mix2') = 91;
Tmp('Spl6','Snk3') = 91;
Tmp('Ads1','Spl5') = 91;
Tmp('Spl5','Mix4')= 91;
Tmp('Spl5','Mix6') = 91;
Tmp('Spl5','Mix7') = 91;

*Define global bounds and fix specific variables

*mass fractions
x.UP(J,unit,unit1)$Arc(unit,unit1)=1;

*Component streams
fc.UP(J,unit,unit1)$Arc(unit,unit1)=220;

fc.up(J,unit,unit1)$(not Arc(unit,unit1)) = 0;


*Specifying heat consumption of certain units
Q.Fx('Wash1')=0;
Q.Fx('Grind1')=0;
Q.Fx('Premix1')=0;
*Q.Fx('Jet1')=0;
Q.Fx('Liq1')=0;
Q.Fx('Sac1')=0;
Q.Fx('MecP1')=0;
Q.Fx('MecP2')=0;
Q.Fx('Flot1')=0;
Q.Fx('Flot2')=0;
Q.Fx('WWT1')=0;
Q.Fx('BC1')=0;
Q.Fx(Mix)=0;
Q.Fx(Spl)=0;
Q.Fx(Src)=0;
Q.Fx(Snk)=0;

*It is assumed that the heat of adsorption is stored in the bed and
*then the bed provides the heat of desorption
Q.Fx('MS1')=0;
Q.Fx('MS2')=0;


*Specify power consumption for cerain units

$ontext
power consumption of all pumps neglected
power consumption for stirring in Premix1, Li1, Sac1, Fer1 neglected
power consumption on dryer and flotation units neglected
$offtext

W.Fx('Wash1')=0;
W.Fx('Premix1')=0;
W.Fx('Jet1')=0;
W.Fx('Liq1')=0;
W.Fx('Sac1')=0;
W.Fx('Fer1')=0;
W.Fx('Flot1')=0;
W.Fx('Flot2')=0;
W.Fx('WWT1')=0;
W.Fx('Dry1')=0;
W.Fx('BC1')=0;
W.Fx('Rec1')=0;
W.Fx('Ads1')=0;
W.Fx('MS1')=0;
W.Fx('Cond1')=0;
W.Fx(Mix)=0;
W.Fx(Spl)=0;
W.Fx(Src)=0;
W.Fx(Snk)=0;
W.Fx(HX)=0;


*Temperature settings

Scalars
*Define temperatures in C
*Data for premix, cook, liq, sac, fer from alcohol textbook (mean values)
         T_amb           ambient temperature /20/
         T_cooldown      cool down temperature /25/
         T_premix        temperature in premixer /60/
         T_cook          temperature in cooker /120/
         T_liq           liquefaction temperature /85/
         T_sac           saccharification temperature /75/
         T_fer           fermentation temperature /32/
         T_MS1           adsorption temperature in MS1 /95/
         T_MS2           desorption temperature in MS2 /95/
         T_Ads           temperature for adsorption on corn grits /91/
         T_dry           drying temperature /100/
         dT_min          EMAT /5/
         T_max           max temperature for a process stream /120/
         T_steam_max     max steam temperature /300/;


*global temperature bounds - bounds get redefined for specific streams
T.LO(unit,unit1)=T_amb;
T.UP(unit,unit1)=300;

*Specifying temperatures
*Pretreatment
T.Fx('Src1','Wash1')=T_amb;
T.Fx('Src2','Wash1')=T_amb;
T.Fx('Wash1','Grind1')=T_amb;
T.Fx('Grind1','Mix2')=T_amb;
T.Fx('Src3','Mix2')=T_amb;
T.Fx('HX1','Premix1')=T_premix;
T.Fx('Premix1','Jet1')=T_premix;
T.Fx('Jet1','Col1')=T_cook;
T.Fx('Col1','Liq1')=T_liq;
T.Fx('Src5','Liq1')=T_liq;
T.Fx('Liq1','HX2')=T_liq;
T.Fx('HX2','Sac1')=T_sac;
T.Fx('Src6','Sac1')=T_sac;
T.Fx('Sac1','HX3')=T_sac;
T.FX('Src7','Mix3')=T_amb;
T.FX('Mix3','Str1')=T_fer;

*Liquid-solid separation
T.Fx('Str2','Spl1')=T_fer;
T.Fx('Spl1','MecP1')=T_fer;
T.Fx('Spl1','HX4')=T_fer;
T.Fx('MecP1','Dry1')=T_fer;
T.Fx('MecP1','Flot1')=T_fer;
T.Fx('Flot1','HX4')=T_fer;
T.Fx('Flot1','Dry1')=T_fer;
T.Fx('HX11','WWT1')=T_cooldown;

*Dryer
T.FX('Dry1','HX10')=T_dry;
T.FX('Dry1','Spl7')=T_dry;
T.FX('Spl7','Snk9')=T_dry;

T.UP('Cond2','HX4')=T_dry;

*Sinks
T.Fx('HX5','Snk5')=T_cooldown;
T.Fx('HX9','Snk4')=T_cooldown;
T.Fx('HX10','Snk8')=T_cooldown;

*Ethanol purification
T.Fx('Src8','HX8')=T_amb;
T.Fx('HX8','MS2')=T_MS2;
T.Fx('MS2','HX9')=T_MS2;
T.Fx('HX7','MS1')=T_MS1;
T.Fx('MS1','MS2')=T_MS1;
T.Fx('MS1','Mix7')=T_MS1;
T.FX('Src9','HX6')=T_amb;
T.FX('HX6','Ads1')=T_ads;
T.FX('Ads1','Spl6')=T_ads;
T.FX('Spl6','Mix2')=T_ads;
T.FX('Spl6','Snk3')=T_ads;
T.FX('Ads1','Spl5')=T_ads;
T.FX('Spl5','Mix4')=T_ads;
T.FX('Spl5','Mix6')=T_ads;
T.FX('Spl5','Mix7')=T_ads;

*bounds for steam temperatures in jet cooker
T.UP('Src4','Jet1')=T_steam_max;
T.LO('Src4','Jet1')=T_cook;
T.L('Src4','Jet1')=(T_cook+T_steam_max)*0.5;

T.Fx('MecP2','Dry1')=T_cooldown;
T.Fx('MecP2','Flot2')=T_cooldown;
T.Fx('Flot2','Dry1')=T_cooldown;
T.Fx('Flot2','WWT1')=T_cooldown;

T.LO('HX3','Mix3') =  25;
T.UP('HX3','Mix3') =  100;
T.L('HX3','Mix3')=50;



$ontext
Here all src streams, which have specified values for a 60MGal/yr
plant, are fixed.
Source 1 can be found in the data.
$offtext


*src2: net consumption of washing water; pure water in src2
fc.Fx('Star','Src2','Wash1')=0;
fc.Fx('Gluc','Src2','Wash1')=0;
fc.Fx('Malt','Src2','Wash1')=0;
fc.Fx('Prot','Src2','Wash1')=0;
fc.Fx('Etho','Src2','Wash1')=0;
fc.Fx('Glyc','Src2','Wash1')=0;
fc.Fx('SucA','Src2','Wash1')=0;
fc.Fx('AceA','Src2','Wash1')=0;
fc.Fx('LacA','Src2','Wash1')=0;
fc.Fx('Urea','Src2','Wash1')=0;
fc.Fx('CellM','Src2','Wash1')=0;
fc.Fx('CO2','Src2','Wash1')=0;
fc.Fx('O2','Src2','Wash1')=0;
fc.Fx('Cellu','Src2','Wash1')=0;
fc.Fx('HCellu','Src2','Wash1')=0;
fc.Fx('Oil','Src2','Wash1')=0;
fc.Fx('Ash','Src2','Wash1')=0;



*Src3 contains only water
fc.UP('Wa','Src3','Mix2')=45;
fc.L('Wa','Src3','Mix2')=fc.UP('Wa','Src3','Mix2');
fc.lo('Wa','Src3','Mix2')= 0;

fc.Fx('Star','Src3','Mix2')=0;
fc.Fx('Gluc','Src3','Mix2')=0;
fc.Fx('Malt','Src3','Mix2')=0;
fc.Fx('Prot','Src3','Mix2')=0;
fc.Fx('Etho','Src3','Mix2')=0;
fc.Fx('Glyc','Src3','Mix2')=0;
fc.Fx('SucA','Src3','Mix2')=0;
fc.Fx('AceA','Src3','Mix2')=0;
fc.Fx('LacA','Src3','Mix2')=0;
fc.Fx('Urea','Src3','Mix2')=0;
fc.Fx('CellM','Src3','Mix2')=0;
fc.Fx('CO2','Src3','Mix2')=0;
fc.Fx('O2','Src3','Mix2')=0;
fc.Fx('Cellu','Src3','Mix2')=0;
fc.Fx('HCellu','Src3','Mix2')=0;
fc.Fx('Oil','Src3','Mix2')=0;
fc.Fx('Ash','Src3','Mix2')=0;


*Src4 contains only steam
*Steam temperature is bounded above
fc.UP('Wa','Src4','Jet1')=70;
fc.LO('Wa','Src4','Jet1')=0.01;
fc.L('Wa','Src4','Jet1')=0;

fc.Fx('Star','Src4','Jet1')=0;
fc.Fx('Gluc','Src4','Jet1')=0;
fc.Fx('Malt','Src4','Jet1')=0;
fc.Fx('Prot','Src4','Jet1')=0;
fc.Fx('Etho','Src4','Jet1')=0;
fc.Fx('Glyc','Src4','Jet1')=0;
fc.Fx('SucA','Src4','Jet1')=0;
fc.Fx('AceA','Src4','Jet1')=0;
fc.Fx('LacA','Src4','Jet1')=0;
fc.Fx('Urea','Src4','Jet1')=0;
fc.Fx('CellM','Src4','Jet1')=0;
fc.Fx('CO2','Src4','Jet1')=0;
fc.Fx('O2','Src4','Jet1')=0;
fc.Fx('Cellu','Src4','Jet1')=0;
fc.Fx('HCellu','Src4','Jet1')=0;
fc.Fx('Oil','Src4','Jet1')=0;
fc.Fx('Ash','Src4','Jet1')=0;


*Src5 contains only enzyme
fc.UP('Prot','Src5','Liq1')=0.5;
fc.LO('Prot','Src5','Liq1')=0.001;
fc.L('Prot','Src5','Liq1')=0.009;

fc.Fx('Wa','Src5','Liq1')=0;
fc.Fx('Star','Src5','Liq1')=0;
fc.Fx('Gluc','Src5','Liq1')=0;
fc.Fx('Malt','Src5','Liq1')=0;
fc.Fx('Etho','Src5','Liq1')=0;
fc.Fx('Glyc','Src5','Liq1')=0;
fc.Fx('SucA','Src5','Liq1')=0;
fc.Fx('AceA','Src5','Liq1')=0;
fc.Fx('LacA','Src5','Liq1')=0;
fc.Fx('Urea','Src5','Liq1')=0;
fc.Fx('CellM','Src5','Liq1')=0;
fc.Fx('CO2','Src5','Liq1')=0;
fc.Fx('O2','Src5','Liq1')=0;
fc.Fx('Cellu','Src5','Liq1')=0;
fc.Fx('HCellu','Src5','Liq1')=0;
fc.Fx('Oil','Src5','Liq1')=0;
fc.Fx('Ash','Src5','Liq1')=0;



*Src6 contains only enzyme
fc.UP('Prot','Src6','Sac1')=13;
fc.LO('Prot','Src6','Sac1')=0.001;
fc.L('Prot','Src6','Sac1')=0.0216;

fc.Fx('Wa','Src6','Sac1')=0;
fc.Fx('Star','Src6','Sac1')=0;
fc.Fx('Gluc','Src6','Sac1')=0;
fc.Fx('Malt','Src6','Sac1')=0;
fc.Fx('Etho','Src6','Sac1')=0;
fc.Fx('Glyc','Src6','Sac1')=0;
fc.Fx('SucA','Src6','Sac1')=0;
fc.Fx('AceA','Src6','Sac1')=0;
fc.Fx('LacA','Src6','Sac1')=0;
fc.Fx('Urea','Src6','Sac1')=0;
fc.Fx('CellM','Src6','Sac1')=0;
fc.Fx('CO2','Src6','Sac1')=0;
fc.Fx('O2','Src6','Sac1')=0;
fc.Fx('Cellu','Src6','Sac1')=0;
fc.Fx('HCellu','Src6','Sac1')=0;
fc.Fx('Oil','Src6','Sac1')=0;
fc.Fx('Ash','Src6','Sac1')=0;



*Src7 contains only water, urea and yeast(cell mass)
fc.Fx('Star','Src7','Mix3')=0;
fc.Fx('Gluc','Src7','Mix3')=0;
fc.Fx('Malt','Src7','Mix3')=0;
fc.Fx('Prot','Src7','Mix3')=0;
fc.Fx('Etho','Src7','Mix3')=0;
fc.Fx('Glyc','Src7','Mix3')=0;
fc.Fx('SucA','Src7','Mix3')=0;
fc.Fx('AceA','Src7','Mix3')=0;
fc.Fx('LacA','Src7','Mix3')=0;
fc.Fx('CO2','Src7','Mix3')=0;
fc.Fx('O2','Src7','Mix3')=0;
fc.Fx('Cellu','Src7','Mix3')=0;
fc.Fx('HCellu','Src7','Mix3')=0;
fc.Fx('Oil','Src7','Mix3')=0;
fc.Fx('Ash','Src7','Mix3')=0;


*Cragill. 0.00027654 kg_yeast/kg_corn * 18 kg_corn/s
*assume: same amount of yeast is needed, if corn grits are used
fc.Fx('CellM','Src7','Mix3')=0.004977;

fc.UP('Wa','Src7','Mix3')=150;
fc.L('Wa','Src7','Mix3')=5;
fc.LO('Wa','Src7','Mix3')=0;

fc.UP('Urea','Src7','Mix3')=15;
fc.LO('Urea','Src7','Mix3')=0.01;
fc.L('Urea','Src7','Mix3')=10;




Equations
         Wash_1, Wash_2, Wash_3

         Grind_1;


****THAT'S NOT GOING TO WORK THIS WAY - FIX ETHO OUTLET LATER****
*For a 60 MGal/yr ethanol plant, about 18 kg_corn/s is needed


*Washing: Wash1
Scalar   frac_wash       fraction of washing water that stays with the corn /0.01/
         min_wash        min amount of washing water (kg per kg corn) /0.5/
         Fcorn           Total amount of corn entering the plant      /18/;
*        min_wash is guessed, frac_wash according to Cargill


*composition of src1 is given, F('Src1','Wash1') total amount of corn proceed
Wash_3.. fc('Wa','Src2','Wash1') =E= min_wash*frac_wash*Fcorn;

Wash_1(J)..
         fc(J,'Src1','Wash1') =E= x_0(J)*Fcorn;

Wash_2(J)..
         fc(J,'Wash1','Grind1') =E= fc(J,'Src1','Wash1') +fc(J,'Src2','Wash1');

Grind_1(J)..
         fc(J,'Grind1','Mix2') =E= fc(J,'Wash1','Grind1');



Equations
         Mix2_1,HX1_1,Mix2_2,HX1_2;



Mix2_1(J)..
         fc(J,'Mix2','HX1') =E= fc(J,'Grind1','Mix2')+fc(J,'Src3','Mix2');



HX1_1(J)..
         fc(J,'HX1','Premix1') =E= fc(J,'Mix2','HX1');

*Outlet temperature of mixer
Mix2_2.. sum(J,fc(J,'Grind1','Mix2')*c_p_ind(J))*(T('Mix2','HX1')-Tmp('Grind1','Mix2'))
         +sum(J,fc(J,'Src3','Mix2')*c_p_ind(J))*(T('Mix2','HX1')-Tmp('Src3','Mix2'))
         =E= 0;


HX1_2..  Q('HX1') =E= sum(J,fc(J,'Mix2','HX1')*c_p_ind(J))*
         (Tmp('HX1','Premix1')-T('Mix2','HX1'));



Equations
         Premix_1

         Jet_Cook_1, Jet_Cook_2, Jet_Cook_3 , Jet_Cook_4

         Col1_1, Col1_2;

Premix_1(J)..
         fc(J,'Premix1','Jet1') =E= fc(J,'HX1','Premix1');

Jet_Cook_1(J)..
         fc(J,'Jet1','Col1') =E= fc(J,'Premix1','Jet1')+fc(J,'Src4','Jet1');

Jet_Cook_2..
         dH_v('Wa','Jet1','Col1') =E= dH_vap_0('Wa')*
         ((Tc('Wa')-Tmp('Jet1','Col1'))/(Tc('Wa')-Tb('Wa')))**n_watson;

Jet_Cook_4..
         Q('Jet1') =E= sum(J,fc(J,'Premix1','Jet1')*c_p_ind(J))*(Tmp('Jet1','Col1')-Tmp('Premix1','Jet1'));

Jet_Cook_3..
         fc('Wa','Src4','Jet1')*(c_p_v('Wa')*(T('Src4','Jet1')-Tmp('Jet1','Col1'))+dH_v('Wa','Jet1','Col1'))
         =E= Q('Jet1');

Col1_1(J)..
         fc(J,'Col1','Liq1') =E= fc(J,'Jet1','Col1');

Col1_2.. Q('Col1') =E= sum(J,fc(J,'Jet1','Col1')*c_p_ind(J))*(Tmp('Col1','Liq1')-Tmp('Jet1','Col1'));

Equations
         Liq_1, Liq_2, Liq_3, Liq_4, Liq_5

         HX2_1, HX2_2;

*Liquefaction
Scalars
         Wa_star_malt    stoch. water requirement for reaction starch to maltose /0.0555/
         Wa_malt_gluc    stoch. water requirement for reaction maltose to glucose /0.0526/
         Wa_abundant     /1.5/
         Enz_Liq         enzyme requirement in liquefaction kg per kg feedstock /0.0005/;

Liq_2..  fc('Prot','Src5','Liq1') =E= Enz_Liq*sum(J,fc(J,'Col1','Liq1'));

Liq_1(J)$((ord(J) ne 1) and (ord(J) ne 2) and (ord(J) ne 4))..
         fc(J,'Liq1','HX2') =E= fc(J,'Col1','Liq1')+fc(J,'Src5','Liq1');

Liq_3..
         fc('Star','Liq1','HX2') =E= (fc('Star','Col1','Liq1')
         +fc('Star','Src5','Liq1'))*(1-conv('Star_Malt'));

Liq_4..  fc('Malt','Liq1','HX2') =E=(1+Wa_star_malt)*conv('star_malt')*(fc('Star','Col1','Liq1')
         +fc('Star','Src5','Liq1'))+fc('Malt','Col1','Liq1')+fc('Malt','Src5','Liq1');

Liq_5..  fc('Wa','Liq1','HX2') =E= fc('Wa','Col1','Liq1')+fc('Wa','Src5','Liq1')
         -Wa_star_malt*conv('Star_Malt')*(fc('Star','Col1','Liq1')+fc('Star','Src5','Liq1'));

HX2_1(J)..
         fc(J,'HX2','Sac1') =E= fc(J,'Liq1','HX2');

HX2_2..  Q('HX2') =E= Sum(J,fc(J,'Liq1','HX2')*c_p_ind(J))*(Tmp('HX2','Sac1')-Tmp('Liq1','HX2'));

Equations
         Sac_1, Sac_2, Sac_3, Sac_4, Sac_5

         HX3_1, HX3_2;


*Saccharification:Sac1
Scalar   Enz_Sac         enzyme requirement in saccarafication kg per kg feedstock /0.0012/;

*for all components J except water, maltose, glucose
Sac_1(J)$((ord(J) ne 1) and (ord(J) ne 3) and (ord(J) ne 4))..
         fc(J,'Sac1','HX3') =E= fc(J,'HX2','Sac1')+fc(J,'Src6','Sac1');

*Amount of enzyme from alcohol textbook: proportional to amount of feedstock
Sac_2..  fc('Prot','Src6','Sac1') =E= Enz_Sac*sum(J,fc(J,'HX2','Sac1'));

Sac_3..  fc('Gluc','Sac1','HX3') =E= fc('Gluc','HX2','Sac1')+fc('Gluc','Src6','Sac1')
         +(1+Wa_malt_gluc)*conv('Malt_Gluc')*(fc('Malt','HX2','Sac1')
         +fc('Malt','Src6','Sac1'));

Sac_4..  fc('Malt','Sac1','HX3') =E= (fc('Malt','HX2','Sac1')
         +fc('Malt','Src6','Sac1'))*(1-conv('Malt_Gluc'));

Sac_5..  fc('Wa','Sac1','HX3') =E= fc('Wa','HX2','Sac1')+fc('Wa','Src6','Sac1')
         -Wa_malt_gluc*conv('Malt_Gluc')*(fc('Malt','HX2','Sac1')
         +fc('Malt','Src6','Sac1'));


*Heat exchanger 3
*T('HX2','Sac1') and T('Liq1','HX2') are fixed

HX3_1(J)..
         fc(J,'HX3','Mix3') =E= fc(J,'Sac1','HX3');



Equations
         Mix3_1,Mix3_2;

fc.fx('CellM','Src7','Mix3')= 0.004977;

Mix3_1(J)..
         fc(J,'Mix3','Str1') =E= fc(J,'HX3','Mix3')+fc(J,'Src7','Mix3');

Mix3_2.. sum(J,fc(J,'HX3','Mix3')*c_p_ind(J))*(Tmp('Mix3','Str1')-T('HX3','Mix3'))+sum(J,fc(J,'Src7','Mix3')*c_p_ind(J))*(Tmp('Mix3','Str1')-Tmp('Src7','Mix3')) =E= 0;

HX3_2..  Q('HX3') =E= Sum(J,fc(J,'Sac1','HX3')*c_p_ind(J))*(T('HX3','Mix3')-Tmp('Sac1','HX3'));


Equations
         Fer_1, Fer_2, Fer_3, Fer_4, Fer_5, Fer_6, Fer_7, Fer_8, Fer_9, Fer_10
         Fer_11, Fer_12, Fer_13, Fer_14, Fer_15, Fer_16, Fer_17, Fer_18
         Fer_19, Fer_21, Fer_22;

*Fermentation: Fer1
Positive Variables
         mc_in(J)        inlet mass of component for one fermenter
         mc_out(J)       outlet mass of component for one fermenter (time dependent)
         conv_t(react)   time dependent conversion of a reaction
         T_cyc           cycle time in h
         ;

Scalar   t_l             lack time in h /4/
         t_f_max         time after which fermentation is complete /26/
         sugar_max       max sugar mass fraction (inlet) /0.21/
         etho_max        max etho mass fraction (outlet) /0.16/
         SucA_max        max succinic a. mass fraction (outlet) /0.0033/
         AceA_max        max acetic a. mass fraction (outlet) /0.00055/
         LacA_max        max lactic a. mass fraction (outelt) /0.0089/
         solid_max       max solid load for fermenter   /0.36/
         t_f             fermentation time in h      /26/;

Fer_1(react)$((ord(react) ne 1) and (ord(react) ne 2))..
         conv_t(react) =E= conv(react)*t_f/t_f_max;

Fer_2..  T_cyc =E= (t_l+t_f);
Fer_3(J)..
         mc_in(J) =E= T_cyc*fc(J,'Mix3','Str1')*3600;



Fer_16.. mc_in('Urea') =E= 0.006955*t_f/t_f_max*mc_in('Gluc');

Fer_4(J)$((Ord(J) ne 1) and (Ord(J) ne 3) and (Ord(J) ne 6) and (Ord(J) ne 7) and
         (Ord(J) ne 8) and (Ord(J) ne 9) and (Ord(J) ne 10) and (Ord(J) ne 11)
         and (Ord(J) ne 12) and (Ord(J) ne 13) and (Ord(J) ne 14))..
         mc_out(J) =E= mc_in(J);
Fer_5..  mc_out('Etho') =E= mc_in('Etho')
         + conv_t('gluc_etho')*mc_in('Gluc');

Fer_6..  mc_out('Glyc') =E= mc_in('Glyc')
         + conv_t('gluc_glyc')*mc_in('Gluc');

Fer_7..  mc_out('SucA') =E= mc_in('SucA')
         + conv_t('gluc_sucA')*mc_in('Gluc');

Fer_8..  mc_out('AceA') =E= mc_in('AceA')
         + conv_t('gluc_aceA')*mc_in('Gluc');

Fer_9..  mc_out('LacA') =E= mc_in('LacA')
         + conv_t('gluc_lacA')*mc_in('Gluc');

Fer_10.. mc_out('CellM') =E= mc_in('CellM')
         + conv_t('gluc_cellM')*mc_in('Gluc');

Fer_11.. mc_out('Gluc') =E= mc_in('Gluc')*(1-t_f/t_f_max) ;

Fer_12.. mc_out('urea') =E= (1.1-t_f/t_f_max)*mc_in('urea');

Fer_13.. mc_out('Wa') =E= mc_in('Wa')
         - 0.00111*t_f/t_f_max*mc_in('Gluc');

Fer_14.. mc_out('CO2') =E= mc_in('CO2')
         +0.449*t_f/t_f_max*mc_in('Gluc');

Fer_15.. mc_out('O2') =E= mc_in('O2')
         +0.00949*t_f/t_f_max*mc_in('Gluc');

*connect mass at end of fermentation to outlet streams
Fer_17(J)$((Ord(J) ne 13) and (Ord(J) ne 14))..
          fc(J,'Str2','Spl1')*T_cyc*3600 =E= mc_out(J);
Fer_21..  fc('CO2','Str2','Spl1')=E= 0;
Fer_22..  fc('O2','Str2','Spl1')=E= 0;

*just Co2 and O2 in stream Fer1 to Snk1
Fer_18.. fc('CO2','Fer1','Snk1')*T_cyc*3600 =E= mc_out('CO2');

Fer_19.. fc('O2','Fer1','Snk1')*T_cyc*3600 =E= mc_out('O2');

fc.FX(J,'Fer1','Snk1')$((Ord(J) ne 13) and (Ord(J) ne 14) )=0;


Equations
         Spl1_1 ;


fc.fx('CO2','Spl1','MecP1')=0.0;
fc.fx('O2','Spl1','MecP1')=0.0;

Spl1_1(J)$((Ord(J) ne 13) and (Ord(J) ne 14 ))..
         fc(J,'Spl1','MecP1') =E= fc(J,'Str2','Spl1');

fc.fx(J,'Spl1','HX4')=0;
fc.fx(J,'Spl3','HX11')=0;

*Mechanical Press
Equations
         MecP_2,MecP_3,MecP_1;

Positive variable
         split_MecP1     split fraction of water in MecP1

Parameter
         factor(J)       solubility in water
         /Wa             1
          Star           0
          Gluc           1
          Malt           1
          Prot           1
          Etho           1
          Glyc           1
          SucA           1
          AceA           1
          LacA           1
          Urea           1
          CellM          0
          CO2            0
          O2             0
          Cellu          0
          HCellu         0
          Oil            0.4
          Ash            0/
         ;

*bounds on split fraction of water
split_MecP1.UP=0.999;
split_MecP1.Lo=0.001;
split_MecP1.L=0.5;


fc.Fx('CO2','MecP1','Flot1')=0;
fc.FX('O2','MecP1','Flot1')=0;
fc.Fx('CO2','MecP1','Dry1')=0;
fc.FX('O2','MecP1','Dry1')=0;


MecP_2(J)$((Ord(J) ne 13) and (Ord(J) ne 14 ))..
         fc(J,'MecP1','Flot1') =E= split_MecP1*factor(J)*fc(J,'Spl1','MecP1');

MecP_3(J)$((Ord(J) ne 13) and (Ord(J) ne 14 ))..
         fc(J,'MecP1','Dry1') =E= (1-split_MecP1*factor(J))*fc(J,'Spl1','MecP1');

MecP_1.. fc('Etho','MecP1','Dry1')+fc('Wa','MecP1','Dry1')+fc('Oil','MecP1','Dry1') =G= 0.4*sum(J, fc(J,'MecP1','Dry1'));


*Flotation
Equations
         Flot_1, Flot_2, Flot_3
         ;

Scalar   rec_prot        recovery of protein in flotation unit /0.95/
         wat_prot        amount of water that stays with 1 kg of protein after flotation /0.01/;
*rec_prot and wat_prot are guessed

Flot_1.. fc('Prot','Flot1','Dry1') =E= rec_prot*fc('Prot','MecP1','Flot1');

Flot_2.. fc('Wa','Flot1','Dry1') =E= wat_prot*rec_prot*fc('Prot','MecP1','Flot1');

Flot_3(J)$((Ord(J) ne 1) and (Ord(J) ne 5 ))..
         fc(J,'Flot1','Dry1') =E= 0;


*Drying
Equations
         Dry_1, Dry_2, Dry_3, Dry_4, Dry_5, Dry_6, Dry_7, Dry_8,Dry_9;

Positive variable
         split_wa_dry    split fraction of water in dryer
         split_etho_dry  split fraction of ethanol in dryer;

Scalar   eff_dry         drying effiency /0.85/
         wa_max          maximum water level in cattle feed /0.1/;
Scalar   alpha           rel. volatility of ethanol based on water /2.239/  ;
fc.up('etho','Dry1','Hx10')= 0.005;

Dry_9.. fc('Wa','Dry1','HX10') =L= wa_max*sum(J,fc(J,'Dry1','HX10'));
*bounds on split fraction for water and ethanol
split_wa_dry.UP=1;

split_etho_dry.UP=1;


Dry_1..  split_etho_dry*(1+(alpha-1)*split_wa_dry) =E= (alpha*split_wa_dry);

Dry_2(J)$((Ord(J) ne 1) and (Ord(J) ne 6))..
         fc(J,'Dry1','HX10') =E= fc(J,'MecP1','Dry1')+fc(J,'Flot1','Dry1');

Dry_3..  fc('Wa','Dry1','Spl7') =E= split_wa_dry*(fc('Wa','MecP1','Dry1')+fc('Wa','Flot1','Dry1'));

Dry_4..  fc('Etho','Dry1','Spl7') =E= split_etho_dry*(fc('Etho','MecP1','Dry1')+fc('Etho','Flot1','Dry1'));

Dry_5..  fc('Wa','Dry1','HX10') =E= (1-split_wa_dry)*(fc('Wa','MecP1','Dry1')+fc('Wa','Flot1','Dry1'));

Dry_6..  fc('Etho','Dry1','HX10') =E= (1-split_etho_dry)*(fc('Etho','MecP1','Dry1')+fc('Etho','Flot1','Dry1'));

Dry_8(h)..
         dH_v(h,'Dry1','Spl7') =E= dH_vap_0(h)*
         ((Tc(h)-Tmp('Dry1','Spl7'))/(Tc(h)-Tb(h)))**n_watson;

Dry_7..  fc('Wa','Dry1','Spl7')*dH_v('Wa','Dry1','Spl7')+ fc('Etho','Dry1','Spl7')*dH_v('Etho','Dry1','Spl7')+ sum(J$((Ord(J) ne 13) and (Ord(J) ne 14)),fc(J,'MecP1','Dry1')*c_p_ind(J))*(Tmp('Dry1','HX10')-Tmp('MecP1','Dry1'))+ sum(J$((Ord(J) ne 13) and (Ord(J) ne 14)),fc(J,'Flot1','Dry1')*c_p_ind(J))*(Tmp('Dry1','HX10')-Tmp('Flot1','Dry1'))=E= Q('Dry1');


*Fix for dryer
fc.Fx('CO2','Dry1','HX10')=0;
fc.Fx('O2','Dry1','HX10')=0;
fc.FX(J,'Dry1','Spl7')$((Ord(J) ne 1) and (Ord(J) ne 6)) = 0;

*HX10
Equations
         HX10_1,ddg;

HX10_1(J)..
         fc(J,'HX10','Snk8') =E= fc(J,'Dry1','HX10');


variables ddgs;
ddg.. ddgs =E= sum(J,fc(J,'HX10','Snk8'));


*Splitter 7
Equations
         Spl7_1,Spl7_3,Spl7_2,Spl7_4;
         ;

variables
split_Spl7_Snk9;

split_Spl7_Snk9.up = 1;

Spl7_3..   fc('Etho','Spl7','Snk9')=L= 0.005;
Spl7_1(J).. fc(J,'Spl7','Snk9')=E= split_Spl7_Snk9*fc(J,'Dry1','Spl7');
Spl7_2(J).. fc(J,'Spl7','Cond2') =E= fc(J,'Dry1','Spl7')-fc(J,'Spl7','Snk9');


Spl7_4(J).. fc(J,'Cond2','HX4')=E= fc(J,'Spl7','Cond2');



* Condenser 2
Scalar
         pcond /760/;

Equations
Cond2_0,Cond2_2,Cond2_1,Cond2_3,Cond2_4,Cond2_5;
*  ;

T.up('Spl7','HX4')=100;
T.lo('Spl7','HX4')=20;
Variable
Temp1,Temp2;
Temp1.lo = 0.00001;
Temp2.lo = 0.00001;
Cond2_0.. Temp1 =E= sum(h1,fc(h1,'Cond2','HX4')) ;
Cond2_2.. Temp2 =E= sum(h1,fc(h1,'Cond2','HX4')/(Temp1*MW(h1)));

Cond2_1(h)..
m_frac(h,'Cond2','HX4')*Temp2 =E= fc(h,'Cond2','HX4')/(Temp1*MW(h));


Cond2_3..  pcond =E= (m_frac('Wa','Cond2','HX4')+alpha*m_frac('Etho','Cond2','HX4'))
         *exp(coef_p('Wa','1')-coef_p('Wa','2')/(coef_p('Wa','3')+T('Cond2','HX4')));

Cond2_4(h)..
         dH_v(h,'Cond2','Hx4') =E= dH_vap_0(h)*
         ((Tc(h)-T('Cond2','HX4'))/(Tc(h)-Tb(h)))**n_watson;

Cond2_5.. -sum(h,fc(h,'Cond2','HX4')*(c_p_v(h)*(Tmp('Dry1','Spl7')-T('Cond2','HX4'))+dH_v(h,'Cond2','HX4'))) =E= Q('Cond2');


*Preliminary Distillation

fc.FX('CO2','Flot1','HX4') = 0;
fc.FX('O2','Flot1','HX4') = 0;

Equations

Flot_4,HX4_1,HX4_2,BC_10;

Flot_4(J)$((Ord(J) ne 13) and (Ord(J) ne 14 ))..
         fc(J,'Flot1','Dry1')+fc(J,'Flot1','HX4') =E= fc(J,'MecP1','Flot1');

HX4_1(J)$((Ord(J) ne 13) and (Ord(J) ne 14 ))..
         fc(J,'HX4','BC1') =E= fc(J,'Flot1','HX4') + fc(J,'Cond2','HX4');

T.UP('HX4','BC1')=110;
T.LO('HX4','BC1')=78.35;
T.l('HX4','BC1')= 90;


m_frac.UP('Wa','HX4','BC1')=0.99;
m_frac.UP('Etho','HX4','BC1')=0.23;
m_frac.LO('Wa','HX4','BC1')=0.2;
m_frac.LO('Etho','HX4','BC1')=0.01;

Equations
BCCC_0,BCCC_1,BCCC_11;
Variable
Temp11,Temp22;
Temp11.lo = 0.00001;
Temp22.lo = 0.00001;
BCCC_0.. Temp11 =E= sum(h1,fc(h1,'HX4','BC1')) ;
BCCC_1.. Temp22 =E= sum(h1,fc(h1,'HX4','BC1')/(Temp11*MW(h1)));

BC_10(h)..
           m_frac(h,'HX4','BC1')*Temp22 =E= fc(h,'HX4','BC1')/(Temp11*MW(h));

BCCC_11..  760 =E= (m_frac('Wa','HX4','BC1')+alpha*m_frac('Etho','HX4','BC1'))*exp(coef_p('Wa','1')-coef_p('Wa','2')/(coef_p('Wa','3')+T('HX4','BC1')));



HX4_2..  Q('HX4') =E= Sum(J,fc(J,'Flot1','HX4')*c_p_ind(J))*(T('HX4','BC1')-Tmp('Flot1','HX4'))
         +Sum(J,fc(J,'Cond2','HX4')*c_p_ind(J))*(T('HX4','BC1')-T('Cond2','HX4'));

*BREAK IN THE PROGRAM

*Equations
*         BC_1, BC_2 ,BC_3, BC_4, BC_5, BC_6, BC_7, BC_8, BC_9,BC_12, BC_13, BC_14, BC_15, BC_16, BC_17, BC_18;
*BC_2 ,BC_3,BC_4;
Positive Variable
         rec_Wa(column)  water recovery in column
         n_theo(column)  theoretical number of trays from Fenske equation
         n_act(column)   actual number of trays
         m_frac_BC(h)    mol fraction of condensed vapor in condenser
         x_BC(h)         mass fraction of condensed vapor in condenser  ;

Scalar
*alpha is calculated at 370K; it is assumed to be constant
*the rel. volatilities of all other components are neglegtable small for a calculations
         p               pressure in both columns in mmHg to be consistent with vapor pressure correlation  /760/
         d_p             pressure drop in column in mmHg /76/
         R_BC            reflux ratio on a MASS basis /2/;

Parameter
         rec_Etho(column) recovery of ethanol in BC1 and Rec1 is fixed
        /BC1     0.996
         Rec1    0.996/;


*bounds for beer column equations
*water recovery
rec_Wa.UP('BC1')=0.999;
rec_Wa.lo('BC1')=0.2;

*update these bounds later, now avoid division by zero in BC_1
*these bounds must be placed before BC_1, so don't move them to Rec1
*rec_Wa.UP('Rec1')=0.2;
*rec_Wa.LO('Rec1')=0.0001;

equations BC_2,BC_3,BC_1_1,BC_1_2,BC_1_3;


*mass balance
*BC_1(J)..

BC_2..   fc('Wa','BC1','Spl2') =E= rec_Wa('BC1')*fc('Wa','HX4','BC1');
BC_3..   fc('Etho','BC1','Spl2') =E= rec_Etho('BC1')*fc('Etho','HX4','BC1');
BC_1_1..   fc('Etho','BC1','Spl3') =E= fc('Etho','HX4','BC1')-fc('Etho','BC1','Spl2');
BC_1_2..   fc('Wa','BC1','Spl3') =E= fc('Wa','HX4','BC1')-fc('Wa','BC1','Spl2');
BC_1_3(J)$((Ord(J) ne 1) and (Ord(J) ne 6 ))..   fc(J,'BC1','Spl3')=E= fc(J,'HX4','BC1')-fc(J,'BC1','Spl2');
fc.fx(J,'BC1','Spl2')$((Ord(J) ne 1) and (Ord(J) ne 6 ))=0;

Equations
BCCC_2,BCCC_3,BC_6,chk3,BC_7,chk6;
Variable
Temp33,Temp44,Tapa,Tamaghna,Tapa1;
Temp33.lo = 0.00001;
Temp44.lo = 0.00001;
BCCC_2.. Temp33 =E= sum(h1,fc(h1,'BC1','Spl2')) ;
chk6.. fc('Etho','BC1','Spl2') =L= 0.73*Temp33;

BCCC_3.. Temp44 =E= sum(h1,fc(h1,'BC1','Spl2')/(Temp33*MW(h1)));
Tapa.L(h) = 0.5;
Q_reb.L('BC1') = 1000;
Tamaghna.L = 500;
Tapa1.L = 70;

Equations
BC_19;

BC_6(h)..
           Tapa(h) =E=fc(h,'BC1','Spl2')/(Temp33*MW(h))/Temp44;


chk3..  Tamaghna =E= (p-d_p/2)*(Tapa('Wa')*alpha+Tapa('Etho')+0.0001);

BC_7..   Tapa1 =E= coef_p('Etho','2')/(coef_p('Etho','1')-log(Tamaghna))-coef_p('Etho','3');





*BC_9(h)..
*           m_frac(h,'BC1','Spl3')*Temp66 =E=(fc(h,'BC1','Spl3')/(Temp55*MW(h)));
*BC_9_1..  (p+d_p/2) =E= (m_frac('Wa','BC1','Spl3')+alpha*m_frac('Etho','BC1','Spl3')*exp(coef_p('Wa','1')-coef_p('Wa','2')/(coef_p('Wa','3')+Tapa1));












BC_19..  Q_reb('BC1') =E= sum(h1,fc(h1,'BC1','Spl2'))*2250.789*3*0.99;







Equations BC_23,BC_24,BC_25,BC_26;
variables Split2Mix4,Split2Mix5,Split2Mix6;
Split2Mix4.LO =0.001;
Split2Mix5.LO =0.001;
Split2Mix6.LO =0.001;
Split2Mix4.UP =1;
Split2Mix5.UP =1;
Split2Mix6.UP =1;



Split2Mix4.L = 0.33;
Split2Mix5.L = 0.33;
Split2Mix6.L=0.3;
*Split2Mix6.UP = 0.9;
BC_24.. Split2Mix4+Split2Mix5+Split2Mix6 =E= 1;
*BC_20..  T('Spl2','Mix4') =E= Tapa1;
*BC_21..  T('Spl2','Mix5') =E= Tapa1;
*BC_22..  T('Spl2','Mix6') =E= Tapa1;
*fc.L(h1,'Spl2','Mix4') = 0.1;
*fc.L(h1,'Spl2','Mix5') = 0.1;
*fc.L(h1,'Spl2','Mix6') = 0.1;
*$ontext
*EQUATIONS BC_27,BC_28;
*x.l('Wa','Spl2','mix6') = 0.1;
*x.up('Wa','Spl2','mix6') = 0.2;
*BC_27(h1).. x(h1,'Spl2','Mix6')* sum(h,fc(h,'Spl2','Mix6')) =E= fc(h1,'Spl2','Mix6');


*$offtext
*BC_28.. fc('Wa','Spl2','Mix6')-0.2*massfrc =g= 0;
*BC_27.. fc('Wa','Spl2','Mix6')  sum(h1,fc(h1,'Spl2','Mix6'));
BC_23(h1).. fc(h1,'Spl2','Mix4') =E=  Split2Mix4*fc(h1,'BC1','Spl2');
BC_25(h1).. fc(h1,'Spl2','Mix5') =E=  Split2Mix5*fc(h1,'BC1','Spl2');
BC_26(h1).. fc(h1,'Spl2','Mix6') =E=  Split2Mix6*fc(h1,'BC1','Spl2');



fc.fx(J,'Spl2','Mix4')$((ord(j)ne 1) and (ord(J) ne 6)) = 0;
fc.fx(J,'Spl2','Mix5')$((ord(j)ne 1) and (ord(J) ne 6)) = 0;
Variable cel(unit,unit1)
variable Heat(unit);

cel.LO('BC1','Spl3') = 95;
cel.UP('BC1','Spl3') = 105;
Heat.L('HX11') = 10;

Equations heat_1,heat_2,Rec1,Rec2,Rec3;
heat_1.. Heat('HX11') =E= sum(J,fc(J,'BC1','Spl3'))*(cel('BC1','Spl3')-25);
heat_2.. Heat('Hx10') =E= sum(J,fc(J,'HX10','Snk8'))*75;

rec_Wa.UP('Rec1')=0.999;
rec_Wa.lo('Rec1')=0.14;

*fc.L(h1,'Rec1','Spl4')=0.01;
*fc.L(h1,'Rec1','Snk2')=0.01;

Rec1..   fc('Wa','Rec1','Spl4') =E= rec_Wa('Rec1')*fc('Wa','Spl2','Mix4');
Rec2..   fc('Etho','Rec1','Spl4') =E= rec_Etho('Rec1')*fc('Etho','Spl2','Mix4');
Rec3(h1)..   fc(h1,'Rec1','Snk2') =E= fc(h1,'Spl2','Mix4')- fc(h1,'Rec1','Spl4');

$ONTEXT
equations Rec1_6,Rec1_7;

m_frac.lo(h,'Rec1','Snk2')= 0.0000001

Rec1_6(h)..
         m_frac(h,'Rec1','Snk2')*sum(h1,fc(h1,'Rec1','Snk2')/MW(h1)) =E= fc(h,'Rec1','Snk2')/MW(h);

Rec1_7.. p+d_p/2 =E= (m_frac('Wa','Rec1','Snk2')+alpha*m_frac('Etho','Rec1','Snk2'))
         *exp(coef_p('Wa','1')-coef_p('Wa','2')/(coef_p('Wa','3')+T('Rec1','Snk2')));

$OFFTEXT






equations heat3;
Heat.L('Rec1') = 10;
heat3.. Heat('rec1') =E= (sum(h1,fc(h1,'rec1','Spl4'))*2-sum(h1,fc(h1,'rec1','Snk2')))*2250;


fc.fx(J,'Spl2','Mix5')$((ord(j)ne 1) and (ord(J) ne 6)) = 0;
fc.fx(J,'Mix5','Ads1')$((ord(J) ne 1) and (ord(J) ne 6)) = 0;
equations mx5;

*fc.l(h1,'mix5','Ads1') = 0.1;
mx5(h1).. fc(h1,'mix5','Ads1')=E=fc(h1,'Spl2','Mix5')+fc(h1,'Rec1','Spl4') ;


VARIABLE GU;
equation BC_28;
*GU.L('Wa','Mix5','Ads1') = 0;
BC_28(h).. GU(h,'Mix5','Ads1')*sum(h1,fc(h1,'Mix5','Ads1')) =E= fc(h,'mix5','Ads1');
GU.UP('Wa','Mix5','Ads1') = 0.23;





*$ONTEXT
cel.LO('Spl4','Mix5') = 75;
cel.UP('Spl4','Mix5') = 100;
cel.L('Spl4','Mix5') = 80;
cel.L('Mix5','Ads1') = 90;
equations gorom;
gorom..
        sum(h,fc(h,'Spl2','Mix5')*c_p_v(h))*(cel('Mix5','Ads1')-Tapa1)
        +sum(h,fc(h,'Rec1','Spl4')*c_p_v(h))*(cel('Mix5','Ads1')-cel('Spl4','Mix5'))
        =E= 0;
*$OFFTEXT
EQUATIONS MX5_1,ads1;

variable rem_w_ads;
scalar ads_potential_Ads1 /0.075/;

rem_w_ads.UP=0.93;
*lower bound is heuristic value
rem_w_ads.LO=0.08;
rem_w_ads.L = 0.3;
variable  FSrc9_HX6,rosh1;
FSrc9_HX6.L = 1;
fc.L(J,'Src9','HX6')=0.001;

mx5_1.. FSrc9_HX6 =E= (1/ads_potential_Ads1)*rem_w_ads*fc('Wa','Mix5','Ads1');

ads1(J).. fc(J,'Src9','HX6') =e= x_ads(J)*FSrc9_HX6;

equations rosh11;
rosh1.lo =0;
rosh1.up = 100;
rosh11.. rosh1 =E= (1- rem_w_ads)*fc('Wa','mix5','Ads1');


equations heat8;
heat.L('HX6')=1;

heat8.. heat('HX6') =e=  sum(J,(fc(J,'Src9','HX6')*c_p_ind(J)))*71;

equations HX7_2;
fc.fx(J,'Spl2','Mix6')$((ord(J) ne 1) and (ord(J) ne 6)) = 0;


equations join,join1;
join.. fc('Wa','HX7','MS1')=E= fc('Wa','sPL2','Mix6')+ rosh1;
join1.. fc('Etho','HX7','MS1')=E= fc('Etho','sPL2','Mix6')+ fc('Etho','mix5','Ads1');


VARIABLE HU;
equation BC_29;

BC_29(h1).. HU(h1,'HX7','MS1')* sum(h,fc(h,'HX7','MS1')) =E= fc(h1,'HX7','MS1');

HU.UP('Wa','HX7','MS1') = 0.20;

*$ONTEXT

cel.lo('Mix6','HX7') = 0;
cel.L('Mix5','Ads1') = 100;

*equations gorom2;
*gorom2..
*        sum(h,fc(h,'Spl2','Mix6')*c_p_v(h))*(cel('Mix6','HX7')-Tapa1)
*        +(fc('Etho','Mix5','Ads1')*c_p_v('Etho')+rosh1*c_p_v('Wa'))*(cel('Mix6','HX7')-cel('Mix5','Ads1'))
*        =E= 0;
*$OFFTEXT
variables tamu1,tamu2,tamu3;
equations gorom2;
tamu1.LO = 1;
tamu2.LO = 0.00000001;
tamu2.L = 1;
tamu3.Up = 200;
tamu3.Lo = 0;
tamu3.L = 1;
equations gorom3;
equations gorom4;
gorom2..  tamu1 =E= (Tapa1*sum(h,fc(h,'Spl2','Mix6')*c_p_v(h))+cel('Mix5','Ads1')*(fc('Etho','Mix5','Ads1')*c_p_v('Etho')+rosh1*c_p_v('Wa')));
gorom3.. tamu2 =G=  (rosh1*c_p_v('Wa')+fc('Etho','Mix5','Ads1')*c_p_v('Etho')+sum(h,fc(h,'Spl2','Mix6')*c_p_v(h)));
gorom4.. tamu3 =E=  tamu1/tamu2;



Heat.L('HX7') = 1;
*$ONTEXT
HX7_2..  Heat('HX7') =E= sum(h,fc(h,'HX7','MS1')*c_p_v(h))*(Tmp('HX7','MS1')-tamu3);

equations MS,MS_12
variable Fair;
MS.. Fair =E= fc('Wa','HX7','MS1')/0.8629;

MS_12..  heat('HX8') =E= Fair*(1+0.0101*c_p_v('Wa'))*75;

*$OFFTEXT
$ONTEXT
HX7_2..  Heat('HX7') =E= sum(h,fc(h,'sPL2','Mix6')*c_p_v(h))*(Tmp('HX7','MS1')-Tapa1);

equations MS,MS_12
variable Fair;
MS.. Fair =E= fc('Wa','Spl2','Mix6')/0.8629;

MS_12..  heat('HX8') =E= Fair*(1+0.0101*c_p_v('Wa'))*75;
$OFFTEXT
*Q_reb.LO('BC1')=60000;
scalar para /100000/;








*equations OVERALLBALANCE;

*OVERALLBALANCE.. sum(J,fc(J,'Src1','Wash1'))+sum(J,fc(J,'Src2','Wash1')) +sum(J,fc(J,'Src3','Mix2')) +sum(J,fc(J,'Src4','Jet1'))+sum(J,fc(J,'Src5','Liq1'))+sum(J,fc(J,'Src6','Sac1'))
*+sum(J,fc(J,'Src7','Mix3')) =e= sum(J,fc(J,'Fer1','Snk1'))+sum(J,fc(J,'Spl7','Snk9'))+sum(J,fc(J,'HX10','Snk8'))+sum(J,fc(J,'HX4','BC1'));







SET i /1*16/;
SET m /1*74/;
ALIAS(i,jj,k);
scalar
eqsf /31104000.0/
CornTranspSF /617153.1/
CornFarmSF /21994971.4/;

variables

energy_objective     the energy objective from the plant
PROTEIN1 to be changed
PROTEIN2
UREA to be changed
F_Src9_HX6 from pplant model
water_objective from plant model
ethanol from plant model
;

equations energy,etho,water,ure,cor;



*PROTEIN1.lo =0.01;
*PROTEIN2.lo =0.01;
*UREA.lo = 0.01;
*water_objective.lo = 0.01;
*ethanol.lo = 0.01;

energy_objective.up = 1000000;
*PROTEIN1.up = 10;
*PROTEIN2.UP =10;
*UREA.up = 10;
*F_Src9_HX6.fx = 0;
*water_objective.up = 10000;
*ethanol.up = 18;
F_Src9_HX6.lo = 0;
F_Src9_HX6.l = 0.01;
ethanol.l=1;

energy..   energy_objective=E= Q('HX4')+Q('Jet1')+Q('Dry1')+Q('HX1')+Q_Reb('BC1')+Heat('HX11')+ Heat('rec1')+Heat('HX6')+Heat('HX7')+Heat('HX8');
water..   water_objective =E= fc('Wa','Src2','Wash1') + fc('Wa','Src3','Mix2') +fc('Wa','Src4','Jet1') + fc('Wa','Src5','Liq1') +fc('Wa','Src6','Sac1') + fc('Wa','Src7','Mix2');
cor..    F_Src9_HX6 =G= FSrc9_HX6;
ure..     UREA=e= fc('Urea','Src7','Mix3');
etho..     ethanol=E=fc('Etho','BC1','Spl2');


parameters
total
eqecondowncut(m)
eqecondowncutusd(m)
eqecondowncut(m)
/74 0/
eqecondowncutusd(m)
/74 0/
;
variables
vcscale(i,jj)
eqeconupstcut(m)
;

equations
eqec1,eqec2,eqec3,eqec4;
*vcscale.fx(vrow,vcol)  =  0;
eqeconupstcut.fx(m)$((Ord(m) ne 1) and (Ord(m) ne 12) and (Ord(m) ne 38)) = 0;
eqec1$(F_Src9_HX6.l >= 4.5).. eqeconupstcut('1') =E=   0.0747996158*(F_Src9_HX6-0.25*18)/0.7;
eqec4$(F_Src9_HX6.l < 4.5).. eqeconupstcut('1') =E=   0.0747996158*(0)/0.7;
eqec2.. eqeconupstcut('12') =E=  5.28344104716297*water_objective/(1000000*0.7);
eqec3.. eqeconupstcut('38') =E= F_Src9_HX6*0.1;


vcscale.fx('1','1') = 21994971.4;
vcscale.fx('2','2') = 21994971.4;
vcscale.fx('3','3') = 21994971.4;
vcscale.fx('4','4') = 21994971.4;
vcscale.fx('5','5') = 21994971.4;
vcscale.fx('6','6') = 21994971.4;
vcscale.fx('7','7') = 21994971.4;
vcscale.fx('8','8') = 617153.1;

equations
eq1,eq2,eq3,eq4,eq5,eq6,eq7,eq8,eeq9,eq9,eq10,eq11,eq12,eq13,eq14,eq15,eq16;

eq1.. vcscale('9','9') =E=  eqsf*0.83352*energy_objective ;
eq2.. vcscale('10','10')=E= eqsf*0.094*energy_objective ;
eq3.. vcscale('11','11')=E= eqsf*0.07248*energy_objective;
eq4.. vcscale('12','12')=E= eqsf*fc('Prot','Src6','Sac1');
*CHANGEEEEEEEEEE
eq5.. vcscale('13','13')=E= eqsf*fc('Prot','Src5','Liq1') ;
*CHAAANNNGGEEEEEE
eq6.. vcscale('14','14')=E= eqsf*0.004977;
*CHANGEEEEEEEEEE
eq7.. vcscale('15','15') =E= eqsf*UREA;
eq8.. vcscale('16','16') =E= eqsf*(39.128650**(-1))*ETHANOL ;
*CHANGEEEEEEEEE

eeq9(i,jj)$(ord(i) ne ord(jj))..  vcscale(i,jj) =E= 0;


parameters

vcdowncut(i,m)
/1.1 0/   ;

variables
vcscalevec(i);


vcscalevec.fx('1') = 21994971.4;
vcscalevec.fx('2') = 21994971.4;
vcscalevec.fx('3') = 21994971.4;
vcscalevec.fx('4') = 21994971.4;
vcscalevec.fx('5') = 21994971.4;
vcscalevec.fx('6') = 21994971.4;
vcscalevec.fx('7')=  21994971.4;
vcscalevec.fx('8') = 617153.1;
eq9 .. vcscalevec('9')=E= eqsf*0.83352*energy_objective;
eq10 .. vcscalevec('10')=E=eqsf*0.094*energy_objective;
eq11 .. vcscalevec('11')=E=eqsf*0.07248*energy_objective;
eq12 .. vcscalevec('12')=E=eqsf*fc('Prot','Src6','Sac1');
*CHANGEEEEEEEEEE
eq13 .. vcscalevec('13')=E=eqsf*fc('Prot','Src5','Liq1');
*CHAAANNNGGEEEEEE
eq14 .. vcscalevec('14')=E=eqsf*0.004977;
*CHANGEEEEEEEEEE
eq15 .. vcscalevec('15') =E=eqsf*UREA;
eq16 .. vcscalevec('16') =E=EqSF*(39.128650**(-1))*ETHANOL ;
*CHANGEEEEEEEEE



alias(m,n);

variable
econmake(m, n);
econmake.FX('1','1') = 2.785490e+004;
econmake.FX('1','2') = 0;
econmake.FX('1','3') = 0;
econmake.FX('1','4') = 0;
econmake.FX('1','5') = 6.352000e+002;
econmake.FX('1','6') = 0;
econmake.FX('1','7') = 0;
econmake.FX('1','8') = 0;
econmake.FX('1','9') = 0;
econmake.FX('1','10') = 0;
econmake.FX('1','11') = 0;
econmake.FX('1','12') = 0;
econmake.FX('1','13') = 0;
econmake.FX('1','14') = 0;
econmake.FX('1','15') = 0;
econmake.FX('1','16') = 0;
econmake.FX('1','17') = 0;
econmake.FX('1','18') = 0;
econmake.FX('1','19') = 0;
econmake.FX('1','20') = 0;
econmake.FX('1','21') = 0;
econmake.FX('1','22') = 0;
econmake.FX('1','23') = 0;
econmake.FX('1','24') = 0;
econmake.FX('1','25') = 0;
econmake.FX('1','26') = 0;
econmake.FX('1','27') = 0;
econmake.FX('1','28') = 0;
econmake.FX('1','29') = 0;
econmake.FX('1','30') = 0;
econmake.FX('1','31') = 0;
econmake.FX('1','32') = 0;
econmake.FX('1','33') = 0;
econmake.FX('1','34') = 0;
econmake.FX('1','35') = 0;
econmake.FX('1','36') = 0;
econmake.FX('1','37') = 0;
econmake.FX('1','38') = 0;
econmake.FX('1','39') = 0;
econmake.FX('1','40') = 0;
econmake.FX('1','41') = 0;
econmake.FX('1','42') = 0;
econmake.FX('1','43') = 0;
econmake.FX('1','44') = 0;
econmake.FX('1','45') = 0;
econmake.FX('1','46') = 0;
econmake.FX('1','47') = 0;
econmake.FX('1','48') = 0;
econmake.FX('1','49') = 0;
econmake.FX('1','50') = 0;
econmake.FX('1','51') = 0;
econmake.FX('1','52') = 0;
econmake.FX('1','53') = 0;
econmake.FX('1','54') = 0;
econmake.FX('1','55') = 0;
econmake.FX('1','56') = 0;
econmake.FX('1','57') = 0;
econmake.FX('1','58') = 0;
econmake.FX('1','59') = 0;
econmake.FX('1','60') = 0;
econmake.FX('1','61') = 0;
econmake.FX('1','62') = 0;
econmake.FX('1','63') = 0;
econmake.FX('1','64') = 0;
econmake.FX('1','65') = 0;
econmake.FX('1','66') = 0;
econmake.FX('1','67') = 3.043000e+002;
econmake.FX('1','68') = 0;
econmake.FX('1','69') = 0;
econmake.FX('1','70') = 0;
econmake.FX('1','71') = 0;
econmake.FX('1','72') = 0;
econmake.FX('1','73') = 0;
econmake.FX('1','74') = 0;
econmake.FX('2','1') = 0;
equation ddgs91,ddgs92;

ddgs91.. econmake('2','2') =E= 8.682940e+004-(ddgs*360*86400*0.075/1000000);

econmake.FX('2','3') = 0;
econmake.FX('2','4') = 0;
econmake.FX('2','5') = 3.407800e+003;
econmake.FX('2','6') = 0;
econmake.FX('2','7') = 0;
econmake.FX('2','8') = 0;
econmake.FX('2','9') = 0;
econmake.FX('2','10') = 0;
econmake.FX('2','11') = 0;
econmake.FX('2','12') = 0;
econmake.FX('2','13') = 0;
econmake.FX('2','14') = 0;
econmake.FX('2','15') = 0;
econmake.FX('2','16') = 0;
econmake.FX('2','17') = 4.240000e+001;
econmake.FX('2','18') = 0;
econmake.FX('2','19') = 0;
econmake.FX('2','20') = 0;
econmake.FX('2','21') = 0;
econmake.FX('2','22') = 0;
econmake.FX('2','23') = 0;
econmake.FX('2','24') = 0;
econmake.FX('2','25') = 0;
econmake.FX('2','26') = 0;
econmake.FX('2','27') = 0;
econmake.FX('2','28') = 0;
econmake.FX('2','29') = 0;
econmake.FX('2','30') = 0;
econmake.FX('2','31') = 0;
econmake.FX('2','32') = 0;
econmake.FX('2','33') = 0;
econmake.FX('2','34') = 0;
econmake.FX('2','35') = 0;
econmake.FX('2','36') = 0;
econmake.FX('2','37') = 0;
econmake.FX('2','38') = 0;
econmake.FX('2','39') = 0;
econmake.FX('2','40') = 0;
econmake.FX('2','41') = 0;
econmake.FX('2','42') = 0;
econmake.FX('2','43') = 0;
econmake.FX('2','44') = 0;
econmake.FX('2','45') = 0;
econmake.FX('2','46') = 0;
econmake.FX('2','47') = 0;
econmake.FX('2','48') = 0;
econmake.FX('2','49') = 0;
econmake.FX('2','50') = 0;
econmake.FX('2','51') = 0;
econmake.FX('2','52') = 0;
econmake.FX('2','53') = 0;
econmake.FX('2','54') = 0;
econmake.FX('2','55') = 0;
econmake.FX('2','56') = 0;
econmake.FX('2','57') = 0;
econmake.FX('2','58') = 0;
econmake.FX('2','59') = 0;
econmake.FX('2','60') = 0;
econmake.FX('2','61') = 0;
econmake.FX('2','62') = 0;
econmake.FX('2','63') = 0;
econmake.FX('2','64') = 0;
econmake.FX('2','65') = 0;
econmake.FX('2','66') = 0;
econmake.FX('2','67') = 4.491000e+002;
econmake.FX('2','68') = 0;
econmake.FX('2','69') = 0;
econmake.FX('2','70') = 0;
econmake.FX('2','71') = 0;
econmake.FX('2','72') = 0;
econmake.FX('2','73') = 0;
econmake.FX('2','74') = 0;
econmake.FX('3','1') = 0;
econmake.FX('3','2') = 0;
econmake.FX('3','3') = 2.072050e+004;
econmake.FX('3','4') = 0;
econmake.FX('3','5') = 1.068000e+002;
econmake.FX('3','6') = 0;
econmake.FX('3','7') = 0;
econmake.FX('3','8') = 0;
econmake.FX('3','9') = 0;
econmake.FX('3','10') = 0;
econmake.FX('3','11') = 0;
econmake.FX('3','12') = 0;
econmake.FX('3','13') = 0;
econmake.FX('3','14') = 0;
econmake.FX('3','15') = 0;
econmake.FX('3','16') = 0;
econmake.FX('3','17') = 0;
econmake.FX('3','18') = 0;
econmake.FX('3','19') = 0;
econmake.FX('3','20') = 0;
econmake.FX('3','21') = 0;
econmake.FX('3','22') = 0;
econmake.FX('3','23') = 0;
econmake.FX('3','24') = 0;
econmake.FX('3','25') = 0;
econmake.FX('3','26') = 0;
econmake.FX('3','27') = 0;
econmake.FX('3','28') = 0;
econmake.FX('3','29') = 0;
econmake.FX('3','30') = 0;
econmake.FX('3','31') = 0;
econmake.FX('3','32') = 0;
econmake.FX('3','33') = 0;
econmake.FX('3','34') = 0;
econmake.FX('3','35') = 0;
econmake.FX('3','36') = 0;
econmake.FX('3','37') = 0;
econmake.FX('3','38') = 0;
econmake.FX('3','39') = 0;
econmake.FX('3','40') = 0;
econmake.FX('3','41') = 0;
econmake.FX('3','42') = 0;
econmake.FX('3','43') = 0;
econmake.FX('3','44') = 0;
econmake.FX('3','45') = 0;
econmake.FX('3','46') = 0;
econmake.FX('3','47') = 0;
econmake.FX('3','48') = 0;
econmake.FX('3','49') = 0;
econmake.FX('3','50') = 0;
econmake.FX('3','51') = 0;
econmake.FX('3','52') = 0;
econmake.FX('3','53') = 0;
econmake.FX('3','54') = 0;
econmake.FX('3','55') = 0;
econmake.FX('3','56') = 0;
econmake.FX('3','57') = 0;
econmake.FX('3','58') = 0;
econmake.FX('3','59') = 0;
econmake.FX('3','60') = 0;
econmake.FX('3','61') = 0;
econmake.FX('3','62') = 0;
econmake.FX('3','63') = 0;
econmake.FX('3','64') = 0;
econmake.FX('3','65') = 0;
econmake.FX('3','66') = 0;
econmake.FX('3','67') = 2.296000e+002;
econmake.FX('3','68') = 0;
econmake.FX('3','69') = 0;
econmake.FX('3','70') = 0;
econmake.FX('3','71') = 0;
econmake.FX('3','72') = 0;
econmake.FX('3','73') = 0;
econmake.FX('3','74') = 0;
econmake.FX('4','1') = 0;
econmake.FX('4','2') = 0;
econmake.FX('4','3') = 0;
econmake.FX('4','4') = 7.890570e+004;
econmake.FX('4','5') = 6.935000e+002;
econmake.FX('4','6') = 0;
econmake.FX('4','7') = 0;
econmake.FX('4','8') = 0;
econmake.FX('4','9') = 0;
econmake.FX('4','10') = 0;
econmake.FX('4','11') = 0;
econmake.FX('4','12') = 0;
econmake.FX('4','13') = 0;
econmake.FX('4','14') = 0;
econmake.FX('4','15') = 0;
econmake.FX('4','16') = 0;
econmake.FX('4','17') = 0;
econmake.FX('4','18') = 0;
econmake.FX('4','19') = 0;
econmake.FX('4','20') = 0;
econmake.FX('4','21') = 0;
econmake.FX('4','22') = 0;
econmake.FX('4','23') = 0;
econmake.FX('4','24') = 0;
econmake.FX('4','25') = 0;
econmake.FX('4','26') = 0;
econmake.FX('4','27') = 0;
econmake.FX('4','28') = 0;
econmake.FX('4','29') = 0;
econmake.FX('4','30') = 0;
econmake.FX('4','31') = 0;
econmake.FX('4','32') = 0;
econmake.FX('4','33') = 0;
econmake.FX('4','34') = 0;
econmake.FX('4','35') = 0;
econmake.FX('4','36') = 0;
econmake.FX('4','37') = 0;
econmake.FX('4','38') = 0;
econmake.FX('4','39') = 0;
econmake.FX('4','40') = 0;
econmake.FX('4','41') = 0;
econmake.FX('4','42') = 0;
econmake.FX('4','43') = 0;
econmake.FX('4','44') = 0;
econmake.FX('4','45') = 0;
econmake.FX('4','46') = 0;
econmake.FX('4','47') = 0;
econmake.FX('4','48') = 0;
econmake.FX('4','49') = 0;
econmake.FX('4','50') = 0;
econmake.FX('4','51') = 0;
econmake.FX('4','52') = 0;
econmake.FX('4','53') = 0;
econmake.FX('4','54') = 0;
econmake.FX('4','55') = 0;
econmake.FX('4','56') = 0;
econmake.FX('4','57') = 0;
econmake.FX('4','58') = 0;
econmake.FX('4','59') = 0;
econmake.FX('4','60') = 0;
econmake.FX('4','61') = 0;
econmake.FX('4','62') = 0;
econmake.FX('4','63') = 0;
econmake.FX('4','64') = 0;
econmake.FX('4','65') = 0;
econmake.FX('4','66') = 0;
econmake.FX('4','67') = 2.603000e+002;
econmake.FX('4','68') = 0;
econmake.FX('4','69') = 0;
econmake.FX('4','70') = 0;
econmake.FX('4','71') = 0;
econmake.FX('4','72') = 0;
econmake.FX('4','73') = 0;
econmake.FX('4','74') = 0;
econmake.FX('5','1') = 0;
econmake.FX('5','2') = 1.890000e+001;
econmake.FX('5','3') = 0;
econmake.FX('5','4') = 0;
econmake.FX('5','5') = 5.072350e+004;
econmake.FX('5','6') = 0;
econmake.FX('5','7') = 0;
econmake.FX('5','8') = 0;
econmake.FX('5','9') = 0;
econmake.FX('5','10') = 0;
econmake.FX('5','11') = 0;
econmake.FX('5','12') = 0;
econmake.FX('5','13') = 0;
econmake.FX('5','14') = 0;
econmake.FX('5','15') = 0;
econmake.FX('5','16') = 0;
econmake.FX('5','17') = 0;
econmake.FX('5','18') = 0;
econmake.FX('5','19') = 0;
econmake.FX('5','20') = 0;
econmake.FX('5','21') = 0;
econmake.FX('5','22') = 0;
econmake.FX('5','23') = 0;
econmake.FX('5','24') = 0;
econmake.FX('5','25') = 0;
econmake.FX('5','26') = 0;
econmake.FX('5','27') = 0;
econmake.FX('5','28') = 0;
econmake.FX('5','29') = 0;
econmake.FX('5','30') = 0;
econmake.FX('5','31') = 0;
econmake.FX('5','32') = 0;
econmake.FX('5','33') = 0;
econmake.FX('5','34') = 0;
econmake.FX('5','35') = 0;
econmake.FX('5','36') = 0;
econmake.FX('5','37') = 0;
econmake.FX('5','38') = 0;
econmake.FX('5','39') = 0;
econmake.FX('5','40') = 0;
econmake.FX('5','41') = 0;
econmake.FX('5','42') = 0;
econmake.FX('5','43') = 0;
econmake.FX('5','44') = 0;
econmake.FX('5','45') = 0;
econmake.FX('5','46') = 0;
econmake.FX('5','47') = 0;
econmake.FX('5','48') = 0;
econmake.FX('5','49') = 0;
econmake.FX('5','50') = 0;
econmake.FX('5','51') = 0;
econmake.FX('5','52') = 0;
econmake.FX('5','53') = 0;
econmake.FX('5','54') = 0;
econmake.FX('5','55') = 0;
econmake.FX('5','56') = 0;
econmake.FX('5','57') = 0;
econmake.FX('5','58') = 0;
econmake.FX('5','59') = 0;
econmake.FX('5','60') = 0;
econmake.FX('5','61') = 0;
econmake.FX('5','62') = 0;
econmake.FX('5','63') = 0;
econmake.FX('5','64') = 0;
econmake.FX('5','65') = 0;
econmake.FX('5','66') = 0;
econmake.FX('5','67') = 0;
econmake.FX('5','68') = 0;
econmake.FX('5','69') = 0;
econmake.FX('5','70') = 0;
econmake.FX('5','71') = 0;
econmake.FX('5','72') = 0;
econmake.FX('5','73') = 0;
econmake.FX('5','74') = 0;
econmake.FX('6','1') = 0;
econmake.FX('6','2') = 0;
econmake.FX('6','3') = 0;
econmake.FX('6','4') = 0;
econmake.FX('6','5') = 0;
econmake.FX('6','6') = 8.915660e+004;
econmake.FX('6','7') = 0;
econmake.FX('6','8') = 8.712000e+002;
econmake.FX('6','9') = 5.637000e+002;
econmake.FX('6','10') = 0;
econmake.FX('6','11') = 0;
econmake.FX('6','12') = 0;
econmake.FX('6','13') = 0;
econmake.FX('6','14') = 0;
econmake.FX('6','15') = 0;
econmake.FX('6','16') = 0;
econmake.FX('6','17') = 0;
econmake.FX('6','18') = 0;
econmake.FX('6','19') = 0;
econmake.FX('6','20') = 1.271310e+004;
econmake.FX('6','21') = 2.930000e+001;
econmake.FX('6','22') = 2.644000e+002;
econmake.FX('6','23') = 0;
econmake.FX('6','24') = 4.857000e+002;
econmake.FX('6','25') = 0;
econmake.FX('6','26') = 0;
econmake.FX('6','27') = 0;
econmake.FX('6','28') = 0;
econmake.FX('6','29') = 0;
econmake.FX('6','30') = 0;
econmake.FX('6','31') = 0;
econmake.FX('6','32') = 0;
econmake.FX('6','33') = 0;
econmake.FX('6','34') = 0;
econmake.FX('6','35') = 0;
econmake.FX('6','36') = 0;
econmake.FX('6','37') = 0;
econmake.FX('6','38') = 0;
econmake.FX('6','39') = 0;
econmake.FX('6','40') = 0;
econmake.FX('6','41') = 0;
econmake.FX('6','42') = 0;
econmake.FX('6','43') = 0;
econmake.FX('6','44') = 0;
econmake.FX('6','45') = 0;
econmake.FX('6','46') = 0;
econmake.FX('6','47') = 0;
econmake.FX('6','48') = 0;
econmake.FX('6','49') = 0;
econmake.FX('6','50') = 0;
econmake.FX('6','51') = 0;
econmake.FX('6','52') = 0;
econmake.FX('6','53') = 0;
econmake.FX('6','54') = 0;
econmake.FX('6','55') = 0;
econmake.FX('6','56') = 0;
econmake.FX('6','57') = 0;
econmake.FX('6','58') = 0;
econmake.FX('6','59') = 0;
econmake.FX('6','60') = 0;
econmake.FX('6','61') = 0;
econmake.FX('6','62') = 0;
econmake.FX('6','63') = 0;
econmake.FX('6','64') = 0;
econmake.FX('6','65') = 0;
econmake.FX('6','66') = 0;
econmake.FX('6','67') = 0;
econmake.FX('6','68') = 0;
econmake.FX('6','69') = 0;
econmake.FX('6','70') = 0;
econmake.FX('6','71') = 0;
econmake.FX('6','72') = 0;
econmake.FX('6','73') = 0;
econmake.FX('6','74') = 0;
econmake.FX('7','1') = 0;
econmake.FX('7','2') = 0;
econmake.FX('7','3') = 0;
econmake.FX('7','4') = 0;
econmake.FX('7','5') = 0;
econmake.FX('7','6') = 5.400000e+000;
econmake.FX('7','7') = 2.037180e+004;
econmake.FX('7','8') = 0;
econmake.FX('7','9') = 1.230000e+001;
econmake.FX('7','10') = 0;
econmake.FX('7','11') = 0;
econmake.FX('7','12') = 0;
econmake.FX('7','13') = 0;
econmake.FX('7','14') = 0;
econmake.FX('7','15') = 0;
econmake.FX('7','16') = 0;
econmake.FX('7','17') = 0;
econmake.FX('7','18') = 0;
econmake.FX('7','19') = 0;
econmake.FX('7','20') = 0;
econmake.FX('7','21') = 0;
econmake.FX('7','22') = 0;
econmake.FX('7','23') = 0;
econmake.FX('7','24') = 0;
econmake.FX('7','25') = 0;
econmake.FX('7','26') = 0;
econmake.FX('7','27') = 0;
econmake.FX('7','28') = 0;
econmake.FX('7','29') = 0;
econmake.FX('7','30') = 0;
econmake.FX('7','31') = 0;
econmake.FX('7','32') = 0;
econmake.FX('7','33') = 0;
econmake.FX('7','34') = 0;
econmake.FX('7','35') = 0;
econmake.FX('7','36') = 0;
econmake.FX('7','37') = 0;
econmake.FX('7','38') = 0;
econmake.FX('7','39') = 0;
econmake.FX('7','40') = 0;
econmake.FX('7','41') = 0;
econmake.FX('7','42') = 0;
econmake.FX('7','43') = 0;
econmake.FX('7','44') = 0;
econmake.FX('7','45') = 0;
econmake.FX('7','46') = 0;
econmake.FX('7','47') = 0;
econmake.FX('7','48') = 0;
econmake.FX('7','49') = 0;
econmake.FX('7','50') = 0;
econmake.FX('7','51') = 0;
econmake.FX('7','52') = 0;
econmake.FX('7','53') = 0;
econmake.FX('7','54') = 0;
econmake.FX('7','55') = 0;
econmake.FX('7','56') = 0;
econmake.FX('7','57') = 0;
econmake.FX('7','58') = 0;
econmake.FX('7','59') = 0;
econmake.FX('7','60') = 0;
econmake.FX('7','61') = 0;
econmake.FX('7','62') = 0;
econmake.FX('7','63') = 0;
econmake.FX('7','64') = 0;
econmake.FX('7','65') = 0;
econmake.FX('7','66') = 0;
econmake.FX('7','67') = 0;
econmake.FX('7','68') = 0;
econmake.FX('7','69') = 0;
econmake.FX('7','70') = 0;
econmake.FX('7','71') = 0;
econmake.FX('7','72') = 0;
econmake.FX('7','73') = 0;
econmake.FX('7','74') = 0;
econmake.FX('8','1') = 0;
econmake.FX('8','2') = 0;
econmake.FX('8','3') = 0;
econmake.FX('8','4') = 0;
econmake.FX('8','5') = 0;
econmake.FX('8','6') = 7.500000e+000;
econmake.FX('8','7') = 0;
econmake.FX('8','8') = 3.765780e+004;
econmake.FX('8','9') = 2.046000e+002;
econmake.FX('8','10') = 0;
econmake.FX('8','11') = 0;
econmake.FX('8','12') = 0;
econmake.FX('8','13') = 0;
econmake.FX('8','14') = 0;
econmake.FX('8','15') = 0;
econmake.FX('8','16') = 0;
econmake.FX('8','17') = 0;
econmake.FX('8','18') = 0;
econmake.FX('8','19') = 0;
econmake.FX('8','20') = 2.375000e+002;
econmake.FX('8','21') = 0;
econmake.FX('8','22') = 0;
econmake.FX('8','23') = 0;
econmake.FX('8','24') = 1.115500e+003;
econmake.FX('8','25') = 0;
econmake.FX('8','26') = 3.386000e+002;
econmake.FX('8','27') = 0;
econmake.FX('8','28') = 0;
econmake.FX('8','29') = 0;
econmake.FX('8','30') = 0;
econmake.FX('8','31') = 0;
econmake.FX('8','32') = 0;
econmake.FX('8','33') = 0;
econmake.FX('8','34') = 0;
econmake.FX('8','35') = 0;
econmake.FX('8','36') = 0;
econmake.FX('8','37') = 0;
econmake.FX('8','38') = 0;
econmake.FX('8','39') = 0;
econmake.FX('8','40') = 0;
econmake.FX('8','41') = 0;
econmake.FX('8','42') = 0;
econmake.FX('8','43') = 0;
econmake.FX('8','44') = 0;
econmake.FX('8','45') = 0;
econmake.FX('8','46') = 0;
econmake.FX('8','47') = 0;
econmake.FX('8','48') = 0;
econmake.FX('8','49') = 0;
econmake.FX('8','50') = 0;
econmake.FX('8','51') = 0;
econmake.FX('8','52') = 0;
econmake.FX('8','53') = 0;
econmake.FX('8','54') = 0;
econmake.FX('8','55') = 0;
econmake.FX('8','56') = 0;
econmake.FX('8','57') = 0;
econmake.FX('8','58') = 0;
econmake.FX('8','59') = 0;
econmake.FX('8','60') = 0;
econmake.FX('8','61') = 0;
econmake.FX('8','62') = 0;
econmake.FX('8','63') = 0;
econmake.FX('8','64') = 0;
econmake.FX('8','65') = 0;
econmake.FX('8','66') = 0;
econmake.FX('8','67') = 0;
econmake.FX('8','68') = 0;
econmake.FX('8','69') = 0;
econmake.FX('8','70') = 0;
econmake.FX('8','71') = 0;
econmake.FX('8','72') = 0;
econmake.FX('8','73') = 0;
econmake.FX('8','74') = 0;
econmake.FX('9','1') = 0;
econmake.FX('9','2') = 0;
econmake.FX('9','3') = 0;
econmake.FX('9','4') = 0;
econmake.FX('9','5') = 0;
econmake.FX('9','6') = 2.580000e+001;
econmake.FX('9','7') = 0;
econmake.FX('9','8') = 8.141000e+002;
econmake.FX('9','9') = 1.949720e+004;
econmake.FX('9','10') = 0;
econmake.FX('9','11') = 0;
econmake.FX('9','12') = 0;
econmake.FX('9','13') = 0;
econmake.FX('9','14') = 0;
econmake.FX('9','15') = 0;
econmake.FX('9','16') = 0;
econmake.FX('9','17') = 0;
econmake.FX('9','18') = 0;
econmake.FX('9','19') = 0;
econmake.FX('9','20') = 0;
econmake.FX('9','21') = 0;
econmake.FX('9','22') = 0;
econmake.FX('9','23') = 0;
econmake.FX('9','24') = 0;
econmake.FX('9','25') = 0;
econmake.FX('9','26') = 0;
econmake.FX('9','27') = 0;
econmake.FX('9','28') = 1.834000e+002;
econmake.FX('9','29') = 0;
econmake.FX('9','30') = 0;
econmake.FX('9','31') = 0;
econmake.FX('9','32') = 0;
econmake.FX('9','33') = 0;
econmake.FX('9','34') = 0;
econmake.FX('9','35') = 0;
econmake.FX('9','36') = 0;
econmake.FX('9','37') = 0;
econmake.FX('9','38') = 0;
econmake.FX('9','39') = 0;
econmake.FX('9','40') = 0;
econmake.FX('9','41') = 0;
econmake.FX('9','42') = 0;
econmake.FX('9','43') = 0;
econmake.FX('9','44') = 0;
econmake.FX('9','45') = 0;
econmake.FX('9','46') = 0;
econmake.FX('9','47') = 0;
econmake.FX('9','48') = 0;
econmake.FX('9','49') = 0;
econmake.FX('9','50') = 0;
econmake.FX('9','51') = 0;
econmake.FX('9','52') = 0;
econmake.FX('9','53') = 0;
econmake.FX('9','54') = 0;
econmake.FX('9','55') = 0;
econmake.FX('9','56') = 0;
econmake.FX('9','57') = 0;
econmake.FX('9','58') = 0;
econmake.FX('9','59') = 0;
econmake.FX('9','60') = 0;
econmake.FX('9','61') = 0;
econmake.FX('9','62') = 0;
econmake.FX('9','63') = 0;
econmake.FX('9','64') = 0;
econmake.FX('9','65') = 0;
econmake.FX('9','66') = 0;
econmake.FX('9','67') = 0;
econmake.FX('9','68') = 0;
econmake.FX('9','69') = 0;
econmake.FX('9','70') = 0;
econmake.FX('9','71') = 0;
econmake.FX('9','72') = 0;
econmake.FX('9','73') = 0;
econmake.FX('9','74') = 0;
econmake.FX('10','1') = 0;
econmake.FX('10','2') = 0;
econmake.FX('10','3') = 0;
econmake.FX('10','4') = 0;
econmake.FX('10','5') = 0;
econmake.FX('10','6') = 0;
econmake.FX('10','7') = 0;
econmake.FX('10','8') = 0;
econmake.FX('10','9') = 0;
econmake.FX('10','10') = 2.142071e+005;
econmake.FX('10','11') = 8.607600e+003;
econmake.FX('10','12') = 2107;
econmake.FX('10','13') = 0;
econmake.FX('10','14') = 0;
econmake.FX('10','15') = 0;
econmake.FX('10','16') = 0;
econmake.FX('10','17') = 0;
econmake.FX('10','18') = 0;
econmake.FX('10','19') = 0;
econmake.FX('10','20') = 0;
econmake.FX('10','21') = 0;
econmake.FX('10','22') = 0;
econmake.FX('10','23') = 0;
econmake.FX('10','24') = 0;
econmake.FX('10','25') = 0;
econmake.FX('10','26') = 0;
econmake.FX('10','27') = 0;
econmake.FX('10','28') = 0;
econmake.FX('10','29') = 0;
econmake.FX('10','30') = 0;
econmake.FX('10','31') = 0;
econmake.FX('10','32') = 0;
econmake.FX('10','33') = 0;
econmake.FX('10','34') = 0;
econmake.FX('10','35') = 0;
econmake.FX('10','36') = 0;
econmake.FX('10','37') = 0;
econmake.FX('10','38') = 0;
econmake.FX('10','39') = 0;
econmake.FX('10','40') = 0;
econmake.FX('10','41') = 0;
econmake.FX('10','42') = 0;
econmake.FX('10','43') = 0;
econmake.FX('10','44') = 0;
econmake.FX('10','45') = 0;
econmake.FX('10','46') = 0;
econmake.FX('10','47') = 0;
econmake.FX('10','48') = 0;
econmake.FX('10','49') = 0;
econmake.FX('10','50') = 0;
econmake.FX('10','51') = 0;
econmake.FX('10','52') = 0;
econmake.FX('10','53') = 0;
econmake.FX('10','54') = 0;
econmake.FX('10','55') = 0;
econmake.FX('10','56') = 0;
econmake.FX('10','57') = 0;
econmake.FX('10','58') = 0;
econmake.FX('10','59') = 0;
econmake.FX('10','60') = 0;
econmake.FX('10','61') = 0;
econmake.FX('10','62') = 0;
econmake.FX('10','63') = 0;
econmake.FX('10','64') = 0;
econmake.FX('10','65') = 0;
econmake.FX('10','66') = 0;
econmake.FX('10','67') = 0;
econmake.FX('10','68') = 0;
econmake.FX('10','69') = 0;
econmake.FX('10','70') = 0;
econmake.FX('10','71') = 0;
econmake.FX('10','72') = 0;
econmake.FX('10','73') = 0;
econmake.FX('10','74') = 1.270000e+001;
econmake.FX('11','1') = 0;
econmake.FX('11','2') = 0;
econmake.FX('11','3') = 0;
econmake.FX('11','4') = 0;
econmake.FX('11','5') = 0;
econmake.FX('11','6') = 2.630000e+001;
econmake.FX('11','7') = 0;
econmake.FX('11','8') = 0;
econmake.FX('11','9') = 0;
econmake.FX('11','10') = 4.285300e+003;
econmake.FX('11','11') = 7.894440e+004;
econmake.FX('11','12') = 0;
econmake.FX('11','13') = 0;
econmake.FX('11','14') = 0;
econmake.FX('11','15') = 0;
econmake.FX('11','16') = 0;
econmake.FX('11','17') = 0;
econmake.FX('11','18') = 0;
econmake.FX('11','19') = 0;
econmake.FX('11','20') = 0;
econmake.FX('11','21') = 0;
econmake.FX('11','22') = 0;
econmake.FX('11','23') = 0;
econmake.FX('11','24') = 0;
econmake.FX('11','25') = 0;
econmake.FX('11','26') = 0;
econmake.FX('11','27') = 0;
econmake.FX('11','28') = 0;
econmake.FX('11','29') = 0;
econmake.FX('11','30') = 0;
econmake.FX('11','31') = 0;
econmake.FX('11','32') = 0;
econmake.FX('11','33') = 0;
econmake.FX('11','34') = 0;
econmake.FX('11','35') = 0;
econmake.FX('11','36') = 0;
econmake.FX('11','37') = 0;
econmake.FX('11','38') = 0;
econmake.FX('11','39') = 0;
econmake.FX('11','40') = 0;
econmake.FX('11','41') = 0;
econmake.FX('11','42') = 0;
econmake.FX('11','43') = 0;
econmake.FX('11','44') = 0;
econmake.FX('11','45') = 0;
econmake.FX('11','46') = 0;
econmake.FX('11','47') = 0;
econmake.FX('11','48') = 0;
econmake.FX('11','49') = 0;
econmake.FX('11','50') = 0;
econmake.FX('11','51') = 0;
econmake.FX('11','52') = 0;
econmake.FX('11','53') = 0;
econmake.FX('11','54') = 0;
econmake.FX('11','55') = 0;
econmake.FX('11','56') = 0;
econmake.FX('11','57') = 0;
econmake.FX('11','58') = 0;
econmake.FX('11','59') = 0;
econmake.FX('11','60') = 0;
econmake.FX('11','61') = 0;
econmake.FX('11','62') = 0;
econmake.FX('11','63') = 0;
econmake.FX('11','64') = 0;
econmake.FX('11','65') = 0;
econmake.FX('11','66') = 0;
econmake.FX('11','67') = 0;
econmake.FX('11','68') = 0;
econmake.FX('11','69') = 0;
econmake.FX('11','70') = 0;
econmake.FX('11','71') = 0;
econmake.FX('11','72') = 0;
econmake.FX('11','73') = 0;
econmake.FX('11','74') = 0;
econmake.FX('12','1') = 0;
econmake.FX('12','2') = 0;
econmake.FX('12','3') = 0;
econmake.FX('12','4') = 0;
econmake.FX('12','5') = 0;
econmake.FX('12','6') = 0;
econmake.FX('12','7') = 0;
econmake.FX('12','8') = 0;
econmake.FX('12','9') = 0;
econmake.FX('12','10') = 0;
econmake.FX('12','11') = 0;
econmake.FX('12','12') = 6.570800e+003;
econmake.FX('12','13') = 0;
econmake.FX('12','14') = 0;
econmake.FX('12','15') = 0;
econmake.FX('12','16') = 0;
econmake.FX('12','17') = 0;
econmake.FX('12','18') = 0;
econmake.FX('12','19') = 0;
econmake.FX('12','20') = 0;
econmake.FX('12','21') = 0;
econmake.FX('12','22') = 0;
econmake.FX('12','23') = 0;
econmake.FX('12','24') = 0;
econmake.FX('12','25') = 0;
econmake.FX('12','26') = 0;
econmake.FX('12','27') = 0;
econmake.FX('12','28') = 0;
econmake.FX('12','29') = 0;
econmake.FX('12','30') = 0;
econmake.FX('12','31') = 0;
econmake.FX('12','32') = 0;
econmake.FX('12','33') = 0;
econmake.FX('12','34') = 0;
econmake.FX('12','35') = 0;
econmake.FX('12','36') = 0;
econmake.FX('12','37') = 0;
econmake.FX('12','38') = 0;
econmake.FX('12','39') = 0;
econmake.FX('12','40') = 0;
econmake.FX('12','41') = 0;
econmake.FX('12','42') = 0;
econmake.FX('12','43') = 0;
econmake.FX('12','44') = 0;
econmake.FX('12','45') = 0;
econmake.FX('12','46') = 0;
econmake.FX('12','47') = 0;
econmake.FX('12','48') = 0;
econmake.FX('12','49') = 0;
econmake.FX('12','50') = 0;
econmake.FX('12','51') = 0;
econmake.FX('12','52') = 0;
econmake.FX('12','53') = 0;
econmake.FX('12','54') = 0;
econmake.FX('12','55') = 0;
econmake.FX('12','56') = 0;
econmake.FX('12','57') = 0;
econmake.FX('12','58') = 0;
econmake.FX('12','59') = 0;
econmake.FX('12','60') = 0;
econmake.FX('12','61') = 0;
econmake.FX('12','62') = 0;
econmake.FX('12','63') = 0;
econmake.FX('12','64') = 0;
econmake.FX('12','65') = 0;
econmake.FX('12','66') = 0;
econmake.FX('12','67') = 0;
econmake.FX('12','68') = 0;
econmake.FX('12','69') = 0;
econmake.FX('12','70') = 0;
econmake.FX('12','71') = 0;
econmake.FX('12','72') = 0;
econmake.FX('12','73') = 0;
econmake.FX('12','74') = 9.482000e+002;
econmake.FX('13','1') = 0;
econmake.FX('13','2') = 0;
econmake.FX('13','3') = 0;
econmake.FX('13','4') = 0;
econmake.FX('13','5') = 0;
econmake.FX('13','6') = 0;
econmake.FX('13','7') = 0;
econmake.FX('13','8') = 0;
econmake.FX('13','9') = 0;
econmake.FX('13','10') = 0;
econmake.FX('13','11') = 0;
econmake.FX('13','12') = 0;
econmake.FX('13','13') = 1.032363e+006;
econmake.FX('13','14') = 0;
econmake.FX('13','15') = 0;
econmake.FX('13','16') = 0;
econmake.FX('13','17') = 0;
econmake.FX('13','18') = 0;
econmake.FX('13','19') = 0;
econmake.FX('13','20') = 0;
econmake.FX('13','21') = 0;
econmake.FX('13','22') = 0;
econmake.FX('13','23') = 0;
econmake.FX('13','24') = 0;
econmake.FX('13','25') = 0;
econmake.FX('13','26') = 0;
econmake.FX('13','27') = 0;
econmake.FX('13','28') = 0;
econmake.FX('13','29') = 0;
econmake.FX('13','30') = 0;
econmake.FX('13','31') = 0;
econmake.FX('13','32') = 0;
econmake.FX('13','33') = 0;
econmake.FX('13','34') = 0;
econmake.FX('13','35') = 0;
econmake.FX('13','36') = 0;
econmake.FX('13','37') = 0;
econmake.FX('13','38') = 0;
econmake.FX('13','39') = 0;
econmake.FX('13','40') = 0;
econmake.FX('13','41') = 0;
econmake.FX('13','42') = 0;
econmake.FX('13','43') = 0;
econmake.FX('13','44') = 0;
econmake.FX('13','45') = 0;
econmake.FX('13','46') = 0;
econmake.FX('13','47') = 0;
econmake.FX('13','48') = 0;
econmake.FX('13','49') = 0;
econmake.FX('13','50') = 0;
econmake.FX('13','51') = 0;
econmake.FX('13','52') = 0;
econmake.FX('13','53') = 0;
econmake.FX('13','54') = 0;
econmake.FX('13','55') = 0;
econmake.FX('13','56') = 0;
econmake.FX('13','57') = 0;
econmake.FX('13','58') = 0;
econmake.FX('13','59') = 0;
econmake.FX('13','60') = 0;
econmake.FX('13','61') = 0;
econmake.FX('13','62') = 0;
econmake.FX('13','63') = 0;
econmake.FX('13','64') = 0;
econmake.FX('13','65') = 0;
econmake.FX('13','66') = 0;
econmake.FX('13','67') = 0;
econmake.FX('13','68') = 0;
econmake.FX('13','69') = 0;
econmake.FX('13','70') = 0;
econmake.FX('13','71') = 0;
econmake.FX('13','72') = 0;
econmake.FX('13','73') = 0;
econmake.FX('13','74') = 0;
econmake.FX('14','1') = 0;
econmake.FX('14','2') = 0;
econmake.FX('14','3') = 0;
econmake.FX('14','4') = 0;
econmake.FX('14','5') = 0;
econmake.FX('14','6') = 0;
econmake.FX('14','7') = 0;
econmake.FX('14','8') = 0;
econmake.FX('14','9') = 0;
econmake.FX('14','10') = 0;
econmake.FX('14','11') = 0;
econmake.FX('14','12') = 0;
econmake.FX('14','13') = 0;
econmake.FX('14','14') = 5.679509e+005;
econmake.FX('14','15') = 2.160000e+001;
econmake.FX('14','16') = 0;
econmake.FX('14','17') = 0;
econmake.FX('14','18') = 11;
econmake.FX('14','19') = 0;
econmake.FX('14','20') = 0;
econmake.FX('14','21') = 2225;
econmake.FX('14','22') = 0;
econmake.FX('14','23') = 0;
econmake.FX('14','24') = 7.915000e+002;
econmake.FX('14','25') = 2.730000e+001;
econmake.FX('14','26') = 0;
econmake.FX('14','27') = 0;
econmake.FX('14','28') = 0;
econmake.FX('14','29') = 0;
econmake.FX('14','30') = 0;
econmake.FX('14','31') = 0;
econmake.FX('14','32') = 0;
econmake.FX('14','33') = 0;
econmake.FX('14','34') = 0;
econmake.FX('14','35') = 0;
econmake.FX('14','36') = 0;
econmake.FX('14','37') = 0;
econmake.FX('14','38') = 0;
econmake.FX('14','39') = 0;
econmake.FX('14','40') = 0;
econmake.FX('14','41') = 0;
econmake.FX('14','42') = 0;
econmake.FX('14','43') = 0;
econmake.FX('14','44') = 0;
econmake.FX('14','45') = 0;
econmake.FX('14','46') = 0;
econmake.FX('14','47') = 0;
econmake.FX('14','48') = 0;
econmake.FX('14','49') = 0;
econmake.FX('14','50') = 0;
econmake.FX('14','51') = 0;
econmake.FX('14','52') = 0;
econmake.FX('14','53') = 0;
econmake.FX('14','54') = 0;
econmake.FX('14','55') = 0;
econmake.FX('14','56') = 0;
econmake.FX('14','57') = 0;
econmake.FX('14','58') = 0;
econmake.FX('14','59') = 0;
econmake.FX('14','60') = 0;
econmake.FX('14','61') = 0;
econmake.FX('14','62') = 0;
econmake.FX('14','63') = 0;
econmake.FX('14','64') = 0;
econmake.FX('14','65') = 0;
econmake.FX('14','66') = 0;
econmake.FX('14','67') = 0;
econmake.FX('14','68') = 0;
econmake.FX('14','69') = 0;
econmake.FX('14','70') = 0;
econmake.FX('14','71') = 0;
econmake.FX('14','72') = 0;
econmake.FX('14','73') = 0;
econmake.FX('14','74') = 0;
econmake.FX('15','1') = 0;
econmake.FX('15','2') = 0;
econmake.FX('15','3') = 0;
econmake.FX('15','4') = 0;
econmake.FX('15','5') = 0;
econmake.FX('15','6') = 0;
econmake.FX('15','7') = 0;
econmake.FX('15','8') = 0;
econmake.FX('15','9') = 0;
econmake.FX('15','10') = 0;
econmake.FX('15','11') = 0;
econmake.FX('15','12') = 0;
econmake.FX('15','13') = 0;
econmake.FX('15','14') = 0;
econmake.FX('15','15') = 6.697135e+004;
econmake.FX('15','16') = 3.646000e+002;
econmake.FX('15','17') = 0;
econmake.FX('15','18') = 1.247956e+002;
econmake.FX('15','19') = 7.980000e+001;
econmake.FX('15','20') = 0;
econmake.FX('15','21') = 5.274867e+002;
econmake.FX('15','22') = 0;
econmake.FX('15','23') = 0;
econmake.FX('15','24') = 4.896054e+003;
econmake.FX('15','25') = 5.922959e+002;
econmake.FX('15','26') = 0;
econmake.FX('15','27') = 0;
econmake.FX('15','28') = 1.702000e+002;
econmake.FX('15','29') = 0;
econmake.FX('15','30') = 0;
econmake.FX('15','31') = 0;
econmake.FX('15','32') = 2.557000e+002;
econmake.FX('15','33') = 0;
econmake.FX('15','34') = 404;
econmake.FX('15','35') = 1.887181e+002;
econmake.FX('15','36') = 0;
econmake.FX('15','37') = 0;
econmake.FX('15','38') = 0;
econmake.FX('15','39') = 0;
econmake.FX('15','40') = 0;
econmake.FX('15','41') = 0;
econmake.FX('15','42') = 0;
econmake.FX('15','43') = 0;
econmake.FX('15','44') = 0;
econmake.FX('15','45') = 0;
econmake.FX('15','46') = 0;
econmake.FX('15','47') = 0;
econmake.FX('15','48') = 0;
econmake.FX('15','49') = 0;
econmake.FX('15','50') = 0;
econmake.FX('15','51') = 0;
econmake.FX('15','52') = 0;
econmake.FX('15','53') = 0;
econmake.FX('15','54') = 0;
econmake.FX('15','55') = 0;
econmake.FX('15','56') = 0;
econmake.FX('15','57') = 0;
econmake.FX('15','58') = 0;
econmake.FX('15','59') = 0;
econmake.FX('15','60') = 0;
econmake.FX('15','61') = 0;
econmake.FX('15','62') = 0;
econmake.FX('15','63') = 0;
econmake.FX('15','64') = 0;
econmake.FX('15','65') = 0;
econmake.FX('15','66') = 0;
econmake.FX('15','67') = 0;
econmake.FX('15','68') = 0;
econmake.FX('15','69') = 0;
econmake.FX('15','70') = 0;
econmake.FX('15','71') = 0;
econmake.FX('15','72') = 0;
econmake.FX('15','73') = 0;
econmake.FX('15','74') = 0;
econmake.FX('16','1') = 0;
econmake.FX('16','2') = 0;
econmake.FX('16','3') = 0;
econmake.FX('16','4') = 0;
econmake.FX('16','5') = 0;
econmake.FX('16','6') = 0;
econmake.FX('16','7') = 0;
econmake.FX('16','8') = 0;
econmake.FX('16','9') = 0;
econmake.FX('16','10') = 0;
econmake.FX('16','11') = 0;
econmake.FX('16','12') = 0;
econmake.FX('16','13') = 0;
econmake.FX('16','14') = 0;
econmake.FX('16','15') = 9.076000e+002;
econmake.FX('16','16') = 4.443770e+004;
econmake.FX('16','17') = 0;
econmake.FX('16','18') = 0;
econmake.FX('16','19') = 0;
econmake.FX('16','20') = 0;
econmake.FX('16','21') = 0;
econmake.FX('16','22') = 0;
econmake.FX('16','23') = 0;
econmake.FX('16','24') = 0;
econmake.FX('16','25') = 0;
econmake.FX('16','26') = 0;
econmake.FX('16','27') = 0;
econmake.FX('16','28') = 0;
econmake.FX('16','29') = 0;
econmake.FX('16','30') = 0;
econmake.FX('16','31') = 0;
econmake.FX('16','32') = 0;
econmake.FX('16','33') = 0;
econmake.FX('16','34') = 0;
econmake.FX('16','35') = 0;
econmake.FX('16','36') = 0;
econmake.FX('16','37') = 0;
econmake.FX('16','38') = 0;
econmake.FX('16','39') = 0;
econmake.FX('16','40') = 0;
econmake.FX('16','41') = 0;
econmake.FX('16','42') = 0;
econmake.FX('16','43') = 0;
econmake.FX('16','44') = 0;
econmake.FX('16','45') = 0;
econmake.FX('16','46') = 0;
econmake.FX('16','47') = 0;
econmake.FX('16','48') = 0;
econmake.FX('16','49') = 0;
econmake.FX('16','50') = 0;
econmake.FX('16','51') = 0;
econmake.FX('16','52') = 0;
econmake.FX('16','53') = 0;
econmake.FX('16','54') = 0;
econmake.FX('16','55') = 0;
econmake.FX('16','56') = 0;
econmake.FX('16','57') = 0;
econmake.FX('16','58') = 0;
econmake.FX('16','59') = 0;
econmake.FX('16','60') = 0;
econmake.FX('16','61') = 0;
econmake.FX('16','62') = 0;
econmake.FX('16','63') = 0;
econmake.FX('16','64') = 0;
econmake.FX('16','65') = 0;
econmake.FX('16','66') = 0;
econmake.FX('16','67') = 0;
econmake.FX('16','68') = 0;
econmake.FX('16','69') = 0;
econmake.FX('16','70') = 0;
econmake.FX('16','71') = 0;
econmake.FX('16','72') = 0;
econmake.FX('16','73') = 0;
econmake.FX('16','74') = 0;
econmake.FX('17','1') = 0;
econmake.FX('17','2') = 0;
econmake.FX('17','3') = 0;
econmake.FX('17','4') = 0;
econmake.FX('17','5') = 0;
econmake.FX('17','6') = 0;
econmake.FX('17','7') = 0;
econmake.FX('17','8') = 0;
econmake.FX('17','9') = 0;
econmake.FX('17','10') = 0;
econmake.FX('17','11') = 0;
econmake.FX('17','12') = 0;
econmake.FX('17','13') = 0;
econmake.FX('17','14') = 0;
econmake.FX('17','15') = 0;
econmake.FX('17','16') = 0;
econmake.FX('17','17') = 8.719597e+004;
econmake.FX('17','18') = 4.821810e+001;
econmake.FX('17','19') = 0;
econmake.FX('17','20') = 0;
econmake.FX('17','21') = 5.802178e+000;
econmake.FX('17','22') = 4.325242e+001;
econmake.FX('17','23') = 0;
econmake.FX('17','24') = 0;
econmake.FX('17','25') = 3.764975e+002;
econmake.FX('17','26') = 1.073454e+002;
econmake.FX('17','27') = 6.117415e+001;
econmake.FX('17','28') = 4.232161e+002;
econmake.FX('17','29') = 0;
econmake.FX('17','30') = 0;
econmake.FX('17','31') = 0;
econmake.FX('17','32') = 0;
econmake.FX('17','33') = 0;
econmake.FX('17','34') = 4.310560e+002;
econmake.FX('17','35') = 5.356492e+001;
econmake.FX('17','36') = 0;
econmake.FX('17','37') = 0;
econmake.FX('17','38') = 0;
econmake.FX('17','39') = 0;
econmake.FX('17','40') = 0;
econmake.FX('17','41') = 0;
econmake.FX('17','42') = 0;
econmake.FX('17','43') = 0;
econmake.FX('17','44') = 0;
econmake.FX('17','45') = 0;
econmake.FX('17','46') = 0;
econmake.FX('17','47') = 0;
econmake.FX('17','48') = 0;
econmake.FX('17','49') = 0;
econmake.FX('17','50') = 0;
econmake.FX('17','51') = 0;
econmake.FX('17','52') = 0;
econmake.FX('17','53') = 0;
econmake.FX('17','54') = 0;
econmake.FX('17','55') = 0;
econmake.FX('17','56') = 0;
econmake.FX('17','57') = 0;
econmake.FX('17','58') = 0;
econmake.FX('17','59') = 0;
econmake.FX('17','60') = 0;
econmake.FX('17','61') = 0;
econmake.FX('17','62') = 0;
econmake.FX('17','63') = 0;
econmake.FX('17','64') = 0;
econmake.FX('17','65') = 0;
econmake.FX('17','66') = 0;
econmake.FX('17','67') = 0;
econmake.FX('17','68') = 0;
econmake.FX('17','69') = 0;
econmake.FX('17','70') = 0;
econmake.FX('17','71') = 0;
econmake.FX('17','72') = 0;
econmake.FX('17','73') = 0;
econmake.FX('17','74') = 0;
econmake.FX('18','1') = 0;
econmake.FX('18','2') = 0;
econmake.FX('18','3') = 0;
econmake.FX('18','4') = 0;
econmake.FX('18','5') = 0;
econmake.FX('18','6') = 0;
econmake.FX('18','7') = 0;
econmake.FX('18','8') = 0;
econmake.FX('18','9') = 0;
econmake.FX('18','10') = 6.290000e+001;
econmake.FX('18','11') = 0;
econmake.FX('18','12') = 0;
econmake.FX('18','13') = 0;
econmake.FX('18','14') = 0;
econmake.FX('18','15') = 3.280648e+002;
econmake.FX('18','16') = 0;
econmake.FX('18','17') = 1.489963e+002;
econmake.FX('18','18') = 1.472415e+005;
econmake.FX('18','19') = 3.686080e+002;
econmake.FX('18','20') = 0;
econmake.FX('18','21') = 1.728482e+002;
econmake.FX('18','22') = 0;
econmake.FX('18','23') = 0;
econmake.FX('18','24') = 3.914578e+002;
econmake.FX('18','25') = 1.615991e+003;
econmake.FX('18','26') = 1.890387e+001;
econmake.FX('18','27') = 1.370280e+002;
econmake.FX('18','28') = 2.421710e+002;
econmake.FX('18','29') = 0;
econmake.FX('18','30') = 0;
econmake.FX('18','31') = 1.520589e+001;
econmake.FX('18','32') = 0;
econmake.FX('18','33') = 0;
econmake.FX('18','34') = 6.420000e+001;
econmake.FX('18','35') = 3.160957e+002;
econmake.FX('18','36') = 0;
econmake.FX('18','37') = 0;
econmake.FX('18','38') = 0;
econmake.FX('18','39') = 0;
econmake.FX('18','40') = 0;
econmake.FX('18','41') = 0;
econmake.FX('18','42') = 0;
econmake.FX('18','43') = 0;
econmake.FX('18','44') = 0;
econmake.FX('18','45') = 0;
econmake.FX('18','46') = 0;
econmake.FX('18','47') = 0;
econmake.FX('18','48') = 0;
econmake.FX('18','49') = 0;
econmake.FX('18','50') = 0;
econmake.FX('18','51') = 0;
econmake.FX('18','52') = 0;
econmake.FX('18','53') = 0;
econmake.FX('18','54') = 0;
econmake.FX('18','55') = 0;
econmake.FX('18','56') = 0;
econmake.FX('18','57') = 0;
econmake.FX('18','58') = 0;
econmake.FX('18','59') = 0;
econmake.FX('18','60') = 0;
econmake.FX('18','61') = 0;
econmake.FX('18','62') = 0;
econmake.FX('18','63') = 0;
econmake.FX('18','64') = 0;
econmake.FX('18','65') = 0;
econmake.FX('18','66') = 0;
econmake.FX('18','67') = 0;
econmake.FX('18','68') = 0;
econmake.FX('18','69') = 0;
econmake.FX('18','70') = 0;
econmake.FX('18','71') = 0;
econmake.FX('18','72') = 0;
econmake.FX('18','73') = 0;
econmake.FX('18','74') = 0;
econmake.FX('19','1') = 0;
econmake.FX('19','2') = 0;
econmake.FX('19','3') = 0;
econmake.FX('19','4') = 0;
econmake.FX('19','5') = 0;
econmake.FX('19','6') = 0;
econmake.FX('19','7') = 0;
econmake.FX('19','8') = 0;
econmake.FX('19','9') = 0;
econmake.FX('19','10') = 0;
econmake.FX('19','11') = 0;
econmake.FX('19','12') = 0;
econmake.FX('19','13') = 0;
econmake.FX('19','14') = 0;
econmake.FX('19','15') = 5.280920e+001;
econmake.FX('19','16') = 2.004144e+001;
econmake.FX('19','17') = 0;
econmake.FX('19','18') = 7.087494e+002;
econmake.FX('19','19') = 7.306222e+004;
econmake.FX('19','20') = 0;
econmake.FX('19','21') = 0;
econmake.FX('19','22') = 0;
econmake.FX('19','23') = 0;
econmake.FX('19','24') = 0;
econmake.FX('19','25') = 1.686487e+002;
econmake.FX('19','26') = 0;
econmake.FX('19','27') = 0;
econmake.FX('19','28') = 2.715615e+001;
econmake.FX('19','29') = 0;
econmake.FX('19','30') = 4.008288e+001;
econmake.FX('19','31') = 1.306702e+002;
econmake.FX('19','32') = 0;
econmake.FX('19','33') = 0;
econmake.FX('19','34') = 0;
econmake.FX('19','35') = 2.976154e+002;
econmake.FX('19','36') = 0;
econmake.FX('19','37') = 0;
econmake.FX('19','38') = 0;
econmake.FX('19','39') = 0;
econmake.FX('19','40') = 0;
econmake.FX('19','41') = 0;
econmake.FX('19','42') = 0;
econmake.FX('19','43') = 0;
econmake.FX('19','44') = 0;
econmake.FX('19','45') = 0;
econmake.FX('19','46') = 0;
econmake.FX('19','47') = 0;
econmake.FX('19','48') = 0;
econmake.FX('19','49') = 0;
econmake.FX('19','50') = 0;
econmake.FX('19','51') = 0;
econmake.FX('19','52') = 0;
econmake.FX('19','53') = 0;
econmake.FX('19','54') = 0;
econmake.FX('19','55') = 0;
econmake.FX('19','56') = 0;
econmake.FX('19','57') = 2.297160e+004;
econmake.FX('19','58') = 0;
econmake.FX('19','59') = 9.733097e+002;
econmake.FX('19','60') = 0;
econmake.FX('19','61') = 0;
econmake.FX('19','62') = 0;
econmake.FX('19','63') = 0;
econmake.FX('19','64') = 0;
econmake.FX('19','65') = 0;
econmake.FX('19','66') = 0;
econmake.FX('19','67') = 0;
econmake.FX('19','68') = 0;
econmake.FX('19','69') = 0;
econmake.FX('19','70') = 0;
econmake.FX('19','71') = 0;
econmake.FX('19','72') = 0;
econmake.FX('19','73') = 0;
econmake.FX('19','74') = 0;
econmake.FX('20','1') = 0;
econmake.FX('20','2') = 0;
econmake.FX('20','3') = 0;
econmake.FX('20','4') = 0;
econmake.FX('20','5') = 0;
econmake.FX('20','6') = 6;
econmake.FX('20','7') = 0;
econmake.FX('20','8') = 1.686000e+002;
econmake.FX('20','9') = 0;
econmake.FX('20','10') = 0;
econmake.FX('20','11') = 0;
econmake.FX('20','12') = 0;
econmake.FX('20','13') = 0;
econmake.FX('20','14') = 0;
econmake.FX('20','15') = 5.440000e+001;
econmake.FX('20','16') = 0;
econmake.FX('20','17') = 0;
econmake.FX('20','18') = 1.450000e+001;
econmake.FX('20','19') = 0;
econmake.FX('20','20') = 1.987851e+005;
econmake.FX('20','21') = 333;
econmake.FX('20','22') = 0;
econmake.FX('20','23') = 0;
econmake.FX('20','24') = 1.024660e+004;
econmake.FX('20','25') = 5.630000e+001;
econmake.FX('20','26') = 1.326000e+002;
econmake.FX('20','27') = 5.419000e+002;
econmake.FX('20','28') = 0;
econmake.FX('20','29') = 5.920000e+001;
econmake.FX('20','30') = 0;
econmake.FX('20','31') = 0;
econmake.FX('20','32') = 0;
econmake.FX('20','33') = 0;
econmake.FX('20','34') = 0;
econmake.FX('20','35') = 0;
econmake.FX('20','36') = 0;
econmake.FX('20','37') = 0;
econmake.FX('20','38') = 0;
econmake.FX('20','39') = 0;
econmake.FX('20','40') = 0;
econmake.FX('20','41') = 0;
econmake.FX('20','42') = 0;
econmake.FX('20','43') = 0;
econmake.FX('20','44') = 0;
econmake.FX('20','45') = 0;
econmake.FX('20','46') = 0;
econmake.FX('20','47') = 0;
econmake.FX('20','48') = 0;
econmake.FX('20','49') = 0;
econmake.FX('20','50') = 0;
econmake.FX('20','51') = 0;
econmake.FX('20','52') = 0;
econmake.FX('20','53') = 0;
econmake.FX('20','54') = 0;
econmake.FX('20','55') = 0;
econmake.FX('20','56') = 0;
econmake.FX('20','57') = 0;
econmake.FX('20','58') = 0;
econmake.FX('20','59') = 0;
econmake.FX('20','60') = 0;
econmake.FX('20','61') = 0;
econmake.FX('20','62') = 0;
econmake.FX('20','63') = 0;
econmake.FX('20','64') = 0;
econmake.FX('20','65') = 0;
econmake.FX('20','66') = 0;
econmake.FX('20','67') = 0;
econmake.FX('20','68') = 0;
econmake.FX('20','69') = 0;
econmake.FX('20','70') = 0;
econmake.FX('20','71') = 0;
econmake.FX('20','72') = 0;
econmake.FX('20','73') = 0;
econmake.FX('20','74') = 0;
econmake.FX('21','1') = 0;
econmake.FX('21','2') = 0;
econmake.FX('21','3') = 0;
econmake.FX('21','4') = 0;
econmake.FX('21','5') = 0;
econmake.FX('21','6') = 6.400000e+000;
econmake.FX('21','7') = 0;
econmake.FX('21','8') = 0;
econmake.FX('21','9') = 0;
econmake.FX('21','10') = 0;
econmake.FX('21','11') = 0;
econmake.FX('21','12') = 0;
econmake.FX('21','13') = 0;
econmake.FX('21','14') = 1.152300e+003;
econmake.FX('21','15') = 0;
econmake.FX('21','16') = 0;
econmake.FX('21','17') = 0;
econmake.FX('21','18') = 0;
econmake.FX('21','19') = 0;
econmake.FX('21','20') = 6.549000e+002;

ddgs92.. econmake('21','21') =E= (4.344940e+004)+(ddgs*360*86400*0.075/1000000);

econmake.FX('21','22') = 1.228000e+002;
econmake.FX('21','23') = 3.198000e+002;
econmake.FX('21','24') = 9.018200e+003;
econmake.FX('21','25') = 1.522000e+002;
econmake.FX('21','26') = 0;
econmake.FX('21','27') = 0;
econmake.FX('21','28') = 0;
econmake.FX('21','29') = 7.080000e+001;
econmake.FX('21','30') = 0;
econmake.FX('21','31') = 0;
econmake.FX('21','32') = 0;
econmake.FX('21','33') = 0;
econmake.FX('21','34') = 0;
econmake.FX('21','35') = 0;
econmake.FX('21','36') = 0;
econmake.FX('21','37') = 0;
econmake.FX('21','38') = 0;
econmake.FX('21','39') = 0;
econmake.FX('21','40') = 0;
econmake.FX('21','41') = 0;
econmake.FX('21','42') = 0;
econmake.FX('21','43') = 0;
econmake.FX('21','44') = 0;
econmake.FX('21','45') = 0;
econmake.FX('21','46') = 0;
econmake.FX('21','47') = 0;
econmake.FX('21','48') = 0;
econmake.FX('21','49') = 0;
econmake.FX('21','50') = 0;
econmake.FX('21','51') = 0;
econmake.FX('21','52') = 0;
econmake.FX('21','53') = 0;
econmake.FX('21','54') = 0;
econmake.FX('21','55') = 0;
econmake.FX('21','56') = 0;
econmake.FX('21','57') = 0;
econmake.FX('21','58') = 0;
econmake.FX('21','59') = 0;
econmake.FX('21','60') = 0;
econmake.FX('21','61') = 0;
econmake.FX('21','62') = 0;
econmake.FX('21','63') = 0;
econmake.FX('21','64') = 0;
econmake.FX('21','65') = 0;
econmake.FX('21','66') = 0;
econmake.FX('21','67') = 0;
econmake.FX('21','68') = 0;
econmake.FX('21','69') = 0;
econmake.FX('21','70') = 0;
econmake.FX('21','71') = 0;
econmake.FX('21','72') = 0;
econmake.FX('21','73') = 0;
econmake.FX('21','74') = 0;
econmake.FX('22','1') = 0;
econmake.FX('22','2') = 0;
econmake.FX('22','3') = 0;
econmake.FX('22','4') = 0;
econmake.FX('22','5') = 0;
econmake.FX('22','6') = 0;
econmake.FX('22','7') = 0;
econmake.FX('22','8') = 0;
econmake.FX('22','9') = 0;
econmake.FX('22','10') = 0;
econmake.FX('22','11') = 0;
econmake.FX('22','12') = 0;
econmake.FX('22','13') = 0;
econmake.FX('22','14') = 4.650000e+001;
econmake.FX('22','15') = 0;
econmake.FX('22','16') = 0;
econmake.FX('22','17') = 0;
econmake.FX('22','18') = 0;
econmake.FX('22','19') = 0;
econmake.FX('22','20') = 0;
econmake.FX('22','21') = 8.900000e+000;
econmake.FX('22','22') = 9.638700e+003;
econmake.FX('22','23') = 0;
econmake.FX('22','24') = 2.178000e+002;
econmake.FX('22','25') = 0;
econmake.FX('22','26') = 0;
econmake.FX('22','27') = 0;
econmake.FX('22','28') = 0;
econmake.FX('22','29') = 0;
econmake.FX('22','30') = 0;
econmake.FX('22','31') = 0;
econmake.FX('22','32') = 0;
econmake.FX('22','33') = 0;
econmake.FX('22','34') = 0;
econmake.FX('22','35') = 0;
econmake.FX('22','36') = 0;
econmake.FX('22','37') = 0;
econmake.FX('22','38') = 0;
econmake.FX('22','39') = 0;
econmake.FX('22','40') = 0;
econmake.FX('22','41') = 0;
econmake.FX('22','42') = 0;
econmake.FX('22','43') = 0;
econmake.FX('22','44') = 0;
econmake.FX('22','45') = 0;
econmake.FX('22','46') = 0;
econmake.FX('22','47') = 0;
econmake.FX('22','48') = 0;
econmake.FX('22','49') = 0;
econmake.FX('22','50') = 0;
econmake.FX('22','51') = 0;
econmake.FX('22','52') = 0;
econmake.FX('22','53') = 0;
econmake.FX('22','54') = 0;
econmake.FX('22','55') = 0;
econmake.FX('22','56') = 0;
econmake.FX('22','57') = 0;
econmake.FX('22','58') = 0;
econmake.FX('22','59') = 0;
econmake.FX('22','60') = 0;
econmake.FX('22','61') = 0;
econmake.FX('22','62') = 0;
econmake.FX('22','63') = 0;
econmake.FX('22','64') = 0;
econmake.FX('22','65') = 0;
econmake.FX('22','66') = 0;
econmake.FX('22','67') = 0;
econmake.FX('22','68') = 0;
econmake.FX('22','69') = 0;
econmake.FX('22','70') = 0;
econmake.FX('22','71') = 0;
econmake.FX('22','72') = 0;
econmake.FX('22','73') = 0;
econmake.FX('22','74') = 0;
econmake.FX('23','1') = 0;
econmake.FX('23','2') = 0;
econmake.FX('23','3') = 0;
econmake.FX('23','4') = 0;
econmake.FX('23','5') = 0;
econmake.FX('23','6') = 0;
econmake.FX('23','7') = 0;
econmake.FX('23','8') = 0;
econmake.FX('23','9') = 0;
econmake.FX('23','10') = 0;
econmake.FX('23','11') = 0;
econmake.FX('23','12') = 0;
econmake.FX('23','13') = 0;
econmake.FX('23','14') = 0;
econmake.FX('23','15') = 0;
econmake.FX('23','16') = 0;
econmake.FX('23','17') = 0;
econmake.FX('23','18') = 0;
econmake.FX('23','19') = 0;
econmake.FX('23','20') = 5.780000e+001;
econmake.FX('23','21') = 5.630000e+001;
econmake.FX('23','22') = 2.880000e+001;
econmake.FX('23','23') = 8.555800e+003;
econmake.FX('23','24') = 50;
econmake.FX('23','25') = 0;
econmake.FX('23','26') = 0;
econmake.FX('23','27') = 0;
econmake.FX('23','28') = 0;
econmake.FX('23','29') = 0;
econmake.FX('23','30') = 0;
econmake.FX('23','31') = 0;
econmake.FX('23','32') = 0;
econmake.FX('23','33') = 0;
econmake.FX('23','34') = 0;
econmake.FX('23','35') = 0;
econmake.FX('23','36') = 0;
econmake.FX('23','37') = 0;
econmake.FX('23','38') = 0;
econmake.FX('23','39') = 0;
econmake.FX('23','40') = 0;
econmake.FX('23','41') = 0;
econmake.FX('23','42') = 0;
econmake.FX('23','43') = 0;
econmake.FX('23','44') = 0;
econmake.FX('23','45') = 0;
econmake.FX('23','46') = 0;
econmake.FX('23','47') = 0;
econmake.FX('23','48') = 0;
econmake.FX('23','49') = 0;
econmake.FX('23','50') = 0;
econmake.FX('23','51') = 0;
econmake.FX('23','52') = 0;
econmake.FX('23','53') = 0;
econmake.FX('23','54') = 0;
econmake.FX('23','55') = 0;
econmake.FX('23','56') = 0;
econmake.FX('23','57') = 0;
econmake.FX('23','58') = 0;
econmake.FX('23','59') = 0;
econmake.FX('23','60') = 0;
econmake.FX('23','61') = 0;
econmake.FX('23','62') = 0;
econmake.FX('23','63') = 0;
econmake.FX('23','64') = 0;
econmake.FX('23','65') = 0;
econmake.FX('23','66') = 0;
econmake.FX('23','67') = 0;
econmake.FX('23','68') = 0;
econmake.FX('23','69') = 0;
econmake.FX('23','70') = 0;
econmake.FX('23','71') = 0;
econmake.FX('23','72') = 0;
econmake.FX('23','73') = 0;
econmake.FX('23','74') = 0;
econmake.FX('24','1') = 0;
econmake.FX('24','2') = 0;
econmake.FX('24','3') = 0;
econmake.FX('24','4') = 0;
econmake.FX('24','5') = 0;
econmake.FX('24','6') = 0;
econmake.FX('24','7') = 0;
econmake.FX('24','8') = 2.510000e+001;
econmake.FX('24','9') = 0;
econmake.FX('24','10') = 0;
econmake.FX('24','11') = 0;
econmake.FX('24','12') = 0;
econmake.FX('24','13') = 0;
econmake.FX('24','14') = 4.675000e+002;
econmake.FX('24','15') = 0;
econmake.FX('24','16') = 0;
econmake.FX('24','17') = 3.570000e+001;
econmake.FX('24','18') = 2.127000e+002;
econmake.FX('24','19') = 1.540000e+001;
econmake.FX('24','20') = 1.054900e+003;
econmake.FX('24','21') = 1.004780e+004;
econmake.FX('24','22') = 1.935000e+002;
econmake.FX('24','23') = 6.948000e+002;
econmake.FX('24','24') = 3.495464e+005;
econmake.FX('24','25') = 2.899300e+003;
econmake.FX('24','26') = 8.930000e+001;
econmake.FX('24','27') = 4.470000e+001;
econmake.FX('24','28') = 2.274000e+002;
econmake.FX('24','29') = 7.662000e+002;
econmake.FX('24','30') = 5.610000e+001;
econmake.FX('24','31') = 1.080500e+003;
econmake.FX('24','32') = 1.009000e+002;
econmake.FX('24','33') = 0;
econmake.FX('24','34') = 0;
econmake.FX('24','35') = 4.346000e+002;
econmake.FX('24','36') = 0;
econmake.FX('24','37') = 0;
econmake.FX('24','38') = 0;
econmake.FX('24','39') = 0;
econmake.FX('24','40') = 0;
econmake.FX('24','41') = 0;
econmake.FX('24','42') = 0;
econmake.FX('24','43') = 0;
econmake.FX('24','44') = 0;
econmake.FX('24','45') = 0;
econmake.FX('24','46') = 0;
econmake.FX('24','47') = 0;
econmake.FX('24','48') = 0;
econmake.FX('24','49') = 0;
econmake.FX('24','50') = 0;
econmake.FX('24','51') = 0;
econmake.FX('24','52') = 0;
econmake.FX('24','53') = 0;
econmake.FX('24','54') = 0;
econmake.FX('24','55') = 0;
econmake.FX('24','56') = 0;
econmake.FX('24','57') = 0;
econmake.FX('24','58') = 0;
econmake.FX('24','59') = 0;
econmake.FX('24','60') = 0;
econmake.FX('24','61') = 0;
econmake.FX('24','62') = 0;
econmake.FX('24','63') = 0;
econmake.FX('24','64') = 0;
econmake.FX('24','65') = 0;
econmake.FX('24','66') = 0;
econmake.FX('24','67') = 0;
econmake.FX('24','68') = 0;
econmake.FX('24','69') = 0;
econmake.FX('24','70') = 0;
econmake.FX('24','71') = 0;
econmake.FX('24','72') = 0;
econmake.FX('24','73') = 0;
econmake.FX('24','74') = 0;
econmake.FX('25','1') = 0;
econmake.FX('25','2') = 0;
econmake.FX('25','3') = 0;
econmake.FX('25','4') = 0;
econmake.FX('25','5') = 0;
econmake.FX('25','6') = 0;
econmake.FX('25','7') = 0;
econmake.FX('25','8') = 0;
econmake.FX('25','9') = 0;
econmake.FX('25','10') = 0;
econmake.FX('25','11') = 0;
econmake.FX('25','12') = 0;
econmake.FX('25','13') = 0;
econmake.FX('25','14') = 0;
econmake.FX('25','15') = 2.728443e+002;
econmake.FX('25','16') = 0;
econmake.FX('25','17') = 1.677633e+002;
econmake.FX('25','18') = 1.248025e+003;
econmake.FX('25','19') = 1.791814e+002;
econmake.FX('25','20') = 0;
econmake.FX('25','21') = 1.398076e+002;
econmake.FX('25','22') = 0;
econmake.FX('25','23') = 0;
econmake.FX('25','24') = 9.067951e+002;
econmake.FX('25','25') = 1.600913e+005;
econmake.FX('25','26') = 1.468364e+002;
econmake.FX('25','27') = 1.589309e+002;
econmake.FX('25','28') = 9.272284e+002;
econmake.FX('25','29') = 2.092596e+003;
econmake.FX('25','30') = 0;
econmake.FX('25','31') = 8.085830e+002;
econmake.FX('25','32') = 1.007981e+003;
econmake.FX('25','33') = 5.564581e+001;
econmake.FX('25','34') = 1.408159e+002;
econmake.FX('25','35') = 6.236724e+002;
econmake.FX('25','36') = 0;
econmake.FX('25','37') = 0;
econmake.FX('25','38') = 0;
econmake.FX('25','39') = 0;
econmake.FX('25','40') = 0;
econmake.FX('25','41') = 0;
econmake.FX('25','42') = 0;
econmake.FX('25','43') = 0;
econmake.FX('25','44') = 0;
econmake.FX('25','45') = 0;
econmake.FX('25','46') = 0;
econmake.FX('25','47') = 0;
econmake.FX('25','48') = 0;
econmake.FX('25','49') = 0;
econmake.FX('25','50') = 0;
econmake.FX('25','51') = 0;
econmake.FX('25','52') = 0;
econmake.FX('25','53') = 0;
econmake.FX('25','54') = 0;
econmake.FX('25','55') = 0;
econmake.FX('25','56') = 0;
econmake.FX('25','57') = 0;
econmake.FX('25','58') = 0;
econmake.FX('25','59') = 4.521187e+001;
econmake.FX('25','60') = 0;
econmake.FX('25','61') = 0;
econmake.FX('25','62') = 0;
econmake.FX('25','63') = 0;
econmake.FX('25','64') = 0;
econmake.FX('25','65') = 0;
econmake.FX('25','66') = 0;
econmake.FX('25','67') = 0;
econmake.FX('25','68') = 0;
econmake.FX('25','69') = 0;
econmake.FX('25','70') = 0;
econmake.FX('25','71') = 0;
econmake.FX('25','72') = 0;
econmake.FX('25','73') = 0;
econmake.FX('25','74') = 0;
econmake.FX('26','1') = 0;
econmake.FX('26','2') = 0;
econmake.FX('26','3') = 0;
econmake.FX('26','4') = 0;
econmake.FX('26','5') = 0;
econmake.FX('26','6') = 0;
econmake.FX('26','7') = 0;
econmake.FX('26','8') = 5.963000e+002;
econmake.FX('26','9') = 4.500000e+000;
econmake.FX('26','10') = 0;
econmake.FX('26','11') = 0;
econmake.FX('26','12') = 0;
econmake.FX('26','13') = 0;
econmake.FX('26','14') = 0;
econmake.FX('26','15') = 1.860000e+001;
econmake.FX('26','16') = 0;
econmake.FX('26','17') = 1.667180e+002;
econmake.FX('26','18') = 1.072000e+002;
econmake.FX('26','19') = 0;
econmake.FX('26','20') = 2.606000e+002;
econmake.FX('26','21') = 0;
econmake.FX('26','22') = 0;
econmake.FX('26','23') = 0;
econmake.FX('26','24') = 9.440000e+001;
econmake.FX('26','25') = 2.379290e+002;
econmake.FX('26','26') = 9.024852e+004;
econmake.FX('26','27') = 0;
econmake.FX('26','28') = 5.040950e+001;
econmake.FX('26','29') = 1.939315e+002;
econmake.FX('26','30') = 0;
econmake.FX('26','31') = 1.715532e+002;
econmake.FX('26','32') = 6.121876e+001;
econmake.FX('26','33') = 2.080000e+001;
econmake.FX('26','34') = 1.134139e+002;
econmake.FX('26','35') = 6.050264e+001;
econmake.FX('26','36') = 0;
econmake.FX('26','37') = 0;
econmake.FX('26','38') = 0;
econmake.FX('26','39') = 0;
econmake.FX('26','40') = 0;
econmake.FX('26','41') = 0;
econmake.FX('26','42') = 0;
econmake.FX('26','43') = 0;
econmake.FX('26','44') = 0;
econmake.FX('26','45') = 0;
econmake.FX('26','46') = 0;
econmake.FX('26','47') = 0;
econmake.FX('26','48') = 0;
econmake.FX('26','49') = 0;
econmake.FX('26','50') = 0;
econmake.FX('26','51') = 0;
econmake.FX('26','52') = 0;
econmake.FX('26','53') = 0;
econmake.FX('26','54') = 0;
econmake.FX('26','55') = 0;
econmake.FX('26','56') = 0;
econmake.FX('26','57') = 0;
econmake.FX('26','58') = 0;
econmake.FX('26','59') = 0;
econmake.FX('26','60') = 0;
econmake.FX('26','61') = 0;
econmake.FX('26','62') = 0;
econmake.FX('26','63') = 0;
econmake.FX('26','64') = 0;
econmake.FX('26','65') = 0;
econmake.FX('26','66') = 0;
econmake.FX('26','67') = 0;
econmake.FX('26','68') = 0;
econmake.FX('26','69') = 0;
econmake.FX('26','70') = 0;
econmake.FX('26','71') = 0;
econmake.FX('26','72') = 0;
econmake.FX('26','73') = 0;
econmake.FX('26','74') = 0;
econmake.FX('27','1') = 0;
econmake.FX('27','2') = 0;
econmake.FX('27','3') = 0;
econmake.FX('27','4') = 0;
econmake.FX('27','5') = 0;
econmake.FX('27','6') = 0;
econmake.FX('27','7') = 0;
econmake.FX('27','8') = 0;
econmake.FX('27','9') = 0;
econmake.FX('27','10') = 0;
econmake.FX('27','11') = 0;
econmake.FX('27','12') = 0;
econmake.FX('27','13') = 0;
econmake.FX('27','14') = 0;
econmake.FX('27','15') = 7.361526e+001;
econmake.FX('27','16') = 0;
econmake.FX('27','17') = 0;
econmake.FX('27','18') = 3.756707e+001;
econmake.FX('27','19') = 0;
econmake.FX('27','20') = 6.367695e+001;
econmake.FX('27','21') = 6.367695e+001;
econmake.FX('27','22') = 0;
econmake.FX('27','23') = 0;
econmake.FX('27','24') = 6.355396e+002;
econmake.FX('27','25') = 1.647275e+002;
econmake.FX('27','26') = 7.946427e+001;
econmake.FX('27','27') = 1.532641e+005;
econmake.FX('27','28') = 1.693706e+003;
econmake.FX('27','29') = 8.467730e+002;
econmake.FX('27','30') = 0;
econmake.FX('27','31') = 6.123945e+002;
econmake.FX('27','32') = 5.427606e+002;
econmake.FX('27','33') = 1.569739e+001;
econmake.FX('27','34') = 1.822661e+001;
econmake.FX('27','35') = 0;
econmake.FX('27','36') = 0;
econmake.FX('27','37') = 0;
econmake.FX('27','38') = 0;
econmake.FX('27','39') = 0;
econmake.FX('27','40') = 0;
econmake.FX('27','41') = 0;
econmake.FX('27','42') = 0;
econmake.FX('27','43') = 0;
econmake.FX('27','44') = 0;
econmake.FX('27','45') = 0;
econmake.FX('27','46') = 0;
econmake.FX('27','47') = 0;
econmake.FX('27','48') = 0;
econmake.FX('27','49') = 0;
econmake.FX('27','50') = 0;
econmake.FX('27','51') = 0;
econmake.FX('27','52') = 0;
econmake.FX('27','53') = 0;
econmake.FX('27','54') = 0;
econmake.FX('27','55') = 0;
econmake.FX('27','56') = 0;
econmake.FX('27','57') = 0;
econmake.FX('27','58') = 0;
econmake.FX('27','59') = 0;
econmake.FX('27','60') = 0;
econmake.FX('27','61') = 0;
econmake.FX('27','62') = 0;
econmake.FX('27','63') = 0;
econmake.FX('27','64') = 0;
econmake.FX('27','65') = 0;
econmake.FX('27','66') = 0;
econmake.FX('27','67') = 0;
econmake.FX('27','68') = 0;
econmake.FX('27','69') = 0;
econmake.FX('27','70') = 0;
econmake.FX('27','71') = 0;
econmake.FX('27','72') = 0;
econmake.FX('27','73') = 0;
econmake.FX('27','74') = 0;
econmake.FX('28','1') = 0;
econmake.FX('28','2') = 0;
econmake.FX('28','3') = 0;
econmake.FX('28','4') = 0;
econmake.FX('28','5') = 0;
econmake.FX('28','6') = 0;
econmake.FX('28','7') = 0;
econmake.FX('28','8') = 0;
econmake.FX('28','9') = 0;
econmake.FX('28','10') = 0;
econmake.FX('28','11') = 0;
econmake.FX('28','12') = 0;
econmake.FX('28','13') = 0;
econmake.FX('28','14') = 0;
econmake.FX('28','15') = 2.685422e+001;
econmake.FX('28','16') = 0;
econmake.FX('28','17') = 2.348418e+002;
econmake.FX('28','18') = 3.632565e+001;
econmake.FX('28','19') = 5.098103e+001;
econmake.FX('28','20') = 0;
econmake.FX('28','21') = 0;
econmake.FX('28','22') = 0;
econmake.FX('28','23') = 0;
econmake.FX('28','24') = 2.024462e+002;
econmake.FX('28','25') = 1.468478e+003;
econmake.FX('28','26') = 2.675540e+002;
econmake.FX('28','27') = 5.486667e+003;
econmake.FX('28','28') = 2.046768e+005;
econmake.FX('28','29') = 3.570342e+003;
econmake.FX('28','30') = 8.948965e+001;
econmake.FX('28','31') = 1.104764e+003;
econmake.FX('28','32') = 1.179897e+003;
econmake.FX('28','33') = 4.478079e+001;
econmake.FX('28','34') = 2.394014e+002;
econmake.FX('28','35') = 4.067386e+002;
econmake.FX('28','36') = 0;
econmake.FX('28','37') = 0;
econmake.FX('28','38') = 0;
econmake.FX('28','39') = 0;
econmake.FX('28','40') = 0;
econmake.FX('28','41') = 0;
econmake.FX('28','42') = 0;
econmake.FX('28','43') = 0;
econmake.FX('28','44') = 0;
econmake.FX('28','45') = 0;
econmake.FX('28','46') = 0;
econmake.FX('28','47') = 0;
econmake.FX('28','48') = 0;
econmake.FX('28','49') = 0;
econmake.FX('28','50') = 0;
econmake.FX('28','51') = 0;
econmake.FX('28','52') = 0;
econmake.FX('28','53') = 0;
econmake.FX('28','54') = 0;
econmake.FX('28','55') = 0;
econmake.FX('28','56') = 0;
econmake.FX('28','57') = 0;
econmake.FX('28','58') = 0;
econmake.FX('28','59') = 0;
econmake.FX('28','60') = 0;
econmake.FX('28','61') = 0;
econmake.FX('28','62') = 0;
econmake.FX('28','63') = 0;
econmake.FX('28','64') = 0;
econmake.FX('28','65') = 0;
econmake.FX('28','66') = 0;
econmake.FX('28','67') = 0;
econmake.FX('28','68') = 0;
econmake.FX('28','69') = 0;
econmake.FX('28','70') = 8.838769e+001;
econmake.FX('28','71') = 0;
econmake.FX('28','72') = 0;
econmake.FX('28','73') = 0;
econmake.FX('28','74') = 0;
econmake.FX('29','1') = 0;
econmake.FX('29','2') = 0;
econmake.FX('29','3') = 0;
econmake.FX('29','4') = 0;
econmake.FX('29','5') = 0;
econmake.FX('29','6') = 0;
econmake.FX('29','7') = 0;
econmake.FX('29','8') = 0;
econmake.FX('29','9') = 0;
econmake.FX('29','10') = 0;
econmake.FX('29','11') = 0;
econmake.FX('29','12') = 0;
econmake.FX('29','13') = 0;
econmake.FX('29','14') = 1.072605e+002;
econmake.FX('29','15') = 0;
econmake.FX('29','16') = 0;
econmake.FX('29','17') = 0;
econmake.FX('29','18') = 2.235273e+001;
econmake.FX('29','19') = 0;
econmake.FX('29','20') = 0;
econmake.FX('29','21') = 2.800357e+000;
econmake.FX('29','22') = 0;
econmake.FX('29','23') = 0;
econmake.FX('29','24') = 3.461999e+002;
econmake.FX('29','25') = 3.160541e+002;
econmake.FX('29','26') = 9.601781e+001;
econmake.FX('29','27') = 4.141223e+002;
econmake.FX('29','28') = 2.658096e+003;
econmake.FX('29','29') = 2.260354e+005;
econmake.FX('29','30') = 2.480000e+001;
econmake.FX('29','31') = 3.191780e+003;
econmake.FX('29','32') = 2.255831e+003;
econmake.FX('29','33') = 4.279115e+002;
econmake.FX('29','34') = 7.342345e+001;
econmake.FX('29','35') = 3.742278e+002;
econmake.FX('29','36') = 0;
econmake.FX('29','37') = 0;
econmake.FX('29','38') = 0;
econmake.FX('29','39') = 0;
econmake.FX('29','40') = 0;
econmake.FX('29','41') = 0;
econmake.FX('29','42') = 0;
econmake.FX('29','43') = 0;
econmake.FX('29','44') = 0;
econmake.FX('29','45') = 0;
econmake.FX('29','46') = 0;
econmake.FX('29','47') = 0;
econmake.FX('29','48') = 0;
econmake.FX('29','49') = 0;
econmake.FX('29','50') = 0;
econmake.FX('29','51') = 0;
econmake.FX('29','52') = 0;
econmake.FX('29','53') = 0;
econmake.FX('29','54') = 0;
econmake.FX('29','55') = 0;
econmake.FX('29','56') = 0;
econmake.FX('29','57') = 0;
econmake.FX('29','58') = 0;
econmake.FX('29','59') = 0;
econmake.FX('29','60') = 0;
econmake.FX('29','61') = 0;
econmake.FX('29','62') = 0;
econmake.FX('29','63') = 0;
econmake.FX('29','64') = 0;
econmake.FX('29','65') = 0;
econmake.FX('29','66') = 0;
econmake.FX('29','67') = 0;
econmake.FX('29','68') = 0;
econmake.FX('29','69') = 0;
econmake.FX('29','70') = 1.500001e+000;
econmake.FX('29','71') = 0;
econmake.FX('29','72') = 0;
econmake.FX('29','73') = 0;
econmake.FX('29','74') = 0;
econmake.FX('30','1') = 0;
econmake.FX('30','2') = 0;
econmake.FX('30','3') = 0;
econmake.FX('30','4') = 0;
econmake.FX('30','5') = 0;
econmake.FX('30','6') = 0;
econmake.FX('30','7') = 0;
econmake.FX('30','8') = 0;
econmake.FX('30','9') = 0;
econmake.FX('30','10') = 0;
econmake.FX('30','11') = 0;
econmake.FX('30','12') = 0;
econmake.FX('30','13') = 0;
econmake.FX('30','14') = 0;
econmake.FX('30','15') = 6.870286e+001;
econmake.FX('30','16') = 0;
econmake.FX('30','17') = 0;
econmake.FX('30','18') = 5.760240e+001;
econmake.FX('30','19') = 0;
econmake.FX('30','20') = 0;
econmake.FX('30','21') = 0;
econmake.FX('30','22') = 0;
econmake.FX('30','23') = 0;
econmake.FX('30','24') = 1.196050e+002;
econmake.FX('30','25') = 1.421059e+002;
econmake.FX('30','26') = 5.090212e+001;
econmake.FX('30','27') = 0;
econmake.FX('30','28') = 0;
econmake.FX('30','29') = 2.790116e+001;
econmake.FX('30','30') = 6.451503e+004;
econmake.FX('30','31') = 2.531149e+003;
econmake.FX('30','32') = 0;
econmake.FX('30','33') = 0;
econmake.FX('30','34') = 1.660000e+001;
econmake.FX('30','35') = 0;
econmake.FX('30','36') = 0;
econmake.FX('30','37') = 0;
econmake.FX('30','38') = 0;
econmake.FX('30','39') = 0;
econmake.FX('30','40') = 0;
econmake.FX('30','41') = 0;
econmake.FX('30','42') = 0;
econmake.FX('30','43') = 0;
econmake.FX('30','44') = 0;
econmake.FX('30','45') = 0;
econmake.FX('30','46') = 0;
econmake.FX('30','47') = 0;
econmake.FX('30','48') = 0;
econmake.FX('30','49') = 0;
econmake.FX('30','50') = 0;
econmake.FX('30','51') = 0;
econmake.FX('30','52') = 0;
econmake.FX('30','53') = 0;
econmake.FX('30','54') = 2.590108e+001;
econmake.FX('30','55') = 0;
econmake.FX('30','56') = 2.590108e+001;
econmake.FX('30','57') = 7.060108e+001;
econmake.FX('30','58') = 0;
econmake.FX('30','59') = 0;
econmake.FX('30','60') = 0;
econmake.FX('30','61') = 0;
econmake.FX('30','62') = 0;
econmake.FX('30','63') = 0;
econmake.FX('30','64') = 0;
econmake.FX('30','65') = 0;
econmake.FX('30','66') = 0;
econmake.FX('30','67') = 0;
econmake.FX('30','68') = 0;
econmake.FX('30','69') = 0;
econmake.FX('30','70') = 0;
econmake.FX('30','71') = 0;
econmake.FX('30','72') = 0;
econmake.FX('30','73') = 0;
econmake.FX('30','74') = 0;
econmake.FX('31','1') = 0;
econmake.FX('31','2') = 0;
econmake.FX('31','3') = 0;
econmake.FX('31','4') = 0;
econmake.FX('31','5') = 0;
econmake.FX('31','6') = 0;
econmake.FX('31','7') = 0;
econmake.FX('31','8') = 0;
econmake.FX('31','9') = 0;
econmake.FX('31','10') = 0;
econmake.FX('31','11') = 0;
econmake.FX('31','12') = 0;
econmake.FX('31','13') = 0;
econmake.FX('31','14') = 0;
econmake.FX('31','15') = 0;
econmake.FX('31','16') = 0;
econmake.FX('31','17') = 1.410000e+001;
econmake.FX('31','18') = 3.560000e+001;
econmake.FX('31','19') = 4.250000e+001;
econmake.FX('31','20') = 3.960000e+001;
econmake.FX('31','21') = 1.049000e+002;
econmake.FX('31','22') = 0;
econmake.FX('31','23') = 0;
econmake.FX('31','24') = 496;
econmake.FX('31','25') = 1.362000e+002;
econmake.FX('31','26') = 7.620000e+001;
econmake.FX('31','27') = 1.269800e+003;
econmake.FX('31','28') = 1.113800e+003;
econmake.FX('31','29') = 3.546300e+003;
econmake.FX('31','30') = 2.497300e+003;
econmake.FX('31','31') = 3.592137e+005;
econmake.FX('31','32') = 3.760900e+003;
econmake.FX('31','33') = 7.590000e+001;
econmake.FX('31','34') = 1.815000e+002;
econmake.FX('31','35') = 1.164900e+003;
econmake.FX('31','36') = 0;
econmake.FX('31','37') = 0;
econmake.FX('31','38') = 0;
econmake.FX('31','39') = 0;
econmake.FX('31','40') = 0;
econmake.FX('31','41') = 0;
econmake.FX('31','42') = 0;
econmake.FX('31','43') = 0;
econmake.FX('31','44') = 0;
econmake.FX('31','45') = 0;
econmake.FX('31','46') = 0;
econmake.FX('31','47') = 0;
econmake.FX('31','48') = 0;
econmake.FX('31','49') = 0;
econmake.FX('31','50') = 0;
econmake.FX('31','51') = 0;
econmake.FX('31','52') = 0;
econmake.FX('31','53') = 0;
econmake.FX('31','54') = 0;
econmake.FX('31','55') = 0;
econmake.FX('31','56') = 0;
econmake.FX('31','57') = 0;
econmake.FX('31','58') = 0;
econmake.FX('31','59') = 0;
econmake.FX('31','60') = 0;
econmake.FX('31','61') = 0;
econmake.FX('31','62') = 0;
econmake.FX('31','63') = 0;
econmake.FX('31','64') = 0;
econmake.FX('31','65') = 0;
econmake.FX('31','66') = 0;
econmake.FX('31','67') = 0;
econmake.FX('31','68') = 0;
econmake.FX('31','69') = 0;
econmake.FX('31','70') = 0;
econmake.FX('31','71') = 0;
econmake.FX('31','72') = 0;
econmake.FX('31','73') = 0;
econmake.FX('31','74') = 0;
econmake.FX('32','1') = 0;
econmake.FX('32','2') = 0;
econmake.FX('32','3') = 0;
econmake.FX('32','4') = 0;
econmake.FX('32','5') = 0;
econmake.FX('32','6') = 0;
econmake.FX('32','7') = 0;
econmake.FX('32','8') = 0;
econmake.FX('32','9') = 0;
econmake.FX('32','10') = 0;
econmake.FX('32','11') = 0;
econmake.FX('32','12') = 0;
econmake.FX('32','13') = 0;
econmake.FX('32','14') = 0;
econmake.FX('32','15') = 6.912680e+001;
econmake.FX('32','16') = 0;
econmake.FX('32','17') = 0;
econmake.FX('32','18') = 0;
econmake.FX('32','19') = 0;
econmake.FX('32','20') = 0;
econmake.FX('32','21') = 4.683545e+001;
econmake.FX('32','22') = 0;
econmake.FX('32','23') = 0;
econmake.FX('32','24') = 7.359286e+001;
econmake.FX('32','25') = 4.203047e+002;
econmake.FX('32','26') = 2.514005e+001;
econmake.FX('32','27') = 4.997638e+002;
econmake.FX('32','28') = 1.190128e+003;
econmake.FX('32','29') = 3.555963e+003;
econmake.FX('32','30') = 1.622585e+001;
econmake.FX('32','31') = 5.349319e+003;
econmake.FX('32','32') = 5.698650e+005;
econmake.FX('32','33') = 4.179169e+002;
econmake.FX('32','34') = 7.401791e+001;
econmake.FX('32','35') = 4.977930e+001;
econmake.FX('32','36') = 0;
econmake.FX('32','37') = 0;
econmake.FX('32','38') = 0;
econmake.FX('32','39') = 0;
econmake.FX('32','40') = 0;
econmake.FX('32','41') = 0;
econmake.FX('32','42') = 0;
econmake.FX('32','43') = 0;
econmake.FX('32','44') = 0;
econmake.FX('32','45') = 0;
econmake.FX('32','46') = 0;
econmake.FX('32','47') = 0;
econmake.FX('32','48') = 0;
econmake.FX('32','49') = 0;
econmake.FX('32','50') = 0;
econmake.FX('32','51') = 0;
econmake.FX('32','52') = 0;
econmake.FX('32','53') = 0;
econmake.FX('32','54') = 0;
econmake.FX('32','55') = 0;
econmake.FX('32','56') = 0;
econmake.FX('32','57') = 0;
econmake.FX('32','58') = 0;
econmake.FX('32','59') = 0;
econmake.FX('32','60') = 0;
econmake.FX('32','61') = 0;
econmake.FX('32','62') = 0;
econmake.FX('32','63') = 0;
econmake.FX('32','64') = 0;
econmake.FX('32','65') = 0;
econmake.FX('32','66') = 0;
econmake.FX('32','67') = 0;
econmake.FX('32','68') = 0;
econmake.FX('32','69') = 0;
econmake.FX('32','70') = 0;
econmake.FX('32','71') = 0;
econmake.FX('32','72') = 0;
econmake.FX('32','73') = 0;
econmake.FX('32','74') = 0;
econmake.FX('33','1') = 0;
econmake.FX('33','2') = 0;
econmake.FX('33','3') = 0;
econmake.FX('33','4') = 0;
econmake.FX('33','5') = 0;
econmake.FX('33','6') = 0;
econmake.FX('33','7') = 0;
econmake.FX('33','8') = 0;
econmake.FX('33','9') = 0;
econmake.FX('33','10') = 0;
econmake.FX('33','11') = 0;
econmake.FX('33','12') = 0;
econmake.FX('33','13') = 0;
econmake.FX('33','14') = 0;
econmake.FX('33','15') = 5.400000e+000;
econmake.FX('33','16') = 0;
econmake.FX('33','17') = 0;
econmake.FX('33','18') = 0;
econmake.FX('33','19') = 0;
econmake.FX('33','20') = 0;
econmake.FX('33','21') = 0;
econmake.FX('33','22') = 0;
econmake.FX('33','23') = 0;
econmake.FX('33','24') = 0;
econmake.FX('33','25') = 7.700844e+001;
econmake.FX('33','26') = 0;
econmake.FX('33','27') = 0;
econmake.FX('33','28') = 8.671305e+001;
econmake.FX('33','29') = 7.459187e+002;
econmake.FX('33','30') = 0;
econmake.FX('33','31') = 5.387696e+002;
econmake.FX('33','32') = 101;
econmake.FX('33','33') = 3.957059e+004;
econmake.FX('33','34') = 0;
econmake.FX('33','35') = 0;
econmake.FX('33','36') = 0;
econmake.FX('33','37') = 0;
econmake.FX('33','38') = 0;
econmake.FX('33','39') = 0;
econmake.FX('33','40') = 0;
econmake.FX('33','41') = 0;
econmake.FX('33','42') = 0;
econmake.FX('33','43') = 0;
econmake.FX('33','44') = 0;
econmake.FX('33','45') = 0;
econmake.FX('33','46') = 0;
econmake.FX('33','47') = 0;
econmake.FX('33','48') = 0;
econmake.FX('33','49') = 0;
econmake.FX('33','50') = 0;
econmake.FX('33','51') = 0;
econmake.FX('33','52') = 0;
econmake.FX('33','53') = 0;
econmake.FX('33','54') = 0;
econmake.FX('33','55') = 0;
econmake.FX('33','56') = 0;
econmake.FX('33','57') = 0;
econmake.FX('33','58') = 0;
econmake.FX('33','59') = 0;
econmake.FX('33','60') = 0;
econmake.FX('33','61') = 0;
econmake.FX('33','62') = 0;
econmake.FX('33','63') = 0;
econmake.FX('33','64') = 0;
econmake.FX('33','65') = 0;
econmake.FX('33','66') = 0;
econmake.FX('33','67') = 0;
econmake.FX('33','68') = 0;
econmake.FX('33','69') = 0;
econmake.FX('33','70') = 0;
econmake.FX('33','71') = 0;
econmake.FX('33','72') = 0;
econmake.FX('33','73') = 0;
econmake.FX('33','74') = 0;
econmake.FX('34','1') = 0;
econmake.FX('34','2') = 0;
econmake.FX('34','3') = 0;
econmake.FX('34','4') = 0;
econmake.FX('34','5') = 0;
econmake.FX('34','6') = 0;
econmake.FX('34','7') = 0;
econmake.FX('34','8') = 0;
econmake.FX('34','9') = 0;
econmake.FX('34','10') = 0;
econmake.FX('34','11') = 0;
econmake.FX('34','12') = 0;
econmake.FX('34','13') = 0;
econmake.FX('34','14') = 0;
econmake.FX('34','15') = 9.420000e+001;
econmake.FX('34','16') = 0;
econmake.FX('34','17') = 5.462000e+002;
econmake.FX('34','18') = 1.213000e+002;
econmake.FX('34','19') = 0;
econmake.FX('34','20') = 0;
econmake.FX('34','21') = 0;
econmake.FX('34','22') = 0;
econmake.FX('34','23') = 0;
econmake.FX('34','24') = 1.095000e+002;
econmake.FX('34','25') = 3.003000e+002;
econmake.FX('34','26') = 2.492000e+002;
econmake.FX('34','27') = 0;
econmake.FX('34','28') = 4.617000e+002;
econmake.FX('34','29') = 2.541000e+002;
econmake.FX('34','30') = 0;
econmake.FX('34','31') = 1.302000e+002;
econmake.FX('34','32') = 8.690000e+001;
econmake.FX('34','33') = 0;
econmake.FX('34','34') = 7.090980e+004;
econmake.FX('34','35') = 7.950000e+001;
econmake.FX('34','36') = 0;
econmake.FX('34','37') = 0;
econmake.FX('34','38') = 0;
econmake.FX('34','39') = 0;
econmake.FX('34','40') = 0;
econmake.FX('34','41') = 0;
econmake.FX('34','42') = 0;
econmake.FX('34','43') = 0;
econmake.FX('34','44') = 0;
econmake.FX('34','45') = 0;
econmake.FX('34','46') = 0;
econmake.FX('34','47') = 0;
econmake.FX('34','48') = 0;
econmake.FX('34','49') = 0;
econmake.FX('34','50') = 0;
econmake.FX('34','51') = 0;
econmake.FX('34','52') = 0;
econmake.FX('34','53') = 0;
econmake.FX('34','54') = 0;
econmake.FX('34','55') = 0;
econmake.FX('34','56') = 0;
econmake.FX('34','57') = 0;
econmake.FX('34','58') = 0;
econmake.FX('34','59') = 0;
econmake.FX('34','60') = 0;
econmake.FX('34','61') = 0;
econmake.FX('34','62') = 0;
econmake.FX('34','63') = 0;
econmake.FX('34','64') = 0;
econmake.FX('34','65') = 0;
econmake.FX('34','66') = 0;
econmake.FX('34','67') = 0;
econmake.FX('34','68') = 0;
econmake.FX('34','69') = 0;
econmake.FX('34','70') = 0;
econmake.FX('34','71') = 0;
econmake.FX('34','72') = 0;
econmake.FX('34','73') = 0;
econmake.FX('34','74') = 0;
econmake.FX('35','1') = 0;
econmake.FX('35','2') = 0;
econmake.FX('35','3') = 0;
econmake.FX('35','4') = 0;
econmake.FX('35','5') = 0;
econmake.FX('35','6') = 0;
econmake.FX('35','7') = 0;
econmake.FX('35','8') = 0;
econmake.FX('35','9') = 0;
econmake.FX('35','10') = 0;
econmake.FX('35','11') = 0;
econmake.FX('35','12') = 0;
econmake.FX('35','13') = 0;
econmake.FX('35','14') = 0;
econmake.FX('35','15') = 1.602000e+002;
econmake.FX('35','16') = 2.660000e+001;
econmake.FX('35','17') = 1.029000e+002;
econmake.FX('35','18') = 1.192000e+002;
econmake.FX('35','19') = 1.873000e+002;
econmake.FX('35','20') = 4.280000e+001;
econmake.FX('35','21') = 4.850000e+001;
econmake.FX('35','22') = 0;
econmake.FX('35','23') = 0;
econmake.FX('35','24') = 7.816000e+002;
econmake.FX('35','25') = 7.281000e+002;
econmake.FX('35','26') = 1.498000e+002;
econmake.FX('35','27') = 2.893000e+002;
econmake.FX('35','28') = 5.583000e+002;
econmake.FX('35','29') = 4.984000e+002;
econmake.FX('35','30') = 0;
econmake.FX('35','31') = 6.704000e+002;
econmake.FX('35','32') = 4.710000e+001;
econmake.FX('35','33') = 1.237000e+002;
econmake.FX('35','34') = 259;
econmake.FX('35','35') = 1.157991e+005;
econmake.FX('35','36') = 0;
econmake.FX('35','37') = 0;
econmake.FX('35','38') = 0;
econmake.FX('35','39') = 0;
econmake.FX('35','40') = 0;
econmake.FX('35','41') = 0;
econmake.FX('35','42') = 0;
econmake.FX('35','43') = 0;
econmake.FX('35','44') = 0;
econmake.FX('35','45') = 0;
econmake.FX('35','46') = 0;
econmake.FX('35','47') = 0;
econmake.FX('35','48') = 0;
econmake.FX('35','49') = 0;
econmake.FX('35','50') = 0;
econmake.FX('35','51') = 0;
econmake.FX('35','52') = 0;
econmake.FX('35','53') = 0;
econmake.FX('35','54') = 0;
econmake.FX('35','55') = 0;
econmake.FX('35','56') = 0;
econmake.FX('35','57') = 2954;
econmake.FX('35','58') = 0;
econmake.FX('35','59') = 0;
econmake.FX('35','60') = 0;
econmake.FX('35','61') = 0;
econmake.FX('35','62') = 0;
econmake.FX('35','63') = 0;
econmake.FX('35','64') = 0;
econmake.FX('35','65') = 0;
econmake.FX('35','66') = 0;
econmake.FX('35','67') = 0;
econmake.FX('35','68') = 0;
econmake.FX('35','69') = 0;
econmake.FX('35','70') = 0;
econmake.FX('35','71') = 0;
econmake.FX('35','72') = 0;
econmake.FX('35','73') = 0;
econmake.FX('35','74') = 0;
econmake.FX('36','1') = 0;
econmake.FX('36','2') = 0;
econmake.FX('36','3') = 0;
econmake.FX('36','4') = 0;
econmake.FX('36','5') = 0;
econmake.FX('36','6') = 0;
econmake.FX('36','7') = 0;
econmake.FX('36','8') = 0;
econmake.FX('36','9') = 0;
econmake.FX('36','10') = 0;
econmake.FX('36','11') = 0;
econmake.FX('36','12') = 0;
econmake.FX('36','13') = 0;
econmake.FX('36','14') = 0;
econmake.FX('36','15') = 0;
econmake.FX('36','16') = 0;
econmake.FX('36','17') = 0;
econmake.FX('36','18') = 0;
econmake.FX('36','19') = 0;
econmake.FX('36','20') = 0;
econmake.FX('36','21') = 0;
econmake.FX('36','22') = 0;
econmake.FX('36','23') = 0;
econmake.FX('36','24') = 0;
econmake.FX('36','25') = 0;
econmake.FX('36','26') = 0;
econmake.FX('36','27') = 0;
econmake.FX('36','28') = 0;
econmake.FX('36','29') = 0;
econmake.FX('36','30') = 0;
econmake.FX('36','31') = 0;
econmake.FX('36','32') = 0;
econmake.FX('36','33') = 0;
econmake.FX('36','34') = 0;
econmake.FX('36','35') = 0;
econmake.FX('36','36') = 1.776848e+006;
econmake.FX('36','37') = 0;
econmake.FX('36','38') = 0;
econmake.FX('36','39') = 0;
econmake.FX('36','40') = 0;
econmake.FX('36','41') = 0;
econmake.FX('36','42') = 0;
econmake.FX('36','43') = 0;
econmake.FX('36','44') = 0;
econmake.FX('36','45') = 0;
econmake.FX('36','46') = 0;
econmake.FX('36','47') = 0;
econmake.FX('36','48') = 0;
econmake.FX('36','49') = 0;
econmake.FX('36','50') = 0;
econmake.FX('36','51') = 0;
econmake.FX('36','52') = 0;
econmake.FX('36','53') = 0;
econmake.FX('36','54') = 0;
econmake.FX('36','55') = 0;
econmake.FX('36','56') = 0;
econmake.FX('36','57') = 0;
econmake.FX('36','58') = 0;
econmake.FX('36','59') = 0;
econmake.FX('36','60') = 0;
econmake.FX('36','61') = 0;
econmake.FX('36','62') = 0;
econmake.FX('36','63') = 0;
econmake.FX('36','64') = 0;
econmake.FX('36','65') = 0;
econmake.FX('36','66') = 0;
econmake.FX('36','67') = 0;
econmake.FX('36','68') = 0;
econmake.FX('36','69') = 0;
econmake.FX('36','70') = 0;
econmake.FX('36','71') = 0;
econmake.FX('36','72') = 0;
econmake.FX('36','73') = 0;
econmake.FX('36','74') = 0;
econmake.FX('37','1') = 0;
econmake.FX('37','2') = 0;
econmake.FX('37','3') = 0;
econmake.FX('37','4') = 0;
econmake.FX('37','5') = 0;
econmake.FX('37','6') = 0;
econmake.FX('37','7') = 0;
econmake.FX('37','8') = 0;
econmake.FX('37','9') = 0;
econmake.FX('37','10') = 0;
econmake.FX('37','11') = 0;
econmake.FX('37','12') = 0;
econmake.FX('37','13') = 0;
econmake.FX('37','14') = 0;
econmake.FX('37','15') = 0;
econmake.FX('37','16') = 0;
econmake.FX('37','17') = 0;
econmake.FX('37','18') = 0;
econmake.FX('37','19') = 0;
econmake.FX('37','20') = 0;
econmake.FX('37','21') = 0;
econmake.FX('37','22') = 0;
econmake.FX('37','23') = 0;
econmake.FX('37','24') = 0;
econmake.FX('37','25') = 0;
econmake.FX('37','26') = 0;
econmake.FX('37','27') = 0;
econmake.FX('37','28') = 0;
econmake.FX('37','29') = 0;
econmake.FX('37','30') = 0;
econmake.FX('37','31') = 0;
econmake.FX('37','32') = 0;
econmake.FX('37','33') = 0;
econmake.FX('37','34') = 0;
econmake.FX('37','35') = 0;
econmake.FX('37','36') = 0;
econmake.FX('37','37') = 9.861190e+004;
econmake.FX('37','38') = 0;
econmake.FX('37','39') = 0;
econmake.FX('37','40') = 0;
econmake.FX('37','41') = 0;
econmake.FX('37','42') = 0;
econmake.FX('37','43') = 0;
econmake.FX('37','44') = 0;
econmake.FX('37','45') = 0;
econmake.FX('37','46') = 0;
econmake.FX('37','47') = 0;
econmake.FX('37','48') = 0;
econmake.FX('37','49') = 0;
econmake.FX('37','50') = 0;
econmake.FX('37','51') = 0;
econmake.FX('37','52') = 0;
econmake.FX('37','53') = 0;
econmake.FX('37','54') = 0;
econmake.FX('37','55') = 0;
econmake.FX('37','56') = 0;
econmake.FX('37','57') = 0;
econmake.FX('37','58') = 0;
econmake.FX('37','59') = 0;
econmake.FX('37','60') = 0;
econmake.FX('37','61') = 0;
econmake.FX('37','62') = 0;
econmake.FX('37','63') = 0;
econmake.FX('37','64') = 0;
econmake.FX('37','65') = 0;
econmake.FX('37','66') = 0;
econmake.FX('37','67') = 0;
econmake.FX('37','68') = 0;
econmake.FX('37','69') = 0;
econmake.FX('37','70') = 0;
econmake.FX('37','71') = 0;
econmake.FX('37','72') = 0;
econmake.FX('37','73') = 0;
econmake.FX('37','74') = 0;
econmake.FX('38','1') = 0;
econmake.FX('38','2') = 0;
econmake.FX('38','3') = 0;
econmake.FX('38','4') = 0;
econmake.FX('38','5') = 0;
econmake.FX('38','6') = 0;
econmake.FX('38','7') = 0;
econmake.FX('38','8') = 0;
econmake.FX('38','9') = 0;
econmake.FX('38','10') = 0;
econmake.FX('38','11') = 0;
econmake.FX('38','12') = 0;
econmake.FX('38','13') = 0;
econmake.FX('38','14') = 0;
econmake.FX('38','15') = 0;
econmake.FX('38','16') = 0;
econmake.FX('38','17') = 0;
econmake.FX('38','18') = 0;
econmake.FX('38','19') = 0;
econmake.FX('38','20') = 0;
econmake.FX('38','21') = 0;
econmake.FX('38','22') = 0;
econmake.FX('38','23') = 0;
econmake.FX('38','24') = 0;
econmake.FX('38','25') = 0;
econmake.FX('38','26') = 0;
econmake.FX('38','27') = 0;
econmake.FX('38','28') = 0;
econmake.FX('38','29') = 0;
econmake.FX('38','30') = 0;
econmake.FX('38','31') = 0;
econmake.FX('38','32') = 0;
econmake.FX('38','33') = 0;
econmake.FX('38','34') = 0;
econmake.FX('38','35') = 0;
econmake.FX('38','36') = 0;
econmake.FX('38','37') = 0;
econmake.FX('38','38') = 4.053670e+004;
econmake.FX('38','39') = 0;
econmake.FX('38','40') = 0;
econmake.FX('38','41') = 0;
econmake.FX('38','42') = 0;
econmake.FX('38','43') = 0;
econmake.FX('38','44') = 0;
econmake.FX('38','45') = 0;
econmake.FX('38','46') = 0;
econmake.FX('38','47') = 0;
econmake.FX('38','48') = 0;
econmake.FX('38','49') = 0;
econmake.FX('38','50') = 0;
econmake.FX('38','51') = 0;
econmake.FX('38','52') = 0;
econmake.FX('38','53') = 0;
econmake.FX('38','54') = 0;
econmake.FX('38','55') = 0;
econmake.FX('38','56') = 0;
econmake.FX('38','57') = 0;
econmake.FX('38','58') = 0;
econmake.FX('38','59') = 0;
econmake.FX('38','60') = 0;
econmake.FX('38','61') = 0;
econmake.FX('38','62') = 0;
econmake.FX('38','63') = 0;
econmake.FX('38','64') = 0;
econmake.FX('38','65') = 0;
econmake.FX('38','66') = 0;
econmake.FX('38','67') = 0;
econmake.FX('38','68') = 0;
econmake.FX('38','69') = 0;
econmake.FX('38','70') = 0;
econmake.FX('38','71') = 0;
econmake.FX('38','72') = 0;
econmake.FX('38','73') = 0;
econmake.FX('38','74') = 0;
econmake.FX('39','1') = 0;
econmake.FX('39','2') = 0;
econmake.FX('39','3') = 0;
econmake.FX('39','4') = 0;
econmake.FX('39','5') = 0;
econmake.FX('39','6') = 0;
econmake.FX('39','7') = 0;
econmake.FX('39','8') = 0;
econmake.FX('39','9') = 0;
econmake.FX('39','10') = 0;
econmake.FX('39','11') = 0;
econmake.FX('39','12') = 0;
econmake.FX('39','13') = 0;
econmake.FX('39','14') = 0;
econmake.FX('39','15') = 0;
econmake.FX('39','16') = 0;
econmake.FX('39','17') = 0;
econmake.FX('39','18') = 0;
econmake.FX('39','19') = 0;
econmake.FX('39','20') = 0;
econmake.FX('39','21') = 0;
econmake.FX('39','22') = 0;
econmake.FX('39','23') = 0;
econmake.FX('39','24') = 0;
econmake.FX('39','25') = 0;
econmake.FX('39','26') = 0;
econmake.FX('39','27') = 0;
econmake.FX('39','28') = 0;
econmake.FX('39','29') = 0;
econmake.FX('39','30') = 0;
econmake.FX('39','31') = 0;
econmake.FX('39','32') = 0;
econmake.FX('39','33') = 0;
econmake.FX('39','34') = 0;
econmake.FX('39','35') = 0;
econmake.FX('39','36') = 0;
econmake.FX('39','37') = 0;
econmake.FX('39','38') = 0;
econmake.FX('39','39') = 2.637750e+004;
econmake.FX('39','40') = 0;
econmake.FX('39','41') = 0;
econmake.FX('39','42') = 0;
econmake.FX('39','43') = 11;
econmake.FX('39','44') = 0;
econmake.FX('39','45') = 0;
econmake.FX('39','46') = 0;
econmake.FX('39','47') = 0;
econmake.FX('39','48') = 0;
econmake.FX('39','49') = 0;
econmake.FX('39','50') = 0;
econmake.FX('39','51') = 0;
econmake.FX('39','52') = 0;
econmake.FX('39','53') = 0;
econmake.FX('39','54') = 0;
econmake.FX('39','55') = 0;
econmake.FX('39','56') = 0;
econmake.FX('39','57') = 0;
econmake.FX('39','58') = 0;
econmake.FX('39','59') = 0;
econmake.FX('39','60') = 0;
econmake.FX('39','61') = 0;
econmake.FX('39','62') = 0;
econmake.FX('39','63') = 0;
econmake.FX('39','64') = 0;
econmake.FX('39','65') = 0;
econmake.FX('39','66') = 0;
econmake.FX('39','67') = 0;
econmake.FX('39','68') = 0;
econmake.FX('39','69') = 0;
econmake.FX('39','70') = 0;
econmake.FX('39','71') = 0;
econmake.FX('39','72') = 0;
econmake.FX('39','73') = 0;
econmake.FX('39','74') = 0;
econmake.FX('40','1') = 0;
econmake.FX('40','2') = 0;
econmake.FX('40','3') = 0;
econmake.FX('40','4') = 0;
econmake.FX('40','5') = 0;
econmake.FX('40','6') = 0;
econmake.FX('40','7') = 0;
econmake.FX('40','8') = 0;
econmake.FX('40','9') = 0;
econmake.FX('40','10') = 0;
econmake.FX('40','11') = 0;
econmake.FX('40','12') = 0;
econmake.FX('40','13') = 0;
econmake.FX('40','14') = 0;
econmake.FX('40','15') = 0;
econmake.FX('40','16') = 0;
econmake.FX('40','17') = 0;
econmake.FX('40','18') = 0;
econmake.FX('40','19') = 0;
econmake.FX('40','20') = 0;
econmake.FX('40','21') = 0;
econmake.FX('40','22') = 0;
econmake.FX('40','23') = 0;
econmake.FX('40','24') = 0;
econmake.FX('40','25') = 0;
econmake.FX('40','26') = 0;
econmake.FX('40','27') = 0;
econmake.FX('40','28') = 0;
econmake.FX('40','29') = 0;
econmake.FX('40','30') = 0;
econmake.FX('40','31') = 0;
econmake.FX('40','32') = 0;
econmake.FX('40','33') = 0;
econmake.FX('40','34') = 0;
econmake.FX('40','35') = 0;
econmake.FX('40','36') = 0;
econmake.FX('40','37') = 0;
econmake.FX('40','38') = 0;
econmake.FX('40','39') = 0;
econmake.FX('40','40') = 2.034277e+005;
econmake.FX('40','41') = 0;
econmake.FX('40','42') = 0;
econmake.FX('40','43') = 1.167000e+002;
econmake.FX('40','44') = 0;
econmake.FX('40','45') = 0;
econmake.FX('40','46') = 0;
econmake.FX('40','47') = 0;
econmake.FX('40','48') = 0;
econmake.FX('40','49') = 0;
econmake.FX('40','50') = 0;
econmake.FX('40','51') = 0;
econmake.FX('40','52') = 0;
econmake.FX('40','53') = 0;
econmake.FX('40','54') = 0;
econmake.FX('40','55') = 0;
econmake.FX('40','56') = 0;
econmake.FX('40','57') = 0;
econmake.FX('40','58') = 0;
econmake.FX('40','59') = 0;
econmake.FX('40','60') = 5.110000e+001;
econmake.FX('40','61') = 0;
econmake.FX('40','62') = 0;
econmake.FX('40','63') = 0;
econmake.FX('40','64') = 0;
econmake.FX('40','65') = 0;
econmake.FX('40','66') = 0;
econmake.FX('40','67') = 0;
econmake.FX('40','68') = 0;
econmake.FX('40','69') = 0;
econmake.FX('40','70') = 0;
econmake.FX('40','71') = 0;
econmake.FX('40','72') = 0;
econmake.FX('40','73') = 0;
econmake.FX('40','74') = 0;
econmake.FX('41','1') = 0;
econmake.FX('41','2') = 0;
econmake.FX('41','3') = 0;
econmake.FX('41','4') = 0;
econmake.FX('41','5') = 0;
econmake.FX('41','6') = 0;
econmake.FX('41','7') = 0;
econmake.FX('41','8') = 0;
econmake.FX('41','9') = 0;
econmake.FX('41','10') = 0;
econmake.FX('41','11') = 0;
econmake.FX('41','12') = 0;
econmake.FX('41','13') = 0;
econmake.FX('41','14') = 0;
econmake.FX('41','15') = 0;
econmake.FX('41','16') = 0;
econmake.FX('41','17') = 0;
econmake.FX('41','18') = 0;
econmake.FX('41','19') = 0;
econmake.FX('41','20') = 0;
econmake.FX('41','21') = 0;
econmake.FX('41','22') = 0;
econmake.FX('41','23') = 0;
econmake.FX('41','24') = 0;
econmake.FX('41','25') = 0;
econmake.FX('41','26') = 0;
econmake.FX('41','27') = 0;
econmake.FX('41','28') = 0;
econmake.FX('41','29') = 0;
econmake.FX('41','30') = 0;
econmake.FX('41','31') = 0;
econmake.FX('41','32') = 0;
econmake.FX('41','33') = 0;
econmake.FX('41','34') = 0;
econmake.FX('41','35') = 0;
econmake.FX('41','36') = 0;
econmake.FX('41','37') = 0;
econmake.FX('41','38') = 0;
econmake.FX('41','39') = 0;
econmake.FX('41','40') = 0;
econmake.FX('41','41') = 3.129710e+004;
econmake.FX('41','42') = 0;
econmake.FX('41','43') = 1.282000e+002;
econmake.FX('41','44') = 0;
econmake.FX('41','45') = 0;
econmake.FX('41','46') = 0;
econmake.FX('41','47') = 0;
econmake.FX('41','48') = 0;
econmake.FX('41','49') = 0;
econmake.FX('41','50') = 0;
econmake.FX('41','51') = 0;
econmake.FX('41','52') = 0;
econmake.FX('41','53') = 0;
econmake.FX('41','54') = 0;
econmake.FX('41','55') = 0;
econmake.FX('41','56') = 0;
econmake.FX('41','57') = 0;
econmake.FX('41','58') = 0;
econmake.FX('41','59') = 0;
econmake.FX('41','60') = 0;
econmake.FX('41','61') = 0;
econmake.FX('41','62') = 0;
econmake.FX('41','63') = 0;
econmake.FX('41','64') = 0;
econmake.FX('41','65') = 0;
econmake.FX('41','66') = 0;
econmake.FX('41','67') = 0;
econmake.FX('41','68') = 0;
econmake.FX('41','69') = 0;
econmake.FX('41','70') = 0;
econmake.FX('41','71') = 0;
econmake.FX('41','72') = 0;
econmake.FX('41','73') = 0;
econmake.FX('41','74') = 0;
econmake.FX('42','1') = 0;
econmake.FX('42','2') = 0;
econmake.FX('42','3') = 0;
econmake.FX('42','4') = 0;
econmake.FX('42','5') = 0;
econmake.FX('42','6') = 0;
econmake.FX('42','7') = 0;
econmake.FX('42','8') = 0;
econmake.FX('42','9') = 0;
econmake.FX('42','10') = 0;
econmake.FX('42','11') = 0;
econmake.FX('42','12') = 0;
econmake.FX('42','13') = 0;
econmake.FX('42','14') = 0;
econmake.FX('42','15') = 0;
econmake.FX('42','16') = 0;
econmake.FX('42','17') = 0;
econmake.FX('42','18') = 0;
econmake.FX('42','19') = 0;
econmake.FX('42','20') = 0;
econmake.FX('42','21') = 0;
econmake.FX('42','22') = 0;
econmake.FX('42','23') = 0;
econmake.FX('42','24') = 0;
econmake.FX('42','25') = 0;
econmake.FX('42','26') = 0;
econmake.FX('42','27') = 0;
econmake.FX('42','28') = 0;
econmake.FX('42','29') = 0;
econmake.FX('42','30') = 0;
econmake.FX('42','31') = 0;
econmake.FX('42','32') = 0;
econmake.FX('42','33') = 0;
econmake.FX('42','34') = 0;
econmake.FX('42','35') = 0;
econmake.FX('42','36') = 0;
econmake.FX('42','37') = 0;
econmake.FX('42','38') = 0;
econmake.FX('42','39') = 0;
econmake.FX('42','40') = 0;
econmake.FX('42','41') = 0;
econmake.FX('42','42') = 2.231580e+004;
econmake.FX('42','43') = 0;
econmake.FX('42','44') = 0;
econmake.FX('42','45') = 0;
econmake.FX('42','46') = 0;
econmake.FX('42','47') = 0;
econmake.FX('42','48') = 0;
econmake.FX('42','49') = 0;
econmake.FX('42','50') = 0;
econmake.FX('42','51') = 0;
econmake.FX('42','52') = 0;
econmake.FX('42','53') = 0;
econmake.FX('42','54') = 0;
econmake.FX('42','55') = 0;
econmake.FX('42','56') = 0;
econmake.FX('42','57') = 0;
econmake.FX('42','58') = 0;
econmake.FX('42','59') = 0;
econmake.FX('42','60') = 0;
econmake.FX('42','61') = 0;
econmake.FX('42','62') = 0;
econmake.FX('42','63') = 0;
econmake.FX('42','64') = 0;
econmake.FX('42','65') = 0;
econmake.FX('42','66') = 0;
econmake.FX('42','67') = 0;
econmake.FX('42','68') = 0;
econmake.FX('42','69') = 0;
econmake.FX('42','70') = 0;
econmake.FX('42','71') = 0;
econmake.FX('42','72') = 0;
econmake.FX('42','73') = 0;
econmake.FX('42','74') = 0;
econmake.FX('43','1') = 0;
econmake.FX('43','2') = 0;
econmake.FX('43','3') = 0;
econmake.FX('43','4') = 0;
econmake.FX('43','5') = 0;
econmake.FX('43','6') = 0;
econmake.FX('43','7') = 0;
econmake.FX('43','8') = 0;
econmake.FX('43','9') = 0;
econmake.FX('43','10') = 0;
econmake.FX('43','11') = 0;
econmake.FX('43','12') = 0;
econmake.FX('43','13') = 0;
econmake.FX('43','14') = 0;
econmake.FX('43','15') = 0;
econmake.FX('43','16') = 0;
econmake.FX('43','17') = 0;
econmake.FX('43','18') = 0;
econmake.FX('43','19') = 0;
econmake.FX('43','20') = 0;
econmake.FX('43','21') = 0;
econmake.FX('43','22') = 0;
econmake.FX('43','23') = 0;
econmake.FX('43','24') = 0;
econmake.FX('43','25') = 0;
econmake.FX('43','26') = 0;
econmake.FX('43','27') = 0;
econmake.FX('43','28') = 0;
econmake.FX('43','29') = 0;
econmake.FX('43','30') = 0;
econmake.FX('43','31') = 0;
econmake.FX('43','32') = 0;
econmake.FX('43','33') = 0;
econmake.FX('43','34') = 0;
econmake.FX('43','35') = 0;
econmake.FX('43','36') = 0;
econmake.FX('43','37') = 3.756900e+003;
econmake.FX('43','38') = 1.667500e+003;
econmake.FX('43','39') = 9.411000e+002;
econmake.FX('43','40') = 8.697100e+003;
econmake.FX('43','41') = 35;
econmake.FX('43','42') = 0;
econmake.FX('43','43') = 1.102096e+005;
econmake.FX('43','44') = 1.347000e+002;
econmake.FX('43','45') = 0;
econmake.FX('43','46') = 0;
econmake.FX('43','47') = 0;
econmake.FX('43','48') = 0;
econmake.FX('43','49') = 0;
econmake.FX('43','50') = 0;
econmake.FX('43','51') = 0;
econmake.FX('43','52') = 0;
econmake.FX('43','53') = 0;
econmake.FX('43','54') = 0;
econmake.FX('43','55') = 0;
econmake.FX('43','56') = 0;
econmake.FX('43','57') = 0;
econmake.FX('43','58') = 0;
econmake.FX('43','59') = 0;
econmake.FX('43','60') = 0;
econmake.FX('43','61') = 0;
econmake.FX('43','62') = 0;
econmake.FX('43','63') = 0;
econmake.FX('43','64') = 0;
econmake.FX('43','65') = 0;
econmake.FX('43','66') = 0;
econmake.FX('43','67') = 0;
econmake.FX('43','68') = 0;
econmake.FX('43','69') = 0;
econmake.FX('43','70') = 0;
econmake.FX('43','71') = 0;
econmake.FX('43','72') = 0;
econmake.FX('43','73') = 0;
econmake.FX('43','74') = 0;
econmake.FX('44','1') = 0;
econmake.FX('44','2') = 0;
econmake.FX('44','3') = 0;
econmake.FX('44','4') = 0;
econmake.FX('44','5') = 0;
econmake.FX('44','6') = 0;
econmake.FX('44','7') = 0;
econmake.FX('44','8') = 0;
econmake.FX('44','9') = 0;
econmake.FX('44','10') = 0;
econmake.FX('44','11') = 0;
econmake.FX('44','12') = 0;
econmake.FX('44','13') = 0;
econmake.FX('44','14') = 0;
econmake.FX('44','15') = 0;
econmake.FX('44','16') = 0;
econmake.FX('44','17') = 0;
econmake.FX('44','18') = 0;
econmake.FX('44','19') = 0;
econmake.FX('44','20') = 0;
econmake.FX('44','21') = 0;
econmake.FX('44','22') = 0;
econmake.FX('44','23') = 0;
econmake.FX('44','24') = 0;
econmake.FX('44','25') = 0;
econmake.FX('44','26') = 0;
econmake.FX('44','27') = 0;
econmake.FX('44','28') = 0;
econmake.FX('44','29') = 0;
econmake.FX('44','30') = 0;
econmake.FX('44','31') = 0;
econmake.FX('44','32') = 0;
econmake.FX('44','33') = 0;
econmake.FX('44','34') = 0;
econmake.FX('44','35') = 0;
econmake.FX('44','36') = 0;
econmake.FX('44','37') = 0;
econmake.FX('44','38') = 0;
econmake.FX('44','39') = 0;
econmake.FX('44','40') = 0;
econmake.FX('44','41') = 0;
econmake.FX('44','42') = 0;
econmake.FX('44','43') = 0;
econmake.FX('44','44') = 4.256330e+004;
econmake.FX('44','45') = 0;
econmake.FX('44','46') = 0;
econmake.FX('44','47') = 0;
econmake.FX('44','48') = 0;
econmake.FX('44','49') = 0;
econmake.FX('44','50') = 0;
econmake.FX('44','51') = 0;
econmake.FX('44','52') = 0;
econmake.FX('44','53') = 0;
econmake.FX('44','54') = 0;
econmake.FX('44','55') = 0;
econmake.FX('44','56') = 0;
econmake.FX('44','57') = 0;
econmake.FX('44','58') = 0;
econmake.FX('44','59') = 0;
econmake.FX('44','60') = 0;
econmake.FX('44','61') = 0;
econmake.FX('44','62') = 0;
econmake.FX('44','63') = 0;
econmake.FX('44','64') = 0;
econmake.FX('44','65') = 0;
econmake.FX('44','66') = 0;
econmake.FX('44','67') = 0;
econmake.FX('44','68') = 0;
econmake.FX('44','69') = 0;
econmake.FX('44','70') = 0;
econmake.FX('44','71') = 0;
econmake.FX('44','72') = 0;
econmake.FX('44','73') = 0;
econmake.FX('44','74') = 0;
econmake.FX('45','1') = 0;
econmake.FX('45','2') = 0;
econmake.FX('45','3') = 0;
econmake.FX('45','4') = 0;
econmake.FX('45','5') = 0;
econmake.FX('45','6') = 0;
econmake.FX('45','7') = 0;
econmake.FX('45','8') = 0;
econmake.FX('45','9') = 0;
econmake.FX('45','10') = 0;
econmake.FX('45','11') = 0;
econmake.FX('45','12') = 0;
econmake.FX('45','13') = 0;
econmake.FX('45','14') = 0;
econmake.FX('45','15') = 0;
econmake.FX('45','16') = 0;
econmake.FX('45','17') = 0;
econmake.FX('45','18') = 0;
econmake.FX('45','19') = 0;
econmake.FX('45','20') = 0;
econmake.FX('45','21') = 0;
econmake.FX('45','22') = 0;
econmake.FX('45','23') = 0;
econmake.FX('45','24') = 0;
econmake.FX('45','25') = 0;
econmake.FX('45','26') = 0;
econmake.FX('45','27') = 0;
econmake.FX('45','28') = 0;
econmake.FX('45','29') = 0;
econmake.FX('45','30') = 0;
econmake.FX('45','31') = 0;
econmake.FX('45','32') = 0;
econmake.FX('45','33') = 0;
econmake.FX('45','34') = 0;
econmake.FX('45','35') = 0;
econmake.FX('45','36') = 0;
econmake.FX('45','37') = 0;
econmake.FX('45','38') = 0;
econmake.FX('45','39') = 0;
econmake.FX('45','40') = 0;
econmake.FX('45','41') = 0;
econmake.FX('45','42') = 0;
econmake.FX('45','43') = 0;
econmake.FX('45','44') = 0;
econmake.FX('45','45') = 1.642401e+005;
econmake.FX('45','46') = 1.220000e+001;
econmake.FX('45','47') = 0;
econmake.FX('45','48') = 1.505700e+003;
econmake.FX('45','49') = 0;
econmake.FX('45','50') = 0;
econmake.FX('45','51') = 0;
econmake.FX('45','52') = 0;
econmake.FX('45','53') = 0;
econmake.FX('45','54') = 3.830000e+001;
econmake.FX('45','55') = 0;
econmake.FX('45','56') = 0;
econmake.FX('45','57') = 7.671580e+004;
econmake.FX('45','58') = 0;
econmake.FX('45','59') = 7.025000e+002;
econmake.FX('45','60') = 0;
econmake.FX('45','61') = 7.446000e+002;
econmake.FX('45','62') = 0;
econmake.FX('45','63') = 0;
econmake.FX('45','64') = 0;
econmake.FX('45','65') = 0;
econmake.FX('45','66') = 0;
econmake.FX('45','67') = 0;
econmake.FX('45','68') = 0;
econmake.FX('45','69') = 0;
econmake.FX('45','70') = 0;
econmake.FX('45','71') = 0;
econmake.FX('45','72') = 0;
econmake.FX('45','73') = 0;
econmake.FX('45','74') = 0;
econmake.FX('46','1') = 0;
econmake.FX('46','2') = 0;
econmake.FX('46','3') = 0;
econmake.FX('46','4') = 0;
econmake.FX('46','5') = 0;
econmake.FX('46','6') = 0;
econmake.FX('46','7') = 0;
econmake.FX('46','8') = 0;
econmake.FX('46','9') = 0;
econmake.FX('46','10') = 0;
econmake.FX('46','11') = 0;
econmake.FX('46','12') = 0;
econmake.FX('46','13') = 0;
econmake.FX('46','14') = 0;
econmake.FX('46','15') = 0;
econmake.FX('46','16') = 0;
econmake.FX('46','17') = 0;
econmake.FX('46','18') = 0;
econmake.FX('46','19') = 0;
econmake.FX('46','20') = 0;
econmake.FX('46','21') = 0;
econmake.FX('46','22') = 0;
econmake.FX('46','23') = 0;
econmake.FX('46','24') = 0;
econmake.FX('46','25') = 0;
econmake.FX('46','26') = 0;
econmake.FX('46','27') = 0;
econmake.FX('46','28') = 0;
econmake.FX('46','29') = 0;
econmake.FX('46','30') = 0;
econmake.FX('46','31') = 0;
econmake.FX('46','32') = 0;
econmake.FX('46','33') = 0;
econmake.FX('46','34') = 0;
econmake.FX('46','35') = 0;
econmake.FX('46','36') = 0;
econmake.FX('46','37') = 0;
econmake.FX('46','38') = 0;
econmake.FX('46','39') = 0;
econmake.FX('46','40') = 0;
econmake.FX('46','41') = 0;
econmake.FX('46','42') = 0;
econmake.FX('46','43') = 0;
econmake.FX('46','44') = 0;
econmake.FX('46','45') = 0;
econmake.FX('46','46') = 8.394880e+004;
econmake.FX('46','47') = 0;
econmake.FX('46','48') = 0;
econmake.FX('46','49') = 0;
econmake.FX('46','50') = 0;
econmake.FX('46','51') = 0;
econmake.FX('46','52') = 0;
econmake.FX('46','53') = 0;
econmake.FX('46','54') = 0;
econmake.FX('46','55') = 0;
econmake.FX('46','56') = 0;
econmake.FX('46','57') = 1.424000e+002;
econmake.FX('46','58') = 0;
econmake.FX('46','59') = 0;
econmake.FX('46','60') = 0;
econmake.FX('46','61') = 0;
econmake.FX('46','62') = 0;
econmake.FX('46','63') = 0;
econmake.FX('46','64') = 0;
econmake.FX('46','65') = 0;
econmake.FX('46','66') = 0;
econmake.FX('46','67') = 8.460000e+001;
econmake.FX('46','68') = 0;
econmake.FX('46','69') = 0;
econmake.FX('46','70') = 0;
econmake.FX('46','71') = 0;
econmake.FX('46','72') = 0;
econmake.FX('46','73') = 0;
econmake.FX('46','74') = 0;
econmake.FX('47','1') = 0;
econmake.FX('47','2') = 0;
econmake.FX('47','3') = 0;
econmake.FX('47','4') = 0;
econmake.FX('47','5') = 0;
econmake.FX('47','6') = 0;
econmake.FX('47','7') = 0;
econmake.FX('47','8') = 0;
econmake.FX('47','9') = 0;
econmake.FX('47','10') = 0;
econmake.FX('47','11') = 0;
econmake.FX('47','12') = 0;
econmake.FX('47','13') = 0;
econmake.FX('47','14') = 0;
econmake.FX('47','15') = 0;
econmake.FX('47','16') = 0;
econmake.FX('47','17') = 0;
econmake.FX('47','18') = 0;
econmake.FX('47','19') = 0;
econmake.FX('47','20') = 0;
econmake.FX('47','21') = 0;
econmake.FX('47','22') = 0;
econmake.FX('47','23') = 0;
econmake.FX('47','24') = 0;
econmake.FX('47','25') = 0;
econmake.FX('47','26') = 0;
econmake.FX('47','27') = 0;
econmake.FX('47','28') = 0;
econmake.FX('47','29') = 0;
econmake.FX('47','30') = 0;
econmake.FX('47','31') = 0;
econmake.FX('47','32') = 0;
econmake.FX('47','33') = 0;
econmake.FX('47','34') = 0;
econmake.FX('47','35') = 0;
econmake.FX('47','36') = 0;
econmake.FX('47','37') = 0;
econmake.FX('47','38') = 0;
econmake.FX('47','39') = 0;
econmake.FX('47','40') = 0;
econmake.FX('47','41') = 0;
econmake.FX('47','42') = 0;
econmake.FX('47','43') = 0;
econmake.FX('47','44') = 0;
econmake.FX('47','45') = 0;
econmake.FX('47','46') = 0;
econmake.FX('47','47') = 4.304619e+005;
econmake.FX('47','48') = 1.660480e+004;
econmake.FX('47','49') = 0;
econmake.FX('47','50') = 0;
econmake.FX('47','51') = 0;
econmake.FX('47','52') = 0;
econmake.FX('47','53') = 0;
econmake.FX('47','54') = 9.723000e+002;
econmake.FX('47','55') = 0;
econmake.FX('47','56') = 9.723000e+002;
econmake.FX('47','57') = 6.062880e+004;
econmake.FX('47','58') = 0;
econmake.FX('47','59') = 0;
econmake.FX('47','60') = 0;
econmake.FX('47','61') = 0;
econmake.FX('47','62') = 0;
econmake.FX('47','63') = 0;
econmake.FX('47','64') = 0;
econmake.FX('47','65') = 0;
econmake.FX('47','66') = 0;
econmake.FX('47','67') = 0;
econmake.FX('47','68') = 0;
econmake.FX('47','69') = 0;
econmake.FX('47','70') = 1.360000e+001;
econmake.FX('47','71') = 0;
econmake.FX('47','72') = 0;
econmake.FX('47','73') = 0;
econmake.FX('47','74') = 0;
econmake.FX('48','1') = 0;
econmake.FX('48','2') = 0;
econmake.FX('48','3') = 0;
econmake.FX('48','4') = 0;
econmake.FX('48','5') = 0;
econmake.FX('48','6') = 0;
econmake.FX('48','7') = 0;
econmake.FX('48','8') = 0;
econmake.FX('48','9') = 0;
econmake.FX('48','10') = 0;
econmake.FX('48','11') = 0;
econmake.FX('48','12') = 0;
econmake.FX('48','13') = 0;
econmake.FX('48','14') = 0;
econmake.FX('48','15') = 0;
econmake.FX('48','16') = 0;
econmake.FX('48','17') = 0;
econmake.FX('48','18') = 0;
econmake.FX('48','19') = 0;
econmake.FX('48','20') = 0;
econmake.FX('48','21') = 0;
econmake.FX('48','22') = 0;
econmake.FX('48','23') = 0;
econmake.FX('48','24') = 0;
econmake.FX('48','25') = 0;
econmake.FX('48','26') = 0;
econmake.FX('48','27') = 0;
econmake.FX('48','28') = 0;
econmake.FX('48','29') = 0;
econmake.FX('48','30') = 0;
econmake.FX('48','31') = 0;
econmake.FX('48','32') = 0;
econmake.FX('48','33') = 0;
econmake.FX('48','34') = 0;
econmake.FX('48','35') = 0;
econmake.FX('48','36') = 0;
econmake.FX('48','37') = 0;
econmake.FX('48','38') = 0;
econmake.FX('48','39') = 0;
econmake.FX('48','40') = 0;
econmake.FX('48','41') = 0;
econmake.FX('48','42') = 0;
econmake.FX('48','43') = 0;
econmake.FX('48','44') = 0;
econmake.FX('48','45') = 0;
econmake.FX('48','46') = 0;
econmake.FX('48','47') = 0;
econmake.FX('48','48') = 8.113680e+004;
econmake.FX('48','49') = 0;
econmake.FX('48','50') = 0;
econmake.FX('48','51') = 0;
econmake.FX('48','52') = 0;
econmake.FX('48','53') = 0;
econmake.FX('48','54') = 0;
econmake.FX('48','55') = 0;
econmake.FX('48','56') = 0;
econmake.FX('48','57') = 5.555400e+003;
econmake.FX('48','58') = 0;
econmake.FX('48','59') = 1.335000e+002;
econmake.FX('48','60') = 0;
econmake.FX('48','61') = 1.807000e+002;
econmake.FX('48','62') = 0;
econmake.FX('48','63') = 0;
econmake.FX('48','64') = 0;
econmake.FX('48','65') = 0;
econmake.FX('48','66') = 0;
econmake.FX('48','67') = 0;
econmake.FX('48','68') = 0;
econmake.FX('48','69') = 0;
econmake.FX('48','70') = 0;
econmake.FX('48','71') = 0;
econmake.FX('48','72') = 0;
econmake.FX('48','73') = 0;
econmake.FX('48','74') = 0;
econmake.FX('49','1') = 0;
econmake.FX('49','2') = 0;
econmake.FX('49','3') = 0;
econmake.FX('49','4') = 0;
econmake.FX('49','5') = 0;
econmake.FX('49','6') = 0;
econmake.FX('49','7') = 0;
econmake.FX('49','8') = 0;
econmake.FX('49','9') = 0;
econmake.FX('49','10') = 0;
econmake.FX('49','11') = 0;
econmake.FX('49','12') = 0;
econmake.FX('49','13') = 0;
econmake.FX('49','14') = 0;
econmake.FX('49','15') = 0;
econmake.FX('49','16') = 0;
econmake.FX('49','17') = 0;
econmake.FX('49','18') = 0;
econmake.FX('49','19') = 0;
econmake.FX('49','20') = 0;
econmake.FX('49','21') = 0;
econmake.FX('49','22') = 0;
econmake.FX('49','23') = 0;
econmake.FX('49','24') = 0;
econmake.FX('49','25') = 0;
econmake.FX('49','26') = 0;
econmake.FX('49','27') = 0;
econmake.FX('49','28') = 0;
econmake.FX('49','29') = 0;
econmake.FX('49','30') = 0;
econmake.FX('49','31') = 0;
econmake.FX('49','32') = 0;
econmake.FX('49','33') = 0;
econmake.FX('49','34') = 0;
econmake.FX('49','35') = 0;
econmake.FX('49','36') = 0;
econmake.FX('49','37') = 0;
econmake.FX('49','38') = 0;
econmake.FX('49','39') = 0;
econmake.FX('49','40') = 0;
econmake.FX('49','41') = 0;
econmake.FX('49','42') = 0;
econmake.FX('49','43') = 0;
econmake.FX('49','44') = 0;
econmake.FX('49','45') = 0;
econmake.FX('49','46') = 0;
econmake.FX('49','47') = 0;
econmake.FX('49','48') = 0;
econmake.FX('49','49') = 583675;
econmake.FX('49','50') = 4.368860e+004;
econmake.FX('49','51') = 0;
econmake.FX('49','52') = 0;
econmake.FX('49','53') = 0;
econmake.FX('49','54') = 0;
econmake.FX('49','55') = 0;
econmake.FX('49','56') = 0;
econmake.FX('49','57') = 0;
econmake.FX('49','58') = 0;
econmake.FX('49','59') = 0;
econmake.FX('49','60') = 0;
econmake.FX('49','61') = 0;
econmake.FX('49','62') = 0;
econmake.FX('49','63') = 0;
econmake.FX('49','64') = 0;
econmake.FX('49','65') = 0;
econmake.FX('49','66') = 0;
econmake.FX('49','67') = 0;
econmake.FX('49','68') = 0;
econmake.FX('49','69') = 0;
econmake.FX('49','70') = 0;
econmake.FX('49','71') = 0;
econmake.FX('49','72') = 0;
econmake.FX('49','73') = 0;
econmake.FX('49','74') = 0;
econmake.FX('50','1') = 0;
econmake.FX('50','2') = 0;
econmake.FX('50','3') = 0;
econmake.FX('50','4') = 0;
econmake.FX('50','5') = 0;
econmake.FX('50','6') = 0;
econmake.FX('50','7') = 0;
econmake.FX('50','8') = 0;
econmake.FX('50','9') = 0;
econmake.FX('50','10') = 0;
econmake.FX('50','11') = 0;
econmake.FX('50','12') = 0;
econmake.FX('50','13') = 0;
econmake.FX('50','14') = 0;
econmake.FX('50','15') = 0;
econmake.FX('50','16') = 0;
econmake.FX('50','17') = 0;
econmake.FX('50','18') = 0;
econmake.FX('50','19') = 0;
econmake.FX('50','20') = 0;
econmake.FX('50','21') = 0;
econmake.FX('50','22') = 0;
econmake.FX('50','23') = 0;
econmake.FX('50','24') = 0;
econmake.FX('50','25') = 0;
econmake.FX('50','26') = 0;
econmake.FX('50','27') = 0;
econmake.FX('50','28') = 0;
econmake.FX('50','29') = 0;
econmake.FX('50','30') = 0;
econmake.FX('50','31') = 0;
econmake.FX('50','32') = 0;
econmake.FX('50','33') = 0;
econmake.FX('50','34') = 0;
econmake.FX('50','35') = 0;
econmake.FX('50','36') = 0;
econmake.FX('50','37') = 0;
econmake.FX('50','38') = 0;
econmake.FX('50','39') = 0;
econmake.FX('50','40') = 0;
econmake.FX('50','41') = 0;
econmake.FX('50','42') = 0;
econmake.FX('50','43') = 0;
econmake.FX('50','44') = 0;
econmake.FX('50','45') = 0;
econmake.FX('50','46') = 0;
econmake.FX('50','47') = 0;
econmake.FX('50','48') = 0;
econmake.FX('50','49') = 5.383300e+003;
econmake.FX('50','50') = 2.797325e+005;
econmake.FX('50','51') = 0;
econmake.FX('50','52') = 0;
econmake.FX('50','53') = 0;
econmake.FX('50','54') = 0;
econmake.FX('50','55') = 0;
econmake.FX('50','56') = 0;
econmake.FX('50','57') = 0;
econmake.FX('50','58') = 0;
econmake.FX('50','59') = 0;
econmake.FX('50','60') = 0;
econmake.FX('50','61') = 0;
econmake.FX('50','62') = 0;
econmake.FX('50','63') = 0;
econmake.FX('50','64') = 0;
econmake.FX('50','65') = 0;
econmake.FX('50','66') = 0;
econmake.FX('50','67') = 0;
econmake.FX('50','68') = 0;
econmake.FX('50','69') = 0;
econmake.FX('50','70') = 0;
econmake.FX('50','71') = 0;
econmake.FX('50','72') = 0;
econmake.FX('50','73') = 0;
econmake.FX('50','74') = 0;
econmake.FX('51','1') = 0;
econmake.FX('51','2') = 0;
econmake.FX('51','3') = 0;
econmake.FX('51','4') = 0;
econmake.FX('51','5') = 0;
econmake.FX('51','6') = 0;
econmake.FX('51','7') = 0;
econmake.FX('51','8') = 0;
econmake.FX('51','9') = 0;
econmake.FX('51','10') = 0;
econmake.FX('51','11') = 0;
econmake.FX('51','12') = 0;
econmake.FX('51','13') = 0;
econmake.FX('51','14') = 0;
econmake.FX('51','15') = 0;
econmake.FX('51','16') = 0;
econmake.FX('51','17') = 0;
econmake.FX('51','18') = 0;
econmake.FX('51','19') = 0;
econmake.FX('51','20') = 0;
econmake.FX('51','21') = 0;
econmake.FX('51','22') = 0;
econmake.FX('51','23') = 0;
econmake.FX('51','24') = 0;
econmake.FX('51','25') = 0;
econmake.FX('51','26') = 0;
econmake.FX('51','27') = 0;
econmake.FX('51','28') = 0;
econmake.FX('51','29') = 0;
econmake.FX('51','30') = 0;
econmake.FX('51','31') = 0;
econmake.FX('51','32') = 0;
econmake.FX('51','33') = 0;
econmake.FX('51','34') = 0;
econmake.FX('51','35') = 0;
econmake.FX('51','36') = 0;
econmake.FX('51','37') = 0;
econmake.FX('51','38') = 0;
econmake.FX('51','39') = 0;
econmake.FX('51','40') = 0;
econmake.FX('51','41') = 0;
econmake.FX('51','42') = 0;
econmake.FX('51','43') = 0;
econmake.FX('51','44') = 0;
econmake.FX('51','45') = 0;
econmake.FX('51','46') = 0;
econmake.FX('51','47') = 0;
econmake.FX('51','48') = 0;
econmake.FX('51','49') = 0;
econmake.FX('51','50') = 4.993000e+002;
econmake.FX('51','51') = 4.516835e+005;
econmake.FX('51','52') = 0;
econmake.FX('51','53') = 5.380000e+001;
econmake.FX('51','54') = 2.063000e+002;
econmake.FX('51','55') = 2.063000e+002;
econmake.FX('51','56') = 0;
econmake.FX('51','57') = 0;
econmake.FX('51','58') = 0;
econmake.FX('51','59') = 0;
econmake.FX('51','60') = 0;
econmake.FX('51','61') = 0;
econmake.FX('51','62') = 0;
econmake.FX('51','63') = 0;
econmake.FX('51','64') = 0;
econmake.FX('51','65') = 0;
econmake.FX('51','66') = 0;
econmake.FX('51','67') = 0;
econmake.FX('51','68') = 0;
econmake.FX('51','69') = 0;
econmake.FX('51','70') = 0;
econmake.FX('51','71') = 0;
econmake.FX('51','72') = 0;
econmake.FX('51','73') = 0;
econmake.FX('51','74') = 0;
econmake.FX('52','1') = 0;
econmake.FX('52','2') = 0;
econmake.FX('52','3') = 0;
econmake.FX('52','4') = 0;
econmake.FX('52','5') = 0;
econmake.FX('52','6') = 0;
econmake.FX('52','7') = 0;
econmake.FX('52','8') = 0;
econmake.FX('52','9') = 0;
econmake.FX('52','10') = 0;
econmake.FX('52','11') = 0;
econmake.FX('52','12') = 0;
econmake.FX('52','13') = 0;
econmake.FX('52','14') = 0;
econmake.FX('52','15') = 0;
econmake.FX('52','16') = 0;
econmake.FX('52','17') = 0;
econmake.FX('52','18') = 0;
econmake.FX('52','19') = 0;
econmake.FX('52','20') = 0;
econmake.FX('52','21') = 0;
econmake.FX('52','22') = 0;
econmake.FX('52','23') = 0;
econmake.FX('52','24') = 0;
econmake.FX('52','25') = 0;
econmake.FX('52','26') = 0;
econmake.FX('52','27') = 0;
econmake.FX('52','28') = 0;
econmake.FX('52','29') = 0;
econmake.FX('52','30') = 0;
econmake.FX('52','31') = 0;
econmake.FX('52','32') = 0;
econmake.FX('52','33') = 0;
econmake.FX('52','34') = 0;
econmake.FX('52','35') = 0;
econmake.FX('52','36') = 0;
econmake.FX('52','37') = 0;
econmake.FX('52','38') = 0;
econmake.FX('52','39') = 0;
econmake.FX('52','40') = 0;
econmake.FX('52','41') = 0;
econmake.FX('52','42') = 0;
econmake.FX('52','43') = 0;
econmake.FX('52','44') = 0;
econmake.FX('52','45') = 0;
econmake.FX('52','46') = 0;
econmake.FX('52','47') = 0;
econmake.FX('52','48') = 0;
econmake.FX('52','49') = 0;
econmake.FX('52','50') = 0;
econmake.FX('52','51') = 0;
econmake.FX('52','52') = 8.801920e+004;
econmake.FX('52','53') = 0;
econmake.FX('52','54') = 0;
econmake.FX('52','55') = 0;
econmake.FX('52','56') = 0;
econmake.FX('52','57') = 0;
econmake.FX('52','58') = 0;
econmake.FX('52','59') = 0;
econmake.FX('52','60') = 0;
econmake.FX('52','61') = 0;
econmake.FX('52','62') = 0;
econmake.FX('52','63') = 0;
econmake.FX('52','64') = 0;
econmake.FX('52','65') = 0;
econmake.FX('52','66') = 0;
econmake.FX('52','67') = 0;
econmake.FX('52','68') = 0;
econmake.FX('52','69') = 0;
econmake.FX('52','70') = 0;
econmake.FX('52','71') = 0;
econmake.FX('52','72') = 0;
econmake.FX('52','73') = 0;
econmake.FX('52','74') = 0;
econmake.FX('53','1') = 0;
econmake.FX('53','2') = 0;
econmake.FX('53','3') = 0;
econmake.FX('53','4') = 0;
econmake.FX('53','5') = 0;
econmake.FX('53','6') = 0;
econmake.FX('53','7') = 0;
econmake.FX('53','8') = 0;
econmake.FX('53','9') = 0;
econmake.FX('53','10') = 0;
econmake.FX('53','11') = 0;
econmake.FX('53','12') = 0;
econmake.FX('53','13') = 0;
econmake.FX('53','14') = 0;
econmake.FX('53','15') = 0;
econmake.FX('53','16') = 0;
econmake.FX('53','17') = 0;
econmake.FX('53','18') = 0;
econmake.FX('53','19') = 0;
econmake.FX('53','20') = 0;
econmake.FX('53','21') = 0;
econmake.FX('53','22') = 0;
econmake.FX('53','23') = 0;
econmake.FX('53','24') = 0;
econmake.FX('53','25') = 0;
econmake.FX('53','26') = 0;
econmake.FX('53','27') = 0;
econmake.FX('53','28') = 0;
econmake.FX('53','29') = 0;
econmake.FX('53','30') = 0;
econmake.FX('53','31') = 0;
econmake.FX('53','32') = 0;
econmake.FX('53','33') = 0;
econmake.FX('53','34') = 0;
econmake.FX('53','35') = 0;
econmake.FX('53','36') = 0;
econmake.FX('53','37') = 0;
econmake.FX('53','38') = 0;
econmake.FX('53','39') = 0;
econmake.FX('53','40') = 0;
econmake.FX('53','41') = 0;
econmake.FX('53','42') = 0;
econmake.FX('53','43') = 0;
econmake.FX('53','44') = 0;
econmake.FX('53','45') = 0;
econmake.FX('53','46') = 0;
econmake.FX('53','47') = 0;
econmake.FX('53','48') = 0;
econmake.FX('53','49') = 0;
econmake.FX('53','50') = 0;
econmake.FX('53','51') = 0;
econmake.FX('53','52') = 0;
econmake.FX('53','53') = 1.775044e+006;
econmake.FX('53','54') = 0;
econmake.FX('53','55') = 0;
econmake.FX('53','56') = 0;
econmake.FX('53','57') = 0;
econmake.FX('53','58') = 0;
econmake.FX('53','59') = 0;
econmake.FX('53','60') = 0;
econmake.FX('53','61') = 0;
econmake.FX('53','62') = 0;
econmake.FX('53','63') = 0;
econmake.FX('53','64') = 0;
econmake.FX('53','65') = 0;
econmake.FX('53','66') = 0;
econmake.FX('53','67') = 3.700000e+000;
econmake.FX('53','68') = 0;
econmake.FX('53','69') = 0;
econmake.FX('53','70') = 5.850000e+001;
econmake.FX('53','71') = 0;
econmake.FX('53','72') = 0;
econmake.FX('53','73') = 0;
econmake.FX('53','74') = 0;
econmake.FX('54','1') = 0;
econmake.FX('54','2') = 0;
econmake.FX('54','3') = 0;
econmake.FX('54','4') = 0;
econmake.FX('54','5') = 0;
econmake.FX('54','6') = 0;
econmake.FX('54','7') = 0;
econmake.FX('54','8') = 0;
econmake.FX('54','9') = 0;
econmake.FX('54','10') = 0;
econmake.FX('54','11') = 0;
econmake.FX('54','12') = 0;
econmake.FX('54','13') = 0;
econmake.FX('54','14') = 0;
econmake.FX('54','15') = 0;
econmake.FX('54','16') = 0;
econmake.FX('54','17') = 0;
econmake.FX('54','18') = 0;
econmake.FX('54','19') = 0;
econmake.FX('54','20') = 0;
econmake.FX('54','21') = 0;
econmake.FX('54','22') = 0;
econmake.FX('54','23') = 0;
econmake.FX('54','24') = 0;
econmake.FX('54','25') = 0;
econmake.FX('54','26') = 0;
econmake.FX('54','27') = 0;
econmake.FX('54','28') = 0;
econmake.FX('54','29') = 0;
econmake.FX('54','30') = 0;
econmake.FX('54','31') = 0;
econmake.FX('54','32') = 0;
econmake.FX('54','33') = 0;
econmake.FX('54','34') = 0;
econmake.FX('54','35') = 0;
econmake.FX('54','36') = 0;
econmake.FX('54','37') = 0;
econmake.FX('54','38') = 0;
econmake.FX('54','39') = 0;
econmake.FX('54','40') = 0;
econmake.FX('54','41') = 0;
econmake.FX('54','42') = 0;
econmake.FX('54','43') = 0;
econmake.FX('54','44') = 0;
econmake.FX('54','45') = 4.608000e+002;
econmake.FX('54','46') = 0;
econmake.FX('54','47') = 0;
econmake.FX('54','48') = 0;
econmake.FX('54','49') = 0;
econmake.FX('54','50') = 7.200000e+000;
econmake.FX('54','51') = 0;
econmake.FX('54','52') = 0;
econmake.FX('54','53') = 1.148000e+002;
econmake.FX('54','54') = 8.158982e+005;
econmake.FX('54','55') = 2.054816e+005;
econmake.FX('54','56') = 1.891775e+005;
econmake.FX('54','57') = 5.099964e+005;
econmake.FX('54','58') = 0;
econmake.FX('54','59') = 0;
econmake.FX('54','60') = 0;
econmake.FX('54','61') = 0;
econmake.FX('54','62') = 0;
econmake.FX('54','63') = 0;
econmake.FX('54','64') = 0;
econmake.FX('54','65') = 0;
econmake.FX('54','66') = 0;
econmake.FX('54','67') = 0;
econmake.FX('54','68') = 0;
econmake.FX('54','69') = 0;
econmake.FX('54','70') = 0;
econmake.FX('54','71') = 0;
econmake.FX('54','72') = 0;
econmake.FX('54','73') = 0;
econmake.FX('54','74') = 0;
econmake.FX('55','1') = 0;
econmake.FX('55','2') = 0;
econmake.FX('55','3') = 0;
econmake.FX('55','4') = 0;
econmake.FX('55','5') = 0;
econmake.FX('55','6') = 0;
econmake.FX('55','7') = 0;
econmake.FX('55','8') = 0;
econmake.FX('55','9') = 0;
econmake.FX('55','10') = 0;
econmake.FX('55','11') = 0;
econmake.FX('55','12') = 0;
econmake.FX('55','13') = 0;
econmake.FX('55','14') = 0;
econmake.FX('55','15') = 0;
econmake.FX('55','16') = 0;
econmake.FX('55','17') = 0;
econmake.FX('55','18') = 0;
econmake.FX('55','19') = 0;
econmake.FX('55','20') = 0;
econmake.FX('55','21') = 0;
econmake.FX('55','22') = 0;
econmake.FX('55','23') = 0;
econmake.FX('55','24') = 0;
econmake.FX('55','25') = 0;
econmake.FX('55','26') = 0;
econmake.FX('55','27') = 0;
econmake.FX('55','28') = 0;
econmake.FX('55','29') = 0;
econmake.FX('55','30') = 0;
econmake.FX('55','31') = 0;
econmake.FX('55','32') = 0;
econmake.FX('55','33') = 0;
econmake.FX('55','34') = 0;
econmake.FX('55','35') = 0;
econmake.FX('55','36') = 0;
econmake.FX('55','37') = 0;
econmake.FX('55','38') = 0;
econmake.FX('55','39') = 0;
econmake.FX('55','40') = 0;
econmake.FX('55','41') = 0;
econmake.FX('55','42') = 0;
econmake.FX('55','43') = 0;
econmake.FX('55','44') = 0;
econmake.FX('55','45') = 0;
econmake.FX('55','46') = 0;
econmake.FX('55','47') = 0;
econmake.FX('55','48') = 0;
econmake.FX('55','49') = 0;
econmake.FX('55','50') = 0;
econmake.FX('55','51') = 0;
econmake.FX('55','52') = 0;
econmake.FX('55','53') = 0;
econmake.FX('55','54') = 2.054816e+005;
econmake.FX('55','55') = 2.054816e+005;
econmake.FX('55','56') = 0;
econmake.FX('55','57') = 0;
econmake.FX('55','58') = 0;
econmake.FX('55','59') = 0;
econmake.FX('55','60') = 0;
econmake.FX('55','61') = 0;
econmake.FX('55','62') = 0;
econmake.FX('55','63') = 0;
econmake.FX('55','64') = 0;
econmake.FX('55','65') = 0;
econmake.FX('55','66') = 0;
econmake.FX('55','67') = 0;
econmake.FX('55','68') = 0;
econmake.FX('55','69') = 0;
econmake.FX('55','70') = 0;
econmake.FX('55','71') = 0;
econmake.FX('55','72') = 0;
econmake.FX('55','73') = 0;
econmake.FX('55','74') = 0;
econmake.FX('56','1') = 0;
econmake.FX('56','2') = 0;
econmake.FX('56','3') = 0;
econmake.FX('56','4') = 0;
econmake.FX('56','5') = 0;
econmake.FX('56','6') = 0;
econmake.FX('56','7') = 0;
econmake.FX('56','8') = 0;
econmake.FX('56','9') = 0;
econmake.FX('56','10') = 0;
econmake.FX('56','11') = 0;
econmake.FX('56','12') = 0;
econmake.FX('56','13') = 0;
econmake.FX('56','14') = 0;
econmake.FX('56','15') = 0;
econmake.FX('56','16') = 0;
econmake.FX('56','17') = 0;
econmake.FX('56','18') = 0;
econmake.FX('56','19') = 0;
econmake.FX('56','20') = 0;
econmake.FX('56','21') = 0;
econmake.FX('56','22') = 0;
econmake.FX('56','23') = 0;
econmake.FX('56','24') = 0;
econmake.FX('56','25') = 0;
econmake.FX('56','26') = 0;
econmake.FX('56','27') = 0;
econmake.FX('56','28') = 0;
econmake.FX('56','29') = 0;
econmake.FX('56','30') = 0;
econmake.FX('56','31') = 0;
econmake.FX('56','32') = 0;
econmake.FX('56','33') = 0;
econmake.FX('56','34') = 0;
econmake.FX('56','35') = 0;
econmake.FX('56','36') = 0;
econmake.FX('56','37') = 0;
econmake.FX('56','38') = 0;
econmake.FX('56','39') = 0;
econmake.FX('56','40') = 0;
econmake.FX('56','41') = 0;
econmake.FX('56','42') = 0;
econmake.FX('56','43') = 0;
econmake.FX('56','44') = 0;
econmake.FX('56','45') = 4.608000e+002;
econmake.FX('56','46') = 0;
econmake.FX('56','47') = 0;
econmake.FX('56','48') = 0;
econmake.FX('56','49') = 0;
econmake.FX('56','50') = 0;
econmake.FX('56','51') = 0;
econmake.FX('56','52') = 0;
econmake.FX('56','53') = 0;
econmake.FX('56','54') = 1.892164e+005;
econmake.FX('56','55') = 0;
econmake.FX('56','56') = 1.889334e+005;
econmake.FX('56','57') = 209663;
econmake.FX('56','58') = 0;
econmake.FX('56','59') = 0;
econmake.FX('56','60') = 0;
econmake.FX('56','61') = 0;
econmake.FX('56','62') = 0;
econmake.FX('56','63') = 0;
econmake.FX('56','64') = 0;
econmake.FX('56','65') = 0;
econmake.FX('56','66') = 0;
econmake.FX('56','67') = 0;
econmake.FX('56','68') = 0;
econmake.FX('56','69') = 0;
econmake.FX('56','70') = 0;
econmake.FX('56','71') = 0;
econmake.FX('56','72') = 0;
econmake.FX('56','73') = 0;
econmake.FX('56','74') = 0;
econmake.FX('57','1') = 0;
econmake.FX('57','2') = 0;
econmake.FX('57','3') = 0;
econmake.FX('57','4') = 0;
econmake.FX('57','5') = 0;
econmake.FX('57','6') = 0;
econmake.FX('57','7') = 0;
econmake.FX('57','8') = 0;
econmake.FX('57','9') = 0;
econmake.FX('57','10') = 0;
econmake.FX('57','11') = 0;
econmake.FX('57','12') = 0;
econmake.FX('57','13') = 0;
econmake.FX('57','14') = 0;
econmake.FX('57','15') = 0;
econmake.FX('57','16') = 0;
econmake.FX('57','17') = 0;
econmake.FX('57','18') = 0;
econmake.FX('57','19') = 0;
econmake.FX('57','20') = 0;
econmake.FX('57','21') = 0;
econmake.FX('57','22') = 0;
econmake.FX('57','23') = 0;
econmake.FX('57','24') = 0;
econmake.FX('57','25') = 0;
econmake.FX('57','26') = 0;
econmake.FX('57','27') = 0;
econmake.FX('57','28') = 0;
econmake.FX('57','29') = 0;
econmake.FX('57','30') = 0;
econmake.FX('57','31') = 0;
econmake.FX('57','32') = 0;
econmake.FX('57','33') = 0;
econmake.FX('57','34') = 0;
econmake.FX('57','35') = 0;
econmake.FX('57','36') = 0;
econmake.FX('57','37') = 0;
econmake.FX('57','38') = 0;
econmake.FX('57','39') = 0;
econmake.FX('57','40') = 0;
econmake.FX('57','41') = 0;
econmake.FX('57','42') = 0;
econmake.FX('57','43') = 0;
econmake.FX('57','44') = 0;
econmake.FX('57','45') = 5.313000e+002;
econmake.FX('57','46') = 0;
econmake.FX('57','47') = 0;
econmake.FX('57','48') = 2.850000e+001;
econmake.FX('57','49') = 0;
econmake.FX('57','50') = 0;
econmake.FX('57','51') = 0;
econmake.FX('57','52') = 0;
econmake.FX('57','53') = 0;
econmake.FX('57','54') = 4.906822e+005;
econmake.FX('57','55') = 0;
econmake.FX('57','56') = 1.916384e+005;
econmake.FX('57','57') = 9.407953e+005;
econmake.FX('57','58') = 0;
econmake.FX('57','59') = 8.841000e+002;
econmake.FX('57','60') = 0;
econmake.FX('57','61') = 0;
econmake.FX('57','62') = 0;
econmake.FX('57','63') = 0;
econmake.FX('57','64') = 0;
econmake.FX('57','65') = 0;
econmake.FX('57','66') = 0;
econmake.FX('57','67') = 0;
econmake.FX('57','68') = 0;
econmake.FX('57','69') = 0;
econmake.FX('57','70') = 0;
econmake.FX('57','71') = 0;
econmake.FX('57','72') = 0;
econmake.FX('57','73') = 0;
econmake.FX('57','74') = 0;
econmake.FX('58','1') = 0;
econmake.FX('58','2') = 0;
econmake.FX('58','3') = 0;
econmake.FX('58','4') = 0;
econmake.FX('58','5') = 0;
econmake.FX('58','6') = 0;
econmake.FX('58','7') = 0;
econmake.FX('58','8') = 0;
econmake.FX('58','9') = 0;
econmake.FX('58','10') = 0;
econmake.FX('58','11') = 0;
econmake.FX('58','12') = 0;
econmake.FX('58','13') = 0;
econmake.FX('58','14') = 0;
econmake.FX('58','15') = 0;
econmake.FX('58','16') = 0;
econmake.FX('58','17') = 0;
econmake.FX('58','18') = 0;
econmake.FX('58','19') = 0;
econmake.FX('58','20') = 0;
econmake.FX('58','21') = 0;
econmake.FX('58','22') = 0;
econmake.FX('58','23') = 0;
econmake.FX('58','24') = 0;
econmake.FX('58','25') = 0;
econmake.FX('58','26') = 0;
econmake.FX('58','27') = 0;
econmake.FX('58','28') = 0;
econmake.FX('58','29') = 0;
econmake.FX('58','30') = 0;
econmake.FX('58','31') = 0;
econmake.FX('58','32') = 0;
econmake.FX('58','33') = 0;
econmake.FX('58','34') = 0;
econmake.FX('58','35') = 0;
econmake.FX('58','36') = 0;
econmake.FX('58','37') = 0;
econmake.FX('58','38') = 0;
econmake.FX('58','39') = 0;
econmake.FX('58','40') = 0;
econmake.FX('58','41') = 0;
econmake.FX('58','42') = 0;
econmake.FX('58','43') = 0;
econmake.FX('58','44') = 0;
econmake.FX('58','45') = 0;
econmake.FX('58','46') = 0;
econmake.FX('58','47') = 0;
econmake.FX('58','48') = 0;
econmake.FX('58','49') = 0;
econmake.FX('58','50') = 0;
econmake.FX('58','51') = 0;
econmake.FX('58','52') = 0;
econmake.FX('58','53') = 0;
econmake.FX('58','54') = 0;
econmake.FX('58','55') = 0;
econmake.FX('58','56') = 0;
econmake.FX('58','57') = 0;
econmake.FX('58','58') = 4.408979e+005;
econmake.FX('58','59') = 0;
econmake.FX('58','60') = 0;
econmake.FX('58','61') = 0;
econmake.FX('58','62') = 0;
econmake.FX('58','63') = 0;
econmake.FX('58','64') = 0;
econmake.FX('58','65') = 0;
econmake.FX('58','66') = 0;
econmake.FX('58','67') = 0;
econmake.FX('58','68') = 0;
econmake.FX('58','69') = 0;
econmake.FX('58','70') = 0;
econmake.FX('58','71') = 0;
econmake.FX('58','72') = 0;
econmake.FX('58','73') = 0;
econmake.FX('58','74') = 0;
econmake.FX('59','1') = 0;
econmake.FX('59','2') = 0;
econmake.FX('59','3') = 0;
econmake.FX('59','4') = 0;
econmake.FX('59','5') = 0;
econmake.FX('59','6') = 0;
econmake.FX('59','7') = 0;
econmake.FX('59','8') = 0;
econmake.FX('59','9') = 0;
econmake.FX('59','10') = 0;
econmake.FX('59','11') = 0;
econmake.FX('59','12') = 0;
econmake.FX('59','13') = 0;
econmake.FX('59','14') = 0;
econmake.FX('59','15') = 0;
econmake.FX('59','16') = 0;
econmake.FX('59','17') = 0;
econmake.FX('59','18') = 0;
econmake.FX('59','19') = 0;
econmake.FX('59','20') = 0;
econmake.FX('59','21') = 0;
econmake.FX('59','22') = 0;
econmake.FX('59','23') = 0;
econmake.FX('59','24') = 0;
econmake.FX('59','25') = 0;
econmake.FX('59','26') = 0;
econmake.FX('59','27') = 0;
econmake.FX('59','28') = 0;
econmake.FX('59','29') = 0;
econmake.FX('59','30') = 0;
econmake.FX('59','31') = 0;
econmake.FX('59','32') = 0;
econmake.FX('59','33') = 0;
econmake.FX('59','34') = 0;
econmake.FX('59','35') = 0;
econmake.FX('59','36') = 0;
econmake.FX('59','37') = 0;
econmake.FX('59','38') = 0;
econmake.FX('59','39') = 0;
econmake.FX('59','40') = 0;
econmake.FX('59','41') = 0;
econmake.FX('59','42') = 0;
econmake.FX('59','43') = 0;
econmake.FX('59','44') = 0;
econmake.FX('59','45') = 0;
econmake.FX('59','46') = 0;
econmake.FX('59','47') = 0;
econmake.FX('59','48') = 0;
econmake.FX('59','49') = 0;
econmake.FX('59','50') = 0;
econmake.FX('59','51') = 0;
econmake.FX('59','52') = 0;
econmake.FX('59','53') = 0;
econmake.FX('59','54') = 7.345000e+002;
econmake.FX('59','55') = 0;
econmake.FX('59','56') = 8.140000e+001;
econmake.FX('59','57') = 1.513500e+003;
econmake.FX('59','58') = 0;
econmake.FX('59','59') = 4.401456e+005;
econmake.FX('59','60') = 6.630000e+001;
econmake.FX('59','61') = 0;
econmake.FX('59','62') = 3.600000e+000;
econmake.FX('59','63') = 0;
econmake.FX('59','64') = 0;
econmake.FX('59','65') = 1.180000e+001;
econmake.FX('59','66') = 0;
econmake.FX('59','67') = 0;
econmake.FX('59','68') = 0;
econmake.FX('59','69') = 0;
econmake.FX('59','70') = 0;
econmake.FX('59','71') = 0;
econmake.FX('59','72') = 0;
econmake.FX('59','73') = 0;
econmake.FX('59','74') = 0;
econmake.FX('60','1') = 0;
econmake.FX('60','2') = 0;
econmake.FX('60','3') = 0;
econmake.FX('60','4') = 0;
econmake.FX('60','5') = 0;
econmake.FX('60','6') = 4.667029e+001;
econmake.FX('60','7') = 0;
econmake.FX('60','8') = 0;
econmake.FX('60','9') = 0;
econmake.FX('60','10') = 0;
econmake.FX('60','11') = 0;
econmake.FX('60','12') = 0;
econmake.FX('60','13') = 0;
econmake.FX('60','14') = 0;
econmake.FX('60','15') = 0;
econmake.FX('60','16') = 0;
econmake.FX('60','17') = 0;
econmake.FX('60','18') = 0;
econmake.FX('60','19') = 0;
econmake.FX('60','20') = 0;
econmake.FX('60','21') = 0;
econmake.FX('60','22') = 0;
econmake.FX('60','23') = 0;
econmake.FX('60','24') = 0;
econmake.FX('60','25') = 0;
econmake.FX('60','26') = 0;
econmake.FX('60','27') = 0;
econmake.FX('60','28') = 0;
econmake.FX('60','29') = 0;
econmake.FX('60','30') = 0;
econmake.FX('60','31') = 0;
econmake.FX('60','32') = 0;
econmake.FX('60','33') = 0;
econmake.FX('60','34') = 0;
econmake.FX('60','35') = 0;
econmake.FX('60','36') = 0;
econmake.FX('60','37') = 0;
econmake.FX('60','38') = 0;
econmake.FX('60','39') = 0;
econmake.FX('60','40') = 0;
econmake.FX('60','41') = 0;
econmake.FX('60','42') = 0;
econmake.FX('60','43') = 0;
econmake.FX('60','44') = 0;
econmake.FX('60','45') = 0;
econmake.FX('60','46') = 0;
econmake.FX('60','47') = 0;
econmake.FX('60','48') = 0;
econmake.FX('60','49') = 0;
econmake.FX('60','50') = 0;
econmake.FX('60','51') = 0;
econmake.FX('60','52') = 0;
econmake.FX('60','53') = 0;
econmake.FX('60','54') = 0;
econmake.FX('60','55') = 0;
econmake.FX('60','56') = 0;
econmake.FX('60','57') = 1.057389e+002;
econmake.FX('60','58') = 0;
econmake.FX('60','59') = 4.656949e+001;
econmake.FX('60','60') = 5.202064e+004;
econmake.FX('60','61') = 0;
econmake.FX('60','62') = 0;
econmake.FX('60','63') = 0;
econmake.FX('60','64') = 0;
econmake.FX('60','65') = 0;
econmake.FX('60','66') = 0;
econmake.FX('60','67') = 0;
econmake.FX('60','68') = 0;
econmake.FX('60','69') = 0;
econmake.FX('60','70') = 0;
econmake.FX('60','71') = 0;
econmake.FX('60','72') = 0;
econmake.FX('60','73') = 0;
econmake.FX('60','74') = 0;
econmake.FX('61','1') = 0;
econmake.FX('61','2') = 0;
econmake.FX('61','3') = 0;
econmake.FX('61','4') = 0;
econmake.FX('61','5') = 0;
econmake.FX('61','6') = 0;
econmake.FX('61','7') = 0;
econmake.FX('61','8') = 0;
econmake.FX('61','9') = 0;
econmake.FX('61','10') = 0;
econmake.FX('61','11') = 0;
econmake.FX('61','12') = 0;
econmake.FX('61','13') = 0;
econmake.FX('61','14') = 0;
econmake.FX('61','15') = 0;
econmake.FX('61','16') = 0;
econmake.FX('61','17') = 0;
econmake.FX('61','18') = 0;
econmake.FX('61','19') = 0;
econmake.FX('61','20') = 0;
econmake.FX('61','21') = 0;
econmake.FX('61','22') = 0;
econmake.FX('61','23') = 0;
econmake.FX('61','24') = 0;
econmake.FX('61','25') = 0;
econmake.FX('61','26') = 0;
econmake.FX('61','27') = 0;
econmake.FX('61','28') = 0;
econmake.FX('61','29') = 0;
econmake.FX('61','30') = 0;
econmake.FX('61','31') = 0;
econmake.FX('61','32') = 0;
econmake.FX('61','33') = 0;
econmake.FX('61','34') = 0;
econmake.FX('61','35') = 0;
econmake.FX('61','36') = 0;
econmake.FX('61','37') = 0;
econmake.FX('61','38') = 0;
econmake.FX('61','39') = 0;
econmake.FX('61','40') = 0;
econmake.FX('61','41') = 0;
econmake.FX('61','42') = 0;
econmake.FX('61','43') = 0;
econmake.FX('61','44') = 0;
econmake.FX('61','45') = 0;
econmake.FX('61','46') = 0;
econmake.FX('61','47') = 0;
econmake.FX('61','48') = 0;
econmake.FX('61','49') = 0;
econmake.FX('61','50') = 0;
econmake.FX('61','51') = 0;
econmake.FX('61','52') = 0;
econmake.FX('61','53') = 0;
econmake.FX('61','54') = 0;
econmake.FX('61','55') = 0;
econmake.FX('61','56') = 0;
econmake.FX('61','57') = 0;
econmake.FX('61','58') = 0;
econmake.FX('61','59') = 0;
econmake.FX('61','60') = 0;
econmake.FX('61','61') = 1.418288e+005;
econmake.FX('61','62') = 0;
econmake.FX('61','63') = 0;
econmake.FX('61','64') = 0;
econmake.FX('61','65') = 0;
econmake.FX('61','66') = 0;
econmake.FX('61','67') = 0;
econmake.FX('61','68') = 0;
econmake.FX('61','69') = 0;
econmake.FX('61','70') = 0;
econmake.FX('61','71') = 0;
econmake.FX('61','72') = 0;
econmake.FX('61','73') = 0;
econmake.FX('61','74') = 0;
econmake.FX('62','1') = 0;
econmake.FX('62','2') = 0;
econmake.FX('62','3') = 0;
econmake.FX('62','4') = 0;
econmake.FX('62','5') = 0;
econmake.FX('62','6') = 0;
econmake.FX('62','7') = 0;
econmake.FX('62','8') = 0;
econmake.FX('62','9') = 0;
econmake.FX('62','10') = 0;
econmake.FX('62','11') = 0;
econmake.FX('62','12') = 0;
econmake.FX('62','13') = 0;
econmake.FX('62','14') = 0;
econmake.FX('62','15') = 0;
econmake.FX('62','16') = 0;
econmake.FX('62','17') = 0;
econmake.FX('62','18') = 0;
econmake.FX('62','19') = 0;
econmake.FX('62','20') = 0;
econmake.FX('62','21') = 0;
econmake.FX('62','22') = 0;
econmake.FX('62','23') = 0;
econmake.FX('62','24') = 0;
econmake.FX('62','25') = 0;
econmake.FX('62','26') = 0;
econmake.FX('62','27') = 0;
econmake.FX('62','28') = 0;
econmake.FX('62','29') = 0;
econmake.FX('62','30') = 0;
econmake.FX('62','31') = 0;
econmake.FX('62','32') = 0;
econmake.FX('62','33') = 0;
econmake.FX('62','34') = 0;
econmake.FX('62','35') = 0;
econmake.FX('62','36') = 0;
econmake.FX('62','37') = 0;
econmake.FX('62','38') = 0;
econmake.FX('62','39') = 0;
econmake.FX('62','40') = 0;
econmake.FX('62','41') = 0;
econmake.FX('62','42') = 0;
econmake.FX('62','43') = 0;
econmake.FX('62','44') = 0;
econmake.FX('62','45') = 0;
econmake.FX('62','46') = 0;
econmake.FX('62','47') = 0;
econmake.FX('62','48') = 0;
econmake.FX('62','49') = 0;
econmake.FX('62','50') = 0;
econmake.FX('62','51') = 0;
econmake.FX('62','52') = 0;
econmake.FX('62','53') = 0;
econmake.FX('62','54') = 0;
econmake.FX('62','55') = 0;
econmake.FX('62','56') = 0;
econmake.FX('62','57') = 0;
econmake.FX('62','58') = 0;
econmake.FX('62','59') = 0;
econmake.FX('62','60') = 0;
econmake.FX('62','61') = 0;
econmake.FX('62','62') = 5.198177e+005;
econmake.FX('62','63') = 0;
econmake.FX('62','64') = 0;
econmake.FX('62','65') = 0;
econmake.FX('62','66') = 0;
econmake.FX('62','67') = 0;
econmake.FX('62','68') = 0;
econmake.FX('62','69') = 0;
econmake.FX('62','70') = 0;
econmake.FX('62','71') = 0;
econmake.FX('62','72') = 0;
econmake.FX('62','73') = 0;
econmake.FX('62','74') = 0;
econmake.FX('63','1') = 0;
econmake.FX('63','2') = 0;
econmake.FX('63','3') = 0;
econmake.FX('63','4') = 0;
econmake.FX('63','5') = 0;
econmake.FX('63','6') = 0;
econmake.FX('63','7') = 0;
econmake.FX('63','8') = 0;
econmake.FX('63','9') = 0;
econmake.FX('63','10') = 0;
econmake.FX('63','11') = 0;
econmake.FX('63','12') = 0;
econmake.FX('63','13') = 0;
econmake.FX('63','14') = 0;
econmake.FX('63','15') = 0;
econmake.FX('63','16') = 0;
econmake.FX('63','17') = 0;
econmake.FX('63','18') = 0;
econmake.FX('63','19') = 0;
econmake.FX('63','20') = 0;
econmake.FX('63','21') = 0;
econmake.FX('63','22') = 0;
econmake.FX('63','23') = 0;
econmake.FX('63','24') = 0;
econmake.FX('63','25') = 0;
econmake.FX('63','26') = 0;
econmake.FX('63','27') = 0;
econmake.FX('63','28') = 0;
econmake.FX('63','29') = 0;
econmake.FX('63','30') = 0;
econmake.FX('63','31') = 0;
econmake.FX('63','32') = 0;
econmake.FX('63','33') = 0;
econmake.FX('63','34') = 0;
econmake.FX('63','35') = 0;
econmake.FX('63','36') = 0;
econmake.FX('63','37') = 0;
econmake.FX('63','38') = 0;
econmake.FX('63','39') = 0;
econmake.FX('63','40') = 0;
econmake.FX('63','41') = 0;
econmake.FX('63','42') = 0;
econmake.FX('63','43') = 0;
econmake.FX('63','44') = 0;
econmake.FX('63','45') = 0;
econmake.FX('63','46') = 0;
econmake.FX('63','47') = 0;
econmake.FX('63','48') = 0;
econmake.FX('63','49') = 0;
econmake.FX('63','50') = 0;
econmake.FX('63','51') = 0;
econmake.FX('63','52') = 0;
econmake.FX('63','53') = 0;
econmake.FX('63','54') = 0;
econmake.FX('63','55') = 0;
econmake.FX('63','56') = 0;
econmake.FX('63','57') = 0;
econmake.FX('63','58') = 0;
econmake.FX('63','59') = 0;
econmake.FX('63','60') = 0;
econmake.FX('63','61') = 0;
econmake.FX('63','62') = 3.935500e+003;
econmake.FX('63','63') = 3.723728e+005;
econmake.FX('63','64') = 4164;
econmake.FX('63','65') = 0;
econmake.FX('63','66') = 0;
econmake.FX('63','67') = 0;
econmake.FX('63','68') = 0;
econmake.FX('63','69') = 0;
econmake.FX('63','70') = 0;
econmake.FX('63','71') = 0;
econmake.FX('63','72') = 0;
econmake.FX('63','73') = 0;
econmake.FX('63','74') = 0;
econmake.FX('64','1') = 0;
econmake.FX('64','2') = 0;
econmake.FX('64','3') = 0;
econmake.FX('64','4') = 0;
econmake.FX('64','5') = 0;
econmake.FX('64','6') = 0;
econmake.FX('64','7') = 0;
econmake.FX('64','8') = 0;
econmake.FX('64','9') = 0;
econmake.FX('64','10') = 0;
econmake.FX('64','11') = 0;
econmake.FX('64','12') = 0;
econmake.FX('64','13') = 0;
econmake.FX('64','14') = 0;
econmake.FX('64','15') = 0;
econmake.FX('64','16') = 0;
econmake.FX('64','17') = 0;
econmake.FX('64','18') = 0;
econmake.FX('64','19') = 0;
econmake.FX('64','20') = 0;
econmake.FX('64','21') = 0;
econmake.FX('64','22') = 0;
econmake.FX('64','23') = 0;
econmake.FX('64','24') = 0;
econmake.FX('64','25') = 0;
econmake.FX('64','26') = 0;
econmake.FX('64','27') = 0;
econmake.FX('64','28') = 0;
econmake.FX('64','29') = 0;
econmake.FX('64','30') = 0;
econmake.FX('64','31') = 0;
econmake.FX('64','32') = 0;
econmake.FX('64','33') = 0;
econmake.FX('64','34') = 0;
econmake.FX('64','35') = 0;
econmake.FX('64','36') = 0;
econmake.FX('64','37') = 0;
econmake.FX('64','38') = 0;
econmake.FX('64','39') = 0;
econmake.FX('64','40') = 0;
econmake.FX('64','41') = 0;
econmake.FX('64','42') = 0;
econmake.FX('64','43') = 0;
econmake.FX('64','44') = 0;
econmake.FX('64','45') = 0;
econmake.FX('64','46') = 0;
econmake.FX('64','47') = 0;
econmake.FX('64','48') = 0;
econmake.FX('64','49') = 0;
econmake.FX('64','50') = 0;
econmake.FX('64','51') = 0;
econmake.FX('64','52') = 0;
econmake.FX('64','53') = 0;
econmake.FX('64','54') = 0;
econmake.FX('64','55') = 0;
econmake.FX('64','56') = 0;
econmake.FX('64','57') = 0;
econmake.FX('64','58') = 0;
econmake.FX('64','59') = 0;
econmake.FX('64','60') = 0;
econmake.FX('64','61') = 0;
econmake.FX('64','62') = 0;
econmake.FX('64','63') = 0;
econmake.FX('64','64') = 1.270938e+005;
econmake.FX('64','65') = 0;
econmake.FX('64','66') = 0;
econmake.FX('64','67') = 0;
econmake.FX('64','68') = 0;
econmake.FX('64','69') = 0;
econmake.FX('64','70') = 0;
econmake.FX('64','71') = 0;
econmake.FX('64','72') = 0;
econmake.FX('64','73') = 0;
econmake.FX('64','74') = 0;
econmake.FX('65','1') = 0;
econmake.FX('65','2') = 0;
econmake.FX('65','3') = 0;
econmake.FX('65','4') = 0;
econmake.FX('65','5') = 0;
econmake.FX('65','6') = 0;
econmake.FX('65','7') = 0;
econmake.FX('65','8') = 0;
econmake.FX('65','9') = 0;
econmake.FX('65','10') = 0;
econmake.FX('65','11') = 0;
econmake.FX('65','12') = 0;
econmake.FX('65','13') = 0;
econmake.FX('65','14') = 0;
econmake.FX('65','15') = 0;
econmake.FX('65','16') = 0;
econmake.FX('65','17') = 0;
econmake.FX('65','18') = 0;
econmake.FX('65','19') = 0;
econmake.FX('65','20') = 0;
econmake.FX('65','21') = 0;
econmake.FX('65','22') = 0;
econmake.FX('65','23') = 0;
econmake.FX('65','24') = 0;
econmake.FX('65','25') = 0;
econmake.FX('65','26') = 0;
econmake.FX('65','27') = 0;
econmake.FX('65','28') = 0;
econmake.FX('65','29') = 0;
econmake.FX('65','30') = 0;
econmake.FX('65','31') = 0;
econmake.FX('65','32') = 0;
econmake.FX('65','33') = 0;
econmake.FX('65','34') = 0;
econmake.FX('65','35') = 0;
econmake.FX('65','36') = 0;
econmake.FX('65','37') = 0;
econmake.FX('65','38') = 0;
econmake.FX('65','39') = 0;
econmake.FX('65','40') = 0;
econmake.FX('65','41') = 0;
econmake.FX('65','42') = 0;
econmake.FX('65','43') = 0;
econmake.FX('65','44') = 0;
econmake.FX('65','45') = 0;
econmake.FX('65','46') = 0;
econmake.FX('65','47') = 0;
econmake.FX('65','48') = 0;
econmake.FX('65','49') = 0;
econmake.FX('65','50') = 0;
econmake.FX('65','51') = 0;
econmake.FX('65','52') = 0;
econmake.FX('65','53') = 0;
econmake.FX('65','54') = 0;
econmake.FX('65','55') = 0;
econmake.FX('65','56') = 0;
econmake.FX('65','57') = 0;
econmake.FX('65','58') = 0;
econmake.FX('65','59') = 0;
econmake.FX('65','60') = 0;
econmake.FX('65','61') = 0;
econmake.FX('65','62') = 0;
econmake.FX('65','63') = 0;
econmake.FX('65','64') = 8.964000e+002;
econmake.FX('65','65') = 1.011365e+005;
econmake.FX('65','66') = 0;
econmake.FX('65','67') = 0;
econmake.FX('65','68') = 0;
econmake.FX('65','69') = 0;
econmake.FX('65','70') = 0;
econmake.FX('65','71') = 0;
econmake.FX('65','72') = 0;
econmake.FX('65','73') = 0;
econmake.FX('65','74') = 0;
econmake.FX('66','1') = 0;
econmake.FX('66','2') = 0;
econmake.FX('66','3') = 0;
econmake.FX('66','4') = 0;
econmake.FX('66','5') = 0;
econmake.FX('66','6') = 0;
econmake.FX('66','7') = 0;
econmake.FX('66','8') = 0;
econmake.FX('66','9') = 0;
econmake.FX('66','10') = 0;
econmake.FX('66','11') = 0;
econmake.FX('66','12') = 0;
econmake.FX('66','13') = 0;
econmake.FX('66','14') = 0;
econmake.FX('66','15') = 0;
econmake.FX('66','16') = 0;
econmake.FX('66','17') = 0;
econmake.FX('66','18') = 0;
econmake.FX('66','19') = 0;
econmake.FX('66','20') = 0;
econmake.FX('66','21') = 0;
econmake.FX('66','22') = 0;
econmake.FX('66','23') = 0;
econmake.FX('66','24') = 0;
econmake.FX('66','25') = 0;
econmake.FX('66','26') = 0;
econmake.FX('66','27') = 0;
econmake.FX('66','28') = 0;
econmake.FX('66','29') = 0;
econmake.FX('66','30') = 0;
econmake.FX('66','31') = 0;
econmake.FX('66','32') = 0;
econmake.FX('66','33') = 0;
econmake.FX('66','34') = 0;
econmake.FX('66','35') = 0;
econmake.FX('66','36') = 0;
econmake.FX('66','37') = 0;
econmake.FX('66','38') = 0;
econmake.FX('66','39') = 0;
econmake.FX('66','40') = 0;
econmake.FX('66','41') = 0;
econmake.FX('66','42') = 0;
econmake.FX('66','43') = 0;
econmake.FX('66','44') = 0;
econmake.FX('66','45') = 0;
econmake.FX('66','46') = 0;
econmake.FX('66','47') = 0;
econmake.FX('66','48') = 0;
econmake.FX('66','49') = 0;
econmake.FX('66','50') = 0;
econmake.FX('66','51') = 0;
econmake.FX('66','52') = 0;
econmake.FX('66','53') = 0;
econmake.FX('66','54') = 0;
econmake.FX('66','55') = 0;
econmake.FX('66','56') = 0;
econmake.FX('66','57') = 0;
econmake.FX('66','58') = 0;
econmake.FX('66','59') = 0;
econmake.FX('66','60') = 0;
econmake.FX('66','61') = 0;
econmake.FX('66','62') = 0;
econmake.FX('66','63') = 0;
econmake.FX('66','64') = 0;
econmake.FX('66','65') = 0;
econmake.FX('66','66') = 7.596230e+004;
econmake.FX('66','67') = 0;
econmake.FX('66','68') = 0;
econmake.FX('66','69') = 0;
econmake.FX('66','70') = 0;
econmake.FX('66','71') = 0;
econmake.FX('66','72') = 0;
econmake.FX('66','73') = 0;
econmake.FX('66','74') = 0;
econmake.FX('67','1') = 0;
econmake.FX('67','2') = 0;
econmake.FX('67','3') = 0;
econmake.FX('67','4') = 0;
econmake.FX('67','5') = 0;
econmake.FX('67','6') = 0;
econmake.FX('67','7') = 0;
econmake.FX('67','8') = 0;
econmake.FX('67','9') = 0;
econmake.FX('67','10') = 0;
econmake.FX('67','11') = 0;
econmake.FX('67','12') = 0;
econmake.FX('67','13') = 0;
econmake.FX('67','14') = 0;
econmake.FX('67','15') = 0;
econmake.FX('67','16') = 0;
econmake.FX('67','17') = 0;
econmake.FX('67','18') = 0;
econmake.FX('67','19') = 0;
econmake.FX('67','20') = 0;
econmake.FX('67','21') = 0;
econmake.FX('67','22') = 0;
econmake.FX('67','23') = 0;
econmake.FX('67','24') = 0;
econmake.FX('67','25') = 0;
econmake.FX('67','26') = 0;
econmake.FX('67','27') = 0;
econmake.FX('67','28') = 0;
econmake.FX('67','29') = 0;
econmake.FX('67','30') = 0;
econmake.FX('67','31') = 0;
econmake.FX('67','32') = 0;
econmake.FX('67','33') = 0;
econmake.FX('67','34') = 0;
econmake.FX('67','35') = 0;
econmake.FX('67','36') = 0;
econmake.FX('67','37') = 0;
econmake.FX('67','38') = 0;
econmake.FX('67','39') = 0;
econmake.FX('67','40') = 0;
econmake.FX('67','41') = 0;
econmake.FX('67','42') = 0;
econmake.FX('67','43') = 0;
econmake.FX('67','44') = 0;
econmake.FX('67','45') = 0;
econmake.FX('67','46') = 0;
econmake.FX('67','47') = 0;
econmake.FX('67','48') = 0;
econmake.FX('67','49') = 0;
econmake.FX('67','50') = 0;
econmake.FX('67','51') = 0;
econmake.FX('67','52') = 0;
econmake.FX('67','53') = 0;
econmake.FX('67','54') = 0;
econmake.FX('67','55') = 0;
econmake.FX('67','56') = 0;
econmake.FX('67','57') = 0;
econmake.FX('67','58') = 0;
econmake.FX('67','59') = 0;
econmake.FX('67','60') = 0;
econmake.FX('67','61') = 0;
econmake.FX('67','62') = 0;
econmake.FX('67','63') = 0;
econmake.FX('67','64') = 0;
econmake.FX('67','65') = 0;
econmake.FX('67','66') = 0;
econmake.FX('67','67') = 9.243770e+004;
econmake.FX('67','68') = 0;
econmake.FX('67','69') = 0;
econmake.FX('67','70') = 0;
econmake.FX('67','71') = 0;
econmake.FX('67','72') = 0;
econmake.FX('67','73') = 0;
econmake.FX('67','74') = 0;
econmake.FX('68','1') = 0;
econmake.FX('68','2') = 0;
econmake.FX('68','3') = 0;
econmake.FX('68','4') = 0;
econmake.FX('68','5') = 0;
econmake.FX('68','6') = 0;
econmake.FX('68','7') = 0;
econmake.FX('68','8') = 0;
econmake.FX('68','9') = 0;
econmake.FX('68','10') = 0;
econmake.FX('68','11') = 0;
econmake.FX('68','12') = 0;
econmake.FX('68','13') = 0;
econmake.FX('68','14') = 0;
econmake.FX('68','15') = 0;
econmake.FX('68','16') = 0;
econmake.FX('68','17') = 0;
econmake.FX('68','18') = 0;
econmake.FX('68','19') = 0;
econmake.FX('68','20') = 0;
econmake.FX('68','21') = 0;
econmake.FX('68','22') = 0;
econmake.FX('68','23') = 0;
econmake.FX('68','24') = 0;
econmake.FX('68','25') = 0;
econmake.FX('68','26') = 0;
econmake.FX('68','27') = 0;
econmake.FX('68','28') = 0;
econmake.FX('68','29') = 0;
econmake.FX('68','30') = 0;
econmake.FX('68','31') = 0;
econmake.FX('68','32') = 0;
econmake.FX('68','33') = 0;
econmake.FX('68','34') = 0;
econmake.FX('68','35') = 0;
econmake.FX('68','36') = 0;
econmake.FX('68','37') = 0;
econmake.FX('68','38') = 0;
econmake.FX('68','39') = 0;
econmake.FX('68','40') = 0;
econmake.FX('68','41') = 0;
econmake.FX('68','42') = 0;
econmake.FX('68','43') = 0;
econmake.FX('68','44') = 0;
econmake.FX('68','45') = 0;
econmake.FX('68','46') = 0;
econmake.FX('68','47') = 0;
econmake.FX('68','48') = 0;
econmake.FX('68','49') = 0;
econmake.FX('68','50') = 0;
econmake.FX('68','51') = 0;
econmake.FX('68','52') = 0;
econmake.FX('68','53') = 6.205700e+003;
econmake.FX('68','54') = 0;
econmake.FX('68','55') = 0;
econmake.FX('68','56') = 0;
econmake.FX('68','57') = 0;
econmake.FX('68','58') = 0;
econmake.FX('68','59') = 0;
econmake.FX('68','60') = 0;
econmake.FX('68','61') = 0;
econmake.FX('68','62') = 0;
econmake.FX('68','63') = 0;
econmake.FX('68','64') = 0;
econmake.FX('68','65') = 0;
econmake.FX('68','66') = 0;
econmake.FX('68','67') = 0;
econmake.FX('68','68') = 1.010926e+005;
econmake.FX('68','69') = 0;
econmake.FX('68','70') = 0;
econmake.FX('68','71') = 0;
econmake.FX('68','72') = 0;
econmake.FX('68','73') = 0;
econmake.FX('68','74') = 0;
econmake.FX('69','1') = 0;
econmake.FX('69','2') = 0;
econmake.FX('69','3') = 0;
econmake.FX('69','4') = 0;
econmake.FX('69','5') = 0;
econmake.FX('69','6') = 0;
econmake.FX('69','7') = 0;
econmake.FX('69','8') = 0;
econmake.FX('69','9') = 0;
econmake.FX('69','10') = 0;
econmake.FX('69','11') = 0;
econmake.FX('69','12') = 0;
econmake.FX('69','13') = 0;
econmake.FX('69','14') = 0;
econmake.FX('69','15') = 0;
econmake.FX('69','16') = 0;
econmake.FX('69','17') = 0;
econmake.FX('69','18') = 0;
econmake.FX('69','19') = 0;
econmake.FX('69','20') = 0;
econmake.FX('69','21') = 0;
econmake.FX('69','22') = 0;
econmake.FX('69','23') = 0;
econmake.FX('69','24') = 0;
econmake.FX('69','25') = 0;
econmake.FX('69','26') = 0;
econmake.FX('69','27') = 0;
econmake.FX('69','28') = 0;
econmake.FX('69','29') = 0;
econmake.FX('69','30') = 0;
econmake.FX('69','31') = 0;
econmake.FX('69','32') = 0;
econmake.FX('69','33') = 0;
econmake.FX('69','34') = 0;
econmake.FX('69','35') = 0;
econmake.FX('69','36') = 0;
econmake.FX('69','37') = 0;
econmake.FX('69','38') = 0;
econmake.FX('69','39') = 0;
econmake.FX('69','40') = 0;
econmake.FX('69','41') = 0;
econmake.FX('69','42') = 0;
econmake.FX('69','43') = 0;
econmake.FX('69','44') = 0;
econmake.FX('69','45') = 0;
econmake.FX('69','46') = 0;
econmake.FX('69','47') = 0;
econmake.FX('69','48') = 0;
econmake.FX('69','49') = 0;
econmake.FX('69','50') = 0;
econmake.FX('69','51') = 0;
econmake.FX('69','52') = 0;
econmake.FX('69','53') = 0;
econmake.FX('69','54') = 0;
econmake.FX('69','55') = 0;
econmake.FX('69','56') = 0;
econmake.FX('69','57') = 0;
econmake.FX('69','58') = 0;
econmake.FX('69','59') = 0;
econmake.FX('69','60') = 0;
econmake.FX('69','61') = 0;
econmake.FX('69','62') = 0;
econmake.FX('69','63') = 0;
econmake.FX('69','64') = 0;
econmake.FX('69','65') = 0;
econmake.FX('69','66') = 0;
econmake.FX('69','67') = 0;
econmake.FX('69','68') = 0;
econmake.FX('69','69') = 4.686657e+005;
econmake.FX('69','70') = 0;
econmake.FX('69','71') = 0;
econmake.FX('69','72') = 0;
econmake.FX('69','73') = 0;
econmake.FX('69','74') = 0;
econmake.FX('70','1') = 0;
econmake.FX('70','2') = 0;
econmake.FX('70','3') = 0;
econmake.FX('70','4') = 0;
econmake.FX('70','5') = 0;
econmake.FX('70','6') = 0;
econmake.FX('70','7') = 0;
econmake.FX('70','8') = 0;
econmake.FX('70','9') = 0;
econmake.FX('70','10') = 0;
econmake.FX('70','11') = 0;
econmake.FX('70','12') = 0;
econmake.FX('70','13') = 0;
econmake.FX('70','14') = 0;
econmake.FX('70','15') = 0;
econmake.FX('70','16') = 0;
econmake.FX('70','17') = 0;
econmake.FX('70','18') = 0;
econmake.FX('70','19') = 0;
econmake.FX('70','20') = 0;
econmake.FX('70','21') = 0;
econmake.FX('70','22') = 0;
econmake.FX('70','23') = 0;
econmake.FX('70','24') = 0;
econmake.FX('70','25') = 0;
econmake.FX('70','26') = 0;
econmake.FX('70','27') = 0;
econmake.FX('70','28') = 0;
econmake.FX('70','29') = 0;
econmake.FX('70','30') = 0;
econmake.FX('70','31') = 0;
econmake.FX('70','32') = 0;
econmake.FX('70','33') = 0;
econmake.FX('70','34') = 0;
econmake.FX('70','35') = 0;
econmake.FX('70','36') = 0;
econmake.FX('70','37') = 0;
econmake.FX('70','38') = 0;
econmake.FX('70','39') = 0;
econmake.FX('70','40') = 0;
econmake.FX('70','41') = 0;
econmake.FX('70','42') = 0;
econmake.FX('70','43') = 0;
econmake.FX('70','44') = 0;
econmake.FX('70','45') = 0;
econmake.FX('70','46') = 0;
econmake.FX('70','47') = 0;
econmake.FX('70','48') = 0;
econmake.FX('70','49') = 0;
econmake.FX('70','50') = 0;
econmake.FX('70','51') = 0;
econmake.FX('70','52') = 0;
econmake.FX('70','53') = 0;
econmake.FX('70','54') = 0;
econmake.FX('70','55') = 0;
econmake.FX('70','56') = 0;
econmake.FX('70','57') = 0;
econmake.FX('70','58') = 0;
econmake.FX('70','59') = 4.010000e+001;
econmake.FX('70','60') = 0;
econmake.FX('70','61') = 0;
econmake.FX('70','62') = 0;
econmake.FX('70','63') = 0;
econmake.FX('70','64') = 0;
econmake.FX('70','65') = 0;
econmake.FX('70','66') = 0;
econmake.FX('70','67') = 0;
econmake.FX('70','68') = 0;
econmake.FX('70','69') = 0;
econmake.FX('70','70') = 5.669005e+005;
econmake.FX('70','71') = 0;
econmake.FX('70','72') = 0;
econmake.FX('70','73') = 0;
econmake.FX('70','74') = 0;
econmake.FX('71','1') = 0;
econmake.FX('71','2') = 0;
econmake.FX('71','3') = 0;
econmake.FX('71','4') = 0;
econmake.FX('71','5') = 0;
econmake.FX('71','6') = 0;
econmake.FX('71','7') = 0;
econmake.FX('71','8') = 0;
econmake.FX('71','9') = 0;
econmake.FX('71','10') = 0;
econmake.FX('71','11') = 0;
econmake.FX('71','12') = 0;
econmake.FX('71','13') = 0;
econmake.FX('71','14') = 0;
econmake.FX('71','15') = 0;
econmake.FX('71','16') = 0;
econmake.FX('71','17') = 0;
econmake.FX('71','18') = 0;
econmake.FX('71','19') = 0;
econmake.FX('71','20') = 0;
econmake.FX('71','21') = 0;
econmake.FX('71','22') = 0;
econmake.FX('71','23') = 0;
econmake.FX('71','24') = 0;
econmake.FX('71','25') = 0;
econmake.FX('71','26') = 0;
econmake.FX('71','27') = 0;
econmake.FX('71','28') = 0;
econmake.FX('71','29') = 0;
econmake.FX('71','30') = 0;
econmake.FX('71','31') = 0;
econmake.FX('71','32') = 0;
econmake.FX('71','33') = 0;
econmake.FX('71','34') = 0;
econmake.FX('71','35') = 0;
econmake.FX('71','36') = 0;
econmake.FX('71','37') = 0;
econmake.FX('71','38') = 0;
econmake.FX('71','39') = 0;
econmake.FX('71','40') = 0;
econmake.FX('71','41') = 0;
econmake.FX('71','42') = 0;
econmake.FX('71','43') = 0;
econmake.FX('71','44') = 0;
econmake.FX('71','45') = 0;
econmake.FX('71','46') = 0;
econmake.FX('71','47') = 0;
econmake.FX('71','48') = 0;
econmake.FX('71','49') = 0;
econmake.FX('71','50') = 0;
econmake.FX('71','51') = 0;
econmake.FX('71','52') = 0;
econmake.FX('71','53') = 0;
econmake.FX('71','54') = 0;
econmake.FX('71','55') = 0;
econmake.FX('71','56') = 0;
econmake.FX('71','57') = 0;
econmake.FX('71','58') = 0;
econmake.FX('71','59') = 0;
econmake.FX('71','60') = 0;
econmake.FX('71','61') = 0;
econmake.FX('71','62') = 0;
econmake.FX('71','63') = 0;
econmake.FX('71','64') = 0;
econmake.FX('71','65') = 0;
econmake.FX('71','66') = 0;
econmake.FX('71','67') = 0;
econmake.FX('71','68') = 0;
econmake.FX('71','69') = 0;
econmake.FX('71','70') = 0;
econmake.FX('71','71') = 5.906529e+005;
econmake.FX('71','72') = 0;
econmake.FX('71','73') = 0;
econmake.FX('71','74') = 0;
econmake.FX('72','1') = 0;
econmake.FX('72','2') = 0;
econmake.FX('72','3') = 0;
econmake.FX('72','4') = 0;
econmake.FX('72','5') = 0;
econmake.FX('72','6') = 0;
econmake.FX('72','7') = 0;
econmake.FX('72','8') = 0;
econmake.FX('72','9') = 0;
econmake.FX('72','10') = 9.795500e+003;
econmake.FX('72','11') = 0;
econmake.FX('72','12') = 0;
econmake.FX('72','13') = 0;
econmake.FX('72','14') = 0;
econmake.FX('72','15') = 0;
econmake.FX('72','16') = 0;
econmake.FX('72','17') = 0;
econmake.FX('72','18') = 0;
econmake.FX('72','19') = 0;
econmake.FX('72','20') = 0;
econmake.FX('72','21') = 0;
econmake.FX('72','22') = 0;
econmake.FX('72','23') = 0;
econmake.FX('72','24') = 0;
econmake.FX('72','25') = 0;
econmake.FX('72','26') = 0;
econmake.FX('72','27') = 0;
econmake.FX('72','28') = 0;
econmake.FX('72','29') = 0;
econmake.FX('72','30') = 0;
econmake.FX('72','31') = 0;
econmake.FX('72','32') = 0;
econmake.FX('72','33') = 0;
econmake.FX('72','34') = 0;
econmake.FX('72','35') = 0;
econmake.FX('72','36') = 1.524100e+003;
econmake.FX('72','37') = 0;
econmake.FX('72','38') = 0;
econmake.FX('72','39') = 0;
econmake.FX('72','40') = 0;
econmake.FX('72','41') = 0;
econmake.FX('72','42') = 0;
econmake.FX('72','43') = 0;
econmake.FX('72','44') = 0;
econmake.FX('72','45') = 0;
econmake.FX('72','46') = 9.780000e+001;
econmake.FX('72','47') = 0;
econmake.FX('72','48') = 0;
econmake.FX('72','49') = 0;
econmake.FX('72','50') = 0;
econmake.FX('72','51') = 2.261000e+002;
econmake.FX('72','52') = 0;
econmake.FX('72','53') = 582;
econmake.FX('72','54') = 0;
econmake.FX('72','55') = 0;
econmake.FX('72','56') = 0;
econmake.FX('72','57') = 0;
econmake.FX('72','58') = 0;
econmake.FX('72','59') = 0;
econmake.FX('72','60') = 0;
econmake.FX('72','61') = 0;
econmake.FX('72','62') = 0;
econmake.FX('72','63') = 0;
econmake.FX('72','64') = 0;
econmake.FX('72','65') = 0;
econmake.FX('72','66') = 0;
econmake.FX('72','67') = 0;
econmake.FX('72','68') = 0;
econmake.FX('72','69') = 1.775600e+003;
econmake.FX('72','70') = 1;
econmake.FX('72','71') = 0;
econmake.FX('72','72') = 69471;
econmake.FX('72','73') = 0;
econmake.FX('72','74') = 0;
econmake.FX('73','1') = 0;
econmake.FX('73','2') = 0;
econmake.FX('73','3') = 0;
econmake.FX('73','4') = 2.155383e+002;
econmake.FX('73','5') = 1.704567e+003;
econmake.FX('73','6') = 0;
econmake.FX('73','7') = 0;
econmake.FX('73','8') = 0;
econmake.FX('73','9') = 0;
econmake.FX('73','10') = 0;
econmake.FX('73','11') = 0;
econmake.FX('73','12') = 6.571364e+002;
econmake.FX('73','13') = 0;
econmake.FX('73','14') = 0;
econmake.FX('73','15') = 0;
econmake.FX('73','16') = 0;
econmake.FX('73','17') = 0;
econmake.FX('73','18') = 0;
econmake.FX('73','19') = 0;
econmake.FX('73','20') = 0;
econmake.FX('73','21') = 0;
econmake.FX('73','22') = 0;
econmake.FX('73','23') = 0;
econmake.FX('73','24') = 0;
econmake.FX('73','25') = 0;
econmake.FX('73','26') = 0;
econmake.FX('73','27') = 0;
econmake.FX('73','28') = 0;
econmake.FX('73','29') = 0;
econmake.FX('73','30') = 0;
econmake.FX('73','31') = 0;
econmake.FX('73','32') = 0;
econmake.FX('73','33') = 0;
econmake.FX('73','34') = 0;
econmake.FX('73','35') = 0;
econmake.FX('73','36') = 0;
econmake.FX('73','37') = 0;
econmake.FX('73','38') = 0;
econmake.FX('73','39') = 0;
econmake.FX('73','40') = 0;
econmake.FX('73','41') = 0;
econmake.FX('73','42') = 0;
econmake.FX('73','43') = 0;
econmake.FX('73','44') = 0;
econmake.FX('73','45') = 0;
econmake.FX('73','46') = 0;
econmake.FX('73','47') = 0;
econmake.FX('73','48') = 8.459203e+002;
econmake.FX('73','49') = 0;
econmake.FX('73','50') = 0;
econmake.FX('73','51') = 0;
econmake.FX('73','52') = 0;
econmake.FX('73','53') = 0;
econmake.FX('73','54') = 2.976052e+002;
econmake.FX('73','55') = 0;
econmake.FX('73','56') = 0;
econmake.FX('73','57') = 5.001171e+002;
econmake.FX('73','58') = 0;
econmake.FX('73','59') = 1.427804e+003;
econmake.FX('73','60') = 8.820638e+003;
econmake.FX('73','61') = 5.447979e+004;
econmake.FX('73','62') = 2.228322e+004;
econmake.FX('73','63') = 9.946939e+004;
econmake.FX('73','64') = 0;
econmake.FX('73','65') = 1.563279e+003;
econmake.FX('73','66') = 1.867698e+003;
econmake.FX('73','67') = 1.870905e+003;
econmake.FX('73','68') = 5.718630e+002;
econmake.FX('73','69') = 0;
econmake.FX('73','70') = 0;
econmake.FX('73','71') = 0;
econmake.FX('73','72') = 0;
econmake.FX('73','73') = 1.044281e+006;
econmake.FX('73','74') = 0;
econmake.FX('74','1') = 0;
econmake.FX('74','2') = 0;
econmake.FX('74','3') = 0;
econmake.FX('74','4') = 0;
econmake.FX('74','5') = 0;
econmake.FX('74','6') = 0;
econmake.FX('74','7') = 0;
econmake.FX('74','8') = 0;
econmake.FX('74','9') = 0;
econmake.FX('74','10') = 2.180810e+004;
econmake.FX('74','11') = 5.576300e+003;
econmake.FX('74','12') = 3.397230e+004;
econmake.FX('74','13') = 0;
econmake.FX('74','14') = 0;
econmake.FX('74','15') = 0;
econmake.FX('74','16') = 0;
econmake.FX('74','17') = 0;
econmake.FX('74','18') = 0;
econmake.FX('74','19') = 0;
econmake.FX('74','20') = 0;
econmake.FX('74','21') = 0;
econmake.FX('74','22') = 0;
econmake.FX('74','23') = 0;
econmake.FX('74','24') = 0;
econmake.FX('74','25') = 0;
econmake.FX('74','26') = 0;
econmake.FX('74','27') = 0;
econmake.FX('74','28') = 0;
econmake.FX('74','29') = 0;
econmake.FX('74','30') = 0;
econmake.FX('74','31') = 0;
econmake.FX('74','32') = 0;
econmake.FX('74','33') = 0;
econmake.FX('74','34') = 0;
econmake.FX('74','35') = 0;
econmake.FX('74','36') = 1.451500e+003;
econmake.FX('74','37') = 0;
econmake.FX('74','38') = 8.440000e+001;
econmake.FX('74','39') = 1.637000e+002;
econmake.FX('74','40') = 0;
econmake.FX('74','41') = 8.959200e+003;
econmake.FX('74','42') = 0;
econmake.FX('74','43') = 6.950300e+003;
econmake.FX('74','44') = 0;
econmake.FX('74','45') = 0;
econmake.FX('74','46') = 0;
econmake.FX('74','47') = 0;
econmake.FX('74','48') = 0;
econmake.FX('74','49') = 5.860000e+001;
econmake.FX('74','50') = 0;
econmake.FX('74','51') = 1;
econmake.FX('74','52') = 0;
econmake.FX('74','53') = 1.499590e+004;
econmake.FX('74','54') = 0;
econmake.FX('74','55') = 0;
econmake.FX('74','56') = 0;
econmake.FX('74','57') = 0;
econmake.FX('74','58') = 0;
econmake.FX('74','59') = 0;
econmake.FX('74','60') = 0;
econmake.FX('74','61') = 0;
econmake.FX('74','62') = 0;
econmake.FX('74','63') = 0;
econmake.FX('74','64') = 0;
econmake.FX('74','65') = 0;
econmake.FX('74','66') = 4.691000e+002;
econmake.FX('74','67') = 1.449840e+004;
econmake.FX('74','68') = 0;
econmake.FX('74','69') = 0;
econmake.FX('74','70') = 1.425200e+003;
econmake.FX('74','71') = 0;
econmake.FX('74','72') = 0;
econmake.FX('74','73') = 0;
econmake.FX('74','74') = 5.109940e+004;


variable
econuse(m,n);
econuse.FX('1','1') = 1996;
econuse.FX('1','2') = 1.369200e+003;
econuse.FX('1','3') = 6.476000e+002;
econuse.FX('1','4') = 4.287700e+003;
econuse.FX('1','5') = 0;
econuse.FX('1','6') = 0;
econuse.FX('1','7') = 0;
econuse.FX('1','8') = 0;
econuse.FX('1','9') = 0;
econuse.FX('1','10') = 0;
econuse.FX('1','11') = 0;
econuse.FX('1','12') = 0;
econuse.FX('1','13') = 0;
econuse.FX('1','14') = 1.491720e+004;
econuse.FX('1','15') = 0;
econuse.FX('1','16') = 0;
econuse.FX('1','17') = 0;
econuse.FX('1','18') = 0;
econuse.FX('1','19') = 0;
econuse.FX('1','20') = 0;
econuse.FX('1','21') = 1.036000e+002;
econuse.FX('1','22') = 0;
econuse.FX('1','23') = 0;
econuse.FX('1','24') = 2.470000e+001;
econuse.FX('1','25') = 0;
econuse.FX('1','26') = 0;
econuse.FX('1','27') = 0;
econuse.FX('1','28') = 0;
econuse.FX('1','29') = 0;
econuse.FX('1','30') = 0;
econuse.FX('1','31') = 0;
econuse.FX('1','32') = 0;
econuse.FX('1','33') = 0;
econuse.FX('1','34') = 0;
econuse.FX('1','35') = 0;
econuse.FX('1','36') = 4.000000e-001;
econuse.FX('1','37') = 0;
econuse.FX('1','38') = 0;
econuse.FX('1','39') = 0;
econuse.FX('1','40') = 0;
econuse.FX('1','41') = 0;
econuse.FX('1','42') = 0;
econuse.FX('1','43') = 0;
econuse.FX('1','44') = 0;
econuse.FX('1','45') = 0;
econuse.FX('1','46') = 0;
econuse.FX('1','47') = 0;
econuse.FX('1','48') = 0;
econuse.FX('1','49') = 0;
econuse.FX('1','50') = 0;
econuse.FX('1','51') = 0;
econuse.FX('1','52') = 0;
econuse.FX('1','53') = 0;
econuse.FX('1','54') = 0;
econuse.FX('1','55') = 0;
econuse.FX('1','56') = 0;
econuse.FX('1','57') = 80;
econuse.FX('1','58') = 4.700000e+000;
econuse.FX('1','59') = 0;
econuse.FX('1','60') = 0;
econuse.FX('1','61') = 6.700000e+000;
econuse.FX('1','62') = 0;
econuse.FX('1','63') = 2.000000e-001;
econuse.FX('1','64') = 0;
econuse.FX('1','65') = 0;
econuse.FX('1','66') = 0;
econuse.FX('1','67') = 1.000000e-001;
econuse.FX('1','68') = 1.700000e+000;
econuse.FX('1','69') = 6.801000e+002;
econuse.FX('1','70') = 0;
econuse.FX('1','71') = 7.340000e+001;
econuse.FX('1','72') = 0;
econuse.FX('1','73') = 62;
econuse.FX('1','74') = 0;
econuse.FX('2','1') = 3.568000e+002;
econuse.FX('2','2') = 4.341400e+003;

equation ddgs94,ddgs95;
ddgs94.. econuse('2','3') =E= 2.197700e+003-(ddgs*360*86400*0.075/1000000);


econuse.FX('2','4') = 7.863300e+003;
econuse.FX('2','5') = 2.518000e+002;
econuse.FX('2','6') = 0;
econuse.FX('2','7') = 8.620000e+001;
econuse.FX('2','8') = 1.684000e+002;
econuse.FX('2','9') = 1.062000e+002;
econuse.FX('2','10') = 1.000000e-001;
econuse.FX('2','11') = 2.000000e-001;
econuse.FX('2','12') = 0;
econuse.FX('2','13') = 2.762900e+003;
econuse.FX('2','14') = 2.632590e+004;
econuse.FX('2','15') = 1.724800e+003;
econuse.FX('2','16') = 0;
econuse.FX('2','17') = 92;
econuse.FX('2','18') = 0;
econuse.FX('2','19') = 0;
econuse.FX('2','20') = 0;
econuse.FX('2','21') = 6.944000e+002;
econuse.FX('2','22') = 0;
econuse.FX('2','23') = 0;
econuse.FX('2','24') = 9.840000e+001;
econuse.FX('2','25') = 0;
econuse.FX('2','26') = 0;
econuse.FX('2','27') = 0;
econuse.FX('2','28') = 0;
econuse.FX('2','29') = 0;
econuse.FX('2','30') = 0;
econuse.FX('2','31') = 0;
econuse.FX('2','32') = 0;
econuse.FX('2','33') = 0;
econuse.FX('2','34') = 0;
econuse.FX('2','35') = 4.250000e+001;
econuse.FX('2','36') = 7.576000e+002;
econuse.FX('2','37') = 0;
econuse.FX('2','38') = 0;
econuse.FX('2','39') = 2.000000e-001;
econuse.FX('2','40') = 0;
econuse.FX('2','41') = 0;
econuse.FX('2','42') = 0;
econuse.FX('2','43') = 0;
econuse.FX('2','44') = 0;
econuse.FX('2','45') = 3.000000e-001;
econuse.FX('2','46') = 0;
econuse.FX('2','47') = 0;
econuse.FX('2','48') = 0;
econuse.FX('2','49') = 1.000000e-001;
econuse.FX('2','50') = 0;
econuse.FX('2','51') = 0;
econuse.FX('2','52') = 0;
econuse.FX('2','53') = 1.336800e+003;
econuse.FX('2','54') = 6.070000e+001;
econuse.FX('2','55') = 4.000000e-001;
econuse.FX('2','56') = 2.000000e-001;
econuse.FX('2','57') = 1.658000e+002;
econuse.FX('2','58') = 4.500000e+000;
econuse.FX('2','59') = 4.019000e+002;
econuse.FX('2','60') = 2.130000e+001;
econuse.FX('2','61') = 6.190000e+001;
econuse.FX('2','62') = 6.000000e-001;
econuse.FX('2','63') = 6.700000e+000;
econuse.FX('2','64') = 1.180000e+001;
econuse.FX('2','65') = 0;
econuse.FX('2','66') = 6.300000e+000;
econuse.FX('2','67') = 7.960000e+001;
econuse.FX('2','68') = 8.300000e+000;
econuse.FX('2','69') = 4.324000e+002;
econuse.FX('2','70') = 2.210000e+001;
econuse.FX('2','71') = 6.560000e+001;
econuse.FX('2','72') = 9.100000e+000;
econuse.FX('2','73') = 802;
econuse.FX('2','74') = 0;
econuse.FX('3','1') = 0;
econuse.FX('3','2') = 0;
econuse.FX('3','3') = 4.120000e+001;
econuse.FX('3','4') = 9.620000e+001;
econuse.FX('3','5') = 0;
econuse.FX('3','6') = 0;
econuse.FX('3','7') = 0;
econuse.FX('3','8') = 0;
econuse.FX('3','9') = 0;
econuse.FX('3','10') = 0;
econuse.FX('3','11') = 0;
econuse.FX('3','12') = 0;
econuse.FX('3','13') = 0;
econuse.FX('3','14') = 2.060350e+004;
econuse.FX('3','15') = 0;
econuse.FX('3','16') = 0;
econuse.FX('3','17') = 0;
econuse.FX('3','18') = 0;
econuse.FX('3','19') = 0;
econuse.FX('3','20') = 0;
econuse.FX('3','21') = 0;
econuse.FX('3','22') = 0;
econuse.FX('3','23') = 0;
econuse.FX('3','24') = 0;
econuse.FX('3','25') = 0;
econuse.FX('3','26') = 0;
econuse.FX('3','27') = 0;
econuse.FX('3','28') = 0;
econuse.FX('3','29') = 0;
econuse.FX('3','30') = 0;
econuse.FX('3','31') = 0;
econuse.FX('3','32') = 0;
econuse.FX('3','33') = 0;
econuse.FX('3','34') = 0;
econuse.FX('3','35') = 0;
econuse.FX('3','36') = 0;
econuse.FX('3','37') = 0;
econuse.FX('3','38') = 0;
econuse.FX('3','39') = 0;
econuse.FX('3','40') = 0;
econuse.FX('3','41') = 0;
econuse.FX('3','42') = 0;
econuse.FX('3','43') = 0;
econuse.FX('3','44') = 0;
econuse.FX('3','45') = 0;
econuse.FX('3','46') = 0;
econuse.FX('3','47') = 0;
econuse.FX('3','48') = 0;
econuse.FX('3','49') = 0;
econuse.FX('3','50') = 0;
econuse.FX('3','51') = 0;
econuse.FX('3','52') = 0;
econuse.FX('3','53') = 0;
econuse.FX('3','54') = 0;
econuse.FX('3','55') = 0;
econuse.FX('3','56') = 0;
econuse.FX('3','57') = 2.300000e+000;
econuse.FX('3','58') = 0;
econuse.FX('3','59') = 0;
econuse.FX('3','60') = 0;
econuse.FX('3','61') = 0;
econuse.FX('3','62') = 0;
econuse.FX('3','63') = 0;
econuse.FX('3','64') = 0;
econuse.FX('3','65') = 0;
econuse.FX('3','66') = 0;
econuse.FX('3','67') = 0;
econuse.FX('3','68') = 0;
econuse.FX('3','69') = 0;
econuse.FX('3','70') = 0;
econuse.FX('3','71') = 0;
econuse.FX('3','72') = 0;
econuse.FX('3','73') = 0;
econuse.FX('3','74') = 0;
econuse.FX('4','1') = 1.429000e+002;
econuse.FX('4','2') = 2.257000e+002;
econuse.FX('4','3') = 5.647000e+002;
econuse.FX('4','4') = 1.893350e+004;
econuse.FX('4','5') = 436;
econuse.FX('4','6') = 0;
econuse.FX('4','7') = 0;
econuse.FX('4','8') = 0;
econuse.FX('4','9') = 0;
econuse.FX('4','10') = 0;
econuse.FX('4','11') = 0;
econuse.FX('4','12') = 0;
econuse.FX('4','13') = 0;
econuse.FX('4','14') = 5.427980e+004;
econuse.FX('4','15') = 2.893000e+002;
econuse.FX('4','16') = 0;
econuse.FX('4','17') = 0;
econuse.FX('4','18') = 0;
econuse.FX('4','19') = 0;
econuse.FX('4','20') = 0;
econuse.FX('4','21') = 0;
econuse.FX('4','22') = 0;
econuse.FX('4','23') = 0;
econuse.FX('4','24') = 0;
econuse.FX('4','25') = 0;
econuse.FX('4','26') = 0;
econuse.FX('4','27') = 0;
econuse.FX('4','28') = 0;
econuse.FX('4','29') = 0;
econuse.FX('4','30') = 0;
econuse.FX('4','31') = 0;
econuse.FX('4','32') = 0;
econuse.FX('4','33') = 0;
econuse.FX('4','34') = 0;
econuse.FX('4','35') = 1.600000e+000;
econuse.FX('4','36') = 1.200000e+000;
econuse.FX('4','37') = 0;
econuse.FX('4','38') = 0;
econuse.FX('4','39') = 0;
econuse.FX('4','40') = 0;
econuse.FX('4','41') = 0;
econuse.FX('4','42') = 0;
econuse.FX('4','43') = 1.580000e+001;
econuse.FX('4','44') = 0;
econuse.FX('4','45') = 0;
econuse.FX('4','46') = 0;
econuse.FX('4','47') = 0;
econuse.FX('4','48') = 0;
econuse.FX('4','49') = 0;
econuse.FX('4','50') = 0;
econuse.FX('4','51') = 0;
econuse.FX('4','52') = 0;
econuse.FX('4','53') = 0;
econuse.FX('4','54') = 0;
econuse.FX('4','55') = 0;
econuse.FX('4','56') = 0;
econuse.FX('4','57') = 1.179000e+002;
econuse.FX('4','58') = 2.300000e+000;
econuse.FX('4','59') = 7.000000e-001;
econuse.FX('4','60') = 0;
econuse.FX('4','61') = 4.560000e+001;
econuse.FX('4','62') = 0;
econuse.FX('4','63') = 1.300000e+000;
econuse.FX('4','64') = 1.800000e+000;
econuse.FX('4','65') = 0;
econuse.FX('4','66') = 4.900000e+000;
econuse.FX('4','67') = 6.390000e+001;
econuse.FX('4','68') = 1.900000e+000;
econuse.FX('4','69') = 509;
econuse.FX('4','70') = 0;
econuse.FX('4','71') = 4.500000e+000;
econuse.FX('4','72') = 0;
econuse.FX('4','73') = 1.627000e+002;
econuse.FX('4','74') = 0;
econuse.FX('5','1') = 2.554500e+003;
econuse.FX('5','2') = 8.206400e+003;
econuse.FX('5','3') = 5.029000e+002;
econuse.FX('5','4') = 1.245500e+003;
econuse.FX('5','5') = 1.576670e+004;
econuse.FX('5','6') = 0;
econuse.FX('5','7') = 0;
econuse.FX('5','8') = 0;
econuse.FX('5','9') = 0;
econuse.FX('5','10') = 0;
econuse.FX('5','11') = 0;
econuse.FX('5','12') = 0;
econuse.FX('5','13') = 0;
econuse.FX('5','14') = 4.124700e+003;
econuse.FX('5','15') = 0;
econuse.FX('5','16') = 1.030000e+001;
econuse.FX('5','17') = 1.646820e+004;
econuse.FX('5','18') = 4692;
econuse.FX('5','19') = 1.030000e+001;
econuse.FX('5','20') = 1.700000e+000;
econuse.FX('5','21') = 2.170000e+001;
econuse.FX('5','22') = 2.370000e+001;
econuse.FX('5','23') = 3.870000e+001;
econuse.FX('5','24') = 4.710000e+001;
econuse.FX('5','25') = 941;
econuse.FX('5','26') = 7.000000e-001;
econuse.FX('5','27') = 0;
econuse.FX('5','28') = 0;
econuse.FX('5','29') = 0;
econuse.FX('5','30') = 0;
econuse.FX('5','31') = 7.600000e+000;
econuse.FX('5','32') = 2.800000e+000;
econuse.FX('5','33') = 0;
econuse.FX('5','34') = 5.440000e+001;
econuse.FX('5','35') = 7.290000e+001;
econuse.FX('5','36') = 2.189000e+002;
econuse.FX('5','37') = 0;
econuse.FX('5','38') = 0;
econuse.FX('5','39') = 2;
econuse.FX('5','40') = 0;
econuse.FX('5','41') = 0;
econuse.FX('5','42') = 0;
econuse.FX('5','43') = 9.000000e-001;
econuse.FX('5','44') = 0;
econuse.FX('5','45') = 0;
econuse.FX('5','46') = 0;
econuse.FX('5','47') = 0;
econuse.FX('5','48') = 0;
econuse.FX('5','49') = 0;
econuse.FX('5','50') = 0;
econuse.FX('5','51') = 0;
econuse.FX('5','52') = 0;
econuse.FX('5','53') = 0;
econuse.FX('5','54') = 0;
econuse.FX('5','55') = 0;
econuse.FX('5','56') = 0;
econuse.FX('5','57') = 8.070000e+001;
econuse.FX('5','58') = 3.300000e+000;
econuse.FX('5','59') = 4.000000e-001;
econuse.FX('5','60') = 0;
econuse.FX('5','61') = 42;
econuse.FX('5','62') = 0;
econuse.FX('5','63') = 2.450000e+001;
econuse.FX('5','64') = 2.420000e+001;
econuse.FX('5','65') = 1.360000e+001;
econuse.FX('5','66') = 1.100000e+000;
econuse.FX('5','67') = 8.480000e+001;
econuse.FX('5','68') = 1.005000e+002;
econuse.FX('5','69') = 2881;
econuse.FX('5','70') = 6.380000e+001;
econuse.FX('5','71') = 0;
econuse.FX('5','72') = 2.400000e+000;
econuse.FX('5','73') = 4.709000e+002;
econuse.FX('5','74') = 0;
econuse.FX('6','1') = 0;
econuse.FX('6','2') = 0;
econuse.FX('6','3') = 0;
econuse.FX('6','4') = 0;
econuse.FX('6','5') = 0;
econuse.FX('6','6') = 1.989900e+003;
econuse.FX('6','7') = 2.000000e-001;
econuse.FX('6','8') = 6.000000e-001;
econuse.FX('6','9') = 1.000000e-001;
econuse.FX('6','10') = 1.385750e+004;
econuse.FX('6','11') = 3.472820e+004;
econuse.FX('6','12') = 0;
econuse.FX('6','13') = 0;
econuse.FX('6','14') = 6.200000e+000;
econuse.FX('6','15') = 2.300000e+000;
econuse.FX('6','16') = 0;
econuse.FX('6','17') = 5.100000e+000;
econuse.FX('6','18') = 5.100000e+000;
econuse.FX('6','19') = 9.000000e-001;
econuse.FX('6','20') = 1.260924e+005;
econuse.FX('6','21') = 4.738000e+002;
econuse.FX('6','22') = 3.830000e+001;
econuse.FX('6','23') = 3.700000e+000;
econuse.FX('6','24') = 6.075000e+002;
econuse.FX('6','25') = 5;
econuse.FX('6','26') = 1.700000e+000;
econuse.FX('6','27') = 4;
econuse.FX('6','28') = 1.800000e+000;
econuse.FX('6','29') = 2.600000e+000;
econuse.FX('6','30') = 0;
econuse.FX('6','31') = 4.000000e-001;
econuse.FX('6','32') = 3.200000e+000;
econuse.FX('6','33') = 2.000000e-001;
econuse.FX('6','34') = 1;
econuse.FX('6','35') = 6.000000e-001;
econuse.FX('6','36') = 1.373000e+002;
econuse.FX('6','37') = 0;
econuse.FX('6','38') = 0;
econuse.FX('6','39') = 0;
econuse.FX('6','40') = 2.000000e-001;
econuse.FX('6','41') = 0;
econuse.FX('6','42') = 1.101900e+003;
econuse.FX('6','43') = 0;
econuse.FX('6','44') = 5.600000e+000;
econuse.FX('6','45') = 3.700000e+000;
econuse.FX('6','46') = 1.800000e+000;
econuse.FX('6','47') = 8.650000e+001;
econuse.FX('6','48') = 1.200000e+000;
econuse.FX('6','49') = 0;
econuse.FX('6','50') = 2.200000e+000;
econuse.FX('6','51') = 4.700000e+000;
econuse.FX('6','52') = 0;
econuse.FX('6','53') = 5.700000e+000;
econuse.FX('6','54') = 1.019000e+002;
econuse.FX('6','55') = 4;
econuse.FX('6','56') = 1.500000e+000;
econuse.FX('6','57') = 1.008000e+002;
econuse.FX('6','58') = 3.990000e+001;
econuse.FX('6','59') = 2.670000e+001;
econuse.FX('6','60') = 6.900000e+000;
econuse.FX('6','61') = 4;
econuse.FX('6','62') = 1.690000e+001;
econuse.FX('6','63') = 6.900000e+000;
econuse.FX('6','64') = 3.030000e+001;
econuse.FX('6','65') = 1.340000e+001;
econuse.FX('6','66') = 4.700000e+000;
econuse.FX('6','67') = 1.450000e+001;
econuse.FX('6','68') = 4.240000e+001;
econuse.FX('6','69') = 9.550000e+001;
econuse.FX('6','70') = 5.350000e+001;
econuse.FX('6','71') = 0;
econuse.FX('6','72') = 4.420000e+001;
econuse.FX('6','73') = 0;
econuse.FX('6','74') = 3.326500e+003;
econuse.FX('7','1') = 0;
econuse.FX('7','2') = 0;
econuse.FX('7','3') = 0;
econuse.FX('7','4') = 1.184000e+002;
econuse.FX('7','5') = 4.000000e-001;
econuse.FX('7','6') = 1.254000e+002;
econuse.FX('7','7') = 1.199400e+003;
econuse.FX('7','8') = 1.237000e+002;
econuse.FX('7','9') = 3.420000e+001;
econuse.FX('7','10') = 13182;
econuse.FX('7','11') = 0;
econuse.FX('7','12') = 0;
econuse.FX('7','13') = 0;
econuse.FX('7','14') = 3.082000e+002;
econuse.FX('7','15') = 29;
econuse.FX('7','16') = 1.600000e+000;
econuse.FX('7','17') = 2;
econuse.FX('7','18') = 2.812000e+002;
econuse.FX('7','19') = 0;
econuse.FX('7','20') = 1.078000e+002;
econuse.FX('7','21') = 3.720000e+001;
econuse.FX('7','22') = 5.900000e+000;
econuse.FX('7','23') = 6.000000e-001;
econuse.FX('7','24') = 6.980000e+001;
econuse.FX('7','25') = 26;
econuse.FX('7','26') = 3.164000e+002;
econuse.FX('7','27') = 1.451800e+003;
econuse.FX('7','28') = 2.200000e+000;
econuse.FX('7','29') = 3.600000e+000;
econuse.FX('7','30') = 0;
econuse.FX('7','31') = 1.800000e+000;
econuse.FX('7','32') = 1.030000e+001;
econuse.FX('7','33') = 6.000000e-001;
econuse.FX('7','34') = 1.900000e+000;
econuse.FX('7','35') = 0;
econuse.FX('7','36') = 1.070000e+001;
econuse.FX('7','37') = 0;
econuse.FX('7','38') = 0;
econuse.FX('7','39') = 9.200000e+000;
econuse.FX('7','40') = 0;
econuse.FX('7','41') = 0;
econuse.FX('7','42') = 0;
econuse.FX('7','43') = 5.000000e-001;
econuse.FX('7','44') = 2.600000e+000;
econuse.FX('7','45') = 2.000000e-001;
econuse.FX('7','46') = 1.000000e-001;
econuse.FX('7','47') = 5.100000e+000;
econuse.FX('7','48') = 0;
econuse.FX('7','49') = 4.000000e-001;
econuse.FX('7','50') = 2.000000e-001;
econuse.FX('7','51') = 3.000000e-001;
econuse.FX('7','52') = 0;
econuse.FX('7','53') = 4.690000e+001;
econuse.FX('7','54') = 7.400000e+000;
econuse.FX('7','55') = 3.000000e-001;
econuse.FX('7','56') = 1.000000e-001;
econuse.FX('7','57') = 49;
econuse.FX('7','58') = 2.900000e+000;
econuse.FX('7','59') = 1.800000e+000;
econuse.FX('7','60') = 5.000000e-001;
econuse.FX('7','61') = 3.000000e-001;
econuse.FX('7','62') = 1.200000e+000;
econuse.FX('7','63') = 6.000000e-001;
econuse.FX('7','64') = 1.900000e+000;
econuse.FX('7','65') = 9.000000e-001;
econuse.FX('7','66') = 2.000000e-001;
econuse.FX('7','67') = 1.200000e+000;
econuse.FX('7','68') = 2.700000e+000;
econuse.FX('7','69') = 1.680000e+001;
econuse.FX('7','70') = 3.200000e+000;
econuse.FX('7','71') = 6.750000e+001;
econuse.FX('7','72') = 0;
econuse.FX('7','73') = 5.070000e+001;
econuse.FX('7','74') = 2.845100e+003;
econuse.FX('8','1') = 1.832000e+002;
econuse.FX('8','2') = 3.237000e+002;
econuse.FX('8','3') = 37;
econuse.FX('8','4') = 39;
econuse.FX('8','5') = 1.500000e+000;
econuse.FX('8','6') = 0;
econuse.FX('8','7') = 4.183000e+002;
econuse.FX('8','8') = 1.627300e+003;
econuse.FX('8','9') = 7.900000e+000;
econuse.FX('8','10') = 0;
econuse.FX('8','11') = 0;
econuse.FX('8','12') = 2.230000e+001;
econuse.FX('8','13') = 9.233500e+003;
econuse.FX('8','14') = 0;
econuse.FX('8','15') = 0;
econuse.FX('8','16') = 0;
econuse.FX('8','17') = 0;
econuse.FX('8','18') = 2.478000e+002;
econuse.FX('8','19') = 0;
econuse.FX('8','20') = 1.016000e+002;
econuse.FX('8','21') = 3.110000e+001;
econuse.FX('8','22') = 5.417000e+002;
econuse.FX('8','23') = 0;
econuse.FX('8','24') = 1.478900e+003;
econuse.FX('8','25') = 0;
econuse.FX('8','26') = 3.813600e+003;
econuse.FX('8','27') = 3.143400e+003;
econuse.FX('8','28') = 1.069000e+002;
econuse.FX('8','29') = 9.820000e+001;
econuse.FX('8','30') = 5.500000e+000;
econuse.FX('8','31') = 1.716000e+002;
econuse.FX('8','32') = 9.567000e+002;
econuse.FX('8','33') = 0;
econuse.FX('8','34') = 1.250000e+001;
econuse.FX('8','35') = 1.049000e+002;
econuse.FX('8','36') = 6.000000e-001;
econuse.FX('8','37') = 0;
econuse.FX('8','38') = 2.340000e+001;
econuse.FX('8','39') = 0;
econuse.FX('8','40') = 0;
econuse.FX('8','41') = 0;
econuse.FX('8','42') = 0;
econuse.FX('8','43') = 0;
econuse.FX('8','44') = 0;
econuse.FX('8','45') = 2.690000e+001;
econuse.FX('8','46') = 24;
econuse.FX('8','47') = 70;
econuse.FX('8','48') = 4.430000e+001;
econuse.FX('8','49') = 0;
econuse.FX('8','50') = 0;
econuse.FX('8','51') = 0;
econuse.FX('8','52') = 0;
econuse.FX('8','53') = 4.881000e+002;
econuse.FX('8','54') = 6.090000e+001;
econuse.FX('8','55') = 0;
econuse.FX('8','56') = 0;
econuse.FX('8','57') = 1.472000e+002;
econuse.FX('8','58') = 3.400000e+000;
econuse.FX('8','59') = 2.790000e+001;
econuse.FX('8','60') = 4.200000e+000;
econuse.FX('8','61') = 4.460000e+001;
econuse.FX('8','62') = 110;
econuse.FX('8','63') = 5.100000e+000;
econuse.FX('8','64') = 9.300000e+000;
econuse.FX('8','65') = 5.040000e+001;
econuse.FX('8','66') = 1.240000e+001;
econuse.FX('8','67') = 1.368000e+002;
econuse.FX('8','68') = 3.200000e+000;
econuse.FX('8','69') = 1.650000e+001;
econuse.FX('8','70') = 1.225000e+002;
econuse.FX('8','71') = 5.410000e+001;
econuse.FX('8','72') = 0;
econuse.FX('8','73') = 5.621000e+002;
econuse.FX('8','74') = 9.586000e+002;
econuse.FX('9','1') = 0;
econuse.FX('9','2') = 0;
econuse.FX('9','3') = 0;
econuse.FX('9','4') = 0;
econuse.FX('9','5') = 0;
econuse.FX('9','6') = 1.569900e+003;
econuse.FX('9','7') = 4.633000e+002;
econuse.FX('9','8') = 783;
econuse.FX('9','9') = 2.675000e+002;
econuse.FX('9','10') = 0;
econuse.FX('9','11') = 0;
econuse.FX('9','12') = 0;
econuse.FX('9','13') = 7.000000e-001;
econuse.FX('9','14') = 0;
econuse.FX('9','15') = 0;
econuse.FX('9','16') = 0;
econuse.FX('9','17') = 0;
econuse.FX('9','18') = 0;
econuse.FX('9','19') = 0;
econuse.FX('9','20') = 0;
econuse.FX('9','21') = 0;
econuse.FX('9','22') = 0;
econuse.FX('9','23') = 0;
econuse.FX('9','24') = 0;
econuse.FX('9','25') = 0;
econuse.FX('9','26') = 0;
econuse.FX('9','27') = 0;
econuse.FX('9','28') = 0;
econuse.FX('9','29') = 0;
econuse.FX('9','30') = 0;
econuse.FX('9','31') = 0;
econuse.FX('9','32') = 0;
econuse.FX('9','33') = 0;
econuse.FX('9','34') = 0;
econuse.FX('9','35') = 0;
econuse.FX('9','36') = 0;
econuse.FX('9','37') = 0;
econuse.FX('9','38') = 0;
econuse.FX('9','39') = 0;
econuse.FX('9','40') = 0;
econuse.FX('9','41') = 0;
econuse.FX('9','42') = 0;
econuse.FX('9','43') = 1.330000e+001;
econuse.FX('9','44') = 0;
econuse.FX('9','45') = 0;
econuse.FX('9','46') = 0;
econuse.FX('9','47') = 0;
econuse.FX('9','48') = 0;
econuse.FX('9','49') = 0;
econuse.FX('9','50') = 0;
econuse.FX('9','51') = 0;
econuse.FX('9','52') = 0;
econuse.FX('9','53') = 0;
econuse.FX('9','54') = 0;
econuse.FX('9','55') = 0;
econuse.FX('9','56') = 0;
econuse.FX('9','57') = 25;
econuse.FX('9','58') = 6.000000e-001;
econuse.FX('9','59') = 0;
econuse.FX('9','60') = 0;
econuse.FX('9','61') = 0;
econuse.FX('9','62') = 0;
econuse.FX('9','63') = 0;
econuse.FX('9','64') = 0;
econuse.FX('9','65') = 0;
econuse.FX('9','66') = 0;
econuse.FX('9','67') = 0;
econuse.FX('9','68') = 0;
econuse.FX('9','69') = 0;
econuse.FX('9','70') = 0;
econuse.FX('9','71') = 0;
econuse.FX('9','72') = 0;
econuse.FX('9','73') = 0;
econuse.FX('9','74') = 0;
econuse.FX('10','1') = 3.486000e+002;
econuse.FX('10','2') = 2.332700e+003;
econuse.FX('10','3') = 5.313000e+002;
econuse.FX('10','4') = 1.119300e+003;
econuse.FX('10','5') = 6.990000e+001;
econuse.FX('10','6') = 1.526400e+003;
econuse.FX('10','7') = 4.261000e+002;
econuse.FX('10','8') = 1.503300e+003;
econuse.FX('10','9') = 6.330000e+001;
econuse.FX('10','10') = 2;
econuse.FX('10','11') = 2.750000e+001;
econuse.FX('10','12') = 2.310000e+001;
econuse.FX('10','13') = 3.432100e+003;
econuse.FX('10','14') = 5.967700e+003;
econuse.FX('10','15') = 1.312100e+003;
econuse.FX('10','16') = 2.642000e+002;
econuse.FX('10','17') = 1.209400e+003;
econuse.FX('10','18') = 3.135600e+003;
econuse.FX('10','19') = 9.778000e+002;
econuse.FX('10','20') = 1.643600e+003;
econuse.FX('10','21') = 9.855000e+002;
econuse.FX('10','22') = 2.309000e+002;
econuse.FX('10','23') = 5.830000e+001;
econuse.FX('10','24') = 5.286400e+003;
econuse.FX('10','25') = 3.102800e+003;
econuse.FX('10','26') = 2.049900e+003;
econuse.FX('10','27') = 4.836700e+003;
econuse.FX('10','28') = 2.270400e+003;
econuse.FX('10','29') = 1.476200e+003;
econuse.FX('10','30') = 156;
econuse.FX('10','31') = 2.667800e+003;
econuse.FX('10','32') = 2.585900e+003;
econuse.FX('10','33') = 1.885000e+002;
econuse.FX('10','34') = 5.216000e+002;
econuse.FX('10','35') = 6.876000e+002;
econuse.FX('10','36') = 1.594380e+004;
econuse.FX('10','37') = 8.380000e+001;
econuse.FX('10','38') = 2.050000e+001;
econuse.FX('10','39') = 1.356000e+002;
econuse.FX('10','40') = 5.084000e+002;
econuse.FX('10','41') = 2.427000e+002;
econuse.FX('10','42') = 2.514000e+002;
econuse.FX('10','43') = 5.978000e+002;
econuse.FX('10','44') = 1.112900e+003;
econuse.FX('10','45') = 537;
econuse.FX('10','46') = 4.092000e+002;
econuse.FX('10','47') = 1.589900e+003;
econuse.FX('10','48') = 1.424000e+002;
econuse.FX('10','49') = 6.531000e+002;
econuse.FX('10','50') = 6.046000e+002;
econuse.FX('10','51') = 3.286000e+002;
econuse.FX('10','52') = 7.770000e+001;
econuse.FX('10','53') = 1.454170e+004;
econuse.FX('10','54') = 4473;
econuse.FX('10','55') = 3.826000e+002;
econuse.FX('10','56') = 1.994900e+003;
econuse.FX('10','57') = 4.089400e+003;
econuse.FX('10','58') = 2.654900e+003;
econuse.FX('10','59') = 1.412100e+003;
econuse.FX('10','60') = 184;
econuse.FX('10','61') = 3.073100e+003;
econuse.FX('10','62') = 1.817800e+003;
econuse.FX('10','63') = 4.343400e+003;
econuse.FX('10','64') = 1.773800e+003;
econuse.FX('10','65') = 6.855000e+002;
econuse.FX('10','66') = 5.303000e+002;
econuse.FX('10','67') = 1.784700e+003;
econuse.FX('10','68') = 3.370200e+003;
econuse.FX('10','69') = 8.877200e+003;
econuse.FX('10','70') = 4.622800e+003;
econuse.FX('10','71') = 2.208900e+003;
econuse.FX('10','72') = 3.378000e+002;
econuse.FX('10','73') = 7.337700e+003;
econuse.FX('10','74') = 1.504700e+003;
econuse.FX('11','1') = 271;
econuse.FX('11','2') = 4.124000e+002;
econuse.FX('11','3') = 1.780000e+001;
econuse.FX('11','4') = 3.342000e+002;
econuse.FX('11','5') = 8.900000e+000;
econuse.FX('11','6') = 7.595000e+002;
econuse.FX('11','7') = 2.291000e+002;
econuse.FX('11','8') = 7.579000e+002;
econuse.FX('11','9') = 2.066000e+002;
econuse.FX('11','10') = 3.000000e-001;
econuse.FX('11','11') = 1.636000e+002;
econuse.FX('11','12') = 4.350000e+001;
econuse.FX('11','13') = 8.364000e+002;
econuse.FX('11','14') = 4.147100e+003;
econuse.FX('11','15') = 5.177000e+002;
econuse.FX('11','16') = 325;
econuse.FX('11','17') = 3.556000e+002;
econuse.FX('11','18') = 2.634600e+003;
econuse.FX('11','19') = 2.809000e+002;
econuse.FX('11','20') = 3.709600e+003;
econuse.FX('11','21') = 1.922900e+003;
econuse.FX('11','22') = 1.476100e+003;
econuse.FX('11','23') = 1.720000e+001;
econuse.FX('11','24') = 2.621800e+003;
econuse.FX('11','25') = 6.468000e+002;
econuse.FX('11','26') = 1.902500e+003;
econuse.FX('11','27') = 2304;
econuse.FX('11','28') = 9.864000e+002;
econuse.FX('11','29') = 435;
econuse.FX('11','30') = 4.810000e+001;
econuse.FX('11','31') = 6.168000e+002;
econuse.FX('11','32') = 1.090500e+003;
econuse.FX('11','33') = 67;
econuse.FX('11','34') = 1.605000e+002;
econuse.FX('11','35') = 1.854000e+002;
econuse.FX('11','36') = 1.665300e+003;
econuse.FX('11','37') = 4.500000e+000;
econuse.FX('11','38') = 9.000000e-001;
econuse.FX('11','39') = 4.910000e+001;
econuse.FX('11','40') = 142;
econuse.FX('11','41') = 0;
econuse.FX('11','42') = 2.036000e+002;
econuse.FX('11','43') = 3.755000e+002;
econuse.FX('11','44') = 8.940000e+001;
econuse.FX('11','45') = 4.610000e+001;
econuse.FX('11','46') = 2.540000e+001;
econuse.FX('11','47') = 1.393600e+003;
econuse.FX('11','48') = 1.590000e+001;
econuse.FX('11','49') = 1.764000e+002;
econuse.FX('11','50') = 2.730000e+001;
econuse.FX('11','51') = 5.990000e+001;
econuse.FX('11','52') = 0;
econuse.FX('11','53') = 6.618000e+002;
econuse.FX('11','54') = 4.452000e+002;
econuse.FX('11','55') = 5.180000e+001;
econuse.FX('11','56') = 1.760000e+001;
econuse.FX('11','57') = 4.609000e+002;
econuse.FX('11','58') = 5.127000e+002;
econuse.FX('11','59') = 3.499000e+002;
econuse.FX('11','60') = 8.850000e+001;
econuse.FX('11','61') = 2.351500e+003;
econuse.FX('11','62') = 212;
econuse.FX('11','63') = 8.650000e+001;
econuse.FX('11','64') = 3.822000e+002;
econuse.FX('11','65') = 1.716000e+002;
econuse.FX('11','66') = 5.320000e+001;
econuse.FX('11','67') = 2.922000e+002;
econuse.FX('11','68') = 5.491000e+002;
econuse.FX('11','69') = 1.261900e+003;
econuse.FX('11','70') = 8.114000e+002;
econuse.FX('11','71') = 8.243000e+002;
econuse.FX('11','72') = 3.002000e+002;
econuse.FX('11','73') = 7.811600e+003;
econuse.FX('11','74') = 2.240100e+003;
econuse.FX('12','1') = 1.833000e+002;
econuse.FX('12','2') = 6.636000e+002;
econuse.FX('12','3') = 9.300000e+000;
econuse.FX('12','4') = 1.970000e+001;
econuse.FX('12','5') = 8.300000e+000;
econuse.FX('12','6') = 0;
econuse.FX('12','7') = 1.100000e+000;
econuse.FX('12','8') = 1.480000e+001;
econuse.FX('12','9') = 3.700000e+000;
econuse.FX('12','10') = 9.510000e+001;
econuse.FX('12','11') = 1.740000e+001;
econuse.FX('12','12') = 0;
econuse.FX('12','13') = 4.059000e+002;
econuse.FX('12','14') = 3.254000e+002;
econuse.FX('12','15') = 3.830000e+001;
econuse.FX('12','16') = 1.370000e+001;
econuse.FX('12','17') = 3.360000e+001;
econuse.FX('12','18') = 96;
econuse.FX('12','19') = 28;
econuse.FX('12','20') = 6.420000e+001;
econuse.FX('12','21') = 7.850000e+001;
econuse.FX('12','22') = 2.600000e+000;
econuse.FX('12','23') = 4.600000e+000;
econuse.FX('12','24') = 2.217000e+002;
econuse.FX('12','25') = 1.092000e+002;
econuse.FX('12','26') = 4.890000e+001;
econuse.FX('12','27') = 1.407000e+002;
econuse.FX('12','28') = 8.970000e+001;
econuse.FX('12','29') = 4.870000e+001;
econuse.FX('12','30') = 4.100000e+000;
econuse.FX('12','31') = 7.560000e+001;
econuse.FX('12','32') = 2.604000e+002;
econuse.FX('12','33') = 1.140000e+001;
econuse.FX('12','34') = 5.580000e+001;
econuse.FX('12','35') = 3.590000e+001;
econuse.FX('12','36') = 5.337000e+002;
econuse.FX('12','37') = 3.600000e+000;
econuse.FX('12','38') = 7.200000e+000;
econuse.FX('12','39') = 5.720000e+001;
econuse.FX('12','40') = 2.880000e+001;
econuse.FX('12','41') = 1.389000e+002;
econuse.FX('12','42') = 0;
econuse.FX('12','43') = 86;
econuse.FX('12','44') = 2.280000e+001;
econuse.FX('12','45') = 1.670000e+001;
econuse.FX('12','46') = 1.020000e+001;
econuse.FX('12','47') = 3.276000e+002;
econuse.FX('12','48') = 1.110000e+001;
econuse.FX('12','49') = 8.170000e+001;
econuse.FX('12','50') = 2.270000e+001;
econuse.FX('12','51') = 8.900000e+000;
econuse.FX('12','52') = 4.000000e-001;
econuse.FX('12','53') = 8.501000e+002;
econuse.FX('12','54') = 1.192000e+002;
econuse.FX('12','55') = 1.540000e+001;
econuse.FX('12','56') = 5.800000e+000;
econuse.FX('12','57') = 1.146000e+002;
econuse.FX('12','58') = 1.410000e+001;
econuse.FX('12','59') = 1.159000e+002;
econuse.FX('12','60') = 1.726000e+002;
econuse.FX('12','61') = 1.858500e+003;
econuse.FX('12','62') = 1.541000e+002;
econuse.FX('12','63') = 2.923000e+002;
econuse.FX('12','64') = 1.538000e+002;
econuse.FX('12','65') = 1.004000e+002;
econuse.FX('12','66') = 2.670000e+001;
econuse.FX('12','67') = 1.033000e+002;
econuse.FX('12','68') = 2.974000e+002;
econuse.FX('12','69') = 5.391000e+002;
econuse.FX('12','70') = 5.695000e+002;
econuse.FX('12','71') = 7.541000e+002;
econuse.FX('12','72') = 3.372000e+002;
econuse.FX('12','73') = 5.125700e+003;
econuse.FX('12','74') = 1.278200e+003;
econuse.FX('13','1') = 2.262000e+002;
econuse.FX('13','2') = 552;
econuse.FX('13','3') = 6.780000e+001;
econuse.FX('13','4') = 221;
econuse.FX('13','5') = 1.013000e+002;
econuse.FX('13','6') = 6618;
econuse.FX('13','7') = 3.000000e-001;
econuse.FX('13','8') = 1.300000e+000;
econuse.FX('13','9') = 1.100000e+000;
econuse.FX('13','10') = 6.361500e+003;
econuse.FX('13','11') = 9.350000e+001;
econuse.FX('13','12') = 7.857000e+002;
econuse.FX('13','13') = 7.178000e+002;
econuse.FX('13','14') = 1.460700e+003;
econuse.FX('13','15') = 2.209000e+002;
econuse.FX('13','16') = 55;
econuse.FX('13','17') = 346;
econuse.FX('13','18') = 7.822000e+002;
econuse.FX('13','19') = 4.228000e+002;
econuse.FX('13','20') = 1.006400e+003;
econuse.FX('13','21') = 3.899000e+002;
econuse.FX('13','22') = 1.028000e+002;
econuse.FX('13','23') = 2.830000e+001;
econuse.FX('13','24') = 1.200500e+003;
econuse.FX('13','25') = 7.226000e+002;
econuse.FX('13','26') = 5.468000e+002;
econuse.FX('13','27') = 9.956000e+002;
econuse.FX('13','28') = 8.346000e+002;
econuse.FX('13','29') = 6.342000e+002;
econuse.FX('13','30') = 5.260000e+001;
econuse.FX('13','31') = 8.856000e+002;
econuse.FX('13','32') = 8.818000e+002;
econuse.FX('13','33') = 8.020000e+001;
econuse.FX('13','34') = 3.059000e+002;
econuse.FX('13','35') = 2.522000e+002;
econuse.FX('13','36') = 3.968900e+003;
econuse.FX('13','37') = 3.010000e+001;
econuse.FX('13','38') = 2.014400e+003;
econuse.FX('13','39') = 0;
econuse.FX('13','40') = 185;
econuse.FX('13','41') = 3.930000e+001;
econuse.FX('13','42') = 1.354500e+003;
econuse.FX('13','43') = 6.451000e+002;
econuse.FX('13','44') = 219;
econuse.FX('13','45') = 2.767000e+002;
econuse.FX('13','46') = 1.267000e+002;
econuse.FX('13','47') = 4.706500e+003;
econuse.FX('13','48') = 206;
econuse.FX('13','49') = 3767;
econuse.FX('13','50') = 472;
econuse.FX('13','51') = 1.487000e+002;
econuse.FX('13','52') = 1.766000e+002;
econuse.FX('13','53') = 5.061080e+004;
econuse.FX('13','54') = 1.126800e+003;
econuse.FX('13','55') = 1.814000e+002;
econuse.FX('13','56') = 1.021000e+002;
econuse.FX('13','57') = 3357;
econuse.FX('13','58') = 1043;
econuse.FX('13','59') = 3.662000e+002;
econuse.FX('13','60') = 4.390000e+001;
econuse.FX('13','61') = 2.665000e+002;
econuse.FX('13','62') = 7.854000e+002;
econuse.FX('13','63') = 6.477000e+002;
econuse.FX('13','64') = 460;
econuse.FX('13','65') = 403;
econuse.FX('13','66') = 1.434000e+002;
econuse.FX('13','67') = 3.094000e+002;
econuse.FX('13','68') = 1.052800e+003;
econuse.FX('13','69') = 1.405600e+003;
econuse.FX('13','70') = 2.731700e+003;
econuse.FX('13','71') = 7.315500e+003;
econuse.FX('13','72') = 1.113100e+003;
econuse.FX('13','73') = 2.296630e+004;
econuse.FX('13','74') = 1.106060e+004;
econuse.FX('14','1') = 0;
econuse.FX('14','2') = 0;
econuse.FX('14','3') = 3.723600e+003;
econuse.FX('14','4') = 1.012910e+004;
econuse.FX('14','5') = 2.355000e+002;
econuse.FX('14','6') = 0;
econuse.FX('14','7') = 0;
econuse.FX('14','8') = 0;
econuse.FX('14','9') = 0;
econuse.FX('14','10') = 0;
econuse.FX('14','11') = 0;
econuse.FX('14','12') = 0;
econuse.FX('14','13') = 0;
econuse.FX('14','14') = 9.836720e+004;
econuse.FX('14','15') = 2.090000e+001;
econuse.FX('14','16') = 1.120800e+003;
econuse.FX('14','17') = 9.500000e+000;
econuse.FX('14','18') = 483;
econuse.FX('14','19') = 1.187000e+002;
econuse.FX('14','20') = 3.870000e+001;
econuse.FX('14','21') = 3.926000e+002;
econuse.FX('14','22') = 0;
econuse.FX('14','23') = 0;
econuse.FX('14','24') = 1.017500e+003;
econuse.FX('14','25') = 7.420000e+001;
econuse.FX('14','26') = 7.830000e+001;
econuse.FX('14','27') = 7.000000e-001;
econuse.FX('14','28') = 0;
econuse.FX('14','29') = 0;
econuse.FX('14','30') = 0;
econuse.FX('14','31') = 0;
econuse.FX('14','32') = 0;
econuse.FX('14','33') = 0;
econuse.FX('14','34') = 0;
econuse.FX('14','35') = 1.900000e+000;
econuse.FX('14','36') = 697;
econuse.FX('14','37') = 5.310000e+001;
econuse.FX('14','38') = 0;
econuse.FX('14','39') = 3.380000e+001;
econuse.FX('14','40') = 0;
econuse.FX('14','41') = 0;
econuse.FX('14','42') = 0;
econuse.FX('14','43') = 9.600000e+000;
econuse.FX('14','44') = 0;
econuse.FX('14','45') = 3.630000e+001;
econuse.FX('14','46') = 1.470000e+001;
econuse.FX('14','47') = 0;
econuse.FX('14','48') = 1.180000e+001;
econuse.FX('14','49') = 0;
econuse.FX('14','50') = 0;
econuse.FX('14','51') = 0;
econuse.FX('14','52') = 0;
econuse.FX('14','53') = 0;
econuse.FX('14','54') = 4.300000e+000;
econuse.FX('14','55') = 0;
econuse.FX('14','56') = 0;
econuse.FX('14','57') = 5.402000e+002;
econuse.FX('14','58') = 1.360000e+001;
econuse.FX('14','59') = 1;
econuse.FX('14','60') = 0;
econuse.FX('14','61') = 4.042700e+003;
econuse.FX('14','62') = 3.000000e-001;
econuse.FX('14','63') = 9.068800e+003;
econuse.FX('14','64') = 3.895900e+003;
econuse.FX('14','65') = 1.988700e+003;
econuse.FX('14','66') = 452;
econuse.FX('14','67') = 1.274300e+003;
econuse.FX('14','68') = 1.074500e+003;
econuse.FX('14','69') = 5.131410e+004;
econuse.FX('14','70') = 8.322000e+002;
econuse.FX('14','71') = 4.015000e+002;
econuse.FX('14','72') = 1.969000e+002;
econuse.FX('14','73') = 1.337780e+004;
econuse.FX('14','74') = 0;
econuse.FX('15','1') = 2.850000e+001;
econuse.FX('15','2') = 2.182000e+002;
econuse.FX('15','3') = 1.210000e+001;
econuse.FX('15','4') = 9.400000e+000;
econuse.FX('15','5') = 3.257000e+002;
econuse.FX('15','6') = 0;
econuse.FX('15','7') = 8.800000e+000;
econuse.FX('15','8') = 0;
econuse.FX('15','9') = 0;
econuse.FX('15','10') = 0;
econuse.FX('15','11') = 0;
econuse.FX('15','12') = 0;
econuse.FX('15','13') = 1.832500e+003;
econuse.FX('15','14') = 427;
econuse.FX('15','15') = 1.575620e+004;
econuse.FX('15','16') = 1.003890e+004;
econuse.FX('15','17') = 6.016000e+002;
econuse.FX('15','18') = 1.255100e+003;
econuse.FX('15','19') = 2.834000e+002;
econuse.FX('15','20') = 1.124000e+002;
econuse.FX('15','21') = 0;
econuse.FX('15','22') = 0;
econuse.FX('15','23') = 0;
econuse.FX('15','24') = 6;
econuse.FX('15','25') = 2.039600e+003;
econuse.FX('15','26') = 2.128000e+002;
econuse.FX('15','27') = 0;
econuse.FX('15','28') = 1.000000e-001;
econuse.FX('15','29') = 4.126000e+002;
econuse.FX('15','30') = 0;
econuse.FX('15','31') = 1.780000e+001;
econuse.FX('15','32') = 4.198300e+003;
econuse.FX('15','33') = 3.618000e+002;
econuse.FX('15','34') = 2.782200e+003;
econuse.FX('15','35') = 1.641200e+003;
econuse.FX('15','36') = 2.490300e+003;
econuse.FX('15','37') = 3.000000e-001;
econuse.FX('15','38') = 0;
econuse.FX('15','39') = 112;
econuse.FX('15','40') = 21;
econuse.FX('15','41') = 0;
econuse.FX('15','42') = 2.170000e+001;
econuse.FX('15','43') = 2.620000e+001;
econuse.FX('15','44') = 2.200000e+000;
econuse.FX('15','45') = 1.270000e+001;
econuse.FX('15','46') = 3.170000e+001;
econuse.FX('15','47') = 9.200000e+000;
econuse.FX('15','48') = 2.900000e+000;
econuse.FX('15','49') = 4.000000e-001;
econuse.FX('15','50') = 4.000000e-001;
econuse.FX('15','51') = 5.300000e+000;
econuse.FX('15','52') = 0;
econuse.FX('15','53') = 1.266000e+002;
econuse.FX('15','54') = 3.700000e+000;
econuse.FX('15','55') = 0;
econuse.FX('15','56') = 0;
econuse.FX('15','57') = 2.799000e+002;
econuse.FX('15','58') = 2.200000e+000;
econuse.FX('15','59') = 7.970000e+001;
econuse.FX('15','60') = 7.060000e+001;
econuse.FX('15','61') = 5;
econuse.FX('15','62') = 1.320000e+001;
econuse.FX('15','63') = 8.119000e+002;
econuse.FX('15','64') = 266;
econuse.FX('15','65') = 9.950000e+001;
econuse.FX('15','66') = 1.600000e+000;
econuse.FX('15','67') = 4.261000e+002;
econuse.FX('15','68') = 2.136000e+002;
econuse.FX('15','69') = 368;
econuse.FX('15','70') = 9.153000e+002;
econuse.FX('15','71') = 5.408000e+002;
econuse.FX('15','72') = 2.200000e+000;
econuse.FX('15','73') = 7.779000e+002;
econuse.FX('15','74') = 2.970000e+001;
econuse.FX('16','1') = 0;
econuse.FX('16','2') = 0;
econuse.FX('16','3') = 0;
econuse.FX('16','4') = 5.020000e+001;
econuse.FX('16','5') = 0;
econuse.FX('16','6') = 0;
econuse.FX('16','7') = 0;
econuse.FX('16','8') = 0;
econuse.FX('16','9') = 0;
econuse.FX('16','10') = 2.000000e-001;
econuse.FX('16','11') = 1.100000e+000;
econuse.FX('16','12') = 0;
econuse.FX('16','13') = 0;
econuse.FX('16','14') = 1.940000e+001;
econuse.FX('16','15') = 8.627000e+002;
econuse.FX('16','16') = 3.111500e+003;
econuse.FX('16','17') = 8.900000e+000;
econuse.FX('16','18') = 0;
econuse.FX('16','19') = 1185;
econuse.FX('16','20') = 5.400000e+000;
econuse.FX('16','21') = 0;
econuse.FX('16','22') = 0;
econuse.FX('16','23') = 0;
econuse.FX('16','24') = 0;
econuse.FX('16','25') = 2.600000e+000;
econuse.FX('16','26') = 2.900000e+000;
econuse.FX('16','27') = 0;
econuse.FX('16','28') = 0;
econuse.FX('16','29') = 0;
econuse.FX('16','30') = 0;
econuse.FX('16','31') = 9.000000e-001;
econuse.FX('16','32') = 2.385700e+003;
econuse.FX('16','33') = 0;
econuse.FX('16','34') = 0;
econuse.FX('16','35') = 7.510000e+001;
econuse.FX('16','36') = 1.558900e+003;
econuse.FX('16','37') = 0;
econuse.FX('16','38') = 0;
econuse.FX('16','39') = 0;
econuse.FX('16','40') = 0;
econuse.FX('16','41') = 0;
econuse.FX('16','42') = 0;
econuse.FX('16','43') = 1.000000e-001;
econuse.FX('16','44') = 0;
econuse.FX('16','45') = 0;
econuse.FX('16','46') = 5.380000e+001;
econuse.FX('16','47') = 1.055000e+002;
econuse.FX('16','48') = 5.000000e-001;
econuse.FX('16','49') = 2.700000e+000;
econuse.FX('16','50') = 0;
econuse.FX('16','51') = 0;
econuse.FX('16','52') = 0;
econuse.FX('16','53') = 0;
econuse.FX('16','54') = 8.000000e-001;
econuse.FX('16','55') = 0;
econuse.FX('16','56') = 0;
econuse.FX('16','57') = 4.760000e+001;
econuse.FX('16','58') = 13;
econuse.FX('16','59') = 1.666000e+002;
econuse.FX('16','60') = 1.503000e+002;
econuse.FX('16','61') = 1.154000e+002;
econuse.FX('16','62') = 12;
econuse.FX('16','63') = 3.040000e+001;
econuse.FX('16','64') = 0;
econuse.FX('16','65') = 29;
econuse.FX('16','66') = 1.544000e+002;
econuse.FX('16','67') = 4.800000e+000;
econuse.FX('16','68') = 1.800000e+000;
econuse.FX('16','69') = 6;
econuse.FX('16','70') = 1.327600e+003;
econuse.FX('16','71') = 5.345000e+002;
econuse.FX('16','72') = 1.091000e+002;
econuse.FX('16','73') = 1.514800e+003;
econuse.FX('16','74') = 5.510000e+001;
econuse.FX('17','1') = 4.200000e+000;
econuse.FX('17','2') = 4.359000e+002;
econuse.FX('17','3') = 3.090000e+001;
econuse.FX('17','4') = 1.910000e+001;
econuse.FX('17','5') = 1.663000e+002;
econuse.FX('17','6') = 0;
econuse.FX('17','7') = 6.000000e-001;
econuse.FX('17','8') = 4.330000e+001;
econuse.FX('17','9') = 1.510000e+001;
econuse.FX('17','10') = 1.100000e+000;
econuse.FX('17','11') = 1.848000e+002;
econuse.FX('17','12') = 2.000000e-001;
econuse.FX('17','13') = 3.849050e+004;
econuse.FX('17','14') = 299;
econuse.FX('17','15') = 1.149000e+002;
econuse.FX('17','16') = 1;
econuse.FX('17','17') = 1.827470e+004;
econuse.FX('17','18') = 3.033200e+003;
econuse.FX('17','19') = 3.300000e+000;
econuse.FX('17','20') = 3.300000e+000;
econuse.FX('17','21') = 1.619000e+002;
econuse.FX('17','22') = 5.400000e+000;
econuse.FX('17','23') = 4.300000e+000;
econuse.FX('17','24') = 83;
econuse.FX('17','25') = 7.636000e+002;
econuse.FX('17','26') = 4.519000e+002;
econuse.FX('17','27') = 2.643000e+002;
econuse.FX('17','28') = 1.712000e+002;
econuse.FX('17','29') = 5.516000e+002;
econuse.FX('17','30') = 1.106000e+002;
econuse.FX('17','31') = 2.769000e+002;
econuse.FX('17','32') = 2.191500e+003;
econuse.FX('17','33') = 1.694000e+002;
econuse.FX('17','34') = 7.137200e+003;
econuse.FX('17','35') = 1254;
econuse.FX('17','36') = 1.940400e+003;
econuse.FX('17','37') = 1.500000e+000;
econuse.FX('17','38') = 8.613000e+002;
econuse.FX('17','39') = 0;
econuse.FX('17','40') = 1.677000e+002;
econuse.FX('17','41') = 0;
econuse.FX('17','42') = 6.700000e+000;
econuse.FX('17','43') = 1.970000e+001;
econuse.FX('17','44') = 4.410000e+001;
econuse.FX('17','45') = 2.709000e+002;
econuse.FX('17','46') = 2.492000e+002;
econuse.FX('17','47') = 4.773000e+002;
econuse.FX('17','48') = 419;
econuse.FX('17','49') = 2.920000e+001;
econuse.FX('17','50') = 6.000000e-001;
econuse.FX('17','51') = 6.100000e+000;
econuse.FX('17','52') = 0;
econuse.FX('17','53') = 4.768400e+003;
econuse.FX('17','54') = 1.032000e+002;
econuse.FX('17','55') = 3.600000e+000;
econuse.FX('17','56') = 3.200000e+000;
econuse.FX('17','57') = 2.618000e+002;
econuse.FX('17','58') = 9.000000e-001;
econuse.FX('17','59') = 2.141000e+002;
econuse.FX('17','60') = 1.550000e+001;
econuse.FX('17','61') = 2.930000e+001;
econuse.FX('17','62') = 1.148000e+002;
econuse.FX('17','63') = 75;
econuse.FX('17','64') = 6;
econuse.FX('17','65') = 4.296000e+002;
econuse.FX('17','66') = 2.900000e+000;
econuse.FX('17','67') = 1.534000e+002;
econuse.FX('17','68') = 1.656000e+002;
econuse.FX('17','69') = 2.020200e+003;
econuse.FX('17','70') = 4.111000e+002;
econuse.FX('17','71') = 3.870000e+001;
econuse.FX('17','72') = 1.600000e+000;
econuse.FX('17','73') = 2.665500e+003;
econuse.FX('17','74') = 5.208000e+002;
econuse.FX('18','1') = 3.800000e+000;
econuse.FX('18','2') = 2.969000e+002;
econuse.FX('18','3') = 1.400000e+000;
econuse.FX('18','4') = 4.240000e+001;
econuse.FX('18','5') = 1.790000e+001;
econuse.FX('18','6') = 2.085000e+002;
econuse.FX('18','7') = 4.120000e+001;
econuse.FX('18','8') = 148;
econuse.FX('18','9') = 1.413000e+002;
econuse.FX('18','10') = 8.680000e+001;
econuse.FX('18','11') = 2.760000e+001;
econuse.FX('18','12') = 7.200000e+000;
econuse.FX('18','13') = 2.676800e+003;
econuse.FX('18','14') = 2.133520e+004;
econuse.FX('18','15') = 6.034000e+002;
econuse.FX('18','16') = 1.317000e+002;
econuse.FX('18','17') = 3.811000e+002;
econuse.FX('18','18') = 3.290770e+004;
econuse.FX('18','19') = 1.505530e+004;
econuse.FX('18','20') = 4.576000e+002;
econuse.FX('18','21') = 2.672000e+002;
econuse.FX('18','22') = 1.143000e+002;
econuse.FX('18','23') = 5.160000e+001;
econuse.FX('18','24') = 3.569800e+003;
econuse.FX('18','25') = 4.049900e+003;
econuse.FX('18','26') = 1.830500e+003;
econuse.FX('18','27') = 9.621000e+002;
econuse.FX('18','28') = 1.335600e+003;
econuse.FX('18','29') = 1.401800e+003;
econuse.FX('18','30') = 3.332000e+002;
econuse.FX('18','31') = 2.402900e+003;
econuse.FX('18','32') = 2.112200e+003;
econuse.FX('18','33') = 2.793000e+002;
econuse.FX('18','34') = 1.059200e+003;
econuse.FX('18','35') = 1.804700e+003;
econuse.FX('18','36') = 4913;
econuse.FX('18','37') = 1.228000e+002;
econuse.FX('18','38') = 6.810000e+001;
econuse.FX('18','39') = 8.300000e+000;
econuse.FX('18','40') = 2.727000e+002;
econuse.FX('18','41') = 4.240000e+001;
econuse.FX('18','42') = 1.064000e+002;
econuse.FX('18','43') = 2.768000e+002;
econuse.FX('18','44') = 1.463000e+002;
econuse.FX('18','45') = 4.483400e+003;
econuse.FX('18','46') = 9.380000e+001;
econuse.FX('18','47') = 5.303000e+002;
econuse.FX('18','48') = 1.043000e+002;
econuse.FX('18','49') = 5.294000e+002;
econuse.FX('18','50') = 8.580000e+001;
econuse.FX('18','51') = 1.051000e+002;
econuse.FX('18','52') = 4.800000e+000;
econuse.FX('18','53') = 2.627000e+002;
econuse.FX('18','54') = 1.111500e+003;
econuse.FX('18','55') = 2.547000e+002;
econuse.FX('18','56') = 1.159000e+002;
econuse.FX('18','57') = 1453;
econuse.FX('18','58') = 5.593000e+002;
econuse.FX('18','59') = 9.537000e+002;
econuse.FX('18','60') = 1.783000e+002;
econuse.FX('18','61') = 2.073000e+002;
econuse.FX('18','62') = 1.090700e+003;
econuse.FX('18','63') = 2.424200e+003;
econuse.FX('18','64') = 8.961000e+002;
econuse.FX('18','65') = 3.624000e+002;
econuse.FX('18','66') = 3.740000e+001;
econuse.FX('18','67') = 315;
econuse.FX('18','68') = 1.383200e+003;
econuse.FX('18','69') = 3801;
econuse.FX('18','70') = 1.045700e+003;
econuse.FX('18','71') = 1.448900e+003;
econuse.FX('18','72') = 1.238000e+002;
econuse.FX('18','73') = 1.182520e+004;
econuse.FX('18','74') = 6.870000e+001;
econuse.FX('19','1') = 5.800000e+000;
econuse.FX('19','2') = 1.760000e+001;
econuse.FX('19','3') = 8.700000e+000;
econuse.FX('19','4') = 1.350000e+001;
econuse.FX('19','5') = 1.590000e+001;
econuse.FX('19','6') = 4.000000e-001;
econuse.FX('19','7') = 4.000000e-001;
econuse.FX('19','8') = 0;
econuse.FX('19','9') = 0;
econuse.FX('19','10') = 9.300000e+000;
econuse.FX('19','11') = 6.900000e+000;
econuse.FX('19','12') = 6.000000e-001;
econuse.FX('19','13') = 6.470000e+001;
econuse.FX('19','14') = 321;
econuse.FX('19','15') = 0;
econuse.FX('19','16') = 2.451000e+002;
econuse.FX('19','17') = 2.620000e+001;
econuse.FX('19','18') = 0;
econuse.FX('19','19') = 2.522500e+003;
econuse.FX('19','20') = 5.670000e+001;
econuse.FX('19','21') = 6.600000e+000;
econuse.FX('19','22') = 0;
econuse.FX('19','23') = 9.100000e+000;
econuse.FX('19','24') = 4.699000e+002;
econuse.FX('19','25') = 0;
econuse.FX('19','26') = 0;
econuse.FX('19','27') = 0;
econuse.FX('19','28') = 5.400000e+000;
econuse.FX('19','29') = 2.780000e+001;
econuse.FX('19','30') = 0;
econuse.FX('19','31') = 1.380000e+001;
econuse.FX('19','32') = 3.900000e+000;
econuse.FX('19','33') = 0;
econuse.FX('19','34') = 0;
econuse.FX('19','35') = 0;
econuse.FX('19','36') = 8.201600e+003;
econuse.FX('19','37') = 0;
econuse.FX('19','38') = 2.190000e+001;
econuse.FX('19','39') = 0;
econuse.FX('19','40') = 1.395000e+002;
econuse.FX('19','41') = 3.070000e+001;
econuse.FX('19','42') = 1.510000e+001;
econuse.FX('19','43') = 1.072000e+002;
econuse.FX('19','44') = 1.040000e+001;
econuse.FX('19','45') = 1.494480e+004;
econuse.FX('19','46') = 3.338000e+002;
econuse.FX('19','47') = 4.557000e+002;
econuse.FX('19','48') = 7.124000e+002;
econuse.FX('19','49') = 1.020500e+003;
econuse.FX('19','50') = 1.324600e+003;
econuse.FX('19','51') = 5668;
econuse.FX('19','52') = 0;
econuse.FX('19','53') = 5.500000e+000;
econuse.FX('19','54') = 2.299300e+003;
econuse.FX('19','55') = 6.527000e+002;
econuse.FX('19','56') = 1.343000e+002;
econuse.FX('19','57') = 4.846100e+003;
econuse.FX('19','58') = 2.248800e+003;
econuse.FX('19','59') = 2.018900e+003;
econuse.FX('19','60') = 4.310000e+001;
econuse.FX('19','61') = 1.199700e+003;
econuse.FX('19','62') = 9.656000e+002;
econuse.FX('19','63') = 9.734000e+002;
econuse.FX('19','64') = 9.070000e+001;
econuse.FX('19','65') = 6.251000e+002;
econuse.FX('19','66') = 5.344000e+002;
econuse.FX('19','67') = 2.525000e+002;
econuse.FX('19','68') = 665;
econuse.FX('19','69') = 1.046500e+003;
econuse.FX('19','70') = 3.280200e+003;
econuse.FX('19','71') = 2.306900e+003;
econuse.FX('19','72') = 6.214000e+002;
econuse.FX('19','73') = 1.160920e+004;
econuse.FX('19','74') = 8.040000e+001;
econuse.FX('20','1') = 1.193700e+003;
econuse.FX('20','2') = 3.282700e+003;
econuse.FX('20','3') = 4.681000e+002;
econuse.FX('20','4') = 1.486500e+003;
econuse.FX('20','5') = 616;
econuse.FX('20','6') = 4.973000e+002;
econuse.FX('20','7') = 1.766000e+002;
econuse.FX('20','8') = 4.673000e+002;
econuse.FX('20','9') = 2.969000e+002;
econuse.FX('20','10') = 2479;
econuse.FX('20','11') = 5.830000e+001;
econuse.FX('20','12') = 3.010000e+001;
econuse.FX('20','13') = 2.410680e+004;
econuse.FX('20','14') = 9.887000e+002;
econuse.FX('20','15') = 8.080000e+001;
econuse.FX('20','16') = 2.640000e+001;
econuse.FX('20','17') = 2.381000e+002;
econuse.FX('20','18') = 7.792000e+002;
econuse.FX('20','19') = 2.487000e+002;
econuse.FX('20','20') = 2.083240e+004;
econuse.FX('20','21') = 3.631100e+003;
econuse.FX('20','22') = 404;
econuse.FX('20','23') = 1.015000e+002;
econuse.FX('20','24') = 7.962600e+003;
econuse.FX('20','25') = 6.525000e+002;
econuse.FX('20','26') = 271;
econuse.FX('20','27') = 4.022000e+002;
econuse.FX('20','28') = 3.583000e+002;
econuse.FX('20','29') = 4.289000e+002;
econuse.FX('20','30') = 7.420000e+001;
econuse.FX('20','31') = 4.654000e+002;
econuse.FX('20','32') = 1.898000e+002;
econuse.FX('20','33') = 8.800000e+000;
econuse.FX('20','34') = 7.630000e+001;
econuse.FX('20','35') = 1.226000e+002;
econuse.FX('20','36') = 4.591500e+003;
econuse.FX('20','37') = 1.058870e+004;
econuse.FX('20','38') = 1.392100e+003;
econuse.FX('20','39') = 0;
econuse.FX('20','40') = 1.214290e+004;
econuse.FX('20','41') = 1.313800e+003;
econuse.FX('20','42') = 3.024700e+003;
econuse.FX('20','43') = 5.015300e+003;
econuse.FX('20','44') = 1.988000e+002;
econuse.FX('20','45') = 1.032000e+002;
econuse.FX('20','46') = 2.330000e+001;
econuse.FX('20','47') = 8.653000e+002;
econuse.FX('20','48') = 71;
econuse.FX('20','49') = 3.104000e+002;
econuse.FX('20','50') = 1.149000e+002;
econuse.FX('20','51') = 6.940000e+001;
econuse.FX('20','52') = 4.600000e+000;
econuse.FX('20','53') = 8.784000e+002;
econuse.FX('20','54') = 8.021000e+002;
econuse.FX('20','55') = 8.410000e+001;
econuse.FX('20','56') = 9.040000e+001;
econuse.FX('20','57') = 1.184900e+003;
econuse.FX('20','58') = 3.234000e+002;
econuse.FX('20','59') = 1.006540e+004;
econuse.FX('20','60') = 387;
econuse.FX('20','61') = 9.870000e+001;
econuse.FX('20','62') = 2.504000e+002;
econuse.FX('20','63') = 2.736000e+002;
econuse.FX('20','64') = 2.606000e+002;
econuse.FX('20','65') = 1.681000e+002;
econuse.FX('20','66') = 4.230000e+001;
econuse.FX('20','67') = 2.051000e+002;
econuse.FX('20','68') = 3.804000e+002;
econuse.FX('20','69') = 1.222400e+003;
econuse.FX('20','70') = 1.019900e+003;
econuse.FX('20','71') = 4.323900e+003;
econuse.FX('20','72') = 7.384000e+002;
econuse.FX('20','73') = 2.012620e+004;
econuse.FX('20','74') = 6.511900e+003;
econuse.FX('21','1') = 0;
econuse.FX('21','2') = 4.119000e+002;

ddgs95.. econuse('21','3') =E= 0+(ddgs*360*86400*0.075/1000000);

econuse.FX('21','4') = 0;
econuse.FX('21','5') = 0;
econuse.FX('21','6') = 1.807000e+002;
econuse.FX('21','7') = 5;
econuse.FX('21','8') = 2.455000e+002;
econuse.FX('21','9') = 5.140000e+001;
econuse.FX('21','10') = 3.700000e+000;
econuse.FX('21','11') = 1.730000e+001;
econuse.FX('21','12') = 7.100000e+000;
econuse.FX('21','13') = 1.161000e+002;
econuse.FX('21','14') = 9.854000e+002;
econuse.FX('21','15') = 1.078000e+002;
econuse.FX('21','16') = 7.060000e+001;
econuse.FX('21','17') = 9.830000e+001;
econuse.FX('21','18') = 1383;
econuse.FX('21','19') = 1.959000e+002;
econuse.FX('21','20') = 9.276000e+002;
econuse.FX('21','21') = 7.728300e+003;
econuse.FX('21','22') = 2.600000e+000;
econuse.FX('21','23') = 1531;
econuse.FX('21','24') = 2.764390e+004;
econuse.FX('21','25') = 3.931200e+003;
econuse.FX('21','26') = 7.086000e+002;
econuse.FX('21','27') = 3.052000e+002;
econuse.FX('21','28') = 2.291000e+002;
econuse.FX('21','29') = 1.657000e+002;
econuse.FX('21','30') = 1.340000e+001;
econuse.FX('21','31') = 2.727000e+002;
econuse.FX('21','32') = 5.546000e+002;
econuse.FX('21','33') = 2.060000e+001;
econuse.FX('21','34') = 1.840000e+001;
econuse.FX('21','35') = 2.034000e+002;
econuse.FX('21','36') = 1.968000e+002;
econuse.FX('21','37') = 0;
econuse.FX('21','38') = 4.660000e+001;
econuse.FX('21','39') = 4;
econuse.FX('21','40') = 5.010000e+001;
econuse.FX('21','41') = 1.700000e+000;
econuse.FX('21','42') = 9.400000e+000;
econuse.FX('21','43') = 4.950000e+001;
econuse.FX('21','44') = 1.100000e+000;
econuse.FX('21','45') = 3.510000e+001;
econuse.FX('21','46') = 2.300000e+000;
econuse.FX('21','47') = 1.401000e+002;
econuse.FX('21','48') = 5;
econuse.FX('21','49') = 0;
econuse.FX('21','50') = 0;
econuse.FX('21','51') = 1;
econuse.FX('21','52') = 6.500000e+000;
econuse.FX('21','53') = 2.965000e+002;
econuse.FX('21','54') = 1.312000e+002;
econuse.FX('21','55') = 4.000000e-001;
econuse.FX('21','56') = 0;
econuse.FX('21','57') = 3.623000e+002;
econuse.FX('21','58') = 6.500000e+000;
econuse.FX('21','59') = 3.625000e+002;
econuse.FX('21','60') = 1.098000e+002;
econuse.FX('21','61') = 43;
econuse.FX('21','62') = 8.673000e+002;
econuse.FX('21','63') = 8.773000e+002;
econuse.FX('21','64') = 1.240000e+001;
econuse.FX('21','65') = 14;
econuse.FX('21','66') = 2.000000e-001;
econuse.FX('21','67') = 5.400000e+000;
econuse.FX('21','68') = 4.700000e+000;
econuse.FX('21','69') = 1.906000e+002;
econuse.FX('21','70') = 2.314000e+002;
econuse.FX('21','71') = 1.134000e+002;
econuse.FX('21','72') = 1.370000e+001;
econuse.FX('21','73') = 2.247200e+003;
econuse.FX('21','74') = 4.348000e+002;
econuse.FX('22','1') = 1.651100e+003;
econuse.FX('22','2') = 1.728800e+003;
econuse.FX('22','3') = 4.470000e+001;
econuse.FX('22','4') = 0;
econuse.FX('22','5') = 1.336900e+003;
econuse.FX('22','6') = 0;
econuse.FX('22','7') = 0;
econuse.FX('22','8') = 3.200000e+000;
econuse.FX('22','9') = 2.300000e+000;
econuse.FX('22','10') = 4.000000e-001;
econuse.FX('22','11') = 0;
econuse.FX('22','12') = 0;
econuse.FX('22','13') = 1.621400e+003;
econuse.FX('22','14') = 0;
econuse.FX('22','15') = 9.000000e-001;
econuse.FX('22','16') = 1.400000e+000;
econuse.FX('22','17') = 0;
econuse.FX('22','18') = 9.000000e-001;
econuse.FX('22','19') = 0;
econuse.FX('22','20') = 1.180000e+001;
econuse.FX('22','21') = 3.136000e+002;
econuse.FX('22','22') = 1.717500e+003;
econuse.FX('22','23') = 2.480000e+001;
econuse.FX('22','24') = 7.558000e+002;
econuse.FX('22','25') = 4.210000e+001;
econuse.FX('22','26') = 1.650000e+001;
econuse.FX('22','27') = 6.800000e+000;
econuse.FX('22','28') = 7.300000e+000;
econuse.FX('22','29') = 9.000000e-001;
econuse.FX('22','30') = 0;
econuse.FX('22','31') = 2;
econuse.FX('22','32') = 1.920000e+001;
econuse.FX('22','33') = 4.000000e-001;
econuse.FX('22','34') = 0;
econuse.FX('22','35') = 3.800000e+000;
econuse.FX('22','36') = 93;
econuse.FX('22','37') = 1.000000e-001;
econuse.FX('22','38') = 1.300000e+000;
econuse.FX('22','39') = 0;
econuse.FX('22','40') = 0;
econuse.FX('22','41') = 0;
econuse.FX('22','42') = 0;
econuse.FX('22','43') = 0;
econuse.FX('22','44') = 0;
econuse.FX('22','45') = 0;
econuse.FX('22','46') = 0;
econuse.FX('22','47') = 0;
econuse.FX('22','48') = 0;
econuse.FX('22','49') = 0;
econuse.FX('22','50') = 0;
econuse.FX('22','51') = 0;
econuse.FX('22','52') = 0;
econuse.FX('22','53') = 2.907000e+002;
econuse.FX('22','54') = 0;
econuse.FX('22','55') = 0;
econuse.FX('22','56') = 0;
econuse.FX('22','57') = 3.860000e+001;
econuse.FX('22','58') = 1.000000e-001;
econuse.FX('22','59') = 8.240000e+001;
econuse.FX('22','60') = 0;
econuse.FX('22','61') = 8.900000e+000;
econuse.FX('22','62') = 0;
econuse.FX('22','63') = 8.100000e+000;
econuse.FX('22','64') = 6.000000e-001;
econuse.FX('22','65') = 0;
econuse.FX('22','66') = 1.000000e-001;
econuse.FX('22','67') = 1.470000e+001;
econuse.FX('22','68') = 0;
econuse.FX('22','69') = 5.200000e+000;
econuse.FX('22','70') = 1.400000e+000;
econuse.FX('22','71') = 3.460000e+001;
econuse.FX('22','72') = 0;
econuse.FX('22','73') = 7.143000e+002;
econuse.FX('22','74') = 1.469000e+002;
econuse.FX('23','1') = 1412;
econuse.FX('23','2') = 3.105400e+003;
econuse.FX('23','3') = 1.697000e+002;
econuse.FX('23','4') = 2.518000e+002;
econuse.FX('23','5') = 7.016000e+002;
econuse.FX('23','6') = 0;
econuse.FX('23','7') = 0;
econuse.FX('23','8') = 0;
econuse.FX('23','9') = 0;
econuse.FX('23','10') = 0;
econuse.FX('23','11') = 0;
econuse.FX('23','12') = 0;
econuse.FX('23','13') = 4.800000e+000;
econuse.FX('23','14') = 0;
econuse.FX('23','15') = 0;
econuse.FX('23','16') = 0;
econuse.FX('23','17') = 0;
econuse.FX('23','18') = 0;
econuse.FX('23','19') = 0;
econuse.FX('23','20') = 0;
econuse.FX('23','21') = 0;
econuse.FX('23','22') = 0;
econuse.FX('23','23') = 7.030000e+001;
econuse.FX('23','24') = 0;
econuse.FX('23','25') = 0;
econuse.FX('23','26') = 0;
econuse.FX('23','27') = 0;
econuse.FX('23','28') = 0;
econuse.FX('23','29') = 0;
econuse.FX('23','30') = 0;
econuse.FX('23','31') = 0;
econuse.FX('23','32') = 0;
econuse.FX('23','33') = 0;
econuse.FX('23','34') = 0;
econuse.FX('23','35') = 0;
econuse.FX('23','36') = 2.270000e+001;
econuse.FX('23','37') = 0;
econuse.FX('23','38') = 0;
econuse.FX('23','39') = 0;
econuse.FX('23','40') = 0;
econuse.FX('23','41') = 0;
econuse.FX('23','42') = 0;
econuse.FX('23','43') = 0;
econuse.FX('23','44') = 0;
econuse.FX('23','45') = 0;
econuse.FX('23','46') = 0;
econuse.FX('23','47') = 0;
econuse.FX('23','48') = 0;
econuse.FX('23','49') = 0;
econuse.FX('23','50') = 0;
econuse.FX('23','51') = 0;
econuse.FX('23','52') = 0;
econuse.FX('23','53') = 6.740000e+001;
econuse.FX('23','54') = 0;
econuse.FX('23','55') = 0;
econuse.FX('23','56') = 0;
econuse.FX('23','57') = 9.200000e+000;
econuse.FX('23','58') = 0;
econuse.FX('23','59') = 3.520000e+001;
econuse.FX('23','60') = 0;
econuse.FX('23','61') = 1.820000e+001;
econuse.FX('23','62') = 0;
econuse.FX('23','63') = 3.000000e-001;
econuse.FX('23','64') = 0;
econuse.FX('23','65') = 0;
econuse.FX('23','66') = 2.000000e-001;
econuse.FX('23','67') = 4.590000e+001;
econuse.FX('23','68') = 2;
econuse.FX('23','69') = 1.610000e+001;
econuse.FX('23','70') = 7.400000e+000;
econuse.FX('23','71') = 1.640000e+001;
econuse.FX('23','72') = 0;
econuse.FX('23','73') = 7.613000e+002;
econuse.FX('23','74') = 0;
econuse.FX('24','1') = 1.676000e+002;
econuse.FX('24','2') = 3.639000e+002;
econuse.FX('24','3') = 6.820000e+001;
econuse.FX('24','4') = 7.929000e+002;
econuse.FX('24','5') = 1.843000e+002;
econuse.FX('24','6') = 1.125100e+003;
econuse.FX('24','7') = 11;
econuse.FX('24','8') = 4.776000e+002;
econuse.FX('24','9') = 1.729000e+002;
econuse.FX('24','10') = 8.200000e+000;
econuse.FX('24','11') = 1.308000e+002;
econuse.FX('24','12') = 8.300000e+000;
econuse.FX('24','13') = 6.800800e+003;
econuse.FX('24','14') = 4.152800e+003;
econuse.FX('24','15') = 1.393530e+004;
econuse.FX('24','16') = 2.569000e+002;
econuse.FX('24','17') = 1.174500e+003;
econuse.FX('24','18') = 5.774700e+003;
econuse.FX('24','19') = 3.076800e+003;
econuse.FX('24','20') = 2.577800e+003;
econuse.FX('24','21') = 1.083470e+004;
econuse.FX('24','22') = 2.052000e+002;
econuse.FX('24','23') = 4.264000e+002;
econuse.FX('24','24') = 6.118930e+004;
econuse.FX('24','25') = 3.295120e+004;
econuse.FX('24','26') = 1756;
econuse.FX('24','27') = 1055;
econuse.FX('24','28') = 5.057800e+003;
econuse.FX('24','29') = 2.093100e+003;
econuse.FX('24','30') = 1.135000e+002;
econuse.FX('24','31') = 8503;
econuse.FX('24','32') = 5.044300e+003;
econuse.FX('24','33') = 5.915000e+002;
econuse.FX('24','34') = 1.344600e+003;
econuse.FX('24','35') = 4.121500e+003;
econuse.FX('24','36') = 1572;
econuse.FX('24','37') = 7.100000e+000;
econuse.FX('24','38') = 1.215000e+002;
econuse.FX('24','39') = 6.300000e+000;
econuse.FX('24','40') = 2.693000e+002;
econuse.FX('24','41') = 1.430000e+001;
econuse.FX('24','42') = 1.560000e+001;
econuse.FX('24','43') = 256;
econuse.FX('24','44') = 2.259000e+002;
econuse.FX('24','45') = 5.831000e+002;
econuse.FX('24','46') = 1.711000e+002;
econuse.FX('24','47') = 2.454000e+002;
econuse.FX('24','48') = 3.599000e+002;
econuse.FX('24','49') = 1.507000e+002;
econuse.FX('24','50') = 1.081000e+002;
econuse.FX('24','51') = 3.680000e+001;
econuse.FX('24','52') = 0;
econuse.FX('24','53') = 749;
econuse.FX('24','54') = 1.055700e+003;
econuse.FX('24','55') = 2.118000e+002;
econuse.FX('24','56') = 7.890000e+001;
econuse.FX('24','57') = 4.476800e+003;
econuse.FX('24','58') = 1125;
econuse.FX('24','59') = 9.263000e+002;
econuse.FX('24','60') = 136;
econuse.FX('24','61') = 6.059000e+002;
econuse.FX('24','62') = 2.225590e+004;
econuse.FX('24','63') = 1.542420e+004;
econuse.FX('24','64') = 1.580400e+003;
econuse.FX('24','65') = 4.788000e+002;
econuse.FX('24','66') = 74;
econuse.FX('24','67') = 3.086000e+002;
econuse.FX('24','68') = 7.670000e+001;
econuse.FX('24','69') = 4.178000e+002;
econuse.FX('24','70') = 3.411200e+003;
econuse.FX('24','71') = 3.627100e+003;
econuse.FX('24','72') = 6.640000e+001;
econuse.FX('24','73') = 1.931640e+004;
econuse.FX('24','74') = 8.547000e+002;
econuse.FX('25','1') = 1.746000e+002;
econuse.FX('25','2') = 5.633000e+002;
econuse.FX('25','3') = 6.480000e+001;
econuse.FX('25','4') = 1.396000e+002;
econuse.FX('25','5') = 1.451000e+002;
econuse.FX('25','6') = 6.791000e+002;
econuse.FX('25','7') = 3.689000e+002;
econuse.FX('25','8') = 5.217000e+002;
econuse.FX('25','9') = 2.764000e+002;
econuse.FX('25','10') = 9.580000e+001;
econuse.FX('25','11') = 2.825000e+002;
econuse.FX('25','12') = 1.400000e+000;
econuse.FX('25','13') = 2.068770e+004;
econuse.FX('25','14') = 1.252070e+004;
econuse.FX('25','15') = 3.826000e+002;
econuse.FX('25','16') = 2.243000e+002;
econuse.FX('25','17') = 7.816000e+002;
econuse.FX('25','18') = 1.934700e+003;
econuse.FX('25','19') = 8.213000e+002;
econuse.FX('25','20') = 3.598000e+002;
econuse.FX('25','21') = 1.105300e+003;
econuse.FX('25','22') = 2.220000e+001;
econuse.FX('25','23') = 1.041000e+002;
econuse.FX('25','24') = 6.920800e+003;
econuse.FX('25','25') = 1.171810e+004;
econuse.FX('25','26') = 785;
econuse.FX('25','27') = 486;
econuse.FX('25','28') = 1.570200e+003;
econuse.FX('25','29') = 6.247100e+003;
econuse.FX('25','30') = 7.931000e+002;
econuse.FX('25','31') = 7.709400e+003;
econuse.FX('25','32') = 17645;
econuse.FX('25','33') = 1.345900e+003;
econuse.FX('25','34') = 3.949400e+003;
econuse.FX('25','35') = 4.352900e+003;
econuse.FX('25','36') = 9.634900e+003;
econuse.FX('25','37') = 4.500000e+000;
econuse.FX('25','38') = 2.110000e+001;
econuse.FX('25','39') = 1.700000e+000;
econuse.FX('25','40') = 2.054600e+003;
econuse.FX('25','41') = 1.227000e+002;
econuse.FX('25','42') = 2.027000e+002;
econuse.FX('25','43') = 6.701000e+002;
econuse.FX('25','44') = 1.467000e+002;
econuse.FX('25','45') = 3.673000e+002;
econuse.FX('25','46') = 8.170000e+001;
econuse.FX('25','47') = 1.753300e+003;
econuse.FX('25','48') = 1.698000e+002;
econuse.FX('25','49') = 3.590000e+001;
econuse.FX('25','50') = 4.210000e+001;
econuse.FX('25','51') = 1.836000e+002;
econuse.FX('25','52') = 6.600000e+000;
econuse.FX('25','53') = 1.504300e+003;
econuse.FX('25','54') = 1.268600e+003;
econuse.FX('25','55') = 1.436000e+002;
econuse.FX('25','56') = 2.093000e+002;
econuse.FX('25','57') = 2.017200e+003;
econuse.FX('25','58') = 1.892000e+002;
econuse.FX('25','59') = 1.038300e+003;
econuse.FX('25','60') = 154;
econuse.FX('25','61') = 3.549000e+002;
econuse.FX('25','62') = 2.427800e+003;
econuse.FX('25','63') = 3.505800e+003;
econuse.FX('25','64') = 9.893000e+002;
econuse.FX('25','65') = 6.516000e+002;
econuse.FX('25','66') = 2.060000e+001;
econuse.FX('25','67') = 1.029000e+002;
econuse.FX('25','68') = 1.625000e+002;
econuse.FX('25','69') = 4.770200e+003;
econuse.FX('25','70') = 6.271500e+003;
econuse.FX('25','71') = 1549;
econuse.FX('25','72') = 1.550000e+001;
econuse.FX('25','73') = 5.740400e+003;
econuse.FX('25','74') = 2.605600e+003;
econuse.FX('26','1') = 0;
econuse.FX('26','2') = 14;
econuse.FX('26','3') = 3.000000e-001;
econuse.FX('26','4') = 0;
econuse.FX('26','5') = 1.380000e+001;
econuse.FX('26','6') = 6.480000e+001;
econuse.FX('26','7') = 6.080000e+001;
econuse.FX('26','8') = 3.444000e+002;
econuse.FX('26','9') = 2.576000e+002;
econuse.FX('26','10') = 1.045000e+002;
econuse.FX('26','11') = 276;
econuse.FX('26','12') = 1.710000e+001;
econuse.FX('26','13') = 4.495920e+004;
econuse.FX('26','14') = 4.318500e+003;
econuse.FX('26','15') = 226;
econuse.FX('26','16') = 0;
econuse.FX('26','17') = 9.663000e+002;
econuse.FX('26','18') = 6.960000e+001;
econuse.FX('26','19') = 2.100000e+000;
econuse.FX('26','20') = 939;
econuse.FX('26','21') = 9.760000e+001;
econuse.FX('26','22') = 1.149000e+002;
econuse.FX('26','23') = 4.600000e+000;
econuse.FX('26','24') = 9.955000e+002;
econuse.FX('26','25') = 1120;
econuse.FX('26','26') = 1.139970e+004;
econuse.FX('26','27') = 1.190800e+003;
econuse.FX('26','28') = 9.693000e+002;
econuse.FX('26','29') = 1.324200e+003;
econuse.FX('26','30') = 2.467000e+002;
econuse.FX('26','31') = 2.563100e+003;
econuse.FX('26','32') = 4.841600e+003;
econuse.FX('26','33') = 2.138000e+002;
econuse.FX('26','34') = 3.134000e+002;
econuse.FX('26','35') = 603;
econuse.FX('26','36') = 1.217100e+003;
econuse.FX('26','37') = 2.700000e+000;
econuse.FX('26','38') = 8.800000e+000;
econuse.FX('26','39') = 0;
econuse.FX('26','40') = 2.190000e+001;
econuse.FX('26','41') = 7.600000e+000;
econuse.FX('26','42') = 1.250000e+001;
econuse.FX('26','43') = 1.060000e+001;
econuse.FX('26','44') = 3.070000e+001;
econuse.FX('26','45') = 1.370000e+001;
econuse.FX('26','46') = 1.550000e+001;
econuse.FX('26','47') = 8.894000e+002;
econuse.FX('26','48') = 1.952000e+002;
econuse.FX('26','49') = 1.670000e+001;
econuse.FX('26','50') = 8.300000e+000;
econuse.FX('26','51') = 6.900000e+000;
econuse.FX('26','52') = 0;
econuse.FX('26','53') = 1.418900e+003;
econuse.FX('26','54') = 4.975000e+002;
econuse.FX('26','55') = 1.900000e+000;
econuse.FX('26','56') = 2.560000e+001;
econuse.FX('26','57') = 1.107400e+003;
econuse.FX('26','58') = 1.361000e+002;
econuse.FX('26','59') = 2.564000e+002;
econuse.FX('26','60') = 1.025000e+002;
econuse.FX('26','61') = 109;
econuse.FX('26','62') = 1.226700e+003;
econuse.FX('26','63') = 6.072000e+002;
econuse.FX('26','64') = 2.134000e+002;
econuse.FX('26','65') = 1.669000e+002;
econuse.FX('26','66') = 1.060000e+001;
econuse.FX('26','67') = 1.034000e+002;
econuse.FX('26','68') = 8.290000e+001;
econuse.FX('26','69') = 2.688300e+003;
econuse.FX('26','70') = 1.225100e+003;
econuse.FX('26','71') = 2.312000e+002;
econuse.FX('26','72') = 0;
econuse.FX('26','73') = 7.313000e+002;
econuse.FX('26','74') = 2.597100e+003;
econuse.FX('27','1') = 2.580000e+001;
econuse.FX('27','2') = 2.070000e+001;
econuse.FX('27','3') = 1.120000e+001;
econuse.FX('27','4') = 1.310000e+001;
econuse.FX('27','5') = 4.700000e+000;
econuse.FX('27','6') = 1.924000e+002;
econuse.FX('27','7') = 1.497000e+002;
econuse.FX('27','8') = 8.327000e+002;
econuse.FX('27','9') = 564;
econuse.FX('27','10') = 4.500000e+000;
econuse.FX('27','11') = 3.190000e+001;
econuse.FX('27','12') = 0;
econuse.FX('27','13') = 3.723800e+003;
econuse.FX('27','14') = 3.879500e+003;
econuse.FX('27','15') = 9.030000e+001;
econuse.FX('27','16') = 1.081000e+002;
econuse.FX('27','17') = 107;
econuse.FX('27','18') = 6.044000e+002;
econuse.FX('27','19') = 2.210000e+001;
econuse.FX('27','20') = 7.910000e+001;
econuse.FX('27','21') = 2.840000e+001;
econuse.FX('27','22') = 5.000000e-001;
econuse.FX('27','23') = 0;
econuse.FX('27','24') = 6.886000e+002;
econuse.FX('27','25') = 9.088000e+002;
econuse.FX('27','26') = 9.103000e+002;
econuse.FX('27','27') = 3.950740e+004;
econuse.FX('27','28') = 3.740320e+004;
econuse.FX('27','29') = 2.356580e+004;
econuse.FX('27','30') = 1.063900e+003;
econuse.FX('27','31') = 1.920580e+004;
econuse.FX('27','32') = 3.340240e+004;
econuse.FX('27','33') = 2.646100e+003;
econuse.FX('27','34') = 2.898100e+003;
econuse.FX('27','35') = 5.455600e+003;
econuse.FX('27','36') = 6.719000e+002;
econuse.FX('27','37') = 1.000000e-001;
econuse.FX('27','38') = 5.517000e+002;
econuse.FX('27','39') = 0;
econuse.FX('27','40') = 0;
econuse.FX('27','41') = 0;
econuse.FX('27','42') = 0;
econuse.FX('27','43') = 3.660000e+001;
econuse.FX('27','44') = 7.000000e-001;
econuse.FX('27','45') = 5.760000e+001;
econuse.FX('27','46') = 4.990000e+001;
econuse.FX('27','47') = 3.592000e+002;
econuse.FX('27','48') = 1.591000e+002;
econuse.FX('27','49') = 0;
econuse.FX('27','50') = 0;
econuse.FX('27','51') = 3.100000e+000;
econuse.FX('27','52') = 0;
econuse.FX('27','53') = 282;
econuse.FX('27','54') = 2.827000e+002;
econuse.FX('27','55') = 2.000000e-001;
econuse.FX('27','56') = 1.300000e+000;
econuse.FX('27','57') = 4.349000e+002;
econuse.FX('27','58') = 1.030000e+001;
econuse.FX('27','59') = 8.890000e+001;
econuse.FX('27','60') = 7.920000e+001;
econuse.FX('27','61') = 6.810000e+001;
econuse.FX('27','62') = 2.521000e+002;
econuse.FX('27','63') = 1.011000e+002;
econuse.FX('27','64') = 2.260000e+001;
econuse.FX('27','65') = 9.710000e+001;
econuse.FX('27','66') = 9.500000e+000;
econuse.FX('27','67') = 1.313000e+002;
econuse.FX('27','68') = 4.700000e+000;
econuse.FX('27','69') = 5.143000e+002;
econuse.FX('27','70') = 7.656000e+002;
econuse.FX('27','71') = 3.562000e+002;
econuse.FX('27','72') = 13;
econuse.FX('27','73') = 2.592000e+002;
econuse.FX('27','74') = 4.686000e+002;
econuse.FX('28','1') = 7.940000e+001;
econuse.FX('28','2') = 2.523000e+002;
econuse.FX('28','3') = 9.050000e+001;
econuse.FX('28','4') = 3.831000e+002;
econuse.FX('28','5') = 1.554000e+002;
econuse.FX('28','6') = 2.395800e+003;
econuse.FX('28','7') = 2.654000e+002;
econuse.FX('28','8') = 4.979000e+002;
econuse.FX('28','9') = 4.679000e+002;
econuse.FX('28','10') = 2.106000e+002;
econuse.FX('28','11') = 7.725000e+002;
econuse.FX('28','12') = 9.600000e+000;
econuse.FX('28','13') = 4.697170e+004;
econuse.FX('28','14') = 1.009590e+004;
econuse.FX('28','15') = 6.594000e+002;
econuse.FX('28','16') = 1.563000e+002;
econuse.FX('28','17') = 1.783700e+003;
econuse.FX('28','18') = 1.646700e+003;
econuse.FX('28','19') = 7.561000e+002;
econuse.FX('28','20') = 8.864000e+002;
econuse.FX('28','21') = 7.697000e+002;
econuse.FX('28','22') = 103;
econuse.FX('28','23') = 1.384000e+002;
econuse.FX('28','24') = 4.266100e+003;
econuse.FX('28','25') = 3518;
econuse.FX('28','26') = 1.663900e+003;
econuse.FX('28','27') = 3.488400e+003;
econuse.FX('28','28') = 19358;
econuse.FX('28','29') = 1.725170e+004;
econuse.FX('28','30') = 7.691000e+002;
econuse.FX('28','31') = 8.525700e+003;
econuse.FX('28','32') = 2.971050e+004;
econuse.FX('28','33') = 2.989700e+003;
econuse.FX('28','34') = 2.366700e+003;
econuse.FX('28','35') = 3.955600e+003;
econuse.FX('28','36') = 3.153600e+003;
econuse.FX('28','37') = 7.849000e+002;
econuse.FX('28','38') = 1.429000e+002;
econuse.FX('28','39') = 1.922700e+003;
econuse.FX('28','40') = 1.708700e+003;
econuse.FX('28','41') = 1.262400e+003;
econuse.FX('28','42') = 9.386000e+002;
econuse.FX('28','43') = 4.199000e+002;
econuse.FX('28','44') = 1.666000e+002;
econuse.FX('28','45') = 1.194700e+003;
econuse.FX('28','46') = 3.220000e+001;
econuse.FX('28','47') = 3.503800e+003;
econuse.FX('28','48') = 3.648000e+002;
econuse.FX('28','49') = 4.660000e+001;
econuse.FX('28','50') = 1.940000e+001;
econuse.FX('28','51') = 2.810000e+001;
econuse.FX('28','52') = 3.400000e+000;
econuse.FX('28','53') = 2.430400e+003;
econuse.FX('28','54') = 1.582400e+003;
econuse.FX('28','55') = 6.680000e+001;
econuse.FX('28','56') = 3.685000e+002;
econuse.FX('28','57') = 2.039400e+003;
econuse.FX('28','58') = 7.876000e+002;
econuse.FX('28','59') = 6.946000e+002;
econuse.FX('28','60') = 6.883000e+002;
econuse.FX('28','61') = 1.535000e+002;
econuse.FX('28','62') = 180;
econuse.FX('28','63') = 1.802000e+002;
econuse.FX('28','64') = 1.770000e+001;
econuse.FX('28','65') = 518;
econuse.FX('28','66') = 7.400000e+000;
econuse.FX('28','67') = 1.987000e+002;
econuse.FX('28','68') = 3.908000e+002;
econuse.FX('28','69') = 4.184100e+003;
econuse.FX('28','70') = 3.855400e+003;
econuse.FX('28','71') = 3.113600e+003;
econuse.FX('28','72') = 2.127000e+002;
econuse.FX('28','73') = 1.789500e+003;
econuse.FX('28','74') = 3.495500e+003;
econuse.FX('29','1') = 2.061000e+002;
econuse.FX('29','2') = 5.904000e+002;
econuse.FX('29','3') = 1.266000e+002;
econuse.FX('29','4') = 1.663000e+002;
econuse.FX('29','5') = 4.635000e+002;
econuse.FX('29','6') = 686;
econuse.FX('29','7') = 824;
econuse.FX('29','8') = 1054;
econuse.FX('29','9') = 6.518000e+002;
econuse.FX('29','10') = 1.770100e+003;
econuse.FX('29','11') = 7.041000e+002;
econuse.FX('29','12') = 3.000000e-001;
econuse.FX('29','13') = 1.793710e+004;
econuse.FX('29','14') = 1422;
econuse.FX('29','15') = 5.350000e+001;
econuse.FX('29','16') = 1.510000e+001;
econuse.FX('29','17') = 3.589000e+002;
econuse.FX('29','18') = 639;
econuse.FX('29','19') = 1035;
econuse.FX('29','20') = 1.699000e+002;
econuse.FX('29','21') = 6.178000e+002;
econuse.FX('29','22') = 3.200000e+000;
econuse.FX('29','23') = 2.600000e+000;
econuse.FX('29','24') = 1.436700e+003;
econuse.FX('29','25') = 1.231500e+003;
econuse.FX('29','26') = 2.563000e+002;
econuse.FX('29','27') = 1.888700e+003;
econuse.FX('29','28') = 2.390500e+003;
econuse.FX('29','29') = 2.028150e+004;
econuse.FX('29','30') = 3.650000e+001;
econuse.FX('29','31') = 1.887800e+003;
econuse.FX('29','32') = 1.327580e+004;
econuse.FX('29','33') = 1.920100e+003;
econuse.FX('29','34') = 65;
econuse.FX('29','35') = 6.558000e+002;
econuse.FX('29','36') = 1.301700e+003;
econuse.FX('29','37') = 1.960000e+001;
econuse.FX('29','38') = 2.017000e+002;
econuse.FX('29','39') = 1.030000e+001;
econuse.FX('29','40') = 1.469000e+002;
econuse.FX('29','41') = 2.293000e+002;
econuse.FX('29','42') = 1.000400e+003;
econuse.FX('29','43') = 9.750000e+001;
econuse.FX('29','44') = 2.612000e+002;
econuse.FX('29','45') = 241;
econuse.FX('29','46') = 2.355000e+002;
econuse.FX('29','47') = 3.182000e+002;
econuse.FX('29','48') = 2.236000e+002;
econuse.FX('29','49') = 6.300000e+000;
econuse.FX('29','50') = 6.500000e+000;
econuse.FX('29','51') = 3.800000e+000;
econuse.FX('29','52') = 0;
econuse.FX('29','53') = 1.346200e+003;
econuse.FX('29','54') = 848;
econuse.FX('29','55') = 1.650000e+001;
econuse.FX('29','56') = 3.709000e+002;
econuse.FX('29','57') = 1.206600e+003;
econuse.FX('29','58') = 3.226000e+002;
econuse.FX('29','59') = 4.679000e+002;
econuse.FX('29','60') = 6.422000e+002;
econuse.FX('29','61') = 868;
econuse.FX('29','62') = 9.930000e+001;
econuse.FX('29','63') = 9.430000e+001;
econuse.FX('29','64') = 2.930000e+001;
econuse.FX('29','65') = 5.010000e+001;
econuse.FX('29','66') = 6.200000e+000;
econuse.FX('29','67') = 5.340000e+001;
econuse.FX('29','68') = 2.190000e+001;
econuse.FX('29','69') = 6.487000e+002;
econuse.FX('29','70') = 4.242600e+003;
econuse.FX('29','71') = 4.884000e+002;
econuse.FX('29','72') = 1.927000e+002;
econuse.FX('29','73') = 2.111900e+003;
econuse.FX('29','74') = 1.590700e+003;
econuse.FX('30','1') = 5.000000e-001;
econuse.FX('30','2') = 1.340000e+001;
econuse.FX('30','3') = 0;
econuse.FX('30','4') = 1.000000e-001;
econuse.FX('30','5') = 5.000000e-001;
econuse.FX('30','6') = 0;
econuse.FX('30','7') = 5.300000e+000;
econuse.FX('30','8') = 8.800000e+000;
econuse.FX('30','9') = 8.700000e+000;
econuse.FX('30','10') = 2.810000e+001;
econuse.FX('30','11') = 2.430000e+001;
econuse.FX('30','12') = 1.700000e+000;
econuse.FX('30','13') = 7.930000e+001;
econuse.FX('30','14') = 7.790000e+001;
econuse.FX('30','15') = 7.300000e+000;
econuse.FX('30','16') = 3.200000e+000;
econuse.FX('30','17') = 3.020000e+001;
econuse.FX('30','18') = 2.210000e+001;
econuse.FX('30','19') = 1.047000e+002;
econuse.FX('30','20') = 5.880000e+001;
econuse.FX('30','21') = 0;
econuse.FX('30','22') = 0;
econuse.FX('30','23') = 0;
econuse.FX('30','24') = 2.100000e+000;
econuse.FX('30','25') = 1.267000e+002;
econuse.FX('30','26') = 2.110000e+001;
econuse.FX('30','27') = 1.580000e+001;
econuse.FX('30','28') = 4.910000e+001;
econuse.FX('30','29') = 1.078000e+002;
econuse.FX('30','30') = 1.177640e+004;
econuse.FX('30','31') = 1.376200e+003;
econuse.FX('30','32') = 9.443000e+002;
econuse.FX('30','33') = 9.600000e+000;
econuse.FX('30','34') = 2.450000e+001;
econuse.FX('30','35') = 2.560000e+001;
econuse.FX('30','36') = 5.135000e+002;
econuse.FX('30','37') = 0;
econuse.FX('30','38') = 0;
econuse.FX('30','39') = 0;
econuse.FX('30','40') = 1.385000e+002;
econuse.FX('30','41') = 6.400000e+000;
econuse.FX('30','42') = 1.390000e+001;
econuse.FX('30','43') = 3.420000e+001;
econuse.FX('30','44') = 1.860000e+001;
econuse.FX('30','45') = 304;
econuse.FX('30','46') = 1.940000e+001;
econuse.FX('30','47') = 9.379000e+002;
econuse.FX('30','48') = 1.259000e+002;
econuse.FX('30','49') = 1.560800e+003;
econuse.FX('30','50') = 1.449000e+002;
econuse.FX('30','51') = 7.500000e+000;
econuse.FX('30','52') = 4.330000e+001;
econuse.FX('30','53') = 1.136000e+002;
econuse.FX('30','54') = 1172;
econuse.FX('30','55') = 3.405000e+002;
econuse.FX('30','56') = 2.169000e+002;
econuse.FX('30','57') = 1.919800e+003;
econuse.FX('30','58') = 1.961300e+003;
econuse.FX('30','59') = 402;
econuse.FX('30','60') = 3.380000e+001;
econuse.FX('30','61') = 2.571000e+002;
econuse.FX('30','62') = 405;
econuse.FX('30','63') = 5;
econuse.FX('30','64') = 8.490000e+001;
econuse.FX('30','65') = 60;
econuse.FX('30','66') = 9;
econuse.FX('30','67') = 4.740000e+001;
econuse.FX('30','68') = 6.440000e+001;
econuse.FX('30','69') = 6.950000e+001;
econuse.FX('30','70') = 2.698000e+002;
econuse.FX('30','71') = 1.275800e+003;
econuse.FX('30','72') = 0;
econuse.FX('30','73') = 2.205600e+003;
econuse.FX('30','74') = 1.136000e+002;
econuse.FX('31','1') = 5.280000e+001;
econuse.FX('31','2') = 1.279000e+002;
econuse.FX('31','3') = 3.340000e+001;
econuse.FX('31','4') = 2.880000e+001;
econuse.FX('31','5') = 233;
econuse.FX('31','6') = 9.800000e+000;
econuse.FX('31','7') = 2.240000e+001;
econuse.FX('31','8') = 8.220000e+001;
econuse.FX('31','9') = 6.180000e+001;
econuse.FX('31','10') = 6.740000e+001;
econuse.FX('31','11') = 5.923000e+002;
econuse.FX('31','12') = 8.790000e+001;
econuse.FX('31','13') = 2.582980e+004;
econuse.FX('31','14') = 2.561100e+003;
econuse.FX('31','15') = 994;
econuse.FX('31','16') = 1.358000e+002;
econuse.FX('31','17') = 9.856000e+002;
econuse.FX('31','18') = 1.795900e+003;
econuse.FX('31','19') = 1.154300e+003;
econuse.FX('31','20') = 664;
econuse.FX('31','21') = 1.035500e+003;
econuse.FX('31','22') = 1.331000e+002;
econuse.FX('31','23') = 1.177000e+002;
econuse.FX('31','24') = 3.625900e+003;
econuse.FX('31','25') = 3.604900e+003;
econuse.FX('31','26') = 1.209200e+003;
econuse.FX('31','27') = 3.823700e+003;
econuse.FX('31','28') = 4.421100e+003;
econuse.FX('31','29') = 1.270550e+004;
econuse.FX('31','30') = 1.137040e+004;
econuse.FX('31','31') = 65761;
econuse.FX('31','32') = 2.718270e+004;
econuse.FX('31','33') = 1.431600e+003;
econuse.FX('31','34') = 8.845000e+002;
econuse.FX('31','35') = 2.332900e+003;
econuse.FX('31','36') = 5.995700e+003;
econuse.FX('31','37') = 3.030000e+001;
econuse.FX('31','38') = 1.703000e+002;
econuse.FX('31','39') = 5;
econuse.FX('31','40') = 2.912000e+002;
econuse.FX('31','41') = 159;
econuse.FX('31','42') = 5.650000e+001;
econuse.FX('31','43') = 6.520000e+001;
econuse.FX('31','44') = 2.286000e+002;
econuse.FX('31','45') = 2.089400e+003;
econuse.FX('31','46') = 1.730200e+003;
econuse.FX('31','47') = 10753;
econuse.FX('31','48') = 1.035600e+003;
econuse.FX('31','49') = 3.478000e+002;
econuse.FX('31','50') = 1.556000e+002;
econuse.FX('31','51') = 3.050000e+001;
econuse.FX('31','52') = 3.430000e+001;
econuse.FX('31','53') = 7.461000e+002;
econuse.FX('31','54') = 4.652100e+003;
econuse.FX('31','55') = 6.895000e+002;
econuse.FX('31','56') = 2.058900e+003;
econuse.FX('31','57') = 6.596700e+003;
econuse.FX('31','58') = 1.916700e+003;
econuse.FX('31','59') = 2.582900e+003;
econuse.FX('31','60') = 3.065000e+002;
econuse.FX('31','61') = 6.585000e+002;
econuse.FX('31','62') = 1.715200e+003;
econuse.FX('31','63') = 1.765800e+003;
econuse.FX('31','64') = 1.492000e+002;
econuse.FX('31','65') = 1.683000e+002;
econuse.FX('31','66') = 8.300000e+000;
econuse.FX('31','67') = 1.996000e+002;
econuse.FX('31','68') = 5.226000e+002;
econuse.FX('31','69') = 2.169200e+003;
econuse.FX('31','70') = 7.506400e+003;
econuse.FX('31','71') = 1.123850e+004;
econuse.FX('31','72') = 3.670000e+001;
econuse.FX('31','73') = 2.704700e+003;
econuse.FX('31','74') = 3.366400e+003;
econuse.FX('32','1') = 9.030000e+001;
econuse.FX('32','2') = 223;
econuse.FX('32','3') = 7.650000e+001;
econuse.FX('32','4') = 8.720000e+001;
econuse.FX('32','5') = 277;
econuse.FX('32','6') = 6.024000e+002;
econuse.FX('32','7') = 1.434000e+002;
econuse.FX('32','8') = 3.042000e+002;
econuse.FX('32','9') = 1.838000e+002;
econuse.FX('32','10') = 2.530000e+001;
econuse.FX('32','11') = 1.923000e+002;
econuse.FX('32','12') = 6.700000e+000;
econuse.FX('32','13') = 5.596400e+003;
econuse.FX('32','14') = 918;
econuse.FX('32','15') = 6.980000e+001;
econuse.FX('32','16') = 4.200000e+000;
econuse.FX('32','17') = 346;
econuse.FX('32','18') = 1.655000e+002;
econuse.FX('32','19') = 7.250000e+001;
econuse.FX('32','20') = 1.945000e+002;
econuse.FX('32','21') = 8.680000e+001;
econuse.FX('32','22') = 8.400000e+000;
econuse.FX('32','23') = 9.900000e+000;
econuse.FX('32','24') = 2.237000e+002;
econuse.FX('32','25') = 139;
econuse.FX('32','26') = 1.945000e+002;
econuse.FX('32','27') = 4.992000e+002;
econuse.FX('32','28') = 1.949000e+002;
econuse.FX('32','29') = 4.097200e+003;
econuse.FX('32','30') = 1.178000e+002;
econuse.FX('32','31') = 757;
econuse.FX('32','32') = 163608;
econuse.FX('32','33') = 1.883600e+003;
econuse.FX('32','34') = 1.074000e+002;
econuse.FX('32','35') = 1.009000e+002;
econuse.FX('32','36') = 7.636300e+003;
econuse.FX('32','37') = 1.587900e+003;
econuse.FX('32','38') = 1.008000e+002;
econuse.FX('32','39') = 7.000000e-001;
econuse.FX('32','40') = 5.418300e+003;
econuse.FX('32','41') = 1.938700e+003;
econuse.FX('32','42') = 1.500000e+000;
econuse.FX('32','43') = 1.319900e+003;
econuse.FX('32','44') = 4.651000e+002;
econuse.FX('32','45') = 178;
econuse.FX('32','46') = 6.600000e+000;
econuse.FX('32','47') = 337;
econuse.FX('32','48') = 5.420000e+001;
econuse.FX('32','49') = 9.120000e+001;
econuse.FX('32','50') = 6.550000e+001;
econuse.FX('32','51') = 2.060000e+001;
econuse.FX('32','52') = 0;
econuse.FX('32','53') = 2.880000e+001;
econuse.FX('32','54') = 1.595000e+002;
econuse.FX('32','55') = 3.000000e-001;
econuse.FX('32','56') = 5.900000e+000;
econuse.FX('32','57') = 1.048800e+003;
econuse.FX('32','58') = 5.117000e+002;
econuse.FX('32','59') = 1.253600e+003;
econuse.FX('32','60') = 7.684000e+002;
econuse.FX('32','61') = 1.644000e+002;
econuse.FX('32','62') = 1.834000e+002;
econuse.FX('32','63') = 6.070000e+001;
econuse.FX('32','64') = 4.450000e+001;
econuse.FX('32','65') = 5.986000e+002;
econuse.FX('32','66') = 30;
econuse.FX('32','67') = 3.260000e+001;
econuse.FX('32','68') = 4.840000e+001;
econuse.FX('32','69') = 6.967000e+002;
econuse.FX('32','70') = 2.310980e+004;
econuse.FX('32','71') = 2.306060e+004;
econuse.FX('32','72') = 1.557800e+003;
econuse.FX('32','73') = 5.223100e+003;
econuse.FX('32','74') = 1.050300e+003;
econuse.FX('33','1') = 0;
econuse.FX('33','2') = 0;
econuse.FX('33','3') = 0;
econuse.FX('33','4') = 0;
econuse.FX('33','5') = 121;
econuse.FX('33','6') = 0;
econuse.FX('33','7') = 1.160000e+001;
econuse.FX('33','8') = 0;
econuse.FX('33','9') = 0;
econuse.FX('33','10') = 0;
econuse.FX('33','11') = 6.000000e-001;
econuse.FX('33','12') = 0;
econuse.FX('33','13') = 5.340000e+001;
econuse.FX('33','14') = 0;
econuse.FX('33','15') = 0;
econuse.FX('33','16') = 0;
econuse.FX('33','17') = 7.100000e+000;
econuse.FX('33','18') = 0;
econuse.FX('33','19') = 0;
econuse.FX('33','20') = 0;
econuse.FX('33','21') = 0;
econuse.FX('33','22') = 0;
econuse.FX('33','23') = 0;
econuse.FX('33','24') = 0;
econuse.FX('33','25') = 0;
econuse.FX('33','26') = 0;
econuse.FX('33','27') = 0;
econuse.FX('33','28') = 3.720000e+001;
econuse.FX('33','29') = 8.290000e+001;
econuse.FX('33','30') = 0;
econuse.FX('33','31') = 0;
econuse.FX('33','32') = 1.502000e+002;
econuse.FX('33','33') = 1.693500e+003;
econuse.FX('33','34') = 0;
econuse.FX('33','35') = 0;
econuse.FX('33','36') = 2.360000e+001;
econuse.FX('33','37') = 0;
econuse.FX('33','38') = 1.316700e+003;
econuse.FX('33','39') = 8.807000e+002;
econuse.FX('33','40') = 7.400000e+000;
econuse.FX('33','41') = 1.647000e+002;
econuse.FX('33','42') = 0;
econuse.FX('33','43') = 1.089000e+002;
econuse.FX('33','44') = 0;
econuse.FX('33','45') = 0;
econuse.FX('33','46') = 0;
econuse.FX('33','47') = 5.100000e+000;
econuse.FX('33','48') = 0;
econuse.FX('33','49') = 0;
econuse.FX('33','50') = 0;
econuse.FX('33','51') = 7.000000e-001;
econuse.FX('33','52') = 0;
econuse.FX('33','53') = 0;
econuse.FX('33','54') = 0;
econuse.FX('33','55') = 0;
econuse.FX('33','56') = 0;
econuse.FX('33','57') = 6.700000e+000;
econuse.FX('33','58') = 1.000000e-001;
econuse.FX('33','59') = 9.300000e+000;
econuse.FX('33','60') = 1.080000e+001;
econuse.FX('33','61') = 6.000000e-001;
econuse.FX('33','62') = 0;
econuse.FX('33','63') = 0;
econuse.FX('33','64') = 0;
econuse.FX('33','65') = 2.440000e+001;
econuse.FX('33','66') = 0;
econuse.FX('33','67') = 8.700000e+000;
econuse.FX('33','68') = 0;
econuse.FX('33','69') = 0;
econuse.FX('33','70') = 5.916000e+002;
econuse.FX('33','71') = 2.135300e+003;
econuse.FX('33','72') = 3.600000e+000;
econuse.FX('33','73') = 3.300000e+000;
econuse.FX('33','74') = 1.202000e+002;
econuse.FX('34','1') = 0;
econuse.FX('34','2') = 9.800000e+000;
econuse.FX('34','3') = 0;
econuse.FX('34','4') = 0;
econuse.FX('34','5') = 0;
econuse.FX('34','6') = 0;
econuse.FX('34','7') = 0;
econuse.FX('34','8') = 0;
econuse.FX('34','9') = 0;
econuse.FX('34','10') = 0;
econuse.FX('34','11') = 18;
econuse.FX('34','12') = 0;
econuse.FX('34','13') = 1.123170e+004;
econuse.FX('34','14') = 0;
econuse.FX('34','15') = 0;
econuse.FX('34','16') = 0;
econuse.FX('34','17') = 2.974000e+002;
econuse.FX('34','18') = 6.000000e-001;
econuse.FX('34','19') = 1.000000e-001;
econuse.FX('34','20') = 0;
econuse.FX('34','21') = 0;
econuse.FX('34','22') = 0;
econuse.FX('34','23') = 0;
econuse.FX('34','24') = 0;
econuse.FX('34','25') = 1.713000e+002;
econuse.FX('34','26') = 7.000000e-001;
econuse.FX('34','27') = 0;
econuse.FX('34','28') = 25;
econuse.FX('34','29') = 1.739000e+002;
econuse.FX('34','30') = 5.870000e+001;
econuse.FX('34','31') = 4.983000e+002;
econuse.FX('34','32') = 1.706000e+002;
econuse.FX('34','33') = 5.600000e+000;
econuse.FX('34','34') = 1935;
econuse.FX('34','35') = 2.308000e+002;
econuse.FX('34','36') = 7.235000e+002;
econuse.FX('34','37') = 1.400000e+000;
econuse.FX('34','38') = 0;
econuse.FX('34','39') = 8.000000e-001;
econuse.FX('34','40') = 0;
econuse.FX('34','41') = 0;
econuse.FX('34','42') = 0;
econuse.FX('34','43') = 5.200000e+000;
econuse.FX('34','44') = 0;
econuse.FX('34','45') = 1.800000e+000;
econuse.FX('34','46') = 0;
econuse.FX('34','47') = 9.260000e+001;
econuse.FX('34','48') = 7.320000e+001;
econuse.FX('34','49') = 0;
econuse.FX('34','50') = 0;
econuse.FX('34','51') = 0;
econuse.FX('34','52') = 0;
econuse.FX('34','53') = 4081;
econuse.FX('34','54') = 3.450000e+001;
econuse.FX('34','55') = 9.900000e+000;
econuse.FX('34','56') = 1.100000e+000;
econuse.FX('34','57') = 7.340000e+001;
econuse.FX('34','58') = 4.100000e+000;
econuse.FX('34','59') = 1.900000e+000;
econuse.FX('34','60') = 0;
econuse.FX('34','61') = 9.000000e-001;
econuse.FX('34','62') = 1.044000e+002;
econuse.FX('34','63') = 9.270000e+001;
econuse.FX('34','64') = 2.500000e+000;
econuse.FX('34','65') = 5.430000e+001;
econuse.FX('34','66') = 153;
econuse.FX('34','67') = 1.057000e+002;
econuse.FX('34','68') = 1.500000e+000;
econuse.FX('34','69') = 5.478000e+002;
econuse.FX('34','70') = 136;
econuse.FX('34','71') = 0;
econuse.FX('34','72') = 1.030000e+001;
econuse.FX('34','73') = 1.320000e+001;
econuse.FX('34','74') = 4.854000e+002;
econuse.FX('35','1') = 7.200000e+000;
econuse.FX('35','2') = 4.440000e+001;
econuse.FX('35','3') = 9.400000e+000;
econuse.FX('35','4') = 9.940000e+001;
econuse.FX('35','5') = 4.700000e+000;
econuse.FX('35','6') = 8.770000e+001;
econuse.FX('35','7') = 8.200000e+000;
econuse.FX('35','8') = 6.050000e+001;
econuse.FX('35','9') = 45;
econuse.FX('35','10') = 3.800000e+000;
econuse.FX('35','11') = 8.200000e+000;
econuse.FX('35','12') = 3.000000e-001;
econuse.FX('35','13') = 7.048000e+002;
econuse.FX('35','14') = 5.130000e+001;
econuse.FX('35','15') = 1.485000e+002;
econuse.FX('35','16') = 375;
econuse.FX('35','17') = 2.180000e+001;
econuse.FX('35','18') = 1.700000e+000;
econuse.FX('35','19') = 3.430000e+001;
econuse.FX('35','20') = 2.480000e+001;
econuse.FX('35','21') = 4.686000e+002;
econuse.FX('35','22') = 0;
econuse.FX('35','23') = 0;
econuse.FX('35','24') = 82;
econuse.FX('35','25') = 1.283000e+002;
econuse.FX('35','26') = 1.927000e+002;
econuse.FX('35','27') = 41;
econuse.FX('35','28') = 2.551000e+002;
econuse.FX('35','29') = 1.681100e+003;
econuse.FX('35','30') = 2.300000e+000;
econuse.FX('35','31') = 2.565000e+002;
econuse.FX('35','32') = 1.754800e+003;
econuse.FX('35','33') = 13;
econuse.FX('35','34') = 3.340000e+001;
econuse.FX('35','35') = 8.405900e+003;
econuse.FX('35','36') = 1767;
econuse.FX('35','37') = 4.500000e+000;
econuse.FX('35','38') = 3.100000e+000;
econuse.FX('35','39') = 0;
econuse.FX('35','40') = 8.200000e+000;
econuse.FX('35','41') = 1.030000e+001;
econuse.FX('35','42') = 2.500000e+000;
econuse.FX('35','43') = 2.670000e+001;
econuse.FX('35','44') = 9.680000e+001;
econuse.FX('35','45') = 1.590000e+001;
econuse.FX('35','46') = 6.300000e+000;
econuse.FX('35','47') = 1.543000e+002;
econuse.FX('35','48') = 1.053000e+002;
econuse.FX('35','49') = 1.603000e+002;
econuse.FX('35','50') = 54;
econuse.FX('35','51') = 1.790000e+001;
econuse.FX('35','52') = 1.300000e+000;
econuse.FX('35','53') = 1.027000e+002;
econuse.FX('35','54') = 5.318000e+002;
econuse.FX('35','55') = 5.170000e+001;
econuse.FX('35','56') = 3.450000e+001;
econuse.FX('35','57') = 1.194800e+003;
econuse.FX('35','58') = 1.450000e+001;
econuse.FX('35','59') = 5.249000e+002;
econuse.FX('35','60') = 3.096000e+002;
econuse.FX('35','61') = 5.952000e+002;
econuse.FX('35','62') = 1.106170e+004;
econuse.FX('35','63') = 5.220900e+003;
econuse.FX('35','64') = 9.596000e+002;
econuse.FX('35','65') = 8.293000e+002;
econuse.FX('35','66') = 4.130000e+001;
econuse.FX('35','67') = 1.354000e+002;
econuse.FX('35','68') = 1.857000e+002;
econuse.FX('35','69') = 9.206000e+002;
econuse.FX('35','70') = 2.432700e+003;
econuse.FX('35','71') = 5.277000e+002;
econuse.FX('35','72') = 4.000000e-001;
econuse.FX('35','73') = 6.879200e+003;
econuse.FX('35','74') = 127;
econuse.FX('36','1') = 1.432700e+003;
econuse.FX('36','2') = 3.207200e+003;
econuse.FX('36','3') = 1122;
econuse.FX('36','4') = 2.827900e+003;
econuse.FX('36','5') = 2.106500e+003;
econuse.FX('36','6') = 1.254200e+003;
econuse.FX('36','7') = 4.865000e+002;
econuse.FX('36','8') = 7.634000e+002;
econuse.FX('36','9') = 5.145000e+002;
econuse.FX('36','10') = 9.604000e+002;
econuse.FX('36','11') = 4.056000e+002;
econuse.FX('36','12') = 2.770000e+001;
econuse.FX('36','13') = 8.080860e+004;
econuse.FX('36','14') = 2.938910e+004;
econuse.FX('36','15') = 3.970700e+003;
econuse.FX('36','16') = 2.488300e+003;
econuse.FX('36','17') = 4.839500e+003;
econuse.FX('36','18') = 8.984500e+003;
econuse.FX('36','19') = 4.657800e+003;
econuse.FX('36','20') = 6.680200e+003;
econuse.FX('36','21') = 3417;
econuse.FX('36','22') = 341;
econuse.FX('36','23') = 3.907000e+002;
econuse.FX('36','24') = 1.868730e+004;
econuse.FX('36','25') = 6.417700e+003;
econuse.FX('36','26') = 3.300500e+003;
econuse.FX('36','27') = 1.022380e+004;
econuse.FX('36','28') = 8.721600e+003;
econuse.FX('36','29') = 1.385240e+004;
econuse.FX('36','30') = 7.248300e+003;
econuse.FX('36','31') = 2.453770e+004;
econuse.FX('36','32') = 3.101630e+004;
econuse.FX('36','33') = 2.568500e+003;
econuse.FX('36','34') = 4.391300e+003;
econuse.FX('36','35') = 5.416200e+003;
econuse.FX('36','36') = 4.077570e+004;
econuse.FX('36','37') = 1152;
econuse.FX('36','38') = 6.995000e+002;
econuse.FX('36','39') = 1.152000e+002;
econuse.FX('36','40') = 5.408600e+003;
econuse.FX('36','41') = 5.402000e+002;
econuse.FX('36','42') = 7.546000e+002;
econuse.FX('36','43') = 1.739600e+003;
econuse.FX('36','44') = 4.383000e+002;
econuse.FX('36','45') = 3.794500e+003;
econuse.FX('36','46') = 1.755000e+002;
econuse.FX('36','47') = 2.716800e+003;
econuse.FX('36','48') = 5.007000e+002;
econuse.FX('36','49') = 1.359100e+003;
econuse.FX('36','50') = 2.965000e+002;
econuse.FX('36','51') = 4.558000e+002;
econuse.FX('36','52') = 29;
econuse.FX('36','53') = 6.009200e+003;
econuse.FX('36','54') = 2.880800e+003;
econuse.FX('36','55') = 669;
econuse.FX('36','56') = 6.003000e+002;
econuse.FX('36','57') = 4.778700e+003;
econuse.FX('36','58') = 1.904100e+003;
econuse.FX('36','59') = 2.043600e+003;
econuse.FX('36','60') = 5.114000e+002;
econuse.FX('36','61') = 1.782600e+003;
econuse.FX('36','62') = 9.019900e+003;
econuse.FX('36','63') = 7.285300e+003;
econuse.FX('36','64') = 1.753800e+003;
econuse.FX('36','65') = 1.183900e+003;
econuse.FX('36','66') = 3.136000e+002;
econuse.FX('36','67') = 8.387000e+002;
econuse.FX('36','68') = 4.908000e+002;
econuse.FX('36','69') = 1.553530e+004;
econuse.FX('36','70') = 1.389090e+004;
econuse.FX('36','71') = 5.148200e+003;
econuse.FX('36','72') = 2.985000e+002;
econuse.FX('36','73') = 2.019940e+004;
econuse.FX('36','74') = 3.811600e+003;
econuse.FX('37','1') = 2.840000e+001;
econuse.FX('37','2') = 7.170000e+001;
econuse.FX('37','3') = 8.300000e+000;
econuse.FX('37','4') = 4.620000e+001;
econuse.FX('37','5') = 1.470000e+001;
econuse.FX('37','6') = 1.420000e+001;
econuse.FX('37','7') = 5.400000e+000;
econuse.FX('37','8') = 2.220000e+001;
econuse.FX('37','9') = 5.460000e+001;
econuse.FX('37','10') = 2.302000e+002;
econuse.FX('37','11') = 7.490000e+001;
econuse.FX('37','12') = 3.800000e+000;
econuse.FX('37','13') = 1.099600e+003;
econuse.FX('37','14') = 8.463000e+002;
econuse.FX('37','15') = 1.345000e+002;
econuse.FX('37','16') = 5.660000e+001;
econuse.FX('37','17') = 1.753000e+002;
econuse.FX('37','18') = 2.243000e+002;
econuse.FX('37','19') = 3.851000e+002;
econuse.FX('37','20') = 1.404000e+002;
econuse.FX('37','21') = 1.215000e+002;
econuse.FX('37','22') = 4.200000e+000;
econuse.FX('37','23') = 1.060000e+001;
econuse.FX('37','24') = 4.684000e+002;
econuse.FX('37','25') = 4.108000e+002;
econuse.FX('37','26') = 164;
econuse.FX('37','27') = 2.833000e+002;
econuse.FX('37','28') = 5.174000e+002;
econuse.FX('37','29') = 3.679000e+002;
econuse.FX('37','30') = 6.930000e+001;
econuse.FX('37','31') = 4.988000e+002;
econuse.FX('37','32') = 7.012000e+002;
econuse.FX('37','33') = 7.330000e+001;
econuse.FX('37','34') = 1.895000e+002;
econuse.FX('37','35') = 2.567000e+002;
econuse.FX('37','36') = 1.660300e+003;
econuse.FX('37','37') = 7.800000e+000;
econuse.FX('37','38') = 1.890000e+001;
econuse.FX('37','39') = 5.850000e+001;
econuse.FX('37','40') = 6.223000e+002;
econuse.FX('37','41') = 1.420000e+001;
econuse.FX('37','42') = 6.200000e+000;
econuse.FX('37','43') = 3.559000e+002;
econuse.FX('37','44') = 4.120000e+001;
econuse.FX('37','45') = 8.415000e+002;
econuse.FX('37','46') = 1.818000e+002;
econuse.FX('37','47') = 797;
econuse.FX('37','48') = 4.083000e+002;
econuse.FX('37','49') = 1.911600e+003;
econuse.FX('37','50') = 4.432000e+002;
econuse.FX('37','51') = 3.404000e+002;
econuse.FX('37','52') = 8.310000e+001;
econuse.FX('37','53') = 5.303000e+002;
econuse.FX('37','54') = 2.163700e+003;
econuse.FX('37','55') = 4.513000e+002;
econuse.FX('37','56') = 6.146000e+002;
econuse.FX('37','57') = 3.298700e+003;
econuse.FX('37','58') = 1.702000e+002;
econuse.FX('37','59') = 1.676600e+003;
econuse.FX('37','60') = 2.733000e+002;
econuse.FX('37','61') = 2.871000e+002;
econuse.FX('37','62') = 8.177000e+002;
econuse.FX('37','63') = 1.241000e+002;
econuse.FX('37','64') = 9.110000e+001;
econuse.FX('37','65') = 1.955000e+002;
econuse.FX('37','66') = 6.990000e+001;
econuse.FX('37','67') = 1.369000e+002;
econuse.FX('37','68') = 152;
econuse.FX('37','69') = 7.555000e+002;
econuse.FX('37','70') = 1.010100e+003;
econuse.FX('37','71') = 4.787400e+003;
econuse.FX('37','72') = 650;
econuse.FX('37','73') = 2.456900e+003;
econuse.FX('37','74') = 8.670000e+001;
econuse.FX('38','1') = 215;
econuse.FX('38','2') = 2.365000e+002;
econuse.FX('38','3') = 9.090000e+001;
econuse.FX('38','4') = 4.186000e+002;
econuse.FX('38','5') = 123;
econuse.FX('38','6') = 102;
econuse.FX('38','7') = 6.515000e+002;
econuse.FX('38','8') = 2.275000e+002;
econuse.FX('38','9') = 5.820000e+001;
econuse.FX('38','10') = 6.781200e+003;
econuse.FX('38','11') = 8.750000e+001;
econuse.FX('38','12') = 8.400000e+000;
econuse.FX('38','13') = 1.384300e+003;
econuse.FX('38','14') = 3.340500e+003;
econuse.FX('38','15') = 7.330000e+001;
econuse.FX('38','16') = 1.220000e+001;
econuse.FX('38','17') = 6.295000e+002;
econuse.FX('38','18') = 1.431500e+003;
econuse.FX('38','19') = 1.522000e+002;
econuse.FX('38','20') = 3.574000e+002;
econuse.FX('38','21') = 4.894000e+002;
econuse.FX('38','22') = 1.299000e+002;
econuse.FX('38','23') = 3.310000e+001;
econuse.FX('38','24') = 1.557300e+003;
econuse.FX('38','25') = 9.334000e+002;
econuse.FX('38','26') = 9.602000e+002;
econuse.FX('38','27') = 1.920200e+003;
econuse.FX('38','28') = 4.584000e+002;
econuse.FX('38','29') = 2.652000e+002;
econuse.FX('38','30') = 1.390000e+001;
econuse.FX('38','31') = 3.771000e+002;
econuse.FX('38','32') = 1.050300e+003;
econuse.FX('38','33') = 5.280000e+001;
econuse.FX('38','34') = 2.078000e+002;
econuse.FX('38','35') = 1.892000e+002;
econuse.FX('38','36') = 2.336000e+002;
econuse.FX('38','37') = 4.330000e+001;
econuse.FX('38','38') = 1.726000e+002;
econuse.FX('38','39') = 6.900000e+000;
econuse.FX('38','40') = 2.199700e+003;
econuse.FX('38','41') = 1.460000e+001;
econuse.FX('38','42') = 1.480000e+001;
econuse.FX('38','43') = 3.860000e+001;
econuse.FX('38','44') = 4.900000e+000;
econuse.FX('38','45') = 1.011000e+002;
econuse.FX('38','46') = 2.300000e+000;
econuse.FX('38','47') = 1.704000e+002;
econuse.FX('38','48') = 11;
econuse.FX('38','49') = 12;
econuse.FX('38','50') = 3.400000e+000;
econuse.FX('38','51') = 1.290000e+001;
econuse.FX('38','52') = 3.000000e-001;
econuse.FX('38','53') = 1.584000e+002;
econuse.FX('38','54') = 7.950000e+001;
econuse.FX('38','55') = 2.690000e+001;
econuse.FX('38','56') = 3.700000e+000;
econuse.FX('38','57') = 266;
econuse.FX('38','58') = 1.770000e+001;
econuse.FX('38','59') = 1.439000e+002;
econuse.FX('38','60') = 1.270000e+001;
econuse.FX('38','61') = 2.440000e+001;
econuse.FX('38','62') = 1.168000e+002;
econuse.FX('38','63') = 1.568000e+002;
econuse.FX('38','64') = 1.490000e+001;
econuse.FX('38','65') = 3.150000e+001;
econuse.FX('38','66') = 2.800000e+000;
econuse.FX('38','67') = 1.590000e+001;
econuse.FX('38','68') = 1.540000e+001;
econuse.FX('38','69') = 3.922000e+002;
econuse.FX('38','70') = 1.993000e+002;
econuse.FX('38','71') = 4.297000e+002;
econuse.FX('38','72') = 3.775000e+002;
econuse.FX('38','73') = 1.203800e+003;
econuse.FX('38','74') = 1.928000e+002;
econuse.FX('39','1') = 7.080000e+001;
econuse.FX('39','2') = 9.840000e+001;
econuse.FX('39','3') = 16;
econuse.FX('39','4') = 1.011000e+002;
econuse.FX('39','5') = 5.700000e+000;
econuse.FX('39','6') = 1.540000e+001;
econuse.FX('39','7') = 1.970000e+001;
econuse.FX('39','8') = 1.930000e+001;
econuse.FX('39','9') = 5.400000e+000;
econuse.FX('39','10') = 1.215000e+002;
econuse.FX('39','11') = 5.000000e-001;
econuse.FX('39','12') = 2.000000e-001;
econuse.FX('39','13') = 277;
econuse.FX('39','14') = 6.195000e+002;
econuse.FX('39','15') = 7.500000e+000;
econuse.FX('39','16') = 2.000000e-001;
econuse.FX('39','17') = 2.300000e+000;
econuse.FX('39','18') = 3.310000e+001;
econuse.FX('39','19') = 2.200000e+000;
econuse.FX('39','20') = 1.504000e+002;
econuse.FX('39','21') = 4.490000e+001;
econuse.FX('39','22') = 9.400000e+000;
econuse.FX('39','23') = 7.000000e-001;
econuse.FX('39','24') = 8.070000e+001;
econuse.FX('39','25') = 6.900000e+000;
econuse.FX('39','26') = 4.840000e+001;
econuse.FX('39','27') = 1.668000e+002;
econuse.FX('39','28') = 5.040000e+001;
econuse.FX('39','29') = 1.280000e+001;
econuse.FX('39','30') = 6.000000e-001;
econuse.FX('39','31') = 2.450000e+001;
econuse.FX('39','32') = 4.620000e+001;
econuse.FX('39','33') = 2;
econuse.FX('39','34') = 3.200000e+000;
econuse.FX('39','35') = 8.500000e+000;
econuse.FX('39','36') = 3.160000e+001;
econuse.FX('39','37') = 7.650000e+001;
econuse.FX('39','38') = 1.210000e+001;
econuse.FX('39','39') = 3.000000e-001;
econuse.FX('39','40') = 7.710000e+001;
econuse.FX('39','41') = 6.500000e+000;
econuse.FX('39','42') = 2.940000e+001;
econuse.FX('39','43') = 3.680000e+001;
econuse.FX('39','44') = 1.500000e+000;
econuse.FX('39','45') = 1.100000e+000;
econuse.FX('39','46') = 0;
econuse.FX('39','47') = 8.700000e+000;
econuse.FX('39','48') = 5.000000e-001;
econuse.FX('39','49') = 1.600000e+000;
econuse.FX('39','50') = 7.000000e-001;
econuse.FX('39','51') = 1.100000e+000;
econuse.FX('39','52') = 0;
econuse.FX('39','53') = 1.580000e+001;
econuse.FX('39','54') = 6.400000e+000;
econuse.FX('39','55') = 4.000000e-001;
econuse.FX('39','56') = 6.000000e-001;
econuse.FX('39','57') = 1319;
econuse.FX('39','58') = 1.840000e+001;
econuse.FX('39','59') = 5.910000e+001;
econuse.FX('39','60') = 2.900000e+000;
econuse.FX('39','61') = 1;
econuse.FX('39','62') = 6.300000e+000;
econuse.FX('39','63') = 1.510000e+001;
econuse.FX('39','64') = 2;
econuse.FX('39','65') = 1.500000e+000;
econuse.FX('39','66') = 2.000000e-001;
econuse.FX('39','67') = 1.500000e+000;
econuse.FX('39','68') = 2.400000e+000;
econuse.FX('39','69') = 2.490000e+001;
econuse.FX('39','70') = 6.900000e+000;
econuse.FX('39','71') = 1.323800e+003;
econuse.FX('39','72') = 1.167000e+002;
econuse.FX('39','73') = 4.581000e+002;
econuse.FX('39','74') = 5.680000e+001;
econuse.FX('40','1') = 5.345000e+002;
econuse.FX('40','2') = 1.190400e+003;
econuse.FX('40','3') = 3.019000e+002;
econuse.FX('40','4') = 1.816400e+003;
econuse.FX('40','5') = 6.959000e+002;
econuse.FX('40','6') = 1.555000e+002;
econuse.FX('40','7') = 4.381000e+002;
econuse.FX('40','8') = 1.152600e+003;
econuse.FX('40','9') = 1.918000e+002;
econuse.FX('40','10') = 1293;
econuse.FX('40','11') = 171;
econuse.FX('40','12') = 1.820000e+001;
econuse.FX('40','13') = 1.444140e+004;
econuse.FX('40','14') = 1.289650e+004;
econuse.FX('40','15') = 1.362400e+003;
econuse.FX('40','16') = 6.462000e+002;
econuse.FX('40','17') = 2.213400e+003;
econuse.FX('40','18') = 2.612500e+003;
econuse.FX('40','19') = 9.216000e+002;
econuse.FX('40','20') = 1.303400e+003;
econuse.FX('40','21') = 6.974000e+002;
econuse.FX('40','22') = 9.687000e+002;
econuse.FX('40','23') = 4.470000e+001;
econuse.FX('40','24') = 3.029600e+003;
econuse.FX('40','25') = 1487;
econuse.FX('40','26') = 3.753700e+003;
econuse.FX('40','27') = 2.959800e+003;
econuse.FX('40','28') = 2085;
econuse.FX('40','29') = 2.287200e+003;
econuse.FX('40','30') = 3.513000e+002;
econuse.FX('40','31') = 2.274700e+003;
econuse.FX('40','32') = 5.957800e+003;
econuse.FX('40','33') = 3.027000e+002;
econuse.FX('40','34') = 1.145900e+003;
econuse.FX('40','35') = 1.796700e+003;
econuse.FX('40','36') = 9.043800e+003;
econuse.FX('40','37') = 3.023000e+002;
econuse.FX('40','38') = 2.773000e+002;
econuse.FX('40','39') = 2.096000e+002;
econuse.FX('40','40') = 1.193650e+004;
econuse.FX('40','41') = 2.181000e+002;
econuse.FX('40','42') = 1.487000e+002;
econuse.FX('40','43') = 1.050800e+003;
econuse.FX('40','44') = 1.625000e+002;
econuse.FX('40','45') = 9.062000e+002;
econuse.FX('40','46') = 2.655000e+002;
econuse.FX('40','47') = 6.671000e+002;
econuse.FX('40','48') = 1.915000e+002;
econuse.FX('40','49') = 9.640000e+001;
econuse.FX('40','50') = 1.504000e+002;
econuse.FX('40','51') = 1.388000e+002;
econuse.FX('40','52') = 5.100000e+000;
econuse.FX('40','53') = 1.197200e+003;
econuse.FX('40','54') = 7.236000e+002;
econuse.FX('40','55') = 159;
econuse.FX('40','56') = 9.020000e+001;
econuse.FX('40','57') = 1.592600e+003;
econuse.FX('40','58') = 1.418800e+003;
econuse.FX('40','59') = 7.404000e+002;
econuse.FX('40','60') = 2.786000e+002;
econuse.FX('40','61') = 4.193000e+002;
econuse.FX('40','62') = 1.560500e+003;
econuse.FX('40','63') = 1.322400e+003;
econuse.FX('40','64') = 3.257000e+002;
econuse.FX('40','65') = 3.434000e+002;
econuse.FX('40','66') = 3.263000e+002;
econuse.FX('40','67') = 5.056000e+002;
econuse.FX('40','68') = 1.999000e+002;
econuse.FX('40','69') = 2.685300e+003;
econuse.FX('40','70') = 3.568900e+003;
econuse.FX('40','71') = 3.015100e+003;
econuse.FX('40','72') = 5.308000e+002;
econuse.FX('40','73') = 5.135600e+003;
econuse.FX('40','74') = 1.516800e+003;
econuse.FX('41','1') = 0;
econuse.FX('41','2') = 0;
econuse.FX('41','3') = 0;
econuse.FX('41','4') = 0;
econuse.FX('41','5') = 4.500000e+000;
econuse.FX('41','6') = 8.000000e-001;
econuse.FX('41','7') = 1.100000e+000;
econuse.FX('41','8') = 5;
econuse.FX('41','9') = 1.890000e+001;
econuse.FX('41','10') = 8.710000e+001;
econuse.FX('41','11') = 52;
econuse.FX('41','12') = 1.200000e+000;
econuse.FX('41','13') = 3.109000e+002;
econuse.FX('41','14') = 1.642000e+002;
econuse.FX('41','15') = 2.210000e+001;
econuse.FX('41','16') = 1.040000e+001;
econuse.FX('41','17') = 6.120000e+001;
econuse.FX('41','18') = 5.810000e+001;
econuse.FX('41','19') = 1.274000e+002;
econuse.FX('41','20') = 4.730000e+001;
econuse.FX('41','21') = 2.040000e+001;
econuse.FX('41','22') = 1.900000e+000;
econuse.FX('41','23') = 1.300000e+000;
econuse.FX('41','24') = 6.370000e+001;
econuse.FX('41','25') = 1.187000e+002;
econuse.FX('41','26') = 5.380000e+001;
econuse.FX('41','27') = 6.740000e+001;
econuse.FX('41','28') = 1.629000e+002;
econuse.FX('41','29') = 1.162000e+002;
econuse.FX('41','30') = 2;
econuse.FX('41','31') = 1.191000e+002;
econuse.FX('41','32') = 1.098000e+002;
econuse.FX('41','33') = 2.140000e+001;
econuse.FX('41','34') = 6.460000e+001;
econuse.FX('41','35') = 1.065000e+002;
econuse.FX('41','36') = 2.821000e+002;
econuse.FX('41','37') = 2.000000e-001;
econuse.FX('41','38') = 3.463000e+002;
econuse.FX('41','39') = 1.000000e-001;
econuse.FX('41','40') = 1.500000e+000;
econuse.FX('41','41') = 0;
econuse.FX('41','42') = 1.800000e+000;
econuse.FX('41','43') = 4.100000e+000;
econuse.FX('41','44') = 6.000000e-001;
econuse.FX('41','45') = 3.026000e+002;
econuse.FX('41','46') = 59;
econuse.FX('41','47') = 409;
econuse.FX('41','48') = 2.021000e+002;
econuse.FX('41','49') = 1.096300e+003;
econuse.FX('41','50') = 2.037000e+002;
econuse.FX('41','51') = 2.251000e+002;
econuse.FX('41','52') = 2.990000e+001;
econuse.FX('41','53') = 440;
econuse.FX('41','54') = 1.157400e+003;
econuse.FX('41','55') = 2.814000e+002;
econuse.FX('41','56') = 3.417000e+002;
econuse.FX('41','57') = 1.878300e+003;
econuse.FX('41','58') = 4.910000e+001;
econuse.FX('41','59') = 8.551000e+002;
econuse.FX('41','60') = 100;
econuse.FX('41','61') = 1.833000e+002;
econuse.FX('41','62') = 4.998000e+002;
econuse.FX('41','63') = 165;
econuse.FX('41','64') = 1.625000e+002;
econuse.FX('41','65') = 6.220000e+001;
econuse.FX('41','66') = 6.382000e+002;
econuse.FX('41','67') = 1.217000e+002;
econuse.FX('41','68') = 9.460000e+001;
econuse.FX('41','69') = 3.164000e+002;
econuse.FX('41','70') = 3.983000e+002;
econuse.FX('41','71') = 31;
econuse.FX('41','72') = 1.040000e+001;
econuse.FX('41','73') = 6.994700e+003;
econuse.FX('41','74') = 653;
econuse.FX('42','1') = 3.200000e+000;
econuse.FX('42','2') = 4.200000e+000;
econuse.FX('42','3') = 0;
econuse.FX('42','4') = 7.000000e-001;
econuse.FX('42','5') = 4.400000e+000;
econuse.FX('42','6') = 3.303000e+002;
econuse.FX('42','7') = 5.300000e+000;
econuse.FX('42','8') = 7.700000e+000;
econuse.FX('42','9') = 9.100000e+000;
econuse.FX('42','10') = 3.824400e+003;
econuse.FX('42','11') = 9410;
econuse.FX('42','12') = 9.000000e-001;
econuse.FX('42','13') = 1.683000e+002;
econuse.FX('42','14') = 1.430000e+001;
econuse.FX('42','15') = 7.440000e+001;
econuse.FX('42','16') = 0;
econuse.FX('42','17') = 3;
econuse.FX('42','18') = 9.400000e+000;
econuse.FX('42','19') = 0;
econuse.FX('42','20') = 3.896600e+003;
econuse.FX('42','21') = 4.710000e+001;
econuse.FX('42','22') = 1.900000e+000;
econuse.FX('42','23') = 1.600000e+000;
econuse.FX('42','24') = 2.205000e+002;
econuse.FX('42','25') = 33;
econuse.FX('42','26') = 0;
econuse.FX('42','27') = 5.200000e+000;
econuse.FX('42','28') = 6.500000e+000;
econuse.FX('42','29') = 9.500000e+000;
econuse.FX('42','30') = 2.500000e+000;
econuse.FX('42','31') = 10;
econuse.FX('42','32') = 1.400000e+000;
econuse.FX('42','33') = 0;
econuse.FX('42','34') = 0;
econuse.FX('42','35') = 6.000000e-001;
econuse.FX('42','36') = 6.710000e+001;
econuse.FX('42','37') = 2.075000e+002;
econuse.FX('42','38') = 4.080000e+001;
econuse.FX('42','39') = 0;
econuse.FX('42','40') = 2.725000e+002;
econuse.FX('42','41') = 2.400000e+000;
econuse.FX('42','42') = 3.680000e+001;
econuse.FX('42','43') = 6.990000e+001;
econuse.FX('42','44') = 3.800000e+000;
econuse.FX('42','45') = 5.000000e-001;
econuse.FX('42','46') = 0;
econuse.FX('42','47') = 8.000000e-001;
econuse.FX('42','48') = 3.000000e-001;
econuse.FX('42','49') = 2.800000e+000;
econuse.FX('42','50') = 1;
econuse.FX('42','51') = 0;
econuse.FX('42','52') = 0;
econuse.FX('42','53') = 2.300000e+000;
econuse.FX('42','54') = 1.300000e+000;
econuse.FX('42','55') = 0;
econuse.FX('42','56') = 0;
econuse.FX('42','57') = 2.100000e+000;
econuse.FX('42','58') = 3.000000e-001;
econuse.FX('42','59') = 1.190000e+001;
econuse.FX('42','60') = 8.500000e+000;
econuse.FX('42','61') = 7.000000e-001;
econuse.FX('42','62') = 1.180000e+001;
econuse.FX('42','63') = 9.500000e+000;
econuse.FX('42','64') = 6.000000e-001;
econuse.FX('42','65') = 1.100000e+000;
econuse.FX('42','66') = 0;
econuse.FX('42','67') = 1.100000e+000;
econuse.FX('42','68') = 1.700000e+000;
econuse.FX('42','69') = 7.300000e+000;
econuse.FX('42','70') = 1.280000e+001;
econuse.FX('42','71') = 9.720000e+001;
econuse.FX('42','72') = 3.300000e+000;
econuse.FX('42','73') = 4.784000e+002;
econuse.FX('42','74') = 9.124000e+002;
econuse.FX('43','1') = 0;
econuse.FX('43','2') = 0;
econuse.FX('43','3') = 0;
econuse.FX('43','4') = 0;
econuse.FX('43','5') = 6.620000e+001;
econuse.FX('43','6') = 4;
econuse.FX('43','7') = 7.700000e+000;
econuse.FX('43','8') = 172;
econuse.FX('43','9') = 1.100000e+000;
econuse.FX('43','10') = 2.841000e+002;
econuse.FX('43','11') = 5.070000e+001;
econuse.FX('43','12') = 0;
econuse.FX('43','13') = 2.085000e+002;
econuse.FX('43','14') = 2.625000e+002;
econuse.FX('43','15') = 3.860000e+001;
econuse.FX('43','16') = 0;
econuse.FX('43','17') = 354;
econuse.FX('43','18') = 2.193000e+002;
econuse.FX('43','19') = 3.583000e+002;
econuse.FX('43','20') = 326;
econuse.FX('43','21') = 5.000000e-001;
econuse.FX('43','22') = 6.300000e+000;
econuse.FX('43','23') = 0;
econuse.FX('43','24') = 5.390000e+001;
econuse.FX('43','25') = 1.309000e+002;
econuse.FX('43','26') = 3.084000e+002;
econuse.FX('43','27') = 5.390000e+001;
econuse.FX('43','28') = 1.520000e+001;
econuse.FX('43','29') = 4.200000e+000;
econuse.FX('43','30') = 0;
econuse.FX('43','31') = 2.700000e+000;
econuse.FX('43','32') = 6.300000e+000;
econuse.FX('43','33') = 0;
econuse.FX('43','34') = 1.673000e+002;
econuse.FX('43','35') = 9.710000e+001;
econuse.FX('43','36') = 2.390980e+004;
econuse.FX('43','37') = 1.038790e+004;
econuse.FX('43','38') = 4.958000e+002;
econuse.FX('43','39') = 4.412600e+003;
econuse.FX('43','40') = 1.607170e+004;
econuse.FX('43','41') = 2.272000e+002;
econuse.FX('43','42') = 1.607000e+002;
econuse.FX('43','43') = 10806;
econuse.FX('43','44') = 9.222000e+002;
econuse.FX('43','45') = 3.734500e+003;
econuse.FX('43','46') = 4.657000e+002;
econuse.FX('43','47') = 1.151000e+002;
econuse.FX('43','48') = 8.931000e+002;
econuse.FX('43','49') = 3.506000e+002;
econuse.FX('43','50') = 1.213700e+003;
econuse.FX('43','51') = 6.323000e+002;
econuse.FX('43','52') = 0;
econuse.FX('43','53') = 0;
econuse.FX('43','54') = 2.733900e+003;
econuse.FX('43','55') = 6.151000e+002;
econuse.FX('43','56') = 3.097000e+002;
econuse.FX('43','57') = 4.389600e+003;
econuse.FX('43','58') = 1.530000e+001;
econuse.FX('43','59') = 1.988400e+003;
econuse.FX('43','60') = 6.132000e+002;
econuse.FX('43','61') = 5.038000e+002;
econuse.FX('43','62') = 1.124500e+003;
econuse.FX('43','63') = 4.705000e+002;
econuse.FX('43','64') = 1.175000e+002;
econuse.FX('43','65') = 4.054000e+002;
econuse.FX('43','66') = 355;
econuse.FX('43','67') = 2.442000e+002;
econuse.FX('43','68') = 1.949000e+002;
econuse.FX('43','69') = 4.534000e+002;
econuse.FX('43','70') = 3.894700e+003;
econuse.FX('43','71') = 5.440000e+001;
econuse.FX('43','72') = 1.876000e+002;
econuse.FX('43','73') = 1.735400e+003;
econuse.FX('43','74') = 6.635000e+002;
econuse.FX('44','1') = 5.720000e+001;
econuse.FX('44','2') = 4.913000e+002;
econuse.FX('44','3') = 1.270000e+001;
econuse.FX('44','4') = 1.439000e+002;
econuse.FX('44','5') = 0;
econuse.FX('44','6') = 0;
econuse.FX('44','7') = 0;
econuse.FX('44','8') = 0;
econuse.FX('44','9') = 0;
econuse.FX('44','10') = 0;
econuse.FX('44','11') = 0;
econuse.FX('44','12') = 0;
econuse.FX('44','13') = 0;
econuse.FX('44','14') = 7.541000e+002;
econuse.FX('44','15') = 1.489000e+002;
econuse.FX('44','16') = 1.156000e+002;
econuse.FX('44','17') = 1.858000e+002;
econuse.FX('44','18') = 2.637000e+002;
econuse.FX('44','19') = 3.462000e+002;
econuse.FX('44','20') = 7.170000e+001;
econuse.FX('44','21') = 6.440000e+001;
econuse.FX('44','22') = 1.130000e+001;
econuse.FX('44','23') = 6.900000e+000;
econuse.FX('44','24') = 4.681000e+002;
econuse.FX('44','25') = 4.054000e+002;
econuse.FX('44','26') = 2.164000e+002;
econuse.FX('44','27') = 2.933000e+002;
econuse.FX('44','28') = 6.367000e+002;
econuse.FX('44','29') = 6.146000e+002;
econuse.FX('44','30') = 1.304000e+002;
econuse.FX('44','31') = 1.077600e+003;
econuse.FX('44','32') = 8.726000e+002;
econuse.FX('44','33') = 9.060000e+001;
econuse.FX('44','34') = 2.154000e+002;
econuse.FX('44','35') = 3.388000e+002;
econuse.FX('44','36') = 1.811010e+004;
econuse.FX('44','37') = 19;
econuse.FX('44','38') = 0;
econuse.FX('44','39') = 2.087000e+002;
econuse.FX('44','40') = 2.262100e+003;
econuse.FX('44','41') = 7.140000e+001;
econuse.FX('44','42') = 9.100000e+000;
econuse.FX('44','43') = 1.296400e+003;
econuse.FX('44','44') = 2.324900e+003;
econuse.FX('44','45') = 7.896000e+002;
econuse.FX('44','46') = 122;
econuse.FX('44','47') = 2.561000e+002;
econuse.FX('44','48') = 2.283000e+002;
econuse.FX('44','49') = 0;
econuse.FX('44','50') = 1.614000e+002;
econuse.FX('44','51') = 7.220000e+001;
econuse.FX('44','52') = 0;
econuse.FX('44','53') = 9.420000e+001;
econuse.FX('44','54') = 4.265000e+002;
econuse.FX('44','55') = 9.980000e+001;
econuse.FX('44','56') = 55;
econuse.FX('44','57') = 6.423000e+002;
econuse.FX('44','58') = 3.800000e+000;
econuse.FX('44','59') = 5.275000e+002;
econuse.FX('44','60') = 7.580000e+001;
econuse.FX('44','61') = 3.920000e+001;
econuse.FX('44','62') = 253;
econuse.FX('44','63') = 4.372000e+002;
econuse.FX('44','64') = 8.430000e+001;
econuse.FX('44','65') = 7.920000e+001;
econuse.FX('44','66') = 1.014000e+002;
econuse.FX('44','67') = 1.044000e+002;
econuse.FX('44','68') = 1.133000e+002;
econuse.FX('44','69') = 3.623000e+002;
econuse.FX('44','70') = 1.241600e+003;
econuse.FX('44','71') = 5.715000e+002;
econuse.FX('44','72') = 0;
econuse.FX('44','73') = 2697;
econuse.FX('44','74') = 6.630000e+001;
econuse.FX('45','1') = 6.400000e+000;
econuse.FX('45','2') = 2.040000e+001;
econuse.FX('45','3') = 8.500000e+000;
econuse.FX('45','4') = 7.400000e+000;
econuse.FX('45','5') = 0;
econuse.FX('45','6') = 2.300000e+000;
econuse.FX('45','7') = 1.500000e+000;
econuse.FX('45','8') = 0;
econuse.FX('45','9') = 0;
econuse.FX('45','10') = 5.100000e+000;
econuse.FX('45','11') = 3.800000e+000;
econuse.FX('45','12') = 1.300000e+000;
econuse.FX('45','13') = 3.000000e-001;
econuse.FX('45','14') = 7.400000e+000;
econuse.FX('45','15') = 2.800000e+000;
econuse.FX('45','16') = 0;
econuse.FX('45','17') = 0;
econuse.FX('45','18') = 0;
econuse.FX('45','19') = 3.860000e+001;
econuse.FX('45','20') = 0;
econuse.FX('45','21') = 0;
econuse.FX('45','22') = 0;
econuse.FX('45','23') = 0;
econuse.FX('45','24') = 9.700000e+000;
econuse.FX('45','25') = 8.700000e+000;
econuse.FX('45','26') = 6.600000e+000;
econuse.FX('45','27') = 8.200000e+000;
econuse.FX('45','28') = 2.640000e+001;
econuse.FX('45','29') = 1.550000e+001;
econuse.FX('45','30') = 4.972300e+003;
econuse.FX('45','31') = 7.748800e+003;
econuse.FX('45','32') = 5.478000e+002;
econuse.FX('45','33') = 451;
econuse.FX('45','34') = 3.100000e+000;
econuse.FX('45','35') = 43;
econuse.FX('45','36') = 7.814000e+002;
econuse.FX('45','37') = 3.200000e+000;
econuse.FX('45','38') = 4.300000e+000;
econuse.FX('45','39') = 8.000000e-001;
econuse.FX('45','40') = 2.090000e+001;
econuse.FX('45','41') = 1.000000e-001;
econuse.FX('45','42') = 4.000000e-001;
econuse.FX('45','43') = 9.280000e+001;
econuse.FX('45','44') = 24;
econuse.FX('45','45') = 1.692400e+003;
econuse.FX('45','46') = 19;
econuse.FX('45','47') = 2.752000e+002;
econuse.FX('45','48') = 3.784000e+002;
econuse.FX('45','49') = 4.438000e+002;
econuse.FX('45','50') = 1.217000e+002;
econuse.FX('45','51') = 1.524000e+002;
econuse.FX('45','52') = 1.510000e+001;
econuse.FX('45','53') = 3.650000e+001;
econuse.FX('45','54') = 1.853600e+003;
econuse.FX('45','55') = 1.351400e+003;
econuse.FX('45','56') = 7.940000e+001;
econuse.FX('45','57') = 1.972800e+003;
econuse.FX('45','58') = 4.287000e+002;
econuse.FX('45','59') = 7.451000e+002;
econuse.FX('45','60') = 4.140000e+001;
econuse.FX('45','61') = 5.125000e+002;
econuse.FX('45','62') = 5.256000e+002;
econuse.FX('45','63') = 82;
econuse.FX('45','64') = 4.270000e+001;
econuse.FX('45','65') = 1.031100e+003;
econuse.FX('45','66') = 19;
econuse.FX('45','67') = 6.020000e+001;
econuse.FX('45','68') = 1.364000e+002;
econuse.FX('45','69') = 2.277000e+002;
econuse.FX('45','70') = 2.007600e+003;
econuse.FX('45','71') = 3.506000e+002;
econuse.FX('45','72') = 3.971000e+002;
econuse.FX('45','73') = 5.846100e+003;
econuse.FX('45','74') = 121;
econuse.FX('46','1') = 0;
econuse.FX('46','2') = 0;
econuse.FX('46','3') = 0;
econuse.FX('46','4') = 0;
econuse.FX('46','5') = 0;
econuse.FX('46','6') = 0;
econuse.FX('46','7') = 0;
econuse.FX('46','8') = 0;
econuse.FX('46','9') = 0;
econuse.FX('46','10') = 0;
econuse.FX('46','11') = 0;
econuse.FX('46','12') = 0;
econuse.FX('46','13') = 0;
econuse.FX('46','14') = 0;
econuse.FX('46','15') = 0;
econuse.FX('46','16') = 0;
econuse.FX('46','17') = 0;
econuse.FX('46','18') = 0;
econuse.FX('46','19') = 0;
econuse.FX('46','20') = 0;
econuse.FX('46','21') = 0;
econuse.FX('46','22') = 0;
econuse.FX('46','23') = 0;
econuse.FX('46','24') = 0;
econuse.FX('46','25') = 0;
econuse.FX('46','26') = 0;
econuse.FX('46','27') = 0;
econuse.FX('46','28') = 0;
econuse.FX('46','29') = 0;
econuse.FX('46','30') = 0;
econuse.FX('46','31') = 0;
econuse.FX('46','32') = 0;
econuse.FX('46','33') = 0;
econuse.FX('46','34') = 0;
econuse.FX('46','35') = 0;
econuse.FX('46','36') = 3.077000e+002;
econuse.FX('46','37') = 16;
econuse.FX('46','38') = 2.500000e+000;
econuse.FX('46','39') = 6.100000e+000;
econuse.FX('46','40') = 1;
econuse.FX('46','41') = 0;
econuse.FX('46','42') = 0;
econuse.FX('46','43') = 1.930000e+001;
econuse.FX('46','44') = 7.000000e-001;
econuse.FX('46','45') = 3.770000e+001;
econuse.FX('46','46') = 1.078610e+004;
econuse.FX('46','47') = 2.064290e+004;
econuse.FX('46','48') = 4.208000e+002;
econuse.FX('46','49') = 2.290000e+001;
econuse.FX('46','50') = 5.200000e+000;
econuse.FX('46','51') = 1;
econuse.FX('46','52') = 0;
econuse.FX('46','53') = 3.080000e+001;
econuse.FX('46','54') = 7.360000e+001;
econuse.FX('46','55') = 1.590000e+001;
econuse.FX('46','56') = 3.820000e+001;
econuse.FX('46','57') = 2.643900e+003;
econuse.FX('46','58') = 9.560000e+001;
econuse.FX('46','59') = 9.950000e+001;
econuse.FX('46','60') = 0;
econuse.FX('46','61') = 5.567000e+002;
econuse.FX('46','62') = 5.260000e+001;
econuse.FX('46','63') = 4.600000e+000;
econuse.FX('46','64') = 2.821000e+002;
econuse.FX('46','65') = 9.223000e+002;
econuse.FX('46','66') = 213;
econuse.FX('46','67') = 5.190000e+001;
econuse.FX('46','68') = 1.282000e+002;
econuse.FX('46','69') = 6.434000e+002;
econuse.FX('46','70') = 6.738000e+002;
econuse.FX('46','71') = 1.436100e+003;
econuse.FX('46','72') = 2.370000e+001;
econuse.FX('46','73') = 452;
econuse.FX('46','74') = 0;
econuse.FX('47','1') = 3.310000e+001;
econuse.FX('47','2') = 1.248000e+002;
econuse.FX('47','3') = 3.420000e+001;
econuse.FX('47','4') = 4.720000e+001;
econuse.FX('47','5') = 4.330000e+001;
econuse.FX('47','6') = 2.326000e+002;
econuse.FX('47','7') = 3.040000e+001;
econuse.FX('47','8') = 105;
econuse.FX('47','9') = 1.233000e+002;
econuse.FX('47','10') = 1.633000e+002;
econuse.FX('47','11') = 7.930000e+001;
econuse.FX('47','12') = 6.420000e+001;
econuse.FX('47','13') = 7.555100e+003;
econuse.FX('47','14') = 7.932000e+002;
econuse.FX('47','15') = 1.709000e+002;
econuse.FX('47','16') = 1.324000e+002;
econuse.FX('47','17') = 2.707000e+002;
econuse.FX('47','18') = 2.759000e+002;
econuse.FX('47','19') = 4.993000e+002;
econuse.FX('47','20') = 195;
econuse.FX('47','21') = 1.079000e+002;
econuse.FX('47','22') = 1.480000e+001;
econuse.FX('47','23') = 5.200000e+000;
econuse.FX('47','24') = 5.059000e+002;
econuse.FX('47','25') = 5.928000e+002;
econuse.FX('47','26') = 2.997000e+002;
econuse.FX('47','27') = 2.912000e+002;
econuse.FX('47','28') = 9.747000e+002;
econuse.FX('47','29') = 8.048000e+002;
econuse.FX('47','30') = 1.414000e+002;
econuse.FX('47','31') = 9.461000e+002;
econuse.FX('47','32') = 5.161000e+002;
econuse.FX('47','33') = 9.440000e+001;
econuse.FX('47','34') = 4.379000e+002;
econuse.FX('47','35') = 5.479000e+002;
econuse.FX('47','36') = 1.146810e+004;
econuse.FX('47','37') = 1.324800e+003;
econuse.FX('47','38') = 6.880000e+001;
econuse.FX('47','39') = 1.485000e+002;
econuse.FX('47','40') = 1.927700e+003;
econuse.FX('47','41') = 2.628000e+002;
econuse.FX('47','42') = 1.706000e+002;
econuse.FX('47','43') = 1.175300e+003;
econuse.FX('47','44') = 3.075000e+002;
econuse.FX('47','45') = 2232;
econuse.FX('47','46') = 5.959000e+002;
econuse.FX('47','47') = 8.209710e+004;
econuse.FX('47','48') = 2.542400e+003;
econuse.FX('47','49') = 3.377700e+003;
econuse.FX('47','50') = 6.827200e+003;
econuse.FX('47','51') = 2.858700e+003;
econuse.FX('47','52') = 1.273000e+002;
econuse.FX('47','53') = 3.181100e+003;
econuse.FX('47','54') = 1.491910e+004;
econuse.FX('47','55') = 2.692600e+003;
econuse.FX('47','56') = 8.881300e+003;
econuse.FX('47','57') = 1.686590e+004;
econuse.FX('47','58') = 8.709700e+003;
econuse.FX('47','59') = 7377;
econuse.FX('47','60') = 313;
econuse.FX('47','61') = 1.440400e+003;
econuse.FX('47','62') = 5.211500e+003;
econuse.FX('47','63') = 1.842900e+003;
econuse.FX('47','64') = 8.829000e+002;
econuse.FX('47','65') = 1.199400e+003;
econuse.FX('47','66') = 457;
econuse.FX('47','67') = 5.022000e+002;
econuse.FX('47','68') = 1.109700e+003;
econuse.FX('47','69') = 3.240300e+003;
econuse.FX('47','70') = 5.656400e+003;
econuse.FX('47','71') = 7.364400e+003;
econuse.FX('47','72') = 3.015000e+002;
econuse.FX('47','73') = 2.491620e+004;
econuse.FX('47','74') = 407;
econuse.FX('48','1') = 5.700000e+000;
econuse.FX('48','2') = 2.690000e+001;
econuse.FX('48','3') = 8.000000e-001;
econuse.FX('48','4') = 5.400000e+000;
econuse.FX('48','5') = 1.930000e+001;
econuse.FX('48','6') = 4.050000e+001;
econuse.FX('48','7') = 7.500000e+000;
econuse.FX('48','8') = 1.750000e+001;
econuse.FX('48','9') = 1.580000e+001;
econuse.FX('48','10') = 6.661000e+002;
econuse.FX('48','11') = 5.520000e+001;
econuse.FX('48','12') = 3.900000e+000;
econuse.FX('48','13') = 1.502700e+003;
econuse.FX('48','14') = 9.071000e+002;
econuse.FX('48','15') = 165;
econuse.FX('48','16') = 105;
econuse.FX('48','17') = 3.325000e+002;
econuse.FX('48','18') = 3.578000e+002;
econuse.FX('48','19') = 3.354000e+002;
econuse.FX('48','20') = 1.014000e+002;
econuse.FX('48','21') = 5.940000e+001;
econuse.FX('48','22') = 1.270000e+001;
econuse.FX('48','23') = 4.400000e+000;
econuse.FX('48','24') = 4.525000e+002;
econuse.FX('48','25') = 4.632000e+002;
econuse.FX('48','26') = 3.045000e+002;
econuse.FX('48','27') = 368;
econuse.FX('48','28') = 8.071000e+002;
econuse.FX('48','29') = 8.458000e+002;
econuse.FX('48','30') = 1.252000e+002;
econuse.FX('48','31') = 1.193300e+003;
econuse.FX('48','32') = 665;
econuse.FX('48','33') = 1.474000e+002;
econuse.FX('48','34') = 4.196000e+002;
econuse.FX('48','35') = 4.258000e+002;
econuse.FX('48','36') = 5.181100e+003;
econuse.FX('48','37') = 1.343000e+002;
econuse.FX('48','38') = 1.160000e+001;
econuse.FX('48','39') = 2.350000e+001;
econuse.FX('48','40') = 1.546000e+002;
econuse.FX('48','41') = 8.270000e+001;
econuse.FX('48','42') = 1.127000e+002;
econuse.FX('48','43') = 1.092000e+002;
econuse.FX('48','44') = 6.710000e+001;
econuse.FX('48','45') = 2.581900e+003;
econuse.FX('48','46') = 1.236000e+002;
econuse.FX('48','47') = 3.166600e+003;
econuse.FX('48','48') = 1.608700e+003;
econuse.FX('48','49') = 2.445600e+003;
econuse.FX('48','50') = 4.695500e+003;
econuse.FX('48','51') = 1.177300e+003;
econuse.FX('48','52') = 2.238000e+002;
econuse.FX('48','53') = 4.144000e+002;
econuse.FX('48','54') = 4.130400e+003;
econuse.FX('48','55') = 9.563000e+002;
econuse.FX('48','56') = 1.419500e+003;
econuse.FX('48','57') = 5.179300e+003;
econuse.FX('48','58') = 5.075700e+003;
econuse.FX('48','59') = 4.362500e+003;
econuse.FX('48','60') = 3.682000e+002;
econuse.FX('48','61') = 1.812500e+003;
econuse.FX('48','62') = 6.813000e+002;
econuse.FX('48','63') = 9.996000e+002;
econuse.FX('48','64') = 180;
econuse.FX('48','65') = 1.401000e+002;
econuse.FX('48','66') = 2.244000e+002;
econuse.FX('48','67') = 2.533000e+002;
econuse.FX('48','68') = 286;
econuse.FX('48','69') = 1.539600e+003;
econuse.FX('48','70') = 2.297500e+003;
econuse.FX('48','71') = 6.254600e+003;
econuse.FX('48','72') = 6.270000e+001;
econuse.FX('48','73') = 9.790700e+003;
econuse.FX('48','74') = 1.889000e+002;
econuse.FX('49','1') = 2.112700e+003;
econuse.FX('49','2') = 4.302300e+003;
econuse.FX('49','3') = 455;
econuse.FX('49','4') = 2.233300e+003;
econuse.FX('49','5') = 4.866000e+002;
econuse.FX('49','6') = 749;
econuse.FX('49','7') = 1.988000e+002;
econuse.FX('49','8') = 4.163000e+002;
econuse.FX('49','9') = 4.343000e+002;
econuse.FX('49','10') = 3242;
econuse.FX('49','11') = 2377;
econuse.FX('49','12') = 1.899000e+002;
econuse.FX('49','13') = 1.050990e+004;
econuse.FX('49','14') = 2768;
econuse.FX('49','15') = 4.309000e+002;
econuse.FX('49','16') = 2.357000e+002;
econuse.FX('49','17') = 410;
econuse.FX('49','18') = 4.611000e+002;
econuse.FX('49','19') = 8.753000e+002;
econuse.FX('49','20') = 6.222000e+002;
econuse.FX('49','21') = 77;
econuse.FX('49','22') = 2.870000e+001;
econuse.FX('49','23') = 2.120000e+001;
econuse.FX('49','24') = 7.866000e+002;
econuse.FX('49','25') = 1.779500e+003;
econuse.FX('49','26') = 794;
econuse.FX('49','27') = 8.622000e+002;
econuse.FX('49','28') = 1.778400e+003;
econuse.FX('49','29') = 1.227100e+003;
econuse.FX('49','30') = 2.070000e+001;
econuse.FX('49','31') = 8.237000e+002;
econuse.FX('49','32') = 1.005800e+003;
econuse.FX('49','33') = 2.577000e+002;
econuse.FX('49','34') = 621;
econuse.FX('49','35') = 8.133000e+002;
econuse.FX('49','36') = 2.580710e+004;
econuse.FX('49','37') = 4.942000e+002;
econuse.FX('49','38') = 3289;
econuse.FX('49','39') = 55;
econuse.FX('49','40') = 1.876600e+003;
econuse.FX('49','41') = 3.334000e+002;
econuse.FX('49','42') = 4.582000e+002;
econuse.FX('49','43') = 6.052000e+002;
econuse.FX('49','44') = 2.654000e+002;
econuse.FX('49','45') = 4.250900e+003;
econuse.FX('49','46') = 6.653000e+002;
econuse.FX('49','47') = 6.122800e+003;
econuse.FX('49','48') = 700;
econuse.FX('49','49') = 6.915960e+004;
econuse.FX('49','50') = 1.223560e+004;
econuse.FX('49','51') = 8.920500e+003;
econuse.FX('49','52') = 1.526600e+003;
econuse.FX('49','53') = 1.268863e+005;
econuse.FX('49','54') = 1.222070e+004;
econuse.FX('49','55') = 2.612500e+003;
econuse.FX('49','56') = 2.702500e+003;
econuse.FX('49','57') = 1.524280e+004;
econuse.FX('49','58') = 7.900400e+003;
econuse.FX('49','59') = 5.305200e+003;
econuse.FX('49','60') = 4.386000e+002;
econuse.FX('49','61') = 1.079400e+003;
econuse.FX('49','62') = 5328;
econuse.FX('49','63') = 6.382000e+002;
econuse.FX('49','64') = 9.149000e+002;
econuse.FX('49','65') = 5.893000e+002;
econuse.FX('49','66') = 3.772000e+002;
econuse.FX('49','67') = 1.288200e+003;
econuse.FX('49','68') = 6.948000e+002;
econuse.FX('49','69') = 2946;
econuse.FX('49','70') = 2.041630e+004;
econuse.FX('49','71') = 9.333000e+002;
econuse.FX('49','72') = 2.229100e+003;
econuse.FX('49','73') = 6.356700e+003;
econuse.FX('49','74') = 7.881600e+003;
econuse.FX('50','1') = 4.340000e+001;
econuse.FX('50','2') = 1.425000e+002;
econuse.FX('50','3') = 6.800000e+000;
econuse.FX('50','4') = 2.258000e+002;
econuse.FX('50','5') = 1.338000e+002;
econuse.FX('50','6') = 2.354000e+002;
econuse.FX('50','7') = 411;
econuse.FX('50','8') = 4.901000e+002;
econuse.FX('50','9') = 7.155000e+002;
econuse.FX('50','10') = 4.052000e+002;
econuse.FX('50','11') = 2.143000e+002;
econuse.FX('50','12') = 1.480000e+001;
econuse.FX('50','13') = 3.693100e+003;
econuse.FX('50','14') = 5.427000e+002;
econuse.FX('50','15') = 8.740000e+001;
econuse.FX('50','16') = 5.420000e+001;
econuse.FX('50','17') = 8.880000e+001;
econuse.FX('50','18') = 1.046000e+002;
econuse.FX('50','19') = 2.397000e+002;
econuse.FX('50','20') = 1.738000e+002;
econuse.FX('50','21') = 1.910000e+001;
econuse.FX('50','22') = 7.300000e+000;
econuse.FX('50','23') = 3.300000e+000;
econuse.FX('50','24') = 1.484000e+002;
econuse.FX('50','25') = 3.347000e+002;
econuse.FX('50','26') = 1.679000e+002;
econuse.FX('50','27') = 1.222300e+003;
econuse.FX('50','28') = 2.272500e+003;
econuse.FX('50','29') = 1811;
econuse.FX('50','30') = 4.440000e+001;
econuse.FX('50','31') = 1.219700e+003;
econuse.FX('50','32') = 1.773500e+003;
econuse.FX('50','33') = 3.936000e+002;
econuse.FX('50','34') = 8.078000e+002;
econuse.FX('50','35') = 1.074700e+003;
econuse.FX('50','36') = 3.078800e+003;
econuse.FX('50','37') = 1.383000e+002;
econuse.FX('50','38') = 1.437300e+003;
econuse.FX('50','39') = 4.703000e+002;
econuse.FX('50','40') = 3.872000e+002;
econuse.FX('50','41') = 142;
econuse.FX('50','42') = 1.966000e+002;
econuse.FX('50','43') = 3.876000e+002;
econuse.FX('50','44') = 4.690000e+001;
econuse.FX('50','45') = 8.389000e+002;
econuse.FX('50','46') = 2.396000e+002;
econuse.FX('50','47') = 9.092000e+002;
econuse.FX('50','48') = 9.030000e+001;
econuse.FX('50','49') = 4.206850e+004;
econuse.FX('50','50') = 2.850510e+004;
econuse.FX('50','51') = 6.936700e+003;
econuse.FX('50','52') = 5.621970e+004;
econuse.FX('50','53') = 8.596000e+002;
econuse.FX('50','54') = 2.459500e+003;
econuse.FX('50','55') = 809;
econuse.FX('50','56') = 4.061000e+002;
econuse.FX('50','57') = 3.291900e+003;
econuse.FX('50','58') = 5.781700e+003;
econuse.FX('50','59') = 1.538800e+003;
econuse.FX('50','60') = 9.070000e+001;
econuse.FX('50','61') = 4.986000e+002;
econuse.FX('50','62') = 1.269800e+003;
econuse.FX('50','63') = 2747;
econuse.FX('50','64') = 2.674000e+002;
econuse.FX('50','65') = 3.815400e+003;
econuse.FX('50','66') = 4.313000e+002;
econuse.FX('50','67') = 1.755000e+002;
econuse.FX('50','68') = 2.569000e+002;
econuse.FX('50','69') = 5.138000e+002;
econuse.FX('50','70') = 18581;
econuse.FX('50','71') = 1.400000e+000;
econuse.FX('50','72') = 1.257000e+002;
econuse.FX('50','73') = 5464;
econuse.FX('50','74') = 1.684600e+003;
econuse.FX('51','1') = -1.721000e+002;
econuse.FX('51','2') = -5.887000e+002;
econuse.FX('51','3') = 21;
econuse.FX('51','4') = 5.260000e+001;
econuse.FX('51','5') = 8.720000e+001;
econuse.FX('51','6') = 6.740000e+001;
econuse.FX('51','7') = 1.830000e+001;
econuse.FX('51','8') = 6.870000e+001;
econuse.FX('51','9') = 1.790000e+001;
econuse.FX('51','10') = 4.730000e+001;
econuse.FX('51','11') = 1.140000e+001;
econuse.FX('51','12') = 0;
econuse.FX('51','13') = 6.800000e+000;
econuse.FX('51','14') = 2.910000e+001;
econuse.FX('51','15') = 3.800000e+000;
econuse.FX('51','16') = 2.100000e+000;
econuse.FX('51','17') = 0;
econuse.FX('51','18') = 0;
econuse.FX('51','19') = 9.810000e+001;
econuse.FX('51','20') = 2.900000e+000;
econuse.FX('51','21') = 1.500000e+000;
econuse.FX('51','22') = 1.200000e+000;
econuse.FX('51','23') = 1.000000e-001;
econuse.FX('51','24') = 6.300000e+000;
econuse.FX('51','25') = 1.750000e+001;
econuse.FX('51','26') = 6.600000e+000;
econuse.FX('51','27') = 8.300000e+000;
econuse.FX('51','28') = 1.350000e+001;
econuse.FX('51','29') = 1.142000e+002;
econuse.FX('51','30') = 1.000000e-001;
econuse.FX('51','31') = 3.940000e+001;
econuse.FX('51','32') = 7.600000e+000;
econuse.FX('51','33') = 4;
econuse.FX('51','34') = 1.030000e+001;
econuse.FX('51','35') = 1.040000e+001;
econuse.FX('51','36') = 18046;
econuse.FX('51','37') = 1.519100e+003;
econuse.FX('51','38') = 0;
econuse.FX('51','39') = 7.701000e+002;
econuse.FX('51','40') = 7.649100e+003;
econuse.FX('51','41') = 1.311600e+003;
econuse.FX('51','42') = 5.307000e+002;
econuse.FX('51','43') = 1.433300e+003;
econuse.FX('51','44') = 3.697000e+002;
econuse.FX('51','45') = 1.212900e+003;
econuse.FX('51','46') = 4.085000e+002;
econuse.FX('51','47') = 9.000000e-001;
econuse.FX('51','48') = 3.423000e+002;
econuse.FX('51','49') = 1.204710e+004;
econuse.FX('51','50') = 3.400800e+003;
econuse.FX('51','51') = 1.223709e+005;
econuse.FX('51','52') = 1430;
econuse.FX('51','53') = 2.991750e+004;
econuse.FX('51','54') = 9.215600e+003;
econuse.FX('51','55') = 2787;
econuse.FX('51','56') = 6.994000e+002;
econuse.FX('51','57') = 8.155200e+003;
econuse.FX('51','58') = 6.664000e+002;
econuse.FX('51','59') = 5.020200e+003;
econuse.FX('51','60') = 1.418800e+003;
econuse.FX('51','61') = 7.009000e+002;
econuse.FX('51','62') = 11331;
econuse.FX('51','63') = 6.319400e+003;
econuse.FX('51','64') = 2.802500e+003;
econuse.FX('51','65') = 1.414500e+003;
econuse.FX('51','66') = 1378;
econuse.FX('51','67') = 1.658900e+003;
econuse.FX('51','68') = 1507;
econuse.FX('51','69') = 5.092400e+003;
econuse.FX('51','70') = 6.233100e+003;
econuse.FX('51','71') = 1606;
econuse.FX('51','72') = 2;
econuse.FX('51','73') = 2.647000e+002;
econuse.FX('51','74') = 8.050000e+001;
econuse.FX('52','1') = 0;
econuse.FX('52','2') = 0;
econuse.FX('52','3') = 0;
econuse.FX('52','4') = 0;
econuse.FX('52','5') = 0;
econuse.FX('52','6') = 0;
econuse.FX('52','7') = 0;
econuse.FX('52','8') = 0;
econuse.FX('52','9') = 0;
econuse.FX('52','10') = 0;
econuse.FX('52','11') = 0;
econuse.FX('52','12') = 0;
econuse.FX('52','13') = 0;
econuse.FX('52','14') = 0;
econuse.FX('52','15') = 0;
econuse.FX('52','16') = 0;
econuse.FX('52','17') = 0;
econuse.FX('52','18') = 0;
econuse.FX('52','19') = 0;
econuse.FX('52','20') = 0;
econuse.FX('52','21') = 0;
econuse.FX('52','22') = 0;
econuse.FX('52','23') = 0;
econuse.FX('52','24') = 0;
econuse.FX('52','25') = 0;
econuse.FX('52','26') = 0;
econuse.FX('52','27') = 0;
econuse.FX('52','28') = 0;
econuse.FX('52','29') = 0;
econuse.FX('52','30') = 0;
econuse.FX('52','31') = 0;
econuse.FX('52','32') = 0;
econuse.FX('52','33') = 0;
econuse.FX('52','34') = 0;
econuse.FX('52','35') = 0;
econuse.FX('52','36') = 0;
econuse.FX('52','37') = 0;
econuse.FX('52','38') = 0;
econuse.FX('52','39') = 0;
econuse.FX('52','40') = 0;
econuse.FX('52','41') = 0;
econuse.FX('52','42') = 0;
econuse.FX('52','43') = 1.000000e-001;
econuse.FX('52','44') = 0;
econuse.FX('52','45') = 0;
econuse.FX('52','46') = 0;
econuse.FX('52','47') = 0;
econuse.FX('52','48') = 0;
econuse.FX('52','49') = 0;
econuse.FX('52','50') = 1.247500e+003;
econuse.FX('52','51') = 4.901500e+003;
econuse.FX('52','52') = 0;
econuse.FX('52','53') = 0;
econuse.FX('52','54') = 1.220000e+001;
econuse.FX('52','55') = 7.300000e+000;
econuse.FX('52','56') = 0;
econuse.FX('52','57') = 7.350000e+001;
econuse.FX('52','58') = 5.000000e-001;
econuse.FX('52','59') = 4.360000e+001;
econuse.FX('52','60') = 0;
econuse.FX('52','61') = 0;
econuse.FX('52','62') = 0;
econuse.FX('52','63') = 0;
econuse.FX('52','64') = 0;
econuse.FX('52','65') = 0;
econuse.FX('52','66') = 0;
econuse.FX('52','67') = 0;
econuse.FX('52','68') = 0;
econuse.FX('52','69') = 0;
econuse.FX('52','70') = 1.448500e+003;
econuse.FX('52','71') = 0;
econuse.FX('52','72') = 0;
econuse.FX('52','73') = 0;
econuse.FX('52','74') = 5.270000e+001;
econuse.FX('53','1') = 6.055500e+003;
econuse.FX('53','2') = 8.193800e+003;
econuse.FX('53','3') = 9.109000e+002;
econuse.FX('53','4') = 3.136700e+003;
econuse.FX('53','5') = 1.435000e+002;
econuse.FX('53','6') = 5.117000e+002;
econuse.FX('53','7') = 4.190000e+001;
econuse.FX('53','8') = 1.743000e+002;
econuse.FX('53','9') = 2.663000e+002;
econuse.FX('53','10') = 1.087400e+003;
econuse.FX('53','11') = 5.007000e+002;
econuse.FX('53','12') = 1.002000e+002;
econuse.FX('53','13') = 6.508900e+003;
econuse.FX('53','14') = 3.366400e+003;
econuse.FX('53','15') = 432;
econuse.FX('53','16') = 441;
econuse.FX('53','17') = 6.933000e+002;
econuse.FX('53','18') = 8.117000e+002;
econuse.FX('53','19') = 1.432400e+003;
econuse.FX('53','20') = 2.775000e+002;
econuse.FX('53','21') = 9.470000e+001;
econuse.FX('53','22') = 3.120000e+001;
econuse.FX('53','23') = 2.650000e+001;
econuse.FX('53','24') = 1.272700e+003;
econuse.FX('53','25') = 1.459900e+003;
econuse.FX('53','26') = 592;
econuse.FX('53','27') = 6.166000e+002;
econuse.FX('53','28') = 2.354900e+003;
econuse.FX('53','29') = 1.719700e+003;
econuse.FX('53','30') = 1.618000e+002;
econuse.FX('53','31') = 2.162100e+003;
econuse.FX('53','32') = 1.188700e+003;
econuse.FX('53','33') = 1.706000e+002;
econuse.FX('53','34') = 9.804000e+002;
econuse.FX('53','35') = 1.322300e+003;
econuse.FX('53','36') = 6.713080e+004;
econuse.FX('53','37') = 2.155700e+003;
econuse.FX('53','38') = 1.318000e+002;
econuse.FX('53','39') = 1.502800e+003;
econuse.FX('53','40') = 3.267100e+003;
econuse.FX('53','41') = 25;
econuse.FX('53','42') = 5.203000e+002;
econuse.FX('53','43') = 2.497300e+003;
econuse.FX('53','44') = 2.981200e+003;
econuse.FX('53','45') = 5.126500e+003;
econuse.FX('53','46') = 2.670200e+003;
econuse.FX('53','47') = 8.751700e+003;
econuse.FX('53','48') = 1.596400e+003;
econuse.FX('53','49') = 7318;
econuse.FX('53','50') = 1.118710e+004;
econuse.FX('53','51') = 7.039900e+003;
econuse.FX('53','52') = 1.744700e+003;
econuse.FX('53','53') = 8.696370e+004;
econuse.FX('53','54') = 3.556180e+004;
econuse.FX('53','55') = 1.111910e+004;
econuse.FX('53','56') = 1.255260e+004;
econuse.FX('53','57') = 3.285860e+004;
econuse.FX('53','58') = 1.046970e+004;
econuse.FX('53','59') = 9.209500e+003;
econuse.FX('53','60') = 6.173000e+002;
econuse.FX('53','61') = 1.551830e+004;
econuse.FX('53','62') = 2.048140e+004;
econuse.FX('53','63') = 4.093250e+004;
econuse.FX('53','64') = 7.485600e+003;
econuse.FX('53','65') = 8.301900e+003;
econuse.FX('53','66') = 2.911500e+003;
econuse.FX('53','67') = 3.648600e+003;
econuse.FX('53','68') = 1.963600e+003;
econuse.FX('53','69') = 2.296140e+004;
econuse.FX('53','70') = 2.695180e+004;
econuse.FX('53','71') = 4.190900e+003;
econuse.FX('53','72') = 9.299000e+002;
econuse.FX('53','73') = 1.683680e+004;
econuse.FX('53','74') = 6.515500e+003;
econuse.FX('54','1') = 1.816000e+002;
econuse.FX('54','2') = 7.864000e+002;
econuse.FX('54','3') = 1.349000e+002;
econuse.FX('54','4') = 3.535000e+002;
econuse.FX('54','5') = 1.187600e+003;
econuse.FX('54','6') = 1.780670e+004;
econuse.FX('54','7') = 8.181000e+002;
econuse.FX('54','8') = 2.011900e+003;
econuse.FX('54','9') = 2.191200e+003;
econuse.FX('54','10') = 3.564100e+003;
econuse.FX('54','11') = 1.379700e+003;
econuse.FX('54','12') = 7.058000e+002;
econuse.FX('54','13') = 6.830070e+004;
econuse.FX('54','14') = 6.898100e+003;
econuse.FX('54','15') = 9.267000e+002;
econuse.FX('54','16') = 2.167300e+003;
econuse.FX('54','17') = 1.296800e+003;
econuse.FX('54','18') = 2.025500e+003;
econuse.FX('54','19') = 3.043300e+003;
econuse.FX('54','20') = 1.816900e+003;
econuse.FX('54','21') = 1.411900e+003;
econuse.FX('54','22') = 2.443000e+002;
econuse.FX('54','23') = 7.830000e+001;
econuse.FX('54','24') = 6.183900e+003;
econuse.FX('54','25') = 2.713900e+003;
econuse.FX('54','26') = 1397;
econuse.FX('54','27') = 2804;
econuse.FX('54','28') = 6369;
econuse.FX('54','29') = 4.891200e+003;
econuse.FX('54','30') = 4.938000e+002;
econuse.FX('54','31') = 1.084370e+004;
econuse.FX('54','32') = 6.591500e+003;
econuse.FX('54','33') = 1.226300e+003;
econuse.FX('54','34') = 1160;
econuse.FX('54','35') = 3.292200e+003;
econuse.FX('54','36') = 2.907870e+004;
econuse.FX('54','37') = 8.527000e+002;
econuse.FX('54','38') = 1.704200e+003;
econuse.FX('54','39') = 2.187000e+002;
econuse.FX('54','40') = 2247;
econuse.FX('54','41') = 4.266000e+002;
econuse.FX('54','42') = 1.091500e+003;
econuse.FX('54','43') = 1.134900e+003;
econuse.FX('54','44') = 5.283000e+002;
econuse.FX('54','45') = 9.328100e+003;
econuse.FX('54','46') = 1.416700e+003;
econuse.FX('54','47') = 2.005930e+004;
econuse.FX('54','48') = 3.933200e+003;
econuse.FX('54','49') = 9.052100e+003;
econuse.FX('54','50') = 8.178400e+003;
econuse.FX('54','51') = 1.150220e+004;
econuse.FX('54','52') = 1.707600e+003;
econuse.FX('54','53') = 2.255730e+004;
econuse.FX('54','54') = 2.827790e+004;
econuse.FX('54','55') = 4.121800e+003;
econuse.FX('54','56') = 7.279300e+003;
econuse.FX('54','57') = 3.719450e+004;
econuse.FX('54','58') = 2.914540e+004;
econuse.FX('54','59') = 1.142520e+004;
econuse.FX('54','60') = 1.356600e+003;
econuse.FX('54','61') = 2.483700e+003;
econuse.FX('54','62') = 10126;
econuse.FX('54','63') = 3698;
econuse.FX('54','64') = 1.616100e+003;
econuse.FX('54','65') = 1.704500e+003;
econuse.FX('54','66') = 2.179500e+003;
econuse.FX('54','67') = 2.680500e+003;
econuse.FX('54','68') = 2528;
econuse.FX('54','69') = 1.044940e+004;
econuse.FX('54','70') = 8835;
econuse.FX('54','71') = 3.446140e+004;
econuse.FX('54','72') = 1.232800e+003;
econuse.FX('54','73') = 3.214410e+004;
econuse.FX('54','74') = 12122;
econuse.FX('55','1') = 8.090000e+001;
econuse.FX('55','2') = 2.699000e+002;
econuse.FX('55','3') = 4.520000e+001;
econuse.FX('55','4') = 2.108000e+002;
econuse.FX('55','5') = 2.578000e+002;
econuse.FX('55','6') = 6.075000e+002;
econuse.FX('55','7') = 1.894000e+002;
econuse.FX('55','8') = 411;
econuse.FX('55','9') = 2.122000e+002;
econuse.FX('55','10') = 2.537500e+003;
econuse.FX('55','11') = 5.776000e+002;
econuse.FX('55','12') = 1.138000e+002;
econuse.FX('55','13') = 9.303900e+003;
econuse.FX('55','14') = 1.170500e+003;
econuse.FX('55','15') = 2.105000e+002;
econuse.FX('55','16') = 3.837000e+002;
econuse.FX('55','17') = 2.709000e+002;
econuse.FX('55','18') = 3.158000e+002;
econuse.FX('55','19') = 5.416000e+002;
econuse.FX('55','20') = 372;
econuse.FX('55','21') = 1.335000e+002;
econuse.FX('55','22') = 2.110000e+001;
econuse.FX('55','23') = 5.400000e+000;
econuse.FX('55','24') = 9.757000e+002;
econuse.FX('55','25') = 5.848000e+002;
econuse.FX('55','26') = 2.979000e+002;
econuse.FX('55','27') = 5.863000e+002;
econuse.FX('55','28') = 1.107100e+003;
econuse.FX('55','29') = 1.101200e+003;
econuse.FX('55','30') = 1.506000e+002;
econuse.FX('55','31') = 1.725600e+003;
econuse.FX('55','32') = 1.133300e+003;
econuse.FX('55','33') = 169;
econuse.FX('55','34') = 2.355000e+002;
econuse.FX('55','35') = 7.387000e+002;
econuse.FX('55','36') = 6.548800e+003;
econuse.FX('55','37') = 4.931000e+002;
econuse.FX('55','38') = 5.318000e+002;
econuse.FX('55','39') = 92;
econuse.FX('55','40') = 5.504000e+002;
econuse.FX('55','41') = 2.119000e+002;
econuse.FX('55','42') = 2.648000e+002;
econuse.FX('55','43') = 5.352000e+002;
econuse.FX('55','44') = 1.649000e+002;
econuse.FX('55','45') = 2.271500e+003;
econuse.FX('55','46') = 7.023000e+002;
econuse.FX('55','47') = 2.075200e+003;
econuse.FX('55','48') = 6.421000e+002;
econuse.FX('55','49') = 4.073200e+003;
econuse.FX('55','50') = 3.570600e+003;
econuse.FX('55','51') = 6.017400e+003;
econuse.FX('55','52') = 1.002800e+003;
econuse.FX('55','53') = 12548;
econuse.FX('55','54') = 6.693200e+003;
econuse.FX('55','55') = 1.806300e+003;
econuse.FX('55','56') = 1528;
econuse.FX('55','57') = 7.809300e+003;
econuse.FX('55','58') = 1.072940e+004;
econuse.FX('55','59') = 3.716100e+003;
econuse.FX('55','60') = 296;
econuse.FX('55','61') = 5.815000e+002;
econuse.FX('55','62') = 4.512600e+003;
econuse.FX('55','63') = 1.743500e+003;
econuse.FX('55','64') = 583;
econuse.FX('55','65') = 4.677000e+002;
econuse.FX('55','66') = 8.301000e+002;
econuse.FX('55','67') = 1223;
econuse.FX('55','68') = 7.047000e+002;
econuse.FX('55','69') = 1.896500e+003;
econuse.FX('55','70') = 3.560200e+003;
econuse.FX('55','71') = 2.162800e+003;
econuse.FX('55','72') = 5.758000e+002;
econuse.FX('55','73') = 12000;
econuse.FX('55','74') = 5.168000e+002;
econuse.FX('56','1') = 1.180000e+001;
econuse.FX('56','2') = 5.370000e+001;
econuse.FX('56','3') = 1.900000e+000;
econuse.FX('56','4') = 12;
econuse.FX('56','5') = 33;
econuse.FX('56','6') = 1.079300e+003;
econuse.FX('56','7') = 1.220000e+001;
econuse.FX('56','8') = 2.009000e+002;
econuse.FX('56','9') = 1.450000e+001;
econuse.FX('56','10') = 8.010000e+001;
econuse.FX('56','11') = 5.920000e+001;
econuse.FX('56','12') = 4.800000e+000;
econuse.FX('56','13') = 6.391000e+002;
econuse.FX('56','14') = 2.212000e+002;
econuse.FX('56','15') = 3.710000e+001;
econuse.FX('56','16') = 2.230000e+001;
econuse.FX('56','17') = 52;
econuse.FX('56','18') = 7.610000e+001;
econuse.FX('56','19') = 2.116000e+002;
econuse.FX('56','20') = 2.111000e+002;
econuse.FX('56','21') = 2.680000e+001;
econuse.FX('56','22') = 2.300000e+000;
econuse.FX('56','23') = 9.000000e-001;
econuse.FX('56','24') = 2.248000e+002;
econuse.FX('56','25') = 128;
econuse.FX('56','26') = 4.990000e+001;
econuse.FX('56','27') = 6.350000e+001;
econuse.FX('56','28') = 4.257000e+002;
econuse.FX('56','29') = 616;
econuse.FX('56','30') = 55;
econuse.FX('56','31') = 1.806800e+003;
econuse.FX('56','32') = 6.288000e+002;
econuse.FX('56','33') = 3.740000e+001;
econuse.FX('56','34') = 9.550000e+001;
econuse.FX('56','35') = 9.610000e+001;
econuse.FX('56','36') = 1.309700e+003;
econuse.FX('56','37') = 3.540000e+001;
econuse.FX('56','38') = 3.303000e+002;
econuse.FX('56','39') = 1.130000e+001;
econuse.FX('56','40') = 1.324000e+002;
econuse.FX('56','41') = 3.130000e+001;
econuse.FX('56','42') = 1.980000e+001;
econuse.FX('56','43') = 6.610000e+001;
econuse.FX('56','44') = 5.270000e+001;
econuse.FX('56','45') = 1.256900e+003;
econuse.FX('56','46') = 7.580000e+001;
econuse.FX('56','47') = 8.752000e+002;
econuse.FX('56','48') = 4.688000e+002;
econuse.FX('56','49') = 3.626000e+002;
econuse.FX('56','50') = 1.658100e+003;
econuse.FX('56','51') = 2.937000e+002;
econuse.FX('56','52') = 5.860000e+001;
econuse.FX('56','53') = 846;
econuse.FX('56','54') = 9.682000e+002;
econuse.FX('56','55') = 1.873000e+002;
econuse.FX('56','56') = 2.249000e+002;
econuse.FX('56','57') = 1.234100e+003;
econuse.FX('56','58') = 3.286100e+003;
econuse.FX('56','59') = 9.367000e+002;
econuse.FX('56','60') = 4.060000e+001;
econuse.FX('56','61') = 8.630000e+001;
econuse.FX('56','62') = 4.667000e+002;
econuse.FX('56','63') = 3.837000e+002;
econuse.FX('56','64') = 8.010000e+001;
econuse.FX('56','65') = 8.240000e+001;
econuse.FX('56','66') = 2.430000e+001;
econuse.FX('56','67') = 1.014000e+002;
econuse.FX('56','68') = 1.258000e+002;
econuse.FX('56','69') = 3.768000e+002;
econuse.FX('56','70') = 5.806000e+002;
econuse.FX('56','71') = 1.253140e+004;
econuse.FX('56','72') = 4.790000e+001;
econuse.FX('56','73') = 2468;
econuse.FX('56','74') = 5.467000e+002;
econuse.FX('57','1') = 1.918000e+002;
econuse.FX('57','2') = 733;
econuse.FX('57','3') = 1.136000e+002;
econuse.FX('57','4') = 4.648000e+002;
econuse.FX('57','5') = 1.206600e+003;
econuse.FX('57','6') = 3.689300e+003;
econuse.FX('57','7') = 5.029000e+002;
econuse.FX('57','8') = 1.673400e+003;
econuse.FX('57','9') = 2.035600e+003;
econuse.FX('57','10') = 6.673500e+003;
econuse.FX('57','11') = 1729;
econuse.FX('57','12') = 7.052000e+002;
econuse.FX('57','13') = 6.493310e+004;
econuse.FX('57','14') = 1.177820e+004;
econuse.FX('57','15') = 1.581500e+003;
econuse.FX('57','16') = 2.478900e+003;
econuse.FX('57','17') = 2.056300e+003;
econuse.FX('57','18') = 2400;
econuse.FX('57','19') = 3746;
econuse.FX('57','20') = 2.788100e+003;
econuse.FX('57','21') = 2.382100e+003;
econuse.FX('57','22') = 3.334000e+002;
econuse.FX('57','23') = 3.921000e+002;
econuse.FX('57','24') = 2.161170e+004;
econuse.FX('57','25') = 4684;
econuse.FX('57','26') = 2.329600e+003;
econuse.FX('57','27') = 3.534800e+003;
econuse.FX('57','28') = 8.016900e+003;
econuse.FX('57','29') = 7059;
econuse.FX('57','30') = 2.323400e+003;
econuse.FX('57','31') = 1.846220e+004;
econuse.FX('57','32') = 1.039410e+004;
econuse.FX('57','33') = 1.731100e+003;
econuse.FX('57','34') = 3.346300e+003;
econuse.FX('57','35') = 5120;
econuse.FX('57','36') = 8.836410e+004;
econuse.FX('57','37') = 1.279200e+003;
econuse.FX('57','38') = 1.798300e+003;
econuse.FX('57','39') = 5.871000e+002;
econuse.FX('57','40') = 3.548900e+003;
econuse.FX('57','41') = 1141;
econuse.FX('57','42') = 2239;
econuse.FX('57','43') = 2.485800e+003;
econuse.FX('57','44') = 1.004400e+003;
econuse.FX('57','45') = 1.911370e+004;
econuse.FX('57','46') = 6.426700e+003;
econuse.FX('57','47') = 3.669780e+004;
econuse.FX('57','48') = 6.339400e+003;
econuse.FX('57','49') = 2.324250e+004;
econuse.FX('57','50') = 1.944780e+004;
econuse.FX('57','51') = 1.404990e+004;
econuse.FX('57','52') = 2.339500e+003;
econuse.FX('57','53') = 1.438830e+004;
econuse.FX('57','54') = 4.986690e+004;
econuse.FX('57','55') = 7.498700e+003;
econuse.FX('57','56') = 1.207350e+004;
econuse.FX('57','57') = 6.813580e+004;
econuse.FX('57','58') = 6.375550e+004;
econuse.FX('57','59') = 2.193810e+004;
econuse.FX('57','60') = 1.547500e+003;
econuse.FX('57','61') = 7.065300e+003;
econuse.FX('57','62') = 2.059390e+004;
econuse.FX('57','63') = 7.750900e+003;
econuse.FX('57','64') = 4.143700e+003;
econuse.FX('57','65') = 3.902400e+003;
econuse.FX('57','66') = 5.526900e+003;
econuse.FX('57','67') = 5.066200e+003;
econuse.FX('57','68') = 7.707500e+003;
econuse.FX('57','69') = 1.698940e+004;
econuse.FX('57','70') = 2.250220e+004;
econuse.FX('57','71') = 8.911470e+004;
econuse.FX('57','72') = 1.553900e+003;
econuse.FX('57','73') = 5.377340e+004;
econuse.FX('57','74') = 1.340350e+004;
econuse.FX('58','1') = 0;
econuse.FX('58','2') = 0;
econuse.FX('58','3') = 0;
econuse.FX('58','4') = 0;
econuse.FX('58','5') = 0;
econuse.FX('58','6') = 7.266900e+003;
econuse.FX('58','7') = 1.028800e+003;
econuse.FX('58','8') = 2.128200e+003;
econuse.FX('58','9') = 1.238400e+003;
econuse.FX('58','10') = 0;
econuse.FX('58','11') = 0;
econuse.FX('58','12') = 0;
econuse.FX('58','13') = 3.630500e+003;
econuse.FX('58','14') = 3.655720e+004;
econuse.FX('58','15') = 2.517500e+003;
econuse.FX('58','16') = 2.029400e+003;
econuse.FX('58','17') = 2.484100e+003;
econuse.FX('58','18') = 6.088500e+003;
econuse.FX('58','19') = 3.380200e+003;
econuse.FX('58','20') = 5.544400e+003;
econuse.FX('58','21') = 3.204800e+003;
econuse.FX('58','22') = 5.863000e+002;
econuse.FX('58','23') = 1.091700e+003;
econuse.FX('58','24') = 3.938730e+004;
econuse.FX('58','25') = 6.290200e+003;
econuse.FX('58','26') = 4.341500e+003;
econuse.FX('58','27') = 4.677100e+003;
econuse.FX('58','28') = 6.519600e+003;
econuse.FX('58','29') = 1.188180e+004;
econuse.FX('58','30') = 5.434800e+003;
econuse.FX('58','31') = 3.037250e+004;
econuse.FX('58','32') = 3.286650e+004;
econuse.FX('58','33') = 2.180600e+003;
econuse.FX('58','34') = 1.726900e+003;
econuse.FX('58','35') = 3.776200e+003;
econuse.FX('58','36') = 4.323290e+004;
econuse.FX('58','37') = 7.277000e+002;
econuse.FX('58','38') = 0;
econuse.FX('58','39') = 472;
econuse.FX('58','40') = 4137;
econuse.FX('58','41') = 7.513000e+002;
econuse.FX('58','42') = 0;
econuse.FX('58','43') = 3.580300e+003;
econuse.FX('58','44') = 8.157000e+002;
econuse.FX('58','45') = 7.130600e+003;
econuse.FX('58','46') = 7.561000e+002;
econuse.FX('58','47') = 1.532300e+003;
econuse.FX('58','48') = 1.098800e+003;
econuse.FX('58','49') = 1.002170e+004;
econuse.FX('58','50') = 3.041100e+003;
econuse.FX('58','51') = 3.229900e+003;
econuse.FX('58','52') = 1.501000e+002;
econuse.FX('58','53') = 3.354900e+003;
econuse.FX('58','54') = 8.944100e+003;
econuse.FX('58','55') = 2.588600e+003;
econuse.FX('58','56') = 2.125700e+003;
econuse.FX('58','57') = 1.127790e+004;
econuse.FX('58','58') = 0;
econuse.FX('58','59') = 8464;
econuse.FX('58','60') = 1.545600e+003;
econuse.FX('58','61') = 5.704000e+002;
econuse.FX('58','62') = 8.179400e+003;
econuse.FX('58','63') = 1.530940e+004;
econuse.FX('58','64') = 2.377300e+003;
econuse.FX('58','65') = 1.375200e+003;
econuse.FX('58','66') = 1.866200e+003;
econuse.FX('58','67') = 2.923600e+003;
econuse.FX('58','68') = 4.320900e+003;
econuse.FX('58','69') = 1.755390e+004;
econuse.FX('58','70') = 5.655200e+003;
econuse.FX('58','71') = 0;
econuse.FX('58','72') = 0;
econuse.FX('58','73') = 0;
econuse.FX('58','74') = 0;
econuse.FX('59','1') = 4.160000e+001;
econuse.FX('59','2') = 2.353000e+002;
econuse.FX('59','3') = 4.570000e+001;
econuse.FX('59','4') = 7.030000e+001;
econuse.FX('59','5') = 1.388000e+002;
econuse.FX('59','6') = 3.166000e+002;
econuse.FX('59','7') = 9.680000e+001;
econuse.FX('59','8') = 2.249000e+002;
econuse.FX('59','9') = 2.662000e+002;
econuse.FX('59','10') = 1.301100e+003;
econuse.FX('59','11') = 4.832000e+002;
econuse.FX('59','12') = 7.060000e+001;
econuse.FX('59','13') = 9.723100e+003;
econuse.FX('59','14') = 4314;
econuse.FX('59','15') = 6.197000e+002;
econuse.FX('59','16') = 1.919100e+003;
econuse.FX('59','17') = 7.149000e+002;
econuse.FX('59','18') = 1.213300e+003;
econuse.FX('59','19') = 2.429100e+003;
econuse.FX('59','20') = 1.236100e+003;
econuse.FX('59','21') = 529;
econuse.FX('59','22') = 146;
econuse.FX('59','23') = 4.030000e+001;
econuse.FX('59','24') = 2.444400e+003;
econuse.FX('59','25') = 1.554500e+003;
econuse.FX('59','26') = 1.036200e+003;
econuse.FX('59','27') = 2.691800e+003;
econuse.FX('59','28') = 3.624700e+003;
econuse.FX('59','29') = 2.336100e+003;
econuse.FX('59','30') = 2.078000e+002;
econuse.FX('59','31') = 4.184100e+003;
econuse.FX('59','32') = 4.099600e+003;
econuse.FX('59','33') = 4.879000e+002;
econuse.FX('59','34') = 6.525000e+002;
econuse.FX('59','35') = 9.622000e+002;
econuse.FX('59','36') = 4.271640e+004;
econuse.FX('59','37') = 2.490400e+003;
econuse.FX('59','38') = 7.988000e+002;
econuse.FX('59','39') = 6.912000e+002;
econuse.FX('59','40') = 1.349830e+004;
econuse.FX('59','41') = 9.841000e+002;
econuse.FX('59','42') = 1.657200e+003;
econuse.FX('59','43') = 6.472800e+003;
econuse.FX('59','44') = 1.694600e+003;
econuse.FX('59','45') = 1.275520e+004;
econuse.FX('59','46') = 1.846900e+003;
econuse.FX('59','47') = 8909;
econuse.FX('59','48') = 3.055500e+003;
econuse.FX('59','49') = 9.731400e+003;
econuse.FX('59','50') = 6.472500e+003;
econuse.FX('59','51') = 1.256790e+004;
econuse.FX('59','52') = 2.505000e+002;
econuse.FX('59','53') = 2.677180e+004;
econuse.FX('59','54') = 2.984320e+004;
econuse.FX('59','55') = 7.111700e+003;
econuse.FX('59','56') = 8.852500e+003;
econuse.FX('59','57') = 3.737640e+004;
econuse.FX('59','58') = 7.174200e+003;
econuse.FX('59','59') = 2.023850e+004;
econuse.FX('59','60') = 1.774400e+003;
econuse.FX('59','61') = 3.665600e+003;
econuse.FX('59','62') = 1.931420e+004;
econuse.FX('59','63') = 1.227110e+004;
econuse.FX('59','64') = 4.165500e+003;
econuse.FX('59','65') = 4.022500e+003;
econuse.FX('59','66') = 2.967500e+003;
econuse.FX('59','67') = 2.097900e+003;
econuse.FX('59','68') = 3.819800e+003;
econuse.FX('59','69') = 5.316700e+003;
econuse.FX('59','70') = 1.539790e+004;
econuse.FX('59','71') = 1.578460e+004;
econuse.FX('59','72') = 1.521100e+003;
econuse.FX('59','73') = 3.606430e+004;
econuse.FX('59','74') = 4.848300e+003;
econuse.FX('60','1') = 0;
econuse.FX('60','2') = 4.200000e+000;
econuse.FX('60','3') = 0;
econuse.FX('60','4') = 0;
econuse.FX('60','5') = 1.850000e+001;
econuse.FX('60','6') = 23;
econuse.FX('60','7') = 1.460000e+001;
econuse.FX('60','8') = 3.590000e+001;
econuse.FX('60','9') = 6.470000e+001;
econuse.FX('60','10') = 1.015000e+002;
econuse.FX('60','11') = 3.480000e+001;
econuse.FX('60','12') = 1.160000e+001;
econuse.FX('60','13') = 1.065500e+003;
econuse.FX('60','14') = 8.294000e+002;
econuse.FX('60','15') = 9.920000e+001;
econuse.FX('60','16') = 3.490000e+001;
econuse.FX('60','17') = 104;
econuse.FX('60','18') = 2.441000e+002;
econuse.FX('60','19') = 9.640000e+001;
econuse.FX('60','20') = 1.981000e+002;
econuse.FX('60','21') = 1.836000e+002;
econuse.FX('60','22') = 6.600000e+000;
econuse.FX('60','23') = 1.090000e+001;
econuse.FX('60','24') = 5.234000e+002;
econuse.FX('60','25') = 3.117000e+002;
econuse.FX('60','26') = 1.353000e+002;
econuse.FX('60','27') = 3.519000e+002;
econuse.FX('60','28') = 2.602000e+002;
econuse.FX('60','29') = 1.517000e+002;
econuse.FX('60','30') = 9.600000e+000;
econuse.FX('60','31') = 1.954000e+002;
econuse.FX('60','32') = 3.052000e+002;
econuse.FX('60','33') = 4.410000e+001;
econuse.FX('60','34') = 1.761000e+002;
econuse.FX('60','35') = 107;
econuse.FX('60','36') = 1.617100e+003;
econuse.FX('60','37') = 1.620000e+001;
econuse.FX('60','38') = 2.130000e+001;
econuse.FX('60','39') = 4.623000e+002;
econuse.FX('60','40') = 1.188000e+002;
econuse.FX('60','41') = 2.715000e+002;
econuse.FX('60','42') = 1.094000e+002;
econuse.FX('60','43') = 6.818000e+002;
econuse.FX('60','44') = 1.182000e+002;
econuse.FX('60','45') = 5.440000e+001;
econuse.FX('60','46') = 2.510000e+001;
econuse.FX('60','47') = 1.180200e+003;
econuse.FX('60','48') = 2.890000e+001;
econuse.FX('60','49') = 7.100000e+000;
econuse.FX('60','50') = 5.210000e+001;
econuse.FX('60','51') = 6.680000e+001;
econuse.FX('60','52') = 0;
econuse.FX('60','53') = 1.050170e+004;
econuse.FX('60','54') = 2.649000e+002;
econuse.FX('60','55') = 3.880000e+001;
econuse.FX('60','56') = 5.680000e+001;
econuse.FX('60','57') = 5.966000e+002;
econuse.FX('60','58') = 1.907000e+002;
econuse.FX('60','59') = 5.544000e+002;
econuse.FX('60','60') = 5.213800e+003;
econuse.FX('60','61') = 3.547000e+002;
econuse.FX('60','62') = 6.339000e+002;
econuse.FX('60','63') = 1.618000e+002;
econuse.FX('60','64') = 4.064000e+002;
econuse.FX('60','65') = 3.276000e+002;
econuse.FX('60','66') = 7.010000e+001;
econuse.FX('60','67') = 2.573000e+002;
econuse.FX('60','68') = 7.664000e+002;
econuse.FX('60','69') = 1.242400e+003;
econuse.FX('60','70') = 1.378200e+003;
econuse.FX('60','71') = 5.785000e+002;
econuse.FX('60','72') = 4.940000e+001;
econuse.FX('60','73') = 13724;
econuse.FX('60','74') = 1.740400e+003;
econuse.FX('61','1') = 1.295000e+002;
econuse.FX('61','2') = 2.425000e+002;
econuse.FX('61','3') = 3.500000e+000;
econuse.FX('61','4') = 1.751000e+002;
econuse.FX('61','5') = 5.071000e+002;
econuse.FX('61','6') = 5.000000e-001;
econuse.FX('61','7') = 0;
econuse.FX('61','8') = 0;
econuse.FX('61','9') = 0;
econuse.FX('61','10') = 26;
econuse.FX('61','11') = 1.033000e+002;
econuse.FX('61','12') = 0;
econuse.FX('61','13') = 40;
econuse.FX('61','14') = 1.700000e+000;
econuse.FX('61','15') = 1.000000e-001;
econuse.FX('61','16') = 1.000000e-001;
econuse.FX('61','17') = 2.000000e-001;
econuse.FX('61','18') = 7.000000e-001;
econuse.FX('61','19') = 5.720000e+001;
econuse.FX('61','20') = 9.100000e+000;
econuse.FX('61','21') = 3.000000e-001;
econuse.FX('61','22') = 0;
econuse.FX('61','23') = 0;
econuse.FX('61','24') = 1.300000e+000;
econuse.FX('61','25') = 1.600000e+000;
econuse.FX('61','26') = 3.000000e-001;
econuse.FX('61','27') = 5.000000e-001;
econuse.FX('61','28') = 1.600000e+000;
econuse.FX('61','29') = 1;
econuse.FX('61','30') = 5.000000e-001;
econuse.FX('61','31') = 3.300000e+000;
econuse.FX('61','32') = 2.900000e+000;
econuse.FX('61','33') = 1.000000e-001;
econuse.FX('61','34') = 4.000000e-001;
econuse.FX('61','35') = 1;
econuse.FX('61','36') = 2.463400e+003;
econuse.FX('61','37') = 1.770000e+001;
econuse.FX('61','38') = 3.280000e+001;
econuse.FX('61','39') = 0;
econuse.FX('61','40') = 0;
econuse.FX('61','41') = 0;
econuse.FX('61','42') = 7.500000e+000;
econuse.FX('61','43') = 6.600000e+000;
econuse.FX('61','44') = 0;
econuse.FX('61','45') = 0;
econuse.FX('61','46') = 0;
econuse.FX('61','47') = 3.542000e+002;
econuse.FX('61','48') = 49;
econuse.FX('61','49') = 6.560000e+001;
econuse.FX('61','50') = 6.400000e+000;
econuse.FX('61','51') = 0;
econuse.FX('61','52') = 0;
econuse.FX('61','53') = 1.000000e-001;
econuse.FX('61','54') = 9.250000e+001;
econuse.FX('61','55') = 0;
econuse.FX('61','56') = 3.910000e+001;
econuse.FX('61','57') = 9.280000e+001;
econuse.FX('61','58') = 0;
econuse.FX('61','59') = 149;
econuse.FX('61','60') = 0;
econuse.FX('61','61') = 7.533000e+002;
econuse.FX('61','62') = 30;
econuse.FX('61','63') = 9.590000e+001;
econuse.FX('61','64') = 0;
econuse.FX('61','65') = 0;
econuse.FX('61','66') = 2.661000e+002;
econuse.FX('61','67') = 7.130000e+001;
econuse.FX('61','68') = 0;
econuse.FX('61','69') = 0;
econuse.FX('61','70') = 1.611400e+003;
econuse.FX('61','71') = 5.179200e+003;
econuse.FX('61','72') = 6.510000e+001;
econuse.FX('61','73') = 8.103400e+003;
econuse.FX('61','74') = 2.350000e+001;
econuse.FX('62','1') = 0;
econuse.FX('62','2') = 0;
econuse.FX('62','3') = 0;
econuse.FX('62','4') = 0;
econuse.FX('62','5') = 0;
econuse.FX('62','6') = 0;
econuse.FX('62','7') = 0;
econuse.FX('62','8') = 0;
econuse.FX('62','9') = 0;
econuse.FX('62','10') = 0;
econuse.FX('62','11') = 0;
econuse.FX('62','12') = 0;
econuse.FX('62','13') = 0;
econuse.FX('62','14') = 0;
econuse.FX('62','15') = 0;
econuse.FX('62','16') = 0;
econuse.FX('62','17') = 0;
econuse.FX('62','18') = 0;
econuse.FX('62','19') = 0;
econuse.FX('62','20') = 0;
econuse.FX('62','21') = 0;
econuse.FX('62','22') = 0;
econuse.FX('62','23') = 0;
econuse.FX('62','24') = 0;
econuse.FX('62','25') = 0;
econuse.FX('62','26') = 0;
econuse.FX('62','27') = 0;
econuse.FX('62','28') = 0;
econuse.FX('62','29') = 0;
econuse.FX('62','30') = 0;
econuse.FX('62','31') = 0;
econuse.FX('62','32') = 0;
econuse.FX('62','33') = 0;
econuse.FX('62','34') = 0;
econuse.FX('62','35') = 0;
econuse.FX('62','36') = 0;
econuse.FX('62','37') = 0;
econuse.FX('62','38') = 0;
econuse.FX('62','39') = 0;
econuse.FX('62','40') = 0;
econuse.FX('62','41') = 0;
econuse.FX('62','42') = 0;
econuse.FX('62','43') = 0;
econuse.FX('62','44') = 0;
econuse.FX('62','45') = 0;
econuse.FX('62','46') = 0;
econuse.FX('62','47') = 0;
econuse.FX('62','48') = 0;
econuse.FX('62','49') = 0;
econuse.FX('62','50') = 0;
econuse.FX('62','51') = 0;
econuse.FX('62','52') = 0;
econuse.FX('62','53') = 0;
econuse.FX('62','54') = 1.160000e+001;
econuse.FX('62','55') = 0;
econuse.FX('62','56') = 0;
econuse.FX('62','57') = 2.242000e+002;
econuse.FX('62','58') = 0;
econuse.FX('62','59') = 2.460000e+001;
econuse.FX('62','60') = 0;
econuse.FX('62','61') = 0;
econuse.FX('62','62') = 1.104640e+004;
econuse.FX('62','63') = 8.464100e+003;
econuse.FX('62','64') = 2.070000e+001;
econuse.FX('62','65') = 0;
econuse.FX('62','66') = 6.540000e+001;
econuse.FX('62','67') = 2.300000e+000;
econuse.FX('62','68') = 0;
econuse.FX('62','69') = 0;
econuse.FX('62','70') = 7.530000e+001;
econuse.FX('62','71') = 2.854000e+002;
econuse.FX('62','72') = 0;
econuse.FX('62','73') = 947;
econuse.FX('62','74') = 0;
econuse.FX('63','1') = 0;
econuse.FX('63','2') = 0;
econuse.FX('63','3') = 0;
econuse.FX('63','4') = 0;
econuse.FX('63','5') = 0;
econuse.FX('63','6') = 0;
econuse.FX('63','7') = 0;
econuse.FX('63','8') = 0;
econuse.FX('63','9') = 0;
econuse.FX('63','10') = 0;
econuse.FX('63','11') = 0;
econuse.FX('63','12') = 0;
econuse.FX('63','13') = 0;
econuse.FX('63','14') = 0;
econuse.FX('63','15') = 0;
econuse.FX('63','16') = 0;
econuse.FX('63','17') = 0;
econuse.FX('63','18') = 0;
econuse.FX('63','19') = 0;
econuse.FX('63','20') = 0;
econuse.FX('63','21') = 0;
econuse.FX('63','22') = 0;
econuse.FX('63','23') = 0;
econuse.FX('63','24') = 0;
econuse.FX('63','25') = 0;
econuse.FX('63','26') = 0;
econuse.FX('63','27') = 0;
econuse.FX('63','28') = 0;
econuse.FX('63','29') = 0;
econuse.FX('63','30') = 0;
econuse.FX('63','31') = 0;
econuse.FX('63','32') = 0;
econuse.FX('63','33') = 0;
econuse.FX('63','34') = 0;
econuse.FX('63','35') = 0;
econuse.FX('63','36') = 0;
econuse.FX('63','37') = 0;
econuse.FX('63','38') = 0;
econuse.FX('63','39') = 0;
econuse.FX('63','40') = 0;
econuse.FX('63','41') = 0;
econuse.FX('63','42') = 0;
econuse.FX('63','43') = 0;
econuse.FX('63','44') = 0;
econuse.FX('63','45') = 0;
econuse.FX('63','46') = 0;
econuse.FX('63','47') = 0;
econuse.FX('63','48') = 0;
econuse.FX('63','49') = 0;
econuse.FX('63','50') = 0;
econuse.FX('63','51') = 0;
econuse.FX('63','52') = 0;
econuse.FX('63','53') = 0;
econuse.FX('63','54') = 0;
econuse.FX('63','55') = 0;
econuse.FX('63','56') = 0;
econuse.FX('63','57') = 0;
econuse.FX('63','58') = 0;
econuse.FX('63','59') = 0;
econuse.FX('63','60') = 0;
econuse.FX('63','61') = 0;
econuse.FX('63','62') = 0;
econuse.FX('63','63') = 5.265000e+002;
econuse.FX('63','64') = 0;
econuse.FX('63','65') = 0;
econuse.FX('63','66') = 0;
econuse.FX('63','67') = 0;
econuse.FX('63','68') = 0;
econuse.FX('63','69') = 0;
econuse.FX('63','70') = 0;
econuse.FX('63','71') = 1.251000e+002;
econuse.FX('63','72') = 0;
econuse.FX('63','73') = 536;
econuse.FX('63','74') = 0;
econuse.FX('64','1') = 0;
econuse.FX('64','2') = 0;
econuse.FX('64','3') = 0;
econuse.FX('64','4') = 0;
econuse.FX('64','5') = 0;
econuse.FX('64','6') = 0;
econuse.FX('64','7') = 0;
econuse.FX('64','8') = 0;
econuse.FX('64','9') = 0;
econuse.FX('64','10') = 0;
econuse.FX('64','11') = 0;
econuse.FX('64','12') = 0;
econuse.FX('64','13') = 0;
econuse.FX('64','14') = 0;
econuse.FX('64','15') = 0;
econuse.FX('64','16') = 0;
econuse.FX('64','17') = 0;
econuse.FX('64','18') = 0;
econuse.FX('64','19') = 0;
econuse.FX('64','20') = 0;
econuse.FX('64','21') = 0;
econuse.FX('64','22') = 0;
econuse.FX('64','23') = 0;
econuse.FX('64','24') = 0;
econuse.FX('64','25') = 0;
econuse.FX('64','26') = 0;
econuse.FX('64','27') = 0;
econuse.FX('64','28') = 0;
econuse.FX('64','29') = 0;
econuse.FX('64','30') = 0;
econuse.FX('64','31') = 0;
econuse.FX('64','32') = 0;
econuse.FX('64','33') = 0;
econuse.FX('64','34') = 0;
econuse.FX('64','35') = 0;
econuse.FX('64','36') = 0;
econuse.FX('64','37') = 0;
econuse.FX('64','38') = 0;
econuse.FX('64','39') = 0;
econuse.FX('64','40') = 0;
econuse.FX('64','41') = 0;
econuse.FX('64','42') = 0;
econuse.FX('64','43') = 0;
econuse.FX('64','44') = 0;
econuse.FX('64','45') = 0;
econuse.FX('64','46') = 0;
econuse.FX('64','47') = 0;
econuse.FX('64','48') = 0;
econuse.FX('64','49') = 0;
econuse.FX('64','50') = 0;
econuse.FX('64','51') = 0;
econuse.FX('64','52') = 0;
econuse.FX('64','53') = 0;
econuse.FX('64','54') = 0;
econuse.FX('64','55') = 0;
econuse.FX('64','56') = 0;
econuse.FX('64','57') = 0;
econuse.FX('64','58') = 0;
econuse.FX('64','59') = 0;
econuse.FX('64','60') = 0;
econuse.FX('64','61') = 0;
econuse.FX('64','62') = 0;
econuse.FX('64','63') = 0;
econuse.FX('64','64') = 0;
econuse.FX('64','65') = 0;
econuse.FX('64','66') = 0;
econuse.FX('64','67') = 0;
econuse.FX('64','68') = 0;
econuse.FX('64','69') = 0;
econuse.FX('64','70') = 0;
econuse.FX('64','71') = 1.836000e+002;
econuse.FX('64','72') = 0;
econuse.FX('64','73') = 4.283000e+002;
econuse.FX('64','74') = 0;
econuse.FX('65','1') = 0;
econuse.FX('65','2') = 0;
econuse.FX('65','3') = 0;
econuse.FX('65','4') = 0;
econuse.FX('65','5') = 0;
econuse.FX('65','6') = 0;
econuse.FX('65','7') = 0;
econuse.FX('65','8') = 0;
econuse.FX('65','9') = 0;
econuse.FX('65','10') = 0;
econuse.FX('65','11') = 0;
econuse.FX('65','12') = 0;
econuse.FX('65','13') = 0;
econuse.FX('65','14') = 0;
econuse.FX('65','15') = 0;
econuse.FX('65','16') = 0;
econuse.FX('65','17') = 0;
econuse.FX('65','18') = 0;
econuse.FX('65','19') = 0;
econuse.FX('65','20') = 0;
econuse.FX('65','21') = 0;
econuse.FX('65','22') = 0;
econuse.FX('65','23') = 0;
econuse.FX('65','24') = 0;
econuse.FX('65','25') = 0;
econuse.FX('65','26') = 0;
econuse.FX('65','27') = 0;
econuse.FX('65','28') = 0;
econuse.FX('65','29') = 0;
econuse.FX('65','30') = 0;
econuse.FX('65','31') = 0;
econuse.FX('65','32') = 0;
econuse.FX('65','33') = 0;
econuse.FX('65','34') = 0;
econuse.FX('65','35') = 0;
econuse.FX('65','36') = 2.000000e-001;
econuse.FX('65','37') = 0;
econuse.FX('65','38') = 0;
econuse.FX('65','39') = 0;
econuse.FX('65','40') = 0;
econuse.FX('65','41') = 0;
econuse.FX('65','42') = 0;
econuse.FX('65','43') = 0;
econuse.FX('65','44') = 0;
econuse.FX('65','45') = 0;
econuse.FX('65','46') = 0;
econuse.FX('65','47') = 0;
econuse.FX('65','48') = 0;
econuse.FX('65','49') = 0;
econuse.FX('65','50') = 0;
econuse.FX('65','51') = 0;
econuse.FX('65','52') = 0;
econuse.FX('65','53') = 0;
econuse.FX('65','54') = 0;
econuse.FX('65','55') = 0;
econuse.FX('65','56') = 0;
econuse.FX('65','57') = 0;
econuse.FX('65','58') = 0;
econuse.FX('65','59') = 0;
econuse.FX('65','60') = 0;
econuse.FX('65','61') = 0;
econuse.FX('65','62') = 0;
econuse.FX('65','63') = 0;
econuse.FX('65','64') = 0;
econuse.FX('65','65') = 0;
econuse.FX('65','66') = 0;
econuse.FX('65','67') = 0;
econuse.FX('65','68') = 0;
econuse.FX('65','69') = 0;
econuse.FX('65','70') = 0;
econuse.FX('65','71') = 26;
econuse.FX('65','72') = 0;
econuse.FX('65','73') = 1.860400e+003;
econuse.FX('65','74') = 0;
econuse.FX('66','1') = 5.800000e+000;
econuse.FX('66','2') = 2.090000e+001;
econuse.FX('66','3') = 6.400000e+000;
econuse.FX('66','4') = 9;
econuse.FX('66','5') = 8.030000e+001;
econuse.FX('66','6') = 1.100000e+000;
econuse.FX('66','7') = 4.000000e-001;
econuse.FX('66','8') = 9.000000e-001;
econuse.FX('66','9') = 6.300000e+000;
econuse.FX('66','10') = 5.040000e+001;
econuse.FX('66','11') = 2.620000e+001;
econuse.FX('66','12') = 1.900000e+000;
econuse.FX('66','13') = 2.763000e+002;
econuse.FX('66','14') = 2.093000e+002;
econuse.FX('66','15') = 40;
econuse.FX('66','16') = 2.620000e+001;
econuse.FX('66','17') = 6.430000e+001;
econuse.FX('66','18') = 7.340000e+001;
econuse.FX('66','19') = 9.130000e+001;
econuse.FX('66','20') = 9.190000e+001;
econuse.FX('66','21') = 1.610000e+001;
econuse.FX('66','22') = 3;
econuse.FX('66','23') = 1.200000e+000;
econuse.FX('66','24') = 6.760000e+001;
econuse.FX('66','25') = 1.308000e+002;
econuse.FX('66','26') = 5.340000e+001;
econuse.FX('66','27') = 7.370000e+001;
econuse.FX('66','28') = 142;
econuse.FX('66','29') = 1.101000e+002;
econuse.FX('66','30') = 2.400000e+000;
econuse.FX('66','31') = 8.210000e+001;
econuse.FX('66','32') = 9.890000e+001;
econuse.FX('66','33') = 2.020000e+001;
econuse.FX('66','34') = 4.760000e+001;
econuse.FX('66','35') = 7.160000e+001;
econuse.FX('66','36') = 1.968900e+003;
econuse.FX('66','37') = 15;
econuse.FX('66','38') = 2.206000e+002;
econuse.FX('66','39') = 2.800000e+000;
econuse.FX('66','40') = 3.650000e+001;
econuse.FX('66','41') = 5.280000e+001;
econuse.FX('66','42') = 4.100000e+000;
econuse.FX('66','43') = 1.573000e+002;
econuse.FX('66','44') = 4.750000e+001;
econuse.FX('66','45') = 3.334000e+002;
econuse.FX('66','46') = 1.673300e+003;
econuse.FX('66','47') = 8.893700e+003;
econuse.FX('66','48') = 9.240000e+001;
econuse.FX('66','49') = 1.329700e+003;
econuse.FX('66','50') = 3.818000e+002;
econuse.FX('66','51') = 1.133000e+002;
econuse.FX('66','52') = 64;
econuse.FX('66','53') = 6.321000e+002;
econuse.FX('66','54') = 1.262900e+003;
econuse.FX('66','55') = 4.198000e+002;
econuse.FX('66','56') = 2.126000e+002;
econuse.FX('66','57') = 3.034500e+003;
econuse.FX('66','58') = 2.252700e+003;
econuse.FX('66','59') = 9.985000e+002;
econuse.FX('66','60') = 8.560000e+001;
econuse.FX('66','61') = 2.587000e+002;
econuse.FX('66','62') = 3.219000e+002;
econuse.FX('66','63') = 1.553000e+002;
econuse.FX('66','64') = 7.330000e+001;
econuse.FX('66','65') = 2.952000e+002;
econuse.FX('66','66') = 8766;
econuse.FX('66','67') = 655;
econuse.FX('66','68') = 1.988000e+002;
econuse.FX('66','69') = 1.579900e+003;
econuse.FX('66','70') = 2.072500e+003;
econuse.FX('66','71') = 9.894000e+002;
econuse.FX('66','72') = 44;
econuse.FX('66','73') = 6.986000e+002;
econuse.FX('66','74') = 7.110000e+001;
econuse.FX('67','1') = 4.600000e+000;
econuse.FX('67','2') = 1.610000e+001;
econuse.FX('67','3') = 5.500000e+000;
econuse.FX('67','4') = 17;
econuse.FX('67','5') = 1.500000e+000;
econuse.FX('67','6') = 4.000000e-001;
econuse.FX('67','7') = 5.000000e-001;
econuse.FX('67','8') = 1.900000e+000;
econuse.FX('67','9') = 9.300000e+000;
econuse.FX('67','10') = 4.030000e+001;
econuse.FX('67','11') = 1.010000e+001;
econuse.FX('67','12') = 5.000000e-001;
econuse.FX('67','13') = 1.463000e+002;
econuse.FX('67','14') = 7.340000e+001;
econuse.FX('67','15') = 9.600000e+000;
econuse.FX('67','16') = 4.700000e+000;
econuse.FX('67','17') = 2.790000e+001;
econuse.FX('67','18') = 2.570000e+001;
econuse.FX('67','19') = 5.780000e+001;
econuse.FX('67','20') = 2.160000e+001;
econuse.FX('67','21') = 9;
econuse.FX('67','22') = 7.000000e-001;
econuse.FX('67','23') = 5.000000e-001;
econuse.FX('67','24') = 26;
econuse.FX('67','25') = 55;
econuse.FX('67','26') = 2.360000e+001;
econuse.FX('67','27') = 2.950000e+001;
econuse.FX('67','28') = 7.290000e+001;
econuse.FX('67','29') = 5.030000e+001;
econuse.FX('67','30') = 8.000000e-001;
econuse.FX('67','31') = 5.030000e+001;
econuse.FX('67','32') = 4.770000e+001;
econuse.FX('67','33') = 9.800000e+000;
econuse.FX('67','34') = 2.970000e+001;
econuse.FX('67','35') = 4.490000e+001;
econuse.FX('67','36') = 6.554000e+002;
econuse.FX('67','37') = 1.000000e-001;
econuse.FX('67','38') = 1.200000e+000;
econuse.FX('67','39') = 0;
econuse.FX('67','40') = 9.000000e-001;
econuse.FX('67','41') = 0;
econuse.FX('67','42') = 2;
econuse.FX('67','43') = 3.200000e+000;
econuse.FX('67','44') = 4.000000e-001;
econuse.FX('67','45') = 144;
econuse.FX('67','46') = 2.760000e+001;
econuse.FX('67','47') = 1.729000e+002;
econuse.FX('67','48') = 9.290000e+001;
econuse.FX('67','49') = 5.139000e+002;
econuse.FX('67','50') = 9.430000e+001;
econuse.FX('67','51') = 7.670000e+001;
econuse.FX('67','52') = 1.190000e+001;
econuse.FX('67','53') = 1.307000e+002;
econuse.FX('67','54') = 5.678000e+002;
econuse.FX('67','55') = 1.495000e+002;
econuse.FX('67','56') = 1.646000e+002;
econuse.FX('67','57') = 8.146000e+002;
econuse.FX('67','58') = 576;
econuse.FX('67','59') = 4.626000e+002;
econuse.FX('67','60') = 4.870000e+001;
econuse.FX('67','61') = 5.780000e+001;
econuse.FX('67','62') = 2.403000e+002;
econuse.FX('67','63') = 5.500000e+000;
econuse.FX('67','64') = 22;
econuse.FX('67','65') = 4.540000e+001;
econuse.FX('67','66') = 3.250000e+001;
econuse.FX('67','67') = 2.070000e+001;
econuse.FX('67','68') = 3.080000e+001;
econuse.FX('67','69') = 345;
econuse.FX('67','70') = 1.882000e+002;
econuse.FX('67','71') = 2.587000e+002;
econuse.FX('67','72') = 4.100000e+000;
econuse.FX('67','73') = 2.097500e+003;
econuse.FX('67','74') = 2.320000e+001;
econuse.FX('68','1') = 1.800000e+000;
econuse.FX('68','2') = 6.600000e+000;
econuse.FX('68','3') = 2.300000e+000;
econuse.FX('68','4') = 3.100000e+000;
econuse.FX('68','5') = 1;
econuse.FX('68','6') = 3;
econuse.FX('68','7') = 4.200000e+000;
econuse.FX('68','8') = 1.920000e+001;
econuse.FX('68','9') = 7.350000e+001;
econuse.FX('68','10') = 3.338000e+002;
econuse.FX('68','11') = 1.053000e+002;
econuse.FX('68','12') = 5;
econuse.FX('68','13') = 1.218400e+003;
econuse.FX('68','14') = 6.268000e+002;
econuse.FX('68','15') = 8.330000e+001;
econuse.FX('68','16') = 3.950000e+001;
econuse.FX('68','17') = 2.342000e+002;
econuse.FX('68','18') = 2.206000e+002;
econuse.FX('68','19') = 4.869000e+002;
econuse.FX('68','20') = 1.797000e+002;
econuse.FX('68','21') = 7.760000e+001;
econuse.FX('68','22') = 6.700000e+000;
econuse.FX('68','23') = 5.100000e+000;
econuse.FX('68','24') = 238;
econuse.FX('68','25') = 4.627000e+002;
econuse.FX('68','26') = 2.025000e+002;
econuse.FX('68','27') = 254;
econuse.FX('68','28') = 6.209000e+002;
econuse.FX('68','29') = 4.402000e+002;
econuse.FX('68','30') = 7.700000e+000;
econuse.FX('68','31') = 4.504000e+002;
econuse.FX('68','32') = 4.134000e+002;
econuse.FX('68','33') = 8.260000e+001;
econuse.FX('68','34') = 2.477000e+002;
econuse.FX('68','35') = 403;
econuse.FX('68','36') = 6.633000e+002;
econuse.FX('68','37') = 8.000000e-001;
econuse.FX('68','38') = 9.800000e+000;
econuse.FX('68','39') = 0;
econuse.FX('68','40') = 4.800000e+000;
econuse.FX('68','41') = 50;
econuse.FX('68','42') = 1.210000e+001;
econuse.FX('68','43') = 2.012000e+002;
econuse.FX('68','44') = 49;
econuse.FX('68','45') = 1168;
econuse.FX('68','46') = 2.419000e+002;
econuse.FX('68','47') = 1.423800e+003;
econuse.FX('68','48') = 7.662000e+002;
econuse.FX('68','49') = 4.175100e+003;
econuse.FX('68','50') = 7.798000e+002;
econuse.FX('68','51') = 6.275000e+002;
econuse.FX('68','52') = 1.227000e+002;
econuse.FX('68','53') = 1050;
econuse.FX('68','54') = 4.288700e+003;
econuse.FX('68','55') = 8.918000e+002;
econuse.FX('68','56') = 1.370100e+003;
econuse.FX('68','57') = 5.577100e+003;
econuse.FX('68','58') = 4.432000e+002;
econuse.FX('68','59') = 2.630600e+003;
econuse.FX('68','60') = 3.825000e+002;
econuse.FX('68','61') = 3.954000e+002;
econuse.FX('68','62') = 1.306700e+003;
econuse.FX('68','63') = 4.630000e+001;
econuse.FX('68','64') = 9.950000e+001;
econuse.FX('68','65') = 2.404000e+002;
econuse.FX('68','66') = 94;
econuse.FX('68','67') = 155;
econuse.FX('68','68') = 258;
econuse.FX('68','69') = 1228;
econuse.FX('68','70') = 1.281300e+003;
econuse.FX('68','71') = 2.653800e+003;
econuse.FX('68','72') = 3.480000e+001;
econuse.FX('68','73') = 2.600700e+003;
econuse.FX('68','74') = 1.613000e+002;
econuse.FX('69','1') = 1.630000e+001;
econuse.FX('69','2') = 6.740000e+001;
econuse.FX('69','3') = 2.040000e+001;
econuse.FX('69','4') = 3.020000e+001;
econuse.FX('69','5') = 1.100000e+000;
econuse.FX('69','6') = 5.100000e+000;
econuse.FX('69','7') = 4;
econuse.FX('69','8') = 1.630000e+001;
econuse.FX('69','9') = 9.170000e+001;
econuse.FX('69','10') = 3.150400e+003;
econuse.FX('69','11') = 1.751000e+002;
econuse.FX('69','12') = 9.200000e+000;
econuse.FX('69','13') = 1.653800e+003;
econuse.FX('69','14') = 1.103600e+003;
econuse.FX('69','15') = 1.858000e+002;
econuse.FX('69','16') = 1.145000e+002;
econuse.FX('69','17') = 3.641000e+002;
econuse.FX('69','18') = 3.859000e+002;
econuse.FX('69','19') = 6.379000e+002;
econuse.FX('69','20') = 5.476000e+002;
econuse.FX('69','21') = 1.048000e+002;
econuse.FX('69','22') = 1.320000e+001;
econuse.FX('69','23') = 7.100000e+000;
econuse.FX('69','24') = 3.894000e+002;
econuse.FX('69','25') = 738;
econuse.FX('69','26') = 3.168000e+002;
econuse.FX('69','27') = 4.207000e+002;
econuse.FX('69','28') = 902;
econuse.FX('69','29') = 6.827000e+002;
econuse.FX('69','30') = 1.380000e+001;
econuse.FX('69','31') = 5.885000e+002;
econuse.FX('69','32') = 6.104000e+002;
econuse.FX('69','33') = 1.248000e+002;
econuse.FX('69','34') = 3.311000e+002;
econuse.FX('69','35') = 5.366000e+002;
econuse.FX('69','36') = 5.799800e+003;
econuse.FX('69','37') = 3.685800e+003;
econuse.FX('69','38') = 13;
econuse.FX('69','39') = 7.200000e+000;
econuse.FX('69','40') = 1.942000e+002;
econuse.FX('69','41') = 15;
econuse.FX('69','42') = 1.340000e+001;
econuse.FX('69','43') = 314;
econuse.FX('69','44') = 5.820000e+001;
econuse.FX('69','45') = 1.361900e+003;
econuse.FX('69','46') = 2.947000e+002;
econuse.FX('69','47') = 1.698100e+003;
econuse.FX('69','48') = 8.122000e+002;
econuse.FX('69','49') = 7.670900e+003;
econuse.FX('69','50') = 7.704000e+002;
econuse.FX('69','51') = 8.355000e+002;
econuse.FX('69','52') = 272;
econuse.FX('69','53') = 2.755900e+003;
econuse.FX('69','54') = 9.498500e+003;
econuse.FX('69','55') = 1.891700e+003;
econuse.FX('69','56') = 2.251200e+003;
econuse.FX('69','57') = 1.289070e+004;
econuse.FX('69','58') = 2937;
econuse.FX('69','59') = 5.618200e+003;
econuse.FX('69','60') = 534;
econuse.FX('69','61') = 9.895000e+002;
econuse.FX('69','62') = 4.771200e+003;
econuse.FX('69','63') = 1577;
econuse.FX('69','64') = 1562;
econuse.FX('69','65') = 1.094200e+003;
econuse.FX('69','66') = 287;
econuse.FX('69','67') = 5.603000e+002;
econuse.FX('69','68') = 2.369500e+003;
econuse.FX('69','69') = 3249;
econuse.FX('69','70') = 3318;
econuse.FX('69','71') = 1.021700e+003;
econuse.FX('69','72') = 8.977000e+002;
econuse.FX('69','73') = 1.104480e+004;
econuse.FX('69','74') = 2.458000e+002;
econuse.FX('70','1') = 9.220000e+001;
econuse.FX('70','2') = 3.476000e+002;
econuse.FX('70','3') = 7.920000e+001;
econuse.FX('70','4') = 8.470000e+001;
econuse.FX('70','5') = 6.627000e+002;
econuse.FX('70','6') = 1.455000e+002;
econuse.FX('70','7') = 3.590000e+001;
econuse.FX('70','8') = 8.650000e+001;
econuse.FX('70','9') = 1.053000e+002;
econuse.FX('70','10') = 1.917000e+002;
econuse.FX('70','11') = 3.779000e+002;
econuse.FX('70','12') = 1.173000e+002;
econuse.FX('70','13') = 1.588510e+004;
econuse.FX('70','14') = 2.464100e+003;
econuse.FX('70','15') = 4.288000e+002;
econuse.FX('70','16') = 1.148000e+002;
econuse.FX('70','17') = 6.016000e+002;
econuse.FX('70','18') = 1.237400e+003;
econuse.FX('70','19') = 7.517000e+002;
econuse.FX('70','20') = 1.112400e+003;
econuse.FX('70','21') = 555;
econuse.FX('70','22') = 1.479000e+002;
econuse.FX('70','23') = 4.140000e+001;
econuse.FX('70','24') = 1.785400e+003;
econuse.FX('70','25') = 1.263200e+003;
econuse.FX('70','26') = 9.203000e+002;
econuse.FX('70','27') = 1.560800e+003;
econuse.FX('70','28') = 1633;
econuse.FX('70','29') = 1.130500e+003;
econuse.FX('70','30') = 9.360000e+001;
econuse.FX('70','31') = 1.466100e+003;
econuse.FX('70','32') = 1.498900e+003;
econuse.FX('70','33') = 1.807000e+002;
econuse.FX('70','34') = 5.445000e+002;
econuse.FX('70','35') = 5.171000e+002;
econuse.FX('70','36') = 1.313570e+004;
econuse.FX('70','37') = 126;
econuse.FX('70','38') = 1.616000e+002;
econuse.FX('70','39') = 29;
econuse.FX('70','40') = 2439;
econuse.FX('70','41') = 5.106000e+002;
econuse.FX('70','42') = 5.817000e+002;
econuse.FX('70','43') = 1.275400e+003;
econuse.FX('70','44') = 5.611000e+002;
econuse.FX('70','45') = 1.389700e+003;
econuse.FX('70','46') = 3.677000e+002;
econuse.FX('70','47') = 4.450500e+003;
econuse.FX('70','48') = 1.738400e+003;
econuse.FX('70','49') = 7.894600e+003;
econuse.FX('70','50') = 1.947300e+003;
econuse.FX('70','51') = 1.901700e+003;
econuse.FX('70','52') = 4.384000e+002;
econuse.FX('70','53') = 1.111590e+004;
econuse.FX('70','54') = 5.368600e+003;
econuse.FX('70','55') = 9.781000e+002;
econuse.FX('70','56') = 7.812000e+002;
econuse.FX('70','57') = 7.195900e+003;
econuse.FX('70','58') = 7146;
econuse.FX('70','59') = 5.938400e+003;
econuse.FX('70','60') = 7.671000e+002;
econuse.FX('70','61') = 1.801500e+003;
econuse.FX('70','62') = 4.634900e+003;
econuse.FX('70','63') = 4.701200e+003;
econuse.FX('70','64') = 8.693000e+002;
econuse.FX('70','65') = 8.082000e+002;
econuse.FX('70','66') = 8.501000e+002;
econuse.FX('70','67') = 1288;
econuse.FX('70','68') = 1.565900e+003;
econuse.FX('70','69') = 4.796800e+003;
econuse.FX('70','70') = 6.676800e+003;
econuse.FX('70','71') = 4.443400e+003;
econuse.FX('70','72') = 7.274000e+002;
econuse.FX('70','73') = 1.944260e+004;
econuse.FX('70','74') = 1.307800e+003;
econuse.FX('71','1') = 0;
econuse.FX('71','2') = 0;
econuse.FX('71','3') = 0;
econuse.FX('71','4') = 0;
econuse.FX('71','5') = 0;
econuse.FX('71','6') = 0;
econuse.FX('71','7') = 0;
econuse.FX('71','8') = 0;
econuse.FX('71','9') = 0;
econuse.FX('71','10') = 0;
econuse.FX('71','11') = 0;
econuse.FX('71','12') = 0;
econuse.FX('71','13') = 0;
econuse.FX('71','14') = 0;
econuse.FX('71','15') = 0;
econuse.FX('71','16') = 0;
econuse.FX('71','17') = 0;
econuse.FX('71','18') = 0;
econuse.FX('71','19') = 0;
econuse.FX('71','20') = 0;
econuse.FX('71','21') = 0;
econuse.FX('71','22') = 0;
econuse.FX('71','23') = 0;
econuse.FX('71','24') = 0;
econuse.FX('71','25') = 0;
econuse.FX('71','26') = 0;
econuse.FX('71','27') = 0;
econuse.FX('71','28') = 0;
econuse.FX('71','29') = 0;
econuse.FX('71','30') = 0;
econuse.FX('71','31') = 0;
econuse.FX('71','32') = 0;
econuse.FX('71','33') = 0;
econuse.FX('71','34') = 0;
econuse.FX('71','35') = 0;
econuse.FX('71','36') = 0;
econuse.FX('71','37') = 0;
econuse.FX('71','38') = 0;
econuse.FX('71','39') = 0;
econuse.FX('71','40') = 0;
econuse.FX('71','41') = 0;
econuse.FX('71','42') = 0;
econuse.FX('71','43') = 0;
econuse.FX('71','44') = 0;
econuse.FX('71','45') = 0;
econuse.FX('71','46') = 0;
econuse.FX('71','47') = 0;
econuse.FX('71','48') = 0;
econuse.FX('71','49') = 0;
econuse.FX('71','50') = 0;
econuse.FX('71','51') = 0;
econuse.FX('71','52') = 0;
econuse.FX('71','53') = 0;
econuse.FX('71','54') = 0;
econuse.FX('71','55') = 0;
econuse.FX('71','56') = 0;
econuse.FX('71','57') = 0;
econuse.FX('71','58') = 0;
econuse.FX('71','59') = 0;
econuse.FX('71','60') = 0;
econuse.FX('71','61') = 0;
econuse.FX('71','62') = 0;
econuse.FX('71','63') = 0;
econuse.FX('71','64') = 0;
econuse.FX('71','65') = 0;
econuse.FX('71','66') = 0;
econuse.FX('71','67') = 0;
econuse.FX('71','68') = 0;
econuse.FX('71','69') = 0;
econuse.FX('71','70') = 0;
econuse.FX('71','71') = 0;
econuse.FX('71','72') = 0;
econuse.FX('71','73') = 0;
econuse.FX('71','74') = 0;
econuse.FX('72','1') = 7.700000e+000;
econuse.FX('72','2') = 2.370000e+001;
econuse.FX('72','3') = 1.030000e+001;
econuse.FX('72','4') = 7.500000e+000;
econuse.FX('72','5') = 1.490000e+001;
econuse.FX('72','6') = 0;
econuse.FX('72','7') = 1.200000e+000;
econuse.FX('72','8') = 1.110000e+001;
econuse.FX('72','9') = 6.000000e-001;
econuse.FX('72','10') = 1.503000e+002;
econuse.FX('72','11') = 7.990000e+001;
econuse.FX('72','12') = 1.840000e+001;
econuse.FX('72','13') = 5.550000e+001;
econuse.FX('72','14') = 5.000000e-001;
econuse.FX('72','15') = 7.500000e+000;
econuse.FX('72','16') = 0;
econuse.FX('72','17') = 1.000000e-001;
econuse.FX('72','18') = 1.000000e-001;
econuse.FX('72','19') = 1.428000e+002;
econuse.FX('72','20') = 2.297000e+002;
econuse.FX('72','21') = 4.250000e+001;
econuse.FX('72','22') = 0;
econuse.FX('72','23') = 0;
econuse.FX('72','24') = 2.920000e+001;
econuse.FX('72','25') = 2.000000e-001;
econuse.FX('72','26') = 0;
econuse.FX('72','27') = 2.250000e+001;
econuse.FX('72','28') = 4.810000e+001;
econuse.FX('72','29') = 3.328000e+002;
econuse.FX('72','30') = 0;
econuse.FX('72','31') = 1.952000e+002;
econuse.FX('72','32') = 2.000000e-001;
econuse.FX('72','33') = 1.000000e-001;
econuse.FX('72','34') = 2.000000e-001;
econuse.FX('72','35') = 2.970000e+001;
econuse.FX('72','36') = 1.277620e+004;
econuse.FX('72','37') = 0;
econuse.FX('72','38') = 6.000000e-001;
econuse.FX('72','39') = 7.065000e+002;
econuse.FX('72','40') = 7.303500e+003;
econuse.FX('72','41') = 1.114000e+002;
econuse.FX('72','42') = 2.153000e+002;
econuse.FX('72','43') = 4.156300e+003;
econuse.FX('72','44') = 4.427000e+002;
econuse.FX('72','45') = 1.814600e+003;
econuse.FX('72','46') = 2.537000e+002;
econuse.FX('72','47') = 6.812000e+002;
econuse.FX('72','48') = 508;
econuse.FX('72','49') = 3.108600e+003;
econuse.FX('72','50') = 1.649400e+003;
econuse.FX('72','51') = 2.922000e+002;
econuse.FX('72','52') = 3.000000e-001;
econuse.FX('72','53') = 4.620000e+001;
econuse.FX('72','54') = 1.889300e+003;
econuse.FX('72','55') = 4.069000e+002;
econuse.FX('72','56') = 227;
econuse.FX('72','57') = 3025;
econuse.FX('72','58') = 2.689000e+002;
econuse.FX('72','59') = 1350;
econuse.FX('72','60') = 2.335000e+002;
econuse.FX('72','61') = 8.154000e+002;
econuse.FX('72','62') = 2.156900e+003;
econuse.FX('72','63') = 2.012400e+003;
econuse.FX('72','64') = 2.538000e+002;
econuse.FX('72','65') = 2.667000e+002;
econuse.FX('72','66') = 1.392000e+002;
econuse.FX('72','67') = 5.202000e+002;
econuse.FX('72','68') = 1.345700e+003;
econuse.FX('72','69') = 4.991600e+003;
econuse.FX('72','70') = 2.712800e+003;
econuse.FX('72','71') = 2.016000e+002;
econuse.FX('72','72') = 4.800000e+000;
econuse.FX('72','73') = 4.254400e+003;
econuse.FX('72','74') = 5.450000e+001;
econuse.FX('73','1') = 0;
econuse.FX('73','2') = 0;
econuse.FX('73','3') = 0;
econuse.FX('73','4') = 0;
econuse.FX('73','5') = 0;
econuse.FX('73','6') = 0;
econuse.FX('73','7') = 0;
econuse.FX('73','8') = 0;
econuse.FX('73','9') = 0;
econuse.FX('73','10') = 0;
econuse.FX('73','11') = 0;
econuse.FX('73','12') = 0;
econuse.FX('73','13') = 0;
econuse.FX('73','14') = 0;
econuse.FX('73','15') = 0;
econuse.FX('73','16') = 0;
econuse.FX('73','17') = 0;
econuse.FX('73','18') = 0;
econuse.FX('73','19') = 0;
econuse.FX('73','20') = 0;
econuse.FX('73','21') = 0;
econuse.FX('73','22') = 0;
econuse.FX('73','23') = 0;
econuse.FX('73','24') = 0;
econuse.FX('73','25') = 0;
econuse.FX('73','26') = 0;
econuse.FX('73','27') = 0;
econuse.FX('73','28') = 0;
econuse.FX('73','29') = 0;
econuse.FX('73','30') = 0;
econuse.FX('73','31') = 0;
econuse.FX('73','32') = 0;
econuse.FX('73','33') = 0;
econuse.FX('73','34') = 0;
econuse.FX('73','35') = 0;
econuse.FX('73','36') = 0;
econuse.FX('73','37') = 0;
econuse.FX('73','38') = 0;
econuse.FX('73','39') = 0;
econuse.FX('73','40') = 0;
econuse.FX('73','41') = 0;
econuse.FX('73','42') = 0;
econuse.FX('73','43') = 0;
econuse.FX('73','44') = 0;
econuse.FX('73','45') = 0;
econuse.FX('73','46') = 0;
econuse.FX('73','47') = 0;
econuse.FX('73','48') = 0;
econuse.FX('73','49') = 0;
econuse.FX('73','50') = 0;
econuse.FX('73','51') = 0;
econuse.FX('73','52') = 0;
econuse.FX('73','53') = 0;
econuse.FX('73','54') = 0;
econuse.FX('73','55') = 0;
econuse.FX('73','56') = 0;
econuse.FX('73','57') = 0;
econuse.FX('73','58') = 0;
econuse.FX('73','59') = 0;
econuse.FX('73','60') = 0;
econuse.FX('73','61') = 0;
econuse.FX('73','62') = 0;
econuse.FX('73','63') = 0;
econuse.FX('73','64') = 0;
econuse.FX('73','65') = 0;
econuse.FX('73','66') = 0;
econuse.FX('73','67') = 0;
econuse.FX('73','68') = 0;
econuse.FX('73','69') = 0;
econuse.FX('73','70') = 0;
econuse.FX('73','71') = 0;
econuse.FX('73','72') = 0;
econuse.FX('73','73') = 0;
econuse.FX('73','74') = 0;
econuse.FX('74','1') = 0;
econuse.FX('74','2') = 0;
econuse.FX('74','3') = 0;
econuse.FX('74','4') = 0;
econuse.FX('74','5') = 6.300000e+000;
econuse.FX('74','6') = 0;
econuse.FX('74','7') = 0;
econuse.FX('74','8') = 0;
econuse.FX('74','9') = 0;
econuse.FX('74','10') = 3.500000e+000;
econuse.FX('74','11') = 9;
econuse.FX('74','12') = 0;
econuse.FX('74','13') = 0;
econuse.FX('74','14') = 2.478000e+002;
econuse.FX('74','15') = 2.910000e+001;
econuse.FX('74','16') = 1.060000e+001;
econuse.FX('74','17') = 26;
econuse.FX('74','18') = 7.360000e+001;
econuse.FX('74','19') = 2.210000e+001;
econuse.FX('74','20') = 4.990000e+001;
econuse.FX('74','21') = 6.030000e+001;
econuse.FX('74','22') = 1.900000e+000;
econuse.FX('74','23') = 3.600000e+000;
econuse.FX('74','24') = 1.692000e+002;
econuse.FX('74','25') = 8.360000e+001;
econuse.FX('74','26') = 3.740000e+001;
econuse.FX('74','27') = 1.077000e+002;
econuse.FX('74','28') = 6.780000e+001;
econuse.FX('74','29') = 3.670000e+001;
econuse.FX('74','30') = 3.200000e+000;
econuse.FX('74','31') = 5.820000e+001;
econuse.FX('74','32') = 9.140000e+001;
econuse.FX('74','33') = 8.600000e+000;
econuse.FX('74','34') = 4.250000e+001;
econuse.FX('74','35') = 2.770000e+001;
econuse.FX('74','36') = 4.463000e+002;
econuse.FX('74','37') = 0;
econuse.FX('74','38') = 0;
econuse.FX('74','39') = 0;
econuse.FX('74','40') = 24;
econuse.FX('74','41') = 0;
econuse.FX('74','42') = 0;
econuse.FX('74','43') = 12;
econuse.FX('74','44') = 3.870000e+001;
econuse.FX('74','45') = 2.920000e+001;
econuse.FX('74','46') = 1.160000e+001;
econuse.FX('74','47') = 4.121000e+002;
econuse.FX('74','48') = 1.240000e+001;
econuse.FX('74','49') = 5.460000e+001;
econuse.FX('74','50') = 3.320000e+001;
econuse.FX('74','51') = 1.260000e+001;
econuse.FX('74','52') = 0;
econuse.FX('74','53') = 3.597000e+002;
econuse.FX('74','54') = 2.352000e+002;
econuse.FX('74','55') = 1.346000e+002;
econuse.FX('74','56') = 2.230000e+001;
econuse.FX('74','57') = 4.258000e+002;
econuse.FX('74','58') = 6.480000e+001;
econuse.FX('74','59') = 2.984000e+002;
econuse.FX('74','60') = 1.275000e+002;
econuse.FX('74','61') = 3.340000e+001;
econuse.FX('74','62') = 4.782000e+002;
econuse.FX('74','63') = 3.480000e+001;
econuse.FX('74','64') = 1.282000e+002;
econuse.FX('74','65') = 1.057900e+003;
econuse.FX('74','66') = 2.190000e+001;
econuse.FX('74','67') = 6.690000e+001;
econuse.FX('74','68') = 2.537000e+002;
econuse.FX('74','69') = 4.051000e+002;
econuse.FX('74','70') = 4.884000e+002;
econuse.FX('74','71') = 5.048000e+002;
econuse.FX('74','72') = 2.098000e+002;
econuse.FX('74','73') = 2.401700e+003;
econuse.FX('74','74') = 2.054500e+003;


parameter
econenvint(m)
/1   4.5e+09
2   1.425451e+010
3   6.639370e+009
4   9.215745e+009
5   8.205019e+009
6   1.635278e+010
7   3.203422e+009
8   6.215562e+009
9   3.224004e+009
10   2.270000e+012
11   0
12   0
13   1.780000e+011
14   9.419450e+010
15   1.215527e+010
16   7.587078e+009
17   1.394302e+010
18   2.374330e+010
19   1.712260e+010
20   3.305595e+010
21   8.632767e+009
22   1557272236
23   1374520285
24   5.838044e+010
25   2.681190e+010
26   1.457591e+010
27   2.484118e+010
28   3.443484e+010
29   3.713293e+010
30   1.062076e+010
31   5.896771e+010
32   9.138432e+010
33   6.461268e+009
34   1.216063e+010
35   1.995896e+010
36   1.470000e+011
37   5.350297e+010
38   3.482925e+010
39   2.690000e+011
40   4.147715e+010
41   2.945384e+010
42   8.540205e+010
43   1187248509
44   0
45   1.657776e+010
46   3.068571e+009
47   4.375232e+008
48   1280887732
49   4.603062e+009
50   5.083014e+009
51   8.066103e+009
52   1569196846
53   1.454150e+010
54   1.498097e+010
55   3.663304e+009
56   3.746065e+009
57   1.679814e+010
58   7.860280e+009
59   7.875308e+009
60   9.475543e+008
61   2.528509e+009
62   9.267254e+009
63   6.783019e+009
64   2.265815e+009
65   1819031584
66   9.601176e+008
67   1343165909
68   1912902570
69   8.355322e+009
70   9.737937e+009
71   2.585784e+010
72   4.607815e+008
73   0
74   9.508369e+009  /





vcmake(i,jj)
/1.1   4.153299e+02
2.2   1.477750e+02
3.3   1.721067e+02
4.4   1.149871e+03
5.5   4.753438e+00
6.6   3.990540e-01
7.7   2.540000e+01
8.8   9.071850e+02
9.9   1
10.10   1
11.11   1
12.12   1
13.13   1
14.14   1
15.15   1
16.16   3.912865e+01/

vcuse(i,jj)
/1.7   4.153299e+02
2.7   1.477750e+02
3.7   1.721067e+02
4.7   1.149871e+03
5.7   4.753438e+00
6.7   3.990540e-01
7.8   9.071850e+02
/

vcupstcut(m,i)
/1.7   4.619713e-01
12.1   4.590833e-05
12.2   3.155519e-05
12.3   5.844221e-06
12.4   5.043433e-04
12.5   3.039065e-08
12.6   2.551313e-09
12.7   2.920000e-03
12.9   3.431098e-11
12.10   8.795743e-11
12.11   1.008477e-08
12.15   1.743535e-05 /;

variable
vcupstcutdisagg(m,i);


parameter
vcenvint(i)
/1   1.690444e+00
2   2.484934e-01
3   6.174315e-01
4   1.566693e-02
5   9.523611e-02
6   9.342907e-03
7   8.924474e-01
8   5.029716e+01
9   1.041687e-05
10   1.627194e-06
11   1.634466e-04
12   1.468647e+00
13   6.550298e+00
14   2.520878e+00
15   1.116197e+00
16   1.345718e-01 / ;


table vcpF1(m,i)
          1        2        3        4        5        6        7        8        9        10      11       12       13       14       15        16
1         0        0        0        0        0        0        1        0        0        0        0        0        0        0        0        0
2         0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0
3         0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0
4         0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0
5         0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0
6         0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0
7         0        0        0        0        0        0        0        0        0        1        0        0        0        0        0        0
8         0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0
9         0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0
10        0        0        0        0        0        0        0        0        0        0        1        0        0        0        0        0
11        0        0        0        0        0        0        0        0        1        0        0        0        0        0        0        0
12        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0
13        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0
14        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0
15        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0
16        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0
17        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0
18        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0
19        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0
20        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0
21        0        0        0        0        0        0        0        0        0        0        0        1        1        1        1        0
22        1        1        1        1        0        0        0        0        0        0        0        0        0        0        0        0
23        0        0        0        0        1        1        0        0        0        0        0        0        0        0        0        0
24        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0
25        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0
26        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0
27        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0
28        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0
29        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0
30        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0
31        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0
32        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0
33        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0
34        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0
35        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0
36        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0
37        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0
38        0        0        0        0        0        0        0        1        0        0        0        0        0        0        0        0
39        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0
40        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        1
41        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0
42        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0
43        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0
44        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0
45        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0
46        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0
47        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0
48        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0
49        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0
50        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0
51        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0
52        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0
53        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0
54        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0
55        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0
56        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0
57        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0
58        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0
59        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0
60        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0
61        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0
62        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0
63        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0
64        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0
65        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0
66        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0
67        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0
68        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0
69        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0
70        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0
71        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0
72        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0
73        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0
74        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0  ;


variable vcpF(i,m);


table vcpP1(i,m)
         1        2        3        4        5        6        7        8        9        10       11      12       13        14       15      16       17       18        19      20        21      22        23      24       25       26       27       28       29       30       31       32       33       34       35       36       37       38       39       40       41       42       43       44       45       46        47       48      49       50       51       52        53       54      55       56        57      58       59       60       61        62      63        64      65        66      67       68       69       70       71       72        73      74
1        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        1        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0
2        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        1        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0
3        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        1        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0
4        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        1        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0
5        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        1        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0
6        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        1        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0
7        1        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0
8        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        1        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0
9        0        0        0        0        0        0        0        0        0        0        1        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        1        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0
10       0        0        0        0        0        0        1        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0
11       0        0        0        0        0        0        0        0        0        1        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0
12       0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        1        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0
13       0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        1        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0
14       0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        1        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0
15       0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        1        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0
16       0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        1        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0    ;



variable vcpP(m,i);





TABLE vcmakeusd2(i,jj)
            1               2                3              4               5               6               7                8               9             10               11               12              13              14             15              16
1        8.82E-08        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00
2        0.00E+00        3.70E-08        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00
3        0.00E+00        0.00E+00        3.11E-08        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00
4        0.00E+00        0.00E+00        0.00E+00        1.38E-07        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00
5        0.00E+00        0.00E+00        0.00E+00        0.00E+00        9.53E-08        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00
6        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        2.58E-08        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00
7        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        7.48E-08        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00
8        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        3.71E-06        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00
9        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        3.88E-12        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00
10        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        1.11E-12        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00
11        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        1.33E-11        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00
12        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        2.75E-06        0.00E+00        0.00E+00        0.00E+00        0.00E+00
13        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        2.75E-06        0.00E+00        0.00E+00        0.00E+00
14        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        5.50E-06        0.00E+00        0.00E+00
15        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        1.10E-07        0.00E+00
16        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        1.47E-05 ;


table

vcuseusd2(i,jj)

            1                 2             3               4               5               6               7               8                9               10            11               12              13             14               15              16
1        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        8.82E-08        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00
2        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        3.70E-08        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00
3        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        3.11E-08        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00
4        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        1.38E-07        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00
5        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        9.53E-08        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00
6        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        2.58E-08        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00
7        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        3.71E-06        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00
8        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00
9        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00
10        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00
11        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00
12        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00
13        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00
14        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00
15        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00
16        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00        0.00E+00     ;


parameters

eqeconpF(m)
/21  1
/

eqeconpP(m)
/21  1
/ ;

variables
eqvcupstcut(i)
eqvcdowncut(i)
;


equations
eq17,eq18,eq19,eq20,eq21,eq22,eq23,eq24;

eqvcdowncut.fx('16')= 3.912865e+01 ;

eqvcdowncut.fx('1')=0;
eqvcdowncut.fx('2')=0;
eqvcdowncut.fx('3')=0;
eqvcdowncut.fx('4')=0;
eqvcdowncut.fx('5')=0;
eqvcdowncut.fx('6')=0;
eqvcdowncut.fx('7')=0;
eqvcdowncut.fx('8')=0;
eqvcdowncut.fx('9')=0;
eqvcdowncut.fx('10')=0;
eqvcdowncut.fx('11')=0;
eqvcdowncut.fx('12')=0;
eqvcdowncut.fx('13')=0;
eqvcdowncut.fx('14')=0;
eqvcdowncut.fx('15')=0;


eq17..  eqvcupstcut('12') =E=fc('Prot','Src6','Sac1');
*amylase NEED TO BE CHANGED
eq18..  eqvcupstcut('8') =E=18;
* Fixed corn input
eq19..  eqvcupstcut('9') =E=0.83352*energy_objective;
* Natural gas
eq20..  eqvcupstcut('10') =E=0.094*energy_objective;
*Coal
eq21..  eqvcupstcut('11') =E=0.07248*energy_objective;
* Electricity
eq22..  eqvcupstcut('13') =E=fc('Prot','Src5','Liq1');
*gluco-amylase NNNEEEED TO BE CHANGGEEEDDDDD
eq23..  eqvcupstcut('14') =E=0.004977;
*Yeast
eq24..  eqvcupstcut('15') =E=UREA;
*Urea     CHANNNGEEEEEE

eqvcupstcut.fx('1')=0;
eqvcupstcut.fx('2')=0;
eqvcupstcut.fx('3')=0;
eqvcupstcut.fx('4')=0;
eqvcupstcut.fx('5')=0;
eqvcupstcut.fx('6')=0;
eqvcupstcut.fx('7')=0;
eqvcupstcut.fx('16')=0;


scalar
equse /0/
equseusd /0/
;

variables
eqmake,eqmakeusd,eqenvint;

equations
eq27,eq28,eq29,eq30(i,jj),eq31(i,jj);


eq27.. eqmake =E= ETHANOL;
eq28.. eqmakeusd =E= 0.375/1000000.0*ETHANOL;


equse = 0.0;
equseusd = equse;
eq29.. eqenvint =E= (energy_objective*5.58001118e-05);

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
equat2 ..    p2pf('2') =E= lstar('2','1')*s('1')+lstar('2','2')*s('2')+lstar('2','3')*s('3')+lstar('2','4')*s('4')+lstar('2','5')*s('5')+lstar('2','6')*s('6')+lstar('2','7')*s('7')+lstar('2','8')*s('8')+lstar('2','9')*s('9')+lstar('2','10')*s('10')+lstar('2','11')*s('11')+lstar('2','12')*s('12')+lstar('2','13')*s('13')+lstar('2','14')*s('14')+lstar('2','15')*s('15')+lstar('2','16')*s('16')+lstar('2','17')*s('17')+lstar('2','18')*s('18')+lstar('2','19')*s('19')+lstar('2','20')*s('20')+lstar('2','21')*s('21')+lstar('2','22')*s('22')+lstar('2','23')*s('23')+lstar('2','24')*s('24')+lstar('2','25')*s('25')+lstar('2','26')*s('26')+lstar('2','27')*s('27')+lstar('2','28')*s('28')+lstar('2','29')*s('29')+lstar('2','30')*s('30')+lstar('2','31')*s('31')+lstar('2','32')*s('32')+lstar('2','33')*s('33')+lstar('2','34')*s('34')+lstar('2','35')*s('35')+lstar('2','36')*s('36')+lstar('2','37')*s('37')+lstar('2','38')*s('38')+lstar('2','39')*s('39')+lstar('2','40')*s('40')+lstar('2','41')*s('41')+lstar('2','42')*s('42')+lstar('2','43')*s('43')+lstar('2','44')*s('44')+lstar('2','45')*s('45')+lstar('2','46')*s('46')+lstar('2','47')*s('47')+lstar('2','48')*s('48')+lstar('2','49')*s('49')+lstar('2','50')*s('50')+lstar('2','51')*s('51')+lstar('2','52')*s('52')+lstar('2','53')*s('53')+lstar('2','54')*s('54')+lstar('2','55')*s('55')+lstar('2','56')*s('56')+lstar('2','57')*s('57')+lstar('2','58')*s('58')+lstar('2','59')*s('59')+lstar('2','60')*s('60')+lstar('2','61')*s('61')+lstar('2','62')*s('62')+lstar('2','63')*s('63')+lstar('2','64')*s('64')+lstar('2','65')*s('65')+lstar('2','66')*s('66')+lstar('2','67')*s('67')+lstar('2','68')*s('68')+lstar('2','69')*s('69')+lstar('2','70')*s('70')+lstar('2','71')*s('71')+lstar('2','72')*s('72')+lstar('2','73')*s('73')+lstar('2','74')*s('74')-vcupstcut('2','1')*s('75')-vcupstcut('2','2')*s('76')-vcupstcut('2','3')*s('77')-vcupstcut('2','4')*s('78')-vcupstcut('2','5')*s('79')-vcupstcut('2','6')*s('80')-vcupstcut('2','7')*s('81')-vcupstcut('2','8')*s('82')-vcupstcut('2','9')*s('83')-vcupstcut('2','10')*s('84')-vcupstcut('2','11')*s('85')-vcupstcut('2','12')*s('86')-vcupstcut('2','13')*s('87')-vcupstcut('2','14')*s('88')-vcupstcut('2','15')*s('89')-vcupstcut('2','16')*s('90')-eqeconupstcut('2')*s('91');
equat3 ..    p2pf('3') =E= lstar('3','1')*s('1')+lstar('3','2')*s('2')+lstar('3','3')*s('3')+lstar('3','4')*s('4')+lstar('3','5')*s('5')+lstar('3','6')*s('6')+lstar('3','7')*s('7')+lstar('3','8')*s('8')+lstar('3','9')*s('9')+lstar('3','10')*s('10')+lstar('3','11')*s('11')+lstar('3','12')*s('12')+lstar('3','13')*s('13')+lstar('3','14')*s('14')+lstar('3','15')*s('15')+lstar('3','16')*s('16')+lstar('3','17')*s('17')+lstar('3','18')*s('18')+lstar('3','19')*s('19')+lstar('3','20')*s('20')+lstar('3','21')*s('21')+lstar('3','22')*s('22')+lstar('3','23')*s('23')+lstar('3','24')*s('24')+lstar('3','25')*s('25')+lstar('3','26')*s('26')+lstar('3','27')*s('27')+lstar('3','28')*s('28')+lstar('3','29')*s('29')+lstar('3','30')*s('30')+lstar('3','31')*s('31')+lstar('3','32')*s('32')+lstar('3','33')*s('33')+lstar('3','34')*s('34')+lstar('3','35')*s('35')+lstar('3','36')*s('36')+lstar('3','37')*s('37')+lstar('3','38')*s('38')+lstar('3','39')*s('39')+lstar('3','40')*s('40')+lstar('3','41')*s('41')+lstar('3','42')*s('42')+lstar('3','43')*s('43')+lstar('3','44')*s('44')+lstar('3','45')*s('45')+lstar('3','46')*s('46')+lstar('3','47')*s('47')+lstar('3','48')*s('48')+lstar('3','49')*s('49')+lstar('3','50')*s('50')+lstar('3','51')*s('51')+lstar('3','52')*s('52')+lstar('3','53')*s('53')+lstar('3','54')*s('54')+lstar('3','55')*s('55')+lstar('3','56')*s('56')+lstar('3','57')*s('57')+lstar('3','58')*s('58')+lstar('3','59')*s('59')+lstar('3','60')*s('60')+lstar('3','61')*s('61')+lstar('3','62')*s('62')+lstar('3','63')*s('63')+lstar('3','64')*s('64')+lstar('3','65')*s('65')+lstar('3','66')*s('66')+lstar('3','67')*s('67')+lstar('3','68')*s('68')+lstar('3','69')*s('69')+lstar('3','70')*s('70')+lstar('3','71')*s('71')+lstar('3','72')*s('72')+lstar('3','73')*s('73')+lstar('3','74')*s('74')-vcupstcut('3','1')*s('75')-vcupstcut('3','2')*s('76')-vcupstcut('3','3')*s('77')-vcupstcut('3','4')*s('78')-vcupstcut('3','5')*s('79')-vcupstcut('3','6')*s('80')-vcupstcut('3','7')*s('81')-vcupstcut('3','8')*s('82')-vcupstcut('3','9')*s('83')-vcupstcut('3','10')*s('84')-vcupstcut('3','11')*s('85')-vcupstcut('3','12')*s('86')-vcupstcut('3','13')*s('87')-vcupstcut('3','14')*s('88')-vcupstcut('3','15')*s('89')-vcupstcut('3','16')*s('90')-eqeconupstcut('3')*s('91');
equat4 ..    p2pf('4') =E= lstar('4','1')*s('1')+lstar('4','2')*s('2')+lstar('4','3')*s('3')+lstar('4','4')*s('4')+lstar('4','5')*s('5')+lstar('4','6')*s('6')+lstar('4','7')*s('7')+lstar('4','8')*s('8')+lstar('4','9')*s('9')+lstar('4','10')*s('10')+lstar('4','11')*s('11')+lstar('4','12')*s('12')+lstar('4','13')*s('13')+lstar('4','14')*s('14')+lstar('4','15')*s('15')+lstar('4','16')*s('16')+lstar('4','17')*s('17')+lstar('4','18')*s('18')+lstar('4','19')*s('19')+lstar('4','20')*s('20')+lstar('4','21')*s('21')+lstar('4','22')*s('22')+lstar('4','23')*s('23')+lstar('4','24')*s('24')+lstar('4','25')*s('25')+lstar('4','26')*s('26')+lstar('4','27')*s('27')+lstar('4','28')*s('28')+lstar('4','29')*s('29')+lstar('4','30')*s('30')+lstar('4','31')*s('31')+lstar('4','32')*s('32')+lstar('4','33')*s('33')+lstar('4','34')*s('34')+lstar('4','35')*s('35')+lstar('4','36')*s('36')+lstar('4','37')*s('37')+lstar('4','38')*s('38')+lstar('4','39')*s('39')+lstar('4','40')*s('40')+lstar('4','41')*s('41')+lstar('4','42')*s('42')+lstar('4','43')*s('43')+lstar('4','44')*s('44')+lstar('4','45')*s('45')+lstar('4','46')*s('46')+lstar('4','47')*s('47')+lstar('4','48')*s('48')+lstar('4','49')*s('49')+lstar('4','50')*s('50')+lstar('4','51')*s('51')+lstar('4','52')*s('52')+lstar('4','53')*s('53')+lstar('4','54')*s('54')+lstar('4','55')*s('55')+lstar('4','56')*s('56')+lstar('4','57')*s('57')+lstar('4','58')*s('58')+lstar('4','59')*s('59')+lstar('4','60')*s('60')+lstar('4','61')*s('61')+lstar('4','62')*s('62')+lstar('4','63')*s('63')+lstar('4','64')*s('64')+lstar('4','65')*s('65')+lstar('4','66')*s('66')+lstar('4','67')*s('67')+lstar('4','68')*s('68')+lstar('4','69')*s('69')+lstar('4','70')*s('70')+lstar('4','71')*s('71')+lstar('4','72')*s('72')+lstar('4','73')*s('73')+lstar('4','74')*s('74')-vcupstcut('4','1')*s('75')-vcupstcut('4','2')*s('76')-vcupstcut('4','3')*s('77')-vcupstcut('4','4')*s('78')-vcupstcut('4','5')*s('79')-vcupstcut('4','6')*s('80')-vcupstcut('4','7')*s('81')-vcupstcut('4','8')*s('82')-vcupstcut('4','9')*s('83')-vcupstcut('4','10')*s('84')-vcupstcut('4','11')*s('85')-vcupstcut('4','12')*s('86')-vcupstcut('4','13')*s('87')-vcupstcut('4','14')*s('88')-vcupstcut('4','15')*s('89')-vcupstcut('4','16')*s('90')-eqeconupstcut('4')*s('91');
equat5 ..    p2pf('5') =E= lstar('5','1')*s('1')+lstar('5','2')*s('2')+lstar('5','3')*s('3')+lstar('5','4')*s('4')+lstar('5','5')*s('5')+lstar('5','6')*s('6')+lstar('5','7')*s('7')+lstar('5','8')*s('8')+lstar('5','9')*s('9')+lstar('5','10')*s('10')+lstar('5','11')*s('11')+lstar('5','12')*s('12')+lstar('5','13')*s('13')+lstar('5','14')*s('14')+lstar('5','15')*s('15')+lstar('5','16')*s('16')+lstar('5','17')*s('17')+lstar('5','18')*s('18')+lstar('5','19')*s('19')+lstar('5','20')*s('20')+lstar('5','21')*s('21')+lstar('5','22')*s('22')+lstar('5','23')*s('23')+lstar('5','24')*s('24')+lstar('5','25')*s('25')+lstar('5','26')*s('26')+lstar('5','27')*s('27')+lstar('5','28')*s('28')+lstar('5','29')*s('29')+lstar('5','30')*s('30')+lstar('5','31')*s('31')+lstar('5','32')*s('32')+lstar('5','33')*s('33')+lstar('5','34')*s('34')+lstar('5','35')*s('35')+lstar('5','36')*s('36')+lstar('5','37')*s('37')+lstar('5','38')*s('38')+lstar('5','39')*s('39')+lstar('5','40')*s('40')+lstar('5','41')*s('41')+lstar('5','42')*s('42')+lstar('5','43')*s('43')+lstar('5','44')*s('44')+lstar('5','45')*s('45')+lstar('5','46')*s('46')+lstar('5','47')*s('47')+lstar('5','48')*s('48')+lstar('5','49')*s('49')+lstar('5','50')*s('50')+lstar('5','51')*s('51')+lstar('5','52')*s('52')+lstar('5','53')*s('53')+lstar('5','54')*s('54')+lstar('5','55')*s('55')+lstar('5','56')*s('56')+lstar('5','57')*s('57')+lstar('5','58')*s('58')+lstar('5','59')*s('59')+lstar('5','60')*s('60')+lstar('5','61')*s('61')+lstar('5','62')*s('62')+lstar('5','63')*s('63')+lstar('5','64')*s('64')+lstar('5','65')*s('65')+lstar('5','66')*s('66')+lstar('5','67')*s('67')+lstar('5','68')*s('68')+lstar('5','69')*s('69')+lstar('5','70')*s('70')+lstar('5','71')*s('71')+lstar('5','72')*s('72')+lstar('5','73')*s('73')+lstar('5','74')*s('74')-vcupstcut('5','1')*s('75')-vcupstcut('5','2')*s('76')-vcupstcut('5','3')*s('77')-vcupstcut('5','4')*s('78')-vcupstcut('5','5')*s('79')-vcupstcut('5','6')*s('80')-vcupstcut('5','7')*s('81')-vcupstcut('5','8')*s('82')-vcupstcut('5','9')*s('83')-vcupstcut('5','10')*s('84')-vcupstcut('5','11')*s('85')-vcupstcut('5','12')*s('86')-vcupstcut('5','13')*s('87')-vcupstcut('5','14')*s('88')-vcupstcut('5','15')*s('89')-vcupstcut('5','16')*s('90')-eqeconupstcut('5')*s('91');
equat6 ..    p2pf('6') =E= lstar('6','1')*s('1')+lstar('6','2')*s('2')+lstar('6','3')*s('3')+lstar('6','4')*s('4')+lstar('6','5')*s('5')+lstar('6','6')*s('6')+lstar('6','7')*s('7')+lstar('6','8')*s('8')+lstar('6','9')*s('9')+lstar('6','10')*s('10')+lstar('6','11')*s('11')+lstar('6','12')*s('12')+lstar('6','13')*s('13')+lstar('6','14')*s('14')+lstar('6','15')*s('15')+lstar('6','16')*s('16')+lstar('6','17')*s('17')+lstar('6','18')*s('18')+lstar('6','19')*s('19')+lstar('6','20')*s('20')+lstar('6','21')*s('21')+lstar('6','22')*s('22')+lstar('6','23')*s('23')+lstar('6','24')*s('24')+lstar('6','25')*s('25')+lstar('6','26')*s('26')+lstar('6','27')*s('27')+lstar('6','28')*s('28')+lstar('6','29')*s('29')+lstar('6','30')*s('30')+lstar('6','31')*s('31')+lstar('6','32')*s('32')+lstar('6','33')*s('33')+lstar('6','34')*s('34')+lstar('6','35')*s('35')+lstar('6','36')*s('36')+lstar('6','37')*s('37')+lstar('6','38')*s('38')+lstar('6','39')*s('39')+lstar('6','40')*s('40')+lstar('6','41')*s('41')+lstar('6','42')*s('42')+lstar('6','43')*s('43')+lstar('6','44')*s('44')+lstar('6','45')*s('45')+lstar('6','46')*s('46')+lstar('6','47')*s('47')+lstar('6','48')*s('48')+lstar('6','49')*s('49')+lstar('6','50')*s('50')+lstar('6','51')*s('51')+lstar('6','52')*s('52')+lstar('6','53')*s('53')+lstar('6','54')*s('54')+lstar('6','55')*s('55')+lstar('6','56')*s('56')+lstar('6','57')*s('57')+lstar('6','58')*s('58')+lstar('6','59')*s('59')+lstar('6','60')*s('60')+lstar('6','61')*s('61')+lstar('6','62')*s('62')+lstar('6','63')*s('63')+lstar('6','64')*s('64')+lstar('6','65')*s('65')+lstar('6','66')*s('66')+lstar('6','67')*s('67')+lstar('6','68')*s('68')+lstar('6','69')*s('69')+lstar('6','70')*s('70')+lstar('6','71')*s('71')+lstar('6','72')*s('72')+lstar('6','73')*s('73')+lstar('6','74')*s('74')-vcupstcut('6','1')*s('75')-vcupstcut('6','2')*s('76')-vcupstcut('6','3')*s('77')-vcupstcut('6','4')*s('78')-vcupstcut('6','5')*s('79')-vcupstcut('6','6')*s('80')-vcupstcut('6','7')*s('81')-vcupstcut('6','8')*s('82')-vcupstcut('6','9')*s('83')-vcupstcut('6','10')*s('84')-vcupstcut('6','11')*s('85')-vcupstcut('6','12')*s('86')-vcupstcut('6','13')*s('87')-vcupstcut('6','14')*s('88')-vcupstcut('6','15')*s('89')-vcupstcut('6','16')*s('90')-eqeconupstcut('6')*s('91');
equat7 ..    p2pf('7') =E= lstar('7','1')*s('1')+lstar('7','2')*s('2')+lstar('7','3')*s('3')+lstar('7','4')*s('4')+lstar('7','5')*s('5')+lstar('7','6')*s('6')+lstar('7','7')*s('7')+lstar('7','8')*s('8')+lstar('7','9')*s('9')+lstar('7','10')*s('10')+lstar('7','11')*s('11')+lstar('7','12')*s('12')+lstar('7','13')*s('13')+lstar('7','14')*s('14')+lstar('7','15')*s('15')+lstar('7','16')*s('16')+lstar('7','17')*s('17')+lstar('7','18')*s('18')+lstar('7','19')*s('19')+lstar('7','20')*s('20')+lstar('7','21')*s('21')+lstar('7','22')*s('22')+lstar('7','23')*s('23')+lstar('7','24')*s('24')+lstar('7','25')*s('25')+lstar('7','26')*s('26')+lstar('7','27')*s('27')+lstar('7','28')*s('28')+lstar('7','29')*s('29')+lstar('7','30')*s('30')+lstar('7','31')*s('31')+lstar('7','32')*s('32')+lstar('7','33')*s('33')+lstar('7','34')*s('34')+lstar('7','35')*s('35')+lstar('7','36')*s('36')+lstar('7','37')*s('37')+lstar('7','38')*s('38')+lstar('7','39')*s('39')+lstar('7','40')*s('40')+lstar('7','41')*s('41')+lstar('7','42')*s('42')+lstar('7','43')*s('43')+lstar('7','44')*s('44')+lstar('7','45')*s('45')+lstar('7','46')*s('46')+lstar('7','47')*s('47')+lstar('7','48')*s('48')+lstar('7','49')*s('49')+lstar('7','50')*s('50')+lstar('7','51')*s('51')+lstar('7','52')*s('52')+lstar('7','53')*s('53')+lstar('7','54')*s('54')+lstar('7','55')*s('55')+lstar('7','56')*s('56')+lstar('7','57')*s('57')+lstar('7','58')*s('58')+lstar('7','59')*s('59')+lstar('7','60')*s('60')+lstar('7','61')*s('61')+lstar('7','62')*s('62')+lstar('7','63')*s('63')+lstar('7','64')*s('64')+lstar('7','65')*s('65')+lstar('7','66')*s('66')+lstar('7','67')*s('67')+lstar('7','68')*s('68')+lstar('7','69')*s('69')+lstar('7','70')*s('70')+lstar('7','71')*s('71')+lstar('7','72')*s('72')+lstar('7','73')*s('73')+lstar('7','74')*s('74')-vcupstcut('7','1')*s('75')-vcupstcut('7','2')*s('76')-vcupstcut('7','3')*s('77')-vcupstcut('7','4')*s('78')-vcupstcut('7','5')*s('79')-vcupstcut('7','6')*s('80')-vcupstcut('7','7')*s('81')-vcupstcut('7','8')*s('82')-vcupstcut('7','9')*s('83')-vcupstcut('7','10')*s('84')-vcupstcut('7','11')*s('85')-vcupstcut('7','12')*s('86')-vcupstcut('7','13')*s('87')-vcupstcut('7','14')*s('88')-vcupstcut('7','15')*s('89')-vcupstcut('7','16')*s('90')-eqeconupstcut('7')*s('91');
equat8 ..    p2pf('8') =E= lstar('8','1')*s('1')+lstar('8','2')*s('2')+lstar('8','3')*s('3')+lstar('8','4')*s('4')+lstar('8','5')*s('5')+lstar('8','6')*s('6')+lstar('8','7')*s('7')+lstar('8','8')*s('8')+lstar('8','9')*s('9')+lstar('8','10')*s('10')+lstar('8','11')*s('11')+lstar('8','12')*s('12')+lstar('8','13')*s('13')+lstar('8','14')*s('14')+lstar('8','15')*s('15')+lstar('8','16')*s('16')+lstar('8','17')*s('17')+lstar('8','18')*s('18')+lstar('8','19')*s('19')+lstar('8','20')*s('20')+lstar('8','21')*s('21')+lstar('8','22')*s('22')+lstar('8','23')*s('23')+lstar('8','24')*s('24')+lstar('8','25')*s('25')+lstar('8','26')*s('26')+lstar('8','27')*s('27')+lstar('8','28')*s('28')+lstar('8','29')*s('29')+lstar('8','30')*s('30')+lstar('8','31')*s('31')+lstar('8','32')*s('32')+lstar('8','33')*s('33')+lstar('8','34')*s('34')+lstar('8','35')*s('35')+lstar('8','36')*s('36')+lstar('8','37')*s('37')+lstar('8','38')*s('38')+lstar('8','39')*s('39')+lstar('8','40')*s('40')+lstar('8','41')*s('41')+lstar('8','42')*s('42')+lstar('8','43')*s('43')+lstar('8','44')*s('44')+lstar('8','45')*s('45')+lstar('8','46')*s('46')+lstar('8','47')*s('47')+lstar('8','48')*s('48')+lstar('8','49')*s('49')+lstar('8','50')*s('50')+lstar('8','51')*s('51')+lstar('8','52')*s('52')+lstar('8','53')*s('53')+lstar('8','54')*s('54')+lstar('8','55')*s('55')+lstar('8','56')*s('56')+lstar('8','57')*s('57')+lstar('8','58')*s('58')+lstar('8','59')*s('59')+lstar('8','60')*s('60')+lstar('8','61')*s('61')+lstar('8','62')*s('62')+lstar('8','63')*s('63')+lstar('8','64')*s('64')+lstar('8','65')*s('65')+lstar('8','66')*s('66')+lstar('8','67')*s('67')+lstar('8','68')*s('68')+lstar('8','69')*s('69')+lstar('8','70')*s('70')+lstar('8','71')*s('71')+lstar('8','72')*s('72')+lstar('8','73')*s('73')+lstar('8','74')*s('74')-vcupstcut('8','1')*s('75')-vcupstcut('8','2')*s('76')-vcupstcut('8','3')*s('77')-vcupstcut('8','4')*s('78')-vcupstcut('8','5')*s('79')-vcupstcut('8','6')*s('80')-vcupstcut('8','7')*s('81')-vcupstcut('8','8')*s('82')-vcupstcut('8','9')*s('83')-vcupstcut('8','10')*s('84')-vcupstcut('8','11')*s('85')-vcupstcut('8','12')*s('86')-vcupstcut('8','13')*s('87')-vcupstcut('8','14')*s('88')-vcupstcut('8','15')*s('89')-vcupstcut('8','16')*s('90')-eqeconupstcut('8')*s('91');
equat9 ..    p2pf('9') =E= lstar('9','1')*s('1')+lstar('9','2')*s('2')+lstar('9','3')*s('3')+lstar('9','4')*s('4')+lstar('9','5')*s('5')+lstar('9','6')*s('6')+lstar('9','7')*s('7')+lstar('9','8')*s('8')+lstar('9','9')*s('9')+lstar('9','10')*s('10')+lstar('9','11')*s('11')+lstar('9','12')*s('12')+lstar('9','13')*s('13')+lstar('9','14')*s('14')+lstar('9','15')*s('15')+lstar('9','16')*s('16')+lstar('9','17')*s('17')+lstar('9','18')*s('18')+lstar('9','19')*s('19')+lstar('9','20')*s('20')+lstar('9','21')*s('21')+lstar('9','22')*s('22')+lstar('9','23')*s('23')+lstar('9','24')*s('24')+lstar('9','25')*s('25')+lstar('9','26')*s('26')+lstar('9','27')*s('27')+lstar('9','28')*s('28')+lstar('9','29')*s('29')+lstar('9','30')*s('30')+lstar('9','31')*s('31')+lstar('9','32')*s('32')+lstar('9','33')*s('33')+lstar('9','34')*s('34')+lstar('9','35')*s('35')+lstar('9','36')*s('36')+lstar('9','37')*s('37')+lstar('9','38')*s('38')+lstar('9','39')*s('39')+lstar('9','40')*s('40')+lstar('9','41')*s('41')+lstar('9','42')*s('42')+lstar('9','43')*s('43')+lstar('9','44')*s('44')+lstar('9','45')*s('45')+lstar('9','46')*s('46')+lstar('9','47')*s('47')+lstar('9','48')*s('48')+lstar('9','49')*s('49')+lstar('9','50')*s('50')+lstar('9','51')*s('51')+lstar('9','52')*s('52')+lstar('9','53')*s('53')+lstar('9','54')*s('54')+lstar('9','55')*s('55')+lstar('9','56')*s('56')+lstar('9','57')*s('57')+lstar('9','58')*s('58')+lstar('9','59')*s('59')+lstar('9','60')*s('60')+lstar('9','61')*s('61')+lstar('9','62')*s('62')+lstar('9','63')*s('63')+lstar('9','64')*s('64')+lstar('9','65')*s('65')+lstar('9','66')*s('66')+lstar('9','67')*s('67')+lstar('9','68')*s('68')+lstar('9','69')*s('69')+lstar('9','70')*s('70')+lstar('9','71')*s('71')+lstar('9','72')*s('72')+lstar('9','73')*s('73')+lstar('9','74')*s('74')-vcupstcut('9','1')*s('75')-vcupstcut('9','2')*s('76')-vcupstcut('9','3')*s('77')-vcupstcut('9','4')*s('78')-vcupstcut('9','5')*s('79')-vcupstcut('9','6')*s('80')-vcupstcut('9','7')*s('81')-vcupstcut('9','8')*s('82')-vcupstcut('9','9')*s('83')-vcupstcut('9','10')*s('84')-vcupstcut('9','11')*s('85')-vcupstcut('9','12')*s('86')-vcupstcut('9','13')*s('87')-vcupstcut('9','14')*s('88')-vcupstcut('9','15')*s('89')-vcupstcut('9','16')*s('90')-eqeconupstcut('9')*s('91');
equat10 ..    p2pf('10') =E= lstar('10','1')*s('1')+lstar('10','2')*s('2')+lstar('10','3')*s('3')+lstar('10','4')*s('4')+lstar('10','5')*s('5')+lstar('10','6')*s('6')+lstar('10','7')*s('7')+lstar('10','8')*s('8')+lstar('10','9')*s('9')+lstar('10','10')*s('10')+lstar('10','11')*s('11')+lstar('10','12')*s('12')+lstar('10','13')*s('13')+lstar('10','14')*s('14')+lstar('10','15')*s('15')+lstar('10','16')*s('16')+lstar('10','17')*s('17')+lstar('10','18')*s('18')+lstar('10','19')*s('19')+lstar('10','20')*s('20')+lstar('10','21')*s('21')+lstar('10','22')*s('22')+lstar('10','23')*s('23')+lstar('10','24')*s('24')+lstar('10','25')*s('25')+lstar('10','26')*s('26')+lstar('10','27')*s('27')+lstar('10','28')*s('28')+lstar('10','29')*s('29')+lstar('10','30')*s('30')+lstar('10','31')*s('31')+lstar('10','32')*s('32')+lstar('10','33')*s('33')+lstar('10','34')*s('34')+lstar('10','35')*s('35')+lstar('10','36')*s('36')+lstar('10','37')*s('37')+lstar('10','38')*s('38')+lstar('10','39')*s('39')+lstar('10','40')*s('40')+lstar('10','41')*s('41')+lstar('10','42')*s('42')+lstar('10','43')*s('43')+lstar('10','44')*s('44')+lstar('10','45')*s('45')+lstar('10','46')*s('46')+lstar('10','47')*s('47')+lstar('10','48')*s('48')+lstar('10','49')*s('49')+lstar('10','50')*s('50')+lstar('10','51')*s('51')+lstar('10','52')*s('52')+lstar('10','53')*s('53')+lstar('10','54')*s('54')+lstar('10','55')*s('55')+lstar('10','56')*s('56')+lstar('10','57')*s('57')+lstar('10','58')*s('58')+lstar('10','59')*s('59')+lstar('10','60')*s('60')+lstar('10','61')*s('61')+lstar('10','62')*s('62')+lstar('10','63')*s('63')+lstar('10','64')*s('64')+lstar('10','65')*s('65')+lstar('10','66')*s('66')+lstar('10','67')*s('67')+lstar('10','68')*s('68')+lstar('10','69')*s('69')+lstar('10','70')*s('70')+lstar('10','71')*s('71')+lstar('10','72')*s('72')+lstar('10','73')*s('73')+lstar('10','74')*s('74')-vcupstcut('10','1')*s('75')-vcupstcut('10','2')*s('76')-vcupstcut('10','3')*s('77')-vcupstcut('10','4')*s('78')-vcupstcut('10','5')*s('79')-vcupstcut('10','6')*s('80')-vcupstcut('10','7')*s('81')-vcupstcut('10','8')*s('82')-vcupstcut('10','9')*s('83')-vcupstcut('10','10')*s('84')-vcupstcut('10','11')*s('85')-vcupstcut('10','12')*s('86')-vcupstcut('10','13')*s('87')-vcupstcut('10','14')*s('88')-vcupstcut('10','15')*s('89')-vcupstcut('10','16')*s('90')-eqeconupstcut('10')*s('91');
equat11 ..    p2pf('11') =E= lstar('11','1')*s('1')+lstar('11','2')*s('2')+lstar('11','3')*s('3')+lstar('11','4')*s('4')+lstar('11','5')*s('5')+lstar('11','6')*s('6')+lstar('11','7')*s('7')+lstar('11','8')*s('8')+lstar('11','9')*s('9')+lstar('11','10')*s('10')+lstar('11','11')*s('11')+lstar('11','12')*s('12')+lstar('11','13')*s('13')+lstar('11','14')*s('14')+lstar('11','15')*s('15')+lstar('11','16')*s('16')+lstar('11','17')*s('17')+lstar('11','18')*s('18')+lstar('11','19')*s('19')+lstar('11','20')*s('20')+lstar('11','21')*s('21')+lstar('11','22')*s('22')+lstar('11','23')*s('23')+lstar('11','24')*s('24')+lstar('11','25')*s('25')+lstar('11','26')*s('26')+lstar('11','27')*s('27')+lstar('11','28')*s('28')+lstar('11','29')*s('29')+lstar('11','30')*s('30')+lstar('11','31')*s('31')+lstar('11','32')*s('32')+lstar('11','33')*s('33')+lstar('11','34')*s('34')+lstar('11','35')*s('35')+lstar('11','36')*s('36')+lstar('11','37')*s('37')+lstar('11','38')*s('38')+lstar('11','39')*s('39')+lstar('11','40')*s('40')+lstar('11','41')*s('41')+lstar('11','42')*s('42')+lstar('11','43')*s('43')+lstar('11','44')*s('44')+lstar('11','45')*s('45')+lstar('11','46')*s('46')+lstar('11','47')*s('47')+lstar('11','48')*s('48')+lstar('11','49')*s('49')+lstar('11','50')*s('50')+lstar('11','51')*s('51')+lstar('11','52')*s('52')+lstar('11','53')*s('53')+lstar('11','54')*s('54')+lstar('11','55')*s('55')+lstar('11','56')*s('56')+lstar('11','57')*s('57')+lstar('11','58')*s('58')+lstar('11','59')*s('59')+lstar('11','60')*s('60')+lstar('11','61')*s('61')+lstar('11','62')*s('62')+lstar('11','63')*s('63')+lstar('11','64')*s('64')+lstar('11','65')*s('65')+lstar('11','66')*s('66')+lstar('11','67')*s('67')+lstar('11','68')*s('68')+lstar('11','69')*s('69')+lstar('11','70')*s('70')+lstar('11','71')*s('71')+lstar('11','72')*s('72')+lstar('11','73')*s('73')+lstar('11','74')*s('74')-vcupstcut('11','1')*s('75')-vcupstcut('11','2')*s('76')-vcupstcut('11','3')*s('77')-vcupstcut('11','4')*s('78')-vcupstcut('11','5')*s('79')-vcupstcut('11','6')*s('80')-vcupstcut('11','7')*s('81')-vcupstcut('11','8')*s('82')-vcupstcut('11','9')*s('83')-vcupstcut('11','10')*s('84')-vcupstcut('11','11')*s('85')-vcupstcut('11','12')*s('86')-vcupstcut('11','13')*s('87')-vcupstcut('11','14')*s('88')-vcupstcut('11','15')*s('89')-vcupstcut('11','16')*s('90')-eqeconupstcut('11')*s('91');
equat12 ..    p2pf('12') =E= lstar('12','1')*s('1')+lstar('12','2')*s('2')+lstar('12','3')*s('3')+lstar('12','4')*s('4')+lstar('12','5')*s('5')+lstar('12','6')*s('6')+lstar('12','7')*s('7')+lstar('12','8')*s('8')+lstar('12','9')*s('9')+lstar('12','10')*s('10')+lstar('12','11')*s('11')+lstar('12','12')*s('12')+lstar('12','13')*s('13')+lstar('12','14')*s('14')+lstar('12','15')*s('15')+lstar('12','16')*s('16')+lstar('12','17')*s('17')+lstar('12','18')*s('18')+lstar('12','19')*s('19')+lstar('12','20')*s('20')+lstar('12','21')*s('21')+lstar('12','22')*s('22')+lstar('12','23')*s('23')+lstar('12','24')*s('24')+lstar('12','25')*s('25')+lstar('12','26')*s('26')+lstar('12','27')*s('27')+lstar('12','28')*s('28')+lstar('12','29')*s('29')+lstar('12','30')*s('30')+lstar('12','31')*s('31')+lstar('12','32')*s('32')+lstar('12','33')*s('33')+lstar('12','34')*s('34')+lstar('12','35')*s('35')+lstar('12','36')*s('36')+lstar('12','37')*s('37')+lstar('12','38')*s('38')+lstar('12','39')*s('39')+lstar('12','40')*s('40')+lstar('12','41')*s('41')+lstar('12','42')*s('42')+lstar('12','43')*s('43')+lstar('12','44')*s('44')+lstar('12','45')*s('45')+lstar('12','46')*s('46')+lstar('12','47')*s('47')+lstar('12','48')*s('48')+lstar('12','49')*s('49')+lstar('12','50')*s('50')+lstar('12','51')*s('51')+lstar('12','52')*s('52')+lstar('12','53')*s('53')+lstar('12','54')*s('54')+lstar('12','55')*s('55')+lstar('12','56')*s('56')+lstar('12','57')*s('57')+lstar('12','58')*s('58')+lstar('12','59')*s('59')+lstar('12','60')*s('60')+lstar('12','61')*s('61')+lstar('12','62')*s('62')+lstar('12','63')*s('63')+lstar('12','64')*s('64')+lstar('12','65')*s('65')+lstar('12','66')*s('66')+lstar('12','67')*s('67')+lstar('12','68')*s('68')+lstar('12','69')*s('69')+lstar('12','70')*s('70')+lstar('12','71')*s('71')+lstar('12','72')*s('72')+lstar('12','73')*s('73')+lstar('12','74')*s('74')-vcupstcut('12','1')*s('75')-vcupstcut('12','2')*s('76')-vcupstcut('12','3')*s('77')-vcupstcut('12','4')*s('78')-vcupstcut('12','5')*s('79')-vcupstcut('12','6')*s('80')-vcupstcut('12','7')*s('81')-vcupstcut('12','8')*s('82')-vcupstcut('12','9')*s('83')-vcupstcut('12','10')*s('84')-vcupstcut('12','11')*s('85')-vcupstcut('12','12')*s('86')-vcupstcut('12','13')*s('87')-vcupstcut('12','14')*s('88')-vcupstcut('12','15')*s('89')-vcupstcut('12','16')*s('90')-eqeconupstcut('12')*s('91');
equat13 ..    p2pf('13') =E= lstar('13','1')*s('1')+lstar('13','2')*s('2')+lstar('13','3')*s('3')+lstar('13','4')*s('4')+lstar('13','5')*s('5')+lstar('13','6')*s('6')+lstar('13','7')*s('7')+lstar('13','8')*s('8')+lstar('13','9')*s('9')+lstar('13','10')*s('10')+lstar('13','11')*s('11')+lstar('13','12')*s('12')+lstar('13','13')*s('13')+lstar('13','14')*s('14')+lstar('13','15')*s('15')+lstar('13','16')*s('16')+lstar('13','17')*s('17')+lstar('13','18')*s('18')+lstar('13','19')*s('19')+lstar('13','20')*s('20')+lstar('13','21')*s('21')+lstar('13','22')*s('22')+lstar('13','23')*s('23')+lstar('13','24')*s('24')+lstar('13','25')*s('25')+lstar('13','26')*s('26')+lstar('13','27')*s('27')+lstar('13','28')*s('28')+lstar('13','29')*s('29')+lstar('13','30')*s('30')+lstar('13','31')*s('31')+lstar('13','32')*s('32')+lstar('13','33')*s('33')+lstar('13','34')*s('34')+lstar('13','35')*s('35')+lstar('13','36')*s('36')+lstar('13','37')*s('37')+lstar('13','38')*s('38')+lstar('13','39')*s('39')+lstar('13','40')*s('40')+lstar('13','41')*s('41')+lstar('13','42')*s('42')+lstar('13','43')*s('43')+lstar('13','44')*s('44')+lstar('13','45')*s('45')+lstar('13','46')*s('46')+lstar('13','47')*s('47')+lstar('13','48')*s('48')+lstar('13','49')*s('49')+lstar('13','50')*s('50')+lstar('13','51')*s('51')+lstar('13','52')*s('52')+lstar('13','53')*s('53')+lstar('13','54')*s('54')+lstar('13','55')*s('55')+lstar('13','56')*s('56')+lstar('13','57')*s('57')+lstar('13','58')*s('58')+lstar('13','59')*s('59')+lstar('13','60')*s('60')+lstar('13','61')*s('61')+lstar('13','62')*s('62')+lstar('13','63')*s('63')+lstar('13','64')*s('64')+lstar('13','65')*s('65')+lstar('13','66')*s('66')+lstar('13','67')*s('67')+lstar('13','68')*s('68')+lstar('13','69')*s('69')+lstar('13','70')*s('70')+lstar('13','71')*s('71')+lstar('13','72')*s('72')+lstar('13','73')*s('73')+lstar('13','74')*s('74')-vcupstcut('13','1')*s('75')-vcupstcut('13','2')*s('76')-vcupstcut('13','3')*s('77')-vcupstcut('13','4')*s('78')-vcupstcut('13','5')*s('79')-vcupstcut('13','6')*s('80')-vcupstcut('13','7')*s('81')-vcupstcut('13','8')*s('82')-vcupstcut('13','9')*s('83')-vcupstcut('13','10')*s('84')-vcupstcut('13','11')*s('85')-vcupstcut('13','12')*s('86')-vcupstcut('13','13')*s('87')-vcupstcut('13','14')*s('88')-vcupstcut('13','15')*s('89')-vcupstcut('13','16')*s('90')-eqeconupstcut('13')*s('91');
equat14 ..    p2pf('14') =E= lstar('14','1')*s('1')+lstar('14','2')*s('2')+lstar('14','3')*s('3')+lstar('14','4')*s('4')+lstar('14','5')*s('5')+lstar('14','6')*s('6')+lstar('14','7')*s('7')+lstar('14','8')*s('8')+lstar('14','9')*s('9')+lstar('14','10')*s('10')+lstar('14','11')*s('11')+lstar('14','12')*s('12')+lstar('14','13')*s('13')+lstar('14','14')*s('14')+lstar('14','15')*s('15')+lstar('14','16')*s('16')+lstar('14','17')*s('17')+lstar('14','18')*s('18')+lstar('14','19')*s('19')+lstar('14','20')*s('20')+lstar('14','21')*s('21')+lstar('14','22')*s('22')+lstar('14','23')*s('23')+lstar('14','24')*s('24')+lstar('14','25')*s('25')+lstar('14','26')*s('26')+lstar('14','27')*s('27')+lstar('14','28')*s('28')+lstar('14','29')*s('29')+lstar('14','30')*s('30')+lstar('14','31')*s('31')+lstar('14','32')*s('32')+lstar('14','33')*s('33')+lstar('14','34')*s('34')+lstar('14','35')*s('35')+lstar('14','36')*s('36')+lstar('14','37')*s('37')+lstar('14','38')*s('38')+lstar('14','39')*s('39')+lstar('14','40')*s('40')+lstar('14','41')*s('41')+lstar('14','42')*s('42')+lstar('14','43')*s('43')+lstar('14','44')*s('44')+lstar('14','45')*s('45')+lstar('14','46')*s('46')+lstar('14','47')*s('47')+lstar('14','48')*s('48')+lstar('14','49')*s('49')+lstar('14','50')*s('50')+lstar('14','51')*s('51')+lstar('14','52')*s('52')+lstar('14','53')*s('53')+lstar('14','54')*s('54')+lstar('14','55')*s('55')+lstar('14','56')*s('56')+lstar('14','57')*s('57')+lstar('14','58')*s('58')+lstar('14','59')*s('59')+lstar('14','60')*s('60')+lstar('14','61')*s('61')+lstar('14','62')*s('62')+lstar('14','63')*s('63')+lstar('14','64')*s('64')+lstar('14','65')*s('65')+lstar('14','66')*s('66')+lstar('14','67')*s('67')+lstar('14','68')*s('68')+lstar('14','69')*s('69')+lstar('14','70')*s('70')+lstar('14','71')*s('71')+lstar('14','72')*s('72')+lstar('14','73')*s('73')+lstar('14','74')*s('74')-vcupstcut('14','1')*s('75')-vcupstcut('14','2')*s('76')-vcupstcut('14','3')*s('77')-vcupstcut('14','4')*s('78')-vcupstcut('14','5')*s('79')-vcupstcut('14','6')*s('80')-vcupstcut('14','7')*s('81')-vcupstcut('14','8')*s('82')-vcupstcut('14','9')*s('83')-vcupstcut('14','10')*s('84')-vcupstcut('14','11')*s('85')-vcupstcut('14','12')*s('86')-vcupstcut('14','13')*s('87')-vcupstcut('14','14')*s('88')-vcupstcut('14','15')*s('89')-vcupstcut('14','16')*s('90')-eqeconupstcut('14')*s('91');
equat15 ..    p2pf('15') =E= lstar('15','1')*s('1')+lstar('15','2')*s('2')+lstar('15','3')*s('3')+lstar('15','4')*s('4')+lstar('15','5')*s('5')+lstar('15','6')*s('6')+lstar('15','7')*s('7')+lstar('15','8')*s('8')+lstar('15','9')*s('9')+lstar('15','10')*s('10')+lstar('15','11')*s('11')+lstar('15','12')*s('12')+lstar('15','13')*s('13')+lstar('15','14')*s('14')+lstar('15','15')*s('15')+lstar('15','16')*s('16')+lstar('15','17')*s('17')+lstar('15','18')*s('18')+lstar('15','19')*s('19')+lstar('15','20')*s('20')+lstar('15','21')*s('21')+lstar('15','22')*s('22')+lstar('15','23')*s('23')+lstar('15','24')*s('24')+lstar('15','25')*s('25')+lstar('15','26')*s('26')+lstar('15','27')*s('27')+lstar('15','28')*s('28')+lstar('15','29')*s('29')+lstar('15','30')*s('30')+lstar('15','31')*s('31')+lstar('15','32')*s('32')+lstar('15','33')*s('33')+lstar('15','34')*s('34')+lstar('15','35')*s('35')+lstar('15','36')*s('36')+lstar('15','37')*s('37')+lstar('15','38')*s('38')+lstar('15','39')*s('39')+lstar('15','40')*s('40')+lstar('15','41')*s('41')+lstar('15','42')*s('42')+lstar('15','43')*s('43')+lstar('15','44')*s('44')+lstar('15','45')*s('45')+lstar('15','46')*s('46')+lstar('15','47')*s('47')+lstar('15','48')*s('48')+lstar('15','49')*s('49')+lstar('15','50')*s('50')+lstar('15','51')*s('51')+lstar('15','52')*s('52')+lstar('15','53')*s('53')+lstar('15','54')*s('54')+lstar('15','55')*s('55')+lstar('15','56')*s('56')+lstar('15','57')*s('57')+lstar('15','58')*s('58')+lstar('15','59')*s('59')+lstar('15','60')*s('60')+lstar('15','61')*s('61')+lstar('15','62')*s('62')+lstar('15','63')*s('63')+lstar('15','64')*s('64')+lstar('15','65')*s('65')+lstar('15','66')*s('66')+lstar('15','67')*s('67')+lstar('15','68')*s('68')+lstar('15','69')*s('69')+lstar('15','70')*s('70')+lstar('15','71')*s('71')+lstar('15','72')*s('72')+lstar('15','73')*s('73')+lstar('15','74')*s('74')-vcupstcut('15','1')*s('75')-vcupstcut('15','2')*s('76')-vcupstcut('15','3')*s('77')-vcupstcut('15','4')*s('78')-vcupstcut('15','5')*s('79')-vcupstcut('15','6')*s('80')-vcupstcut('15','7')*s('81')-vcupstcut('15','8')*s('82')-vcupstcut('15','9')*s('83')-vcupstcut('15','10')*s('84')-vcupstcut('15','11')*s('85')-vcupstcut('15','12')*s('86')-vcupstcut('15','13')*s('87')-vcupstcut('15','14')*s('88')-vcupstcut('15','15')*s('89')-vcupstcut('15','16')*s('90')-eqeconupstcut('15')*s('91');
equat16 ..    p2pf('16') =E= lstar('16','1')*s('1')+lstar('16','2')*s('2')+lstar('16','3')*s('3')+lstar('16','4')*s('4')+lstar('16','5')*s('5')+lstar('16','6')*s('6')+lstar('16','7')*s('7')+lstar('16','8')*s('8')+lstar('16','9')*s('9')+lstar('16','10')*s('10')+lstar('16','11')*s('11')+lstar('16','12')*s('12')+lstar('16','13')*s('13')+lstar('16','14')*s('14')+lstar('16','15')*s('15')+lstar('16','16')*s('16')+lstar('16','17')*s('17')+lstar('16','18')*s('18')+lstar('16','19')*s('19')+lstar('16','20')*s('20')+lstar('16','21')*s('21')+lstar('16','22')*s('22')+lstar('16','23')*s('23')+lstar('16','24')*s('24')+lstar('16','25')*s('25')+lstar('16','26')*s('26')+lstar('16','27')*s('27')+lstar('16','28')*s('28')+lstar('16','29')*s('29')+lstar('16','30')*s('30')+lstar('16','31')*s('31')+lstar('16','32')*s('32')+lstar('16','33')*s('33')+lstar('16','34')*s('34')+lstar('16','35')*s('35')+lstar('16','36')*s('36')+lstar('16','37')*s('37')+lstar('16','38')*s('38')+lstar('16','39')*s('39')+lstar('16','40')*s('40')+lstar('16','41')*s('41')+lstar('16','42')*s('42')+lstar('16','43')*s('43')+lstar('16','44')*s('44')+lstar('16','45')*s('45')+lstar('16','46')*s('46')+lstar('16','47')*s('47')+lstar('16','48')*s('48')+lstar('16','49')*s('49')+lstar('16','50')*s('50')+lstar('16','51')*s('51')+lstar('16','52')*s('52')+lstar('16','53')*s('53')+lstar('16','54')*s('54')+lstar('16','55')*s('55')+lstar('16','56')*s('56')+lstar('16','57')*s('57')+lstar('16','58')*s('58')+lstar('16','59')*s('59')+lstar('16','60')*s('60')+lstar('16','61')*s('61')+lstar('16','62')*s('62')+lstar('16','63')*s('63')+lstar('16','64')*s('64')+lstar('16','65')*s('65')+lstar('16','66')*s('66')+lstar('16','67')*s('67')+lstar('16','68')*s('68')+lstar('16','69')*s('69')+lstar('16','70')*s('70')+lstar('16','71')*s('71')+lstar('16','72')*s('72')+lstar('16','73')*s('73')+lstar('16','74')*s('74')-vcupstcut('16','1')*s('75')-vcupstcut('16','2')*s('76')-vcupstcut('16','3')*s('77')-vcupstcut('16','4')*s('78')-vcupstcut('16','5')*s('79')-vcupstcut('16','6')*s('80')-vcupstcut('16','7')*s('81')-vcupstcut('16','8')*s('82')-vcupstcut('16','9')*s('83')-vcupstcut('16','10')*s('84')-vcupstcut('16','11')*s('85')-vcupstcut('16','12')*s('86')-vcupstcut('16','13')*s('87')-vcupstcut('16','14')*s('88')-vcupstcut('16','15')*s('89')-vcupstcut('16','16')*s('90')-eqeconupstcut('16')*s('91');
equat17 ..    p2pf('17') =E= lstar('17','1')*s('1')+lstar('17','2')*s('2')+lstar('17','3')*s('3')+lstar('17','4')*s('4')+lstar('17','5')*s('5')+lstar('17','6')*s('6')+lstar('17','7')*s('7')+lstar('17','8')*s('8')+lstar('17','9')*s('9')+lstar('17','10')*s('10')+lstar('17','11')*s('11')+lstar('17','12')*s('12')+lstar('17','13')*s('13')+lstar('17','14')*s('14')+lstar('17','15')*s('15')+lstar('17','16')*s('16')+lstar('17','17')*s('17')+lstar('17','18')*s('18')+lstar('17','19')*s('19')+lstar('17','20')*s('20')+lstar('17','21')*s('21')+lstar('17','22')*s('22')+lstar('17','23')*s('23')+lstar('17','24')*s('24')+lstar('17','25')*s('25')+lstar('17','26')*s('26')+lstar('17','27')*s('27')+lstar('17','28')*s('28')+lstar('17','29')*s('29')+lstar('17','30')*s('30')+lstar('17','31')*s('31')+lstar('17','32')*s('32')+lstar('17','33')*s('33')+lstar('17','34')*s('34')+lstar('17','35')*s('35')+lstar('17','36')*s('36')+lstar('17','37')*s('37')+lstar('17','38')*s('38')+lstar('17','39')*s('39')+lstar('17','40')*s('40')+lstar('17','41')*s('41')+lstar('17','42')*s('42')+lstar('17','43')*s('43')+lstar('17','44')*s('44')+lstar('17','45')*s('45')+lstar('17','46')*s('46')+lstar('17','47')*s('47')+lstar('17','48')*s('48')+lstar('17','49')*s('49')+lstar('17','50')*s('50')+lstar('17','51')*s('51')+lstar('17','52')*s('52')+lstar('17','53')*s('53')+lstar('17','54')*s('54')+lstar('17','55')*s('55')+lstar('17','56')*s('56')+lstar('17','57')*s('57')+lstar('17','58')*s('58')+lstar('17','59')*s('59')+lstar('17','60')*s('60')+lstar('17','61')*s('61')+lstar('17','62')*s('62')+lstar('17','63')*s('63')+lstar('17','64')*s('64')+lstar('17','65')*s('65')+lstar('17','66')*s('66')+lstar('17','67')*s('67')+lstar('17','68')*s('68')+lstar('17','69')*s('69')+lstar('17','70')*s('70')+lstar('17','71')*s('71')+lstar('17','72')*s('72')+lstar('17','73')*s('73')+lstar('17','74')*s('74')-vcupstcut('17','1')*s('75')-vcupstcut('17','2')*s('76')-vcupstcut('17','3')*s('77')-vcupstcut('17','4')*s('78')-vcupstcut('17','5')*s('79')-vcupstcut('17','6')*s('80')-vcupstcut('17','7')*s('81')-vcupstcut('17','8')*s('82')-vcupstcut('17','9')*s('83')-vcupstcut('17','10')*s('84')-vcupstcut('17','11')*s('85')-vcupstcut('17','12')*s('86')-vcupstcut('17','13')*s('87')-vcupstcut('17','14')*s('88')-vcupstcut('17','15')*s('89')-vcupstcut('17','16')*s('90')-eqeconupstcut('17')*s('91');
equat18 ..    p2pf('18') =E= lstar('18','1')*s('1')+lstar('18','2')*s('2')+lstar('18','3')*s('3')+lstar('18','4')*s('4')+lstar('18','5')*s('5')+lstar('18','6')*s('6')+lstar('18','7')*s('7')+lstar('18','8')*s('8')+lstar('18','9')*s('9')+lstar('18','10')*s('10')+lstar('18','11')*s('11')+lstar('18','12')*s('12')+lstar('18','13')*s('13')+lstar('18','14')*s('14')+lstar('18','15')*s('15')+lstar('18','16')*s('16')+lstar('18','17')*s('17')+lstar('18','18')*s('18')+lstar('18','19')*s('19')+lstar('18','20')*s('20')+lstar('18','21')*s('21')+lstar('18','22')*s('22')+lstar('18','23')*s('23')+lstar('18','24')*s('24')+lstar('18','25')*s('25')+lstar('18','26')*s('26')+lstar('18','27')*s('27')+lstar('18','28')*s('28')+lstar('18','29')*s('29')+lstar('18','30')*s('30')+lstar('18','31')*s('31')+lstar('18','32')*s('32')+lstar('18','33')*s('33')+lstar('18','34')*s('34')+lstar('18','35')*s('35')+lstar('18','36')*s('36')+lstar('18','37')*s('37')+lstar('18','38')*s('38')+lstar('18','39')*s('39')+lstar('18','40')*s('40')+lstar('18','41')*s('41')+lstar('18','42')*s('42')+lstar('18','43')*s('43')+lstar('18','44')*s('44')+lstar('18','45')*s('45')+lstar('18','46')*s('46')+lstar('18','47')*s('47')+lstar('18','48')*s('48')+lstar('18','49')*s('49')+lstar('18','50')*s('50')+lstar('18','51')*s('51')+lstar('18','52')*s('52')+lstar('18','53')*s('53')+lstar('18','54')*s('54')+lstar('18','55')*s('55')+lstar('18','56')*s('56')+lstar('18','57')*s('57')+lstar('18','58')*s('58')+lstar('18','59')*s('59')+lstar('18','60')*s('60')+lstar('18','61')*s('61')+lstar('18','62')*s('62')+lstar('18','63')*s('63')+lstar('18','64')*s('64')+lstar('18','65')*s('65')+lstar('18','66')*s('66')+lstar('18','67')*s('67')+lstar('18','68')*s('68')+lstar('18','69')*s('69')+lstar('18','70')*s('70')+lstar('18','71')*s('71')+lstar('18','72')*s('72')+lstar('18','73')*s('73')+lstar('18','74')*s('74')-vcupstcut('18','1')*s('75')-vcupstcut('18','2')*s('76')-vcupstcut('18','3')*s('77')-vcupstcut('18','4')*s('78')-vcupstcut('18','5')*s('79')-vcupstcut('18','6')*s('80')-vcupstcut('18','7')*s('81')-vcupstcut('18','8')*s('82')-vcupstcut('18','9')*s('83')-vcupstcut('18','10')*s('84')-vcupstcut('18','11')*s('85')-vcupstcut('18','12')*s('86')-vcupstcut('18','13')*s('87')-vcupstcut('18','14')*s('88')-vcupstcut('18','15')*s('89')-vcupstcut('18','16')*s('90')-eqeconupstcut('18')*s('91');
equat19 ..    p2pf('19') =E= lstar('19','1')*s('1')+lstar('19','2')*s('2')+lstar('19','3')*s('3')+lstar('19','4')*s('4')+lstar('19','5')*s('5')+lstar('19','6')*s('6')+lstar('19','7')*s('7')+lstar('19','8')*s('8')+lstar('19','9')*s('9')+lstar('19','10')*s('10')+lstar('19','11')*s('11')+lstar('19','12')*s('12')+lstar('19','13')*s('13')+lstar('19','14')*s('14')+lstar('19','15')*s('15')+lstar('19','16')*s('16')+lstar('19','17')*s('17')+lstar('19','18')*s('18')+lstar('19','19')*s('19')+lstar('19','20')*s('20')+lstar('19','21')*s('21')+lstar('19','22')*s('22')+lstar('19','23')*s('23')+lstar('19','24')*s('24')+lstar('19','25')*s('25')+lstar('19','26')*s('26')+lstar('19','27')*s('27')+lstar('19','28')*s('28')+lstar('19','29')*s('29')+lstar('19','30')*s('30')+lstar('19','31')*s('31')+lstar('19','32')*s('32')+lstar('19','33')*s('33')+lstar('19','34')*s('34')+lstar('19','35')*s('35')+lstar('19','36')*s('36')+lstar('19','37')*s('37')+lstar('19','38')*s('38')+lstar('19','39')*s('39')+lstar('19','40')*s('40')+lstar('19','41')*s('41')+lstar('19','42')*s('42')+lstar('19','43')*s('43')+lstar('19','44')*s('44')+lstar('19','45')*s('45')+lstar('19','46')*s('46')+lstar('19','47')*s('47')+lstar('19','48')*s('48')+lstar('19','49')*s('49')+lstar('19','50')*s('50')+lstar('19','51')*s('51')+lstar('19','52')*s('52')+lstar('19','53')*s('53')+lstar('19','54')*s('54')+lstar('19','55')*s('55')+lstar('19','56')*s('56')+lstar('19','57')*s('57')+lstar('19','58')*s('58')+lstar('19','59')*s('59')+lstar('19','60')*s('60')+lstar('19','61')*s('61')+lstar('19','62')*s('62')+lstar('19','63')*s('63')+lstar('19','64')*s('64')+lstar('19','65')*s('65')+lstar('19','66')*s('66')+lstar('19','67')*s('67')+lstar('19','68')*s('68')+lstar('19','69')*s('69')+lstar('19','70')*s('70')+lstar('19','71')*s('71')+lstar('19','72')*s('72')+lstar('19','73')*s('73')+lstar('19','74')*s('74')-vcupstcut('19','1')*s('75')-vcupstcut('19','2')*s('76')-vcupstcut('19','3')*s('77')-vcupstcut('19','4')*s('78')-vcupstcut('19','5')*s('79')-vcupstcut('19','6')*s('80')-vcupstcut('19','7')*s('81')-vcupstcut('19','8')*s('82')-vcupstcut('19','9')*s('83')-vcupstcut('19','10')*s('84')-vcupstcut('19','11')*s('85')-vcupstcut('19','12')*s('86')-vcupstcut('19','13')*s('87')-vcupstcut('19','14')*s('88')-vcupstcut('19','15')*s('89')-vcupstcut('19','16')*s('90')-eqeconupstcut('19')*s('91');
equat20 ..    p2pf('20') =E= lstar('20','1')*s('1')+lstar('20','2')*s('2')+lstar('20','3')*s('3')+lstar('20','4')*s('4')+lstar('20','5')*s('5')+lstar('20','6')*s('6')+lstar('20','7')*s('7')+lstar('20','8')*s('8')+lstar('20','9')*s('9')+lstar('20','10')*s('10')+lstar('20','11')*s('11')+lstar('20','12')*s('12')+lstar('20','13')*s('13')+lstar('20','14')*s('14')+lstar('20','15')*s('15')+lstar('20','16')*s('16')+lstar('20','17')*s('17')+lstar('20','18')*s('18')+lstar('20','19')*s('19')+lstar('20','20')*s('20')+lstar('20','21')*s('21')+lstar('20','22')*s('22')+lstar('20','23')*s('23')+lstar('20','24')*s('24')+lstar('20','25')*s('25')+lstar('20','26')*s('26')+lstar('20','27')*s('27')+lstar('20','28')*s('28')+lstar('20','29')*s('29')+lstar('20','30')*s('30')+lstar('20','31')*s('31')+lstar('20','32')*s('32')+lstar('20','33')*s('33')+lstar('20','34')*s('34')+lstar('20','35')*s('35')+lstar('20','36')*s('36')+lstar('20','37')*s('37')+lstar('20','38')*s('38')+lstar('20','39')*s('39')+lstar('20','40')*s('40')+lstar('20','41')*s('41')+lstar('20','42')*s('42')+lstar('20','43')*s('43')+lstar('20','44')*s('44')+lstar('20','45')*s('45')+lstar('20','46')*s('46')+lstar('20','47')*s('47')+lstar('20','48')*s('48')+lstar('20','49')*s('49')+lstar('20','50')*s('50')+lstar('20','51')*s('51')+lstar('20','52')*s('52')+lstar('20','53')*s('53')+lstar('20','54')*s('54')+lstar('20','55')*s('55')+lstar('20','56')*s('56')+lstar('20','57')*s('57')+lstar('20','58')*s('58')+lstar('20','59')*s('59')+lstar('20','60')*s('60')+lstar('20','61')*s('61')+lstar('20','62')*s('62')+lstar('20','63')*s('63')+lstar('20','64')*s('64')+lstar('20','65')*s('65')+lstar('20','66')*s('66')+lstar('20','67')*s('67')+lstar('20','68')*s('68')+lstar('20','69')*s('69')+lstar('20','70')*s('70')+lstar('20','71')*s('71')+lstar('20','72')*s('72')+lstar('20','73')*s('73')+lstar('20','74')*s('74')-vcupstcut('20','1')*s('75')-vcupstcut('20','2')*s('76')-vcupstcut('20','3')*s('77')-vcupstcut('20','4')*s('78')-vcupstcut('20','5')*s('79')-vcupstcut('20','6')*s('80')-vcupstcut('20','7')*s('81')-vcupstcut('20','8')*s('82')-vcupstcut('20','9')*s('83')-vcupstcut('20','10')*s('84')-vcupstcut('20','11')*s('85')-vcupstcut('20','12')*s('86')-vcupstcut('20','13')*s('87')-vcupstcut('20','14')*s('88')-vcupstcut('20','15')*s('89')-vcupstcut('20','16')*s('90')-eqeconupstcut('20')*s('91');
equat21 ..    p2pf('21') =E= lstar('21','1')*s('1')+lstar('21','2')*s('2')+lstar('21','3')*s('3')+lstar('21','4')*s('4')+lstar('21','5')*s('5')+lstar('21','6')*s('6')+lstar('21','7')*s('7')+lstar('21','8')*s('8')+lstar('21','9')*s('9')+lstar('21','10')*s('10')+lstar('21','11')*s('11')+lstar('21','12')*s('12')+lstar('21','13')*s('13')+lstar('21','14')*s('14')+lstar('21','15')*s('15')+lstar('21','16')*s('16')+lstar('21','17')*s('17')+lstar('21','18')*s('18')+lstar('21','19')*s('19')+lstar('21','20')*s('20')+lstar('21','21')*s('21')+lstar('21','22')*s('22')+lstar('21','23')*s('23')+lstar('21','24')*s('24')+lstar('21','25')*s('25')+lstar('21','26')*s('26')+lstar('21','27')*s('27')+lstar('21','28')*s('28')+lstar('21','29')*s('29')+lstar('21','30')*s('30')+lstar('21','31')*s('31')+lstar('21','32')*s('32')+lstar('21','33')*s('33')+lstar('21','34')*s('34')+lstar('21','35')*s('35')+lstar('21','36')*s('36')+lstar('21','37')*s('37')+lstar('21','38')*s('38')+lstar('21','39')*s('39')+lstar('21','40')*s('40')+lstar('21','41')*s('41')+lstar('21','42')*s('42')+lstar('21','43')*s('43')+lstar('21','44')*s('44')+lstar('21','45')*s('45')+lstar('21','46')*s('46')+lstar('21','47')*s('47')+lstar('21','48')*s('48')+lstar('21','49')*s('49')+lstar('21','50')*s('50')+lstar('21','51')*s('51')+lstar('21','52')*s('52')+lstar('21','53')*s('53')+lstar('21','54')*s('54')+lstar('21','55')*s('55')+lstar('21','56')*s('56')+lstar('21','57')*s('57')+lstar('21','58')*s('58')+lstar('21','59')*s('59')+lstar('21','60')*s('60')+lstar('21','61')*s('61')+lstar('21','62')*s('62')+lstar('21','63')*s('63')+lstar('21','64')*s('64')+lstar('21','65')*s('65')+lstar('21','66')*s('66')+lstar('21','67')*s('67')+lstar('21','68')*s('68')+lstar('21','69')*s('69')+lstar('21','70')*s('70')+lstar('21','71')*s('71')+lstar('21','72')*s('72')+lstar('21','73')*s('73')+lstar('21','74')*s('74')-vcupstcut('21','1')*s('75')-vcupstcut('21','2')*s('76')-vcupstcut('21','3')*s('77')-vcupstcut('21','4')*s('78')-vcupstcut('21','5')*s('79')-vcupstcut('21','6')*s('80')-vcupstcut('21','7')*s('81')-vcupstcut('21','8')*s('82')-vcupstcut('21','9')*s('83')-vcupstcut('21','10')*s('84')-vcupstcut('21','11')*s('85')-vcupstcut('21','12')*s('86')-vcupstcut('21','13')*s('87')-vcupstcut('21','14')*s('88')-vcupstcut('21','15')*s('89')-vcupstcut('21','16')*s('90')-eqeconupstcut('21')*s('91');
equat22 ..    p2pf('22') =E= lstar('22','1')*s('1')+lstar('22','2')*s('2')+lstar('22','3')*s('3')+lstar('22','4')*s('4')+lstar('22','5')*s('5')+lstar('22','6')*s('6')+lstar('22','7')*s('7')+lstar('22','8')*s('8')+lstar('22','9')*s('9')+lstar('22','10')*s('10')+lstar('22','11')*s('11')+lstar('22','12')*s('12')+lstar('22','13')*s('13')+lstar('22','14')*s('14')+lstar('22','15')*s('15')+lstar('22','16')*s('16')+lstar('22','17')*s('17')+lstar('22','18')*s('18')+lstar('22','19')*s('19')+lstar('22','20')*s('20')+lstar('22','21')*s('21')+lstar('22','22')*s('22')+lstar('22','23')*s('23')+lstar('22','24')*s('24')+lstar('22','25')*s('25')+lstar('22','26')*s('26')+lstar('22','27')*s('27')+lstar('22','28')*s('28')+lstar('22','29')*s('29')+lstar('22','30')*s('30')+lstar('22','31')*s('31')+lstar('22','32')*s('32')+lstar('22','33')*s('33')+lstar('22','34')*s('34')+lstar('22','35')*s('35')+lstar('22','36')*s('36')+lstar('22','37')*s('37')+lstar('22','38')*s('38')+lstar('22','39')*s('39')+lstar('22','40')*s('40')+lstar('22','41')*s('41')+lstar('22','42')*s('42')+lstar('22','43')*s('43')+lstar('22','44')*s('44')+lstar('22','45')*s('45')+lstar('22','46')*s('46')+lstar('22','47')*s('47')+lstar('22','48')*s('48')+lstar('22','49')*s('49')+lstar('22','50')*s('50')+lstar('22','51')*s('51')+lstar('22','52')*s('52')+lstar('22','53')*s('53')+lstar('22','54')*s('54')+lstar('22','55')*s('55')+lstar('22','56')*s('56')+lstar('22','57')*s('57')+lstar('22','58')*s('58')+lstar('22','59')*s('59')+lstar('22','60')*s('60')+lstar('22','61')*s('61')+lstar('22','62')*s('62')+lstar('22','63')*s('63')+lstar('22','64')*s('64')+lstar('22','65')*s('65')+lstar('22','66')*s('66')+lstar('22','67')*s('67')+lstar('22','68')*s('68')+lstar('22','69')*s('69')+lstar('22','70')*s('70')+lstar('22','71')*s('71')+lstar('22','72')*s('72')+lstar('22','73')*s('73')+lstar('22','74')*s('74')-vcupstcut('22','1')*s('75')-vcupstcut('22','2')*s('76')-vcupstcut('22','3')*s('77')-vcupstcut('22','4')*s('78')-vcupstcut('22','5')*s('79')-vcupstcut('22','6')*s('80')-vcupstcut('22','7')*s('81')-vcupstcut('22','8')*s('82')-vcupstcut('22','9')*s('83')-vcupstcut('22','10')*s('84')-vcupstcut('22','11')*s('85')-vcupstcut('22','12')*s('86')-vcupstcut('22','13')*s('87')-vcupstcut('22','14')*s('88')-vcupstcut('22','15')*s('89')-vcupstcut('22','16')*s('90')-eqeconupstcut('22')*s('91');
equat23 ..    p2pf('23') =E= lstar('23','1')*s('1')+lstar('23','2')*s('2')+lstar('23','3')*s('3')+lstar('23','4')*s('4')+lstar('23','5')*s('5')+lstar('23','6')*s('6')+lstar('23','7')*s('7')+lstar('23','8')*s('8')+lstar('23','9')*s('9')+lstar('23','10')*s('10')+lstar('23','11')*s('11')+lstar('23','12')*s('12')+lstar('23','13')*s('13')+lstar('23','14')*s('14')+lstar('23','15')*s('15')+lstar('23','16')*s('16')+lstar('23','17')*s('17')+lstar('23','18')*s('18')+lstar('23','19')*s('19')+lstar('23','20')*s('20')+lstar('23','21')*s('21')+lstar('23','22')*s('22')+lstar('23','23')*s('23')+lstar('23','24')*s('24')+lstar('23','25')*s('25')+lstar('23','26')*s('26')+lstar('23','27')*s('27')+lstar('23','28')*s('28')+lstar('23','29')*s('29')+lstar('23','30')*s('30')+lstar('23','31')*s('31')+lstar('23','32')*s('32')+lstar('23','33')*s('33')+lstar('23','34')*s('34')+lstar('23','35')*s('35')+lstar('23','36')*s('36')+lstar('23','37')*s('37')+lstar('23','38')*s('38')+lstar('23','39')*s('39')+lstar('23','40')*s('40')+lstar('23','41')*s('41')+lstar('23','42')*s('42')+lstar('23','43')*s('43')+lstar('23','44')*s('44')+lstar('23','45')*s('45')+lstar('23','46')*s('46')+lstar('23','47')*s('47')+lstar('23','48')*s('48')+lstar('23','49')*s('49')+lstar('23','50')*s('50')+lstar('23','51')*s('51')+lstar('23','52')*s('52')+lstar('23','53')*s('53')+lstar('23','54')*s('54')+lstar('23','55')*s('55')+lstar('23','56')*s('56')+lstar('23','57')*s('57')+lstar('23','58')*s('58')+lstar('23','59')*s('59')+lstar('23','60')*s('60')+lstar('23','61')*s('61')+lstar('23','62')*s('62')+lstar('23','63')*s('63')+lstar('23','64')*s('64')+lstar('23','65')*s('65')+lstar('23','66')*s('66')+lstar('23','67')*s('67')+lstar('23','68')*s('68')+lstar('23','69')*s('69')+lstar('23','70')*s('70')+lstar('23','71')*s('71')+lstar('23','72')*s('72')+lstar('23','73')*s('73')+lstar('23','74')*s('74')-vcupstcut('23','1')*s('75')-vcupstcut('23','2')*s('76')-vcupstcut('23','3')*s('77')-vcupstcut('23','4')*s('78')-vcupstcut('23','5')*s('79')-vcupstcut('23','6')*s('80')-vcupstcut('23','7')*s('81')-vcupstcut('23','8')*s('82')-vcupstcut('23','9')*s('83')-vcupstcut('23','10')*s('84')-vcupstcut('23','11')*s('85')-vcupstcut('23','12')*s('86')-vcupstcut('23','13')*s('87')-vcupstcut('23','14')*s('88')-vcupstcut('23','15')*s('89')-vcupstcut('23','16')*s('90')-eqeconupstcut('23')*s('91');
equat24 ..    p2pf('24') =E= lstar('24','1')*s('1')+lstar('24','2')*s('2')+lstar('24','3')*s('3')+lstar('24','4')*s('4')+lstar('24','5')*s('5')+lstar('24','6')*s('6')+lstar('24','7')*s('7')+lstar('24','8')*s('8')+lstar('24','9')*s('9')+lstar('24','10')*s('10')+lstar('24','11')*s('11')+lstar('24','12')*s('12')+lstar('24','13')*s('13')+lstar('24','14')*s('14')+lstar('24','15')*s('15')+lstar('24','16')*s('16')+lstar('24','17')*s('17')+lstar('24','18')*s('18')+lstar('24','19')*s('19')+lstar('24','20')*s('20')+lstar('24','21')*s('21')+lstar('24','22')*s('22')+lstar('24','23')*s('23')+lstar('24','24')*s('24')+lstar('24','25')*s('25')+lstar('24','26')*s('26')+lstar('24','27')*s('27')+lstar('24','28')*s('28')+lstar('24','29')*s('29')+lstar('24','30')*s('30')+lstar('24','31')*s('31')+lstar('24','32')*s('32')+lstar('24','33')*s('33')+lstar('24','34')*s('34')+lstar('24','35')*s('35')+lstar('24','36')*s('36')+lstar('24','37')*s('37')+lstar('24','38')*s('38')+lstar('24','39')*s('39')+lstar('24','40')*s('40')+lstar('24','41')*s('41')+lstar('24','42')*s('42')+lstar('24','43')*s('43')+lstar('24','44')*s('44')+lstar('24','45')*s('45')+lstar('24','46')*s('46')+lstar('24','47')*s('47')+lstar('24','48')*s('48')+lstar('24','49')*s('49')+lstar('24','50')*s('50')+lstar('24','51')*s('51')+lstar('24','52')*s('52')+lstar('24','53')*s('53')+lstar('24','54')*s('54')+lstar('24','55')*s('55')+lstar('24','56')*s('56')+lstar('24','57')*s('57')+lstar('24','58')*s('58')+lstar('24','59')*s('59')+lstar('24','60')*s('60')+lstar('24','61')*s('61')+lstar('24','62')*s('62')+lstar('24','63')*s('63')+lstar('24','64')*s('64')+lstar('24','65')*s('65')+lstar('24','66')*s('66')+lstar('24','67')*s('67')+lstar('24','68')*s('68')+lstar('24','69')*s('69')+lstar('24','70')*s('70')+lstar('24','71')*s('71')+lstar('24','72')*s('72')+lstar('24','73')*s('73')+lstar('24','74')*s('74')-vcupstcut('24','1')*s('75')-vcupstcut('24','2')*s('76')-vcupstcut('24','3')*s('77')-vcupstcut('24','4')*s('78')-vcupstcut('24','5')*s('79')-vcupstcut('24','6')*s('80')-vcupstcut('24','7')*s('81')-vcupstcut('24','8')*s('82')-vcupstcut('24','9')*s('83')-vcupstcut('24','10')*s('84')-vcupstcut('24','11')*s('85')-vcupstcut('24','12')*s('86')-vcupstcut('24','13')*s('87')-vcupstcut('24','14')*s('88')-vcupstcut('24','15')*s('89')-vcupstcut('24','16')*s('90')-eqeconupstcut('24')*s('91');
equat25 ..    p2pf('25') =E= lstar('25','1')*s('1')+lstar('25','2')*s('2')+lstar('25','3')*s('3')+lstar('25','4')*s('4')+lstar('25','5')*s('5')+lstar('25','6')*s('6')+lstar('25','7')*s('7')+lstar('25','8')*s('8')+lstar('25','9')*s('9')+lstar('25','10')*s('10')+lstar('25','11')*s('11')+lstar('25','12')*s('12')+lstar('25','13')*s('13')+lstar('25','14')*s('14')+lstar('25','15')*s('15')+lstar('25','16')*s('16')+lstar('25','17')*s('17')+lstar('25','18')*s('18')+lstar('25','19')*s('19')+lstar('25','20')*s('20')+lstar('25','21')*s('21')+lstar('25','22')*s('22')+lstar('25','23')*s('23')+lstar('25','24')*s('24')+lstar('25','25')*s('25')+lstar('25','26')*s('26')+lstar('25','27')*s('27')+lstar('25','28')*s('28')+lstar('25','29')*s('29')+lstar('25','30')*s('30')+lstar('25','31')*s('31')+lstar('25','32')*s('32')+lstar('25','33')*s('33')+lstar('25','34')*s('34')+lstar('25','35')*s('35')+lstar('25','36')*s('36')+lstar('25','37')*s('37')+lstar('25','38')*s('38')+lstar('25','39')*s('39')+lstar('25','40')*s('40')+lstar('25','41')*s('41')+lstar('25','42')*s('42')+lstar('25','43')*s('43')+lstar('25','44')*s('44')+lstar('25','45')*s('45')+lstar('25','46')*s('46')+lstar('25','47')*s('47')+lstar('25','48')*s('48')+lstar('25','49')*s('49')+lstar('25','50')*s('50')+lstar('25','51')*s('51')+lstar('25','52')*s('52')+lstar('25','53')*s('53')+lstar('25','54')*s('54')+lstar('25','55')*s('55')+lstar('25','56')*s('56')+lstar('25','57')*s('57')+lstar('25','58')*s('58')+lstar('25','59')*s('59')+lstar('25','60')*s('60')+lstar('25','61')*s('61')+lstar('25','62')*s('62')+lstar('25','63')*s('63')+lstar('25','64')*s('64')+lstar('25','65')*s('65')+lstar('25','66')*s('66')+lstar('25','67')*s('67')+lstar('25','68')*s('68')+lstar('25','69')*s('69')+lstar('25','70')*s('70')+lstar('25','71')*s('71')+lstar('25','72')*s('72')+lstar('25','73')*s('73')+lstar('25','74')*s('74')-vcupstcut('25','1')*s('75')-vcupstcut('25','2')*s('76')-vcupstcut('25','3')*s('77')-vcupstcut('25','4')*s('78')-vcupstcut('25','5')*s('79')-vcupstcut('25','6')*s('80')-vcupstcut('25','7')*s('81')-vcupstcut('25','8')*s('82')-vcupstcut('25','9')*s('83')-vcupstcut('25','10')*s('84')-vcupstcut('25','11')*s('85')-vcupstcut('25','12')*s('86')-vcupstcut('25','13')*s('87')-vcupstcut('25','14')*s('88')-vcupstcut('25','15')*s('89')-vcupstcut('25','16')*s('90')-eqeconupstcut('25')*s('91');
equat26 ..    p2pf('26') =E= lstar('26','1')*s('1')+lstar('26','2')*s('2')+lstar('26','3')*s('3')+lstar('26','4')*s('4')+lstar('26','5')*s('5')+lstar('26','6')*s('6')+lstar('26','7')*s('7')+lstar('26','8')*s('8')+lstar('26','9')*s('9')+lstar('26','10')*s('10')+lstar('26','11')*s('11')+lstar('26','12')*s('12')+lstar('26','13')*s('13')+lstar('26','14')*s('14')+lstar('26','15')*s('15')+lstar('26','16')*s('16')+lstar('26','17')*s('17')+lstar('26','18')*s('18')+lstar('26','19')*s('19')+lstar('26','20')*s('20')+lstar('26','21')*s('21')+lstar('26','22')*s('22')+lstar('26','23')*s('23')+lstar('26','24')*s('24')+lstar('26','25')*s('25')+lstar('26','26')*s('26')+lstar('26','27')*s('27')+lstar('26','28')*s('28')+lstar('26','29')*s('29')+lstar('26','30')*s('30')+lstar('26','31')*s('31')+lstar('26','32')*s('32')+lstar('26','33')*s('33')+lstar('26','34')*s('34')+lstar('26','35')*s('35')+lstar('26','36')*s('36')+lstar('26','37')*s('37')+lstar('26','38')*s('38')+lstar('26','39')*s('39')+lstar('26','40')*s('40')+lstar('26','41')*s('41')+lstar('26','42')*s('42')+lstar('26','43')*s('43')+lstar('26','44')*s('44')+lstar('26','45')*s('45')+lstar('26','46')*s('46')+lstar('26','47')*s('47')+lstar('26','48')*s('48')+lstar('26','49')*s('49')+lstar('26','50')*s('50')+lstar('26','51')*s('51')+lstar('26','52')*s('52')+lstar('26','53')*s('53')+lstar('26','54')*s('54')+lstar('26','55')*s('55')+lstar('26','56')*s('56')+lstar('26','57')*s('57')+lstar('26','58')*s('58')+lstar('26','59')*s('59')+lstar('26','60')*s('60')+lstar('26','61')*s('61')+lstar('26','62')*s('62')+lstar('26','63')*s('63')+lstar('26','64')*s('64')+lstar('26','65')*s('65')+lstar('26','66')*s('66')+lstar('26','67')*s('67')+lstar('26','68')*s('68')+lstar('26','69')*s('69')+lstar('26','70')*s('70')+lstar('26','71')*s('71')+lstar('26','72')*s('72')+lstar('26','73')*s('73')+lstar('26','74')*s('74')-vcupstcut('26','1')*s('75')-vcupstcut('26','2')*s('76')-vcupstcut('26','3')*s('77')-vcupstcut('26','4')*s('78')-vcupstcut('26','5')*s('79')-vcupstcut('26','6')*s('80')-vcupstcut('26','7')*s('81')-vcupstcut('26','8')*s('82')-vcupstcut('26','9')*s('83')-vcupstcut('26','10')*s('84')-vcupstcut('26','11')*s('85')-vcupstcut('26','12')*s('86')-vcupstcut('26','13')*s('87')-vcupstcut('26','14')*s('88')-vcupstcut('26','15')*s('89')-vcupstcut('26','16')*s('90')-eqeconupstcut('26')*s('91');
equat27 ..    p2pf('27') =E= lstar('27','1')*s('1')+lstar('27','2')*s('2')+lstar('27','3')*s('3')+lstar('27','4')*s('4')+lstar('27','5')*s('5')+lstar('27','6')*s('6')+lstar('27','7')*s('7')+lstar('27','8')*s('8')+lstar('27','9')*s('9')+lstar('27','10')*s('10')+lstar('27','11')*s('11')+lstar('27','12')*s('12')+lstar('27','13')*s('13')+lstar('27','14')*s('14')+lstar('27','15')*s('15')+lstar('27','16')*s('16')+lstar('27','17')*s('17')+lstar('27','18')*s('18')+lstar('27','19')*s('19')+lstar('27','20')*s('20')+lstar('27','21')*s('21')+lstar('27','22')*s('22')+lstar('27','23')*s('23')+lstar('27','24')*s('24')+lstar('27','25')*s('25')+lstar('27','26')*s('26')+lstar('27','27')*s('27')+lstar('27','28')*s('28')+lstar('27','29')*s('29')+lstar('27','30')*s('30')+lstar('27','31')*s('31')+lstar('27','32')*s('32')+lstar('27','33')*s('33')+lstar('27','34')*s('34')+lstar('27','35')*s('35')+lstar('27','36')*s('36')+lstar('27','37')*s('37')+lstar('27','38')*s('38')+lstar('27','39')*s('39')+lstar('27','40')*s('40')+lstar('27','41')*s('41')+lstar('27','42')*s('42')+lstar('27','43')*s('43')+lstar('27','44')*s('44')+lstar('27','45')*s('45')+lstar('27','46')*s('46')+lstar('27','47')*s('47')+lstar('27','48')*s('48')+lstar('27','49')*s('49')+lstar('27','50')*s('50')+lstar('27','51')*s('51')+lstar('27','52')*s('52')+lstar('27','53')*s('53')+lstar('27','54')*s('54')+lstar('27','55')*s('55')+lstar('27','56')*s('56')+lstar('27','57')*s('57')+lstar('27','58')*s('58')+lstar('27','59')*s('59')+lstar('27','60')*s('60')+lstar('27','61')*s('61')+lstar('27','62')*s('62')+lstar('27','63')*s('63')+lstar('27','64')*s('64')+lstar('27','65')*s('65')+lstar('27','66')*s('66')+lstar('27','67')*s('67')+lstar('27','68')*s('68')+lstar('27','69')*s('69')+lstar('27','70')*s('70')+lstar('27','71')*s('71')+lstar('27','72')*s('72')+lstar('27','73')*s('73')+lstar('27','74')*s('74')-vcupstcut('27','1')*s('75')-vcupstcut('27','2')*s('76')-vcupstcut('27','3')*s('77')-vcupstcut('27','4')*s('78')-vcupstcut('27','5')*s('79')-vcupstcut('27','6')*s('80')-vcupstcut('27','7')*s('81')-vcupstcut('27','8')*s('82')-vcupstcut('27','9')*s('83')-vcupstcut('27','10')*s('84')-vcupstcut('27','11')*s('85')-vcupstcut('27','12')*s('86')-vcupstcut('27','13')*s('87')-vcupstcut('27','14')*s('88')-vcupstcut('27','15')*s('89')-vcupstcut('27','16')*s('90')-eqeconupstcut('27')*s('91');
equat28 ..    p2pf('28') =E= lstar('28','1')*s('1')+lstar('28','2')*s('2')+lstar('28','3')*s('3')+lstar('28','4')*s('4')+lstar('28','5')*s('5')+lstar('28','6')*s('6')+lstar('28','7')*s('7')+lstar('28','8')*s('8')+lstar('28','9')*s('9')+lstar('28','10')*s('10')+lstar('28','11')*s('11')+lstar('28','12')*s('12')+lstar('28','13')*s('13')+lstar('28','14')*s('14')+lstar('28','15')*s('15')+lstar('28','16')*s('16')+lstar('28','17')*s('17')+lstar('28','18')*s('18')+lstar('28','19')*s('19')+lstar('28','20')*s('20')+lstar('28','21')*s('21')+lstar('28','22')*s('22')+lstar('28','23')*s('23')+lstar('28','24')*s('24')+lstar('28','25')*s('25')+lstar('28','26')*s('26')+lstar('28','27')*s('27')+lstar('28','28')*s('28')+lstar('28','29')*s('29')+lstar('28','30')*s('30')+lstar('28','31')*s('31')+lstar('28','32')*s('32')+lstar('28','33')*s('33')+lstar('28','34')*s('34')+lstar('28','35')*s('35')+lstar('28','36')*s('36')+lstar('28','37')*s('37')+lstar('28','38')*s('38')+lstar('28','39')*s('39')+lstar('28','40')*s('40')+lstar('28','41')*s('41')+lstar('28','42')*s('42')+lstar('28','43')*s('43')+lstar('28','44')*s('44')+lstar('28','45')*s('45')+lstar('28','46')*s('46')+lstar('28','47')*s('47')+lstar('28','48')*s('48')+lstar('28','49')*s('49')+lstar('28','50')*s('50')+lstar('28','51')*s('51')+lstar('28','52')*s('52')+lstar('28','53')*s('53')+lstar('28','54')*s('54')+lstar('28','55')*s('55')+lstar('28','56')*s('56')+lstar('28','57')*s('57')+lstar('28','58')*s('58')+lstar('28','59')*s('59')+lstar('28','60')*s('60')+lstar('28','61')*s('61')+lstar('28','62')*s('62')+lstar('28','63')*s('63')+lstar('28','64')*s('64')+lstar('28','65')*s('65')+lstar('28','66')*s('66')+lstar('28','67')*s('67')+lstar('28','68')*s('68')+lstar('28','69')*s('69')+lstar('28','70')*s('70')+lstar('28','71')*s('71')+lstar('28','72')*s('72')+lstar('28','73')*s('73')+lstar('28','74')*s('74')-vcupstcut('28','1')*s('75')-vcupstcut('28','2')*s('76')-vcupstcut('28','3')*s('77')-vcupstcut('28','4')*s('78')-vcupstcut('28','5')*s('79')-vcupstcut('28','6')*s('80')-vcupstcut('28','7')*s('81')-vcupstcut('28','8')*s('82')-vcupstcut('28','9')*s('83')-vcupstcut('28','10')*s('84')-vcupstcut('28','11')*s('85')-vcupstcut('28','12')*s('86')-vcupstcut('28','13')*s('87')-vcupstcut('28','14')*s('88')-vcupstcut('28','15')*s('89')-vcupstcut('28','16')*s('90')-eqeconupstcut('28')*s('91');
equat29 ..    p2pf('29') =E= lstar('29','1')*s('1')+lstar('29','2')*s('2')+lstar('29','3')*s('3')+lstar('29','4')*s('4')+lstar('29','5')*s('5')+lstar('29','6')*s('6')+lstar('29','7')*s('7')+lstar('29','8')*s('8')+lstar('29','9')*s('9')+lstar('29','10')*s('10')+lstar('29','11')*s('11')+lstar('29','12')*s('12')+lstar('29','13')*s('13')+lstar('29','14')*s('14')+lstar('29','15')*s('15')+lstar('29','16')*s('16')+lstar('29','17')*s('17')+lstar('29','18')*s('18')+lstar('29','19')*s('19')+lstar('29','20')*s('20')+lstar('29','21')*s('21')+lstar('29','22')*s('22')+lstar('29','23')*s('23')+lstar('29','24')*s('24')+lstar('29','25')*s('25')+lstar('29','26')*s('26')+lstar('29','27')*s('27')+lstar('29','28')*s('28')+lstar('29','29')*s('29')+lstar('29','30')*s('30')+lstar('29','31')*s('31')+lstar('29','32')*s('32')+lstar('29','33')*s('33')+lstar('29','34')*s('34')+lstar('29','35')*s('35')+lstar('29','36')*s('36')+lstar('29','37')*s('37')+lstar('29','38')*s('38')+lstar('29','39')*s('39')+lstar('29','40')*s('40')+lstar('29','41')*s('41')+lstar('29','42')*s('42')+lstar('29','43')*s('43')+lstar('29','44')*s('44')+lstar('29','45')*s('45')+lstar('29','46')*s('46')+lstar('29','47')*s('47')+lstar('29','48')*s('48')+lstar('29','49')*s('49')+lstar('29','50')*s('50')+lstar('29','51')*s('51')+lstar('29','52')*s('52')+lstar('29','53')*s('53')+lstar('29','54')*s('54')+lstar('29','55')*s('55')+lstar('29','56')*s('56')+lstar('29','57')*s('57')+lstar('29','58')*s('58')+lstar('29','59')*s('59')+lstar('29','60')*s('60')+lstar('29','61')*s('61')+lstar('29','62')*s('62')+lstar('29','63')*s('63')+lstar('29','64')*s('64')+lstar('29','65')*s('65')+lstar('29','66')*s('66')+lstar('29','67')*s('67')+lstar('29','68')*s('68')+lstar('29','69')*s('69')+lstar('29','70')*s('70')+lstar('29','71')*s('71')+lstar('29','72')*s('72')+lstar('29','73')*s('73')+lstar('29','74')*s('74')-vcupstcut('29','1')*s('75')-vcupstcut('29','2')*s('76')-vcupstcut('29','3')*s('77')-vcupstcut('29','4')*s('78')-vcupstcut('29','5')*s('79')-vcupstcut('29','6')*s('80')-vcupstcut('29','7')*s('81')-vcupstcut('29','8')*s('82')-vcupstcut('29','9')*s('83')-vcupstcut('29','10')*s('84')-vcupstcut('29','11')*s('85')-vcupstcut('29','12')*s('86')-vcupstcut('29','13')*s('87')-vcupstcut('29','14')*s('88')-vcupstcut('29','15')*s('89')-vcupstcut('29','16')*s('90')-eqeconupstcut('29')*s('91');
equat30 ..    p2pf('30') =E= lstar('30','1')*s('1')+lstar('30','2')*s('2')+lstar('30','3')*s('3')+lstar('30','4')*s('4')+lstar('30','5')*s('5')+lstar('30','6')*s('6')+lstar('30','7')*s('7')+lstar('30','8')*s('8')+lstar('30','9')*s('9')+lstar('30','10')*s('10')+lstar('30','11')*s('11')+lstar('30','12')*s('12')+lstar('30','13')*s('13')+lstar('30','14')*s('14')+lstar('30','15')*s('15')+lstar('30','16')*s('16')+lstar('30','17')*s('17')+lstar('30','18')*s('18')+lstar('30','19')*s('19')+lstar('30','20')*s('20')+lstar('30','21')*s('21')+lstar('30','22')*s('22')+lstar('30','23')*s('23')+lstar('30','24')*s('24')+lstar('30','25')*s('25')+lstar('30','26')*s('26')+lstar('30','27')*s('27')+lstar('30','28')*s('28')+lstar('30','29')*s('29')+lstar('30','30')*s('30')+lstar('30','31')*s('31')+lstar('30','32')*s('32')+lstar('30','33')*s('33')+lstar('30','34')*s('34')+lstar('30','35')*s('35')+lstar('30','36')*s('36')+lstar('30','37')*s('37')+lstar('30','38')*s('38')+lstar('30','39')*s('39')+lstar('30','40')*s('40')+lstar('30','41')*s('41')+lstar('30','42')*s('42')+lstar('30','43')*s('43')+lstar('30','44')*s('44')+lstar('30','45')*s('45')+lstar('30','46')*s('46')+lstar('30','47')*s('47')+lstar('30','48')*s('48')+lstar('30','49')*s('49')+lstar('30','50')*s('50')+lstar('30','51')*s('51')+lstar('30','52')*s('52')+lstar('30','53')*s('53')+lstar('30','54')*s('54')+lstar('30','55')*s('55')+lstar('30','56')*s('56')+lstar('30','57')*s('57')+lstar('30','58')*s('58')+lstar('30','59')*s('59')+lstar('30','60')*s('60')+lstar('30','61')*s('61')+lstar('30','62')*s('62')+lstar('30','63')*s('63')+lstar('30','64')*s('64')+lstar('30','65')*s('65')+lstar('30','66')*s('66')+lstar('30','67')*s('67')+lstar('30','68')*s('68')+lstar('30','69')*s('69')+lstar('30','70')*s('70')+lstar('30','71')*s('71')+lstar('30','72')*s('72')+lstar('30','73')*s('73')+lstar('30','74')*s('74')-vcupstcut('30','1')*s('75')-vcupstcut('30','2')*s('76')-vcupstcut('30','3')*s('77')-vcupstcut('30','4')*s('78')-vcupstcut('30','5')*s('79')-vcupstcut('30','6')*s('80')-vcupstcut('30','7')*s('81')-vcupstcut('30','8')*s('82')-vcupstcut('30','9')*s('83')-vcupstcut('30','10')*s('84')-vcupstcut('30','11')*s('85')-vcupstcut('30','12')*s('86')-vcupstcut('30','13')*s('87')-vcupstcut('30','14')*s('88')-vcupstcut('30','15')*s('89')-vcupstcut('30','16')*s('90')-eqeconupstcut('30')*s('91');
equat31 ..    p2pf('31') =E= lstar('31','1')*s('1')+lstar('31','2')*s('2')+lstar('31','3')*s('3')+lstar('31','4')*s('4')+lstar('31','5')*s('5')+lstar('31','6')*s('6')+lstar('31','7')*s('7')+lstar('31','8')*s('8')+lstar('31','9')*s('9')+lstar('31','10')*s('10')+lstar('31','11')*s('11')+lstar('31','12')*s('12')+lstar('31','13')*s('13')+lstar('31','14')*s('14')+lstar('31','15')*s('15')+lstar('31','16')*s('16')+lstar('31','17')*s('17')+lstar('31','18')*s('18')+lstar('31','19')*s('19')+lstar('31','20')*s('20')+lstar('31','21')*s('21')+lstar('31','22')*s('22')+lstar('31','23')*s('23')+lstar('31','24')*s('24')+lstar('31','25')*s('25')+lstar('31','26')*s('26')+lstar('31','27')*s('27')+lstar('31','28')*s('28')+lstar('31','29')*s('29')+lstar('31','30')*s('30')+lstar('31','31')*s('31')+lstar('31','32')*s('32')+lstar('31','33')*s('33')+lstar('31','34')*s('34')+lstar('31','35')*s('35')+lstar('31','36')*s('36')+lstar('31','37')*s('37')+lstar('31','38')*s('38')+lstar('31','39')*s('39')+lstar('31','40')*s('40')+lstar('31','41')*s('41')+lstar('31','42')*s('42')+lstar('31','43')*s('43')+lstar('31','44')*s('44')+lstar('31','45')*s('45')+lstar('31','46')*s('46')+lstar('31','47')*s('47')+lstar('31','48')*s('48')+lstar('31','49')*s('49')+lstar('31','50')*s('50')+lstar('31','51')*s('51')+lstar('31','52')*s('52')+lstar('31','53')*s('53')+lstar('31','54')*s('54')+lstar('31','55')*s('55')+lstar('31','56')*s('56')+lstar('31','57')*s('57')+lstar('31','58')*s('58')+lstar('31','59')*s('59')+lstar('31','60')*s('60')+lstar('31','61')*s('61')+lstar('31','62')*s('62')+lstar('31','63')*s('63')+lstar('31','64')*s('64')+lstar('31','65')*s('65')+lstar('31','66')*s('66')+lstar('31','67')*s('67')+lstar('31','68')*s('68')+lstar('31','69')*s('69')+lstar('31','70')*s('70')+lstar('31','71')*s('71')+lstar('31','72')*s('72')+lstar('31','73')*s('73')+lstar('31','74')*s('74')-vcupstcut('31','1')*s('75')-vcupstcut('31','2')*s('76')-vcupstcut('31','3')*s('77')-vcupstcut('31','4')*s('78')-vcupstcut('31','5')*s('79')-vcupstcut('31','6')*s('80')-vcupstcut('31','7')*s('81')-vcupstcut('31','8')*s('82')-vcupstcut('31','9')*s('83')-vcupstcut('31','10')*s('84')-vcupstcut('31','11')*s('85')-vcupstcut('31','12')*s('86')-vcupstcut('31','13')*s('87')-vcupstcut('31','14')*s('88')-vcupstcut('31','15')*s('89')-vcupstcut('31','16')*s('90')-eqeconupstcut('31')*s('91');
equat32 ..    p2pf('32') =E= lstar('32','1')*s('1')+lstar('32','2')*s('2')+lstar('32','3')*s('3')+lstar('32','4')*s('4')+lstar('32','5')*s('5')+lstar('32','6')*s('6')+lstar('32','7')*s('7')+lstar('32','8')*s('8')+lstar('32','9')*s('9')+lstar('32','10')*s('10')+lstar('32','11')*s('11')+lstar('32','12')*s('12')+lstar('32','13')*s('13')+lstar('32','14')*s('14')+lstar('32','15')*s('15')+lstar('32','16')*s('16')+lstar('32','17')*s('17')+lstar('32','18')*s('18')+lstar('32','19')*s('19')+lstar('32','20')*s('20')+lstar('32','21')*s('21')+lstar('32','22')*s('22')+lstar('32','23')*s('23')+lstar('32','24')*s('24')+lstar('32','25')*s('25')+lstar('32','26')*s('26')+lstar('32','27')*s('27')+lstar('32','28')*s('28')+lstar('32','29')*s('29')+lstar('32','30')*s('30')+lstar('32','31')*s('31')+lstar('32','32')*s('32')+lstar('32','33')*s('33')+lstar('32','34')*s('34')+lstar('32','35')*s('35')+lstar('32','36')*s('36')+lstar('32','37')*s('37')+lstar('32','38')*s('38')+lstar('32','39')*s('39')+lstar('32','40')*s('40')+lstar('32','41')*s('41')+lstar('32','42')*s('42')+lstar('32','43')*s('43')+lstar('32','44')*s('44')+lstar('32','45')*s('45')+lstar('32','46')*s('46')+lstar('32','47')*s('47')+lstar('32','48')*s('48')+lstar('32','49')*s('49')+lstar('32','50')*s('50')+lstar('32','51')*s('51')+lstar('32','52')*s('52')+lstar('32','53')*s('53')+lstar('32','54')*s('54')+lstar('32','55')*s('55')+lstar('32','56')*s('56')+lstar('32','57')*s('57')+lstar('32','58')*s('58')+lstar('32','59')*s('59')+lstar('32','60')*s('60')+lstar('32','61')*s('61')+lstar('32','62')*s('62')+lstar('32','63')*s('63')+lstar('32','64')*s('64')+lstar('32','65')*s('65')+lstar('32','66')*s('66')+lstar('32','67')*s('67')+lstar('32','68')*s('68')+lstar('32','69')*s('69')+lstar('32','70')*s('70')+lstar('32','71')*s('71')+lstar('32','72')*s('72')+lstar('32','73')*s('73')+lstar('32','74')*s('74')-vcupstcut('32','1')*s('75')-vcupstcut('32','2')*s('76')-vcupstcut('32','3')*s('77')-vcupstcut('32','4')*s('78')-vcupstcut('32','5')*s('79')-vcupstcut('32','6')*s('80')-vcupstcut('32','7')*s('81')-vcupstcut('32','8')*s('82')-vcupstcut('32','9')*s('83')-vcupstcut('32','10')*s('84')-vcupstcut('32','11')*s('85')-vcupstcut('32','12')*s('86')-vcupstcut('32','13')*s('87')-vcupstcut('32','14')*s('88')-vcupstcut('32','15')*s('89')-vcupstcut('32','16')*s('90')-eqeconupstcut('32')*s('91');
equat33 ..    p2pf('33') =E= lstar('33','1')*s('1')+lstar('33','2')*s('2')+lstar('33','3')*s('3')+lstar('33','4')*s('4')+lstar('33','5')*s('5')+lstar('33','6')*s('6')+lstar('33','7')*s('7')+lstar('33','8')*s('8')+lstar('33','9')*s('9')+lstar('33','10')*s('10')+lstar('33','11')*s('11')+lstar('33','12')*s('12')+lstar('33','13')*s('13')+lstar('33','14')*s('14')+lstar('33','15')*s('15')+lstar('33','16')*s('16')+lstar('33','17')*s('17')+lstar('33','18')*s('18')+lstar('33','19')*s('19')+lstar('33','20')*s('20')+lstar('33','21')*s('21')+lstar('33','22')*s('22')+lstar('33','23')*s('23')+lstar('33','24')*s('24')+lstar('33','25')*s('25')+lstar('33','26')*s('26')+lstar('33','27')*s('27')+lstar('33','28')*s('28')+lstar('33','29')*s('29')+lstar('33','30')*s('30')+lstar('33','31')*s('31')+lstar('33','32')*s('32')+lstar('33','33')*s('33')+lstar('33','34')*s('34')+lstar('33','35')*s('35')+lstar('33','36')*s('36')+lstar('33','37')*s('37')+lstar('33','38')*s('38')+lstar('33','39')*s('39')+lstar('33','40')*s('40')+lstar('33','41')*s('41')+lstar('33','42')*s('42')+lstar('33','43')*s('43')+lstar('33','44')*s('44')+lstar('33','45')*s('45')+lstar('33','46')*s('46')+lstar('33','47')*s('47')+lstar('33','48')*s('48')+lstar('33','49')*s('49')+lstar('33','50')*s('50')+lstar('33','51')*s('51')+lstar('33','52')*s('52')+lstar('33','53')*s('53')+lstar('33','54')*s('54')+lstar('33','55')*s('55')+lstar('33','56')*s('56')+lstar('33','57')*s('57')+lstar('33','58')*s('58')+lstar('33','59')*s('59')+lstar('33','60')*s('60')+lstar('33','61')*s('61')+lstar('33','62')*s('62')+lstar('33','63')*s('63')+lstar('33','64')*s('64')+lstar('33','65')*s('65')+lstar('33','66')*s('66')+lstar('33','67')*s('67')+lstar('33','68')*s('68')+lstar('33','69')*s('69')+lstar('33','70')*s('70')+lstar('33','71')*s('71')+lstar('33','72')*s('72')+lstar('33','73')*s('73')+lstar('33','74')*s('74')-vcupstcut('33','1')*s('75')-vcupstcut('33','2')*s('76')-vcupstcut('33','3')*s('77')-vcupstcut('33','4')*s('78')-vcupstcut('33','5')*s('79')-vcupstcut('33','6')*s('80')-vcupstcut('33','7')*s('81')-vcupstcut('33','8')*s('82')-vcupstcut('33','9')*s('83')-vcupstcut('33','10')*s('84')-vcupstcut('33','11')*s('85')-vcupstcut('33','12')*s('86')-vcupstcut('33','13')*s('87')-vcupstcut('33','14')*s('88')-vcupstcut('33','15')*s('89')-vcupstcut('33','16')*s('90')-eqeconupstcut('33')*s('91');
equat34 ..    p2pf('34') =E= lstar('34','1')*s('1')+lstar('34','2')*s('2')+lstar('34','3')*s('3')+lstar('34','4')*s('4')+lstar('34','5')*s('5')+lstar('34','6')*s('6')+lstar('34','7')*s('7')+lstar('34','8')*s('8')+lstar('34','9')*s('9')+lstar('34','10')*s('10')+lstar('34','11')*s('11')+lstar('34','12')*s('12')+lstar('34','13')*s('13')+lstar('34','14')*s('14')+lstar('34','15')*s('15')+lstar('34','16')*s('16')+lstar('34','17')*s('17')+lstar('34','18')*s('18')+lstar('34','19')*s('19')+lstar('34','20')*s('20')+lstar('34','21')*s('21')+lstar('34','22')*s('22')+lstar('34','23')*s('23')+lstar('34','24')*s('24')+lstar('34','25')*s('25')+lstar('34','26')*s('26')+lstar('34','27')*s('27')+lstar('34','28')*s('28')+lstar('34','29')*s('29')+lstar('34','30')*s('30')+lstar('34','31')*s('31')+lstar('34','32')*s('32')+lstar('34','33')*s('33')+lstar('34','34')*s('34')+lstar('34','35')*s('35')+lstar('34','36')*s('36')+lstar('34','37')*s('37')+lstar('34','38')*s('38')+lstar('34','39')*s('39')+lstar('34','40')*s('40')+lstar('34','41')*s('41')+lstar('34','42')*s('42')+lstar('34','43')*s('43')+lstar('34','44')*s('44')+lstar('34','45')*s('45')+lstar('34','46')*s('46')+lstar('34','47')*s('47')+lstar('34','48')*s('48')+lstar('34','49')*s('49')+lstar('34','50')*s('50')+lstar('34','51')*s('51')+lstar('34','52')*s('52')+lstar('34','53')*s('53')+lstar('34','54')*s('54')+lstar('34','55')*s('55')+lstar('34','56')*s('56')+lstar('34','57')*s('57')+lstar('34','58')*s('58')+lstar('34','59')*s('59')+lstar('34','60')*s('60')+lstar('34','61')*s('61')+lstar('34','62')*s('62')+lstar('34','63')*s('63')+lstar('34','64')*s('64')+lstar('34','65')*s('65')+lstar('34','66')*s('66')+lstar('34','67')*s('67')+lstar('34','68')*s('68')+lstar('34','69')*s('69')+lstar('34','70')*s('70')+lstar('34','71')*s('71')+lstar('34','72')*s('72')+lstar('34','73')*s('73')+lstar('34','74')*s('74')-vcupstcut('34','1')*s('75')-vcupstcut('34','2')*s('76')-vcupstcut('34','3')*s('77')-vcupstcut('34','4')*s('78')-vcupstcut('34','5')*s('79')-vcupstcut('34','6')*s('80')-vcupstcut('34','7')*s('81')-vcupstcut('34','8')*s('82')-vcupstcut('34','9')*s('83')-vcupstcut('34','10')*s('84')-vcupstcut('34','11')*s('85')-vcupstcut('34','12')*s('86')-vcupstcut('34','13')*s('87')-vcupstcut('34','14')*s('88')-vcupstcut('34','15')*s('89')-vcupstcut('34','16')*s('90')-eqeconupstcut('34')*s('91');
equat35 ..    p2pf('35') =E= lstar('35','1')*s('1')+lstar('35','2')*s('2')+lstar('35','3')*s('3')+lstar('35','4')*s('4')+lstar('35','5')*s('5')+lstar('35','6')*s('6')+lstar('35','7')*s('7')+lstar('35','8')*s('8')+lstar('35','9')*s('9')+lstar('35','10')*s('10')+lstar('35','11')*s('11')+lstar('35','12')*s('12')+lstar('35','13')*s('13')+lstar('35','14')*s('14')+lstar('35','15')*s('15')+lstar('35','16')*s('16')+lstar('35','17')*s('17')+lstar('35','18')*s('18')+lstar('35','19')*s('19')+lstar('35','20')*s('20')+lstar('35','21')*s('21')+lstar('35','22')*s('22')+lstar('35','23')*s('23')+lstar('35','24')*s('24')+lstar('35','25')*s('25')+lstar('35','26')*s('26')+lstar('35','27')*s('27')+lstar('35','28')*s('28')+lstar('35','29')*s('29')+lstar('35','30')*s('30')+lstar('35','31')*s('31')+lstar('35','32')*s('32')+lstar('35','33')*s('33')+lstar('35','34')*s('34')+lstar('35','35')*s('35')+lstar('35','36')*s('36')+lstar('35','37')*s('37')+lstar('35','38')*s('38')+lstar('35','39')*s('39')+lstar('35','40')*s('40')+lstar('35','41')*s('41')+lstar('35','42')*s('42')+lstar('35','43')*s('43')+lstar('35','44')*s('44')+lstar('35','45')*s('45')+lstar('35','46')*s('46')+lstar('35','47')*s('47')+lstar('35','48')*s('48')+lstar('35','49')*s('49')+lstar('35','50')*s('50')+lstar('35','51')*s('51')+lstar('35','52')*s('52')+lstar('35','53')*s('53')+lstar('35','54')*s('54')+lstar('35','55')*s('55')+lstar('35','56')*s('56')+lstar('35','57')*s('57')+lstar('35','58')*s('58')+lstar('35','59')*s('59')+lstar('35','60')*s('60')+lstar('35','61')*s('61')+lstar('35','62')*s('62')+lstar('35','63')*s('63')+lstar('35','64')*s('64')+lstar('35','65')*s('65')+lstar('35','66')*s('66')+lstar('35','67')*s('67')+lstar('35','68')*s('68')+lstar('35','69')*s('69')+lstar('35','70')*s('70')+lstar('35','71')*s('71')+lstar('35','72')*s('72')+lstar('35','73')*s('73')+lstar('35','74')*s('74')-vcupstcut('35','1')*s('75')-vcupstcut('35','2')*s('76')-vcupstcut('35','3')*s('77')-vcupstcut('35','4')*s('78')-vcupstcut('35','5')*s('79')-vcupstcut('35','6')*s('80')-vcupstcut('35','7')*s('81')-vcupstcut('35','8')*s('82')-vcupstcut('35','9')*s('83')-vcupstcut('35','10')*s('84')-vcupstcut('35','11')*s('85')-vcupstcut('35','12')*s('86')-vcupstcut('35','13')*s('87')-vcupstcut('35','14')*s('88')-vcupstcut('35','15')*s('89')-vcupstcut('35','16')*s('90')-eqeconupstcut('35')*s('91');
equat36 ..    p2pf('36') =E= lstar('36','1')*s('1')+lstar('36','2')*s('2')+lstar('36','3')*s('3')+lstar('36','4')*s('4')+lstar('36','5')*s('5')+lstar('36','6')*s('6')+lstar('36','7')*s('7')+lstar('36','8')*s('8')+lstar('36','9')*s('9')+lstar('36','10')*s('10')+lstar('36','11')*s('11')+lstar('36','12')*s('12')+lstar('36','13')*s('13')+lstar('36','14')*s('14')+lstar('36','15')*s('15')+lstar('36','16')*s('16')+lstar('36','17')*s('17')+lstar('36','18')*s('18')+lstar('36','19')*s('19')+lstar('36','20')*s('20')+lstar('36','21')*s('21')+lstar('36','22')*s('22')+lstar('36','23')*s('23')+lstar('36','24')*s('24')+lstar('36','25')*s('25')+lstar('36','26')*s('26')+lstar('36','27')*s('27')+lstar('36','28')*s('28')+lstar('36','29')*s('29')+lstar('36','30')*s('30')+lstar('36','31')*s('31')+lstar('36','32')*s('32')+lstar('36','33')*s('33')+lstar('36','34')*s('34')+lstar('36','35')*s('35')+lstar('36','36')*s('36')+lstar('36','37')*s('37')+lstar('36','38')*s('38')+lstar('36','39')*s('39')+lstar('36','40')*s('40')+lstar('36','41')*s('41')+lstar('36','42')*s('42')+lstar('36','43')*s('43')+lstar('36','44')*s('44')+lstar('36','45')*s('45')+lstar('36','46')*s('46')+lstar('36','47')*s('47')+lstar('36','48')*s('48')+lstar('36','49')*s('49')+lstar('36','50')*s('50')+lstar('36','51')*s('51')+lstar('36','52')*s('52')+lstar('36','53')*s('53')+lstar('36','54')*s('54')+lstar('36','55')*s('55')+lstar('36','56')*s('56')+lstar('36','57')*s('57')+lstar('36','58')*s('58')+lstar('36','59')*s('59')+lstar('36','60')*s('60')+lstar('36','61')*s('61')+lstar('36','62')*s('62')+lstar('36','63')*s('63')+lstar('36','64')*s('64')+lstar('36','65')*s('65')+lstar('36','66')*s('66')+lstar('36','67')*s('67')+lstar('36','68')*s('68')+lstar('36','69')*s('69')+lstar('36','70')*s('70')+lstar('36','71')*s('71')+lstar('36','72')*s('72')+lstar('36','73')*s('73')+lstar('36','74')*s('74')-vcupstcut('36','1')*s('75')-vcupstcut('36','2')*s('76')-vcupstcut('36','3')*s('77')-vcupstcut('36','4')*s('78')-vcupstcut('36','5')*s('79')-vcupstcut('36','6')*s('80')-vcupstcut('36','7')*s('81')-vcupstcut('36','8')*s('82')-vcupstcut('36','9')*s('83')-vcupstcut('36','10')*s('84')-vcupstcut('36','11')*s('85')-vcupstcut('36','12')*s('86')-vcupstcut('36','13')*s('87')-vcupstcut('36','14')*s('88')-vcupstcut('36','15')*s('89')-vcupstcut('36','16')*s('90')-eqeconupstcut('36')*s('91');
equat37 ..    p2pf('37') =E= lstar('37','1')*s('1')+lstar('37','2')*s('2')+lstar('37','3')*s('3')+lstar('37','4')*s('4')+lstar('37','5')*s('5')+lstar('37','6')*s('6')+lstar('37','7')*s('7')+lstar('37','8')*s('8')+lstar('37','9')*s('9')+lstar('37','10')*s('10')+lstar('37','11')*s('11')+lstar('37','12')*s('12')+lstar('37','13')*s('13')+lstar('37','14')*s('14')+lstar('37','15')*s('15')+lstar('37','16')*s('16')+lstar('37','17')*s('17')+lstar('37','18')*s('18')+lstar('37','19')*s('19')+lstar('37','20')*s('20')+lstar('37','21')*s('21')+lstar('37','22')*s('22')+lstar('37','23')*s('23')+lstar('37','24')*s('24')+lstar('37','25')*s('25')+lstar('37','26')*s('26')+lstar('37','27')*s('27')+lstar('37','28')*s('28')+lstar('37','29')*s('29')+lstar('37','30')*s('30')+lstar('37','31')*s('31')+lstar('37','32')*s('32')+lstar('37','33')*s('33')+lstar('37','34')*s('34')+lstar('37','35')*s('35')+lstar('37','36')*s('36')+lstar('37','37')*s('37')+lstar('37','38')*s('38')+lstar('37','39')*s('39')+lstar('37','40')*s('40')+lstar('37','41')*s('41')+lstar('37','42')*s('42')+lstar('37','43')*s('43')+lstar('37','44')*s('44')+lstar('37','45')*s('45')+lstar('37','46')*s('46')+lstar('37','47')*s('47')+lstar('37','48')*s('48')+lstar('37','49')*s('49')+lstar('37','50')*s('50')+lstar('37','51')*s('51')+lstar('37','52')*s('52')+lstar('37','53')*s('53')+lstar('37','54')*s('54')+lstar('37','55')*s('55')+lstar('37','56')*s('56')+lstar('37','57')*s('57')+lstar('37','58')*s('58')+lstar('37','59')*s('59')+lstar('37','60')*s('60')+lstar('37','61')*s('61')+lstar('37','62')*s('62')+lstar('37','63')*s('63')+lstar('37','64')*s('64')+lstar('37','65')*s('65')+lstar('37','66')*s('66')+lstar('37','67')*s('67')+lstar('37','68')*s('68')+lstar('37','69')*s('69')+lstar('37','70')*s('70')+lstar('37','71')*s('71')+lstar('37','72')*s('72')+lstar('37','73')*s('73')+lstar('37','74')*s('74')-vcupstcut('37','1')*s('75')-vcupstcut('37','2')*s('76')-vcupstcut('37','3')*s('77')-vcupstcut('37','4')*s('78')-vcupstcut('37','5')*s('79')-vcupstcut('37','6')*s('80')-vcupstcut('37','7')*s('81')-vcupstcut('37','8')*s('82')-vcupstcut('37','9')*s('83')-vcupstcut('37','10')*s('84')-vcupstcut('37','11')*s('85')-vcupstcut('37','12')*s('86')-vcupstcut('37','13')*s('87')-vcupstcut('37','14')*s('88')-vcupstcut('37','15')*s('89')-vcupstcut('37','16')*s('90')-eqeconupstcut('37')*s('91');
equat38 ..    p2pf('38') =E= lstar('38','1')*s('1')+lstar('38','2')*s('2')+lstar('38','3')*s('3')+lstar('38','4')*s('4')+lstar('38','5')*s('5')+lstar('38','6')*s('6')+lstar('38','7')*s('7')+lstar('38','8')*s('8')+lstar('38','9')*s('9')+lstar('38','10')*s('10')+lstar('38','11')*s('11')+lstar('38','12')*s('12')+lstar('38','13')*s('13')+lstar('38','14')*s('14')+lstar('38','15')*s('15')+lstar('38','16')*s('16')+lstar('38','17')*s('17')+lstar('38','18')*s('18')+lstar('38','19')*s('19')+lstar('38','20')*s('20')+lstar('38','21')*s('21')+lstar('38','22')*s('22')+lstar('38','23')*s('23')+lstar('38','24')*s('24')+lstar('38','25')*s('25')+lstar('38','26')*s('26')+lstar('38','27')*s('27')+lstar('38','28')*s('28')+lstar('38','29')*s('29')+lstar('38','30')*s('30')+lstar('38','31')*s('31')+lstar('38','32')*s('32')+lstar('38','33')*s('33')+lstar('38','34')*s('34')+lstar('38','35')*s('35')+lstar('38','36')*s('36')+lstar('38','37')*s('37')+lstar('38','38')*s('38')+lstar('38','39')*s('39')+lstar('38','40')*s('40')+lstar('38','41')*s('41')+lstar('38','42')*s('42')+lstar('38','43')*s('43')+lstar('38','44')*s('44')+lstar('38','45')*s('45')+lstar('38','46')*s('46')+lstar('38','47')*s('47')+lstar('38','48')*s('48')+lstar('38','49')*s('49')+lstar('38','50')*s('50')+lstar('38','51')*s('51')+lstar('38','52')*s('52')+lstar('38','53')*s('53')+lstar('38','54')*s('54')+lstar('38','55')*s('55')+lstar('38','56')*s('56')+lstar('38','57')*s('57')+lstar('38','58')*s('58')+lstar('38','59')*s('59')+lstar('38','60')*s('60')+lstar('38','61')*s('61')+lstar('38','62')*s('62')+lstar('38','63')*s('63')+lstar('38','64')*s('64')+lstar('38','65')*s('65')+lstar('38','66')*s('66')+lstar('38','67')*s('67')+lstar('38','68')*s('68')+lstar('38','69')*s('69')+lstar('38','70')*s('70')+lstar('38','71')*s('71')+lstar('38','72')*s('72')+lstar('38','73')*s('73')+lstar('38','74')*s('74')-vcupstcut('38','1')*s('75')-vcupstcut('38','2')*s('76')-vcupstcut('38','3')*s('77')-vcupstcut('38','4')*s('78')-vcupstcut('38','5')*s('79')-vcupstcut('38','6')*s('80')-vcupstcut('38','7')*s('81')-vcupstcut('38','8')*s('82')-vcupstcut('38','9')*s('83')-vcupstcut('38','10')*s('84')-vcupstcut('38','11')*s('85')-vcupstcut('38','12')*s('86')-vcupstcut('38','13')*s('87')-vcupstcut('38','14')*s('88')-vcupstcut('38','15')*s('89')-vcupstcut('38','16')*s('90')-eqeconupstcut('38')*s('91');
equat39 ..    p2pf('39') =E= lstar('39','1')*s('1')+lstar('39','2')*s('2')+lstar('39','3')*s('3')+lstar('39','4')*s('4')+lstar('39','5')*s('5')+lstar('39','6')*s('6')+lstar('39','7')*s('7')+lstar('39','8')*s('8')+lstar('39','9')*s('9')+lstar('39','10')*s('10')+lstar('39','11')*s('11')+lstar('39','12')*s('12')+lstar('39','13')*s('13')+lstar('39','14')*s('14')+lstar('39','15')*s('15')+lstar('39','16')*s('16')+lstar('39','17')*s('17')+lstar('39','18')*s('18')+lstar('39','19')*s('19')+lstar('39','20')*s('20')+lstar('39','21')*s('21')+lstar('39','22')*s('22')+lstar('39','23')*s('23')+lstar('39','24')*s('24')+lstar('39','25')*s('25')+lstar('39','26')*s('26')+lstar('39','27')*s('27')+lstar('39','28')*s('28')+lstar('39','29')*s('29')+lstar('39','30')*s('30')+lstar('39','31')*s('31')+lstar('39','32')*s('32')+lstar('39','33')*s('33')+lstar('39','34')*s('34')+lstar('39','35')*s('35')+lstar('39','36')*s('36')+lstar('39','37')*s('37')+lstar('39','38')*s('38')+lstar('39','39')*s('39')+lstar('39','40')*s('40')+lstar('39','41')*s('41')+lstar('39','42')*s('42')+lstar('39','43')*s('43')+lstar('39','44')*s('44')+lstar('39','45')*s('45')+lstar('39','46')*s('46')+lstar('39','47')*s('47')+lstar('39','48')*s('48')+lstar('39','49')*s('49')+lstar('39','50')*s('50')+lstar('39','51')*s('51')+lstar('39','52')*s('52')+lstar('39','53')*s('53')+lstar('39','54')*s('54')+lstar('39','55')*s('55')+lstar('39','56')*s('56')+lstar('39','57')*s('57')+lstar('39','58')*s('58')+lstar('39','59')*s('59')+lstar('39','60')*s('60')+lstar('39','61')*s('61')+lstar('39','62')*s('62')+lstar('39','63')*s('63')+lstar('39','64')*s('64')+lstar('39','65')*s('65')+lstar('39','66')*s('66')+lstar('39','67')*s('67')+lstar('39','68')*s('68')+lstar('39','69')*s('69')+lstar('39','70')*s('70')+lstar('39','71')*s('71')+lstar('39','72')*s('72')+lstar('39','73')*s('73')+lstar('39','74')*s('74')-vcupstcut('39','1')*s('75')-vcupstcut('39','2')*s('76')-vcupstcut('39','3')*s('77')-vcupstcut('39','4')*s('78')-vcupstcut('39','5')*s('79')-vcupstcut('39','6')*s('80')-vcupstcut('39','7')*s('81')-vcupstcut('39','8')*s('82')-vcupstcut('39','9')*s('83')-vcupstcut('39','10')*s('84')-vcupstcut('39','11')*s('85')-vcupstcut('39','12')*s('86')-vcupstcut('39','13')*s('87')-vcupstcut('39','14')*s('88')-vcupstcut('39','15')*s('89')-vcupstcut('39','16')*s('90')-eqeconupstcut('39')*s('91');
equat40 ..    p2pf('40') =E= lstar('40','1')*s('1')+lstar('40','2')*s('2')+lstar('40','3')*s('3')+lstar('40','4')*s('4')+lstar('40','5')*s('5')+lstar('40','6')*s('6')+lstar('40','7')*s('7')+lstar('40','8')*s('8')+lstar('40','9')*s('9')+lstar('40','10')*s('10')+lstar('40','11')*s('11')+lstar('40','12')*s('12')+lstar('40','13')*s('13')+lstar('40','14')*s('14')+lstar('40','15')*s('15')+lstar('40','16')*s('16')+lstar('40','17')*s('17')+lstar('40','18')*s('18')+lstar('40','19')*s('19')+lstar('40','20')*s('20')+lstar('40','21')*s('21')+lstar('40','22')*s('22')+lstar('40','23')*s('23')+lstar('40','24')*s('24')+lstar('40','25')*s('25')+lstar('40','26')*s('26')+lstar('40','27')*s('27')+lstar('40','28')*s('28')+lstar('40','29')*s('29')+lstar('40','30')*s('30')+lstar('40','31')*s('31')+lstar('40','32')*s('32')+lstar('40','33')*s('33')+lstar('40','34')*s('34')+lstar('40','35')*s('35')+lstar('40','36')*s('36')+lstar('40','37')*s('37')+lstar('40','38')*s('38')+lstar('40','39')*s('39')+lstar('40','40')*s('40')+lstar('40','41')*s('41')+lstar('40','42')*s('42')+lstar('40','43')*s('43')+lstar('40','44')*s('44')+lstar('40','45')*s('45')+lstar('40','46')*s('46')+lstar('40','47')*s('47')+lstar('40','48')*s('48')+lstar('40','49')*s('49')+lstar('40','50')*s('50')+lstar('40','51')*s('51')+lstar('40','52')*s('52')+lstar('40','53')*s('53')+lstar('40','54')*s('54')+lstar('40','55')*s('55')+lstar('40','56')*s('56')+lstar('40','57')*s('57')+lstar('40','58')*s('58')+lstar('40','59')*s('59')+lstar('40','60')*s('60')+lstar('40','61')*s('61')+lstar('40','62')*s('62')+lstar('40','63')*s('63')+lstar('40','64')*s('64')+lstar('40','65')*s('65')+lstar('40','66')*s('66')+lstar('40','67')*s('67')+lstar('40','68')*s('68')+lstar('40','69')*s('69')+lstar('40','70')*s('70')+lstar('40','71')*s('71')+lstar('40','72')*s('72')+lstar('40','73')*s('73')+lstar('40','74')*s('74')-vcupstcut('40','1')*s('75')-vcupstcut('40','2')*s('76')-vcupstcut('40','3')*s('77')-vcupstcut('40','4')*s('78')-vcupstcut('40','5')*s('79')-vcupstcut('40','6')*s('80')-vcupstcut('40','7')*s('81')-vcupstcut('40','8')*s('82')-vcupstcut('40','9')*s('83')-vcupstcut('40','10')*s('84')-vcupstcut('40','11')*s('85')-vcupstcut('40','12')*s('86')-vcupstcut('40','13')*s('87')-vcupstcut('40','14')*s('88')-vcupstcut('40','15')*s('89')-vcupstcut('40','16')*s('90')-eqeconupstcut('40')*s('91');
equat41 ..    p2pf('41') =E= lstar('41','1')*s('1')+lstar('41','2')*s('2')+lstar('41','3')*s('3')+lstar('41','4')*s('4')+lstar('41','5')*s('5')+lstar('41','6')*s('6')+lstar('41','7')*s('7')+lstar('41','8')*s('8')+lstar('41','9')*s('9')+lstar('41','10')*s('10')+lstar('41','11')*s('11')+lstar('41','12')*s('12')+lstar('41','13')*s('13')+lstar('41','14')*s('14')+lstar('41','15')*s('15')+lstar('41','16')*s('16')+lstar('41','17')*s('17')+lstar('41','18')*s('18')+lstar('41','19')*s('19')+lstar('41','20')*s('20')+lstar('41','21')*s('21')+lstar('41','22')*s('22')+lstar('41','23')*s('23')+lstar('41','24')*s('24')+lstar('41','25')*s('25')+lstar('41','26')*s('26')+lstar('41','27')*s('27')+lstar('41','28')*s('28')+lstar('41','29')*s('29')+lstar('41','30')*s('30')+lstar('41','31')*s('31')+lstar('41','32')*s('32')+lstar('41','33')*s('33')+lstar('41','34')*s('34')+lstar('41','35')*s('35')+lstar('41','36')*s('36')+lstar('41','37')*s('37')+lstar('41','38')*s('38')+lstar('41','39')*s('39')+lstar('41','40')*s('40')+lstar('41','41')*s('41')+lstar('41','42')*s('42')+lstar('41','43')*s('43')+lstar('41','44')*s('44')+lstar('41','45')*s('45')+lstar('41','46')*s('46')+lstar('41','47')*s('47')+lstar('41','48')*s('48')+lstar('41','49')*s('49')+lstar('41','50')*s('50')+lstar('41','51')*s('51')+lstar('41','52')*s('52')+lstar('41','53')*s('53')+lstar('41','54')*s('54')+lstar('41','55')*s('55')+lstar('41','56')*s('56')+lstar('41','57')*s('57')+lstar('41','58')*s('58')+lstar('41','59')*s('59')+lstar('41','60')*s('60')+lstar('41','61')*s('61')+lstar('41','62')*s('62')+lstar('41','63')*s('63')+lstar('41','64')*s('64')+lstar('41','65')*s('65')+lstar('41','66')*s('66')+lstar('41','67')*s('67')+lstar('41','68')*s('68')+lstar('41','69')*s('69')+lstar('41','70')*s('70')+lstar('41','71')*s('71')+lstar('41','72')*s('72')+lstar('41','73')*s('73')+lstar('41','74')*s('74')-vcupstcut('41','1')*s('75')-vcupstcut('41','2')*s('76')-vcupstcut('41','3')*s('77')-vcupstcut('41','4')*s('78')-vcupstcut('41','5')*s('79')-vcupstcut('41','6')*s('80')-vcupstcut('41','7')*s('81')-vcupstcut('41','8')*s('82')-vcupstcut('41','9')*s('83')-vcupstcut('41','10')*s('84')-vcupstcut('41','11')*s('85')-vcupstcut('41','12')*s('86')-vcupstcut('41','13')*s('87')-vcupstcut('41','14')*s('88')-vcupstcut('41','15')*s('89')-vcupstcut('41','16')*s('90')-eqeconupstcut('41')*s('91');
equat42 ..    p2pf('42') =E= lstar('42','1')*s('1')+lstar('42','2')*s('2')+lstar('42','3')*s('3')+lstar('42','4')*s('4')+lstar('42','5')*s('5')+lstar('42','6')*s('6')+lstar('42','7')*s('7')+lstar('42','8')*s('8')+lstar('42','9')*s('9')+lstar('42','10')*s('10')+lstar('42','11')*s('11')+lstar('42','12')*s('12')+lstar('42','13')*s('13')+lstar('42','14')*s('14')+lstar('42','15')*s('15')+lstar('42','16')*s('16')+lstar('42','17')*s('17')+lstar('42','18')*s('18')+lstar('42','19')*s('19')+lstar('42','20')*s('20')+lstar('42','21')*s('21')+lstar('42','22')*s('22')+lstar('42','23')*s('23')+lstar('42','24')*s('24')+lstar('42','25')*s('25')+lstar('42','26')*s('26')+lstar('42','27')*s('27')+lstar('42','28')*s('28')+lstar('42','29')*s('29')+lstar('42','30')*s('30')+lstar('42','31')*s('31')+lstar('42','32')*s('32')+lstar('42','33')*s('33')+lstar('42','34')*s('34')+lstar('42','35')*s('35')+lstar('42','36')*s('36')+lstar('42','37')*s('37')+lstar('42','38')*s('38')+lstar('42','39')*s('39')+lstar('42','40')*s('40')+lstar('42','41')*s('41')+lstar('42','42')*s('42')+lstar('42','43')*s('43')+lstar('42','44')*s('44')+lstar('42','45')*s('45')+lstar('42','46')*s('46')+lstar('42','47')*s('47')+lstar('42','48')*s('48')+lstar('42','49')*s('49')+lstar('42','50')*s('50')+lstar('42','51')*s('51')+lstar('42','52')*s('52')+lstar('42','53')*s('53')+lstar('42','54')*s('54')+lstar('42','55')*s('55')+lstar('42','56')*s('56')+lstar('42','57')*s('57')+lstar('42','58')*s('58')+lstar('42','59')*s('59')+lstar('42','60')*s('60')+lstar('42','61')*s('61')+lstar('42','62')*s('62')+lstar('42','63')*s('63')+lstar('42','64')*s('64')+lstar('42','65')*s('65')+lstar('42','66')*s('66')+lstar('42','67')*s('67')+lstar('42','68')*s('68')+lstar('42','69')*s('69')+lstar('42','70')*s('70')+lstar('42','71')*s('71')+lstar('42','72')*s('72')+lstar('42','73')*s('73')+lstar('42','74')*s('74')-vcupstcut('42','1')*s('75')-vcupstcut('42','2')*s('76')-vcupstcut('42','3')*s('77')-vcupstcut('42','4')*s('78')-vcupstcut('42','5')*s('79')-vcupstcut('42','6')*s('80')-vcupstcut('42','7')*s('81')-vcupstcut('42','8')*s('82')-vcupstcut('42','9')*s('83')-vcupstcut('42','10')*s('84')-vcupstcut('42','11')*s('85')-vcupstcut('42','12')*s('86')-vcupstcut('42','13')*s('87')-vcupstcut('42','14')*s('88')-vcupstcut('42','15')*s('89')-vcupstcut('42','16')*s('90')-eqeconupstcut('42')*s('91');
equat43 ..    p2pf('43') =E= lstar('43','1')*s('1')+lstar('43','2')*s('2')+lstar('43','3')*s('3')+lstar('43','4')*s('4')+lstar('43','5')*s('5')+lstar('43','6')*s('6')+lstar('43','7')*s('7')+lstar('43','8')*s('8')+lstar('43','9')*s('9')+lstar('43','10')*s('10')+lstar('43','11')*s('11')+lstar('43','12')*s('12')+lstar('43','13')*s('13')+lstar('43','14')*s('14')+lstar('43','15')*s('15')+lstar('43','16')*s('16')+lstar('43','17')*s('17')+lstar('43','18')*s('18')+lstar('43','19')*s('19')+lstar('43','20')*s('20')+lstar('43','21')*s('21')+lstar('43','22')*s('22')+lstar('43','23')*s('23')+lstar('43','24')*s('24')+lstar('43','25')*s('25')+lstar('43','26')*s('26')+lstar('43','27')*s('27')+lstar('43','28')*s('28')+lstar('43','29')*s('29')+lstar('43','30')*s('30')+lstar('43','31')*s('31')+lstar('43','32')*s('32')+lstar('43','33')*s('33')+lstar('43','34')*s('34')+lstar('43','35')*s('35')+lstar('43','36')*s('36')+lstar('43','37')*s('37')+lstar('43','38')*s('38')+lstar('43','39')*s('39')+lstar('43','40')*s('40')+lstar('43','41')*s('41')+lstar('43','42')*s('42')+lstar('43','43')*s('43')+lstar('43','44')*s('44')+lstar('43','45')*s('45')+lstar('43','46')*s('46')+lstar('43','47')*s('47')+lstar('43','48')*s('48')+lstar('43','49')*s('49')+lstar('43','50')*s('50')+lstar('43','51')*s('51')+lstar('43','52')*s('52')+lstar('43','53')*s('53')+lstar('43','54')*s('54')+lstar('43','55')*s('55')+lstar('43','56')*s('56')+lstar('43','57')*s('57')+lstar('43','58')*s('58')+lstar('43','59')*s('59')+lstar('43','60')*s('60')+lstar('43','61')*s('61')+lstar('43','62')*s('62')+lstar('43','63')*s('63')+lstar('43','64')*s('64')+lstar('43','65')*s('65')+lstar('43','66')*s('66')+lstar('43','67')*s('67')+lstar('43','68')*s('68')+lstar('43','69')*s('69')+lstar('43','70')*s('70')+lstar('43','71')*s('71')+lstar('43','72')*s('72')+lstar('43','73')*s('73')+lstar('43','74')*s('74')-vcupstcut('43','1')*s('75')-vcupstcut('43','2')*s('76')-vcupstcut('43','3')*s('77')-vcupstcut('43','4')*s('78')-vcupstcut('43','5')*s('79')-vcupstcut('43','6')*s('80')-vcupstcut('43','7')*s('81')-vcupstcut('43','8')*s('82')-vcupstcut('43','9')*s('83')-vcupstcut('43','10')*s('84')-vcupstcut('43','11')*s('85')-vcupstcut('43','12')*s('86')-vcupstcut('43','13')*s('87')-vcupstcut('43','14')*s('88')-vcupstcut('43','15')*s('89')-vcupstcut('43','16')*s('90')-eqeconupstcut('43')*s('91');
equat44 ..    p2pf('44') =E= lstar('44','1')*s('1')+lstar('44','2')*s('2')+lstar('44','3')*s('3')+lstar('44','4')*s('4')+lstar('44','5')*s('5')+lstar('44','6')*s('6')+lstar('44','7')*s('7')+lstar('44','8')*s('8')+lstar('44','9')*s('9')+lstar('44','10')*s('10')+lstar('44','11')*s('11')+lstar('44','12')*s('12')+lstar('44','13')*s('13')+lstar('44','14')*s('14')+lstar('44','15')*s('15')+lstar('44','16')*s('16')+lstar('44','17')*s('17')+lstar('44','18')*s('18')+lstar('44','19')*s('19')+lstar('44','20')*s('20')+lstar('44','21')*s('21')+lstar('44','22')*s('22')+lstar('44','23')*s('23')+lstar('44','24')*s('24')+lstar('44','25')*s('25')+lstar('44','26')*s('26')+lstar('44','27')*s('27')+lstar('44','28')*s('28')+lstar('44','29')*s('29')+lstar('44','30')*s('30')+lstar('44','31')*s('31')+lstar('44','32')*s('32')+lstar('44','33')*s('33')+lstar('44','34')*s('34')+lstar('44','35')*s('35')+lstar('44','36')*s('36')+lstar('44','37')*s('37')+lstar('44','38')*s('38')+lstar('44','39')*s('39')+lstar('44','40')*s('40')+lstar('44','41')*s('41')+lstar('44','42')*s('42')+lstar('44','43')*s('43')+lstar('44','44')*s('44')+lstar('44','45')*s('45')+lstar('44','46')*s('46')+lstar('44','47')*s('47')+lstar('44','48')*s('48')+lstar('44','49')*s('49')+lstar('44','50')*s('50')+lstar('44','51')*s('51')+lstar('44','52')*s('52')+lstar('44','53')*s('53')+lstar('44','54')*s('54')+lstar('44','55')*s('55')+lstar('44','56')*s('56')+lstar('44','57')*s('57')+lstar('44','58')*s('58')+lstar('44','59')*s('59')+lstar('44','60')*s('60')+lstar('44','61')*s('61')+lstar('44','62')*s('62')+lstar('44','63')*s('63')+lstar('44','64')*s('64')+lstar('44','65')*s('65')+lstar('44','66')*s('66')+lstar('44','67')*s('67')+lstar('44','68')*s('68')+lstar('44','69')*s('69')+lstar('44','70')*s('70')+lstar('44','71')*s('71')+lstar('44','72')*s('72')+lstar('44','73')*s('73')+lstar('44','74')*s('74')-vcupstcut('44','1')*s('75')-vcupstcut('44','2')*s('76')-vcupstcut('44','3')*s('77')-vcupstcut('44','4')*s('78')-vcupstcut('44','5')*s('79')-vcupstcut('44','6')*s('80')-vcupstcut('44','7')*s('81')-vcupstcut('44','8')*s('82')-vcupstcut('44','9')*s('83')-vcupstcut('44','10')*s('84')-vcupstcut('44','11')*s('85')-vcupstcut('44','12')*s('86')-vcupstcut('44','13')*s('87')-vcupstcut('44','14')*s('88')-vcupstcut('44','15')*s('89')-vcupstcut('44','16')*s('90')-eqeconupstcut('44')*s('91');
equat45 ..    p2pf('45') =E= lstar('45','1')*s('1')+lstar('45','2')*s('2')+lstar('45','3')*s('3')+lstar('45','4')*s('4')+lstar('45','5')*s('5')+lstar('45','6')*s('6')+lstar('45','7')*s('7')+lstar('45','8')*s('8')+lstar('45','9')*s('9')+lstar('45','10')*s('10')+lstar('45','11')*s('11')+lstar('45','12')*s('12')+lstar('45','13')*s('13')+lstar('45','14')*s('14')+lstar('45','15')*s('15')+lstar('45','16')*s('16')+lstar('45','17')*s('17')+lstar('45','18')*s('18')+lstar('45','19')*s('19')+lstar('45','20')*s('20')+lstar('45','21')*s('21')+lstar('45','22')*s('22')+lstar('45','23')*s('23')+lstar('45','24')*s('24')+lstar('45','25')*s('25')+lstar('45','26')*s('26')+lstar('45','27')*s('27')+lstar('45','28')*s('28')+lstar('45','29')*s('29')+lstar('45','30')*s('30')+lstar('45','31')*s('31')+lstar('45','32')*s('32')+lstar('45','33')*s('33')+lstar('45','34')*s('34')+lstar('45','35')*s('35')+lstar('45','36')*s('36')+lstar('45','37')*s('37')+lstar('45','38')*s('38')+lstar('45','39')*s('39')+lstar('45','40')*s('40')+lstar('45','41')*s('41')+lstar('45','42')*s('42')+lstar('45','43')*s('43')+lstar('45','44')*s('44')+lstar('45','45')*s('45')+lstar('45','46')*s('46')+lstar('45','47')*s('47')+lstar('45','48')*s('48')+lstar('45','49')*s('49')+lstar('45','50')*s('50')+lstar('45','51')*s('51')+lstar('45','52')*s('52')+lstar('45','53')*s('53')+lstar('45','54')*s('54')+lstar('45','55')*s('55')+lstar('45','56')*s('56')+lstar('45','57')*s('57')+lstar('45','58')*s('58')+lstar('45','59')*s('59')+lstar('45','60')*s('60')+lstar('45','61')*s('61')+lstar('45','62')*s('62')+lstar('45','63')*s('63')+lstar('45','64')*s('64')+lstar('45','65')*s('65')+lstar('45','66')*s('66')+lstar('45','67')*s('67')+lstar('45','68')*s('68')+lstar('45','69')*s('69')+lstar('45','70')*s('70')+lstar('45','71')*s('71')+lstar('45','72')*s('72')+lstar('45','73')*s('73')+lstar('45','74')*s('74')-vcupstcut('45','1')*s('75')-vcupstcut('45','2')*s('76')-vcupstcut('45','3')*s('77')-vcupstcut('45','4')*s('78')-vcupstcut('45','5')*s('79')-vcupstcut('45','6')*s('80')-vcupstcut('45','7')*s('81')-vcupstcut('45','8')*s('82')-vcupstcut('45','9')*s('83')-vcupstcut('45','10')*s('84')-vcupstcut('45','11')*s('85')-vcupstcut('45','12')*s('86')-vcupstcut('45','13')*s('87')-vcupstcut('45','14')*s('88')-vcupstcut('45','15')*s('89')-vcupstcut('45','16')*s('90')-eqeconupstcut('45')*s('91');
equat46 ..    p2pf('46') =E= lstar('46','1')*s('1')+lstar('46','2')*s('2')+lstar('46','3')*s('3')+lstar('46','4')*s('4')+lstar('46','5')*s('5')+lstar('46','6')*s('6')+lstar('46','7')*s('7')+lstar('46','8')*s('8')+lstar('46','9')*s('9')+lstar('46','10')*s('10')+lstar('46','11')*s('11')+lstar('46','12')*s('12')+lstar('46','13')*s('13')+lstar('46','14')*s('14')+lstar('46','15')*s('15')+lstar('46','16')*s('16')+lstar('46','17')*s('17')+lstar('46','18')*s('18')+lstar('46','19')*s('19')+lstar('46','20')*s('20')+lstar('46','21')*s('21')+lstar('46','22')*s('22')+lstar('46','23')*s('23')+lstar('46','24')*s('24')+lstar('46','25')*s('25')+lstar('46','26')*s('26')+lstar('46','27')*s('27')+lstar('46','28')*s('28')+lstar('46','29')*s('29')+lstar('46','30')*s('30')+lstar('46','31')*s('31')+lstar('46','32')*s('32')+lstar('46','33')*s('33')+lstar('46','34')*s('34')+lstar('46','35')*s('35')+lstar('46','36')*s('36')+lstar('46','37')*s('37')+lstar('46','38')*s('38')+lstar('46','39')*s('39')+lstar('46','40')*s('40')+lstar('46','41')*s('41')+lstar('46','42')*s('42')+lstar('46','43')*s('43')+lstar('46','44')*s('44')+lstar('46','45')*s('45')+lstar('46','46')*s('46')+lstar('46','47')*s('47')+lstar('46','48')*s('48')+lstar('46','49')*s('49')+lstar('46','50')*s('50')+lstar('46','51')*s('51')+lstar('46','52')*s('52')+lstar('46','53')*s('53')+lstar('46','54')*s('54')+lstar('46','55')*s('55')+lstar('46','56')*s('56')+lstar('46','57')*s('57')+lstar('46','58')*s('58')+lstar('46','59')*s('59')+lstar('46','60')*s('60')+lstar('46','61')*s('61')+lstar('46','62')*s('62')+lstar('46','63')*s('63')+lstar('46','64')*s('64')+lstar('46','65')*s('65')+lstar('46','66')*s('66')+lstar('46','67')*s('67')+lstar('46','68')*s('68')+lstar('46','69')*s('69')+lstar('46','70')*s('70')+lstar('46','71')*s('71')+lstar('46','72')*s('72')+lstar('46','73')*s('73')+lstar('46','74')*s('74')-vcupstcut('46','1')*s('75')-vcupstcut('46','2')*s('76')-vcupstcut('46','3')*s('77')-vcupstcut('46','4')*s('78')-vcupstcut('46','5')*s('79')-vcupstcut('46','6')*s('80')-vcupstcut('46','7')*s('81')-vcupstcut('46','8')*s('82')-vcupstcut('46','9')*s('83')-vcupstcut('46','10')*s('84')-vcupstcut('46','11')*s('85')-vcupstcut('46','12')*s('86')-vcupstcut('46','13')*s('87')-vcupstcut('46','14')*s('88')-vcupstcut('46','15')*s('89')-vcupstcut('46','16')*s('90')-eqeconupstcut('46')*s('91');
equat47 ..    p2pf('47') =E= lstar('47','1')*s('1')+lstar('47','2')*s('2')+lstar('47','3')*s('3')+lstar('47','4')*s('4')+lstar('47','5')*s('5')+lstar('47','6')*s('6')+lstar('47','7')*s('7')+lstar('47','8')*s('8')+lstar('47','9')*s('9')+lstar('47','10')*s('10')+lstar('47','11')*s('11')+lstar('47','12')*s('12')+lstar('47','13')*s('13')+lstar('47','14')*s('14')+lstar('47','15')*s('15')+lstar('47','16')*s('16')+lstar('47','17')*s('17')+lstar('47','18')*s('18')+lstar('47','19')*s('19')+lstar('47','20')*s('20')+lstar('47','21')*s('21')+lstar('47','22')*s('22')+lstar('47','23')*s('23')+lstar('47','24')*s('24')+lstar('47','25')*s('25')+lstar('47','26')*s('26')+lstar('47','27')*s('27')+lstar('47','28')*s('28')+lstar('47','29')*s('29')+lstar('47','30')*s('30')+lstar('47','31')*s('31')+lstar('47','32')*s('32')+lstar('47','33')*s('33')+lstar('47','34')*s('34')+lstar('47','35')*s('35')+lstar('47','36')*s('36')+lstar('47','37')*s('37')+lstar('47','38')*s('38')+lstar('47','39')*s('39')+lstar('47','40')*s('40')+lstar('47','41')*s('41')+lstar('47','42')*s('42')+lstar('47','43')*s('43')+lstar('47','44')*s('44')+lstar('47','45')*s('45')+lstar('47','46')*s('46')+lstar('47','47')*s('47')+lstar('47','48')*s('48')+lstar('47','49')*s('49')+lstar('47','50')*s('50')+lstar('47','51')*s('51')+lstar('47','52')*s('52')+lstar('47','53')*s('53')+lstar('47','54')*s('54')+lstar('47','55')*s('55')+lstar('47','56')*s('56')+lstar('47','57')*s('57')+lstar('47','58')*s('58')+lstar('47','59')*s('59')+lstar('47','60')*s('60')+lstar('47','61')*s('61')+lstar('47','62')*s('62')+lstar('47','63')*s('63')+lstar('47','64')*s('64')+lstar('47','65')*s('65')+lstar('47','66')*s('66')+lstar('47','67')*s('67')+lstar('47','68')*s('68')+lstar('47','69')*s('69')+lstar('47','70')*s('70')+lstar('47','71')*s('71')+lstar('47','72')*s('72')+lstar('47','73')*s('73')+lstar('47','74')*s('74')-vcupstcut('47','1')*s('75')-vcupstcut('47','2')*s('76')-vcupstcut('47','3')*s('77')-vcupstcut('47','4')*s('78')-vcupstcut('47','5')*s('79')-vcupstcut('47','6')*s('80')-vcupstcut('47','7')*s('81')-vcupstcut('47','8')*s('82')-vcupstcut('47','9')*s('83')-vcupstcut('47','10')*s('84')-vcupstcut('47','11')*s('85')-vcupstcut('47','12')*s('86')-vcupstcut('47','13')*s('87')-vcupstcut('47','14')*s('88')-vcupstcut('47','15')*s('89')-vcupstcut('47','16')*s('90')-eqeconupstcut('47')*s('91');
equat48 ..    p2pf('48') =E= lstar('48','1')*s('1')+lstar('48','2')*s('2')+lstar('48','3')*s('3')+lstar('48','4')*s('4')+lstar('48','5')*s('5')+lstar('48','6')*s('6')+lstar('48','7')*s('7')+lstar('48','8')*s('8')+lstar('48','9')*s('9')+lstar('48','10')*s('10')+lstar('48','11')*s('11')+lstar('48','12')*s('12')+lstar('48','13')*s('13')+lstar('48','14')*s('14')+lstar('48','15')*s('15')+lstar('48','16')*s('16')+lstar('48','17')*s('17')+lstar('48','18')*s('18')+lstar('48','19')*s('19')+lstar('48','20')*s('20')+lstar('48','21')*s('21')+lstar('48','22')*s('22')+lstar('48','23')*s('23')+lstar('48','24')*s('24')+lstar('48','25')*s('25')+lstar('48','26')*s('26')+lstar('48','27')*s('27')+lstar('48','28')*s('28')+lstar('48','29')*s('29')+lstar('48','30')*s('30')+lstar('48','31')*s('31')+lstar('48','32')*s('32')+lstar('48','33')*s('33')+lstar('48','34')*s('34')+lstar('48','35')*s('35')+lstar('48','36')*s('36')+lstar('48','37')*s('37')+lstar('48','38')*s('38')+lstar('48','39')*s('39')+lstar('48','40')*s('40')+lstar('48','41')*s('41')+lstar('48','42')*s('42')+lstar('48','43')*s('43')+lstar('48','44')*s('44')+lstar('48','45')*s('45')+lstar('48','46')*s('46')+lstar('48','47')*s('47')+lstar('48','48')*s('48')+lstar('48','49')*s('49')+lstar('48','50')*s('50')+lstar('48','51')*s('51')+lstar('48','52')*s('52')+lstar('48','53')*s('53')+lstar('48','54')*s('54')+lstar('48','55')*s('55')+lstar('48','56')*s('56')+lstar('48','57')*s('57')+lstar('48','58')*s('58')+lstar('48','59')*s('59')+lstar('48','60')*s('60')+lstar('48','61')*s('61')+lstar('48','62')*s('62')+lstar('48','63')*s('63')+lstar('48','64')*s('64')+lstar('48','65')*s('65')+lstar('48','66')*s('66')+lstar('48','67')*s('67')+lstar('48','68')*s('68')+lstar('48','69')*s('69')+lstar('48','70')*s('70')+lstar('48','71')*s('71')+lstar('48','72')*s('72')+lstar('48','73')*s('73')+lstar('48','74')*s('74')-vcupstcut('48','1')*s('75')-vcupstcut('48','2')*s('76')-vcupstcut('48','3')*s('77')-vcupstcut('48','4')*s('78')-vcupstcut('48','5')*s('79')-vcupstcut('48','6')*s('80')-vcupstcut('48','7')*s('81')-vcupstcut('48','8')*s('82')-vcupstcut('48','9')*s('83')-vcupstcut('48','10')*s('84')-vcupstcut('48','11')*s('85')-vcupstcut('48','12')*s('86')-vcupstcut('48','13')*s('87')-vcupstcut('48','14')*s('88')-vcupstcut('48','15')*s('89')-vcupstcut('48','16')*s('90')-eqeconupstcut('48')*s('91');
equat49 ..    p2pf('49') =E= lstar('49','1')*s('1')+lstar('49','2')*s('2')+lstar('49','3')*s('3')+lstar('49','4')*s('4')+lstar('49','5')*s('5')+lstar('49','6')*s('6')+lstar('49','7')*s('7')+lstar('49','8')*s('8')+lstar('49','9')*s('9')+lstar('49','10')*s('10')+lstar('49','11')*s('11')+lstar('49','12')*s('12')+lstar('49','13')*s('13')+lstar('49','14')*s('14')+lstar('49','15')*s('15')+lstar('49','16')*s('16')+lstar('49','17')*s('17')+lstar('49','18')*s('18')+lstar('49','19')*s('19')+lstar('49','20')*s('20')+lstar('49','21')*s('21')+lstar('49','22')*s('22')+lstar('49','23')*s('23')+lstar('49','24')*s('24')+lstar('49','25')*s('25')+lstar('49','26')*s('26')+lstar('49','27')*s('27')+lstar('49','28')*s('28')+lstar('49','29')*s('29')+lstar('49','30')*s('30')+lstar('49','31')*s('31')+lstar('49','32')*s('32')+lstar('49','33')*s('33')+lstar('49','34')*s('34')+lstar('49','35')*s('35')+lstar('49','36')*s('36')+lstar('49','37')*s('37')+lstar('49','38')*s('38')+lstar('49','39')*s('39')+lstar('49','40')*s('40')+lstar('49','41')*s('41')+lstar('49','42')*s('42')+lstar('49','43')*s('43')+lstar('49','44')*s('44')+lstar('49','45')*s('45')+lstar('49','46')*s('46')+lstar('49','47')*s('47')+lstar('49','48')*s('48')+lstar('49','49')*s('49')+lstar('49','50')*s('50')+lstar('49','51')*s('51')+lstar('49','52')*s('52')+lstar('49','53')*s('53')+lstar('49','54')*s('54')+lstar('49','55')*s('55')+lstar('49','56')*s('56')+lstar('49','57')*s('57')+lstar('49','58')*s('58')+lstar('49','59')*s('59')+lstar('49','60')*s('60')+lstar('49','61')*s('61')+lstar('49','62')*s('62')+lstar('49','63')*s('63')+lstar('49','64')*s('64')+lstar('49','65')*s('65')+lstar('49','66')*s('66')+lstar('49','67')*s('67')+lstar('49','68')*s('68')+lstar('49','69')*s('69')+lstar('49','70')*s('70')+lstar('49','71')*s('71')+lstar('49','72')*s('72')+lstar('49','73')*s('73')+lstar('49','74')*s('74')-vcupstcut('49','1')*s('75')-vcupstcut('49','2')*s('76')-vcupstcut('49','3')*s('77')-vcupstcut('49','4')*s('78')-vcupstcut('49','5')*s('79')-vcupstcut('49','6')*s('80')-vcupstcut('49','7')*s('81')-vcupstcut('49','8')*s('82')-vcupstcut('49','9')*s('83')-vcupstcut('49','10')*s('84')-vcupstcut('49','11')*s('85')-vcupstcut('49','12')*s('86')-vcupstcut('49','13')*s('87')-vcupstcut('49','14')*s('88')-vcupstcut('49','15')*s('89')-vcupstcut('49','16')*s('90')-eqeconupstcut('49')*s('91');
equat50 ..    p2pf('50') =E= lstar('50','1')*s('1')+lstar('50','2')*s('2')+lstar('50','3')*s('3')+lstar('50','4')*s('4')+lstar('50','5')*s('5')+lstar('50','6')*s('6')+lstar('50','7')*s('7')+lstar('50','8')*s('8')+lstar('50','9')*s('9')+lstar('50','10')*s('10')+lstar('50','11')*s('11')+lstar('50','12')*s('12')+lstar('50','13')*s('13')+lstar('50','14')*s('14')+lstar('50','15')*s('15')+lstar('50','16')*s('16')+lstar('50','17')*s('17')+lstar('50','18')*s('18')+lstar('50','19')*s('19')+lstar('50','20')*s('20')+lstar('50','21')*s('21')+lstar('50','22')*s('22')+lstar('50','23')*s('23')+lstar('50','24')*s('24')+lstar('50','25')*s('25')+lstar('50','26')*s('26')+lstar('50','27')*s('27')+lstar('50','28')*s('28')+lstar('50','29')*s('29')+lstar('50','30')*s('30')+lstar('50','31')*s('31')+lstar('50','32')*s('32')+lstar('50','33')*s('33')+lstar('50','34')*s('34')+lstar('50','35')*s('35')+lstar('50','36')*s('36')+lstar('50','37')*s('37')+lstar('50','38')*s('38')+lstar('50','39')*s('39')+lstar('50','40')*s('40')+lstar('50','41')*s('41')+lstar('50','42')*s('42')+lstar('50','43')*s('43')+lstar('50','44')*s('44')+lstar('50','45')*s('45')+lstar('50','46')*s('46')+lstar('50','47')*s('47')+lstar('50','48')*s('48')+lstar('50','49')*s('49')+lstar('50','50')*s('50')+lstar('50','51')*s('51')+lstar('50','52')*s('52')+lstar('50','53')*s('53')+lstar('50','54')*s('54')+lstar('50','55')*s('55')+lstar('50','56')*s('56')+lstar('50','57')*s('57')+lstar('50','58')*s('58')+lstar('50','59')*s('59')+lstar('50','60')*s('60')+lstar('50','61')*s('61')+lstar('50','62')*s('62')+lstar('50','63')*s('63')+lstar('50','64')*s('64')+lstar('50','65')*s('65')+lstar('50','66')*s('66')+lstar('50','67')*s('67')+lstar('50','68')*s('68')+lstar('50','69')*s('69')+lstar('50','70')*s('70')+lstar('50','71')*s('71')+lstar('50','72')*s('72')+lstar('50','73')*s('73')+lstar('50','74')*s('74')-vcupstcut('50','1')*s('75')-vcupstcut('50','2')*s('76')-vcupstcut('50','3')*s('77')-vcupstcut('50','4')*s('78')-vcupstcut('50','5')*s('79')-vcupstcut('50','6')*s('80')-vcupstcut('50','7')*s('81')-vcupstcut('50','8')*s('82')-vcupstcut('50','9')*s('83')-vcupstcut('50','10')*s('84')-vcupstcut('50','11')*s('85')-vcupstcut('50','12')*s('86')-vcupstcut('50','13')*s('87')-vcupstcut('50','14')*s('88')-vcupstcut('50','15')*s('89')-vcupstcut('50','16')*s('90')-eqeconupstcut('50')*s('91');
equat51 ..    p2pf('51') =E= lstar('51','1')*s('1')+lstar('51','2')*s('2')+lstar('51','3')*s('3')+lstar('51','4')*s('4')+lstar('51','5')*s('5')+lstar('51','6')*s('6')+lstar('51','7')*s('7')+lstar('51','8')*s('8')+lstar('51','9')*s('9')+lstar('51','10')*s('10')+lstar('51','11')*s('11')+lstar('51','12')*s('12')+lstar('51','13')*s('13')+lstar('51','14')*s('14')+lstar('51','15')*s('15')+lstar('51','16')*s('16')+lstar('51','17')*s('17')+lstar('51','18')*s('18')+lstar('51','19')*s('19')+lstar('51','20')*s('20')+lstar('51','21')*s('21')+lstar('51','22')*s('22')+lstar('51','23')*s('23')+lstar('51','24')*s('24')+lstar('51','25')*s('25')+lstar('51','26')*s('26')+lstar('51','27')*s('27')+lstar('51','28')*s('28')+lstar('51','29')*s('29')+lstar('51','30')*s('30')+lstar('51','31')*s('31')+lstar('51','32')*s('32')+lstar('51','33')*s('33')+lstar('51','34')*s('34')+lstar('51','35')*s('35')+lstar('51','36')*s('36')+lstar('51','37')*s('37')+lstar('51','38')*s('38')+lstar('51','39')*s('39')+lstar('51','40')*s('40')+lstar('51','41')*s('41')+lstar('51','42')*s('42')+lstar('51','43')*s('43')+lstar('51','44')*s('44')+lstar('51','45')*s('45')+lstar('51','46')*s('46')+lstar('51','47')*s('47')+lstar('51','48')*s('48')+lstar('51','49')*s('49')+lstar('51','50')*s('50')+lstar('51','51')*s('51')+lstar('51','52')*s('52')+lstar('51','53')*s('53')+lstar('51','54')*s('54')+lstar('51','55')*s('55')+lstar('51','56')*s('56')+lstar('51','57')*s('57')+lstar('51','58')*s('58')+lstar('51','59')*s('59')+lstar('51','60')*s('60')+lstar('51','61')*s('61')+lstar('51','62')*s('62')+lstar('51','63')*s('63')+lstar('51','64')*s('64')+lstar('51','65')*s('65')+lstar('51','66')*s('66')+lstar('51','67')*s('67')+lstar('51','68')*s('68')+lstar('51','69')*s('69')+lstar('51','70')*s('70')+lstar('51','71')*s('71')+lstar('51','72')*s('72')+lstar('51','73')*s('73')+lstar('51','74')*s('74')-vcupstcut('51','1')*s('75')-vcupstcut('51','2')*s('76')-vcupstcut('51','3')*s('77')-vcupstcut('51','4')*s('78')-vcupstcut('51','5')*s('79')-vcupstcut('51','6')*s('80')-vcupstcut('51','7')*s('81')-vcupstcut('51','8')*s('82')-vcupstcut('51','9')*s('83')-vcupstcut('51','10')*s('84')-vcupstcut('51','11')*s('85')-vcupstcut('51','12')*s('86')-vcupstcut('51','13')*s('87')-vcupstcut('51','14')*s('88')-vcupstcut('51','15')*s('89')-vcupstcut('51','16')*s('90')-eqeconupstcut('51')*s('91');
equat52 ..    p2pf('52') =E= lstar('52','1')*s('1')+lstar('52','2')*s('2')+lstar('52','3')*s('3')+lstar('52','4')*s('4')+lstar('52','5')*s('5')+lstar('52','6')*s('6')+lstar('52','7')*s('7')+lstar('52','8')*s('8')+lstar('52','9')*s('9')+lstar('52','10')*s('10')+lstar('52','11')*s('11')+lstar('52','12')*s('12')+lstar('52','13')*s('13')+lstar('52','14')*s('14')+lstar('52','15')*s('15')+lstar('52','16')*s('16')+lstar('52','17')*s('17')+lstar('52','18')*s('18')+lstar('52','19')*s('19')+lstar('52','20')*s('20')+lstar('52','21')*s('21')+lstar('52','22')*s('22')+lstar('52','23')*s('23')+lstar('52','24')*s('24')+lstar('52','25')*s('25')+lstar('52','26')*s('26')+lstar('52','27')*s('27')+lstar('52','28')*s('28')+lstar('52','29')*s('29')+lstar('52','30')*s('30')+lstar('52','31')*s('31')+lstar('52','32')*s('32')+lstar('52','33')*s('33')+lstar('52','34')*s('34')+lstar('52','35')*s('35')+lstar('52','36')*s('36')+lstar('52','37')*s('37')+lstar('52','38')*s('38')+lstar('52','39')*s('39')+lstar('52','40')*s('40')+lstar('52','41')*s('41')+lstar('52','42')*s('42')+lstar('52','43')*s('43')+lstar('52','44')*s('44')+lstar('52','45')*s('45')+lstar('52','46')*s('46')+lstar('52','47')*s('47')+lstar('52','48')*s('48')+lstar('52','49')*s('49')+lstar('52','50')*s('50')+lstar('52','51')*s('51')+lstar('52','52')*s('52')+lstar('52','53')*s('53')+lstar('52','54')*s('54')+lstar('52','55')*s('55')+lstar('52','56')*s('56')+lstar('52','57')*s('57')+lstar('52','58')*s('58')+lstar('52','59')*s('59')+lstar('52','60')*s('60')+lstar('52','61')*s('61')+lstar('52','62')*s('62')+lstar('52','63')*s('63')+lstar('52','64')*s('64')+lstar('52','65')*s('65')+lstar('52','66')*s('66')+lstar('52','67')*s('67')+lstar('52','68')*s('68')+lstar('52','69')*s('69')+lstar('52','70')*s('70')+lstar('52','71')*s('71')+lstar('52','72')*s('72')+lstar('52','73')*s('73')+lstar('52','74')*s('74')-vcupstcut('52','1')*s('75')-vcupstcut('52','2')*s('76')-vcupstcut('52','3')*s('77')-vcupstcut('52','4')*s('78')-vcupstcut('52','5')*s('79')-vcupstcut('52','6')*s('80')-vcupstcut('52','7')*s('81')-vcupstcut('52','8')*s('82')-vcupstcut('52','9')*s('83')-vcupstcut('52','10')*s('84')-vcupstcut('52','11')*s('85')-vcupstcut('52','12')*s('86')-vcupstcut('52','13')*s('87')-vcupstcut('52','14')*s('88')-vcupstcut('52','15')*s('89')-vcupstcut('52','16')*s('90')-eqeconupstcut('52')*s('91');
equat53 ..    p2pf('53') =E= lstar('53','1')*s('1')+lstar('53','2')*s('2')+lstar('53','3')*s('3')+lstar('53','4')*s('4')+lstar('53','5')*s('5')+lstar('53','6')*s('6')+lstar('53','7')*s('7')+lstar('53','8')*s('8')+lstar('53','9')*s('9')+lstar('53','10')*s('10')+lstar('53','11')*s('11')+lstar('53','12')*s('12')+lstar('53','13')*s('13')+lstar('53','14')*s('14')+lstar('53','15')*s('15')+lstar('53','16')*s('16')+lstar('53','17')*s('17')+lstar('53','18')*s('18')+lstar('53','19')*s('19')+lstar('53','20')*s('20')+lstar('53','21')*s('21')+lstar('53','22')*s('22')+lstar('53','23')*s('23')+lstar('53','24')*s('24')+lstar('53','25')*s('25')+lstar('53','26')*s('26')+lstar('53','27')*s('27')+lstar('53','28')*s('28')+lstar('53','29')*s('29')+lstar('53','30')*s('30')+lstar('53','31')*s('31')+lstar('53','32')*s('32')+lstar('53','33')*s('33')+lstar('53','34')*s('34')+lstar('53','35')*s('35')+lstar('53','36')*s('36')+lstar('53','37')*s('37')+lstar('53','38')*s('38')+lstar('53','39')*s('39')+lstar('53','40')*s('40')+lstar('53','41')*s('41')+lstar('53','42')*s('42')+lstar('53','43')*s('43')+lstar('53','44')*s('44')+lstar('53','45')*s('45')+lstar('53','46')*s('46')+lstar('53','47')*s('47')+lstar('53','48')*s('48')+lstar('53','49')*s('49')+lstar('53','50')*s('50')+lstar('53','51')*s('51')+lstar('53','52')*s('52')+lstar('53','53')*s('53')+lstar('53','54')*s('54')+lstar('53','55')*s('55')+lstar('53','56')*s('56')+lstar('53','57')*s('57')+lstar('53','58')*s('58')+lstar('53','59')*s('59')+lstar('53','60')*s('60')+lstar('53','61')*s('61')+lstar('53','62')*s('62')+lstar('53','63')*s('63')+lstar('53','64')*s('64')+lstar('53','65')*s('65')+lstar('53','66')*s('66')+lstar('53','67')*s('67')+lstar('53','68')*s('68')+lstar('53','69')*s('69')+lstar('53','70')*s('70')+lstar('53','71')*s('71')+lstar('53','72')*s('72')+lstar('53','73')*s('73')+lstar('53','74')*s('74')-vcupstcut('53','1')*s('75')-vcupstcut('53','2')*s('76')-vcupstcut('53','3')*s('77')-vcupstcut('53','4')*s('78')-vcupstcut('53','5')*s('79')-vcupstcut('53','6')*s('80')-vcupstcut('53','7')*s('81')-vcupstcut('53','8')*s('82')-vcupstcut('53','9')*s('83')-vcupstcut('53','10')*s('84')-vcupstcut('53','11')*s('85')-vcupstcut('53','12')*s('86')-vcupstcut('53','13')*s('87')-vcupstcut('53','14')*s('88')-vcupstcut('53','15')*s('89')-vcupstcut('53','16')*s('90')-eqeconupstcut('53')*s('91');
equat54 ..    p2pf('54') =E= lstar('54','1')*s('1')+lstar('54','2')*s('2')+lstar('54','3')*s('3')+lstar('54','4')*s('4')+lstar('54','5')*s('5')+lstar('54','6')*s('6')+lstar('54','7')*s('7')+lstar('54','8')*s('8')+lstar('54','9')*s('9')+lstar('54','10')*s('10')+lstar('54','11')*s('11')+lstar('54','12')*s('12')+lstar('54','13')*s('13')+lstar('54','14')*s('14')+lstar('54','15')*s('15')+lstar('54','16')*s('16')+lstar('54','17')*s('17')+lstar('54','18')*s('18')+lstar('54','19')*s('19')+lstar('54','20')*s('20')+lstar('54','21')*s('21')+lstar('54','22')*s('22')+lstar('54','23')*s('23')+lstar('54','24')*s('24')+lstar('54','25')*s('25')+lstar('54','26')*s('26')+lstar('54','27')*s('27')+lstar('54','28')*s('28')+lstar('54','29')*s('29')+lstar('54','30')*s('30')+lstar('54','31')*s('31')+lstar('54','32')*s('32')+lstar('54','33')*s('33')+lstar('54','34')*s('34')+lstar('54','35')*s('35')+lstar('54','36')*s('36')+lstar('54','37')*s('37')+lstar('54','38')*s('38')+lstar('54','39')*s('39')+lstar('54','40')*s('40')+lstar('54','41')*s('41')+lstar('54','42')*s('42')+lstar('54','43')*s('43')+lstar('54','44')*s('44')+lstar('54','45')*s('45')+lstar('54','46')*s('46')+lstar('54','47')*s('47')+lstar('54','48')*s('48')+lstar('54','49')*s('49')+lstar('54','50')*s('50')+lstar('54','51')*s('51')+lstar('54','52')*s('52')+lstar('54','53')*s('53')+lstar('54','54')*s('54')+lstar('54','55')*s('55')+lstar('54','56')*s('56')+lstar('54','57')*s('57')+lstar('54','58')*s('58')+lstar('54','59')*s('59')+lstar('54','60')*s('60')+lstar('54','61')*s('61')+lstar('54','62')*s('62')+lstar('54','63')*s('63')+lstar('54','64')*s('64')+lstar('54','65')*s('65')+lstar('54','66')*s('66')+lstar('54','67')*s('67')+lstar('54','68')*s('68')+lstar('54','69')*s('69')+lstar('54','70')*s('70')+lstar('54','71')*s('71')+lstar('54','72')*s('72')+lstar('54','73')*s('73')+lstar('54','74')*s('74')-vcupstcut('54','1')*s('75')-vcupstcut('54','2')*s('76')-vcupstcut('54','3')*s('77')-vcupstcut('54','4')*s('78')-vcupstcut('54','5')*s('79')-vcupstcut('54','6')*s('80')-vcupstcut('54','7')*s('81')-vcupstcut('54','8')*s('82')-vcupstcut('54','9')*s('83')-vcupstcut('54','10')*s('84')-vcupstcut('54','11')*s('85')-vcupstcut('54','12')*s('86')-vcupstcut('54','13')*s('87')-vcupstcut('54','14')*s('88')-vcupstcut('54','15')*s('89')-vcupstcut('54','16')*s('90')-eqeconupstcut('54')*s('91');
equat55 ..    p2pf('55') =E= lstar('55','1')*s('1')+lstar('55','2')*s('2')+lstar('55','3')*s('3')+lstar('55','4')*s('4')+lstar('55','5')*s('5')+lstar('55','6')*s('6')+lstar('55','7')*s('7')+lstar('55','8')*s('8')+lstar('55','9')*s('9')+lstar('55','10')*s('10')+lstar('55','11')*s('11')+lstar('55','12')*s('12')+lstar('55','13')*s('13')+lstar('55','14')*s('14')+lstar('55','15')*s('15')+lstar('55','16')*s('16')+lstar('55','17')*s('17')+lstar('55','18')*s('18')+lstar('55','19')*s('19')+lstar('55','20')*s('20')+lstar('55','21')*s('21')+lstar('55','22')*s('22')+lstar('55','23')*s('23')+lstar('55','24')*s('24')+lstar('55','25')*s('25')+lstar('55','26')*s('26')+lstar('55','27')*s('27')+lstar('55','28')*s('28')+lstar('55','29')*s('29')+lstar('55','30')*s('30')+lstar('55','31')*s('31')+lstar('55','32')*s('32')+lstar('55','33')*s('33')+lstar('55','34')*s('34')+lstar('55','35')*s('35')+lstar('55','36')*s('36')+lstar('55','37')*s('37')+lstar('55','38')*s('38')+lstar('55','39')*s('39')+lstar('55','40')*s('40')+lstar('55','41')*s('41')+lstar('55','42')*s('42')+lstar('55','43')*s('43')+lstar('55','44')*s('44')+lstar('55','45')*s('45')+lstar('55','46')*s('46')+lstar('55','47')*s('47')+lstar('55','48')*s('48')+lstar('55','49')*s('49')+lstar('55','50')*s('50')+lstar('55','51')*s('51')+lstar('55','52')*s('52')+lstar('55','53')*s('53')+lstar('55','54')*s('54')+lstar('55','55')*s('55')+lstar('55','56')*s('56')+lstar('55','57')*s('57')+lstar('55','58')*s('58')+lstar('55','59')*s('59')+lstar('55','60')*s('60')+lstar('55','61')*s('61')+lstar('55','62')*s('62')+lstar('55','63')*s('63')+lstar('55','64')*s('64')+lstar('55','65')*s('65')+lstar('55','66')*s('66')+lstar('55','67')*s('67')+lstar('55','68')*s('68')+lstar('55','69')*s('69')+lstar('55','70')*s('70')+lstar('55','71')*s('71')+lstar('55','72')*s('72')+lstar('55','73')*s('73')+lstar('55','74')*s('74')-vcupstcut('55','1')*s('75')-vcupstcut('55','2')*s('76')-vcupstcut('55','3')*s('77')-vcupstcut('55','4')*s('78')-vcupstcut('55','5')*s('79')-vcupstcut('55','6')*s('80')-vcupstcut('55','7')*s('81')-vcupstcut('55','8')*s('82')-vcupstcut('55','9')*s('83')-vcupstcut('55','10')*s('84')-vcupstcut('55','11')*s('85')-vcupstcut('55','12')*s('86')-vcupstcut('55','13')*s('87')-vcupstcut('55','14')*s('88')-vcupstcut('55','15')*s('89')-vcupstcut('55','16')*s('90')-eqeconupstcut('55')*s('91');
equat56 ..    p2pf('56') =E= lstar('56','1')*s('1')+lstar('56','2')*s('2')+lstar('56','3')*s('3')+lstar('56','4')*s('4')+lstar('56','5')*s('5')+lstar('56','6')*s('6')+lstar('56','7')*s('7')+lstar('56','8')*s('8')+lstar('56','9')*s('9')+lstar('56','10')*s('10')+lstar('56','11')*s('11')+lstar('56','12')*s('12')+lstar('56','13')*s('13')+lstar('56','14')*s('14')+lstar('56','15')*s('15')+lstar('56','16')*s('16')+lstar('56','17')*s('17')+lstar('56','18')*s('18')+lstar('56','19')*s('19')+lstar('56','20')*s('20')+lstar('56','21')*s('21')+lstar('56','22')*s('22')+lstar('56','23')*s('23')+lstar('56','24')*s('24')+lstar('56','25')*s('25')+lstar('56','26')*s('26')+lstar('56','27')*s('27')+lstar('56','28')*s('28')+lstar('56','29')*s('29')+lstar('56','30')*s('30')+lstar('56','31')*s('31')+lstar('56','32')*s('32')+lstar('56','33')*s('33')+lstar('56','34')*s('34')+lstar('56','35')*s('35')+lstar('56','36')*s('36')+lstar('56','37')*s('37')+lstar('56','38')*s('38')+lstar('56','39')*s('39')+lstar('56','40')*s('40')+lstar('56','41')*s('41')+lstar('56','42')*s('42')+lstar('56','43')*s('43')+lstar('56','44')*s('44')+lstar('56','45')*s('45')+lstar('56','46')*s('46')+lstar('56','47')*s('47')+lstar('56','48')*s('48')+lstar('56','49')*s('49')+lstar('56','50')*s('50')+lstar('56','51')*s('51')+lstar('56','52')*s('52')+lstar('56','53')*s('53')+lstar('56','54')*s('54')+lstar('56','55')*s('55')+lstar('56','56')*s('56')+lstar('56','57')*s('57')+lstar('56','58')*s('58')+lstar('56','59')*s('59')+lstar('56','60')*s('60')+lstar('56','61')*s('61')+lstar('56','62')*s('62')+lstar('56','63')*s('63')+lstar('56','64')*s('64')+lstar('56','65')*s('65')+lstar('56','66')*s('66')+lstar('56','67')*s('67')+lstar('56','68')*s('68')+lstar('56','69')*s('69')+lstar('56','70')*s('70')+lstar('56','71')*s('71')+lstar('56','72')*s('72')+lstar('56','73')*s('73')+lstar('56','74')*s('74')-vcupstcut('56','1')*s('75')-vcupstcut('56','2')*s('76')-vcupstcut('56','3')*s('77')-vcupstcut('56','4')*s('78')-vcupstcut('56','5')*s('79')-vcupstcut('56','6')*s('80')-vcupstcut('56','7')*s('81')-vcupstcut('56','8')*s('82')-vcupstcut('56','9')*s('83')-vcupstcut('56','10')*s('84')-vcupstcut('56','11')*s('85')-vcupstcut('56','12')*s('86')-vcupstcut('56','13')*s('87')-vcupstcut('56','14')*s('88')-vcupstcut('56','15')*s('89')-vcupstcut('56','16')*s('90')-eqeconupstcut('56')*s('91');
equat57 ..    p2pf('57') =E= lstar('57','1')*s('1')+lstar('57','2')*s('2')+lstar('57','3')*s('3')+lstar('57','4')*s('4')+lstar('57','5')*s('5')+lstar('57','6')*s('6')+lstar('57','7')*s('7')+lstar('57','8')*s('8')+lstar('57','9')*s('9')+lstar('57','10')*s('10')+lstar('57','11')*s('11')+lstar('57','12')*s('12')+lstar('57','13')*s('13')+lstar('57','14')*s('14')+lstar('57','15')*s('15')+lstar('57','16')*s('16')+lstar('57','17')*s('17')+lstar('57','18')*s('18')+lstar('57','19')*s('19')+lstar('57','20')*s('20')+lstar('57','21')*s('21')+lstar('57','22')*s('22')+lstar('57','23')*s('23')+lstar('57','24')*s('24')+lstar('57','25')*s('25')+lstar('57','26')*s('26')+lstar('57','27')*s('27')+lstar('57','28')*s('28')+lstar('57','29')*s('29')+lstar('57','30')*s('30')+lstar('57','31')*s('31')+lstar('57','32')*s('32')+lstar('57','33')*s('33')+lstar('57','34')*s('34')+lstar('57','35')*s('35')+lstar('57','36')*s('36')+lstar('57','37')*s('37')+lstar('57','38')*s('38')+lstar('57','39')*s('39')+lstar('57','40')*s('40')+lstar('57','41')*s('41')+lstar('57','42')*s('42')+lstar('57','43')*s('43')+lstar('57','44')*s('44')+lstar('57','45')*s('45')+lstar('57','46')*s('46')+lstar('57','47')*s('47')+lstar('57','48')*s('48')+lstar('57','49')*s('49')+lstar('57','50')*s('50')+lstar('57','51')*s('51')+lstar('57','52')*s('52')+lstar('57','53')*s('53')+lstar('57','54')*s('54')+lstar('57','55')*s('55')+lstar('57','56')*s('56')+lstar('57','57')*s('57')+lstar('57','58')*s('58')+lstar('57','59')*s('59')+lstar('57','60')*s('60')+lstar('57','61')*s('61')+lstar('57','62')*s('62')+lstar('57','63')*s('63')+lstar('57','64')*s('64')+lstar('57','65')*s('65')+lstar('57','66')*s('66')+lstar('57','67')*s('67')+lstar('57','68')*s('68')+lstar('57','69')*s('69')+lstar('57','70')*s('70')+lstar('57','71')*s('71')+lstar('57','72')*s('72')+lstar('57','73')*s('73')+lstar('57','74')*s('74')-vcupstcut('57','1')*s('75')-vcupstcut('57','2')*s('76')-vcupstcut('57','3')*s('77')-vcupstcut('57','4')*s('78')-vcupstcut('57','5')*s('79')-vcupstcut('57','6')*s('80')-vcupstcut('57','7')*s('81')-vcupstcut('57','8')*s('82')-vcupstcut('57','9')*s('83')-vcupstcut('57','10')*s('84')-vcupstcut('57','11')*s('85')-vcupstcut('57','12')*s('86')-vcupstcut('57','13')*s('87')-vcupstcut('57','14')*s('88')-vcupstcut('57','15')*s('89')-vcupstcut('57','16')*s('90')-eqeconupstcut('57')*s('91');
equat58 ..    p2pf('58') =E= lstar('58','1')*s('1')+lstar('58','2')*s('2')+lstar('58','3')*s('3')+lstar('58','4')*s('4')+lstar('58','5')*s('5')+lstar('58','6')*s('6')+lstar('58','7')*s('7')+lstar('58','8')*s('8')+lstar('58','9')*s('9')+lstar('58','10')*s('10')+lstar('58','11')*s('11')+lstar('58','12')*s('12')+lstar('58','13')*s('13')+lstar('58','14')*s('14')+lstar('58','15')*s('15')+lstar('58','16')*s('16')+lstar('58','17')*s('17')+lstar('58','18')*s('18')+lstar('58','19')*s('19')+lstar('58','20')*s('20')+lstar('58','21')*s('21')+lstar('58','22')*s('22')+lstar('58','23')*s('23')+lstar('58','24')*s('24')+lstar('58','25')*s('25')+lstar('58','26')*s('26')+lstar('58','27')*s('27')+lstar('58','28')*s('28')+lstar('58','29')*s('29')+lstar('58','30')*s('30')+lstar('58','31')*s('31')+lstar('58','32')*s('32')+lstar('58','33')*s('33')+lstar('58','34')*s('34')+lstar('58','35')*s('35')+lstar('58','36')*s('36')+lstar('58','37')*s('37')+lstar('58','38')*s('38')+lstar('58','39')*s('39')+lstar('58','40')*s('40')+lstar('58','41')*s('41')+lstar('58','42')*s('42')+lstar('58','43')*s('43')+lstar('58','44')*s('44')+lstar('58','45')*s('45')+lstar('58','46')*s('46')+lstar('58','47')*s('47')+lstar('58','48')*s('48')+lstar('58','49')*s('49')+lstar('58','50')*s('50')+lstar('58','51')*s('51')+lstar('58','52')*s('52')+lstar('58','53')*s('53')+lstar('58','54')*s('54')+lstar('58','55')*s('55')+lstar('58','56')*s('56')+lstar('58','57')*s('57')+lstar('58','58')*s('58')+lstar('58','59')*s('59')+lstar('58','60')*s('60')+lstar('58','61')*s('61')+lstar('58','62')*s('62')+lstar('58','63')*s('63')+lstar('58','64')*s('64')+lstar('58','65')*s('65')+lstar('58','66')*s('66')+lstar('58','67')*s('67')+lstar('58','68')*s('68')+lstar('58','69')*s('69')+lstar('58','70')*s('70')+lstar('58','71')*s('71')+lstar('58','72')*s('72')+lstar('58','73')*s('73')+lstar('58','74')*s('74')-vcupstcut('58','1')*s('75')-vcupstcut('58','2')*s('76')-vcupstcut('58','3')*s('77')-vcupstcut('58','4')*s('78')-vcupstcut('58','5')*s('79')-vcupstcut('58','6')*s('80')-vcupstcut('58','7')*s('81')-vcupstcut('58','8')*s('82')-vcupstcut('58','9')*s('83')-vcupstcut('58','10')*s('84')-vcupstcut('58','11')*s('85')-vcupstcut('58','12')*s('86')-vcupstcut('58','13')*s('87')-vcupstcut('58','14')*s('88')-vcupstcut('58','15')*s('89')-vcupstcut('58','16')*s('90')-eqeconupstcut('58')*s('91');
equat59 ..    p2pf('59') =E= lstar('59','1')*s('1')+lstar('59','2')*s('2')+lstar('59','3')*s('3')+lstar('59','4')*s('4')+lstar('59','5')*s('5')+lstar('59','6')*s('6')+lstar('59','7')*s('7')+lstar('59','8')*s('8')+lstar('59','9')*s('9')+lstar('59','10')*s('10')+lstar('59','11')*s('11')+lstar('59','12')*s('12')+lstar('59','13')*s('13')+lstar('59','14')*s('14')+lstar('59','15')*s('15')+lstar('59','16')*s('16')+lstar('59','17')*s('17')+lstar('59','18')*s('18')+lstar('59','19')*s('19')+lstar('59','20')*s('20')+lstar('59','21')*s('21')+lstar('59','22')*s('22')+lstar('59','23')*s('23')+lstar('59','24')*s('24')+lstar('59','25')*s('25')+lstar('59','26')*s('26')+lstar('59','27')*s('27')+lstar('59','28')*s('28')+lstar('59','29')*s('29')+lstar('59','30')*s('30')+lstar('59','31')*s('31')+lstar('59','32')*s('32')+lstar('59','33')*s('33')+lstar('59','34')*s('34')+lstar('59','35')*s('35')+lstar('59','36')*s('36')+lstar('59','37')*s('37')+lstar('59','38')*s('38')+lstar('59','39')*s('39')+lstar('59','40')*s('40')+lstar('59','41')*s('41')+lstar('59','42')*s('42')+lstar('59','43')*s('43')+lstar('59','44')*s('44')+lstar('59','45')*s('45')+lstar('59','46')*s('46')+lstar('59','47')*s('47')+lstar('59','48')*s('48')+lstar('59','49')*s('49')+lstar('59','50')*s('50')+lstar('59','51')*s('51')+lstar('59','52')*s('52')+lstar('59','53')*s('53')+lstar('59','54')*s('54')+lstar('59','55')*s('55')+lstar('59','56')*s('56')+lstar('59','57')*s('57')+lstar('59','58')*s('58')+lstar('59','59')*s('59')+lstar('59','60')*s('60')+lstar('59','61')*s('61')+lstar('59','62')*s('62')+lstar('59','63')*s('63')+lstar('59','64')*s('64')+lstar('59','65')*s('65')+lstar('59','66')*s('66')+lstar('59','67')*s('67')+lstar('59','68')*s('68')+lstar('59','69')*s('69')+lstar('59','70')*s('70')+lstar('59','71')*s('71')+lstar('59','72')*s('72')+lstar('59','73')*s('73')+lstar('59','74')*s('74')-vcupstcut('59','1')*s('75')-vcupstcut('59','2')*s('76')-vcupstcut('59','3')*s('77')-vcupstcut('59','4')*s('78')-vcupstcut('59','5')*s('79')-vcupstcut('59','6')*s('80')-vcupstcut('59','7')*s('81')-vcupstcut('59','8')*s('82')-vcupstcut('59','9')*s('83')-vcupstcut('59','10')*s('84')-vcupstcut('59','11')*s('85')-vcupstcut('59','12')*s('86')-vcupstcut('59','13')*s('87')-vcupstcut('59','14')*s('88')-vcupstcut('59','15')*s('89')-vcupstcut('59','16')*s('90')-eqeconupstcut('59')*s('91');
equat60 ..    p2pf('60') =E= lstar('60','1')*s('1')+lstar('60','2')*s('2')+lstar('60','3')*s('3')+lstar('60','4')*s('4')+lstar('60','5')*s('5')+lstar('60','6')*s('6')+lstar('60','7')*s('7')+lstar('60','8')*s('8')+lstar('60','9')*s('9')+lstar('60','10')*s('10')+lstar('60','11')*s('11')+lstar('60','12')*s('12')+lstar('60','13')*s('13')+lstar('60','14')*s('14')+lstar('60','15')*s('15')+lstar('60','16')*s('16')+lstar('60','17')*s('17')+lstar('60','18')*s('18')+lstar('60','19')*s('19')+lstar('60','20')*s('20')+lstar('60','21')*s('21')+lstar('60','22')*s('22')+lstar('60','23')*s('23')+lstar('60','24')*s('24')+lstar('60','25')*s('25')+lstar('60','26')*s('26')+lstar('60','27')*s('27')+lstar('60','28')*s('28')+lstar('60','29')*s('29')+lstar('60','30')*s('30')+lstar('60','31')*s('31')+lstar('60','32')*s('32')+lstar('60','33')*s('33')+lstar('60','34')*s('34')+lstar('60','35')*s('35')+lstar('60','36')*s('36')+lstar('60','37')*s('37')+lstar('60','38')*s('38')+lstar('60','39')*s('39')+lstar('60','40')*s('40')+lstar('60','41')*s('41')+lstar('60','42')*s('42')+lstar('60','43')*s('43')+lstar('60','44')*s('44')+lstar('60','45')*s('45')+lstar('60','46')*s('46')+lstar('60','47')*s('47')+lstar('60','48')*s('48')+lstar('60','49')*s('49')+lstar('60','50')*s('50')+lstar('60','51')*s('51')+lstar('60','52')*s('52')+lstar('60','53')*s('53')+lstar('60','54')*s('54')+lstar('60','55')*s('55')+lstar('60','56')*s('56')+lstar('60','57')*s('57')+lstar('60','58')*s('58')+lstar('60','59')*s('59')+lstar('60','60')*s('60')+lstar('60','61')*s('61')+lstar('60','62')*s('62')+lstar('60','63')*s('63')+lstar('60','64')*s('64')+lstar('60','65')*s('65')+lstar('60','66')*s('66')+lstar('60','67')*s('67')+lstar('60','68')*s('68')+lstar('60','69')*s('69')+lstar('60','70')*s('70')+lstar('60','71')*s('71')+lstar('60','72')*s('72')+lstar('60','73')*s('73')+lstar('60','74')*s('74')-vcupstcut('60','1')*s('75')-vcupstcut('60','2')*s('76')-vcupstcut('60','3')*s('77')-vcupstcut('60','4')*s('78')-vcupstcut('60','5')*s('79')-vcupstcut('60','6')*s('80')-vcupstcut('60','7')*s('81')-vcupstcut('60','8')*s('82')-vcupstcut('60','9')*s('83')-vcupstcut('60','10')*s('84')-vcupstcut('60','11')*s('85')-vcupstcut('60','12')*s('86')-vcupstcut('60','13')*s('87')-vcupstcut('60','14')*s('88')-vcupstcut('60','15')*s('89')-vcupstcut('60','16')*s('90')-eqeconupstcut('60')*s('91');
equat61 ..    p2pf('61') =E= lstar('61','1')*s('1')+lstar('61','2')*s('2')+lstar('61','3')*s('3')+lstar('61','4')*s('4')+lstar('61','5')*s('5')+lstar('61','6')*s('6')+lstar('61','7')*s('7')+lstar('61','8')*s('8')+lstar('61','9')*s('9')+lstar('61','10')*s('10')+lstar('61','11')*s('11')+lstar('61','12')*s('12')+lstar('61','13')*s('13')+lstar('61','14')*s('14')+lstar('61','15')*s('15')+lstar('61','16')*s('16')+lstar('61','17')*s('17')+lstar('61','18')*s('18')+lstar('61','19')*s('19')+lstar('61','20')*s('20')+lstar('61','21')*s('21')+lstar('61','22')*s('22')+lstar('61','23')*s('23')+lstar('61','24')*s('24')+lstar('61','25')*s('25')+lstar('61','26')*s('26')+lstar('61','27')*s('27')+lstar('61','28')*s('28')+lstar('61','29')*s('29')+lstar('61','30')*s('30')+lstar('61','31')*s('31')+lstar('61','32')*s('32')+lstar('61','33')*s('33')+lstar('61','34')*s('34')+lstar('61','35')*s('35')+lstar('61','36')*s('36')+lstar('61','37')*s('37')+lstar('61','38')*s('38')+lstar('61','39')*s('39')+lstar('61','40')*s('40')+lstar('61','41')*s('41')+lstar('61','42')*s('42')+lstar('61','43')*s('43')+lstar('61','44')*s('44')+lstar('61','45')*s('45')+lstar('61','46')*s('46')+lstar('61','47')*s('47')+lstar('61','48')*s('48')+lstar('61','49')*s('49')+lstar('61','50')*s('50')+lstar('61','51')*s('51')+lstar('61','52')*s('52')+lstar('61','53')*s('53')+lstar('61','54')*s('54')+lstar('61','55')*s('55')+lstar('61','56')*s('56')+lstar('61','57')*s('57')+lstar('61','58')*s('58')+lstar('61','59')*s('59')+lstar('61','60')*s('60')+lstar('61','61')*s('61')+lstar('61','62')*s('62')+lstar('61','63')*s('63')+lstar('61','64')*s('64')+lstar('61','65')*s('65')+lstar('61','66')*s('66')+lstar('61','67')*s('67')+lstar('61','68')*s('68')+lstar('61','69')*s('69')+lstar('61','70')*s('70')+lstar('61','71')*s('71')+lstar('61','72')*s('72')+lstar('61','73')*s('73')+lstar('61','74')*s('74')-vcupstcut('61','1')*s('75')-vcupstcut('61','2')*s('76')-vcupstcut('61','3')*s('77')-vcupstcut('61','4')*s('78')-vcupstcut('61','5')*s('79')-vcupstcut('61','6')*s('80')-vcupstcut('61','7')*s('81')-vcupstcut('61','8')*s('82')-vcupstcut('61','9')*s('83')-vcupstcut('61','10')*s('84')-vcupstcut('61','11')*s('85')-vcupstcut('61','12')*s('86')-vcupstcut('61','13')*s('87')-vcupstcut('61','14')*s('88')-vcupstcut('61','15')*s('89')-vcupstcut('61','16')*s('90')-eqeconupstcut('61')*s('91');
equat62 ..    p2pf('62') =E= lstar('62','1')*s('1')+lstar('62','2')*s('2')+lstar('62','3')*s('3')+lstar('62','4')*s('4')+lstar('62','5')*s('5')+lstar('62','6')*s('6')+lstar('62','7')*s('7')+lstar('62','8')*s('8')+lstar('62','9')*s('9')+lstar('62','10')*s('10')+lstar('62','11')*s('11')+lstar('62','12')*s('12')+lstar('62','13')*s('13')+lstar('62','14')*s('14')+lstar('62','15')*s('15')+lstar('62','16')*s('16')+lstar('62','17')*s('17')+lstar('62','18')*s('18')+lstar('62','19')*s('19')+lstar('62','20')*s('20')+lstar('62','21')*s('21')+lstar('62','22')*s('22')+lstar('62','23')*s('23')+lstar('62','24')*s('24')+lstar('62','25')*s('25')+lstar('62','26')*s('26')+lstar('62','27')*s('27')+lstar('62','28')*s('28')+lstar('62','29')*s('29')+lstar('62','30')*s('30')+lstar('62','31')*s('31')+lstar('62','32')*s('32')+lstar('62','33')*s('33')+lstar('62','34')*s('34')+lstar('62','35')*s('35')+lstar('62','36')*s('36')+lstar('62','37')*s('37')+lstar('62','38')*s('38')+lstar('62','39')*s('39')+lstar('62','40')*s('40')+lstar('62','41')*s('41')+lstar('62','42')*s('42')+lstar('62','43')*s('43')+lstar('62','44')*s('44')+lstar('62','45')*s('45')+lstar('62','46')*s('46')+lstar('62','47')*s('47')+lstar('62','48')*s('48')+lstar('62','49')*s('49')+lstar('62','50')*s('50')+lstar('62','51')*s('51')+lstar('62','52')*s('52')+lstar('62','53')*s('53')+lstar('62','54')*s('54')+lstar('62','55')*s('55')+lstar('62','56')*s('56')+lstar('62','57')*s('57')+lstar('62','58')*s('58')+lstar('62','59')*s('59')+lstar('62','60')*s('60')+lstar('62','61')*s('61')+lstar('62','62')*s('62')+lstar('62','63')*s('63')+lstar('62','64')*s('64')+lstar('62','65')*s('65')+lstar('62','66')*s('66')+lstar('62','67')*s('67')+lstar('62','68')*s('68')+lstar('62','69')*s('69')+lstar('62','70')*s('70')+lstar('62','71')*s('71')+lstar('62','72')*s('72')+lstar('62','73')*s('73')+lstar('62','74')*s('74')-vcupstcut('62','1')*s('75')-vcupstcut('62','2')*s('76')-vcupstcut('62','3')*s('77')-vcupstcut('62','4')*s('78')-vcupstcut('62','5')*s('79')-vcupstcut('62','6')*s('80')-vcupstcut('62','7')*s('81')-vcupstcut('62','8')*s('82')-vcupstcut('62','9')*s('83')-vcupstcut('62','10')*s('84')-vcupstcut('62','11')*s('85')-vcupstcut('62','12')*s('86')-vcupstcut('62','13')*s('87')-vcupstcut('62','14')*s('88')-vcupstcut('62','15')*s('89')-vcupstcut('62','16')*s('90')-eqeconupstcut('62')*s('91');
equat63 ..    p2pf('63') =E= lstar('63','1')*s('1')+lstar('63','2')*s('2')+lstar('63','3')*s('3')+lstar('63','4')*s('4')+lstar('63','5')*s('5')+lstar('63','6')*s('6')+lstar('63','7')*s('7')+lstar('63','8')*s('8')+lstar('63','9')*s('9')+lstar('63','10')*s('10')+lstar('63','11')*s('11')+lstar('63','12')*s('12')+lstar('63','13')*s('13')+lstar('63','14')*s('14')+lstar('63','15')*s('15')+lstar('63','16')*s('16')+lstar('63','17')*s('17')+lstar('63','18')*s('18')+lstar('63','19')*s('19')+lstar('63','20')*s('20')+lstar('63','21')*s('21')+lstar('63','22')*s('22')+lstar('63','23')*s('23')+lstar('63','24')*s('24')+lstar('63','25')*s('25')+lstar('63','26')*s('26')+lstar('63','27')*s('27')+lstar('63','28')*s('28')+lstar('63','29')*s('29')+lstar('63','30')*s('30')+lstar('63','31')*s('31')+lstar('63','32')*s('32')+lstar('63','33')*s('33')+lstar('63','34')*s('34')+lstar('63','35')*s('35')+lstar('63','36')*s('36')+lstar('63','37')*s('37')+lstar('63','38')*s('38')+lstar('63','39')*s('39')+lstar('63','40')*s('40')+lstar('63','41')*s('41')+lstar('63','42')*s('42')+lstar('63','43')*s('43')+lstar('63','44')*s('44')+lstar('63','45')*s('45')+lstar('63','46')*s('46')+lstar('63','47')*s('47')+lstar('63','48')*s('48')+lstar('63','49')*s('49')+lstar('63','50')*s('50')+lstar('63','51')*s('51')+lstar('63','52')*s('52')+lstar('63','53')*s('53')+lstar('63','54')*s('54')+lstar('63','55')*s('55')+lstar('63','56')*s('56')+lstar('63','57')*s('57')+lstar('63','58')*s('58')+lstar('63','59')*s('59')+lstar('63','60')*s('60')+lstar('63','61')*s('61')+lstar('63','62')*s('62')+lstar('63','63')*s('63')+lstar('63','64')*s('64')+lstar('63','65')*s('65')+lstar('63','66')*s('66')+lstar('63','67')*s('67')+lstar('63','68')*s('68')+lstar('63','69')*s('69')+lstar('63','70')*s('70')+lstar('63','71')*s('71')+lstar('63','72')*s('72')+lstar('63','73')*s('73')+lstar('63','74')*s('74')-vcupstcut('63','1')*s('75')-vcupstcut('63','2')*s('76')-vcupstcut('63','3')*s('77')-vcupstcut('63','4')*s('78')-vcupstcut('63','5')*s('79')-vcupstcut('63','6')*s('80')-vcupstcut('63','7')*s('81')-vcupstcut('63','8')*s('82')-vcupstcut('63','9')*s('83')-vcupstcut('63','10')*s('84')-vcupstcut('63','11')*s('85')-vcupstcut('63','12')*s('86')-vcupstcut('63','13')*s('87')-vcupstcut('63','14')*s('88')-vcupstcut('63','15')*s('89')-vcupstcut('63','16')*s('90')-eqeconupstcut('63')*s('91');
equat64 ..    p2pf('64') =E= lstar('64','1')*s('1')+lstar('64','2')*s('2')+lstar('64','3')*s('3')+lstar('64','4')*s('4')+lstar('64','5')*s('5')+lstar('64','6')*s('6')+lstar('64','7')*s('7')+lstar('64','8')*s('8')+lstar('64','9')*s('9')+lstar('64','10')*s('10')+lstar('64','11')*s('11')+lstar('64','12')*s('12')+lstar('64','13')*s('13')+lstar('64','14')*s('14')+lstar('64','15')*s('15')+lstar('64','16')*s('16')+lstar('64','17')*s('17')+lstar('64','18')*s('18')+lstar('64','19')*s('19')+lstar('64','20')*s('20')+lstar('64','21')*s('21')+lstar('64','22')*s('22')+lstar('64','23')*s('23')+lstar('64','24')*s('24')+lstar('64','25')*s('25')+lstar('64','26')*s('26')+lstar('64','27')*s('27')+lstar('64','28')*s('28')+lstar('64','29')*s('29')+lstar('64','30')*s('30')+lstar('64','31')*s('31')+lstar('64','32')*s('32')+lstar('64','33')*s('33')+lstar('64','34')*s('34')+lstar('64','35')*s('35')+lstar('64','36')*s('36')+lstar('64','37')*s('37')+lstar('64','38')*s('38')+lstar('64','39')*s('39')+lstar('64','40')*s('40')+lstar('64','41')*s('41')+lstar('64','42')*s('42')+lstar('64','43')*s('43')+lstar('64','44')*s('44')+lstar('64','45')*s('45')+lstar('64','46')*s('46')+lstar('64','47')*s('47')+lstar('64','48')*s('48')+lstar('64','49')*s('49')+lstar('64','50')*s('50')+lstar('64','51')*s('51')+lstar('64','52')*s('52')+lstar('64','53')*s('53')+lstar('64','54')*s('54')+lstar('64','55')*s('55')+lstar('64','56')*s('56')+lstar('64','57')*s('57')+lstar('64','58')*s('58')+lstar('64','59')*s('59')+lstar('64','60')*s('60')+lstar('64','61')*s('61')+lstar('64','62')*s('62')+lstar('64','63')*s('63')+lstar('64','64')*s('64')+lstar('64','65')*s('65')+lstar('64','66')*s('66')+lstar('64','67')*s('67')+lstar('64','68')*s('68')+lstar('64','69')*s('69')+lstar('64','70')*s('70')+lstar('64','71')*s('71')+lstar('64','72')*s('72')+lstar('64','73')*s('73')+lstar('64','74')*s('74')-vcupstcut('64','1')*s('75')-vcupstcut('64','2')*s('76')-vcupstcut('64','3')*s('77')-vcupstcut('64','4')*s('78')-vcupstcut('64','5')*s('79')-vcupstcut('64','6')*s('80')-vcupstcut('64','7')*s('81')-vcupstcut('64','8')*s('82')-vcupstcut('64','9')*s('83')-vcupstcut('64','10')*s('84')-vcupstcut('64','11')*s('85')-vcupstcut('64','12')*s('86')-vcupstcut('64','13')*s('87')-vcupstcut('64','14')*s('88')-vcupstcut('64','15')*s('89')-vcupstcut('64','16')*s('90')-eqeconupstcut('64')*s('91');
equat65 ..    p2pf('65') =E= lstar('65','1')*s('1')+lstar('65','2')*s('2')+lstar('65','3')*s('3')+lstar('65','4')*s('4')+lstar('65','5')*s('5')+lstar('65','6')*s('6')+lstar('65','7')*s('7')+lstar('65','8')*s('8')+lstar('65','9')*s('9')+lstar('65','10')*s('10')+lstar('65','11')*s('11')+lstar('65','12')*s('12')+lstar('65','13')*s('13')+lstar('65','14')*s('14')+lstar('65','15')*s('15')+lstar('65','16')*s('16')+lstar('65','17')*s('17')+lstar('65','18')*s('18')+lstar('65','19')*s('19')+lstar('65','20')*s('20')+lstar('65','21')*s('21')+lstar('65','22')*s('22')+lstar('65','23')*s('23')+lstar('65','24')*s('24')+lstar('65','25')*s('25')+lstar('65','26')*s('26')+lstar('65','27')*s('27')+lstar('65','28')*s('28')+lstar('65','29')*s('29')+lstar('65','30')*s('30')+lstar('65','31')*s('31')+lstar('65','32')*s('32')+lstar('65','33')*s('33')+lstar('65','34')*s('34')+lstar('65','35')*s('35')+lstar('65','36')*s('36')+lstar('65','37')*s('37')+lstar('65','38')*s('38')+lstar('65','39')*s('39')+lstar('65','40')*s('40')+lstar('65','41')*s('41')+lstar('65','42')*s('42')+lstar('65','43')*s('43')+lstar('65','44')*s('44')+lstar('65','45')*s('45')+lstar('65','46')*s('46')+lstar('65','47')*s('47')+lstar('65','48')*s('48')+lstar('65','49')*s('49')+lstar('65','50')*s('50')+lstar('65','51')*s('51')+lstar('65','52')*s('52')+lstar('65','53')*s('53')+lstar('65','54')*s('54')+lstar('65','55')*s('55')+lstar('65','56')*s('56')+lstar('65','57')*s('57')+lstar('65','58')*s('58')+lstar('65','59')*s('59')+lstar('65','60')*s('60')+lstar('65','61')*s('61')+lstar('65','62')*s('62')+lstar('65','63')*s('63')+lstar('65','64')*s('64')+lstar('65','65')*s('65')+lstar('65','66')*s('66')+lstar('65','67')*s('67')+lstar('65','68')*s('68')+lstar('65','69')*s('69')+lstar('65','70')*s('70')+lstar('65','71')*s('71')+lstar('65','72')*s('72')+lstar('65','73')*s('73')+lstar('65','74')*s('74')-vcupstcut('65','1')*s('75')-vcupstcut('65','2')*s('76')-vcupstcut('65','3')*s('77')-vcupstcut('65','4')*s('78')-vcupstcut('65','5')*s('79')-vcupstcut('65','6')*s('80')-vcupstcut('65','7')*s('81')-vcupstcut('65','8')*s('82')-vcupstcut('65','9')*s('83')-vcupstcut('65','10')*s('84')-vcupstcut('65','11')*s('85')-vcupstcut('65','12')*s('86')-vcupstcut('65','13')*s('87')-vcupstcut('65','14')*s('88')-vcupstcut('65','15')*s('89')-vcupstcut('65','16')*s('90')-eqeconupstcut('65')*s('91');
equat66 ..    p2pf('66') =E= lstar('66','1')*s('1')+lstar('66','2')*s('2')+lstar('66','3')*s('3')+lstar('66','4')*s('4')+lstar('66','5')*s('5')+lstar('66','6')*s('6')+lstar('66','7')*s('7')+lstar('66','8')*s('8')+lstar('66','9')*s('9')+lstar('66','10')*s('10')+lstar('66','11')*s('11')+lstar('66','12')*s('12')+lstar('66','13')*s('13')+lstar('66','14')*s('14')+lstar('66','15')*s('15')+lstar('66','16')*s('16')+lstar('66','17')*s('17')+lstar('66','18')*s('18')+lstar('66','19')*s('19')+lstar('66','20')*s('20')+lstar('66','21')*s('21')+lstar('66','22')*s('22')+lstar('66','23')*s('23')+lstar('66','24')*s('24')+lstar('66','25')*s('25')+lstar('66','26')*s('26')+lstar('66','27')*s('27')+lstar('66','28')*s('28')+lstar('66','29')*s('29')+lstar('66','30')*s('30')+lstar('66','31')*s('31')+lstar('66','32')*s('32')+lstar('66','33')*s('33')+lstar('66','34')*s('34')+lstar('66','35')*s('35')+lstar('66','36')*s('36')+lstar('66','37')*s('37')+lstar('66','38')*s('38')+lstar('66','39')*s('39')+lstar('66','40')*s('40')+lstar('66','41')*s('41')+lstar('66','42')*s('42')+lstar('66','43')*s('43')+lstar('66','44')*s('44')+lstar('66','45')*s('45')+lstar('66','46')*s('46')+lstar('66','47')*s('47')+lstar('66','48')*s('48')+lstar('66','49')*s('49')+lstar('66','50')*s('50')+lstar('66','51')*s('51')+lstar('66','52')*s('52')+lstar('66','53')*s('53')+lstar('66','54')*s('54')+lstar('66','55')*s('55')+lstar('66','56')*s('56')+lstar('66','57')*s('57')+lstar('66','58')*s('58')+lstar('66','59')*s('59')+lstar('66','60')*s('60')+lstar('66','61')*s('61')+lstar('66','62')*s('62')+lstar('66','63')*s('63')+lstar('66','64')*s('64')+lstar('66','65')*s('65')+lstar('66','66')*s('66')+lstar('66','67')*s('67')+lstar('66','68')*s('68')+lstar('66','69')*s('69')+lstar('66','70')*s('70')+lstar('66','71')*s('71')+lstar('66','72')*s('72')+lstar('66','73')*s('73')+lstar('66','74')*s('74')-vcupstcut('66','1')*s('75')-vcupstcut('66','2')*s('76')-vcupstcut('66','3')*s('77')-vcupstcut('66','4')*s('78')-vcupstcut('66','5')*s('79')-vcupstcut('66','6')*s('80')-vcupstcut('66','7')*s('81')-vcupstcut('66','8')*s('82')-vcupstcut('66','9')*s('83')-vcupstcut('66','10')*s('84')-vcupstcut('66','11')*s('85')-vcupstcut('66','12')*s('86')-vcupstcut('66','13')*s('87')-vcupstcut('66','14')*s('88')-vcupstcut('66','15')*s('89')-vcupstcut('66','16')*s('90')-eqeconupstcut('66')*s('91');
equat67 ..    p2pf('67') =E= lstar('67','1')*s('1')+lstar('67','2')*s('2')+lstar('67','3')*s('3')+lstar('67','4')*s('4')+lstar('67','5')*s('5')+lstar('67','6')*s('6')+lstar('67','7')*s('7')+lstar('67','8')*s('8')+lstar('67','9')*s('9')+lstar('67','10')*s('10')+lstar('67','11')*s('11')+lstar('67','12')*s('12')+lstar('67','13')*s('13')+lstar('67','14')*s('14')+lstar('67','15')*s('15')+lstar('67','16')*s('16')+lstar('67','17')*s('17')+lstar('67','18')*s('18')+lstar('67','19')*s('19')+lstar('67','20')*s('20')+lstar('67','21')*s('21')+lstar('67','22')*s('22')+lstar('67','23')*s('23')+lstar('67','24')*s('24')+lstar('67','25')*s('25')+lstar('67','26')*s('26')+lstar('67','27')*s('27')+lstar('67','28')*s('28')+lstar('67','29')*s('29')+lstar('67','30')*s('30')+lstar('67','31')*s('31')+lstar('67','32')*s('32')+lstar('67','33')*s('33')+lstar('67','34')*s('34')+lstar('67','35')*s('35')+lstar('67','36')*s('36')+lstar('67','37')*s('37')+lstar('67','38')*s('38')+lstar('67','39')*s('39')+lstar('67','40')*s('40')+lstar('67','41')*s('41')+lstar('67','42')*s('42')+lstar('67','43')*s('43')+lstar('67','44')*s('44')+lstar('67','45')*s('45')+lstar('67','46')*s('46')+lstar('67','47')*s('47')+lstar('67','48')*s('48')+lstar('67','49')*s('49')+lstar('67','50')*s('50')+lstar('67','51')*s('51')+lstar('67','52')*s('52')+lstar('67','53')*s('53')+lstar('67','54')*s('54')+lstar('67','55')*s('55')+lstar('67','56')*s('56')+lstar('67','57')*s('57')+lstar('67','58')*s('58')+lstar('67','59')*s('59')+lstar('67','60')*s('60')+lstar('67','61')*s('61')+lstar('67','62')*s('62')+lstar('67','63')*s('63')+lstar('67','64')*s('64')+lstar('67','65')*s('65')+lstar('67','66')*s('66')+lstar('67','67')*s('67')+lstar('67','68')*s('68')+lstar('67','69')*s('69')+lstar('67','70')*s('70')+lstar('67','71')*s('71')+lstar('67','72')*s('72')+lstar('67','73')*s('73')+lstar('67','74')*s('74')-vcupstcut('67','1')*s('75')-vcupstcut('67','2')*s('76')-vcupstcut('67','3')*s('77')-vcupstcut('67','4')*s('78')-vcupstcut('67','5')*s('79')-vcupstcut('67','6')*s('80')-vcupstcut('67','7')*s('81')-vcupstcut('67','8')*s('82')-vcupstcut('67','9')*s('83')-vcupstcut('67','10')*s('84')-vcupstcut('67','11')*s('85')-vcupstcut('67','12')*s('86')-vcupstcut('67','13')*s('87')-vcupstcut('67','14')*s('88')-vcupstcut('67','15')*s('89')-vcupstcut('67','16')*s('90')-eqeconupstcut('67')*s('91');
equat68 ..    p2pf('68') =E= lstar('68','1')*s('1')+lstar('68','2')*s('2')+lstar('68','3')*s('3')+lstar('68','4')*s('4')+lstar('68','5')*s('5')+lstar('68','6')*s('6')+lstar('68','7')*s('7')+lstar('68','8')*s('8')+lstar('68','9')*s('9')+lstar('68','10')*s('10')+lstar('68','11')*s('11')+lstar('68','12')*s('12')+lstar('68','13')*s('13')+lstar('68','14')*s('14')+lstar('68','15')*s('15')+lstar('68','16')*s('16')+lstar('68','17')*s('17')+lstar('68','18')*s('18')+lstar('68','19')*s('19')+lstar('68','20')*s('20')+lstar('68','21')*s('21')+lstar('68','22')*s('22')+lstar('68','23')*s('23')+lstar('68','24')*s('24')+lstar('68','25')*s('25')+lstar('68','26')*s('26')+lstar('68','27')*s('27')+lstar('68','28')*s('28')+lstar('68','29')*s('29')+lstar('68','30')*s('30')+lstar('68','31')*s('31')+lstar('68','32')*s('32')+lstar('68','33')*s('33')+lstar('68','34')*s('34')+lstar('68','35')*s('35')+lstar('68','36')*s('36')+lstar('68','37')*s('37')+lstar('68','38')*s('38')+lstar('68','39')*s('39')+lstar('68','40')*s('40')+lstar('68','41')*s('41')+lstar('68','42')*s('42')+lstar('68','43')*s('43')+lstar('68','44')*s('44')+lstar('68','45')*s('45')+lstar('68','46')*s('46')+lstar('68','47')*s('47')+lstar('68','48')*s('48')+lstar('68','49')*s('49')+lstar('68','50')*s('50')+lstar('68','51')*s('51')+lstar('68','52')*s('52')+lstar('68','53')*s('53')+lstar('68','54')*s('54')+lstar('68','55')*s('55')+lstar('68','56')*s('56')+lstar('68','57')*s('57')+lstar('68','58')*s('58')+lstar('68','59')*s('59')+lstar('68','60')*s('60')+lstar('68','61')*s('61')+lstar('68','62')*s('62')+lstar('68','63')*s('63')+lstar('68','64')*s('64')+lstar('68','65')*s('65')+lstar('68','66')*s('66')+lstar('68','67')*s('67')+lstar('68','68')*s('68')+lstar('68','69')*s('69')+lstar('68','70')*s('70')+lstar('68','71')*s('71')+lstar('68','72')*s('72')+lstar('68','73')*s('73')+lstar('68','74')*s('74')-vcupstcut('68','1')*s('75')-vcupstcut('68','2')*s('76')-vcupstcut('68','3')*s('77')-vcupstcut('68','4')*s('78')-vcupstcut('68','5')*s('79')-vcupstcut('68','6')*s('80')-vcupstcut('68','7')*s('81')-vcupstcut('68','8')*s('82')-vcupstcut('68','9')*s('83')-vcupstcut('68','10')*s('84')-vcupstcut('68','11')*s('85')-vcupstcut('68','12')*s('86')-vcupstcut('68','13')*s('87')-vcupstcut('68','14')*s('88')-vcupstcut('68','15')*s('89')-vcupstcut('68','16')*s('90')-eqeconupstcut('68')*s('91');
equat69 ..    p2pf('69') =E= lstar('69','1')*s('1')+lstar('69','2')*s('2')+lstar('69','3')*s('3')+lstar('69','4')*s('4')+lstar('69','5')*s('5')+lstar('69','6')*s('6')+lstar('69','7')*s('7')+lstar('69','8')*s('8')+lstar('69','9')*s('9')+lstar('69','10')*s('10')+lstar('69','11')*s('11')+lstar('69','12')*s('12')+lstar('69','13')*s('13')+lstar('69','14')*s('14')+lstar('69','15')*s('15')+lstar('69','16')*s('16')+lstar('69','17')*s('17')+lstar('69','18')*s('18')+lstar('69','19')*s('19')+lstar('69','20')*s('20')+lstar('69','21')*s('21')+lstar('69','22')*s('22')+lstar('69','23')*s('23')+lstar('69','24')*s('24')+lstar('69','25')*s('25')+lstar('69','26')*s('26')+lstar('69','27')*s('27')+lstar('69','28')*s('28')+lstar('69','29')*s('29')+lstar('69','30')*s('30')+lstar('69','31')*s('31')+lstar('69','32')*s('32')+lstar('69','33')*s('33')+lstar('69','34')*s('34')+lstar('69','35')*s('35')+lstar('69','36')*s('36')+lstar('69','37')*s('37')+lstar('69','38')*s('38')+lstar('69','39')*s('39')+lstar('69','40')*s('40')+lstar('69','41')*s('41')+lstar('69','42')*s('42')+lstar('69','43')*s('43')+lstar('69','44')*s('44')+lstar('69','45')*s('45')+lstar('69','46')*s('46')+lstar('69','47')*s('47')+lstar('69','48')*s('48')+lstar('69','49')*s('49')+lstar('69','50')*s('50')+lstar('69','51')*s('51')+lstar('69','52')*s('52')+lstar('69','53')*s('53')+lstar('69','54')*s('54')+lstar('69','55')*s('55')+lstar('69','56')*s('56')+lstar('69','57')*s('57')+lstar('69','58')*s('58')+lstar('69','59')*s('59')+lstar('69','60')*s('60')+lstar('69','61')*s('61')+lstar('69','62')*s('62')+lstar('69','63')*s('63')+lstar('69','64')*s('64')+lstar('69','65')*s('65')+lstar('69','66')*s('66')+lstar('69','67')*s('67')+lstar('69','68')*s('68')+lstar('69','69')*s('69')+lstar('69','70')*s('70')+lstar('69','71')*s('71')+lstar('69','72')*s('72')+lstar('69','73')*s('73')+lstar('69','74')*s('74')-vcupstcut('69','1')*s('75')-vcupstcut('69','2')*s('76')-vcupstcut('69','3')*s('77')-vcupstcut('69','4')*s('78')-vcupstcut('69','5')*s('79')-vcupstcut('69','6')*s('80')-vcupstcut('69','7')*s('81')-vcupstcut('69','8')*s('82')-vcupstcut('69','9')*s('83')-vcupstcut('69','10')*s('84')-vcupstcut('69','11')*s('85')-vcupstcut('69','12')*s('86')-vcupstcut('69','13')*s('87')-vcupstcut('69','14')*s('88')-vcupstcut('69','15')*s('89')-vcupstcut('69','16')*s('90')-eqeconupstcut('69')*s('91');
equat70 ..    p2pf('70') =E= lstar('70','1')*s('1')+lstar('70','2')*s('2')+lstar('70','3')*s('3')+lstar('70','4')*s('4')+lstar('70','5')*s('5')+lstar('70','6')*s('6')+lstar('70','7')*s('7')+lstar('70','8')*s('8')+lstar('70','9')*s('9')+lstar('70','10')*s('10')+lstar('70','11')*s('11')+lstar('70','12')*s('12')+lstar('70','13')*s('13')+lstar('70','14')*s('14')+lstar('70','15')*s('15')+lstar('70','16')*s('16')+lstar('70','17')*s('17')+lstar('70','18')*s('18')+lstar('70','19')*s('19')+lstar('70','20')*s('20')+lstar('70','21')*s('21')+lstar('70','22')*s('22')+lstar('70','23')*s('23')+lstar('70','24')*s('24')+lstar('70','25')*s('25')+lstar('70','26')*s('26')+lstar('70','27')*s('27')+lstar('70','28')*s('28')+lstar('70','29')*s('29')+lstar('70','30')*s('30')+lstar('70','31')*s('31')+lstar('70','32')*s('32')+lstar('70','33')*s('33')+lstar('70','34')*s('34')+lstar('70','35')*s('35')+lstar('70','36')*s('36')+lstar('70','37')*s('37')+lstar('70','38')*s('38')+lstar('70','39')*s('39')+lstar('70','40')*s('40')+lstar('70','41')*s('41')+lstar('70','42')*s('42')+lstar('70','43')*s('43')+lstar('70','44')*s('44')+lstar('70','45')*s('45')+lstar('70','46')*s('46')+lstar('70','47')*s('47')+lstar('70','48')*s('48')+lstar('70','49')*s('49')+lstar('70','50')*s('50')+lstar('70','51')*s('51')+lstar('70','52')*s('52')+lstar('70','53')*s('53')+lstar('70','54')*s('54')+lstar('70','55')*s('55')+lstar('70','56')*s('56')+lstar('70','57')*s('57')+lstar('70','58')*s('58')+lstar('70','59')*s('59')+lstar('70','60')*s('60')+lstar('70','61')*s('61')+lstar('70','62')*s('62')+lstar('70','63')*s('63')+lstar('70','64')*s('64')+lstar('70','65')*s('65')+lstar('70','66')*s('66')+lstar('70','67')*s('67')+lstar('70','68')*s('68')+lstar('70','69')*s('69')+lstar('70','70')*s('70')+lstar('70','71')*s('71')+lstar('70','72')*s('72')+lstar('70','73')*s('73')+lstar('70','74')*s('74')-vcupstcut('70','1')*s('75')-vcupstcut('70','2')*s('76')-vcupstcut('70','3')*s('77')-vcupstcut('70','4')*s('78')-vcupstcut('70','5')*s('79')-vcupstcut('70','6')*s('80')-vcupstcut('70','7')*s('81')-vcupstcut('70','8')*s('82')-vcupstcut('70','9')*s('83')-vcupstcut('70','10')*s('84')-vcupstcut('70','11')*s('85')-vcupstcut('70','12')*s('86')-vcupstcut('70','13')*s('87')-vcupstcut('70','14')*s('88')-vcupstcut('70','15')*s('89')-vcupstcut('70','16')*s('90')-eqeconupstcut('70')*s('91');
equat71 ..    p2pf('71') =E= lstar('71','1')*s('1')+lstar('71','2')*s('2')+lstar('71','3')*s('3')+lstar('71','4')*s('4')+lstar('71','5')*s('5')+lstar('71','6')*s('6')+lstar('71','7')*s('7')+lstar('71','8')*s('8')+lstar('71','9')*s('9')+lstar('71','10')*s('10')+lstar('71','11')*s('11')+lstar('71','12')*s('12')+lstar('71','13')*s('13')+lstar('71','14')*s('14')+lstar('71','15')*s('15')+lstar('71','16')*s('16')+lstar('71','17')*s('17')+lstar('71','18')*s('18')+lstar('71','19')*s('19')+lstar('71','20')*s('20')+lstar('71','21')*s('21')+lstar('71','22')*s('22')+lstar('71','23')*s('23')+lstar('71','24')*s('24')+lstar('71','25')*s('25')+lstar('71','26')*s('26')+lstar('71','27')*s('27')+lstar('71','28')*s('28')+lstar('71','29')*s('29')+lstar('71','30')*s('30')+lstar('71','31')*s('31')+lstar('71','32')*s('32')+lstar('71','33')*s('33')+lstar('71','34')*s('34')+lstar('71','35')*s('35')+lstar('71','36')*s('36')+lstar('71','37')*s('37')+lstar('71','38')*s('38')+lstar('71','39')*s('39')+lstar('71','40')*s('40')+lstar('71','41')*s('41')+lstar('71','42')*s('42')+lstar('71','43')*s('43')+lstar('71','44')*s('44')+lstar('71','45')*s('45')+lstar('71','46')*s('46')+lstar('71','47')*s('47')+lstar('71','48')*s('48')+lstar('71','49')*s('49')+lstar('71','50')*s('50')+lstar('71','51')*s('51')+lstar('71','52')*s('52')+lstar('71','53')*s('53')+lstar('71','54')*s('54')+lstar('71','55')*s('55')+lstar('71','56')*s('56')+lstar('71','57')*s('57')+lstar('71','58')*s('58')+lstar('71','59')*s('59')+lstar('71','60')*s('60')+lstar('71','61')*s('61')+lstar('71','62')*s('62')+lstar('71','63')*s('63')+lstar('71','64')*s('64')+lstar('71','65')*s('65')+lstar('71','66')*s('66')+lstar('71','67')*s('67')+lstar('71','68')*s('68')+lstar('71','69')*s('69')+lstar('71','70')*s('70')+lstar('71','71')*s('71')+lstar('71','72')*s('72')+lstar('71','73')*s('73')+lstar('71','74')*s('74')-vcupstcut('71','1')*s('75')-vcupstcut('71','2')*s('76')-vcupstcut('71','3')*s('77')-vcupstcut('71','4')*s('78')-vcupstcut('71','5')*s('79')-vcupstcut('71','6')*s('80')-vcupstcut('71','7')*s('81')-vcupstcut('71','8')*s('82')-vcupstcut('71','9')*s('83')-vcupstcut('71','10')*s('84')-vcupstcut('71','11')*s('85')-vcupstcut('71','12')*s('86')-vcupstcut('71','13')*s('87')-vcupstcut('71','14')*s('88')-vcupstcut('71','15')*s('89')-vcupstcut('71','16')*s('90')-eqeconupstcut('71')*s('91');
equat72 ..    p2pf('72') =E= lstar('72','1')*s('1')+lstar('72','2')*s('2')+lstar('72','3')*s('3')+lstar('72','4')*s('4')+lstar('72','5')*s('5')+lstar('72','6')*s('6')+lstar('72','7')*s('7')+lstar('72','8')*s('8')+lstar('72','9')*s('9')+lstar('72','10')*s('10')+lstar('72','11')*s('11')+lstar('72','12')*s('12')+lstar('72','13')*s('13')+lstar('72','14')*s('14')+lstar('72','15')*s('15')+lstar('72','16')*s('16')+lstar('72','17')*s('17')+lstar('72','18')*s('18')+lstar('72','19')*s('19')+lstar('72','20')*s('20')+lstar('72','21')*s('21')+lstar('72','22')*s('22')+lstar('72','23')*s('23')+lstar('72','24')*s('24')+lstar('72','25')*s('25')+lstar('72','26')*s('26')+lstar('72','27')*s('27')+lstar('72','28')*s('28')+lstar('72','29')*s('29')+lstar('72','30')*s('30')+lstar('72','31')*s('31')+lstar('72','32')*s('32')+lstar('72','33')*s('33')+lstar('72','34')*s('34')+lstar('72','35')*s('35')+lstar('72','36')*s('36')+lstar('72','37')*s('37')+lstar('72','38')*s('38')+lstar('72','39')*s('39')+lstar('72','40')*s('40')+lstar('72','41')*s('41')+lstar('72','42')*s('42')+lstar('72','43')*s('43')+lstar('72','44')*s('44')+lstar('72','45')*s('45')+lstar('72','46')*s('46')+lstar('72','47')*s('47')+lstar('72','48')*s('48')+lstar('72','49')*s('49')+lstar('72','50')*s('50')+lstar('72','51')*s('51')+lstar('72','52')*s('52')+lstar('72','53')*s('53')+lstar('72','54')*s('54')+lstar('72','55')*s('55')+lstar('72','56')*s('56')+lstar('72','57')*s('57')+lstar('72','58')*s('58')+lstar('72','59')*s('59')+lstar('72','60')*s('60')+lstar('72','61')*s('61')+lstar('72','62')*s('62')+lstar('72','63')*s('63')+lstar('72','64')*s('64')+lstar('72','65')*s('65')+lstar('72','66')*s('66')+lstar('72','67')*s('67')+lstar('72','68')*s('68')+lstar('72','69')*s('69')+lstar('72','70')*s('70')+lstar('72','71')*s('71')+lstar('72','72')*s('72')+lstar('72','73')*s('73')+lstar('72','74')*s('74')-vcupstcut('72','1')*s('75')-vcupstcut('72','2')*s('76')-vcupstcut('72','3')*s('77')-vcupstcut('72','4')*s('78')-vcupstcut('72','5')*s('79')-vcupstcut('72','6')*s('80')-vcupstcut('72','7')*s('81')-vcupstcut('72','8')*s('82')-vcupstcut('72','9')*s('83')-vcupstcut('72','10')*s('84')-vcupstcut('72','11')*s('85')-vcupstcut('72','12')*s('86')-vcupstcut('72','13')*s('87')-vcupstcut('72','14')*s('88')-vcupstcut('72','15')*s('89')-vcupstcut('72','16')*s('90')-eqeconupstcut('72')*s('91');
equat73 ..    p2pf('73') =E= lstar('73','1')*s('1')+lstar('73','2')*s('2')+lstar('73','3')*s('3')+lstar('73','4')*s('4')+lstar('73','5')*s('5')+lstar('73','6')*s('6')+lstar('73','7')*s('7')+lstar('73','8')*s('8')+lstar('73','9')*s('9')+lstar('73','10')*s('10')+lstar('73','11')*s('11')+lstar('73','12')*s('12')+lstar('73','13')*s('13')+lstar('73','14')*s('14')+lstar('73','15')*s('15')+lstar('73','16')*s('16')+lstar('73','17')*s('17')+lstar('73','18')*s('18')+lstar('73','19')*s('19')+lstar('73','20')*s('20')+lstar('73','21')*s('21')+lstar('73','22')*s('22')+lstar('73','23')*s('23')+lstar('73','24')*s('24')+lstar('73','25')*s('25')+lstar('73','26')*s('26')+lstar('73','27')*s('27')+lstar('73','28')*s('28')+lstar('73','29')*s('29')+lstar('73','30')*s('30')+lstar('73','31')*s('31')+lstar('73','32')*s('32')+lstar('73','33')*s('33')+lstar('73','34')*s('34')+lstar('73','35')*s('35')+lstar('73','36')*s('36')+lstar('73','37')*s('37')+lstar('73','38')*s('38')+lstar('73','39')*s('39')+lstar('73','40')*s('40')+lstar('73','41')*s('41')+lstar('73','42')*s('42')+lstar('73','43')*s('43')+lstar('73','44')*s('44')+lstar('73','45')*s('45')+lstar('73','46')*s('46')+lstar('73','47')*s('47')+lstar('73','48')*s('48')+lstar('73','49')*s('49')+lstar('73','50')*s('50')+lstar('73','51')*s('51')+lstar('73','52')*s('52')+lstar('73','53')*s('53')+lstar('73','54')*s('54')+lstar('73','55')*s('55')+lstar('73','56')*s('56')+lstar('73','57')*s('57')+lstar('73','58')*s('58')+lstar('73','59')*s('59')+lstar('73','60')*s('60')+lstar('73','61')*s('61')+lstar('73','62')*s('62')+lstar('73','63')*s('63')+lstar('73','64')*s('64')+lstar('73','65')*s('65')+lstar('73','66')*s('66')+lstar('73','67')*s('67')+lstar('73','68')*s('68')+lstar('73','69')*s('69')+lstar('73','70')*s('70')+lstar('73','71')*s('71')+lstar('73','72')*s('72')+lstar('73','73')*s('73')+lstar('73','74')*s('74')-vcupstcut('73','1')*s('75')-vcupstcut('73','2')*s('76')-vcupstcut('73','3')*s('77')-vcupstcut('73','4')*s('78')-vcupstcut('73','5')*s('79')-vcupstcut('73','6')*s('80')-vcupstcut('73','7')*s('81')-vcupstcut('73','8')*s('82')-vcupstcut('73','9')*s('83')-vcupstcut('73','10')*s('84')-vcupstcut('73','11')*s('85')-vcupstcut('73','12')*s('86')-vcupstcut('73','13')*s('87')-vcupstcut('73','14')*s('88')-vcupstcut('73','15')*s('89')-vcupstcut('73','16')*s('90')-eqeconupstcut('73')*s('91');
equat74 ..    p2pf('74') =E= lstar('74','1')*s('1')+lstar('74','2')*s('2')+lstar('74','3')*s('3')+lstar('74','4')*s('4')+lstar('74','5')*s('5')+lstar('74','6')*s('6')+lstar('74','7')*s('7')+lstar('74','8')*s('8')+lstar('74','9')*s('9')+lstar('74','10')*s('10')+lstar('74','11')*s('11')+lstar('74','12')*s('12')+lstar('74','13')*s('13')+lstar('74','14')*s('14')+lstar('74','15')*s('15')+lstar('74','16')*s('16')+lstar('74','17')*s('17')+lstar('74','18')*s('18')+lstar('74','19')*s('19')+lstar('74','20')*s('20')+lstar('74','21')*s('21')+lstar('74','22')*s('22')+lstar('74','23')*s('23')+lstar('74','24')*s('24')+lstar('74','25')*s('25')+lstar('74','26')*s('26')+lstar('74','27')*s('27')+lstar('74','28')*s('28')+lstar('74','29')*s('29')+lstar('74','30')*s('30')+lstar('74','31')*s('31')+lstar('74','32')*s('32')+lstar('74','33')*s('33')+lstar('74','34')*s('34')+lstar('74','35')*s('35')+lstar('74','36')*s('36')+lstar('74','37')*s('37')+lstar('74','38')*s('38')+lstar('74','39')*s('39')+lstar('74','40')*s('40')+lstar('74','41')*s('41')+lstar('74','42')*s('42')+lstar('74','43')*s('43')+lstar('74','44')*s('44')+lstar('74','45')*s('45')+lstar('74','46')*s('46')+lstar('74','47')*s('47')+lstar('74','48')*s('48')+lstar('74','49')*s('49')+lstar('74','50')*s('50')+lstar('74','51')*s('51')+lstar('74','52')*s('52')+lstar('74','53')*s('53')+lstar('74','54')*s('54')+lstar('74','55')*s('55')+lstar('74','56')*s('56')+lstar('74','57')*s('57')+lstar('74','58')*s('58')+lstar('74','59')*s('59')+lstar('74','60')*s('60')+lstar('74','61')*s('61')+lstar('74','62')*s('62')+lstar('74','63')*s('63')+lstar('74','64')*s('64')+lstar('74','65')*s('65')+lstar('74','66')*s('66')+lstar('74','67')*s('67')+lstar('74','68')*s('68')+lstar('74','69')*s('69')+lstar('74','70')*s('70')+lstar('74','71')*s('71')+lstar('74','72')*s('72')+lstar('74','73')*s('73')+lstar('74','74')*s('74')-vcupstcut('74','1')*s('75')-vcupstcut('74','2')*s('76')-vcupstcut('74','3')*s('77')-vcupstcut('74','4')*s('78')-vcupstcut('74','5')*s('79')-vcupstcut('74','6')*s('80')-vcupstcut('74','7')*s('81')-vcupstcut('74','8')*s('82')-vcupstcut('74','9')*s('83')-vcupstcut('74','10')*s('84')-vcupstcut('74','11')*s('85')-vcupstcut('74','12')*s('86')-vcupstcut('74','13')*s('87')-vcupstcut('74','14')*s('88')-vcupstcut('74','15')*s('89')-vcupstcut('74','16')*s('90')-eqeconupstcut('74')*s('91');
equat75 ..    p2pf('75') =E= -vcdowncut('1','1')*s('1')-vcdowncut('1','2')*s('2')-vcdowncut('1','3')*s('3')-vcdowncut('1','4')*s('4')-vcdowncut('1','5')*s('5')-vcdowncut('1','6')*s('6')-vcdowncut('1','7')*s('7')-vcdowncut('1','8')*s('8')-vcdowncut('1','9')*s('9')-vcdowncut('1','10')*s('10')-vcdowncut('1','11')*s('11')-vcdowncut('1','12')*s('12')-vcdowncut('1','13')*s('13')-vcdowncut('1','14')*s('14')-vcdowncut('1','15')*s('15')-vcdowncut('1','16')*s('16')-vcdowncut('1','17')*s('17')-vcdowncut('1','18')*s('18')-vcdowncut('1','19')*s('19')-vcdowncut('1','20')*s('20')-vcdowncut('1','21')*s('21')-vcdowncut('1','22')*s('22')-vcdowncut('1','23')*s('23')-vcdowncut('1','24')*s('24')-vcdowncut('1','25')*s('25')-vcdowncut('1','26')*s('26')-vcdowncut('1','27')*s('27')-vcdowncut('1','28')*s('28')-vcdowncut('1','29')*s('29')-vcdowncut('1','30')*s('30')-vcdowncut('1','31')*s('31')-vcdowncut('1','32')*s('32')-vcdowncut('1','33')*s('33')-vcdowncut('1','34')*s('34')-vcdowncut('1','35')*s('35')-vcdowncut('1','36')*s('36')-vcdowncut('1','37')*s('37')-vcdowncut('1','38')*s('38')-vcdowncut('1','39')*s('39')-vcdowncut('1','40')*s('40')-vcdowncut('1','41')*s('41')-vcdowncut('1','42')*s('42')-vcdowncut('1','43')*s('43')-vcdowncut('1','44')*s('44')-vcdowncut('1','45')*s('45')-vcdowncut('1','46')*s('46')-vcdowncut('1','47')*s('47')-vcdowncut('1','48')*s('48')-vcdowncut('1','49')*s('49')-vcdowncut('1','50')*s('50')-vcdowncut('1','51')*s('51')-vcdowncut('1','52')*s('52')-vcdowncut('1','53')*s('53')-vcdowncut('1','54')*s('54')-vcdowncut('1','55')*s('55')-vcdowncut('1','56')*s('56')-vcdowncut('1','57')*s('57')-vcdowncut('1','58')*s('58')-vcdowncut('1','59')*s('59')-vcdowncut('1','60')*s('60')-vcdowncut('1','61')*s('61')-vcdowncut('1','62')*s('62')-vcdowncut('1','63')*s('63')-vcdowncut('1','64')*s('64')-vcdowncut('1','65')*s('65')-vcdowncut('1','66')*s('66')-vcdowncut('1','67')*s('67')-vcdowncut('1','68')*s('68')-vcdowncut('1','69')*s('69')-vcdowncut('1','70')*s('70')-vcdowncut('1','71')*s('71')-vcdowncut('1','72')*s('72')-vcdowncut('1','73')*s('73')-vcdowncut('1','74')*s('74')+vcy('1','1')*s('75')+vcy('1','2')*s('76')+vcy('1','3')*s('77')+vcy('1','4')*s('78')+vcy('1','5')*s('79')+vcy('1','6')*s('80')+vcy('1','7')*s('81')+vcy('1','8')*s('82')+vcy('1','9')*s('83')+vcy('1','10')*s('84')+vcy('1','11')*s('85')+vcy('1','12')*s('86')+vcy('1','13')*s('87')+vcy('1','14')*s('88')+vcy('1','15')*s('89')+vcy('1','16')*s('90')-eqvcupstcut('1')*s('91');
equat76 ..    p2pf('76') =E= -vcdowncut('2','1')*s('1')-vcdowncut('2','2')*s('2')-vcdowncut('2','3')*s('3')-vcdowncut('2','4')*s('4')-vcdowncut('2','5')*s('5')-vcdowncut('2','6')*s('6')-vcdowncut('2','7')*s('7')-vcdowncut('2','8')*s('8')-vcdowncut('2','9')*s('9')-vcdowncut('2','10')*s('10')-vcdowncut('2','11')*s('11')-vcdowncut('2','12')*s('12')-vcdowncut('2','13')*s('13')-vcdowncut('2','14')*s('14')-vcdowncut('2','15')*s('15')-vcdowncut('2','16')*s('16')-vcdowncut('2','17')*s('17')-vcdowncut('2','18')*s('18')-vcdowncut('2','19')*s('19')-vcdowncut('2','20')*s('20')-vcdowncut('2','21')*s('21')-vcdowncut('2','22')*s('22')-vcdowncut('2','23')*s('23')-vcdowncut('2','24')*s('24')-vcdowncut('2','25')*s('25')-vcdowncut('2','26')*s('26')-vcdowncut('2','27')*s('27')-vcdowncut('2','28')*s('28')-vcdowncut('2','29')*s('29')-vcdowncut('2','30')*s('30')-vcdowncut('2','31')*s('31')-vcdowncut('2','32')*s('32')-vcdowncut('2','33')*s('33')-vcdowncut('2','34')*s('34')-vcdowncut('2','35')*s('35')-vcdowncut('2','36')*s('36')-vcdowncut('2','37')*s('37')-vcdowncut('2','38')*s('38')-vcdowncut('2','39')*s('39')-vcdowncut('2','40')*s('40')-vcdowncut('2','41')*s('41')-vcdowncut('2','42')*s('42')-vcdowncut('2','43')*s('43')-vcdowncut('2','44')*s('44')-vcdowncut('2','45')*s('45')-vcdowncut('2','46')*s('46')-vcdowncut('2','47')*s('47')-vcdowncut('2','48')*s('48')-vcdowncut('2','49')*s('49')-vcdowncut('2','50')*s('50')-vcdowncut('2','51')*s('51')-vcdowncut('2','52')*s('52')-vcdowncut('2','53')*s('53')-vcdowncut('2','54')*s('54')-vcdowncut('2','55')*s('55')-vcdowncut('2','56')*s('56')-vcdowncut('2','57')*s('57')-vcdowncut('2','58')*s('58')-vcdowncut('2','59')*s('59')-vcdowncut('2','60')*s('60')-vcdowncut('2','61')*s('61')-vcdowncut('2','62')*s('62')-vcdowncut('2','63')*s('63')-vcdowncut('2','64')*s('64')-vcdowncut('2','65')*s('65')-vcdowncut('2','66')*s('66')-vcdowncut('2','67')*s('67')-vcdowncut('2','68')*s('68')-vcdowncut('2','69')*s('69')-vcdowncut('2','70')*s('70')-vcdowncut('2','71')*s('71')-vcdowncut('2','72')*s('72')-vcdowncut('2','73')*s('73')-vcdowncut('2','74')*s('74')+vcy('2','1')*s('75')+vcy('2','2')*s('76')+vcy('2','3')*s('77')+vcy('2','4')*s('78')+vcy('2','5')*s('79')+vcy('2','6')*s('80')+vcy('2','7')*s('81')+vcy('2','8')*s('82')+vcy('2','9')*s('83')+vcy('2','10')*s('84')+vcy('2','11')*s('85')+vcy('2','12')*s('86')+vcy('2','13')*s('87')+vcy('2','14')*s('88')+vcy('2','15')*s('89')+vcy('2','16')*s('90')-eqvcupstcut('2')*s('91');
equat77 ..    p2pf('77') =E= -vcdowncut('3','1')*s('1')-vcdowncut('3','2')*s('2')-vcdowncut('3','3')*s('3')-vcdowncut('3','4')*s('4')-vcdowncut('3','5')*s('5')-vcdowncut('3','6')*s('6')-vcdowncut('3','7')*s('7')-vcdowncut('3','8')*s('8')-vcdowncut('3','9')*s('9')-vcdowncut('3','10')*s('10')-vcdowncut('3','11')*s('11')-vcdowncut('3','12')*s('12')-vcdowncut('3','13')*s('13')-vcdowncut('3','14')*s('14')-vcdowncut('3','15')*s('15')-vcdowncut('3','16')*s('16')-vcdowncut('3','17')*s('17')-vcdowncut('3','18')*s('18')-vcdowncut('3','19')*s('19')-vcdowncut('3','20')*s('20')-vcdowncut('3','21')*s('21')-vcdowncut('3','22')*s('22')-vcdowncut('3','23')*s('23')-vcdowncut('3','24')*s('24')-vcdowncut('3','25')*s('25')-vcdowncut('3','26')*s('26')-vcdowncut('3','27')*s('27')-vcdowncut('3','28')*s('28')-vcdowncut('3','29')*s('29')-vcdowncut('3','30')*s('30')-vcdowncut('3','31')*s('31')-vcdowncut('3','32')*s('32')-vcdowncut('3','33')*s('33')-vcdowncut('3','34')*s('34')-vcdowncut('3','35')*s('35')-vcdowncut('3','36')*s('36')-vcdowncut('3','37')*s('37')-vcdowncut('3','38')*s('38')-vcdowncut('3','39')*s('39')-vcdowncut('3','40')*s('40')-vcdowncut('3','41')*s('41')-vcdowncut('3','42')*s('42')-vcdowncut('3','43')*s('43')-vcdowncut('3','44')*s('44')-vcdowncut('3','45')*s('45')-vcdowncut('3','46')*s('46')-vcdowncut('3','47')*s('47')-vcdowncut('3','48')*s('48')-vcdowncut('3','49')*s('49')-vcdowncut('3','50')*s('50')-vcdowncut('3','51')*s('51')-vcdowncut('3','52')*s('52')-vcdowncut('3','53')*s('53')-vcdowncut('3','54')*s('54')-vcdowncut('3','55')*s('55')-vcdowncut('3','56')*s('56')-vcdowncut('3','57')*s('57')-vcdowncut('3','58')*s('58')-vcdowncut('3','59')*s('59')-vcdowncut('3','60')*s('60')-vcdowncut('3','61')*s('61')-vcdowncut('3','62')*s('62')-vcdowncut('3','63')*s('63')-vcdowncut('3','64')*s('64')-vcdowncut('3','65')*s('65')-vcdowncut('3','66')*s('66')-vcdowncut('3','67')*s('67')-vcdowncut('3','68')*s('68')-vcdowncut('3','69')*s('69')-vcdowncut('3','70')*s('70')-vcdowncut('3','71')*s('71')-vcdowncut('3','72')*s('72')-vcdowncut('3','73')*s('73')-vcdowncut('3','74')*s('74')+vcy('3','1')*s('75')+vcy('3','2')*s('76')+vcy('3','3')*s('77')+vcy('3','4')*s('78')+vcy('3','5')*s('79')+vcy('3','6')*s('80')+vcy('3','7')*s('81')+vcy('3','8')*s('82')+vcy('3','9')*s('83')+vcy('3','10')*s('84')+vcy('3','11')*s('85')+vcy('3','12')*s('86')+vcy('3','13')*s('87')+vcy('3','14')*s('88')+vcy('3','15')*s('89')+vcy('3','16')*s('90')-eqvcupstcut('3')*s('91');
equat78 ..    p2pf('78') =E= -vcdowncut('4','1')*s('1')-vcdowncut('4','2')*s('2')-vcdowncut('4','3')*s('3')-vcdowncut('4','4')*s('4')-vcdowncut('4','5')*s('5')-vcdowncut('4','6')*s('6')-vcdowncut('4','7')*s('7')-vcdowncut('4','8')*s('8')-vcdowncut('4','9')*s('9')-vcdowncut('4','10')*s('10')-vcdowncut('4','11')*s('11')-vcdowncut('4','12')*s('12')-vcdowncut('4','13')*s('13')-vcdowncut('4','14')*s('14')-vcdowncut('4','15')*s('15')-vcdowncut('4','16')*s('16')-vcdowncut('4','17')*s('17')-vcdowncut('4','18')*s('18')-vcdowncut('4','19')*s('19')-vcdowncut('4','20')*s('20')-vcdowncut('4','21')*s('21')-vcdowncut('4','22')*s('22')-vcdowncut('4','23')*s('23')-vcdowncut('4','24')*s('24')-vcdowncut('4','25')*s('25')-vcdowncut('4','26')*s('26')-vcdowncut('4','27')*s('27')-vcdowncut('4','28')*s('28')-vcdowncut('4','29')*s('29')-vcdowncut('4','30')*s('30')-vcdowncut('4','31')*s('31')-vcdowncut('4','32')*s('32')-vcdowncut('4','33')*s('33')-vcdowncut('4','34')*s('34')-vcdowncut('4','35')*s('35')-vcdowncut('4','36')*s('36')-vcdowncut('4','37')*s('37')-vcdowncut('4','38')*s('38')-vcdowncut('4','39')*s('39')-vcdowncut('4','40')*s('40')-vcdowncut('4','41')*s('41')-vcdowncut('4','42')*s('42')-vcdowncut('4','43')*s('43')-vcdowncut('4','44')*s('44')-vcdowncut('4','45')*s('45')-vcdowncut('4','46')*s('46')-vcdowncut('4','47')*s('47')-vcdowncut('4','48')*s('48')-vcdowncut('4','49')*s('49')-vcdowncut('4','50')*s('50')-vcdowncut('4','51')*s('51')-vcdowncut('4','52')*s('52')-vcdowncut('4','53')*s('53')-vcdowncut('4','54')*s('54')-vcdowncut('4','55')*s('55')-vcdowncut('4','56')*s('56')-vcdowncut('4','57')*s('57')-vcdowncut('4','58')*s('58')-vcdowncut('4','59')*s('59')-vcdowncut('4','60')*s('60')-vcdowncut('4','61')*s('61')-vcdowncut('4','62')*s('62')-vcdowncut('4','63')*s('63')-vcdowncut('4','64')*s('64')-vcdowncut('4','65')*s('65')-vcdowncut('4','66')*s('66')-vcdowncut('4','67')*s('67')-vcdowncut('4','68')*s('68')-vcdowncut('4','69')*s('69')-vcdowncut('4','70')*s('70')-vcdowncut('4','71')*s('71')-vcdowncut('4','72')*s('72')-vcdowncut('4','73')*s('73')-vcdowncut('4','74')*s('74')+vcy('4','1')*s('75')+vcy('4','2')*s('76')+vcy('4','3')*s('77')+vcy('4','4')*s('78')+vcy('4','5')*s('79')+vcy('4','6')*s('80')+vcy('4','7')*s('81')+vcy('4','8')*s('82')+vcy('4','9')*s('83')+vcy('4','10')*s('84')+vcy('4','11')*s('85')+vcy('4','12')*s('86')+vcy('4','13')*s('87')+vcy('4','14')*s('88')+vcy('4','15')*s('89')+vcy('4','16')*s('90')-eqvcupstcut('4')*s('91');
equat79 ..    p2pf('79') =E= -vcdowncut('5','1')*s('1')-vcdowncut('5','2')*s('2')-vcdowncut('5','3')*s('3')-vcdowncut('5','4')*s('4')-vcdowncut('5','5')*s('5')-vcdowncut('5','6')*s('6')-vcdowncut('5','7')*s('7')-vcdowncut('5','8')*s('8')-vcdowncut('5','9')*s('9')-vcdowncut('5','10')*s('10')-vcdowncut('5','11')*s('11')-vcdowncut('5','12')*s('12')-vcdowncut('5','13')*s('13')-vcdowncut('5','14')*s('14')-vcdowncut('5','15')*s('15')-vcdowncut('5','16')*s('16')-vcdowncut('5','17')*s('17')-vcdowncut('5','18')*s('18')-vcdowncut('5','19')*s('19')-vcdowncut('5','20')*s('20')-vcdowncut('5','21')*s('21')-vcdowncut('5','22')*s('22')-vcdowncut('5','23')*s('23')-vcdowncut('5','24')*s('24')-vcdowncut('5','25')*s('25')-vcdowncut('5','26')*s('26')-vcdowncut('5','27')*s('27')-vcdowncut('5','28')*s('28')-vcdowncut('5','29')*s('29')-vcdowncut('5','30')*s('30')-vcdowncut('5','31')*s('31')-vcdowncut('5','32')*s('32')-vcdowncut('5','33')*s('33')-vcdowncut('5','34')*s('34')-vcdowncut('5','35')*s('35')-vcdowncut('5','36')*s('36')-vcdowncut('5','37')*s('37')-vcdowncut('5','38')*s('38')-vcdowncut('5','39')*s('39')-vcdowncut('5','40')*s('40')-vcdowncut('5','41')*s('41')-vcdowncut('5','42')*s('42')-vcdowncut('5','43')*s('43')-vcdowncut('5','44')*s('44')-vcdowncut('5','45')*s('45')-vcdowncut('5','46')*s('46')-vcdowncut('5','47')*s('47')-vcdowncut('5','48')*s('48')-vcdowncut('5','49')*s('49')-vcdowncut('5','50')*s('50')-vcdowncut('5','51')*s('51')-vcdowncut('5','52')*s('52')-vcdowncut('5','53')*s('53')-vcdowncut('5','54')*s('54')-vcdowncut('5','55')*s('55')-vcdowncut('5','56')*s('56')-vcdowncut('5','57')*s('57')-vcdowncut('5','58')*s('58')-vcdowncut('5','59')*s('59')-vcdowncut('5','60')*s('60')-vcdowncut('5','61')*s('61')-vcdowncut('5','62')*s('62')-vcdowncut('5','63')*s('63')-vcdowncut('5','64')*s('64')-vcdowncut('5','65')*s('65')-vcdowncut('5','66')*s('66')-vcdowncut('5','67')*s('67')-vcdowncut('5','68')*s('68')-vcdowncut('5','69')*s('69')-vcdowncut('5','70')*s('70')-vcdowncut('5','71')*s('71')-vcdowncut('5','72')*s('72')-vcdowncut('5','73')*s('73')-vcdowncut('5','74')*s('74')+vcy('5','1')*s('75')+vcy('5','2')*s('76')+vcy('5','3')*s('77')+vcy('5','4')*s('78')+vcy('5','5')*s('79')+vcy('5','6')*s('80')+vcy('5','7')*s('81')+vcy('5','8')*s('82')+vcy('5','9')*s('83')+vcy('5','10')*s('84')+vcy('5','11')*s('85')+vcy('5','12')*s('86')+vcy('5','13')*s('87')+vcy('5','14')*s('88')+vcy('5','15')*s('89')+vcy('5','16')*s('90')-eqvcupstcut('5')*s('91');
equat80 ..    p2pf('80') =E= -vcdowncut('6','1')*s('1')-vcdowncut('6','2')*s('2')-vcdowncut('6','3')*s('3')-vcdowncut('6','4')*s('4')-vcdowncut('6','5')*s('5')-vcdowncut('6','6')*s('6')-vcdowncut('6','7')*s('7')-vcdowncut('6','8')*s('8')-vcdowncut('6','9')*s('9')-vcdowncut('6','10')*s('10')-vcdowncut('6','11')*s('11')-vcdowncut('6','12')*s('12')-vcdowncut('6','13')*s('13')-vcdowncut('6','14')*s('14')-vcdowncut('6','15')*s('15')-vcdowncut('6','16')*s('16')-vcdowncut('6','17')*s('17')-vcdowncut('6','18')*s('18')-vcdowncut('6','19')*s('19')-vcdowncut('6','20')*s('20')-vcdowncut('6','21')*s('21')-vcdowncut('6','22')*s('22')-vcdowncut('6','23')*s('23')-vcdowncut('6','24')*s('24')-vcdowncut('6','25')*s('25')-vcdowncut('6','26')*s('26')-vcdowncut('6','27')*s('27')-vcdowncut('6','28')*s('28')-vcdowncut('6','29')*s('29')-vcdowncut('6','30')*s('30')-vcdowncut('6','31')*s('31')-vcdowncut('6','32')*s('32')-vcdowncut('6','33')*s('33')-vcdowncut('6','34')*s('34')-vcdowncut('6','35')*s('35')-vcdowncut('6','36')*s('36')-vcdowncut('6','37')*s('37')-vcdowncut('6','38')*s('38')-vcdowncut('6','39')*s('39')-vcdowncut('6','40')*s('40')-vcdowncut('6','41')*s('41')-vcdowncut('6','42')*s('42')-vcdowncut('6','43')*s('43')-vcdowncut('6','44')*s('44')-vcdowncut('6','45')*s('45')-vcdowncut('6','46')*s('46')-vcdowncut('6','47')*s('47')-vcdowncut('6','48')*s('48')-vcdowncut('6','49')*s('49')-vcdowncut('6','50')*s('50')-vcdowncut('6','51')*s('51')-vcdowncut('6','52')*s('52')-vcdowncut('6','53')*s('53')-vcdowncut('6','54')*s('54')-vcdowncut('6','55')*s('55')-vcdowncut('6','56')*s('56')-vcdowncut('6','57')*s('57')-vcdowncut('6','58')*s('58')-vcdowncut('6','59')*s('59')-vcdowncut('6','60')*s('60')-vcdowncut('6','61')*s('61')-vcdowncut('6','62')*s('62')-vcdowncut('6','63')*s('63')-vcdowncut('6','64')*s('64')-vcdowncut('6','65')*s('65')-vcdowncut('6','66')*s('66')-vcdowncut('6','67')*s('67')-vcdowncut('6','68')*s('68')-vcdowncut('6','69')*s('69')-vcdowncut('6','70')*s('70')-vcdowncut('6','71')*s('71')-vcdowncut('6','72')*s('72')-vcdowncut('6','73')*s('73')-vcdowncut('6','74')*s('74')+vcy('6','1')*s('75')+vcy('6','2')*s('76')+vcy('6','3')*s('77')+vcy('6','4')*s('78')+vcy('6','5')*s('79')+vcy('6','6')*s('80')+vcy('6','7')*s('81')+vcy('6','8')*s('82')+vcy('6','9')*s('83')+vcy('6','10')*s('84')+vcy('6','11')*s('85')+vcy('6','12')*s('86')+vcy('6','13')*s('87')+vcy('6','14')*s('88')+vcy('6','15')*s('89')+vcy('6','16')*s('90')-eqvcupstcut('6')*s('91');
equat81 ..    p2pf('81') =E= -vcdowncut('7','1')*s('1')-vcdowncut('7','2')*s('2')-vcdowncut('7','3')*s('3')-vcdowncut('7','4')*s('4')-vcdowncut('7','5')*s('5')-vcdowncut('7','6')*s('6')-vcdowncut('7','7')*s('7')-vcdowncut('7','8')*s('8')-vcdowncut('7','9')*s('9')-vcdowncut('7','10')*s('10')-vcdowncut('7','11')*s('11')-vcdowncut('7','12')*s('12')-vcdowncut('7','13')*s('13')-vcdowncut('7','14')*s('14')-vcdowncut('7','15')*s('15')-vcdowncut('7','16')*s('16')-vcdowncut('7','17')*s('17')-vcdowncut('7','18')*s('18')-vcdowncut('7','19')*s('19')-vcdowncut('7','20')*s('20')-vcdowncut('7','21')*s('21')-vcdowncut('7','22')*s('22')-vcdowncut('7','23')*s('23')-vcdowncut('7','24')*s('24')-vcdowncut('7','25')*s('25')-vcdowncut('7','26')*s('26')-vcdowncut('7','27')*s('27')-vcdowncut('7','28')*s('28')-vcdowncut('7','29')*s('29')-vcdowncut('7','30')*s('30')-vcdowncut('7','31')*s('31')-vcdowncut('7','32')*s('32')-vcdowncut('7','33')*s('33')-vcdowncut('7','34')*s('34')-vcdowncut('7','35')*s('35')-vcdowncut('7','36')*s('36')-vcdowncut('7','37')*s('37')-vcdowncut('7','38')*s('38')-vcdowncut('7','39')*s('39')-vcdowncut('7','40')*s('40')-vcdowncut('7','41')*s('41')-vcdowncut('7','42')*s('42')-vcdowncut('7','43')*s('43')-vcdowncut('7','44')*s('44')-vcdowncut('7','45')*s('45')-vcdowncut('7','46')*s('46')-vcdowncut('7','47')*s('47')-vcdowncut('7','48')*s('48')-vcdowncut('7','49')*s('49')-vcdowncut('7','50')*s('50')-vcdowncut('7','51')*s('51')-vcdowncut('7','52')*s('52')-vcdowncut('7','53')*s('53')-vcdowncut('7','54')*s('54')-vcdowncut('7','55')*s('55')-vcdowncut('7','56')*s('56')-vcdowncut('7','57')*s('57')-vcdowncut('7','58')*s('58')-vcdowncut('7','59')*s('59')-vcdowncut('7','60')*s('60')-vcdowncut('7','61')*s('61')-vcdowncut('7','62')*s('62')-vcdowncut('7','63')*s('63')-vcdowncut('7','64')*s('64')-vcdowncut('7','65')*s('65')-vcdowncut('7','66')*s('66')-vcdowncut('7','67')*s('67')-vcdowncut('7','68')*s('68')-vcdowncut('7','69')*s('69')-vcdowncut('7','70')*s('70')-vcdowncut('7','71')*s('71')-vcdowncut('7','72')*s('72')-vcdowncut('7','73')*s('73')-vcdowncut('7','74')*s('74')+vcy('7','1')*s('75')+vcy('7','2')*s('76')+vcy('7','3')*s('77')+vcy('7','4')*s('78')+vcy('7','5')*s('79')+vcy('7','6')*s('80')+vcy('7','7')*s('81')+vcy('7','8')*s('82')+vcy('7','9')*s('83')+vcy('7','10')*s('84')+vcy('7','11')*s('85')+vcy('7','12')*s('86')+vcy('7','13')*s('87')+vcy('7','14')*s('88')+vcy('7','15')*s('89')+vcy('7','16')*s('90')-eqvcupstcut('7')*s('91');
equat82 ..    p2pf('82') =E= -vcdowncut('8','1')*s('1')-vcdowncut('8','2')*s('2')-vcdowncut('8','3')*s('3')-vcdowncut('8','4')*s('4')-vcdowncut('8','5')*s('5')-vcdowncut('8','6')*s('6')-vcdowncut('8','7')*s('7')-vcdowncut('8','8')*s('8')-vcdowncut('8','9')*s('9')-vcdowncut('8','10')*s('10')-vcdowncut('8','11')*s('11')-vcdowncut('8','12')*s('12')-vcdowncut('8','13')*s('13')-vcdowncut('8','14')*s('14')-vcdowncut('8','15')*s('15')-vcdowncut('8','16')*s('16')-vcdowncut('8','17')*s('17')-vcdowncut('8','18')*s('18')-vcdowncut('8','19')*s('19')-vcdowncut('8','20')*s('20')-vcdowncut('8','21')*s('21')-vcdowncut('8','22')*s('22')-vcdowncut('8','23')*s('23')-vcdowncut('8','24')*s('24')-vcdowncut('8','25')*s('25')-vcdowncut('8','26')*s('26')-vcdowncut('8','27')*s('27')-vcdowncut('8','28')*s('28')-vcdowncut('8','29')*s('29')-vcdowncut('8','30')*s('30')-vcdowncut('8','31')*s('31')-vcdowncut('8','32')*s('32')-vcdowncut('8','33')*s('33')-vcdowncut('8','34')*s('34')-vcdowncut('8','35')*s('35')-vcdowncut('8','36')*s('36')-vcdowncut('8','37')*s('37')-vcdowncut('8','38')*s('38')-vcdowncut('8','39')*s('39')-vcdowncut('8','40')*s('40')-vcdowncut('8','41')*s('41')-vcdowncut('8','42')*s('42')-vcdowncut('8','43')*s('43')-vcdowncut('8','44')*s('44')-vcdowncut('8','45')*s('45')-vcdowncut('8','46')*s('46')-vcdowncut('8','47')*s('47')-vcdowncut('8','48')*s('48')-vcdowncut('8','49')*s('49')-vcdowncut('8','50')*s('50')-vcdowncut('8','51')*s('51')-vcdowncut('8','52')*s('52')-vcdowncut('8','53')*s('53')-vcdowncut('8','54')*s('54')-vcdowncut('8','55')*s('55')-vcdowncut('8','56')*s('56')-vcdowncut('8','57')*s('57')-vcdowncut('8','58')*s('58')-vcdowncut('8','59')*s('59')-vcdowncut('8','60')*s('60')-vcdowncut('8','61')*s('61')-vcdowncut('8','62')*s('62')-vcdowncut('8','63')*s('63')-vcdowncut('8','64')*s('64')-vcdowncut('8','65')*s('65')-vcdowncut('8','66')*s('66')-vcdowncut('8','67')*s('67')-vcdowncut('8','68')*s('68')-vcdowncut('8','69')*s('69')-vcdowncut('8','70')*s('70')-vcdowncut('8','71')*s('71')-vcdowncut('8','72')*s('72')-vcdowncut('8','73')*s('73')-vcdowncut('8','74')*s('74')+vcy('8','1')*s('75')+vcy('8','2')*s('76')+vcy('8','3')*s('77')+vcy('8','4')*s('78')+vcy('8','5')*s('79')+vcy('8','6')*s('80')+vcy('8','7')*s('81')+vcy('8','8')*s('82')+vcy('8','9')*s('83')+vcy('8','10')*s('84')+vcy('8','11')*s('85')+vcy('8','12')*s('86')+vcy('8','13')*s('87')+vcy('8','14')*s('88')+vcy('8','15')*s('89')+vcy('8','16')*s('90')-eqvcupstcut('8')*s('91');
equat83 ..    p2pf('83') =E= -vcdowncut('9','1')*s('1')-vcdowncut('9','2')*s('2')-vcdowncut('9','3')*s('3')-vcdowncut('9','4')*s('4')-vcdowncut('9','5')*s('5')-vcdowncut('9','6')*s('6')-vcdowncut('9','7')*s('7')-vcdowncut('9','8')*s('8')-vcdowncut('9','9')*s('9')-vcdowncut('9','10')*s('10')-vcdowncut('9','11')*s('11')-vcdowncut('9','12')*s('12')-vcdowncut('9','13')*s('13')-vcdowncut('9','14')*s('14')-vcdowncut('9','15')*s('15')-vcdowncut('9','16')*s('16')-vcdowncut('9','17')*s('17')-vcdowncut('9','18')*s('18')-vcdowncut('9','19')*s('19')-vcdowncut('9','20')*s('20')-vcdowncut('9','21')*s('21')-vcdowncut('9','22')*s('22')-vcdowncut('9','23')*s('23')-vcdowncut('9','24')*s('24')-vcdowncut('9','25')*s('25')-vcdowncut('9','26')*s('26')-vcdowncut('9','27')*s('27')-vcdowncut('9','28')*s('28')-vcdowncut('9','29')*s('29')-vcdowncut('9','30')*s('30')-vcdowncut('9','31')*s('31')-vcdowncut('9','32')*s('32')-vcdowncut('9','33')*s('33')-vcdowncut('9','34')*s('34')-vcdowncut('9','35')*s('35')-vcdowncut('9','36')*s('36')-vcdowncut('9','37')*s('37')-vcdowncut('9','38')*s('38')-vcdowncut('9','39')*s('39')-vcdowncut('9','40')*s('40')-vcdowncut('9','41')*s('41')-vcdowncut('9','42')*s('42')-vcdowncut('9','43')*s('43')-vcdowncut('9','44')*s('44')-vcdowncut('9','45')*s('45')-vcdowncut('9','46')*s('46')-vcdowncut('9','47')*s('47')-vcdowncut('9','48')*s('48')-vcdowncut('9','49')*s('49')-vcdowncut('9','50')*s('50')-vcdowncut('9','51')*s('51')-vcdowncut('9','52')*s('52')-vcdowncut('9','53')*s('53')-vcdowncut('9','54')*s('54')-vcdowncut('9','55')*s('55')-vcdowncut('9','56')*s('56')-vcdowncut('9','57')*s('57')-vcdowncut('9','58')*s('58')-vcdowncut('9','59')*s('59')-vcdowncut('9','60')*s('60')-vcdowncut('9','61')*s('61')-vcdowncut('9','62')*s('62')-vcdowncut('9','63')*s('63')-vcdowncut('9','64')*s('64')-vcdowncut('9','65')*s('65')-vcdowncut('9','66')*s('66')-vcdowncut('9','67')*s('67')-vcdowncut('9','68')*s('68')-vcdowncut('9','69')*s('69')-vcdowncut('9','70')*s('70')-vcdowncut('9','71')*s('71')-vcdowncut('9','72')*s('72')-vcdowncut('9','73')*s('73')-vcdowncut('9','74')*s('74')+vcy('9','1')*s('75')+vcy('9','2')*s('76')+vcy('9','3')*s('77')+vcy('9','4')*s('78')+vcy('9','5')*s('79')+vcy('9','6')*s('80')+vcy('9','7')*s('81')+vcy('9','8')*s('82')+vcy('9','9')*s('83')+vcy('9','10')*s('84')+vcy('9','11')*s('85')+vcy('9','12')*s('86')+vcy('9','13')*s('87')+vcy('9','14')*s('88')+vcy('9','15')*s('89')+vcy('9','16')*s('90')-eqvcupstcut('9')*s('91');
equat84 ..    p2pf('84') =E= -vcdowncut('10','1')*s('1')-vcdowncut('10','2')*s('2')-vcdowncut('10','3')*s('3')-vcdowncut('10','4')*s('4')-vcdowncut('10','5')*s('5')-vcdowncut('10','6')*s('6')-vcdowncut('10','7')*s('7')-vcdowncut('10','8')*s('8')-vcdowncut('10','9')*s('9')-vcdowncut('10','10')*s('10')-vcdowncut('10','11')*s('11')-vcdowncut('10','12')*s('12')-vcdowncut('10','13')*s('13')-vcdowncut('10','14')*s('14')-vcdowncut('10','15')*s('15')-vcdowncut('10','16')*s('16')-vcdowncut('10','17')*s('17')-vcdowncut('10','18')*s('18')-vcdowncut('10','19')*s('19')-vcdowncut('10','20')*s('20')-vcdowncut('10','21')*s('21')-vcdowncut('10','22')*s('22')-vcdowncut('10','23')*s('23')-vcdowncut('10','24')*s('24')-vcdowncut('10','25')*s('25')-vcdowncut('10','26')*s('26')-vcdowncut('10','27')*s('27')-vcdowncut('10','28')*s('28')-vcdowncut('10','29')*s('29')-vcdowncut('10','30')*s('30')-vcdowncut('10','31')*s('31')-vcdowncut('10','32')*s('32')-vcdowncut('10','33')*s('33')-vcdowncut('10','34')*s('34')-vcdowncut('10','35')*s('35')-vcdowncut('10','36')*s('36')-vcdowncut('10','37')*s('37')-vcdowncut('10','38')*s('38')-vcdowncut('10','39')*s('39')-vcdowncut('10','40')*s('40')-vcdowncut('10','41')*s('41')-vcdowncut('10','42')*s('42')-vcdowncut('10','43')*s('43')-vcdowncut('10','44')*s('44')-vcdowncut('10','45')*s('45')-vcdowncut('10','46')*s('46')-vcdowncut('10','47')*s('47')-vcdowncut('10','48')*s('48')-vcdowncut('10','49')*s('49')-vcdowncut('10','50')*s('50')-vcdowncut('10','51')*s('51')-vcdowncut('10','52')*s('52')-vcdowncut('10','53')*s('53')-vcdowncut('10','54')*s('54')-vcdowncut('10','55')*s('55')-vcdowncut('10','56')*s('56')-vcdowncut('10','57')*s('57')-vcdowncut('10','58')*s('58')-vcdowncut('10','59')*s('59')-vcdowncut('10','60')*s('60')-vcdowncut('10','61')*s('61')-vcdowncut('10','62')*s('62')-vcdowncut('10','63')*s('63')-vcdowncut('10','64')*s('64')-vcdowncut('10','65')*s('65')-vcdowncut('10','66')*s('66')-vcdowncut('10','67')*s('67')-vcdowncut('10','68')*s('68')-vcdowncut('10','69')*s('69')-vcdowncut('10','70')*s('70')-vcdowncut('10','71')*s('71')-vcdowncut('10','72')*s('72')-vcdowncut('10','73')*s('73')-vcdowncut('10','74')*s('74')+vcy('10','1')*s('75')+vcy('10','2')*s('76')+vcy('10','3')*s('77')+vcy('10','4')*s('78')+vcy('10','5')*s('79')+vcy('10','6')*s('80')+vcy('10','7')*s('81')+vcy('10','8')*s('82')+vcy('10','9')*s('83')+vcy('10','10')*s('84')+vcy('10','11')*s('85')+vcy('10','12')*s('86')+vcy('10','13')*s('87')+vcy('10','14')*s('88')+vcy('10','15')*s('89')+vcy('10','16')*s('90')-eqvcupstcut('10')*s('91');
equat85 ..    p2pf('85') =E= -vcdowncut('11','1')*s('1')-vcdowncut('11','2')*s('2')-vcdowncut('11','3')*s('3')-vcdowncut('11','4')*s('4')-vcdowncut('11','5')*s('5')-vcdowncut('11','6')*s('6')-vcdowncut('11','7')*s('7')-vcdowncut('11','8')*s('8')-vcdowncut('11','9')*s('9')-vcdowncut('11','10')*s('10')-vcdowncut('11','11')*s('11')-vcdowncut('11','12')*s('12')-vcdowncut('11','13')*s('13')-vcdowncut('11','14')*s('14')-vcdowncut('11','15')*s('15')-vcdowncut('11','16')*s('16')-vcdowncut('11','17')*s('17')-vcdowncut('11','18')*s('18')-vcdowncut('11','19')*s('19')-vcdowncut('11','20')*s('20')-vcdowncut('11','21')*s('21')-vcdowncut('11','22')*s('22')-vcdowncut('11','23')*s('23')-vcdowncut('11','24')*s('24')-vcdowncut('11','25')*s('25')-vcdowncut('11','26')*s('26')-vcdowncut('11','27')*s('27')-vcdowncut('11','28')*s('28')-vcdowncut('11','29')*s('29')-vcdowncut('11','30')*s('30')-vcdowncut('11','31')*s('31')-vcdowncut('11','32')*s('32')-vcdowncut('11','33')*s('33')-vcdowncut('11','34')*s('34')-vcdowncut('11','35')*s('35')-vcdowncut('11','36')*s('36')-vcdowncut('11','37')*s('37')-vcdowncut('11','38')*s('38')-vcdowncut('11','39')*s('39')-vcdowncut('11','40')*s('40')-vcdowncut('11','41')*s('41')-vcdowncut('11','42')*s('42')-vcdowncut('11','43')*s('43')-vcdowncut('11','44')*s('44')-vcdowncut('11','45')*s('45')-vcdowncut('11','46')*s('46')-vcdowncut('11','47')*s('47')-vcdowncut('11','48')*s('48')-vcdowncut('11','49')*s('49')-vcdowncut('11','50')*s('50')-vcdowncut('11','51')*s('51')-vcdowncut('11','52')*s('52')-vcdowncut('11','53')*s('53')-vcdowncut('11','54')*s('54')-vcdowncut('11','55')*s('55')-vcdowncut('11','56')*s('56')-vcdowncut('11','57')*s('57')-vcdowncut('11','58')*s('58')-vcdowncut('11','59')*s('59')-vcdowncut('11','60')*s('60')-vcdowncut('11','61')*s('61')-vcdowncut('11','62')*s('62')-vcdowncut('11','63')*s('63')-vcdowncut('11','64')*s('64')-vcdowncut('11','65')*s('65')-vcdowncut('11','66')*s('66')-vcdowncut('11','67')*s('67')-vcdowncut('11','68')*s('68')-vcdowncut('11','69')*s('69')-vcdowncut('11','70')*s('70')-vcdowncut('11','71')*s('71')-vcdowncut('11','72')*s('72')-vcdowncut('11','73')*s('73')-vcdowncut('11','74')*s('74')+vcy('11','1')*s('75')+vcy('11','2')*s('76')+vcy('11','3')*s('77')+vcy('11','4')*s('78')+vcy('11','5')*s('79')+vcy('11','6')*s('80')+vcy('11','7')*s('81')+vcy('11','8')*s('82')+vcy('11','9')*s('83')+vcy('11','10')*s('84')+vcy('11','11')*s('85')+vcy('11','12')*s('86')+vcy('11','13')*s('87')+vcy('11','14')*s('88')+vcy('11','15')*s('89')+vcy('11','16')*s('90')-eqvcupstcut('11')*s('91');
equat86 ..    p2pf('86') =E= -vcdowncut('12','1')*s('1')-vcdowncut('12','2')*s('2')-vcdowncut('12','3')*s('3')-vcdowncut('12','4')*s('4')-vcdowncut('12','5')*s('5')-vcdowncut('12','6')*s('6')-vcdowncut('12','7')*s('7')-vcdowncut('12','8')*s('8')-vcdowncut('12','9')*s('9')-vcdowncut('12','10')*s('10')-vcdowncut('12','11')*s('11')-vcdowncut('12','12')*s('12')-vcdowncut('12','13')*s('13')-vcdowncut('12','14')*s('14')-vcdowncut('12','15')*s('15')-vcdowncut('12','16')*s('16')-vcdowncut('12','17')*s('17')-vcdowncut('12','18')*s('18')-vcdowncut('12','19')*s('19')-vcdowncut('12','20')*s('20')-vcdowncut('12','21')*s('21')-vcdowncut('12','22')*s('22')-vcdowncut('12','23')*s('23')-vcdowncut('12','24')*s('24')-vcdowncut('12','25')*s('25')-vcdowncut('12','26')*s('26')-vcdowncut('12','27')*s('27')-vcdowncut('12','28')*s('28')-vcdowncut('12','29')*s('29')-vcdowncut('12','30')*s('30')-vcdowncut('12','31')*s('31')-vcdowncut('12','32')*s('32')-vcdowncut('12','33')*s('33')-vcdowncut('12','34')*s('34')-vcdowncut('12','35')*s('35')-vcdowncut('12','36')*s('36')-vcdowncut('12','37')*s('37')-vcdowncut('12','38')*s('38')-vcdowncut('12','39')*s('39')-vcdowncut('12','40')*s('40')-vcdowncut('12','41')*s('41')-vcdowncut('12','42')*s('42')-vcdowncut('12','43')*s('43')-vcdowncut('12','44')*s('44')-vcdowncut('12','45')*s('45')-vcdowncut('12','46')*s('46')-vcdowncut('12','47')*s('47')-vcdowncut('12','48')*s('48')-vcdowncut('12','49')*s('49')-vcdowncut('12','50')*s('50')-vcdowncut('12','51')*s('51')-vcdowncut('12','52')*s('52')-vcdowncut('12','53')*s('53')-vcdowncut('12','54')*s('54')-vcdowncut('12','55')*s('55')-vcdowncut('12','56')*s('56')-vcdowncut('12','57')*s('57')-vcdowncut('12','58')*s('58')-vcdowncut('12','59')*s('59')-vcdowncut('12','60')*s('60')-vcdowncut('12','61')*s('61')-vcdowncut('12','62')*s('62')-vcdowncut('12','63')*s('63')-vcdowncut('12','64')*s('64')-vcdowncut('12','65')*s('65')-vcdowncut('12','66')*s('66')-vcdowncut('12','67')*s('67')-vcdowncut('12','68')*s('68')-vcdowncut('12','69')*s('69')-vcdowncut('12','70')*s('70')-vcdowncut('12','71')*s('71')-vcdowncut('12','72')*s('72')-vcdowncut('12','73')*s('73')-vcdowncut('12','74')*s('74')+vcy('12','1')*s('75')+vcy('12','2')*s('76')+vcy('12','3')*s('77')+vcy('12','4')*s('78')+vcy('12','5')*s('79')+vcy('12','6')*s('80')+vcy('12','7')*s('81')+vcy('12','8')*s('82')+vcy('12','9')*s('83')+vcy('12','10')*s('84')+vcy('12','11')*s('85')+vcy('12','12')*s('86')+vcy('12','13')*s('87')+vcy('12','14')*s('88')+vcy('12','15')*s('89')+vcy('12','16')*s('90')-eqvcupstcut('12')*s('91');
equat87 ..    p2pf('87') =E= -vcdowncut('13','1')*s('1')-vcdowncut('13','2')*s('2')-vcdowncut('13','3')*s('3')-vcdowncut('13','4')*s('4')-vcdowncut('13','5')*s('5')-vcdowncut('13','6')*s('6')-vcdowncut('13','7')*s('7')-vcdowncut('13','8')*s('8')-vcdowncut('13','9')*s('9')-vcdowncut('13','10')*s('10')-vcdowncut('13','11')*s('11')-vcdowncut('13','12')*s('12')-vcdowncut('13','13')*s('13')-vcdowncut('13','14')*s('14')-vcdowncut('13','15')*s('15')-vcdowncut('13','16')*s('16')-vcdowncut('13','17')*s('17')-vcdowncut('13','18')*s('18')-vcdowncut('13','19')*s('19')-vcdowncut('13','20')*s('20')-vcdowncut('13','21')*s('21')-vcdowncut('13','22')*s('22')-vcdowncut('13','23')*s('23')-vcdowncut('13','24')*s('24')-vcdowncut('13','25')*s('25')-vcdowncut('13','26')*s('26')-vcdowncut('13','27')*s('27')-vcdowncut('13','28')*s('28')-vcdowncut('13','29')*s('29')-vcdowncut('13','30')*s('30')-vcdowncut('13','31')*s('31')-vcdowncut('13','32')*s('32')-vcdowncut('13','33')*s('33')-vcdowncut('13','34')*s('34')-vcdowncut('13','35')*s('35')-vcdowncut('13','36')*s('36')-vcdowncut('13','37')*s('37')-vcdowncut('13','38')*s('38')-vcdowncut('13','39')*s('39')-vcdowncut('13','40')*s('40')-vcdowncut('13','41')*s('41')-vcdowncut('13','42')*s('42')-vcdowncut('13','43')*s('43')-vcdowncut('13','44')*s('44')-vcdowncut('13','45')*s('45')-vcdowncut('13','46')*s('46')-vcdowncut('13','47')*s('47')-vcdowncut('13','48')*s('48')-vcdowncut('13','49')*s('49')-vcdowncut('13','50')*s('50')-vcdowncut('13','51')*s('51')-vcdowncut('13','52')*s('52')-vcdowncut('13','53')*s('53')-vcdowncut('13','54')*s('54')-vcdowncut('13','55')*s('55')-vcdowncut('13','56')*s('56')-vcdowncut('13','57')*s('57')-vcdowncut('13','58')*s('58')-vcdowncut('13','59')*s('59')-vcdowncut('13','60')*s('60')-vcdowncut('13','61')*s('61')-vcdowncut('13','62')*s('62')-vcdowncut('13','63')*s('63')-vcdowncut('13','64')*s('64')-vcdowncut('13','65')*s('65')-vcdowncut('13','66')*s('66')-vcdowncut('13','67')*s('67')-vcdowncut('13','68')*s('68')-vcdowncut('13','69')*s('69')-vcdowncut('13','70')*s('70')-vcdowncut('13','71')*s('71')-vcdowncut('13','72')*s('72')-vcdowncut('13','73')*s('73')-vcdowncut('13','74')*s('74')+vcy('13','1')*s('75')+vcy('13','2')*s('76')+vcy('13','3')*s('77')+vcy('13','4')*s('78')+vcy('13','5')*s('79')+vcy('13','6')*s('80')+vcy('13','7')*s('81')+vcy('13','8')*s('82')+vcy('13','9')*s('83')+vcy('13','10')*s('84')+vcy('13','11')*s('85')+vcy('13','12')*s('86')+vcy('13','13')*s('87')+vcy('13','14')*s('88')+vcy('13','15')*s('89')+vcy('13','16')*s('90')-eqvcupstcut('13')*s('91');
equat88 ..    p2pf('88') =E= -vcdowncut('14','1')*s('1')-vcdowncut('14','2')*s('2')-vcdowncut('14','3')*s('3')-vcdowncut('14','4')*s('4')-vcdowncut('14','5')*s('5')-vcdowncut('14','6')*s('6')-vcdowncut('14','7')*s('7')-vcdowncut('14','8')*s('8')-vcdowncut('14','9')*s('9')-vcdowncut('14','10')*s('10')-vcdowncut('14','11')*s('11')-vcdowncut('14','12')*s('12')-vcdowncut('14','13')*s('13')-vcdowncut('14','14')*s('14')-vcdowncut('14','15')*s('15')-vcdowncut('14','16')*s('16')-vcdowncut('14','17')*s('17')-vcdowncut('14','18')*s('18')-vcdowncut('14','19')*s('19')-vcdowncut('14','20')*s('20')-vcdowncut('14','21')*s('21')-vcdowncut('14','22')*s('22')-vcdowncut('14','23')*s('23')-vcdowncut('14','24')*s('24')-vcdowncut('14','25')*s('25')-vcdowncut('14','26')*s('26')-vcdowncut('14','27')*s('27')-vcdowncut('14','28')*s('28')-vcdowncut('14','29')*s('29')-vcdowncut('14','30')*s('30')-vcdowncut('14','31')*s('31')-vcdowncut('14','32')*s('32')-vcdowncut('14','33')*s('33')-vcdowncut('14','34')*s('34')-vcdowncut('14','35')*s('35')-vcdowncut('14','36')*s('36')-vcdowncut('14','37')*s('37')-vcdowncut('14','38')*s('38')-vcdowncut('14','39')*s('39')-vcdowncut('14','40')*s('40')-vcdowncut('14','41')*s('41')-vcdowncut('14','42')*s('42')-vcdowncut('14','43')*s('43')-vcdowncut('14','44')*s('44')-vcdowncut('14','45')*s('45')-vcdowncut('14','46')*s('46')-vcdowncut('14','47')*s('47')-vcdowncut('14','48')*s('48')-vcdowncut('14','49')*s('49')-vcdowncut('14','50')*s('50')-vcdowncut('14','51')*s('51')-vcdowncut('14','52')*s('52')-vcdowncut('14','53')*s('53')-vcdowncut('14','54')*s('54')-vcdowncut('14','55')*s('55')-vcdowncut('14','56')*s('56')-vcdowncut('14','57')*s('57')-vcdowncut('14','58')*s('58')-vcdowncut('14','59')*s('59')-vcdowncut('14','60')*s('60')-vcdowncut('14','61')*s('61')-vcdowncut('14','62')*s('62')-vcdowncut('14','63')*s('63')-vcdowncut('14','64')*s('64')-vcdowncut('14','65')*s('65')-vcdowncut('14','66')*s('66')-vcdowncut('14','67')*s('67')-vcdowncut('14','68')*s('68')-vcdowncut('14','69')*s('69')-vcdowncut('14','70')*s('70')-vcdowncut('14','71')*s('71')-vcdowncut('14','72')*s('72')-vcdowncut('14','73')*s('73')-vcdowncut('14','74')*s('74')+vcy('14','1')*s('75')+vcy('14','2')*s('76')+vcy('14','3')*s('77')+vcy('14','4')*s('78')+vcy('14','5')*s('79')+vcy('14','6')*s('80')+vcy('14','7')*s('81')+vcy('14','8')*s('82')+vcy('14','9')*s('83')+vcy('14','10')*s('84')+vcy('14','11')*s('85')+vcy('14','12')*s('86')+vcy('14','13')*s('87')+vcy('14','14')*s('88')+vcy('14','15')*s('89')+vcy('14','16')*s('90')-eqvcupstcut('14')*s('91');
equat89 ..    p2pf('89') =E= -vcdowncut('15','1')*s('1')-vcdowncut('15','2')*s('2')-vcdowncut('15','3')*s('3')-vcdowncut('15','4')*s('4')-vcdowncut('15','5')*s('5')-vcdowncut('15','6')*s('6')-vcdowncut('15','7')*s('7')-vcdowncut('15','8')*s('8')-vcdowncut('15','9')*s('9')-vcdowncut('15','10')*s('10')-vcdowncut('15','11')*s('11')-vcdowncut('15','12')*s('12')-vcdowncut('15','13')*s('13')-vcdowncut('15','14')*s('14')-vcdowncut('15','15')*s('15')-vcdowncut('15','16')*s('16')-vcdowncut('15','17')*s('17')-vcdowncut('15','18')*s('18')-vcdowncut('15','19')*s('19')-vcdowncut('15','20')*s('20')-vcdowncut('15','21')*s('21')-vcdowncut('15','22')*s('22')-vcdowncut('15','23')*s('23')-vcdowncut('15','24')*s('24')-vcdowncut('15','25')*s('25')-vcdowncut('15','26')*s('26')-vcdowncut('15','27')*s('27')-vcdowncut('15','28')*s('28')-vcdowncut('15','29')*s('29')-vcdowncut('15','30')*s('30')-vcdowncut('15','31')*s('31')-vcdowncut('15','32')*s('32')-vcdowncut('15','33')*s('33')-vcdowncut('15','34')*s('34')-vcdowncut('15','35')*s('35')-vcdowncut('15','36')*s('36')-vcdowncut('15','37')*s('37')-vcdowncut('15','38')*s('38')-vcdowncut('15','39')*s('39')-vcdowncut('15','40')*s('40')-vcdowncut('15','41')*s('41')-vcdowncut('15','42')*s('42')-vcdowncut('15','43')*s('43')-vcdowncut('15','44')*s('44')-vcdowncut('15','45')*s('45')-vcdowncut('15','46')*s('46')-vcdowncut('15','47')*s('47')-vcdowncut('15','48')*s('48')-vcdowncut('15','49')*s('49')-vcdowncut('15','50')*s('50')-vcdowncut('15','51')*s('51')-vcdowncut('15','52')*s('52')-vcdowncut('15','53')*s('53')-vcdowncut('15','54')*s('54')-vcdowncut('15','55')*s('55')-vcdowncut('15','56')*s('56')-vcdowncut('15','57')*s('57')-vcdowncut('15','58')*s('58')-vcdowncut('15','59')*s('59')-vcdowncut('15','60')*s('60')-vcdowncut('15','61')*s('61')-vcdowncut('15','62')*s('62')-vcdowncut('15','63')*s('63')-vcdowncut('15','64')*s('64')-vcdowncut('15','65')*s('65')-vcdowncut('15','66')*s('66')-vcdowncut('15','67')*s('67')-vcdowncut('15','68')*s('68')-vcdowncut('15','69')*s('69')-vcdowncut('15','70')*s('70')-vcdowncut('15','71')*s('71')-vcdowncut('15','72')*s('72')-vcdowncut('15','73')*s('73')-vcdowncut('15','74')*s('74')+vcy('15','1')*s('75')+vcy('15','2')*s('76')+vcy('15','3')*s('77')+vcy('15','4')*s('78')+vcy('15','5')*s('79')+vcy('15','6')*s('80')+vcy('15','7')*s('81')+vcy('15','8')*s('82')+vcy('15','9')*s('83')+vcy('15','10')*s('84')+vcy('15','11')*s('85')+vcy('15','12')*s('86')+vcy('15','13')*s('87')+vcy('15','14')*s('88')+vcy('15','15')*s('89')+vcy('15','16')*s('90')-eqvcupstcut('15')*s('91');
equat90 ..    p2pf('90') =E= -vcdowncut('16','1')*s('1')-vcdowncut('16','2')*s('2')-vcdowncut('16','3')*s('3')-vcdowncut('16','4')*s('4')-vcdowncut('16','5')*s('5')-vcdowncut('16','6')*s('6')-vcdowncut('16','7')*s('7')-vcdowncut('16','8')*s('8')-vcdowncut('16','9')*s('9')-vcdowncut('16','10')*s('10')-vcdowncut('16','11')*s('11')-vcdowncut('16','12')*s('12')-vcdowncut('16','13')*s('13')-vcdowncut('16','14')*s('14')-vcdowncut('16','15')*s('15')-vcdowncut('16','16')*s('16')-vcdowncut('16','17')*s('17')-vcdowncut('16','18')*s('18')-vcdowncut('16','19')*s('19')-vcdowncut('16','20')*s('20')-vcdowncut('16','21')*s('21')-vcdowncut('16','22')*s('22')-vcdowncut('16','23')*s('23')-vcdowncut('16','24')*s('24')-vcdowncut('16','25')*s('25')-vcdowncut('16','26')*s('26')-vcdowncut('16','27')*s('27')-vcdowncut('16','28')*s('28')-vcdowncut('16','29')*s('29')-vcdowncut('16','30')*s('30')-vcdowncut('16','31')*s('31')-vcdowncut('16','32')*s('32')-vcdowncut('16','33')*s('33')-vcdowncut('16','34')*s('34')-vcdowncut('16','35')*s('35')-vcdowncut('16','36')*s('36')-vcdowncut('16','37')*s('37')-vcdowncut('16','38')*s('38')-vcdowncut('16','39')*s('39')-vcdowncut('16','40')*s('40')-vcdowncut('16','41')*s('41')-vcdowncut('16','42')*s('42')-vcdowncut('16','43')*s('43')-vcdowncut('16','44')*s('44')-vcdowncut('16','45')*s('45')-vcdowncut('16','46')*s('46')-vcdowncut('16','47')*s('47')-vcdowncut('16','48')*s('48')-vcdowncut('16','49')*s('49')-vcdowncut('16','50')*s('50')-vcdowncut('16','51')*s('51')-vcdowncut('16','52')*s('52')-vcdowncut('16','53')*s('53')-vcdowncut('16','54')*s('54')-vcdowncut('16','55')*s('55')-vcdowncut('16','56')*s('56')-vcdowncut('16','57')*s('57')-vcdowncut('16','58')*s('58')-vcdowncut('16','59')*s('59')-vcdowncut('16','60')*s('60')-vcdowncut('16','61')*s('61')-vcdowncut('16','62')*s('62')-vcdowncut('16','63')*s('63')-vcdowncut('16','64')*s('64')-vcdowncut('16','65')*s('65')-vcdowncut('16','66')*s('66')-vcdowncut('16','67')*s('67')-vcdowncut('16','68')*s('68')-vcdowncut('16','69')*s('69')-vcdowncut('16','70')*s('70')-vcdowncut('16','71')*s('71')-vcdowncut('16','72')*s('72')-vcdowncut('16','73')*s('73')-vcdowncut('16','74')*s('74')+vcy('16','1')*s('75')+vcy('16','2')*s('76')+vcy('16','3')*s('77')+vcy('16','4')*s('78')+vcy('16','5')*s('79')+vcy('16','6')*s('80')+vcy('16','7')*s('81')+vcy('16','8')*s('82')+vcy('16','9')*s('83')+vcy('16','10')*s('84')+vcy('16','11')*s('85')+vcy('16','12')*s('86')+vcy('16','13')*s('87')+vcy('16','14')*s('88')+vcy('16','15')*s('89')+vcy('16','16')*s('90')-eqvcupstcut('16')*s('91');
equat91 ..    p2pf('91') =E= -eqecondowncut('1')*s('1')-eqecondowncut('2')*s('2')-eqecondowncut('3')*s('3')-eqecondowncut('4')*s('4')-eqecondowncut('5')*s('5')-eqecondowncut('6')*s('6')-eqecondowncut('7')*s('7')-eqecondowncut('8')*s('8')-eqecondowncut('9')*s('9')-eqecondowncut('10')*s('10')-eqecondowncut('11')*s('11')-eqecondowncut('12')*s('12')-eqecondowncut('13')*s('13')-eqecondowncut('14')*s('14')-eqecondowncut('15')*s('15')-eqecondowncut('16')*s('16')-eqecondowncut('17')*s('17')-eqecondowncut('18')*s('18')-eqecondowncut('19')*s('19')-eqecondowncut('20')*s('20')-eqecondowncut('21')*s('21')-eqecondowncut('22')*s('22')-eqecondowncut('23')*s('23')-eqecondowncut('24')*s('24')-eqecondowncut('25')*s('25')-eqecondowncut('26')*s('26')-eqecondowncut('27')*s('27')-eqecondowncut('28')*s('28')-eqecondowncut('29')*s('29')-eqecondowncut('30')*s('30')-eqecondowncut('31')*s('31')-eqecondowncut('32')*s('32')-eqecondowncut('33')*s('33')-eqecondowncut('34')*s('34')-eqecondowncut('35')*s('35')-eqecondowncut('36')*s('36')-eqecondowncut('37')*s('37')-eqecondowncut('38')*s('38')-eqecondowncut('39')*s('39')-eqecondowncut('40')*s('40')-eqecondowncut('41')*s('41')-eqecondowncut('42')*s('42')-eqecondowncut('43')*s('43')-eqecondowncut('44')*s('44')-eqecondowncut('45')*s('45')-eqecondowncut('46')*s('46')-eqecondowncut('47')*s('47')-eqecondowncut('48')*s('48')-eqecondowncut('49')*s('49')-eqecondowncut('50')*s('50')-eqecondowncut('51')*s('51')-eqecondowncut('52')*s('52')-eqecondowncut('53')*s('53')-eqecondowncut('54')*s('54')-eqecondowncut('55')*s('55')-eqecondowncut('56')*s('56')-eqecondowncut('57')*s('57')-eqecondowncut('58')*s('58')-eqecondowncut('59')*s('59')-eqecondowncut('60')*s('60')-eqecondowncut('61')*s('61')-eqecondowncut('62')*s('62')-eqecondowncut('63')*s('63')-eqecondowncut('64')*s('64')-eqecondowncut('65')*s('65')-eqecondowncut('66')*s('66')-eqecondowncut('67')*s('67')-eqecondowncut('68')*s('68')-eqecondowncut('69')*s('69')-eqecondowncut('70')*s('70')-eqecondowncut('71')*s('71')-eqecondowncut('72')*s('72')-eqecondowncut('73')*s('73')-eqecondowncut('74')*s('74')-eqvcdowncut('1')*s('75')-eqvcdowncut('2')*s('76')-eqvcdowncut('3')*s('77')-eqvcdowncut('4')*s('78')-eqvcdowncut('5')*s('79')-eqvcdowncut('6')*s('80')-eqvcdowncut('7')*s('81')-eqvcdowncut('8')*s('82')-eqvcdowncut('9')*s('83')-eqvcdowncut('10')*s('84')-eqvcdowncut('11')*s('85')-eqvcdowncut('12')*s('86')-eqvcdowncut('13')*s('87')-eqvcdowncut('14')*s('88')-eqvcdowncut('15')*s('89')-eqvcdowncut('16')*s('90')+eqy*s('91');

EQUATIONS
CO2,CO3,gra,envgra,equip25,cost,NPV1,NPV2,NPV3;


variables
Z,Z2,valuechainvar,equipmentvar,price,equipcost,cashflow,NPV,PV;


equip25.. equipcost =E= (((Heat('HX11')+10)/(0.0644*164460))**0.68)*121576*2.1 + (((Heat('HX10')+10)/(0.0644*164460))**0.68)*121576*2.1 + (((Heat('HX8')+10)/(0.0644*164460))**0.68)*121576*2.1 + (((Heat('HX7')+100)/(0.0644*164460))**0.68)*121576*2.1 + (((Heat('HX6')+10)/(0.0644*164460))**0.68)*121576*2.1 + (((Q('HX1')+10)/(0.0644*164460))**0.68)*121576*2.1 + (((Q('HX4')*Q('HX4'))/(0.00414*8223))**0.34)*121576*2.1 + (((sum(J,fc(J,'Wash1','Grind1'))*86400*0.264)/50000)**0.51)*50000*2.8+ (((sum(J,fc(J,'Wash1','Grind1'))*3600)/28000)**0.6)*302000*1.38 + (((sum(J,fc(J,'Spl2','Mix6'))*60*0.264)/340)**0.48)*1900*2.8 + (((sum(J,fc(J,'Spl2','Mix5'))*60*0.264)/340)**0.48)*1900*2.8  +  (((sum(J,fc(J,'Spl2','Mix4'))*60*0.264)/340)**0.48)*1900*2.8+(((sum(J,fc(J,'Grind1','Mix2'))*60*0.264)/340)**0.48)*1900*2.8 + (((sum(J,fc(J,'HX1','Premix1'))*900*0.264)/24770)**0.71)*44800*1.2 + (((sum(J,fc(J,'Jet1','Col1'))*600*0.264)/14500)**0.93)*64400*1.2 + (((sum(J,fc(J,'Col1','Liq1'))*900*0.264)/24770)**0.71)*44800*1.2 + (((sum(J,fc(J,'Col1','Liq1'))*900*0.264)/24770)**0.71)*44800*1.2 + 3000000 + (((sum(J,fc(J,'HX3','Mix3'))*60*0.264)/340)**0.48)*1900*2.8 + 5363376+ 2406460 + 2530345 ;





cost.. price =E= ethanol*0.33481*1.4+ddgs*0.075-(0.83352*energy_objective*0.000003876 + 0.094*energy_objective*0.00000112 + 0.07248*energy_objective*0.00001327 + fc('Prot','Src6','Sac1')*2.75 + fc('Prot','Src5','Liq1')*2.75 + 0.004977*5.5 + fc('Urea','Src7','Mix3')*0.11 + 0.0747996158*F_Src9_HX6 + 0.00000528*water_objective+18*(2.05/25.4)+ethanol*0.3348*(0.1033 + equipcost*0.1/(60000000*20) + equipcost*0.0825*0.040/60000000));

NPV1.. cashflow =E= price*86400*360;
NPV2.. PV =E= ((cashflow)/0.07)*(1 - (1/((1.07)**20)));
NPV3.. NPV =E= (PV - equipcost)/20;




*P2P MODEL
CO3.. Z2 =E= econenvintstar('1')*s('1')+econenvintstar('2')*s('2')+econenvintstar('3')*s('3')+econenvintstar('4')*s('4')+econenvintstar('5')*s('5')+econenvintstar('6')*s('6')+econenvintstar('7')*s('7')+econenvintstar('8')*s('8')+econenvintstar('9')*s('9')+econenvintstar('10')*s('10')+econenvintstar('11')*s('11')+econenvintstar('12')*s('12')+econenvintstar('13')*s('13')+econenvintstar('14')*s('14')+econenvintstar('15')*s('15')+econenvintstar('16')*s('16')+econenvintstar('17')*s('17')+econenvintstar('18')*s('18')+econenvintstar('19')*s('19')+econenvintstar('20')*s('20')+econenvintstar('21')*s('21')+econenvintstar('22')*s('22')+econenvintstar('23')*s('23')+econenvintstar('24')*s('24')+econenvintstar('25')*s('25')+econenvintstar('26')*s('26')+econenvintstar('27')*s('27')+econenvintstar('28')*s('28')+econenvintstar('29')*s('29')+econenvintstar('30')*s('30')+econenvintstar('31')*s('31')+econenvintstar('32')*s('32')+econenvintstar('33')*s('33')+econenvintstar('34')*s('34')+econenvintstar('35')*s('35')+econenvintstar('36')*s('36')+econenvintstar('37')*s('37')+econenvintstar('38')*s('38')+econenvintstar('39')*s('39')+econenvintstar('40')*s('40')+econenvintstar('41')*s('41')+econenvintstar('42')*s('42')+econenvintstar('43')*s('43')+econenvintstar('44')*s('44')+econenvintstar('45')*s('45')+econenvintstar('46')*s('46')+econenvintstar('47')*s('47')+econenvintstar('48')*s('48')+econenvintstar('49')*s('49')+econenvintstar('50')*s('50')+econenvintstar('51')*s('51')+econenvintstar('52')*s('52')+econenvintstar('53')*s('53')+econenvintstar('54')*s('54')+econenvintstar('55')*s('55')+econenvintstar('56')*s('56')+econenvintstar('57')*s('57')+econenvintstar('58')*s('58')+econenvintstar('59')*s('59')+econenvintstar('60')*s('60')+econenvintstar('61')*s('61')+econenvintstar('62')*s('62')+econenvintstar('63')*s('63')+econenvintstar('64')*s('64')+econenvintstar('65')*s('65')+econenvintstar('66')*s('66')+econenvintstar('67')*s('67')+econenvintstar('68')*s('68')+econenvintstar('69')*s('69')+econenvintstar('70')*s('70')+econenvintstar('71')*s('71')+econenvintstar('72')*s('72')+econenvintstar('73')*s('73')+econenvintstar('74')*s('74')+vcenvint('1')*s('75')+vcenvint('2')*s('76')+vcenvint('3')*s('77')+vcenvint('4')*s('78')+vcenvint('5')*s('79')+vcenvint('6')*s('80')+vcenvint('7')*s('81')+vcenvint('8')*s('82')+vcenvint('9')*s('83')+vcenvint('10')*s('84')+vcenvint('11')*s('85')+vcenvint('12')*s('86')+vcenvint('13')*s('87')+vcenvint('14')*s('88')+vcenvint('15')*s('89')+vcenvint('16')*s('90')+eqenvint*s('91');
gra.. valuechainvar =E=  vcenvint('1')*s('75')+vcenvint('2')*s('76')+vcenvint('3')*s('77')+vcenvint('4')*s('78')+vcenvint('5')*s('79')+vcenvint('6')*s('80')+vcenvint('7')*s('81')+vcenvint('8')*s('82')+vcenvint('9')*s('83')+vcenvint('10')*s('84')+vcenvint('11')*s('85')+vcenvint('12')*s('86')+vcenvint('13')*s('87')+vcenvint('14')*s('88')+vcenvint('15')*s('89')+vcenvint('16')*s('90');
envgra.. equipmentvar =E= eqenvint*s('91');
*CONVENTIONAL MODEL
CO2.. Z =e= vcenvint('1')*s('75')+vcenvint('2')*s('76')+vcenvint('3')*s('77')+vcenvint('4')*s('78')+vcenvint('5')*s('79')+vcenvint('6')*s('80')+vcenvint('7')*s('81')+vcenvint('8')*s('82')+vcenvint('9')*s('83')+vcenvint('10')*s('84')+vcenvint('11')*s('85')+vcenvint('12')*s('86')+vcenvint('13')*s('87')+vcenvint('14')*s('88')+vcenvint('15')*s('89')+vcenvint('16')*s('90')+eqenvint*s('91');


set

          count    counter

          /1*51/ ;


parameter lim(count)

/1      9.4664
2       9.49725
3       9.5281
4       9.55895
5       9.5898
6       9.62065
7       9.6515
8       9.68235
9       9.7132
10      9.74405
11      9.7749
12      9.80575
13      9.8366
14      9.86745
15      9.8983
16      9.92915
17      9.96
18      9.99085
19      10.0217
20      10.05255
21      10.0834
22      10.11425
23      10.1451
24      10.17595
25      10.2068
26      10.23765
27      10.2685
28      10.29935
29      10.3302
30      10.36105
31      10.3919
32      10.42275
33      10.4536
34      10.48445
35      10.5153
36      10.54615
37      10.577
38      10.60785
39      10.6387
40      10.66955
41      10.7004
42      10.73125
43      10.7621
44      10.79295
45      10.8238
46      10.85465
47      10.8855
48      10.91635
49      10.9472
50      10.97805
51      11.0089/ ;
parameter data(count);
parameter data2(count);

MODEL TRANS /ALL/ ;
TRANS.iterlim = para;

TRANS.OptFile = 1

option NLP = CONOPT;

*Solve TRANS Using NLP Maximizing NPV;
*Solve TRANS Using NLP Minimizing Z2;

*Solve TRANS Using NLP Maximizing NPV;


Loop(count,
Z2.up = lim(count);
Solve TRANS Using NLP Maximizing NPV;
data(count) = split_MecP1.L;
data2(count) = Split2Mix5.L;
);










Execute_Unload "var1.gdx",data;
Execute_Unload "var2.gdx",data2;


