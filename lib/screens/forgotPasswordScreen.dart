import 'package:flutter/material.dart';
import 'package:sciverse/Utils/CustomLogs.dart';
import 'package:sciverse/Utils/SharedPreferenceHelper.dart';
import 'package:sciverse/dataBase/localDatabase.dart';

import '../Models/User.dart';
import '../dataBase/databaseHelper.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();

  var _securtiyQuestionController = TextEditingController();
  var _securtiyAnswerController = TextEditingController();
  var _userSecurtiyAnswerController = TextEditingController();
  var _updatePasswordController = TextEditingController();

  int? checkResetPassword;

  bool isEmailVerified = false;
  bool resetPassword = false;

  // String? securtiyAnswer;

  var code;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Forgot Password'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              isEmailVerified == false
                  ? ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          isEmailVerified = true;
                        });
                      },
                      child: Text('Reset Password'),
                    )
                  : Container(),
              isEmailVerified == false && resetPassword == false
                  ? Container()
                  : ConnectionState.active == true
                      ? FutureBuilder(
                          future: MongoDatabase()
                              .findUserByEmail(_emailController.text),
                          builder: (BuildContext context,
                              AsyncSnapshot<User> snapshot) {
                            customLogger("warn", "YOur Working in Online Mode");
                            _securtiyQuestionController = TextEditingController(
                                text: snapshot.data?.securityQuestion);
                            if (snapshot.hasData) {
                              return Column(
                                children: [
                                  const SizedBox(height: 16.0),
                                  TextFormField(
                                    controller: _securtiyQuestionController,
                                    decoration: const InputDecoration(
                                      labelText: 'Securiy Question',
                                      border: OutlineInputBorder(),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your address';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16.0),
                                  TextFormField(
                                    controller: _securtiyAnswerController,
                                    decoration: const InputDecoration(
                                      labelText: 'Security Answer',
                                      border: OutlineInputBorder(),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your Answer';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16.0),
                                  resetPassword == true
                                      ? Container()
                                      : ElevatedButton(
                                          onPressed: () {
                                            String securityAnswer =
                                                snapshot.data?.securityAnswer ??
                                                    '';
                                            if (_securtiyAnswerController
                                                    .text ==
                                                securityAnswer) {
                                              setState(() {
                                                resetPassword = true;
                                              });
                                            }
                                          },
                                          child: const Text('Submit Answer'),
                                        )
                                ],
                              );
                            }
                            return Center(child: CircularProgressIndicator());
                          },
                        )
                      : FutureBuilder(
                          future: LocalDatabaseHelper()
                              .getUserByEmail(_emailController.text),
                          builder: (BuildContext context,
                              AsyncSnapshot<User> snapshot) {
                            customLogger(
                                "warn", "YOur Working in offline Mode");
                            _securtiyQuestionController = TextEditingController(
                                text: snapshot.data?.securityQuestion);
                            if (snapshot.hasData) {
                              return Column(
                                children: [
                                  const SizedBox(height: 16.0),
                                  TextFormField(
                                    controller: _securtiyQuestionController,
                                    decoration: const InputDecoration(
                                      labelText: 'Securiy Question',
                                      border: OutlineInputBorder(),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your address';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16.0),
                                  TextFormField(
                                    controller: _securtiyAnswerController,
                                    decoration: const InputDecoration(
                                      labelText: 'Security Answer',
                                      border: OutlineInputBorder(),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your Answer';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16.0),
                                  resetPassword == true
                                      ? Container()
                                      : ElevatedButton(
                                          onPressed: () {
                                            String securityAnswer =
                                                snapshot.data?.securityAnswer ??
                                                    '';
                                            if (_securtiyAnswerController
                                                    .text ==
                                                securityAnswer) {
                                              setState(() {
                                                resetPassword = true;
                                              });
                                            }
                                          },
                                          child: const Text('Submit Answer'),
                                        )
                                ],
                              );
                            }
                            return Center(child: CircularProgressIndicator());
                          },
                        ),
              resetPassword == true
                  ? Column(
                      children: [
                        TextFormField(
                          controller: _updatePasswordController,
                          decoration: const InputDecoration(
                            labelText: 'Update Password',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter New Password';
                            }
                            // writeToLogFile("number Chnaged");
                            return null;
                          },
                        ),
                        ElevatedButton(
                          onPressed: () {
                            User user = User(
                              email: _emailController.text,
                              password: _updatePasswordController.text,
                              updated_at: DateTime.now(),
                            );
                            print("useremail : ${_emailController.text}");
                            if (ConnectionState.active == true) {
                              MongoDatabase().updatePassword(context, user);
                              LocalDatabaseHelper().updateUserPassword(user);
                            } else {
                              SharedPreferencesHelper.setBool(
                                  "offlineUserUpdated", true);
                              SharedPreferencesHelper.setString(
                                  "offlineUserUpdatedUserName",
                                  _emailController.text);
                              LocalDatabaseHelper().updateUserPassword(user);
                            }
                            writeToLogFile("info", "passWord Updated");
                            customLogger("warn", "passWord Updated");
                          },
                          child: const Text('Update Password'),
                        )
                      ],
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
