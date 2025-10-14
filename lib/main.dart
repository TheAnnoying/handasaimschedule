import 'dart:async';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:handasaimschedule/fetchers/appstorage.dart';
import 'package:handasaimschedule/fetchers/fetcher.dart';
import 'package:handasaimschedule/pages/settings/settings.dart';
import 'package:handasaimschedule/pages/schedule/schedule.dart';
import 'package:handasaimschedule/theme/dynamic_theme.dart';

Future<void> refresh(bool full) async {
  await Data.fetchClassNames();
  await Data.fetchSchedule();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AppStorage.init();
  refresh(true);

  runApp(const App());
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  int currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
      return DynamicColorBuilder(
        builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
          return MaterialApp(
            title: "מערכת הנדסאים",
            theme: getThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Color(AppStorage.get("color-app") ?? (lightDynamic?.primary.toARGB32() ?? Colors.lightBlue.toARGB32())), brightness: Brightness.light)),
            darkTheme: getThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Color(AppStorage.get("color-app") ?? (darkDynamic?.primary.toARGB32() ?? Colors.lightBlue.toARGB32())), brightness: Brightness.dark)),
            debugShowCheckedModeBanner: false,
            home: Directionality(textDirection: TextDirection.rtl, child:
              Scaffold(
                appBar: AppBar(
                  automaticallyImplyLeading: false,
                  backgroundColor: Colors.transparent,
                  primary: true,
                  actionsPadding: EdgeInsets.all(8),
                  title: Text('מערכת הנדסאים', style: TextStyle(letterSpacing: 0.1)),
                  actions: <Widget>[
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () async { refresh(true); },
                    ),
                  ],
                ),
                bottomNavigationBar: NavigationBar(
                  onDestinationSelected: (int index) {
                    setState(() {
                      currentPageIndex = index;
                    });
                  },
                  selectedIndex: currentPageIndex,
                  destinations: const <Widget>[
                    NavigationDestination(
                      selectedIcon: Icon(Icons.home),
                      icon: Icon(Icons.home_outlined),
                      label: 'מערכת'
                    ),
                    NavigationDestination(
                      selectedIcon: Icon(Icons.settings),
                      icon: Icon(Icons.settings_outlined),
                      label: 'הגדרות'
                    )
                  ],
                ),
              body: <Widget>[
                SchedulePage(),
                SettingsPage()
              ][currentPageIndex]
              ),
            )
          );
        }
      );
  }
}

