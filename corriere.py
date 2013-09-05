import requests,re
from bs4 import BeautifulSoup



def corriereScrape(query, mode, start, end):
    baseurl='http://sitesearch.corriere.it/archivioStoricoEngine?q='+query
    
    s=start.split("-");
    e=end.split("-");


    payload={
        "queryString":query,
        "queryMode":"phrase",
        "autore":"",
        "fromDay":s[2],
        "fromMonth":s[1],
        "fromYear":s[0],
        "toDay":e[2],
        "toMonth":e[1],
        "toYear":e[0],
        "orderBy":"data",
        "Ricerca":"Cerca",
        "__checkbox_sectionCorriere":"true",
        "__checkbox_sectionLavoro":"true",
        "__checkbox_sectionEconomia":"true",
        "__checkbox_sectionSalute":"true",
        "__checkbox_sectionSoldi":"true",
        "__checkbox_sectionViviMilano":"true"
    }
    
    headers={
         "Host":"sitesearch.corriere.it",
         "Referer":"http://sitesearch.corriere.it/archivioStoricoEngine",
         "User-Agent":"Mozilla/5.0 (Macintosh; Intel Mac OS X 10.7; rv:19.0) Gecko/20100101 Firefox/19.0"
             }
    
    r = requests.post(baseurl, params=payload)
    
    soup = BeautifulSoup(r.text)
    
    g=soup.find_all("div",id="sbcolleft")[0]
    
    rawpeople=g.find_all(href=re.compile("addPerson"))
    rawplaces=g.find_all(href=re.compile("addLocation"))
    rawcompanies=g.find_all(href=re.compile("addCompany"))
    
    
    
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
    
    
    print "done"
            
    return {
        'start':start,
        'end':end,
        'people':people,
        'companies':companies,
        'locations':places
        }