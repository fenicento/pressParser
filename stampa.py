import requests,re
from bs4 import BeautifulSoup

baseurl='http://www.archiviolastampa.it/'

def stampaScrape(query, mode, start, end):
    
    s_tmp=start.split("-")
    start=s_tmp[2]+"."+s_tmp[1]+"."+s_tmp[0]
   
    
    e_tmp=end.split("-")
    end=e_tmp[2]+"."+e_tmp[1]+"."+e_tmp[0]
    
    
    print start+" - "+end
    
    headers = {
               "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/27.0.1453.116 Safari/537.36"
               }
    
    payload = {
               'keywords':query,
               'old_keywords':query,
               'free_search_query-type':"q_f",
               'free_search_add_entity_author':"",
               'free_search_add_entity_person':"",
               'free_search_add_entity_place':"",
               'free_search_add_entity_organization':"",
               'datePickerFrom':start,
               'datePickerTo':end,
               'datePickerFixed':"",
               'date_radio':"date_on",
               'q_h':"",
               'q_l':"all",
               'q_fp':"",
               'q_o':"date+asc",
               'free_search_add_entity_authors':"",
               'free_search_add_entity_persons':"",
               'free_search_add_entity_places':"",
               'free_search_add_entity_organizations':"",
               'free_search_add_entity_authors_old':"",
               'free_search_add_entity_persons_old':"",
               'free_search_add_entity_places_old':"",
               'free_search_add_entity_organizations_old':"",
               'option':"com_lastampa",
               'task':"search",
               'mod':"libera",
               'Itemid':3,
               'q_dt':"",
               'q_df':"",
               't':"e67d19bcaf823f2d2c8aae03bfcacc2c",
               }
    
    cookies={
             "6c682c64700ab4f1b92c124127278451":"6c109c5bd62bbc3eea2a11e773b5ce92",
             "JSESSIONID":"CE372493AD37E6D120E78F7783E50F96.instance139",
             "PHPSESSID":"eeat6pgkori8gdv1e57t5kmnj1",
             "__utma":"66456574.1583479959.1372245497.1372251476.1372255996.4",
             "__utmb":"66456574.8.10.1372255996",
             "__utmc":"66456574",
             "__utmz":"66456574.1372255996.4.3.utmcsr=lastampa.it|utmccn=(referral)|utmcmd=referral|utmcct=/archivio-storico/",
             "mosvisitor":"1"
             }
    
    
    r = requests.post(baseurl, params=payload, headers=headers, timeout=2)
    
    soup = BeautifulSoup(r.text)
    
    g=soup.find_all("div",id="left_sidebar")[0]
    
    rawpeople=g.find_all(href=re.compile("filter_p"))
    rawplaces=g.find_all(href=re.compile("filter_g"))
    rawcompanies=g.find_all(href=re.compile("filter_o"))
    
    
    
    people=[]
    companies=[]
    places=[]
    
    for x in rawpeople:
        print x
        p=x.get_text().split("(")
        people.append({
                       'name':p[0],
                       'count':p[1].split(")")[0]
        })
        
    for x in rawcompanies:
        print x
        p=x.get_text().split("(")
        companies.append({
                       'name':p[0],
                       'count':p[1].split(")")[0]
        })
        
    for x in rawplaces:
        print x
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

    # rawpeople= soup.find_all(href=re.compile("filter_people"))
    # rawcompanies= soup.find_all(href=re.compile("filter_companies"))
    # rawplaces= soup.find_all(href=re.compile("filter_locations"))
#     
    # people=[]
    # companies=[]
    # places=[]
#     
    # for x in rawpeople:
        # p=x.get_text().split("(")
        # people.append({
                       # 'name':p[0],
                       # 'count':p[1].split(")")[0]
        # })
#         
    # for x in rawcompanies:
        # p=x.get_text().split("(")
        # companies.append({
                       # 'name':p[0],
                       # 'count':p[1].split(")")[0]
        # })
#         
    # for x in rawplaces:
        # p=x.get_text().split("(")
        # places.append({
                       # 'name':p[0],
                       # 'count':p[1].split(")")[0]
        # })
#     
    # return {
            # 'start':start,
            # 'end':end,
            # 'people':people,
            # 'companies':companies,
            # 'locations':places
            # }
        