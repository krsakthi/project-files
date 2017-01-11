import json
from urlparse import urlparse
import time
import datetime
import httplib2 as http
import pandas as pd
import pyodbc
import pyproj as proj
from shapely import geometry
import numpy as np
import paho.mqtt.client as mqtt

def collect_traffic_incident_data():
    print("collecting data for traffice incident")
    headers ={'AccountKey' : 'VPuQbqzSQBOEHx2rfaFTWQ==',# TODO create a api key and then give that
                'accept' : 'application/json'}
    uri = 'http://datamall2.mytransport.sg/'
    path = '/ltaodataservice/TrafficIncidents?'
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
    jsonObj = jsonObj['value']
    jsonObj=json.dumps(jsonObj)
    traffic_incident_DF = pd.read_json(jsonObj)
    return traffic_incident_DF

def check_within_radius(speedBandLat,speedBandLong,trafficIncidentLat,trafficIncidentLong):
    crs_wgs = proj.Proj(init='epsg:4326')  # assuming you're using WGS84 geographic
    crs_bng = proj.Proj(init='epsg:3414')  # use a locally appropriate projected CRS

    # then cast your geographic coordinate pair to the projected system
    x_1, y_1 = proj.transform(crs_wgs, crs_bng, speedBandLong, speedBandLat)
    x_2, y_2 = proj.transform(crs_wgs, crs_bng, trafficIncidentLong, trafficIncidentLat)
    point_1 = geometry.Point(x_1, y_1)
    point_2 = geometry.Point(x_2, y_2)

    # create your circle buffer from one of the points
    distance = 1000 #1km
    circle_buffer = point_1.buffer(distance)

    # and you can then check if the other point lies within
    if point_2.within(circle_buffer):
        return True
    else:
        return False




def speed_band_data_collection():
    print('collecting data for traffic speed band')
    ts = time.time()
    date_time = datetime.datetime.fromtimestamp(ts).strftime('%Y-%m-%d %H:%M:%S')
    #time = datetime.datetime.fromtimestamp(ts).strftime('%H:%M:%S')
    headers ={'AccountKey' : 'VPuQbqzSQBOEHx2rfaFTWQ==',# TODO create a api key and then give that
                'accept' : 'application/json'}
    uri = 'http://datamall2.mytransport.sg/'
    path = '/ltaodataservice/TrafficSpeedBands?'
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
    jsonObj = jsonObj['value']
    jsonObj=json.dumps(jsonObj)
    df = pd.read_json(jsonObj)
    df['date'] = date_time
    return df

def collect_erp_data():
    erpData = pd.read_csv("E:\\NUS-SEM2\\Sense Making\\Project\\erp_data.csv", low_memory=True)
    return erpData


def insert_into_table(editedDF):
    conn = pyodbc.connect(r'Driver={SQL Server};Server=LAPTOP-VUL4TP1T;DATABASE=Transport;Trusted_Connection=yes;')
    cursor = conn.cursor()

    for index, row in editedDF.iterrows():
        cursor.execute(
            "insert into arterial_road_traffic_v2(LinkID, Location, MaximumSpeed, MinimumSpeed,RoadCategory, Name, SpeedBand, dt,Latitude, Longitude, Category) values (?,?,?,?,?,?,?,?,?,?,'Road')",
            row['LinkID'], row['Location'], row['MaximumSpeed'], row['MinimumSpeed'], row['RoadCategory'],
            row['RoadName'], row['SpeedBand'], row['date'], row['end_latitude'], row['end_longitude'])
        cursor.execute(
            "insert into arterial_road_traffic_v2(LinkID, Location, MaximumSpeed, MinimumSpeed,RoadCategory, Name, SpeedBand, dt,Latitude, Longitude, tfType, Category) values (?,?,?,?,?,?,?,?,?,?,?,'TrafficIncident')",
            row['LinkID'], row['Location'], row['MaximumSpeed'], row['MinimumSpeed'], row['RoadCategory'],
            row['tfMessage'], row['SpeedBand'], row['date'], row['tfLatitude'], row['tfLongitude'],
            row['tfType'])
        cursor.execute(
            "insert into arterial_road_traffic_v2(LinkID, Location, MaximumSpeed, MinimumSpeed,RoadCategory, Name, SpeedBand, dt,Latitude, Longitude, erpDistrict, Category) values (?,?,?,?,?,?,?,?,?,?,?,'ERP')",
            row['LinkID'], row['Location'], row['MaximumSpeed'], row['MinimumSpeed'], row['RoadCategory'],
            row['erpRoad'], row['SpeedBand'], row['date'], row['erpLatitude'], row['erpLongitude'],
            row['erpDistrict'])
        cursor.execute("update arterial_road_traffic_v2 set tfType = Category where tfType is null")
        cursor.execute("update arterial_road_traffic_v2 set Speeds = CONVERT(VARCHAR,MinimumSpeed) + ' - ' + CONVERT(VARCHAR,MaximumSpeed)")
        conn.commit()
    conn.close()

