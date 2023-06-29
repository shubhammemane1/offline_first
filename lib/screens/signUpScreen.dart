import 'package:flutter/material.dart';
import 'package:sciverse/Models/User.dart';
import 'package:sciverse/Utils/CustomLogs.dart';
import 'package:sciverse/dataBase/databaseHelper.dart';
import 'package:sciverse/dataBase/localDatabase.dart';
import 'package:sciverse/screens/screens.dart';

import '../widgets/CustomSnackBar.dart';

class SignupScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _userNameController = TextEditingController();
  String? _selectedSecurityQuestion;
  final _securityQuestions = [
    'What is your mother\'s maiden name?',
    'What is the name of your first pet?',
    'What is your favorite movie?',
    'What is your favorite book?',
    'What is your favorite food?',
  ];
  final _answerController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Signup'),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _userNameController,
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    labelText: 'UserName',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please confirm your password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Security Question',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedSecurityQuestion,
                  onChanged: (value) {
                    _selectedSecurityQuestion = value;
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a security question';
                    }
                    return null;
                  },
                  items: _securityQuestions
                      .map(
                        (question) => DropdownMenuItem(
                          value: question,
                          child: Text(question),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _answerController,
                  decoration: const InputDecoration(
                    labelText: 'Security Answer',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your security answer';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      User user = User(
                        name: _nameController.text,
                        email: _emailController.text,
                        username: _userNameController.text,
                        password: _passwordController.text,
                        securityQuestion: _selectedSecurityQuestion,
                        securityAnswer: _answerController.text,
                        created_at: DateTime.now(),
                        updated_at: DateTime.now(),
                      );

                      MongoDatabase.addUser(user).then(
                        (value) => {
                          CustomSnackBar(context, "Account Created"),
                          LocalDatabaseHelper().insertUser(user).then(
                                (value) => {
                                  CustomSnackBar(context,
                                      "Data is Saved in local Storage"),
                                  print("Data is Saved in local Storage"),
                                },
                              ),
                        },
                      );

                      // Future.delayed(const Duration(seconds: 2));
                      // // writeToLogFile(
                      // //   "Created new User With Info ${_nameController.text} ,  ${_userNameController.text} ,  ${_emailController.text},  ${_passwordController.text}",
                      // // );
                      // Navigator.pop(context);
                    }
                  },
                  child: const Text('Signup'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
