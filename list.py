a=str('10,20,30,40,50,60,70,80,90,100')
l=list(a)
print("\033c\033[43;30m\n\n")
ll=[]
s=""
for n in l:
    if n.strip()==",":
        ll=ll+[int(s)]
        s=""
    else:
        s=s+n
ll=ll+[int(s)]
     

print(ll)