def post_data(datapayloadJson):
    client = mqtt.Client()
    client.connect("iot.eclipse.org", 1883, 60)
    client.publish("topic/transportDF", datapayloadJson)
    client.disconnect()

def main_function():

    print("inside traffic speed band collection")
    df = speed_band_data_collection()
    traffic_incident_DF = collect_traffic_incident_data()
    erpData = collect_erp_data()

    editedDF = df[(df['RoadCategory']=='B') | (df['RoadCategory']=='C') | (df['RoadCategory']=='D')]
    editedDF = editedDF[editedDF['SpeedBand']<=2]
    editedDF['start_latitude'] = editedDF['Location'].apply(lambda x: x.split(' ')[0])
    editedDF['start_longitude'] = editedDF['Location'].apply(lambda x: x.split(' ')[1])
    editedDF['end_latitude'] = editedDF['Location'].apply(lambda x: x.split(' ')[2])
    editedDF['end_longitude'] = editedDF['Location'].apply(lambda x: x.split(' ')[3])



    editedDF['tfType'] = None
    editedDF['tfMessage'] = None
    editedDF['tfLatitude'] = None
    editedDF['tfLongitude'] = None

    for speedBandindex,speedBandrow in editedDF.iterrows():
        for trafficIncidentIndex,trafficIncidentRow in traffic_incident_DF.iterrows():
            status = check_within_radius(speedBandrow['end_latitude'],speedBandrow['end_longitude'],trafficIncidentRow['Latitude'],trafficIncidentRow['Longitude'])
            if status:
                editedDF['tfType'][speedBandindex] = trafficIncidentRow['Type']
                editedDF['tfMessage'][speedBandindex] = trafficIncidentRow['Message']
                editedDF['tfLatitude'][speedBandindex] = trafficIncidentRow['Latitude']
                editedDF['tfLongitude'][speedBandindex] = trafficIncidentRow['Longitude']



    editedDF['erpDistrict'] = None
    editedDF['erpRoad'] = None
    editedDF['erpLatitude'] = None
    editedDF['erpLongitude'] = None

    for speedBandindex,speedBandrow in editedDF.iterrows():
        for erpDataIndex,erpDataRow in erpData.iterrows():
            status = check_within_radius(speedBandrow['end_latitude'],speedBandrow['end_longitude'],erpDataRow['erpLatitude'],erpDataRow['erpLongitude'])
            if status:
                editedDF['erpDistrict'][speedBandindex] = erpDataRow['district']
                editedDF['erpRoad'][speedBandindex] = erpDataRow['erpRoad']
                editedDF['erpLatitude'][speedBandindex] = erpDataRow['erpLatitude']
                editedDF['erpLongitude'][speedBandindex] = erpDataRow['erpLongitude']


    datapayloadJson = editedDF.to_json(path_or_buf = None, orient = 'records',date_format = 'epoch', double_precision = 10, force_ascii = True, date_unit = 'ms', default_handler = None)
    post_data(datapayloadJson)

    insert_into_table(editedDF)
