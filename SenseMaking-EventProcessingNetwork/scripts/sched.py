from apscheduler.schedulers.blocking import BlockingScheduler
import logging
logging.basicConfig()
import json
from urlparse import urlparse
import time
import datetime
import httplib2 as http
import pandas as pd
import pyodbc



def road_openings_data():


    print('Colleting data for road openings')
    ts = time.time()
    date_time = datetime.datetime.fromtimestamp(ts).strftime('%Y-%m-%d %H:%M:%S')
    # time = datetime.datetime.fromtimestamp(ts).strftime('%H:%M:%S')
    headers = {'AccountKey': 'VPuQbqzSQBOEHx2rfaFTWQ==',  # TODO create a api key and then give that
                   'accept': 'application/json'}
    uri = 'http://datamall2.mytransport.sg/'
    #path = 'ltaodataservice/BusArrival/?BusStopID=43009&ServiceNo=106&SST=True'
    conn = pyodbc.connect(r'Driver={SQL Server};Server=LAPTOP-GUHC0F3U\SAKTHI;DATABASE=Transport;Trusted_Connection=yes;')
    cursor = conn.cursor()
    list =["43009","43179","43189","43619","43629","42319","28109","28189","28019","20109","17189","17179","17169","17159","19049","19039","19029","19019","11199","11189","11401","11239","11229","11219","11209","13029","13019","9149","9159","9169","9179","9048","9038","8138","8057","8069","4179","2049","2151","2161","2171","3509","3519","3539","3529","3129","3218","3219","3239"]
    for i in list:
            print(i)
            path = 'ltaodataservice/BusArrival/?BusStopID='+str(i)+'&ServiceNo=106&SST=True'

            #incident_name = "_traffic_incidents"
            #folderName = "Traffic Incident"
            #fileLocation = "E:\\NUS-SEM2\\Sense Making\\data\\"
            #end of things to change
            target = urlparse(uri+path)
            method = 'GET'
            body = ''

            h = http.Http()
            response, content = h.request(
            target.geturl(),
            method,
            body,
            headers)
                    # Parse JSON to print
            jsonObj = json.loads(content)
            print("obj",jsonObj)
            #jsonObjSrv = jsonObj['BusStopID']
            #print("obj2",jsonObj)
            jsonObjSrv = jsonObj['Services'][0]['SubsequentBus']
            jsonObjNxt = jsonObj['Services'][0]['NextBus']
            jsonObjSub1 = jsonObj['Services'][0]['SubsequentBus3']
            #jsonObj=json.dumps(jsonObj)
            #df = pd.read_json(jsonObj)
            #df['date'] = date_time
            #df1 = pd.concat([df1, df])
            cursor.execute("insert into bus_routes1(BusStopID,ServiceNo,Status,NextBus_Load,NextBus_Long,NextBus_Lat,NextBus_EstArrival,Subseq_Load,Subseq_Long,Subseq_Lat,Subseq_EstArrival,Subseq1_Load,Subseq1_Long,Subseq1_Lat,Subseq1_EstArrival,dt) values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",jsonObj['BusStopID'],jsonObj['Services'][0]['ServiceNo'],jsonObj['Services'][0]['Status'],jsonObjNxt['Load'],jsonObjNxt['Longitude'],jsonObjNxt['Latitude'],jsonObjNxt['EstimatedArrival'],jsonObjSrv['Load'],jsonObjSrv['Longitude'],jsonObjSrv['Latitude'],jsonObjSrv['EstimatedArrival'],jsonObjSub1['Load'],jsonObjSub1['Longitude'],jsonObjSub1['Latitude'],jsonObjSub1['EstimatedArrival'],date_time)
            conn.commit()
    #cursor.execute("drop table sample_viz_table ")
    #cursor.execute( "select distinct NextBus_Lat,NextBus_Long,NextBus_Load,'Bus' as Typ into sample_viz_table from bus_routes1 where dt=(select Max(dt) from bus_routes1)and NextBus_Lat != 0")
    conn.close()

sched = BlockingScheduler()
#road_openings
@sched.scheduled_job('interval',minutes=2)
def road_opening():
    road_openings_data()

sched.start()