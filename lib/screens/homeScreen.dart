import 'package:flutter/material.dart';
import 'package:sciverse/Models/Question.dart';
import 'package:sciverse/Utils/CustomLogs.dart';
import 'package:sciverse/Utils/SharedPreferenceHelper.dart';
import 'package:sciverse/dataBase/databaseHelper.dart';
import './screens.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? user;

  final List<Question> _questions = [
    Question(
      text: 'What is the capital of France?',
      options: ['Paris', 'Madrid', 'Berlin', 'Rome'],
      answer: 'Paris',
    ),
    Question(
      text: 'What is the currency of Japan?',
      options: ['Dollar', 'Euro', 'Yen', 'Pound'],
      answer: 'Yen',
    ),
  ];

  List<String> _answers = [];
  @override
  void initState() {
    super.initState();
    _answers = List<String>.filled(_questions.length, '');
    getUser();
  }

  void getUser() async {
    user = (await SharedPreferencesHelper.getString("user"))!;
    print("user : $user");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My App'),
        actions: [
          PopupMenuButton(
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: const [
                    Icon(Icons.person),
                    SizedBox(width: 8.0),
                    Text('Profile'),
                  ],
                ),
              ),
              PopupMenuItem(
                onTap: () {
                  SharedPreferencesHelper.remove("user");
                },
                value: 'logout',
                child: Row(
                  children: const [
                    Icon(Icons.exit_to_app),
                    SizedBox(width: 8.0),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              switch (value) {
                case "profile":
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => EditProfileScreen()),
                  );
                  break;
                case "logout":
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                  break;
                default:
              }
              if (value == 'profile') {}
            },
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView.builder(
          itemCount: _questions.length,
          itemBuilder: (context, index) {
            final question = _questions[index];
            return Column(
              children: [
                Container(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(question.text, style: TextStyle(fontSize: 18)),
                        SizedBox(height: 16),
                        ...question.options.map((option) => RadioListTile(
                              title: Text(option),
                              value: option,
                              groupValue: _answers[index],
                              onChanged: (value) {
                                setState(() {
                                  _answers[index] = value!;
                                });
                              },
                            )),
                        SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            _formKey.currentState!.save();
            _submitAnswers();
          }
        },
        child: Icon(Icons.check),
      ),
    );
  }

  void _submitAnswers() async {
    // Build a list of QuestionResponse objects with the user's answers
    print("check this value : $user");
    final responses = List<QuestionResponse>.generate(
      _questions.length,
      (index) => QuestionResponse(
        user: user,
        question: _questions[index],
        answer: _answers[index],
      ),
    );

    await MongoDatabase.submitAnswer(responses);
    writeToLogFile(
        "info", "Response Submitted ${responses.map((e) => e.answer)}");
    customLogger("warn", "successFully Entered");
  }
}
