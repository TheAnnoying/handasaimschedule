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
                        centerTitle: false,
                        titleSpacing: 24,
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
                            child: DefaultTabController(
                              length: 2,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TabBar(
                                    splashBorderRadius: BorderRadius.circular(26),
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
                                          : SingleChildScrollView(
                                              child: Directionality(
                                                textDirection: TextDirection.rtl,
                                                child: RadioGroup<String>(
                                                  groupValue: _selectedName,
                                                  onChanged: (String? value) {
                                                    setState(() {
                                                      _selectedName = value ?? "ז'1";
                                                    });
                                                
                                                    AppStorage.set("selectedName", value);
                                                    AppStorage.set("selectedType", "class");
                                                    Navigator.pop(context); 
                                                  },
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.end,
                                                    children: [
                                                      ...schedule.getClasses().map((name) {
                                                        return RadioListTile(
                                                          value: name,
                                                          title: Text(name)
                                                        );
                                                      })
                                                    ]
                                                  )
                                                ),
                                              ),
                                            ),
                                          SingleChildScrollView(
                                            child: Directionality(
                                              textDirection: TextDirection.rtl,
                                              child: RadioGroup<String>(
                                                groupValue: _selectedName,
                                                onChanged: (String? value) {
                                                  setState(() {
                                                    _selectedName = value ?? (schedule.teacherList.toList()..sort()).first;
                                                  });
                                              
                                                  AppStorage.set("selectedName", value);
                                                  AppStorage.set("selectedType", "teacher");
                                                  Navigator.pop(context);                                                 
                                                },
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.end,
                                                  children: [
                                                    ...(schedule.teacherList.toList()..sort()).map((name) {
                                                      return RadioListTile(
                                                        value: name,
                                                        title: Text(name),
                                                      );
                                                    })
                                                  ]
                                                )
                                              ),
                                            ),
                                          )
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
}

class _RadioListTab extends StatefulWidget {
  final String selectedName;
  final Schedule schedule;
  final String type;
  const _RadioListTab({required this.selectedName, required this.schedule, required this.type});

  @override
  State<_RadioListTab> createState() => _RadioListTabState();
}

class _RadioListTabState extends State<_RadioListTab> {
  @override
  Widget build(BuildContext context) {
    String? selectedName = widget.selectedName;

    return SingleChildScrollView(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: RadioGroup<String>(
          groupValue: selectedName,
          onChanged: (String? value) {
            setState(() {
              selectedName = value;
            });
        
            AppStorage.set("selectedName", value);
            AppStorage.set("selectedType", widget.type);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ...(widget.type == "teacher" ? (widget.schedule.teacherList.toList()..sort()) : widget.schedule.getClasses()).map((name) {
                return ListTile(
                  title: Text(name),
                  leading: Radio<String>(value: name),
                );
              })
            ]
          )
        ),
      ),
    );
  }
}