print("\033c\033[43;30m\ngive me file ? \n")
a=input()
f1=open(a,"r")
b=f1.read()
f1.close()
c=b.split("\n")
d=len(c)
l=[]
m=""
for e in range(d):
    s=c[d-1-e]
    m=m+"\n"+s

f1=open(a+".inv","w")
f1.write(m)
f1.close()