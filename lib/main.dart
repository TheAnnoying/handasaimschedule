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
            theme: getThemeData(colorScheme: ColorScheme.fromSeed(dynamicSchemeVariant: DynamicSchemeVariant.neutral, seedColor: lightDynamic?.primary ?? Colors.blue, brightness: Brightness.light)),
            darkTheme: getThemeData(colorScheme: ColorScheme.fromSeed(dynamicSchemeVariant: DynamicSchemeVariant.neutral, seedColor: darkDynamic?.primary ?? Colors.blue, brightness: Brightness.dark)),
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
                        centerTitle: true,
                        automaticallyImplyLeading: false,
                        primary: true,
                        forceMaterialTransparency: true,
                        title: Text("מערכת הנדסאים"),
                      ),
                      body: Align(
                        alignment: Alignment.topCenter,
                        child: SchedulePage(schedule: schedule)
                      ),
                      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
                      floatingActionButton: FloatingActionButton.extended(
                        icon: Icon(Icons.edit),
                        tooltip: "החלפת המידע המוצג",
                        label: Text(_selectedName),
                        onPressed: () => showDialog(context: context, builder: (context) {
                          return Dialog(
                            constraints: BoxConstraints.loose(Size.fromWidth(400)),
                            clipBehavior: Clip.hardEdge,
                            child: DefaultTabController(
                              length: 3,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Material(
                                    color: Theme.of(context).colorScheme.surfaceContainer,
                                    child: TabBar(
                                      enableFeedback: true,
                                      splashBorderRadius: BorderRadius.circular(24),
                                      tabs: [
                                        Tab(icon: Icon(Icons.school), text: "לפי כיתה"),
                                        Tab(icon: Icon(Icons.person), text: "לפי מורה"),
                                        Tab(icon: Icon(Icons.square_foot), text: "לפי מקצוע")
                                      ]
                                    ),
                                  ),
                                  SizedBox(
                                    height: 500,
                                    child: TabBarView(
                                      children: [
                                        schedule.getClasses().isEmpty
                                          ? Center(child: Text('לא נמצאו כיתות.', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)))
                                          : radioGroupSelect(context, schedule, "class", schedule.getClasses()),
                                        radioGroupSelect(context, schedule, "teacher", schedule.teacherList.toList()..sort()),
                                        radioGroupSelect(context, schedule, "subject", schedule.subjectList.toList()..sort()),
                                      ],
                                    )
                                  ),
                                ],
                              )
                              ),
                          );
                        }
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

  SingleChildScrollView radioGroupSelect(BuildContext context, Schedule schedule, String type, List<String> options) {
    return SingleChildScrollView(
      child: Directionality(
        textDirection: TextDirection.rtl,
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if(type == "teacher") ListTile(
                tileColor: Theme.of(context).splashColor,
                contentPadding: EdgeInsets.all(16),
                leading: Icon(Icons.warning),
                subtitle: Text('רשימת המורים בנויה מהמורים שיש להם שעות היום.\nבתור מורה יש מצב שלא תימצא ברשימה הזו.'),
              ),
              ...options.map((name) {
                return RadioListTile(
                  value: name,
                  title: Text(name)
                );
              })
            ]
          )
        ),
      ),
    );
  }
}