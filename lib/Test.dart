class Test {
  String name = "Default";
  int numQuestions = -1;
  int totalMinutes = -1;
  int hours = -1;
  int minutes = -1;

  Test(String n, int q, int h, int m) {
    name = n;
    numQuestions = q;
    totalMinutes = h*60 + m;
    hours = h;
    minutes = m;
  }

  String testToString() {
    return name.toString() + " " + numQuestions.toString() + " " + totalMinutes.toString();
  }

  String getName() {return this.name;}
  int getNumQuestions() {return this.numQuestions;}
  int getTotalMinutes() {return this.totalMinutes;}

  String encode() {
    return this.name + " ";
  }
}