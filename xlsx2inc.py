import pandas as pd
import sys
# filename.xlsx sheetname 1stRowIDinGAMS 1stColIDinGAMS
name=sys.argv[2];
xlsx = pd.read_excel('./'+sys.argv[1],sheet_name=sys.argv[2])
xlsx=xlsx.fillna(0);
print(xlsx)
x1=2;
y1=2;
x2=int(sys.argv[3]);
y2=int(sys.argv[4]);


fillin="";
count=0;
for i in range(x1-1,len(xlsx.iloc[:,0])):
    for j in range(y1-1,len(xlsx.iloc[0,:])):
        if count==0:
            fillin+=""+name+"(\'"+str(i-x1+1+x2)+"\',\'"+str(j-y1+1+y2)+"\')="+str(round(xlsx.iloc[i,j],4))+";";
        else:
            fillin+="\n"+name+"(\'"+str(i-x1+1+x2)+"\',\'"+str(j-y1+1+y2)+"\')="+str(round(xlsx.iloc[i,j],4))+";";
        count=count+1;

#print(fillin)


with open('./'+name+'.inc','w') as outfile:
   outfile.write(fillin)
