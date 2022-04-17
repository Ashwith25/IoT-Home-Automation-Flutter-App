import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mm_app/history_model.dart';

class DeviceHistory extends StatefulWidget {
  const DeviceHistory({Key key}) : super(key: key);

  @override
  State<DeviceHistory> createState() => _DeviceHistoryState();
}

class _DeviceHistoryState extends State<DeviceHistory> {
  List<Feeds> feeds = [];
  List<DeviceData> deviceData = [];
  bool isLoading = true;

  getHistory() async {
    var url = Uri.parse(
        'https://api.thingspeak.com/channels/1700213/feeds.json?api_key=ZO78JD211YCW469Q');

    Map<String, String> header = {
      "Content-type": "application/json",
    };
    try {
      http.Response response = await http
          .get(
            url,
            headers: header,
          )
          .catchError((err) {});
      if (response.statusCode != 201 && response.statusCode != 200) {
        return null;
      } else {
        var data = jsonDecode(response.body);
        feeds =
            data['feeds'].map<Feeds>((json) => Feeds.fromJson(json)).toList();
        for (int i = 0; i < feeds.length; i++) {
          if (feeds[i].field1 == '1') {
            for (int j = i; j < feeds.length; j++) {
              if (feeds[j].field1 == '0') {
                deviceData.add(DeviceData(
                  device: "bulb",
                  startTime: feeds[i].createdAt,
                  endTime: feeds[j].createdAt,
                ));
                i = j;
                break;
              }
            }
          }
        }
        for (int i = 0; i < feeds.length; i++) {
          if (feeds[i].field2 == '1') {
            for (int j = i; j < feeds.length; j++) {
              if (feeds[j].field2 == '0') {
                deviceData.add(DeviceData(
                  device: "fan",
                  startTime: feeds[i].createdAt,
                  endTime: feeds[j].createdAt,
                ));
                i = j;
                break;
              }
            }
          }
        }

        isLoading = false;
        setState(() {});
      }
    } catch (error) {
      rethrow;
    }
  }

  @override
  void initState() {
    super.initState();
    getHistory();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Scaffold(
            backgroundColor: Colors.blueGrey,
            appBar: AppBar(
              title: Text("Appliance History"),
              backgroundColor: Colors.blueAccent,
            ),
            body: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          )
        : DefaultTabController(
            length: 2,
            child: Scaffold(
              backgroundColor: Colors.blueGrey,
              appBar: AppBar(
                backgroundColor: Colors.blueAccent,
                title: Text("Appliance History"),
                bottom: TabBar(
                  indicatorColor: Colors.white,
                  tabs: [
                    Tab(
                      icon: Icon(
                        FontAwesomeIcons.lightbulb,
                      ),
                      text: "Bulb",
                    ),
                    Tab(
                      icon: Icon(FontAwesomeIcons.fan),
                      text: "Fan",
                    ),
                  ],
                ),
              ),
              body: TabBarView(
                children: [bulbList("bulb"), bulbList("fan")],
              ),
            ),
          );
  }

  Widget bulbList(device) {
    List<ListTile> list = deviceData.map(
      (_device) {
        if (_device.device == device) {
          int minutes = DateTime.parse(_device.endTime)
              .difference(DateTime.parse(_device.startTime))
              .inMinutes;
          return ListTile(
            title: Text(
              _device.device.toUpperCase() +
                  " was turned on for " +
                  "${((minutes ~/ 60).toInt() > 24) ? ((minutes ~/ 60) % 24).toString() + ' day(s), ' : ""}" +
                  "${(minutes.toInt() > 60) ? (minutes ~/ 60).toString() + ' hours and ' : ""}" +
                  "${(minutes.toInt() == 0) ? (DateTime.parse(_device.endTime).difference(DateTime.parse(_device.startTime)).inSeconds).toString() + ' seconds' : (minutes % 60).toString() + " minutes and " + (DateTime.parse(_device.endTime).difference(DateTime.parse(_device.startTime)).inSeconds % 60).toString() + " seconds"}",
              // "${(minutes % 60)} minutes",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                "from " +
                    "${DateFormat("dd MMM, HH:mm").format(DateTime.parse(
                      _device.startTime,
                    ).toLocal())}"
                        " to " +
                    "${DateFormat("dd MMM, HH:mm").format(DateTime.parse(_device.endTime).toLocal())}",
                style: TextStyle(
                    color: Colors.tealAccent,
                    fontSize: 15,
                    fontWeight: FontWeight.bold),
              ),
            ),
          );
        }
      },
    ).toList();
    list.removeWhere((element) => element == null);
    if (list.isEmpty) {
      return Center(
        child: Text("No data found",
            style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
      );
    }
    print(list.reversed);
    return ListView.separated(
      itemCount: list.length,
      itemBuilder: (context, index) => list.reversed.toList()[index],
      separatorBuilder: (context, index) => Divider(
        color: Colors.white,
      ),
    );
  }
}
