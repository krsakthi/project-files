import paho.mqtt.client as mqtt
import sys
import json
from BeautifulSoup import BeautifulSoup

def on_connect(client,userdata,flags,rc):
    print("connected with result code"+str(rc))
    client.subscribe("topic/transportDF")

def on_message(client,userdata,msg):
    null=None
    #data_a = [{"LinkID":103000040,"Location":"1.3094817613742067 103.85571657719505 1.3100415318076366 103.85617487784177","MaximumSpeed":"39","MinimumSpeed":20,"RoadCategory":"D","RoadName":"VERDUN ROAD","SpeedBand":2,"date":"2016-11-11 19:26:47","start_latitude":"1.3094817613742067","start_longitude":"103.85571657719505","end_latitude":"1.3100415318076366","end_longitude":"103.85617487784177","tfType":null,"tfMessage":null,"tfLatitude":null,"tfLongitude":null,"erpDistrict":"Central Business District (CBD)","erpRoad":"Queen Street","erpLatitude":1.30129,"erpLongitude":103.85494},{"LinkID":103000086,"Location":"1.3009014346769388 103.90150591557894 1.3000155854751687 103.90006277560406","MaximumSpeed":"39","MinimumSpeed":20,"RoadCategory":"C","RoadName":"AMBER ROAD","SpeedBand":2,"date":"2016-11-11 19:26:47","start_latitude":"1.3009014346769388","start_longitude":"103.90150591557894","end_latitude":"1.3000155854751687","end_longitude":"103.90006277560406","tfType":null,"tfMessage":null,"tfLatitude":null,"tfLongitude":null,"erpDistrict":null,"erpRoad":null,"erpLatitude":null,"erpLongitude":null},{"LinkID":103000087,"Location":"1.3000155854751687 103.90006277560406 1.3009014346769388 103.90150591557894","MaximumSpeed":"39","MinimumSpeed":20,"RoadCategory":"C","RoadName":"AMBER ROAD","SpeedBand":2,"date":"2016-11-11 19:26:47","start_latitude":"1.3000155854751687","start_longitude":"103.90006277560406","end_latitude":"1.3009014346769388","end_longitude":"103.90150591557894","tfType":null,"tfMessage":null,"tfLatitude":null,"tfLongitude":null,"erpDistrict":null,"erpRoad":null,"erpLatitude":null,"erpLongitude":null},{"LinkID":103000090,"Location":"1.379554969889813 103.83982137005755 1.3778764702530613 103.83969577191468","MaximumSpeed":"39","MinimumSpeed":20,"RoadCategory":"C","RoadName":"ANG MO KIO AVENUE 4","SpeedBand":2,"date":"2016-11-11 19:26:47","start_latitude":"1.379554969889813","start_longitude":"103.83982137005755","end_latitude":"1.3778764702530613","end_longitude":"103.83969577191468","tfType":null,"tfMessage":null,"tfLatitude":null,"tfLongitude":null,"erpDistrict":null,"erpRoad":null,"erpLatitude":null,"erpLongitude":null},{"LinkID":103000091,"Location":"1.3778764702530613 103.83969577191468 1.379554969889813 103.83982137005755","MaximumSpeed":"19","MinimumSpeed":0,"RoadCategory":"C","RoadName":"ANG MO KIO AVENUE 4","SpeedBand":1,"date":"2016-11-11 19:26:47","start_latitude":"1.3778764702530613","start_longitude":"103.83969577191468","end_latitude":"1.379554969889813","end_longitude":"103.83982137005755","tfType":null,"tfMessage":null,"tfLatitude":null,"tfLongitude":null,"erpDistrict":null,"erpRoad":null,"erpLatitude":null,"erpLongitude":null},{"LinkID":103000098,"Location":"1.3034535281731428 103.82621354051224 1.302018104115238 103.82687869301155","MaximumSpeed":"39","MinimumSpeed":20,"RoadCategory":"D","RoadName":"TOMLINSON ROAD","SpeedBand":2,"date":"2016-11-11 19:26:47","start_latitude":"1.3034535281731428","start_longitude":"103.82621354051224","end_latitude":"1.302018104115238","end_longitude":"103.82687869301155","tfType":null,"tfMessage":null,"tfLatitude":null,"tfLongitude":null,"erpDistrict":"Orchard Cordon (OC)","erpRoad":"Orchard Turn","erpLatitude":1.30335,"erpLongitude":103.83251},{"LinkID":103000099,"Location":"1.302018104115238 103.82687869301155 1.3034535281731428 103.82621354051224","MaximumSpeed":"19","MinimumSpeed":0,"RoadCategory":"D","RoadName":"TOMLINSON ROAD","SpeedBand":1,"date":"2016-11-11 19:26:47","start_latitude":"1.302018104115238","start_longitude":"103.82687869301155","end_latitude":"1.3034535281731428","end_longitude":"103.82621354051224","tfType":null,"tfMessage":null,"tfLatitude":null,"tfLongitude":null,"erpDistrict":"Orchard Cordon (OC)","erpRoad":"Orchard Turn","erpLatitude":1.30335,"erpLongitude":103.83251},{"LinkID":103000111,"Location":"1.277633353991097 103.80909264308315 1.2771369059505562 103.81040355919788","MaximumSpeed":"39","MinimumSpeed":20,"RoadCategory":"D","RoadName":"TELOK BLANGAH HEIGHTS","SpeedBand":2,"date":"2016-11-11 19:26:47","start_latitude":"1.277633353991097","start_longitude":"103.80909264308315","end_latitude":"1.2771369059505562","end_longitude":"103.81040355919788","tfType":null,"tfMessage":null,"tfLatitude":null,"tfLongitude":null,"erpDistrict":null,"erpRoad":null,"erpLatitude":null,"erpLongitude":null},{"LinkID":103000115,"Location":"1.2780189431917124 103.80767112662544 1.277633353991097 103.80909264308315","MaximumSpeed":"39","MinimumSpeed":20,"RoadCategory":"D","RoadName":"TELOK BLANGAH HEIGHTS","SpeedBand":2,"date":"2016-11-11 19:26:47","start_latitude":"1.2780189431917124","start_longitude":"103.80767112662544","end_latitude":"1.277633353991097","end_longitude":"103.80909264308315","tfType":null,"tfMessage":null,"tfLatitude":null,"tfLongitude":null,"erpDistrict":null,"erpRoad":null,"erpLatitude":null,"erpLongitude":null},{"LinkID":103000118,"Location":"1.2765900388648779 103.81171237266507 1.276042945010033 103.81302172471231","MaximumSpeed":"39","MinimumSpeed":20,"RoadCategory":"D","RoadName":"TELOK BLANGAH HEIGHTS","SpeedBand":2,"date":"2016-11-11 19:26:47","start_latitude":"1.2765900388648779","start_longitude":"103.81171237266507","end_latitude":"1.276042945010033","end_longitude":"103.81302172471231","tfType":null,"tfMessage":null,"tfLatitude":null,"tfLongitude":null,"erpDistrict":null,"erpRoad":null,"erpLatitude":null,"erpLongitude":null}]

    data_a = msg.payload
    json1_data = json.loads(data_a)[0]
    #return data_a
    print(json1_data)

    with open(statusPath, "r+") as f:
        data = f.read()
        soup = BeautifulSoup(data)
        json_str_bus_RoadName = json1_data['RoadName']
        json_str_bus_SpeedBand = json1_data['SpeedBand']
        json_str_bus_tfType = json1_data['tfType']
        json_str_bus_erpRoad = json1_data['erpRoad']
        json_str_bus_tfMessage = json1_data['tfMessage']
        td_bus_RoadName = soup.find('td', {'id': 'json_str_bus_RoadName'})
        td_bus_SpeedBand = soup.find('td', {'id': 'json_str_bus_SpeedBand'})
        td_bus_tfType = soup.find('td', {'id': 'json_str_bus_tfType'})
        td_bus_erpRoad = soup.find('td', {'id': 'json_str_bus_erpRoad'})
        td_bus_tfMessage = soup.find('td', {'id': 'json_str_bus_tfMessage'})
        td_bus_RoadName.string = json1_data['RoadName']
        td_bus_SpeedBand = json1_data['SpeedBand']
        td_bus_tfType = json1_data['tfType']
        td_bus_erpRoad = json1_data['erpRoad']
        td_bus_tfMessage = json1_data['erpRoad']
        print(td_bus_RoadName)
        td_bus_RoadName_2 = soup.find('td', {'id': 'json_str_bus_RoadName_2'})
        td_bus_SpeedBand_2 = soup.find('td', {'id': 'json_str_bus_SpeedBand_2'})
        td_bus_tfType_2 = soup.find('td', {'id': 'json_str_bus_tfType_2'})
        td_bus_erpRoad_2 = soup.find('td', {'id': 'json_str_bus_erpRoad_2'})
        td_bus_tfMessage_2 = soup.find('td', {'id': 'json_str_bus_tfMessage_2'})
        td_bus_RoadName_2.string = json.loads(data_a)[1]['RoadName']
        td_bus_SpeedBand_2 = json.loads(data_a)[1]['SpeedBand']
        td_bus_tfType_2 = json.loads(data_a)[1]['tfType']
        td_bus_erpRoad_2 = json.loads(data_a)[1]['erpRoad']
        td_bus_erpRoad_2 = json.loads(data_a)[1]['erpRoad']
        td_bus_RoadName_3 = soup.find('td', {'id': 'json_str_bus_RoadName_3'})
        td_bus_SpeedBand_3 = soup.find('td', {'id': 'json_str_bus_SpeedBand_3'})
        td_bus_tfType_3 = soup.find('td', {'id': 'json_str_bus_tfType_3'})
        td_bus_RoadName_3.string = json.loads(data_a)[2]['RoadName']
        td_bus_SpeedBand_3 = json.loads(data_a)[2]['SpeedBand']
        td_bus_tfType_3 = json.loads(data_a)[2]['tfType']
        f.close
        html = soup.prettify("utf-8")
        with open(statusPath, "wb") as file:
            file.write(html)

			
statusPath="D:\CA Sense Making\Traffic_updates.html"
client = mqtt.Client()
client.connect("iot.eclipse.org",1883,60)
client.on_connect = on_connect
client.on_message = on_message
client.loop_forever()

# Update HTML File

