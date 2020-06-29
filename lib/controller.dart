import 'package:get/get.dart';
import 'package:save_the_earth/model/HelthData.dart';
import 'package:save_the_earth/model/User.dart';
import 'package:save_the_earth/data/repository.dart';

class Controller extends GetxController {
  static Controller get to => Get.find();

  User user;
  HealthData healthData;

  @override
  void onInit() async {
    await setUser();
    super.onInit();
  }

  Future<void> setUser() async {
    await Future.delayed(const Duration(seconds: 2), () async => user = await signInWithGoogle());
    healthData = await getFirecloudData(user.userId);
    update();
  }

  void updateHealthData(HealthData healthData) {
    this.healthData = healthData;
    update();
  }
}
