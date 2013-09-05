from repubblica import repubblicaScrape
from stampa import stampaScrape
from corriere import corriereScrape
import datetime
import time
from calendar import monthrange
import json

#query string
string='politecnico di milano'


res=dict()

res['query']=string
res['results']=[]

#set dates interval
dt1 = datetime.date(1992, 1, 1)
dt2 = datetime.date(2013, 6, 27)


start_month=dt1.month
end_months=(dt2.year-dt1.year)*12 + dt2.month+1
dates=[datetime.datetime(year=yr, month=mn, day=1) for (yr, mn) in (
          ((m - 1) / 12 + dt1.year, (m - 1) % 12 + 1) for m in range(start_month, end_months)
      )]



for d in dates:
    s=d.strftime("%Y-%m-%d")
    last=monthrange(d.year,d.month)[1]
    e=str(d.year)+"-"+str(d.month).zfill(2)+"-"+str(last).zfill(2)
    
    while True:
        try:
            x= corriereScrape(string,'all',s,e)
            res['results'].append(x)
        except:
            print  "timed out, retrying in 5 seconds"
            time.sleep(5)
            continue
        break
    
      
   
    
with open('corriere_polimi_1992_2013.json', 'w') as outfile:
    json.dump(res, outfile,indent=4)
    


