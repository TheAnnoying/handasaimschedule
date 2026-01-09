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
  bool _rawMode = AppStorage.get("rawMode") ?? false;

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
          theme: getThemeData(colorScheme: ColorScheme.fromSeed(dynamicSchemeVariant: .tonalSpot, seedColor: lightDynamic?.primary ?? Colors.grey, brightness: .light)),
          darkTheme: getThemeData(colorScheme: ColorScheme.fromSeed(dynamicSchemeVariant: .tonalSpot, seedColor: darkDynamic?.primary ?? Colors.grey, brightness: .dark)),
          debugShowCheckedModeBanner: false,
          home: Directionality(
            textDirection: .rtl,
            child: Consumer(
              builder: (context, ref, _) {
                final scheduleState = ref.watch(scheduleProvider);

                return scheduleState.when(
                  loading: () => Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  ),
                  error: (_, _) => Scaffold(
                    body: Center(child: Text('שגיאה בטעינת המערכת')),
                  ),
                  data: (schedule) => Scaffold(
                    appBar: AppBar(
                      forceMaterialTransparency: true,
                      centerTitle: true,
                      automaticallyImplyLeading: false,
                      primary: true,
                      title: Text("מערכת הנדסאים"),
                    ),
                    body: Align(
                      alignment: .topCenter,
                      child: SizedBox(width: 500, child: SchedulePage(schedule: schedule, raw: _rawMode)),
                    ),
                    floatingActionButtonLocation: .startFloat,
                    floatingActionButton: FloatingActionButton.extended(
                      icon: Icon(Icons.edit),
                      tooltip: "החלפת המידע המוצג",
                      label: Text(_selectedName),
                      onPressed: () => showDialog(
                        context: context,
                        builder: (context) {
                          return Dialog(
                            constraints: .loose(
                              Size.fromWidth(400),
                            ),
                            clipBehavior: .hardEdge,
                            child: DefaultTabController(
                              length: 3,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Material(
                                    color: Theme.of(
                                      context,
                                    ).scaffoldBackgroundColor.withOpacity(0.5),
                                    child: TabBar(
                                      enableFeedback: true,
                                      splashBorderRadius: .circular(
                                        24,
                                      ),
                                      tabs: [
                                        Tab(
                                          icon: Icon(Icons.school),
                                          text: "לפי כיתה",
                                        ),
                                        Tab(
                                          icon: Icon(Icons.person),
                                          text: "לפי מורה",
                                        ),
                                        Tab(
                                          icon: Icon(Icons.settings),
                                          text: "הגדרות"
                                        )
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 500,
                                    child: TabBarView(
                                      children: [
                                        schedule.getClasses().isEmpty
                                            ? Center(
                                                child: Text(
                                                  'לא נמצאו כיתות.',
                                                  style: TextStyle(
                                                    color: Theme.of(
                                                      context,
                                                    ).colorScheme.onSurface,
                                                  ),
                                                ),
                                              )
                                            : radioGroupSelect(
                                                context,
                                                schedule,
                                                "class",
                                                schedule.getClasses(),
                                              ),
                                        radioGroupSelect(
                                          context,
                                          schedule,
                                          "teacher",
                                          schedule.teacherList.toList()..sort(),
                                        ),
                                        Directionality(
                                          textDirection: .rtl,
                                          child: Column(
                                            children: [
                                              SwitchListTile(
                                                title: Text("נתונים גולמיים"),
                                                subtitle: Text("הפעל אם אתה מוצא נתונים לא עקביים. פעולה זו תציג נתונים גולמיים אך תהפוך את לוח הזמנים למכוער ולא מעוצב במיוחד."),
                                                secondary: Icon(Icons.emergency),
                                                value: _rawMode,
                                                onChanged: (bool value) {
                                                  setState(() {
                                                    _rawMode = value;
                                                  });
                                            
                                                  AppStorage.set("rawMode", value);
                                              }),
                                            ]
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  SingleChildScrollView radioGroupSelect(
    BuildContext context,
    Schedule schedule,
    String type,
    List<String> options,
  ) {
    return SingleChildScrollView(
      child: Directionality(
        textDirection: .rtl,
        child: RadioGroup<String>(
          groupValue: _selectedName,
          onChanged: (String? value) {
            setState(() {
              _selectedName = value ?? options[0];
            });

            AppStorage.set("selectedName", value);
            AppStorage.set("selectedType", type);
            Navigator.pop(context);
          },
          child: Column(
            crossAxisAlignment: .center,
            children: [
              if (type == "teacher")
                ListTile(
                  tileColor: Theme.of(context).splashColor,
                  contentPadding: .all(16),
                  leading: Icon(Icons.warning),
                  subtitle: Text(
                    'רשימת המורים בנויה מהמורים שיש להם שעות היום.\nבתור מורה יש מצב שלא תימצא ברשימה הזו.',
                  ),
                ),
              ...options.map((name) {
                return RadioListTile(value: name, title: Text(name));
              }),
            ],
          ),
        ),
      ),
    );
  }
}