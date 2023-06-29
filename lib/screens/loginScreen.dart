import 'package:flutter/material.dart';
import 'package:sciverse/Models/User.dart';
import 'package:sciverse/Utils/CustomLogs.dart';
import 'package:sciverse/Utils/SharedPreferenceHelper.dart';
import 'package:sciverse/dataBase/databaseHelper.dart';
import 'package:sciverse/dataBase/localDatabase.dart';
import 'package:sciverse/screens/screens.dart';

import '../widgets/CustomSnackBar.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _userNameController = TextEditingController();

  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _userNameController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'UserName',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your UserName';
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
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    User user = User(
                      username: _userNameController.text,
                      password: _passwordController.text,
                    );
                    // TODO: Perform login action
                    final isAuthSuccess =
                        await MongoDatabase.authenticate(user);

                    final snackBarText =
                        isAuthSuccess ? "Login Success" : "Login Failed";

                    final snackBar = SnackBar(
                      content: Text(snackBarText),
                    );

                    User getUser = await MongoDatabase()
                        .findUserByUsername(user.username!);
                    if (isAuthSuccess) {
                      CustomSnackBar(context, snackBarText);
                      Future.delayed(Duration(seconds: 2));
                      await LocalDatabaseHelper().insertUser(getUser);
                      customLogger("error", "User is Inserted");
                      SharedPreferencesHelper.setString(
                          "user", _userNameController.text);
                      writeToLogFile("info",
                          "Logged In With User ${_userNameController.text}");
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => HomeScreen()),
                      );
                    } else {
                      CustomSnackBar(context, snackBarText);
                      print("failed");
                      customLogger("error", "invalid Credentials");
                    }
                  }
                },
                child: const Text('Login'),
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't Have An Account ?"),
                  TextButton(
                    child: const Text('SignUp'),
                    onPressed: () {
                      // Navigate to forgot password screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SignupScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              TextButton(
                child: const Text('Forgot Password?'),
                onPressed: () {
                  // Navigate to forgot password screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ForgotPasswordScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
