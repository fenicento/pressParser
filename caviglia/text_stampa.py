import requests,re
from bs4 import BeautifulSoup
import json
from calendar import monthrange
import datetime
import time
from collections import Counter

objects = []

def stampaScrape(query, start, end):
    baseurl='http://www.archiviolastampa.it/'

    s_tmp=start.split("-")
    start=s_tmp[2]+"."+s_tmp[1]+"."+s_tmp[0]
   
    e_tmp=end.split("-")
    end=e_tmp[2]+"."+e_tmp[1]+"."+e_tmp[0]

    headers = {
        "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/27.0.1453.116 Safari/537.36"
    }

    payload = {
               'keywords' : query,
               'old_keywords' : query,
               'free_search_query-type':"q_f",
               'free_search_add_entity_author':"",
               'free_search_add_entity_person':"",
               'free_search_add_entity_place':"",
               'free_search_add_entity_organization':"",
               'datePickerFrom' : start,
               'datePickerTo' : end,
               'datePickerFixed':"",
               'date_radio':"date_on",
               'q_h':"",
               'q_l':"all",
               'q_fp':"allpages",
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
    
    r = requests.post(baseurl, params=payload, headers=headers, timeout=5)
    cookies = dict(r.cookies)

    def getArticles(req):

        print "screpo " + query + " alla pagina " + str(page)
        
        soup = BeautifulSoup(req.text)

        if soup.find("div",id="searchresult").find("div",{"class":"navigation ui-tabs-nav ui-helper-reset ui-helper-clearfix ui-widget-header ui-corner-all"}) == None:
                return []
        
        # results
        result = int(soup.find("div",id="searchresult").find("div",{"class":"navigation ui-tabs-nav ui-helper-reset ui-helper-clearfix ui-widget-header ui-corner-all"}).div.text.split("di ")[1])

        print "Trovati " + str(result) + " risultati"

        if result > 3000:
            print "Ho eleminato " + query
            return []

        links = soup.find(id="searchresult")
        if links == None:
            return []
        links = links.find_all( "dl", { "class": "search_result_content" } )
        articles = []

        for link in links:
            articles.append(link.dt.a.get("href"))

        return articles

    page = 1
    all_articles = articles = getArticles(r)
    
    while len(articles):

        page += 1
        next_url = "http://www.archiviolastampa.it/component/option,com_lastampa/task,search/Itemid,3/mod,libera/limit,10/limitstart," + str((page-1) * 10) + "/"

        r = requests.post(next_url, params=payload, headers=headers, timeout=5, cookies=cookies)
        articles = getArticles(r)
        all_articles.extend(articles)


    return all_articles


def month_year_iter( start_month, start_year, end_month, end_year ):
    ym_start= 12*start_year + start_month - 1
    ym_end= 12*end_year + end_month - 1
    for ym in range( ym_start, ym_end ):
        y, m = divmod( ym, 12 )
        yield y, m+1


with open('stampa.json', 'r') as infile:
    data = json.load(infile)

    all_entities = []

    for month in data:
        entities = data[month]["entities"]

        for people in entities["people"]:
            all_entities.append(people)
        for people in entities["places"]:
            all_entities.append(people)
        for people in entities["companies"]:
            all_entities.append(people)


    #all_entities = set(all_entities)
    #print all_entities

    all_entities = Counter(all_entities)
    all_entities = [el for el in all_entities if all_entities[el] > 1]

    
    entities_articles = {}
    
    for entity in all_entities:

        while True:
            try:
                entities_articles[entity] = stampaScrape(entity,"1900-01-01", "2006-01-01")
                with open('stampa_links.json', 'w') as outfile:
                    json.dump(entities_articles, outfile)
            except:
                print  "timed out, retrying in 5 seconds"
                time.sleep(5)
                continue
            break
    

        


                
