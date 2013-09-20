'''
Created on Sep 20, 2013

@author: davide
'''

import sqlite3,json

with open('repubblica.json') as infile:
    data=json.load(infile);
    
    
con = sqlite3.connect('press.sqlite')

with con:
    cur = con.cursor()
    
    for a in iter(data):
        print a
        for b in data[a]['entities']['companies']:
            
            cur.execute('INSERT OR IGNORE INTO entities VALUES(\"'+str(b).strip("\"")+'\",'+str(0)+')')
        for b in data[a]['entities']['people']:
            cur.execute('INSERT OR IGNORE INTO entities VALUES(\"'+str(b).strip("\"")+'\",'+str(1)+')')
        for b in data[a]['entities']['places']:
            cur.execute('INSERT OR IGNORE INTO entities VALUES(\"'+str(b).strip("\"")+'\",'+str(2)+')')
    