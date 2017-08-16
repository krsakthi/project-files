import json,StringIO,requests,time
from sseclient import SSEClient
from datetime import datetime

api_key = ''
print_events = 'enabled'
batch_size = 10
batch_pause = 60
particle_uri='http://datamall2.mytransport.sg/ltaodataservice/BusServices'
uri = particle_uri + '?AccountKey=' + api_key+'accept=application/json'
count = 0
flume_http_source = 'http://localhost:9998'
payload = {}
headers = {"Accept-Content":"application/json; charset=UTF-8"}

while True:
	messages = requests.get(url=particle_uri,headers={'AccountKey': 'xKHesnu1S7+ukz9xXrC75g==','accept': 'application/json'})
	jsonobj = json.loads(messages.text)
	ts = time.time()
	date_time = datetime.fromtimestamp(ts).strftime('%Y-%m-%d %H:%M:%S.%f')
	

	for i in range(1,len(jsonobj['value'])):
		if (jsonobj['value'][i]['ServiceNo'] == '15'):
			servicesNo = jsonobj['value'][i]['ServiceNo']
			operator = jsonobj['value'][i]['Operator']
			direction = str(jsonobj['value'][i]['Direction'])
			category = jsonobj['value'][i]['Category']
			originCode = str(jsonobj['value'][i]['OriginCode'])
			destinationCode = str(jsonobj['value'][i]['DestinationCode'])
			am_Peak_Freq = jsonobj['value'][i]['AM_Peak_Freq']
			am_Offpeak_Freq = jsonobj['value'][i]['AM_Offpeak_Freq']
			pm_Peak_Freq = jsonobj['value'][i]['PM_Peak_Freq']
			pm_Offpeak_Freq = jsonobj['value'][i]['PM_Offpeak_Freq']
			LoopDesc = jsonobj['value'][i]['LoopDesc']
			payload['body'] = date_time+','+servicesNo+','+operator+','+direction+','+category+','+originCode+','+destinationCode+','+am_Peak_Freq+','+am_Offpeak_Freq+','+pm_Peak_Freq+','+pm_Offpeak_Freq+','+LoopDesc
			finalresult ='['+json.dumps(payload)+']'
			print(finalresult)
			r = requests.post(flume_http_source,headers=headers,data=finalresult)
			
	time.sleep(600)
	
