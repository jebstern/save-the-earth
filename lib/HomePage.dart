import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:health/health.dart';
import 'package:save_the_earth/model/HelthData.dart';
import 'package:save_the_earth/controller.dart';
import 'package:save_the_earth/ProgressPage.dart';
import 'package:save_the_earth/data/repository.dart';
import 'package:charts_flutter/flutter.dart' as charts;

/// Sample time series data type.
class TimeSeriesSales {
  final DateTime time;
  final int sales;

  TimeSeriesSales(this.time, this.sales);
}

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isAuthorized = false;
  int _lastSync;
  int _totalSteps;
  bool _isLoadingGoogleFitData = true;
  bool _isUpdatingFirestoreDocument = false;
  bool _hasSynchronizedData = false;
  Random random = new Random();
  final Controller c = Get.find();
  List<charts.Series<TimeSeriesSales, DateTime>> seriesList;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 0), () async {
      if (!_hasSynchronizedData) {
        initPlatformState(c.healthData.lastSync);
      }
    });
    _createSampleData();
  }

  void _createSampleData() {
    final now = DateTime.now();
    final data = [
      new TimeSeriesSales(new DateTime(now.year, now.month, now.day - 7), 9232),
      new TimeSeriesSales(new DateTime(now.year, now.month, now.day - 6), 500),
      new TimeSeriesSales(new DateTime(now.year, now.month, now.day - 5), 5232),
      new TimeSeriesSales(new DateTime(now.year, now.month, now.day - 4), 7219),
      new TimeSeriesSales(new DateTime(now.year, now.month, now.day - 3), 14000),
      new TimeSeriesSales(new DateTime(now.year, now.month, now.day - 2), 2242),
      new TimeSeriesSales(new DateTime(now.year, now.month, now.day - 1), 8023),
      new TimeSeriesSales(new DateTime(now.year, now.month, now.day), 7723),
      new TimeSeriesSales(new DateTime(now.year, now.month, now.day + 1), 6532),
    ];

    seriesList = [
      new charts.Series<TimeSeriesSales, DateTime>(
        id: 'steps',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (TimeSeriesSales sales, _) => sales.time,
        measureFn: (TimeSeriesSales sales, _) => sales.sales,
        data: data,
      )
    ];
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState(int lastSync) async {
    final now = DateTime.now();
    DateTime startDate;
    if (lastSync == 0 || lastSync == null) {
      startDate = new DateTime(now.year, now.month, now.day);
    } else {
      startDate = DateTime.fromMillisecondsSinceEpoch(lastSync);
    }

    DateTime endDate = DateTime.now();

    Future.delayed(Duration(seconds: 2), () async {
      _isAuthorized = await Health.requestAuthorization();

      if (_isAuthorized) {
        try {
          List<HealthDataPoint> healthDataList = await Health.getHealthDataFromType(startDate, endDate, HealthDataType.STEPS);

          if (healthDataList.length > 0) {
            _lastSync = healthDataList[healthDataList.length - 1].dateTo;
            _totalSteps = healthDataList.fold(0, (t, e) => t + e.value);
            _isUpdatingFirestoreDocument = true;
          } else {
            _lastSync = c.healthData.lastSync > 0 ? c.healthData.lastSync : 0;
            _totalSteps = 0;
          }
          _totalSteps += c.healthData.steps;
          _isLoadingGoogleFitData = false;
        } catch (exception) {
          print(exception.toString());
        }

        /// Update the UI to display the results
        setState(() {});
      } else {
        print('Not authorized');
      }
    });

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoadingGoogleFitData && !_hasSynchronizedData) {
      WidgetsBinding.instance.addPostFrameCallback((_) => updateFirestore());
    }
    return Scaffold(
      drawer: Drawer(
        child: GetBuilder<Controller>(
          builder: (_) {
            return ListView(
              // Important: Remove any padding from the ListView.
              padding: EdgeInsets.zero,
              children: <Widget>[
                UserAccountsDrawerHeader(
                  accountName: Text(_.user.name),
                  accountEmail: Text(_.user.email),
                  currentAccountPicture: CircleAvatar(backgroundImage: NetworkImage(_.user.photoUrl)),
                ),
                ListTile(
                  leading: Icon(Icons.trending_up),
                  title: Text('Community progress'),
                  onTap: () {
                    Get.back();
                    Get.to(ProgressPage());
                  },
                ),
              ],
            );
          },
        ),
      ),
      appBar: AppBar(
        title: const Text('Save the Earth'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.info),
            onPressed: () {
              _showInfoDialog();
            },
          ),
        ],
      ),
      body: _getBodyBasedOnLastSync(),
    );
  }

  Widget _getBodyBasedOnLastSync() {
    if (c.healthData.firstTime) {
      return _firstTimeView();
    } else {
      return _getLastSyncView();
    }
  }

  Widget _firstTimeView() {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: <Widget>[
            Text(
              "Hello and Welcome!",
              style: TextStyle(
                fontSize: 28,
              ),
            ),
            SizedBox(
              height: 24,
            ),
            Text(
              "Apparently this is your first time using this app. Your STEPS data will be synchronized with our servers every time you open up this app. Have fun!",
            ),
            _getFirstTimeSync(),
            SizedBox(
              height: 44,
            ),
            Image.asset("assets/walking.gif"),
          ],
        ),
      ),
    );
  }

  Widget _getFirstTimeSync() {
    if (_isUpdatingFirestoreDocument) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: 32,
            ),
            Text('Synchronizing STEPS data, please wait ...'),
            SizedBox(
              height: 12,
            ),
            CircularProgressIndicator(
              value: null,
            )
          ],
        ),
      );
    } else {
      return Container();
    }
  }

  Widget _getLastSyncView() {
    if (_isLoadingGoogleFitData) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Loading Google Fit data, please wait ...'),
            SizedBox(
              height: 12,
            ),
            CircularProgressIndicator(
              value: null,
            )
          ],
        ),
      );
    } else if (_isUpdatingFirestoreDocument) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Synchronizing STEPS data, please wait ...'),
            SizedBox(
              height: 12,
            ),
            CircularProgressIndicator(
              value: null,
            )
          ],
        ),
      );
    } else {
      return Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: <Widget>[
                Text(
                  'Welcome back!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: 6,
                ),
                c.healthData.steps == _totalSteps
                    ? Text('No new step data has been recorded by Google Fit since last sync. Check back later.')
                    : Text('Your steps data was synchronized succesfully. Thanks for contributing!'),
                SizedBox(
                  height: 74,
                ),
                Text("Your contribution:"),
                SizedBox(
                  height: 16,
                ),
                Text("- 94423 steps\n~ 78.4 km walked"),
                Container(
                  height: 200,
                  child: charts.TimeSeriesChart(
                    seriesList,
                    animate: true,
                    // Optionally pass in a [DateTimeFactory] used by the chart. The factory
                    // should create the same type of [DateTime] as the data provided. If none
                    // specified, the default creates local date time.
                    dateTimeFactory: const charts.LocalDateTimeFactory(),
                  ),
                )
              ],
            ),
          ),
        ],
      );
    }
  }

  void updateFirestore() {
    if (!_isLoadingGoogleFitData && !_hasSynchronizedData) {
      Future.delayed(const Duration(seconds: 2), () async {
        await updateFirecloudData(c.user.userId, HealthData(lastSync: _lastSync, steps: _totalSteps));
        setState(() {
          _isUpdatingFirestoreDocument = false;
          _hasSynchronizedData = true;
        });
      });
    }
  }

  void _showInfoDialog() {
    showDialog(
        context: context,
        barrierDismissible: false,
        //context: _scaffoldKey.currentContext,
        builder: (context) {
          return AlertDialog(
            contentPadding: EdgeInsets.only(left: 25, right: 25),
            title: Center(child: Text("Challenge information")),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  SizedBox(
                    height: 18,
                  ),
                  Text(
                    '"To the Moon and back!"',
                    textAlign: TextAlign.left,
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  Text(
                    'Prize:\nOne lucky winner will receive an "Electric Scooter 2000". Two users will each receive one (1) 30€ Spotify Pro gift card.',
                    style: TextStyle(),
                    textAlign: TextAlign.left,
                  ),
                  SizedBox(
                    height: 6,
                  ),
                  Text(
                    "Rules:",
                    style: TextStyle(fontSize: 14),
                  ),
                  Text(
                    "In order to participate in the contest, the user must have contributed at least 30 000 steps. Of all eligible users, one is randomly selected for the main prize and two are randomly selected for the 'Gift card' prizes.",
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Close'),
                onPressed: () {
                  Get.back();
                },
              ),
            ],
          );
        });
  }
}
