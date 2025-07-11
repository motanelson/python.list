a=str('1 2 3 4 5 6 7 8 9 0')
l=list(a)
print("\033c\033[43;30m\n\n")
ll=[]
for n in l:
    if n.strip()!="":
        ll=ll+[n.strip()]
for n in ll:
    print(n)