import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeline_tile/timeline_tile.dart';

class ProgressPage extends StatelessWidget {
  const ProgressPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<RemoteConfig>(
      future: setupRemoteConfig(),
      builder: (BuildContext context, AsyncSnapshot<RemoteConfig> snapshot) {
        return Scaffold(
          appBar: AppBar(
            title: Text("Community Progress"),
          ),
          body: Container(
            color: Colors.grey[300],
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                children: <Widget>[
                  Text(
                    "To the Moon and back!",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  !snapshot.hasData
                      ? CircularProgressIndicator(
                          value: null,
                        )
                      : RichText(
                          text: TextSpan(
                            text: 'So far, ',
                            style: GoogleFonts.montserrat(
                              color: Colors.black,
                              fontSize: 12,
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                text: snapshot.data.getString("progress_people"),
                                style: GoogleFonts.montserrat(
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                text: ' people have contributed ',
                                style: GoogleFonts.montserrat(
                                  color: Colors.black,
                                  fontSize: 12,
                                ),
                              ),
                              TextSpan(
                                text: snapshot.data.getString("progress_steps"),
                                style: GoogleFonts.montserrat(
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                text: ' steps, which averages about ',
                                style: GoogleFonts.montserrat(
                                  color: Colors.black,
                                  fontSize: 12,
                                ),
                              ),
                              TextSpan(
                                text: snapshot.data.getString("progress_distance"),
                                style: GoogleFonts.montserrat(
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                text: ' km. This challenge is set to end at ',
                                style: GoogleFonts.montserrat(
                                  color: Colors.black,
                                  fontSize: 12,
                                ),
                              ),
                              TextSpan(
                                text: snapshot.data.getString("progress_end"),
                                style: GoogleFonts.montserrat(
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                text: '. \nGood work everyone!',
                                style: GoogleFonts.montserrat(
                                  color: Colors.black,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          children: _getTimeline(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _getTimeline() {
    List<Widget> list = new List();

    list.add(Image.asset(
      "assets/earth.png",
      width: 120,
    ));
    list.add(SizedBox(
      height: 6,
    ));

    int distance = 38400;
    for (int i = 1; i < 10; i++) {
      list.add(TimelineTile(
        alignment: TimelineAlign.center,
        topLineStyle: LineStyle(color: Colors.green),
        bottomLineStyle: LineStyle(color: i == 9 ? Colors.red : Colors.green),
        indicatorStyle: IndicatorStyle(
          width: 1,
          iconStyle: IconStyle(iconData: Icons.check_circle, fontSize: 32, color: Colors.blue),
          padding: EdgeInsets.all(15),
        ),
        rightChild: Container(
          child: Padding(
            padding: const EdgeInsets.only(left: 6),
            child: Text("${distance * i} km"),
          ),
        ),
      ));
    }

    list.add(TimelineTile(
      alignment: TimelineAlign.center,
      topLineStyle: LineStyle(color: Colors.red),
      indicatorStyle: IndicatorStyle(
        width: 1,
        iconStyle: IconStyle(iconData: Icons.error, fontSize: 32, color: Colors.red),
        padding: EdgeInsets.all(15),
      ),
      rightChild: Container(
        child: Padding(
          padding: const EdgeInsets.only(left: 6),
          child: Text("${distance * 10} km"),
        ),
      ),
    ));

    list.add(Image.asset(
      "assets/moon.png",
      width: 120,
    ));

    return list;
  }

  Future<RemoteConfig> setupRemoteConfig() async {
    final RemoteConfig remoteConfig = await RemoteConfig.instance;
    final defaults = <String, dynamic>{'progress_people': '0', 'progress_steps': '0', 'progress_distance': '0', 'progress_end': '16.09.2020'};
    await remoteConfig.setConfigSettings(RemoteConfigSettings(debugMode: true));
    await remoteConfig.setDefaults(defaults);
    await remoteConfig.fetch(expiration: const Duration(seconds: 0));
    await remoteConfig.activateFetched();
    return remoteConfig;
  }
}
