import requests,re
from bs4 import BeautifulSoup

baseurl='http://ricerca.repubblica.it/ricerca/repubblica'

def repubblicaScrape(query, mode, start, end):
    
    payload = {'query': query, 'mode': mode, 'fromdate':start, 'todate': end,'sortby':'ddate','view':'repubblica'}
    
    r = requests.get(baseurl, params=payload)
    
    print r.url
    
    soup = BeautifulSoup(r.text)
    
    rawpeople= soup.find_all(href=re.compile("filter_people"))
    rawcompanies= soup.find_all(href=re.compile("filter_companies"))
    rawplaces= soup.find_all(href=re.compile("filter_locations"))
    
    people=[]
    
    companies=[]
    places=[]
    
    for x in rawpeople:
        p=x.get_text().split("(")
        people.append({
                       'name':p[0],
                       'count':p[1].split(")")[0]
        })
        
    for x in rawcompanies:
        p=x.get_text().split("(")
        companies.append({
                       'name':p[0],
                       'count':p[1].split(")")[0]
        })
        
    for x in rawplaces:
        p=x.get_text().split("(")
        places.append({
                       'name':p[0],
                       'count':p[1].split(")")[0]
        })
    
    return {
            'start':start,
            'end':end,
            'people':people,
            'companies':companies,
            'locations':places
            }
        