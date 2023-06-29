// ignore_for_file: prefer_typing_uninitialized_variables

import 'dart:developer';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:sciverse/Models/Question.dart';
import 'package:sciverse/Models/User.dart';
import 'package:sciverse/Utils/Constants.dart';

import '../widgets/CustomSnackBar.dart';

class MongoDatabase {
  static var db, userCollection;

  static connect() async {
    db = await Db.create(AppConstants.MONGO_URL);
    await db.open();
    inspect(db);
    userCollection = db.collection(AppConstants.COLLECTION_NAME);
  }

  static addUser(User user) async {
    final users = db.collection(AppConstants.COLLECTION_NAME);

    print(users.toString());

    final newUser = User(
      name: user.name,
      username: user.username,
      email: user.email,
      password: user.password,
      securityQuestion: user.securityQuestion,
      securityAnswer: user.securityAnswer,
      created_at: DateTime.now(),
    );

    final result = await users.insertOne(user.toJson());

    // await db.close();
  }

  static authenticate(User user) async {
    final query =
        where.eq('username', user.username).eq('password', user.password);
    final users = db.collection(AppConstants.COLLECTION_NAME);
    final result = await users.findOne(query);
    if (result != null) {
      // Authentication successful

      print("success");
      return true;
    } else {
      // Authentication failed
      print("failed ");
      return false;
    }
  }

  Future<User> findUserByUsername(String username) async {
    final users = db.collection(AppConstants.COLLECTION_NAME);
    final userMap = await users.findOne({'username': username});

    if (userMap != null) {
      return User.fromJson(userMap);
    } else {
      return User();
    }
  }

  Future<User> findUserByEmail(String email) async {
    final users = db.collection(AppConstants.COLLECTION_NAME);
    final userMap = await users.findOne({'email': email});

    if (userMap != null) {
      return User.fromJson(userMap);
    } else {
      return User();
    }
  }

  void updateProfile(BuildContext context, User user) async {
    final users = db.collection(AppConstants.COLLECTION_NAME);

    final result = await users.updateOne(
      where.eq('username', user.username),
      {
        '\$set': {
          'address': user.address,
          // 'number': user.number,
          'dob': user.dob,
        },
      },
    );

    // await db.close();

    if (result.ok == 1) {
      CustomSnackBar(context, "Profile Updated");
    } else {
      CustomSnackBar(context, "Error Updating Profile");
    }
  }

  void updatePassword(BuildContext context, User user) async {
    final users = db.collection(AppConstants.COLLECTION_NAME);

    final result = await users.updateOne(
      where.eq('email', user.email),
      {
        '\$set': {
          'username': user.username,
          'password': user.password,
          'updated_at': DateTime.now().toString(),
        },
      },
    );
    print("is data pushed ${user.toJson()}");
  }

  static submitAnswer(List<QuestionResponse> questionResponse) async {
    final users = db.collection(AppConstants.ANSWER_COLLECTION_NAME);

    final documents = questionResponse
        .map((response) => {
              'user': response.user,
              'question': response.question.toJson(),
              'answer': response.answer,
            })
        .toList();

    await users.insertMany(documents);
  }

  static close() async {
    await db.close();
  }
}
