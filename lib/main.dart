// ignore_for_file: use_build_context_synchronously

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:sciverse/Models/User.dart';
import 'package:sciverse/Utils/CustomLogs.dart';
import 'package:sciverse/dataBase/databaseHelper.dart';
import 'package:sciverse/dataBase/localDatabase.dart';
import 'package:sciverse/screens/screens.dart';

import 'Utils/SharedPreferenceHelper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // for debug mode comment and uncomment this if condition

  // if (ConnectionState.active == true) {
  await MongoDatabase.connect();
  // }
  await LocalDatabaseHelper.connect();
  await LocalDatabaseHelper().printUsersTable();

  final logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );
  runApp(MyApp(logger: logger));
}

class MyApp extends StatefulWidget {
  final Logger logger;
  const MyApp({super.key, required this.logger});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? user = "";
  String? offlineUserUpdatedUserEmail = "";
  bool? offlineUserUpdated = false;

  final Connectivity _connectivity = Connectivity();

  @override
  void initState() {
    // TODO: implement initState
    getUser();
    super.initState();
  }

  Future<bool> checkConnectivity() async {
    final ConnectivityResult result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  void getUser() async {
    user = (await SharedPreferencesHelper.getString("user"));

    bool isDataBaseExist = await LocalDatabaseHelper().checkIfDatabaseExists();

    offlineUserUpdated =
        await SharedPreferencesHelper.getBool("offlineUserUpdated");
    offlineUserUpdatedUserEmail =
        await SharedPreferencesHelper.getString("offlineUserUpdatedUserName");

    bool hasConnectivity = await checkConnectivity();
    if (hasConnectivity && isDataBaseExist && offlineUserUpdated == true) {
      User mongoUser =
          await MongoDatabase().findUserByEmail(offlineUserUpdatedUserEmail!);
      User localUser = await LocalDatabaseHelper()
          .getUserByEmail(offlineUserUpdatedUserEmail!);

      print("MOngo user : ${mongoUser.toJson()}");
      print("local user : ${localUser.toJson()}");

      if (mongoUser.updated_at!.isBefore(localUser.updated_at!)) {
        print("Data is Ready to push");
        mongoUser = User(
          username: localUser.username,
          email: localUser.email,
          password: localUser.password,
          updated_at: DateTime.now(),
        );
        MongoDatabase().updatePassword(context, mongoUser);
        LocalDatabaseHelper().updateUserPassword(mongoUser);

        bool isRemoved =
            await SharedPreferencesHelper.remove("offlineUserUpdated");
        print("isUpdated and removed from sharedPrefes : $isRemoved");
      } else {
        print("Password is already Uppdated");
        print(
            "is Already Updated : ${mongoUser.updated_at!.isAfter(localUser.updated_at!)}");
      }

      customLogger("warn ", "mongoDb : ${mongoUser.updated_at}");
      customLogger("error ", "LOcalDB : ${localUser.updated_at}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(body: LoginScreen()),
    );
  }
}
