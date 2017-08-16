
from pyspark import SparkContext
from pyspark.sql import SQLContext
from pyspark.sql import Row
import datetime
from pyspark.sql.functions import desc, udf, col, avg
from pyspark.sql.types import TimestampType
# sudo pip install python-dateutil
from dateutil.parser import parse
import requests

sc = SparkContext()
sqlContext = SQLContext(sc)
logfile = "/user/training/busarrival/busarrival/FlumeData.*"
logs = sc.textFile(logfile)
logs = logs.map(lambda line: line.replace('u"', ''))
logs = logs.map(lambda line: line.replace('"', ''))
logs = logs.map(lambda line: line.split(','))

date = logs.filter(lambda line: (len(line[0]) ==26 and len(line[6]) == 25 and len(line[12]) == 25 and len(line[18]) == 25))
date = date.map(lambda line: [parse(str(line[0])), parse(str(line[6])).replace(tzinfo = None), parse(str(line[12])).replace(tzinfo = None), parse(str(line[18])).replace(tzinfo = None)])

am_peak = date.filter(lambda line: (datetime.datetime.combine(line[0].date(), datetime.time(6, 30, 0, 0)) - line[0]).total_seconds() <= 0 and (datetime.datetime.combine(line[0].date(), datetime.time(8, 30, 0, 0)) - line[0]).total_seconds() >= 0)
am_peak = am_peak.map(lambda line: (line[0], (line[2] - line[1]).total_seconds(), (line[3] - line[2]).total_seconds()))
am_peak_no = float(am_peak.count())
if am_peak_no == 0:
	am_peak_bunching_percentage = 0
else:
	am_peak_bunching = float(am_peak.filter(lambda line: line[1] < 240).count())
	am_peak_bunching_percenrage = am_peak_bunching/am_peak_no


am_no_peak = date.filter(lambda line: (datetime.datetime.combine(line[0].date(), datetime.time(8, 30, 0, 0)) - line[0]).total_seconds() < 0 and (datetime.datetime.combine(line[0].date(), datetime.time(17, 0, 0, 0)) - line[0]).total_seconds() > 0)
am_no_peak = am_no_peak.map(lambda line: (line[0], (line[2] - line[1]).total_seconds(), (line[3] - line[2]).total_seconds()))
am_no_peak_no = float(am_no_peak.count())
if am_no_peak_no == 0:
	am_no_peak_bunching_percentage = 0
else:
	am_no_peak_bunching = float(am_no_peak.filter(lambda line: line[1] < 1800).count())
	am_no_peak_bunching_percentage = am_no_peak_bunching/am_no_peak_no



pm_peak = date.filter(lambda line: (datetime.datetime.combine(line[0].date(), datetime.time(17, 0, 0, 0)) - line[0]).total_seconds() <= 0 and (datetime.datetime.combine(line[0].date(), datetime.time(19, 0, 0, 0)) - line[0]).total_seconds() >= 0)
pm_peak = pm_peak.map(lambda line: (line[0], (line[2] - line[1]).total_seconds(), (line[3] - line[2]).total_seconds()))
pm_peak_no = float(pm_peak.count())
if pm_peak_no == 0:
	pm_peak_bunching_percentage = 0
else:
	pm_peak_bunching = float(pm_peak.filter(lambda line: line[1] < 420).count())
	pm_peak_bunching_percentage = pm_peak_bunching/pm_peak_no


pm_no_peak = date.filter(lambda line: (datetime.datetime.combine(line[0].date(), datetime.time(19, 0, 0, 0)) - line[0]).total_seconds() < 0 and (datetime.datetime.combine(line[0].date(), datetime.time(23, 59, 59, 0)) - line[0]).total_seconds() > 0)
pm_no_peak = pm_no_peak.map(lambda line: (line[0], (line[2] - line[1]).total_seconds(), (line[3] - line[2]).total_seconds()))
pm_no_peak_no = float(pm_no_peak.count())
if pm_no_peak_no == 0:
	pm_no_peak_bunching_percentage = 0
else:
	pm_no_peak_bunching = float(pm_no_peak.filter(lambda line: line[1] < 780).count())
	pm_no_peak_bunching_percentage = pm_no_peak_bunching/pm_no_peak_no

ampmURL = 'https://busbunching-bigdata.firebaseio.com/ampm.json'
amData = {
	"name": "AM",
	"offpeak": am_no_peak_bunching_percentage,
	"peak": am_peak_bunching_percentage
}
pmData = {
	"name": "PM",
	"offpeak": pm_no_peak_bunching_percentage,
	"peak": pm_peak_bunching_percentage
}

#Post the data to Firebase URL
request = requests.post(ampmURL, json=amData)
request = requests.post(ampmURL, json=pmData)
