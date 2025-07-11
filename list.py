a=str('hello world,hi,there....')
l=list(a)
print("\033c\033[43;30m\n\n")
ll=[]
s=""
for n in l:
    if n==",":
        ll=ll+[str(s)]
        s=""
    else:
        s=s+n
ll=ll+[str(s)]
     

print(ll)