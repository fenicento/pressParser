import json, re
import sqlite3 as lite

con = lite.connect('press.sqlite')

cur = con.cursor()
cur.execute('SELECT x.f1,Count(x.f1) FROM (SELECT source As F1 FROM links  UNION ALL SELECT target As F1 FROM links ) x GROUP BY x.f1 ORDER BY Count(x.f1) DESC')

rows = cur.fetchall()
lst = [x[0] for x in rows if x[1]>3] 
print lst

res=list() 

for i in lst:
	
	cur.execute('SELECT DISTINCT year,month from links where source=\''+i+'\' OR target=\''+i+'\'')
	rows=cur.fetchall()
	for r in rows:
		print(i,r)
	



