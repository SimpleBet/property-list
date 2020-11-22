library property_list;

import 'dart:convert';

import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expandable Demo',
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
        title: Text("Expandable Demo"),
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
              controller: controller,
            ),
          ],
        ),
      ),
    );
  }
}

class PropertySheetController {
  final List<PropertySheetController> controllers = [];
  final Map<String, TextEditingController> textControllers = {};
  Map<String, Key> keyedWidgets;

  Map<String, dynamic> _values = {};

  String key;

  Map<String, dynamic> get value {
    controllers.forEach((controller) {
      _values[controller.key] = controller.value;
    });
    textControllers.forEach((key, value) {
      _values[key] = value.value.text;
    });
    return _values;
  }

  void initWith(Map<String, dynamic> map) {
    _values = map;
  }
}

class PropertySheetFormField extends FormField<Map<String, dynamic>> {}

class PropertySwitch extends StatefulWidget {
  final bool value;
  final String name;
  final PropertySheetController controller;

  const PropertySwitch({Key key, this.value, this.controller, this.name})
      : super(key: key);

  @override
  _PropertySwitchState createState() => _PropertySwitchState();
}

class _PropertySwitchState extends State<PropertySwitch> {
  bool _value;

  @override
  void initState() {
    super.initState();
    _value = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: _value,
      onChanged: (bool value) {
        setState(() {
          _value = value;
          widget.controller.value[this.widget.name] = value;
        });
      },
    );
  }
}

class PropertySheet extends StatefulWidget {
  factory PropertySheet.fromMap(Map<String, dynamic> json,
      {String title = '', PropertySheetController controller}) {
    List<PropertySheet> sheets = [];
    List<TableRow> properties = [];
    _buildItemsForMap(sheets, json, properties, controller);
    return PropertySheet(
      title: title,
      controller: controller,
      children: sheets,
      properties: properties,
    );
  }

  static _buildItemsForMap(List<PropertySheet> sheets, Map value,
      List<TableRow> properties, PropertySheetController controller) {
    controller.initWith(value);
    value.forEach((key, value) {
      if (value is Map) {
        List<PropertySheet> childrenSheets = [];
        List<TableRow> myProperties = [];

        PropertySheetController myController = PropertySheetController();
        myController.key = key;
        controller.controllers.add(myController);

        _buildItemsForMap(childrenSheets, value, myProperties, myController);

        sheets.add(PropertySheet(
          title: key,
          children: childrenSheets,
          properties: myProperties,
          controller: myController,
        ));
      } else {
        TableCell valueCell;

        if (value is bool) {
          valueCell = TableCell(
            child: Row(
              children: [
                PropertySwitch(
                  value: value,
                  controller: controller,
                  name: key,
                ),
              ],
            ),
          );
        } else {
          var textEditingController =
              TextEditingController(text: value.toString());
          controller.textControllers[key] = textEditingController;

          valueCell = TableCell(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: TextField(
                controller: textEditingController,
              ),
            ),
          );
        }

        properties.add(TableRow(
          children: [
            TableCell(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(key),
              ),
            ),
            valueCell
          ],
        ));
      }
    });
  }

  final List<PropertySheet> children;
  final List<TableRow> properties;
  final String title;
  final PropertySheetController controller;

  const PropertySheet(
      {Key key, this.children, this.title, this.properties, this.controller})
      : super(key: key);

  @override
  _PropertySheetState createState() => _PropertySheetState();
}

class _PropertySheetState extends State<PropertySheet> {
  @override
  Widget build(BuildContext context) {
    return ExpandableNotifier(
        child: Padding(
      padding: const EdgeInsets.all(10),
      child: ScrollOnExpand(
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: <Widget>[
              ExpandablePanel(
                theme: const ExpandableThemeData(
                  headerAlignment: ExpandablePanelHeaderAlignment.center,
                  tapBodyToExpand: false,
                  tapBodyToCollapse: false,
                  hasIcon: false,
                ),
                header: Container(
                  color: Colors.blueGrey[600],
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      children: [
                        ExpandableIcon(
                          theme: const ExpandableThemeData(
                            expandIcon: Icons.arrow_right,
                            collapseIcon: Icons.arrow_drop_down,
                            iconColor: Colors.white,
                            iconSize: 28.0,
                            iconRotationAngle: math.pi / 2,
                            iconPadding: EdgeInsets.only(right: 5),
                            hasIcon: false,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            widget.title,
                            style: Theme.of(context)
                                .textTheme
                                .body2
                                .copyWith(color: Colors.white),
                          ),
                        ),
                        FlatButton(
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  String json = JsonEncoder.withIndent('    ')
                                      .convert(widget.controller.value);
                                  return SimpleDialog(children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: TextField(
                                        controller: TextEditingController(text: json),
                                        maxLines: null,
                                        readOnly: true,
                                        decoration: null,
                                      ),
                                    )
                                  ]);
                                });
                          },
                          child: Text("JSON", style: TextStyle(color: Colors.white),),
                        )
                      ],
                    ),
                  ),
                ),
                expanded: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: []
                      ..addAll(widget.children)
                      ..add(Table(columnWidths: {
                        0: FlexColumnWidth(1),
                        1: FlexColumnWidth(3)
                      }, children: widget.properties)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }
}

const testData = '''
{"widget": {
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
