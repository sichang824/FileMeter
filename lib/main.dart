import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'controllers/file_controller.dart';
import 'services/file_service.dart';
import 'screens/home_screen.dart';
import 'controllers/settings_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init('settings');
  Get.put(SettingsController());
  Get.lazyPut<FileService>(
      () => FileService(settingsController: Get.find<SettingsController>()),
      fenix: true);
  Get.put(FileController(fileService: Get.find<FileService>()));
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      home: HomeScreen(),
      defaultTransition: Transition.fade,
      title: 'FileMeter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}
