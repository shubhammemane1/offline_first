// ignore_for_file: non_constant_identifier_names

import 'package:fixnum/fixnum.dart';

class User {
  final String? id;
  final String? name;
  final String? username;
  final String? email;
  final String? password;
  final String? address;
  final Int64? number;
  final DateTime? dob;
  final String? securityQuestion;
  final String? securityAnswer;
  final DateTime? created_at;
  final DateTime? updated_at;

  User({
    this.id,
    this.name,
    this.username,
    this.email,
    this.password,
    this.address,
    this.number,
    this.dob,
    this.securityQuestion,
    this.securityAnswer,
    this.created_at,
    this.updated_at,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      // id: json['id'],
      name: json['name'],
      username: json['username'],
      email: json['email'],
      password: json['password'],
      address: json['address'],
      number: json['number'] != null
          ? Int64.parseInt(json['number'].toString())
          : null,
      dob: json['dob'],
      securityQuestion: json['securityQuestion'],
      securityAnswer: json['securityAnswer'],
      created_at: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : null,
      updated_at: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // 'id': id,
      'name': name,
      'username': username,
      'email': email,
      'password': password,
      'address': address,
      'number': number?.toInt(),
      'dob': dob?.toIso8601String(),
      'securityQuestion': securityQuestion,
      'securityAnswer': securityAnswer,
      'created_at': created_at?.toIso8601String(),
      'updated_at': updated_at?.toIso8601String(),
    };
  }
}
