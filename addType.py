'''
Created on 04/ott/2013

@author: Cento
'''

import json, sqlite3

con = sqlite3.connect('press.sqlite')

cur = con.cursor()

with open('ent.json','r') as infile:
    ent = json.load(infile)
    
    
for e in ent:
    
    cur.execute("SELECT type from entities where name=\""+e['n']+"\"")
    
    res=cur.fetchone()
    
    e['t']=res[0]+1

with open('entities.json','w') as outfile:
    json.dump(ent,outfile) 
    
    