import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:save_the_earth/LoginPage.dart';

class OnBoardingPage extends StatefulWidget {
  @override
  _OnBoardingPageState createState() => _OnBoardingPageState();
}

class _OnBoardingPageState extends State<OnBoardingPage> {
  final introKey = GlobalKey<IntroductionScreenState>();

  void _onIntroEnd(context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    const bodyStyle = TextStyle(fontSize: 19.0);
    const pageDecoration = const PageDecoration(
        titleTextStyle: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700),
        bodyTextStyle: bodyStyle,
        descriptionPadding: EdgeInsets.fromLTRB(16.0, 64.0, 16.0, 16.0),
        pageColor: Colors.white,
        imagePadding: EdgeInsets.zero,
        titlePadding: EdgeInsets.all(24));

    return IntroductionScreen(
      key: introKey,
      pages: [
        PageViewModel(
          title: "Save The Earth",
          body:
              "Welcome to our app!\nWe want to save our planet by motivating people from all over the world to reduce the amount of pollution they produce from vehicles.\nBy walking, bicycling or running more, you also get more exercise.",
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Still a prototype",
          body: "As this app is still in early development, we currently only gather data which has been generated from walking (collected by Google Fit).",
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Requirements",
          body: "You need a Google account in order to sign in. You also need to have Google Fit installed, and grant access to Google Fit data.",
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Changing challenges",
          body: "There is always one active challenge that the community (users) will try to achieve. However, if the deed seems to hard, a set deadline will eventually end the challenge.\nYour contribution is securely stored in Firestore, which you can view insided the app.",
          decoration: pageDecoration,
        ),
      ],
      onDone: () => _onIntroEnd(context),
      //onSkip: () => _onIntroEnd(context), // You can override onSkip callback
      showSkipButton: false,
      skipFlex: 0,
      nextFlex: 0,
      skip: const Text('Skip'),
      next: const Icon(Icons.arrow_forward),
      done: const Text('Done', style: TextStyle(fontWeight: FontWeight.w600)),
      dotsDecorator: const DotsDecorator(
        size: Size(10.0, 10.0),
        color: Color(0xFFBDBDBD),
        activeSize: Size(22.0, 10.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
      ),
    );
  }
}
