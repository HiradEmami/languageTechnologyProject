import numpy as np
from math import *

a = [ i**2%5 for i in range(1,101) if i]
print(len(a))

print(ceil(0.1*len(a)))
print(round(0.9*len(a)))
v= np.array_split(a,3)
print(v)
print(v[1])
print(len(v))


def merge(argChunks):
    list = argChunks[0]
    for i in range(1,len(argChunks)):
        print(i)
        list += argChunks[i]
    return list

list=merge(v)
print(list)