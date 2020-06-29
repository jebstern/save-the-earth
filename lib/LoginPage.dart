import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:save_the_earth/HomePage.dart';
import 'package:save_the_earth/controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  void initState() {
    super.initState();
    _saveOnboardingDone();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<Controller>(
        init: Controller(),
        builder: (_) {
          if (_.user == null) {
            return Column(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Expanded(
                  flex: 4,
                  child: Container(
                    alignment: Alignment.center,
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Image.asset("assets/logo.jpg"),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    color: Colors.white,
                    child: Center(
                      child: Column(
                        children: <Widget>[
                          Text("Logging in..."),
                          SizedBox(
                            height: 20,
                          ),
                          CircularProgressIndicator(
                            value: null,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          } else {
            Future.microtask(() => Get.to(HomePage()));
            return Container();
          }
        },
      ),
    );
  }

  void _saveOnboardingDone() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboardShown', true);
  }
}
