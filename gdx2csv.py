import pandas as pd
xlsx = pd.read_excel('./indata.xlsx', sheetname=0, index=0)
print(xlsx)

fillin="";

for i in range(1,len(xlsx.iloc[:,0])):
    for j in range(2,len(xlsx.iloc[0,:])):
        fillin+="\nrnfa(\'"+str(i+450)+"\',\'"+str(j-1+450)+"\')="+str(round(xlsx.iloc[i,j],4))+";";
        #fillin+="\nrnfa(\'"+str(int((xlsx.iloc[i,1])[1:])+450)+"\',\'"+str(int(list(xlsx.columns)[j][1:])+450)+"\')="+str(round(xlsx.iloc[i,j],4))+";";

print(fillin)


with open('./indata.inc','w') as outfile:
   outfile.write(fillin)
