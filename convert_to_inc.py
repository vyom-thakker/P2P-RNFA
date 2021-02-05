import pandas as pd
import numpy as np
from sys import *
import os


X=pd.read_csv("X.csv",skiprows=[0],header=None);

incfile="";

for i in range(5):
    for j in range(6):
        incfile+="X1('"+str(X.iloc[6*i+j,0])+"','"+str(X.iloc[6*i+j,1])+"')="+str(round(X.iloc[6*i+j,2],4))+";\n";

file1=open("X1.inc","a+");
file1.write(incfile);
file1.close();

B=pd.read_csv("B.csv",skiprows=[0],header=None);

incfile="";

for i in range(2):
    for j in range(6):
        incfile+="B1('"+str(B.iloc[6*i+j,0])+"','"+str(X.iloc[6*i+j,1])+"')="+str(round(B.iloc[6*i+j,2],4))+";\n";

file1=open("B1.inc","a+");
file1.write(incfile);
file1.close();
