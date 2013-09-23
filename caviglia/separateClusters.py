'''
Created on Sep 20, 2013

@author: davide
'''

import sqlite3,json
from datetime import timedelta,date
from time import strftime
from sets import Set

conn = sqlite3.connect('press.sqlite')
print "Opened database successfully";

def merge(lsts):
  sets = [set(lst) for lst in lsts if lst]
  merged = 1
  while merged:
    merged = 0
    results = []
    while sets:
      common, rest = sets[0], sets[1:]
      sets = []
      for x in rest:
        if x.isdisjoint(common):
          sets.append(x)
        else:
          merged = 1
          common |= x
      results.append(common)
    sets = results
  return sets
  
# cursor = conn.execute("SELECT * from links")
# for row in cursor:
   # print "ID = ", row[0]
   # print "NAME = ", row[1]
   # print "ADDRESS = ", row[2]
   # print "SALARY = ", row[3], "\n"
   
def daterange(start_date, end_date):
    for n in range(int ((end_date - start_date).days)):
        yield start_date + timedelta(n)

start = date(1992,1,1)
end = date(2013,9,1)
a=set()
for single_date in daterange(start, end):
    a.add(strftime("%Y-%m", single_date.timetuple()))
    

biglist=list()
count=0

for i in a:
    count=count+1
    
    sp=i.split("-")
    y= sp[0]
    m= int(sp[1])
    
    cursor = conn.execute("SELECT rowid,value,source,target from links where year=\""+y+"\" AND month=\""+str(m)+"\"")
    clusters=list()
    for row in cursor:
        
        found = False
        for s in clusters:
            if row[2].lower() in s or row[3].lower() in s:
                s.add(row[2].lower())
                s.add(row[3].lower())
                
                found=True
                
        if not found:
    
            c=Set([row[2].lower(),row[3].lower()])
           
            clusters.append(c)
            
            #conn.execute('update links set cluster=\"'+str(clusters.index(c))+'\" WHERE year=\"'+y+'\" AND month=\"'+str(m)+'\" AND source=\"'+row[2]+'\" AND target =\"'+row[3]+'\"')
            
    biglist.append(merge(clusters))
    


finlist=dict()
print len(biglist)

count=0 
for i in a:
    sp=i.split("-")
    y= sp[0]
    m= int(sp[1])
    
    cursor = conn.execute("SELECT rowid,source,target from links where year=\""+y+"\" AND month=\""+str(m)+"\"")
    currsets=biglist[count]
    print y, str(m)
    for row in cursor:
        print row[0]
        found = False
        for s in currsets:
            if row[1].lower() in s or row[2].lower() in s:
                finlist[row[0]]=currsets.index(s)
                found = True
                break
        if not found:
            print "not found!"
                
    count=count+1

print len(finlist)
               
for k in finlist.iteritems():
    
    conn.execute('update links set cluster=\"'+str(k[1])+'\" WHERE rowid=\"'+str(k[0])+'\"')                 
    conn.commit()          
    print "committed" + str(k[0])
    
    

                
   
   
