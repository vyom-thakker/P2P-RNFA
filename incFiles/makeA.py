import pandas as pd
import sys
import numpy as np
# filename.xlsx sheetname 1stRowIDinGAMS 1stColIDinGAMS
name="A";
xlsxA = pd.read_excel('./'+sys.argv[1],sheet_name=sys.argv[2],skiprows=[0],usecols="B:NV",header=None);
xlsxB = pd.read_excel('./'+sys.argv[1],sheet_name=sys.argv[3],skiprows=[0],usecols="B:NV",header=None);
xlsxA=xlsxA.fillna(0);
xlsxB=xlsxB.fillna(0);
x1=1;
y1=2;
x2=int(sys.argv[4]);
y2=int(sys.argv[5]);

xlsxB_inv= pd.DataFrame(np.linalg.pinv(xlsxB.T.values), xlsxB.T.index)
A=xlsxA.dot(xlsxB_inv);
fillin="";
count=0;
for i in range(x1-1,len(A.iloc[:,0])):
    for j in range(y1-1,len(A.iloc[0,:])):
        if count==0:
            fillin+=""+name+"(\'"+str(i-x1+1+x2)+"\',\'"+str(j-y1+1+y2)+"\')="+str(round(A.iloc[i,j],4))+";";
        else:
            fillin+="\n"+name+"(\'"+str(i-x1+1+x2)+"\',\'"+str(j-y1+1+y2)+"\')="+str(round(A.iloc[i,j],4))+";";
        count=count+1;

#print(fillin)


with open('./'+name+'.inc','w') as outfile:
   outfile.write(fillin)
