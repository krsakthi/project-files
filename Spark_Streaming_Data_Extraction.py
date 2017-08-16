import json,StringIO,requests,time
from sseclient import SSEClient
from datetime import datetime
import subprocess
# Extract Data from LTA API
api_key = '/5e6w0/RSKW3bxOJniLc5g=='
print_events = 'enabled'
batch_size = 10
batch_pause = 60
particle_uri='http://datamall2.mytransport.sg/ltaodataservice/BusArrival?BusStopID=83139&ServiceNo=15&SST=True'
uri = particle_uri + '?AccountKey=' + api_key+'accept=application/json'
count = 0
flume_http_source = 'http://localhost:7778'
payload = {}
headers = {"Accept-Content":"application/json; charset=UTF-8"}
# Convert to structured format
while True:
	messages = requests.get(url=particle_uri,headers={'AccountKey': 'eT2fiQhDQLyLlFUC2Fhe1g==','accept': 'application/json'})
	jsonobj = json.loads(messages.text)
	ts = time.time()
	date_time = datetime.fromtimestamp(ts).strftime('%Y-%m-%d %H:%M:%S.%f')
	servicesNo = jsonobj['Services'][0]['ServiceNo']
	status = jsonobj['Services'][0]['Status']
	operator = jsonobj['Services'][0]['Operator']
	orginatingID = jsonobj['Services'][0]['OriginatingID']
	terminatingID = jsonobj['Services'][0]['TerminatingID']
	next_est = jsonobj['Services'][0]['NextBus']['EstimatedArrival']
	next_lat = jsonobj['Services'][0]['NextBus']['Latitude']
	next_long = jsonobj['Services'][0]['NextBus']['Longitude']
	next_vist = jsonobj['Services'][0]['NextBus']['VisitNumber']
	next_load = jsonobj['Services'][0]['NextBus']['Load']
	next_feature = jsonobj['Services'][0]['NextBus']['Feature']
	
	sub_est = jsonobj['Services'][0]['SubsequentBus']['EstimatedArrival']
	sub_lat = jsonobj['Services'][0]['SubsequentBus']['Latitude']
	sub_long = jsonobj['Services'][0]['SubsequentBus']['Longitude']
	sub_vist = jsonobj['Services'][0]['SubsequentBus']['VisitNumber']
	sub_load = jsonobj['Services'][0]['SubsequentBus']['Load']
	sub_feature = jsonobj['Services'][0]['SubsequentBus']['Feature']

	sub2_est = jsonobj['Services'][0]['SubsequentBus3']['EstimatedArrival']
	sub2_lat = jsonobj['Services'][0]['SubsequentBus3']['Latitude']
	sub2_long = jsonobj['Services'][0]['SubsequentBus3']['Longitude']
	sub2_vist = jsonobj['Services'][0]['SubsequentBus3']['VisitNumber']
	sub2_load = jsonobj['Services'][0]['SubsequentBus3']['Load']
	sub2_feature = jsonobj['Services'][0]['SubsequentBus3']['Feature']
	payload['body'] = date_time+','+servicesNo+','+status+','+operator+','+orginatingID+','+terminatingID+','+next_est+','+next_lat+','+next_long+','+next_vist+','+next_load+','+next_feature+','+sub_est+','+sub_lat+','+sub_long+','+sub_vist+','+sub_load+','+sub_feature+','+sub2_est+','+sub2_lat+','+sub2_long+','+sub2_vist+','+sub2_load+','+sub2_feature

	finalresult ='['+json.dumps(payload)+']'
	print(finalresult)
# Post the data to Streaming HTTP Source
	r = requests.post(flume_http_source,headers=headers,data=finalresult)
	bash_command = "echo "+finalresult+"|nc -l localhost 9978 -w 0"
	subprocess.call(bash_command,shell=True)
	time.sleep(10)

	
	
