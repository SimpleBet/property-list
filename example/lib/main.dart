import 'package:flutter/material.dart';

import 'dart:convert';

import 'package:expandable/expandable.dart';
import 'package:property_list/property_list.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PropertyList Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State createState() {
    return MyHomePageState();
  }
}

class MyHomePageState extends State<MyHomePage> {
  PropertySheetController controller = PropertySheetController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("PropertyList Demo"),
      ),
      body: ExpandableTheme(
        data: const ExpandableThemeData(
          iconColor: Colors.blue,
          useInkWell: true,
        ),
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            PropertySheet.fromMap(
              json.decode(testData),
            ),
            PropertySheet(controller: controller,),
            RaisedButton(child: Text("Populate"), onPressed: (){
              controller.update(json.decode(testData2));
            },)
          ],
        ),
      ),
    );
  }
}

const testData2= '''

{
    "sport": null,
    "uuid": "6671a5e0-136c-4c01-b002-6a3bb8da8d9a",
    "match_uuid": "6659f8fa-037a-4cc2-995e-d6a1c35fdb98",
    "market_description": "What will Cincinnati Bengals do this next drive?",
    "market_name": "drive_result_grouped",
    "market_title": "Score This Drive?",
    "market_category": "current_drive",
    "entity_name": "Cincinnati Bengals",
    "entity_uuid": "bc17433a-bf6a-40b3-a385-59bb7c34e393",
    "team_color": "00FF66",
    "market_image": "https://sdw-static.staging.simplebet-infra.net/public/nfl/team/fanduel_away_logo/b2047534-4d5c-4744-aa17-c727e82fe0f1CIN_Away3x.png",
    "status": "active",
    "market_status_reason": null,
    "match_drive_number": 20,
    "period": 3,
    "timeframe_status": "live",
    "selections": [
        {
            "uuid": "fd753b14-c3ad-466f-9820-71758581b17c",
            "code": "offensive_score",
            "coefficient": "5.51",
            "probability": "0.18",
            "status": "suspended",
            "title": "offensive score"
        },
        {
            "uuid": "9d4d46d2-c610-4c48-95e9-bce0dc4f23c3",
            "code": "no_offensive_score",
            "coefficient": "1.22",
            "probability": "0.82",
            "status": "suspended",
            "title": "no offensive score"
        }
    ],
    "runtimeType": "football"
}


''';
const testData = '''
{
"numbers": [0,1,2],
"letters": ["a", "b", "c"],
"widget": {
    "debug": "on",
    "enable": true,
    "window": {
        "title": "Sample Konfabulator Widget",
        "name": "main_window",
        "width": 500,
        "height": 500
    },
    "image": { 
        "src": "Images/Sun.png",
        "name": "sun1",
        "hOffset": 250,
        "vOffset": 250,
        "alignment": "center"
    },
    "text": {
        "data": "Click Here",
        "size": 36,
        "style": "bold",
        "name": "text1",
        "hOffset": 250,
        "vOffset": 100,
        "alignment": "center",
        "onMouseUp": "sun1.opacity = (sun1.opacity / 100) * 90;"
    }
}} 
''';
