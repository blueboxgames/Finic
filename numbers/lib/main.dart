import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:numbers/dialogs/daily.dart';
import 'package:numbers/dialogs/quests.dart';
import 'package:numbers/dialogs/quit.dart';
import 'package:numbers/dialogs/start.dart';
import 'package:numbers/utils/ads.dart';
import 'package:numbers/utils/analytic.dart';
import 'package:numbers/utils/localization.dart';
import 'package:numbers/utils/notification.dart';
import 'package:numbers/utils/prefs.dart';
import 'package:numbers/utils/sounds.dart';
import 'package:numbers/utils/themes.dart';
import 'package:numbers/utils/utils.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp();
  @override
  AppState createState() => AppState();
  static AppState? of(BuildContext context) =>
      context.findAncestorStateOfType<AppState>();
}

class AppState extends State<MyApp> {
  ThemeData _themeData = Themes.darkData;
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    return MaterialApp(
        theme: _themeData,
        builder: (BuildContext context, Widget? child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1),
            child: child!),
        home: MainPage());
  }

  updateTheme() async {
    await Future.delayed(const Duration(milliseconds: 1));
    _themeData = Themes.darkData;
    setState(() {});
  }
}

class MainPage extends StatefulWidget {
  MainPage({Key? key}) : super(key: key);
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _loadingState = 0;
  @override
  Widget build(BuildContext context) {
    if (Device.size == Size.zero) {
      Device.size = MediaQuery.of(context).size;
      Device.ratio = Device.size.height / 764;
      Device.aspectRatio = Device.size.width / Device.size.height;
      print("${Device.size} ${MediaQuery.of(context).devicePixelRatio}");
      MyApp.of(context)!.updateTheme();
      return SizedBox();
    }

    _initServices();
    return WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
            body: _loadingState < 2
                ? SizedBox()
                : SizedBox(
                    width: Device.size.width,
                    height: Device.size.height,
                    child: StartDialog())));
  }

  Future<bool> _onWillPop() async {
    var result =
        await Rout.push(context, QuitDialog(), barrierDismissible: true);
    return result != null;
  }

  _initServices() async {
    if (_loadingState > 0) return;
    _loadingState = 1;

    Sound.init();
    Prefs.init(() async {
      await Localization.init();
      Analytics.init();
      Days.init();
      Quests.init();
      Notifier.init();
      Ads.init();
      _loadingState = 2;
      setState(() {});
    });
  }
}
