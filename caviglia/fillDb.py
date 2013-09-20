'''
Created on Sep 20, 2013

@author: daniele
'''


import sqlite3,json

with open('corriere_linkati.json') as infile:
    data=json.load(infile);
    
    
con = sqlite3.connect('press.sqlite')

with con:
    
    cur = con.cursor()
#print data.keys()
    for a in iter(data):
        year=a.split('-')[0]
        month=a.split('-')[1]
        
        for c in data[a]:

            source=c['source'].strip("\"")
            target=c['target'].strip("\"")
            value=c['value']
            print c
            
            b='INSERT INTO lnks VALUES('+str(month)+','+str(year)+','+str(source)+','+str(target)+','+str(value)+')';
            print b
            cur.execute('INSERT INTO links VALUES('+str(month)+','+str(year)+',\"'+str(source)+'\",\"'+str(target)+'\",'+str(value)+')')
        