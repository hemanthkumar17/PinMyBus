import 'package:flutter/material.dart';

class MultiSelectDialogItem<V> {
  const MultiSelectDialogItem(this.value, this.label);

  final V value;
  final String label;
}

class MultiSelectDialog<V> extends StatefulWidget {
  MultiSelectDialog({Key key, this.items, this.initialSelectedValues})
      : super(key: key);

  final List<MultiSelectDialogItem<V>> items;
  final Set<V> initialSelectedValues;

  @override
  State<StatefulWidget> createState() => _MultiSelectDialogState<V>();
}

class _MultiSelectDialogState<V> extends State<MultiSelectDialog<V>> {
  final _selectedValues = Set<V>();

  void initState() {
    super.initState();
    if (widget.initialSelectedValues != null) {
      _selectedValues.addAll(widget.initialSelectedValues);
    }
  }

  void _onItemCheckedChange(V itemValue, bool checked) {
    setState(() {
      if (checked) {
        _selectedValues.add(itemValue);
      } else {
        _selectedValues.remove(itemValue);
      }
    });
  }

  void _onCancelTap() {
    Navigator.pop(context);
  }

  void _onSubmitTap() {
    Navigator.pop(context, _selectedValues);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Select Time Schedule Type'),
      contentPadding: EdgeInsets.only(top: 12.0),
      content: SingleChildScrollView(
        child: ListTileTheme(
          contentPadding: EdgeInsets.fromLTRB(14.0, 0.0, 24.0, 0.0),
          child: ListBody(
            children: widget.items.map(_buildItem).toList(),
          ),
        ),
      ),
      actions: <Widget>[
        FlatButton(
          child: Text('CANCEL'),
          onPressed: _onCancelTap,
        ),
        FlatButton(
          child: Text('OK'),
          onPressed: _onSubmitTap,
        )
      ],
    );
  }

  Widget _buildItem(MultiSelectDialogItem<V> item) {
    final checked = _selectedValues.contains(item.value);
    return CheckboxListTile(
      value: checked,
      title: Text(item.label),
      controlAffinity: ListTileControlAffinity.leading,
      onChanged: (checked) => _onItemCheckedChange(item.value, checked),
    );
  }
}

class Dropdowns extends StatefulWidget {
  final ValueChanged<String> recMode;
  final ValueChanged<List<String>> dropList;
  Dropdowns({Key key, this.recMode, this.dropList}) : super(key: key);

  @override
  _DropdownsState createState() => _DropdownsState();
}

class _DropdownsState extends State<Dropdowns> {
  String value = "";
  String prevalue = "";
  List<DropdownMenuItem<String>> menuitems = List();
  bool disabledropdown = true;

  List<String> droplist = [];

  // final onetime = {
  //   "1": "PHP",
  //   "2": "Python",
  //   "3": "Node JSs",
  // };

  // void populateonetime() {
  //   for (String key in onetime.keys) {
  //     menuitems.add(DropdownMenuItem<String>(
  //       child: Center(
  //         child: Text(onetime[key]),
  //       ),
  //       value: onetime[key],
  //     ));
  //   }
  // }

  void selected(_value) {
    if (_value == "One-Time") {
      menuitems = [];
      prevalue = _value;
      // populateonetime();
      populateMultiselect();
    } else if (_value == "Weekly") {
      menuitems = [];
      prevalue = _value;
      // populateweekly();
      populateMultiselect1();
    }
    setState(() {
      value = _value;
      disabledropdown = false;
    });
  }

  void secondselected(_value) {
    setState(() {
      value = _value;
    });
  }

  List<MultiSelectDialogItem<int>> multiItem = List();

  final valueweekly = {
    1: "Monday",
    2: "Tuesday",
    3: "Wednesday",
    4: "Thursday",
    5: "Friday",
    6: "Saturday",
    7: "Sunday"
  };
  final valueonetime = {
    // 1:"None"
    1: "1",
    2: "2",
    3: "3",
    4: "4",
    5: "5",
    6: "6",
    7: "7",
    8: "8",
    9: "9",
    10: "10",
    11: "11",
    12: "12",
    13: "13",
    14: "14",
    15: "15",
    16: "16",
    17: "17",
    18: "18",
    19: "19",
    20: "20",
    21: "21",
    22: "22",
    23: "23",
    24: "24",
    25: "25",
    26: "26",
    27: "27",
    28: "28",
    29: "29",
    30: "30",
    31: "31",
  };

  void populateMultiselect1() {
    for (int v in valueweekly.keys) {
      multiItem.add(MultiSelectDialogItem(v, valueweekly[v]));
    }
  }

  void populateMultiselect() {
    for (int v in valueonetime.keys) {
      multiItem.add(MultiSelectDialogItem(v, valueonetime[v]));
    }
  }

  DateTime selectedDate = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
  }

  void _showMultiSelect(BuildContext context) async {
    multiItem = [];
    // populateMultiselect();
    if (value == "One-Time") {
      menuitems = [];
      prevalue = value;
      // populateonetime();
      populateMultiselect();
    } else if (value == "Weekly") {
      menuitems = [];
      prevalue = value;
      // populateweekly();
      populateMultiselect1();
    }
    final items = multiItem;
    // final items = <MultiSelectDialogItem<int>>[
    //   MultiSelectDialogItem(1, 'India'),
    //   MultiSelectDialogItem(2, 'USA'),
    //   MultiSelectDialogItem(3, 'Canada'),
    // ];
    if (value == "Weekly") {
      final selectedValues = await showDialog<Set<int>>(
        context: context,
        builder: (BuildContext context) {
          return MultiSelectDialog(
            items: items,
            initialSelectedValues: [1].toSet(),
          );
        },
      );

      print(selectedValues);
      getvaluefromkey(selectedValues);
    } else {
      await _selectDate(context);
      widget.dropList([selectedDate.day.toString()]);
    }
  }

  void getvaluefromkey(Set selection) {
    if (selection != null) {
      droplist = [];
      for (int x in selection.toList()) {
        droplist.add("$x");
        widget.dropList(droplist);
      }
      print(widget.dropList);
      print(widget.recMode);
    }
  }

  @override
  Widget build(BuildContext context) {
    widget.recMode(value);
    return Container(
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            DropdownButton<String>(
              items: [
                DropdownMenuItem<String>(
                  value: "Weekly",
                  child: Center(
                    child: Text("Weekly"),
                  ),
                ),
                DropdownMenuItem<String>(
                  value: "One-Time",
                  child: Center(
                    child: Text("One-Time"),
                  ),
                ),
              ],
              onChanged: (_value) => selected(_value),
              hint: Text(prevalue),
            ),
            // DropdownButton<String>(
            //   items: menuitems,
            //   onChanged:
            //       disabledropdown ? null : (_value) => secondselected(_value),
            //   hint: Text(value),
            //   disabledHint: Text("First Select Your Field"),
            // ),

            RaisedButton(
              color: Color.fromRGBO(255, 171, 0, .9),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Container(
                  height: 50,
                  width: 100,
                  child: Center(
                      child: Text(
                    "Choose TimeLine",
                    style: TextStyle(fontSize: 10, color: Colors.white),
                  ))),
              onPressed: () => _showMultiSelect(context),
            ),
          ],
        ),
      ),
    );
  }
}
