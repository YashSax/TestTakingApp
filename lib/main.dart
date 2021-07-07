import 'package:flutter/material.dart';
import 'package:test_timer/second_screen.dart';
import 'package:test_timer/edit_menu.dart';
import 'package:test_timer/Test.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:test_timer/third_screen.dart';

const Color BACKGROUND_COLOR = Colors.white; // F1F9DA
const Color TEST_BACKGROUND_COLOR = Colors.white;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Test Timer',
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final Test? returnedTest;

  MyHomePage({Key? key, this.returnedTest}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Test justDeleted = Test("blank", 1, 2, 3);

  @override
  Widget build(BuildContext context) {
    String encodeJSON(Test? t) {
      if (t != null) {
        Map<String, dynamic> map = {
          'name': t.name,
          'numQuestions': t.numQuestions,
          'totalMinutes': t.totalMinutes,
          'hours': t.hours,
          'minutes': t.minutes
        };
        String rawJSON = jsonEncode(map);
        return rawJSON;
      }
      return "";
    }

    Test decodeJSON(String rawJSON) {
      Map<String, dynamic> map = jsonDecode(rawJSON);
      return Test(
          map['name'], map['numQuestions'], map['hours'], map['minutes']);
    }

    List<Test> testList = [];

    void deleteItem(item, index) async {
      final prefs = await SharedPreferences.getInstance();
      final startingTestList = prefs.getStringList('testStorage') ?? [];
      print("Starting: " + startingTestList.toString());
      while (startingTestList.contains(encodeJSON(item))) {
        startingTestList.remove(encodeJSON(item));
      }
      print("After Deleting: " + startingTestList.toString());
      await prefs.setStringList('testStorage', startingTestList);
      setState(() {
        testList.removeAt(index);
      });
      print("testList after: " + testList.toString());
      print("storage after" + prefs.getStringList('testStorage').toString());
      setState(() {
        justDeleted = item;
      });
    }

    void undoDeletion(int index, item) async {
      final prefs = await SharedPreferences.getInstance();
      final startingTestList = prefs.getStringList('testStorage') ?? [];
      //prefs.reload();
      startingTestList.add(encodeJSON(item));
      await prefs.setStringList('testStorage', startingTestList);
      print('index');
      setState(() {
        testList.insert(index, item);
      });
    }

    Future<List<Test>> loadTests() async {
      final prefs = await SharedPreferences.getInstance();
      final startingTestList = prefs.getStringList('testStorage') ?? [];
      //prefs.reload();
      print("On entering loadTests(): " + startingTestList.toString());
      if (encodeJSON(widget.returnedTest) != "" &&
          encodeJSON(widget.returnedTest) != encodeJSON(justDeleted)) {
        print("in");
        startingTestList.add(encodeJSON(widget.returnedTest));
      }
      prefs.setStringList('testStorage', startingTestList);
      testList = [for (var t in startingTestList) decodeJSON(t)]
          .where((x) => x.name != "nullTest")
          .toList();
      // remove duplicates
      final jsonTestList = testList.map((x) => encodeJSON(x)).toList();
      final uniqueJSONTestList = jsonTestList.toSet().toList();
      final result = uniqueJSONTestList.map((x) => decodeJSON(x)).toList();
      testList = result;
      print("after loading tests: " + testList.toString());
      return testList;
    }

    loadTests();
    return Scaffold(
      appBar: new AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange, Colors.red], stops: [0.5, 1.0],
            ),
          ),
        ),
      ),
      backgroundColor: BACKGROUND_COLOR,
      body: Column(
        children: [
          SizedBox(
            height: 30,
          ),
          Row(
            children: [
              SizedBox(width: 100,),
              Text(
                "Menu",
                textAlign: TextAlign.right,
                textScaleFactor: 5.0,
              )
            ],
          ),
          Expanded(
            child: FutureBuilder<List<Test>>(
                future: loadTests(),
                builder: (BuildContext context,
                    AsyncSnapshot<List<Test>> snapshot) {
                  return ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: testList.length,
                    itemBuilder: (context, index) {
                      return Dismissible(
                        background: stackBehindDismissLeft(),
                        secondaryBackground: stackBehindDismissRight(),
                        key: ObjectKey(testList[index]),
                        child: ListTile(
                          title: TestDisplay(testToDisplay: testList[index]),
                        ),
                        onDismissed: (direction) {
                          var item = testList.elementAt(index);
                          // Delete
                          deleteItem(item, index);
                          // UNDO
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text("\"${item.name}\" deleted"),
                              action: SnackBarAction(
                                  label: "UNDO",
                                  onPressed: () {
                                    //To undo deletion
                                    undoDeletion(index, item);
                                  })));
                        },
                      );
                    },
                  );
                }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => {
          Navigator.push(context,
              new MaterialPageRoute(builder: (context) => new SecondScreen()))
        },
        tooltip: 'Add Test',
        child: Icon(Icons.add),
      ),
    );
  }
}

Widget stackBehindDismissRight() {
  return Container(
    alignment: Alignment.centerRight,
    padding: EdgeInsets.only(right: 20.0),
    color: BACKGROUND_COLOR,
    child: Icon(
      Icons.delete,
      color: Colors.red,
    ),
  );
}

Widget stackBehindDismissLeft() {
  return Container(
    alignment: Alignment.centerLeft,
    padding: EdgeInsets.only(right: 20.0),
    color: BACKGROUND_COLOR,
    child: Icon(
      Icons.delete,
      color: Colors.red,
    ),
  );
}

class TestDisplay extends StatefulWidget {
  final Test testToDisplay;

  const TestDisplay({Key? key, required this.testToDisplay}) : super(key: key);

  @override
  _TestDisplayState createState() => _TestDisplayState();
}

class _TestDisplayState extends State<TestDisplay> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
              context,
              new MaterialPageRoute(
                  builder: (context) =>
                      new PlayTestScreen(testToPlay: widget.testToDisplay)));
        },
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: TEST_BACKGROUND_COLOR,
                    borderRadius: BorderRadius.all(Radius.circular(20))),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        children: [
                          Text(widget.testToDisplay.getNumQuestions().toString() +
                              " Questions"),
                          Text(widget.testToDisplay.getTotalMinutes().toString() +
                              " Minutes"),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        widget.testToDisplay.getName(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: IconButton(
                          onPressed: () => {
                                Navigator.push(
                                    context,
                                    new MaterialPageRoute(
                                        builder: (context) => new EditMenu(
                                            testToEdit: widget.testToDisplay)))
                              },
                          icon: Icon(Icons.edit)),
                      flex: 1,
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
