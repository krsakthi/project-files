from pyspark import SparkContext, SparkConf
from pyspark.sql.context import SQLContext
from pyspark.streaming import StreamingContext
import requests
import commands
from datetime import datetime
import subprocess
import time
from pyspark.storagelevel import StorageLevel


# Firebase URL
bunchingURL = 'https://busbunching-bigdata.firebaseio.com/busbunch.json'
arrivingURL = 'https://busbunching-bigdata.firebaseio.com/busarriving.json'

sc= SparkContext("local[2]","process_data_streaming")
ssc = StreamingContext(sc,10)
text_file1 = ssc.socketTextStream("localhost",int(9978))

def getMinTime(record):
    if (record[0] >= record[3] and record[0] <= record[4]):
        return int(record[2])
    elif (record[0] >= record[6] and record[0] <= record[7]):
        return int(record[5])
    elif (record[0] >= record[9] and record[0] <= record[10]):
        return int(record[8])
    elif (record[0] >= record[12] and record[0] <= record[13]):
        return int(record[11])

def action(text_file1):
	bus_data1 = text_file1.map(lambda k : k.split(',')).map(lambda x: (time.strptime(str(x[6]).split('+')[0],'%Y-%m-%dT%H:%M:%S'), str(x[7]),str(x[8]),time.strptime(str(x[12]).split('+')[0],'%Y-%m-%dT%H:%M:%S'),str(x[13]),str(x[14]),time.strptime(str(x[18]).split('+')[0],'%Y-%m-%dT%H:%M:%S'),str(x[19]),str(x[20])))
	
	bus_services_file = subprocess.check_output('hdfs dfs -cat hdfs://localhost/lta_data/bus_services/Flume* | tail -1', shell = True)
	
	bus_services = sc.parallelize([bus_services_file])

	bus_services_split = bus_services.map(lambda k: k.split(",")).map(lambda line: [line[0],line[1],line[2],line[3],line[4],line[5],line[6],line[7],line[8],line[9],line[10],line[11]])

	bus_find_peak = bus_services_split.map(lambda p: (datetime.strptime(datetime.now().strftime('%H:%M:%S'),'%H:%M:%S'),str(p[1]),str(p[7]).split('-')[0],datetime.strptime('06:30:00','%H:%M:%S'),datetime.strptime('08:29:59','%H:%M:%S'),str(p[8]).split('-')[0],datetime.strptime('08:30:00','%H:%M:%S'),datetime.strptime('16:59:59','%H:%M:%S'),str(p[9]).split('-')[0],datetime.strptime('17:00:00','%H:%M:%S'),datetime.strptime('18:59:59','%H:%M:%S'),str(p[10]).split('-')[0],datetime.strptime('19:00:00','%H:%M:%S'),datetime.strptime('23:59:59','%H:%M:%S')))
	outputdf = bus_find_peak.map(lambda p:(getMinTime(p)*10))	
	diff = bus_data1.map(lambda k : ((time.mktime(k[3])-time.mktime(k[0]))/60))
	diff2 = bus_data1.map(lambda k :((time.mktime(k[6])-time.mktime(k[3]))/60))
	time_threshold = outputdf.collect()
	diffbus12 = diff.collect()
	diffbus23 = diff2.collect()
	print("Difference between bus1 and bus2"+str(diffbus12))
	print("Difference between bus2 and bus3"+str(diffbus23))
	print("Time Threshold "+str(time_threshold))

# Check the condition and post the status to Firebase URL	
	if diffbus12[0]  < time_threshold[0]:
		print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ Bus Bunching between Bus 1 and Bus 2 @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@")
		for elem in bus_data1.collect():
       			requests.post(bunchingURL, json ={"busnumber":15,"lat":elem[1],"lng":elem[2]})
			break
	elif diffbus23[0] < time_threshold[0] :
		print("^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^  Bus Bunching between Bus 2 and Bus3 ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^")
		for elem in bus_data1.collect():
			requests.post(bunchingURL, json ={"busnumber":15,"lat":elem[7],"lng":elem[8]})
			break
	else:
		print("$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$  No Bunching $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$")


	requests.post(arrivingURL, json={"time":datetime.now().strftime('%Y-%m-%d %H:%M:%S'),"bus1bus2": diffbus12[0],"bus2bus3":diffbus23[0]})

text_file1.foreachRDD(action)
ssc.start()
ssc.awaitTermination()

