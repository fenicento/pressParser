import requests,re
from bs4 import BeautifulSoup
import json
from calendar import monthrange
import datetime
import time
from collections import Counter
from datetime import datetime
from locale import setlocale, LC_TIME
import itertools


with open('corriere_links.json', 'r') as corriere:
    corriere_data = json.load(corriere)

#with open('repubblica_links.json', 'r') as repubblica:
#    repubblica_data = json.load(repubblica)

setlocale(LC_TIME, ('it_it'))

dates = {}

valid_links = []

for a in corriere_data:
	for link in a["links"]:
		valid_links.append(link)

black_list = ["politecnico di milano", "italia", "milano", "europa", "ue"]

for a in corriere_data:
	date = datetime.strptime( a['date'], "%d %B %Y" ).strftime("%Y-%m")
	if not date in dates:
		dates[date] = {}
	month = dates[date]
	links = list(itertools.combinations(a["links"],2))

	for link in links:
		source = link[0]
		target = link[1]
		if source.lower() in black_list or target.lower() in black_list:
			continue
		if not source in month:
			print "non cera " + source
			source = link[1]
			target = link[0]
		if not source in month:
			print "non cera " + source + "e ho creato"
			month[source] = {}
		if not target in month[source]:
			month[source][target] = 1
		else:
			month[source][target] += 1

dates_all = {}

for d in dates:
	for source in dates[d]:
		for target in dates[d][source]:

			if not d in dates_all:
				dates_all[d] = []
			dates_all[d].append({
				"source" : source,
				"target" : target,
				"value" : dates[d][source][target]
				})

with open('corriere_linkati.json', 'w') as outfile:
    json.dump(dates_all, outfile)




