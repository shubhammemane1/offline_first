import 'package:fixnum/fixnum.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:sciverse/Models/User.dart';
import 'package:sciverse/Utils/SharedPreferenceHelper.dart';
import 'package:sciverse/dataBase/databaseHelper.dart';

import '../Utils/CustomLogs.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  DateTime? _dateOfBirth;

  String? formattedDate;

  bool _isLoading = true;

  String? user = "";

  @override
  void initState() {
    super.initState();
    getUser();
  }

  void getUser() async {
    user = (await SharedPreferencesHelper.getString("user"))!;
    print("user 12: $user");
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Profile'),
        ),
        body: _isLoading
            ? Center(child: CircularProgressIndicator())
            : FutureBuilder(
                future: MongoDatabase().findUserByUsername(user!),
                builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
                  print("snapshot :${snapshot.data?.toJson()}");
                  _addressController =
                      TextEditingController(text: snapshot.data?.address ?? "");
                  _phoneController = TextEditingController(
                      text: snapshot.data?.number.toString() ?? "");
                  _dateOfBirth = snapshot.data?.dob;
                  if (snapshot.hasData) {
                    return Form(
                      key: _formKey,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            const SizedBox(height: 16.0),
                            TextFormField(
                              controller: _addressController,
                              decoration: const InputDecoration(
                                labelText: 'Address',
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
                              controller: _phoneController,
                              decoration: const InputDecoration(
                                labelText: 'Phone Number',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your phone number';
                                }
                                // writeToLogFile("number Chnaged");
                                return null;
                              },
                            ),
                            const SizedBox(height: 16.0),
                            Container(
                              width: MediaQuery.of(context).size.width - 20,
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.blue,
                                ),
                              ),
                              child: GestureDetector(
                                onTap: () async {
                                  var selectedDate = await showDatePicker(
                                    context: context,
                                    initialDate: _dateOfBirth ?? DateTime.now(),
                                    firstDate: DateTime(1900),
                                    lastDate: DateTime.now(),
                                  );
                                  if (selectedDate != null) {
                                    setState(() {
                                      _dateOfBirth =
                                          selectedDate?.add(Duration(days: 1));
                                      selectedDate = _dateOfBirth;
                                    });
                                    formattedDate = DateFormat("yyyy-MM-dd")
                                        .format(DateTime.parse(
                                            selectedDate.toString()));
                                    writeToLogFile("info", "Birthdate Updated");
                                  }
                                },
                                child: Text(
                                  _dateOfBirth != null
                                      ? DateFormat('dd MMM yyyy')
                                          .format(_dateOfBirth!)
                                      : 'Select your date of birth',
                                  style: const TextStyle(fontSize: 16.0),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16.0),
                            _isLoading
                                ? const CircularProgressIndicator()
                                : ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        _isLoading = true;
                                      });
                                      print(
                                          "$user , ${_addressController.text} , ${_phoneController.text} , $formattedDate");
                                      User updatedUser = User(
                                        username: user,
                                        address: _addressController.text,
                                        // number: Int64.parseInt(
                                        //     _phoneController.text),
                                        dob: formattedDate != null
                                            ? DateTime.parse(formattedDate!)
                                            : _dateOfBirth,
                                      );

                                      MongoDatabase()
                                          .updateProfile(context, updatedUser);
                                      setState(() {
                                        _isLoading = false;
                                      });
                                      writeToLogFile("info", " Saved Chanes");
                                    },
                                    child: const Text('Save Changes'),
                                  ),
                          ],
                        ),
                      ),
                    );
                  }
                  return Center(child: CircularProgressIndicator());
                },
              ));
  }
}
