import 'package:flutter/material.dart';
import 'package:test_timer/Test.dart';
import 'package:test_timer/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class EditMenu extends StatelessWidget {
  final Test testToEdit;
  EditMenu({Key? key, required this.testToEdit}) : super(key: key);

  final nameController = TextEditingController();
  final numQuestionsController = TextEditingController();
  final numHoursController = TextEditingController();
  final numMinutesController = TextEditingController();

  displayInfo() {
    print("Test name " + nameController.text);
    print("Number of Questions " + numQuestionsController.text);
    print("Number of Hours " + numHoursController.text);
    print("Number of Minutes " + numMinutesController.text);
  }
  // TODO: make user unable to input no or invalid input
  @override
  Widget build(BuildContext context) {
    String encodeJSON(Test t) {
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

    void deleteItem(item, index) async {
      final prefs = await SharedPreferences.getInstance();
      final startingTestList = prefs.getStringList('testStorage') ?? [];
      print("Starting: "  + startingTestList.toString());
      while(startingTestList.contains(encodeJSON(item))) {
        startingTestList.remove(encodeJSON(item));
      }
      print("After Deleting: " + startingTestList.toString());
      await prefs.setStringList('testStorage', startingTestList);
    }
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Create Test Here!"),
      ),
      body: Column(
        // Test Name, Number of Questions, Total Time
        children: [
          // TEST NAME
          Row(
            children: [
              SizedBox(
                width: 10,
              ),
              Text("Test Name"),
              SizedBox(
                width: 30,
              ),
              Expanded(
                child: TextField(
                  controller: nameController..text = testToEdit.name,
                  decoration: InputDecoration(
                      hintText: "Enter the name of the test here"),
                ),
              )
            ],
          ),
          // NUMBER OF QUESTIONS
          Row(
            children: [
              SizedBox(
                width: 10,
              ),
              Text("Number of Questions"),
              SizedBox(
                width: 30,
              ),
              Expanded(
                child: TextField(
                  controller: numQuestionsController..text = testToEdit.numQuestions.toString(),
                  keyboardType: TextInputType.number,
                ),
              )
            ],
          ),
          // TIME
          Row(
            children: [
              SizedBox(
                width: 10,
              ),
              Text("Total Time"),
              SizedBox(
                width: 30,
              ),
              Expanded(
                child: TextField(
                  controller: numHoursController..text = testToEdit.hours.toString(),
                  decoration: InputDecoration(hintText: "Hours"),
                  keyboardType: TextInputType.number,
                ),
              ),
              SizedBox(
                width: 20,
              ),
              Expanded(
                child: TextField(
                  controller: numMinutesController..text = testToEdit.minutes.toString(),
                  decoration: InputDecoration(
                    hintText: "Minutes",
                  ),
                  keyboardType: TextInputType.number,
                ),
              )
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
        {
          if(nameController.text.isEmpty || numQuestionsController.text.isEmpty || (numHoursController.text.isEmpty && numMinutesController.text.isEmpty)) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invalid Input')))
          } else {
            deleteItem(testToEdit,0),
            Navigator.push( // change screen
              context,
              MaterialPageRoute(
                builder: (context) =>
                    MyHomePage(
                        returnedTest: Test(
                            nameController.text,
                            int.parse(numQuestionsController.text),
                            int.parse(numHoursController.text),
                            int.parse(numMinutesController.text))),
              ),
            )
          }
        },
        child: Icon(Icons.check),
      ),
    );
  }
}
