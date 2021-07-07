import 'package:flutter/material.dart';
import 'package:test_timer/Test.dart';
import 'package:test_timer/main.dart';

class SecondScreen extends StatefulWidget {
  const SecondScreen({Key? key}) : super(key: key);

  @override
  SecondScreenState createState() => SecondScreenState();
}

class SecondScreenState extends State<SecondScreen> {
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

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange, Colors.red], stops: [0.5, 1.0],
              ),
            ),
          ),
          centerTitle: true,
          title: new Text("Create A Test"),
        ),
      body: Column(
        // Test Name, Number of Questions, Total Time
        children: [
          SizedBox(height: 10),
          // TEST NAME
          Row(
            children: [
              SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: "Test Name",
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black12, width: 1.0),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10),
            ],
          ),
          // NUMBER OF QUESTIONS
          SizedBox(height: 20,),
          Row(
            children: [
              SizedBox(
                width: 10,
              ),
              Text(
                "Number of Questions",
                textScaleFactor: 1.5,
              ),
              SizedBox(
                width: 30,
              ),
              Expanded(
                child: TextField(
                  controller: numQuestionsController,
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
              Text(
                "Total Time",
                textScaleFactor: 1.5,
              ),
              SizedBox(
                width: 30,
              ),
              Expanded(
                child: TextField(
                  controller: numHoursController,
                  decoration: InputDecoration(hintText: "Hours"),
                  keyboardType: TextInputType.number,
                ),
              ),
              SizedBox(
                width: 20,
              ),
              Expanded(
                child: TextField(
                  controller: numMinutesController,
                  decoration: InputDecoration(
                    hintText: "Minutes",
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
        {
          if(nameController.text.isEmpty || int.tryParse(numQuestionsController.text)==null || int.tryParse(numHoursController.text)==null || int.tryParse(numMinutesController.text)==null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invalid Input')))
          } else {
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

