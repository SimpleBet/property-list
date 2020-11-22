library property_list;

import 'dart:convert';

import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class PropertySheet extends StatefulWidget {
  final List<PropertySheet> sheets;

  final List<TableRow> properties;

  factory PropertySheet.fromMap(Map<String, dynamic> values,
      {String title = '', PropertySheetController controller}) {
    if (controller == null) {
      controller = PropertySheetController();
      controller._values = values;
    }
    return PropertySheet(
      title: title,
      controller: controller,
    );
  }

  final String title;
  final PropertySheetController controller;

  const PropertySheet(
      {Key key,
      this.sheets = const [],
      this.title = '',
      this.properties = const [],
      this.controller})
      : super(key: key);

  @override
  _PropertySheetState createState() => _PropertySheetState();
}

class _PropertySheetState extends State<PropertySheet> {
  List<PropertySheet> sheets = [];
  List<TableRow> properties = [];

  updateValues(Map<String, dynamic> values) {
    sheets = [];
    properties = [];
    _buildItemsForMap(sheets, values, properties, widget.controller);
    setState(() {});
  }

  _buildItemsForMap(List<PropertySheet> sheets, Map value,
      List<TableRow> properties, PropertySheetController controller) {
    value.forEach((key, value) {
      if (value is Map) {
        PropertySheetController myController = PropertySheetController();
        myController.key = key;
        myController._values = value;
        controller.controllers.add(myController);

        sheets.add(PropertySheet(
          title: key,
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
          controller.valueTypes[key] = value.runtimeType;

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

  @override
  void initState() {
    super.initState();
    widget.controller._init(this);
  }

  @override
  void dispose() {
    super.dispose();
    widget.controller.dispose();
  }

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
                                        controller:
                                            TextEditingController(text: json),
                                        maxLines: null,
                                        readOnly: true,
                                        decoration: null,
                                      ),
                                    )
                                  ]);
                                });
                          },
                          child: Text(
                            "JSON",
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                expanded: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: []
                      ..addAll(sheets)
                      ..add(Table(columnWidths: {
                        0: FlexColumnWidth(1),
                        1: FlexColumnWidth(3)
                      }, children: properties)),
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

class PropertySheetController {
  final List<PropertySheetController> controllers = [];
  final Map<String, TextEditingController> textControllers = {};

  Map<String, dynamic> _values = {};

  String key;

  _PropertySheetState _state;

  Map<String, Type> valueTypes = {};

  Map<String, dynamic> get value {
    controllers.forEach((controller) {
      _values[controller.key] = controller.value;
    });
    textControllers.forEach((key, value) {
      if( valueTypes[key] == String ) {
        _values[key] = value.value.text;
      } else if( valueTypes[key] == int ){
        _values[key] = int.tryParse(value.value.text);
      } else if( valueTypes[key] == double ){
        _values[key] = double.tryParse(value.value.text);
      }
    });
    return _values;
  }

  initWith(Map<String, dynamic> map) {
    _values = map;
  }

  update(Map<String, dynamic> map) {
    _values = map;
    _state.updateValues(_values);
  }

  dispose() {
    _state = null;
  }

  void _init(_PropertySheetState _propertySheetState) {
    _state = _propertySheetState;
    update(_values);
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
