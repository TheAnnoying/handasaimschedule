import 'package:handasaimschedule/fetchers/schedule_fetcher.dart';
import 'package:handasaimschedule/fetchers/app_storage.dart';
import 'package:handasaimschedule/theme/dynamic_theme.dart';
import 'package:handasaimschedule/widgets/schedule.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppStorage.init();

  runApp(ProviderScope(child: App()));
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  String _selectedName = AppStorage.get("selectedName") ?? "ז'1";

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
            theme: getThemeData(colorScheme: ColorScheme.fromSeed(dynamicSchemeVariant: DynamicSchemeVariant.tonalSpot, seedColor: lightDynamic?.primary ?? Colors.blue, brightness: Brightness.light)),
            darkTheme: getThemeData(colorScheme: ColorScheme.fromSeed(dynamicSchemeVariant: DynamicSchemeVariant.tonalSpot, seedColor: darkDynamic?.primary ?? Colors.blue, brightness: Brightness.dark)),
            debugShowCheckedModeBanner: false,
            home: Directionality(textDirection: TextDirection.rtl,
              child: Consumer(
                builder: (context, ref, _) {
                  final scheduleState = ref.watch(scheduleProvider);

                  return scheduleState.when(
                    loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
                    error: (_, _) => const Scaffold(body: Center(child: Text('שגיאה בטעינת המערכת'))),
                    data: (schedule) => Scaffold(
                      appBar: AppBar(
                        centerTitle: false,
                        titleSpacing: 24,
                        automaticallyImplyLeading: false,
                        primary: true,
                        forceMaterialTransparency: true,
                        title: Text("מערכת הנדסאים"),
                      ),
                      body: SchedulePage(schedule: schedule),
                      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
                      floatingActionButton: FloatingActionButton.extended(
                        icon: Icon(Icons.edit),
                        tooltip: "החלפת המידע המוצג",
                        label: Text(_selectedName),
                        onPressed: () => showModalBottomSheet(context: context, isScrollControlled: true, builder: (context) => DefaultTabController(
                          length: 2,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TabBar(
                                splashBorderRadius: BorderRadius.circular(27),
                                tabs: [
                                  Tab(icon: Icon(Icons.book), text: "לפי כיתה"),
                                  Tab(icon: Icon(Icons.school), text: "לפי מורה"),
                                ]
                              ),
                              SizedBox(
                                height: 500,
                                child: TabBarView(
                                  children: [
                                    schedule.getClasses().isEmpty
                                      ? Center(child: Text('לא נמצאו כיתות.', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)))
                                      : Center(
                                        child: SingleChildScrollView(
                                          child: Directionality(
                                            textDirection: TextDirection.rtl,
                                            child: RadioGroup<String>(
                                              groupValue: _selectedName,
                                              onChanged: (String? value) {
                                                setState(() {
                                                  _selectedName = value ?? "ז'1";
                                                });
                                              
                                                AppStorage.set("selectedName", value ?? "ז'1");
                                                AppStorage.set("selectedType", "class");
                                              },
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                children: [
                                                  ...schedule.getClasses().map((className) {
                                                    return ListTile(
                                                      title: Text(className),
                                                      leading: Radio<String>(value: className),
                                                    );
                                                  })
                                                ]
                                              )
                                            ),
                                          ),
                                        ),
                                      ),
                                    Center(
                                      child: SingleChildScrollView(
                                          child: Directionality(
                                            textDirection: TextDirection.rtl,
                                            child: RadioGroup<String>(
                                              groupValue: _selectedName,
                                              onChanged: (String? value) {
                                                setState(() {
                                                  _selectedName = value ?? "לפל לורטה";
                                                });

                                                AppStorage.set("selectedName", value ?? "לפל לורטה");
                                                AppStorage.set("selectedType", "teacher");
                                              },
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                children: [
                                                  ...schedule.teacherList.map((teacherName) {
                                                    return ListTile(
                                                      title: Text(teacherName),
                                                      leading: Radio<String>(value: teacherName),
                                                    );
                                                  })
                                                ]
                                              )
                                            ),
                                          ),
                                        ),
                                    )
                                  ],
                                )
                              ),
                            ],
                          )
                          )
                        )
                      ),
                    )
                  );
                }
              ),
            )
          );
        }
      );
  }
}
