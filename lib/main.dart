import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:save_the_earth/LoginPage.dart';
import 'package:save_the_earth/OnBoardingPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Save The Earth',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: GoogleFonts.montserratTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: LoadingPage(),
    );
  }
}

class LoadingPage extends StatefulWidget {
  LoadingPage({Key key}) : super(key: key);

  _LoadingPageState createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  @override
  void initState() {
    super.initState();
    _shouldShowOnboard();
  }

  Future<void> _shouldShowOnboard() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool onboardShown = prefs.getBool('onboardShown') ?? false;
    if (onboardShown) {
      Get.to(LoginPage());
    } else {
      Get.to(OnBoardingPage());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Center(
      child: CircularProgressIndicator(),
    ));
  }
}
